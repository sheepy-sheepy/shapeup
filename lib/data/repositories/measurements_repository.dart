import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/measurements_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../../core/enums.dart';
import '../../core/number_utils.dart';
import '../../domain/services/nutrition_calculator.dart';
import '../local/app_database.dart';

final measurementsRepositoryProvider =
    Provider<domain.MeasurementsRepository>((ref) {
  return MeasurementsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
  );
});

class MeasurementsRepository implements domain.MeasurementsRepository {
  MeasurementsRepository(this.db, this.auth);

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
      bodyFat = NutritionCalculator.bodyFatPercent(
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
  Future<List<BodyMeasurement>> allMeasurements() {
    final user = auth.currentUser;
    if (user == null) return Future.value([]);
    return (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id)))
        .get();
  }

  @override
  Future<BodyMeasurement?> measurementForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return null;

    return (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();
  }

  @override
  Future<BodyMeasurement?> latestMeasurementUpToDay(String dayKey) async {
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
    return rows.first;
  }

  @override
  Future<BodyMeasurement?> measurementForNormDay(String dayKey) async {
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
    return rows.first;
  }
}
