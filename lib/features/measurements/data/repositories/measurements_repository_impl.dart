import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart' as auth_domain;
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart' as domain;
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/numbers.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/local/entity_mappers.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';

class MeasurementsRepositoryImpl implements domain.MeasurementsRepository {
  MeasurementsRepositoryImpl(this.db, this.auth);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final _uuid = const Uuid();

  @override
  Future<void> saveMeasurement({
    required String dayKey,
    required double weightKg,
    required double neckCm,
    required double waistCm,
    required double hipsCm,
    required double heightCm,
    required Sex sex,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw const AppException(unauthorizedMessage);

    ensurePositive(weightKg, 'Вес');
    ensurePositive(neckCm, 'Шея');
    ensurePositive(waistCm, 'Талия');
    ensurePositive(hipsCm, 'Бедра');
    ensurePositive(heightCm, 'Рост');

    final roundedWeightKg = roundTo1(weightKg);
    final roundedNeckCm = roundTo1(neckCm);
    final roundedWaistCm = roundTo1(waistCm);
    final roundedHipsCm = roundTo1(hipsCm);
    final roundedHeightCm = roundTo1(heightCm);

    final double bodyFat;
    try {
      bodyFat = NutritionCalculationUseCase.bodyFatPercent(
        sex: sex,
        heightCm: roundedHeightCm,
        neckCm: roundedNeckCm,
        waistCm: roundedWaistCm,
        hipsCm: roundedHipsCm,
      );
    } catch (_) {
      throw const ValidationException(calculatedBodyFatInvalidMessage);
    }

    if (bodyFat.isNaN || bodyFat.isInfinite || bodyFat <= 0) {
      throw const ValidationException(calculatedBodyFatInvalidMessage);
    }

    final existing = await (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.bodyMeasurements)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        BodyMeasurementsCompanion(
          weightKg: drift.Value(roundedWeightKg),
          neckCm: drift.Value(roundedNeckCm),
          waistCm: drift.Value(roundedWaistCm),
          hipsCm: drift.Value(roundedHipsCm),
          bodyFatPercent: drift.Value(bodyFat),
        ),
      );
    } else {
      await db.into(db.bodyMeasurements).insert(
            BodyMeasurementsCompanion.insert(
              id: _uuid.v4(),
              userId: user.id,
              dayKey: dayKey,
              weightKg: roundedWeightKg,
              neckCm: roundedNeckCm,
              waistCm: roundedWaistCm,
              hipsCm: roundedHipsCm,
              bodyFatPercent: bodyFat,
            ),
          );
    }
  }

  @override
  Future<List<BodyMeasurementEntity>> allMeasurements() async {
    final user = auth.currentUser;
    if (user == null) return [];
    final rows = await (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id)))
        .get();
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<BodyMeasurementEntity?> measurementForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return null;

    final row = await (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  @override
  Future<BodyMeasurementEntity?> latestMeasurementUpToDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return null;

    final rows = await (db.select(db.bodyMeasurements)
          ..where((t) =>
              t.userId.equals(user.id) & t.dayKey.isSmallerOrEqualValue(dayKey))
          ..orderBy([
            (t) => drift.OrderingTerm.desc(t.dayKey),
          ])
          ..limit(1))
        .get();

    if (rows.isEmpty) return null;
    return rows.first.toEntity();
  }

  @override
  Future<BodyMeasurementEntity?> measurementForNormDay(String dayKey) async {
    final latest = await latestMeasurementUpToDay(dayKey);
    if (latest != null) return latest;

    final user = auth.currentUser;
    if (user == null) return null;

    final rows = await (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.dayKey),
          ])
          ..limit(1))
        .get();

    if (rows.isEmpty) return null;
    return rows.first.toEntity();
  }
}
