import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/onboarding_data.dart';
import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/profile_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../../core/date_utils.dart';
import '../../core/enums.dart';
import '../../core/number_utils.dart';
import '../../domain/services/nutrition_calculator.dart';
import '../local/app_database.dart';
import '../remote/supabase_provider.dart';

final profileRepositoryProvider = Provider<domain.ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
  );
});

class ProfileRepository implements domain.ProfileRepository {
  ProfileRepository(this.db, this.client, this.auth);

  final AppDatabase db;
  final SupabaseClient client;
  final auth_domain.AuthRepository auth;
  final _uuid = const Uuid();

  @override
  Future<void> completeOnboarding(OnboardingData data) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    await auth.waitForRemoteSessionWarmUp(
      maxWait: const Duration(seconds: 12),
    );

    final remoteUserId = auth.activeRemoteUserId;
    if (remoteUserId == null) {
      throw const AppException(
        'Для завершения onboarding нужно интернет-соединение. Проверьте подключение и повторите попытку.',
      );
    }

    final email = auth.currentEmail ?? user.email ?? '';
    final dayKey = dayKeyFromDate(DateTime.now());
    final heightCm = roundTo1(data.heightCm);
    final weightKg = roundTo1(data.weightKg);
    final neckCm = roundTo1(data.neckCm);
    final waistCm = roundTo1(data.waistCm);
    final hipsCm = roundTo1(data.hipsCm);

    final bodyFat = NutritionCalculator.bodyFatPercent(
      sex: data.sex,
      heightCm: heightCm,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );

    final payload = <String, dynamic>{
      'id': remoteUserId,
      'email': email,
      'registration_status': RegistrationStatus.fullyRegistered.value,
      'name': data.name,
      'sex': data.sex.name,
      'goal': data.goal.name,
      'activity_level': data.activityLevel.name,
      'height_cm': heightCm,
      'deficit_kcal': data.deficitKcal,
      'date_of_birth': _dateOnly(data.dateOfBirth),
      'latest_measurement_day_key': dayKey,
      'latest_weight_kg': weightKg,
      'latest_neck_cm': neckCm,
      'latest_waist_cm': waistCm,
      'latest_hips_cm': hipsCm,
      'latest_body_fat_percent': bodyFat,
    };

    final savedProfile = await client
        .from('profiles')
        .upsert(payload, onConflict: 'id')
        .select('registration_status')
        .single();

    final savedStatus = savedProfile['registration_status'] as String?;
    if (savedStatus != RegistrationStatus.fullyRegistered.value) {
      throw const AppException(
        'Не удалось завершить onboarding в Supabase. Повторите попытку.',
      );
    }

    await db.into(db.localUsers).insertOnConflictUpdate(
          LocalUsersCompanion.insert(
            userId: remoteUserId,
            email: email,
            registrationStatus: RegistrationStatus.fullyRegistered.value,
            name: Value(data.name),
            sex: Value(data.sex.name),
            goal: Value(data.goal.name),
            activityLevel: Value(data.activityLevel.name),
            heightCm: Value(heightCm),
            deficitKcal: Value(data.deficitKcal),
            dateOfBirth: Value(data.dateOfBirth),
          ),
        );

    await db.into(db.bodyMeasurements).insertOnConflictUpdate(
          BodyMeasurementsCompanion.insert(
            id: _uuid.v4(),
            userId: remoteUserId,
            dayKey: dayKey,
            weightKg: weightKg,
            neckCm: neckCm,
            waistCm: waistCm,
            hipsCm: hipsCm,
            bodyFatPercent: bodyFat,
          ),
        );
  }

  @override
  Future<void> updateProfileSettings({
    required String name,
    required String sex,
    required String goal,
    required String activityLevel,
    required double heightCm,
    required double deficitKcal,
    required DateTime dateOfBirth,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final roundedHeightCm = roundTo1(heightCm);

    await auth.waitForRemoteSessionWarmUp(
      maxWait: const Duration(seconds: 12),
    );

    final remoteUserId = auth.activeRemoteUserId;
    if (remoteUserId == null) {
      throw const AppException(
        'Нет интернет-соединения. Проверьте подключение и повторите попытку.',
      );
    }

    final latestLocalMeasurement = await _latestLocalMeasurement(user.id);
    final bodyFatSource = latestLocalMeasurement == null
        ? await _fetchProfileMeasurementForBodyFat(remoteUserId)
        : _ProfileBodyValues.fromLocal(latestLocalMeasurement);

    if (bodyFatSource == null) {
      throw const ValidationException(
        'Для пересчета % жира нет сохраненных параметров тела.',
      );
    }

    final recalculatedLatestBodyFatPercent =
        _calculateBodyFatForSettingsOrThrow(
      values: bodyFatSource,
      heightCm: roundedHeightCm,
      sexName: sex,
    );

    final todayKey = dayKeyFromDate(DateTime.now());
    final todayLocalMeasurement =
        await _localMeasurementForDay(user.id, todayKey);

    final double? recalculatedTodayBodyFatPercent;
    if (todayLocalMeasurement != null &&
        todayLocalMeasurement.id != latestLocalMeasurement?.id) {
      recalculatedTodayBodyFatPercent = _calculateBodyFatForSettingsOrThrow(
        values: _ProfileBodyValues.fromLocal(todayLocalMeasurement),
        heightCm: roundedHeightCm,
        sexName: sex,
      );
    } else {
      recalculatedTodayBodyFatPercent = null;
    }

    final updateMap = <String, dynamic>{
      'name': name,
      'sex': sex,
      'goal': goal,
      'activity_level': activityLevel,
      'height_cm': roundedHeightCm,
      'deficit_kcal': deficitKcal,
      'date_of_birth': _dateOnly(dateOfBirth),
      'latest_body_fat_percent': recalculatedLatestBodyFatPercent,
    };

    try {
      await _withSupabaseTimeout(
        client.from('profiles').update(updateMap).eq('id', remoteUserId),
        operationName: 'сохранение параметров пользователя',
      );
    } catch (e) {
      throw AppException(
        russianErrorMessage(
          e,
          fallback:
              'Не удалось сохранить параметры пользователя. Проверьте интернет и повторите попытку.',
        ),
      );
    }

    await db.into(db.localUsers).insertOnConflictUpdate(
          LocalUsersCompanion.insert(
            userId: user.id,
            email: user.email ?? '',
            registrationStatus: RegistrationStatus.fullyRegistered.value,
            name: Value(name),
            sex: Value(sex),
            goal: Value(goal),
            activityLevel: Value(activityLevel),
            heightCm: Value(roundedHeightCm),
            deficitKcal: Value(deficitKcal),
            dateOfBirth: Value(dateOfBirth),
          ),
        );

    if (latestLocalMeasurement != null) {
      await (db.update(db.bodyMeasurements)
            ..where((t) => t.id.equals(latestLocalMeasurement.id)))
          .write(
        BodyMeasurementsCompanion(
          bodyFatPercent: Value(recalculatedLatestBodyFatPercent),
        ),
      );
    }

    if (todayLocalMeasurement != null &&
        recalculatedTodayBodyFatPercent != null) {
      await (db.update(db.bodyMeasurements)
            ..where((t) => t.id.equals(todayLocalMeasurement.id)))
          .write(
        BodyMeasurementsCompanion(
          bodyFatPercent: Value(recalculatedTodayBodyFatPercent),
        ),
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = auth.currentUser;
    if (user?.email == null) {
      throw const AppException('Пользователь не найден');
    }

    await auth.waitForRemoteSessionWarmUp();
    if (auth.activeRemoteUserId == null) {
      throw const AppException(
        'Нет интернет-соединения. Проверьте подключение и повторите попытку.',
      );
    }

    final oldValue = currentPassword;
    final newValue = newPassword;

    if (oldValue.isEmpty || newValue.isEmpty) {
      throw const ValidationException('Введите старый и новый пароль');
    }

    if (newValue.length < 6) {
      throw const ValidationException(
        'Новый пароль не соответствует требованиям. Используйте минимум 6 символов.',
      );
    }

    try {
      await client.auth.signInWithPassword(
        email: user!.email!,
        password: oldValue,
      );
    } catch (e) {
      throw AppException(
        russianErrorMessage(
          e,
          fallback: 'Неверный текущий пароль.',
        ),
      );
    }

    if (oldValue == newValue) {
      throw const ValidationException(
          'Новый пароль должен отличаться от старого');
    }

    try {
      await client.auth.updateUser(UserAttributes(password: newValue));
    } catch (e) {
      throw AppException(
        russianErrorMessage(
          e,
          fallback: 'Не удалось изменить пароль. Повторите попытку.',
        ),
      );
    }

    await auth.cacheLocalPasswordForCurrentUser(password: newValue);
  }

  @override
  Future<LocalUser?> getCurrentLocalUser() async {
    final userId = auth.currentUserId;
    if (userId == null) return null;

    return (db.select(db.localUsers)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<BodyMeasurement?> _latestLocalMeasurement(String userId) async {
    final rows = await (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.dayKey),
          ])
          ..limit(1))
        .get();

    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<BodyMeasurement?> _localMeasurementForDay(
    String userId,
    String dayKey,
  ) {
    return (db.select(db.bodyMeasurements)
          ..where((t) => t.userId.equals(userId) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();
  }

  Future<T> _withSupabaseTimeout<T>(
    Future<T> future, {
    required String operationName,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return future.timeout(
      timeout,
      onTimeout: () {
        throw AppException(
          'Не удалось выполнить $operationName. Проверьте интернет и повторите попытку.',
        );
      },
    );
  }

  Future<_ProfileBodyValues?> _fetchProfileMeasurementForBodyFat(
    String remoteUserId,
  ) async {
    try {
      final row = await _withSupabaseTimeout(
        client
            .from('profiles')
            .select(
              'latest_measurement_day_key, latest_weight_kg, latest_neck_cm, '
              'latest_waist_cm, latest_hips_cm',
            )
            .eq('id', remoteUserId)
            .maybeSingle(),
        operationName: 'получение параметров тела для пересчета % жира',
      );

      if (row == null) return null;

      return _ProfileBodyValues.fromProfileMap(
        Map<String, dynamic>.from(row as Map),
      );
    } catch (e) {
      throw AppException(
        russianErrorMessage(
          e,
          fallback: 'Не удалось получить параметры тела для пересчета % жира.',
        ),
      );
    }
  }

  double _calculateBodyFatForSettingsOrThrow({
    required _ProfileBodyValues values,
    required double heightCm,
    required String sexName,
  }) {
    final userSex = Sex.values.firstWhere(
      (e) => e.name == sexName,
      orElse: () => Sex.male,
    );

    try {
      final bodyFat = NutritionCalculator.bodyFatPercent(
        sex: userSex,
        heightCm: heightCm,
        neckCm: roundTo1(values.neckCm),
        waistCm: roundTo1(values.waistCm),
        hipsCm: roundTo1(values.hipsCm),
      );

      if (!bodyFat.isFinite || bodyFat <= 0) {
        throw const FormatException('Invalid body fat');
      }

      return bodyFat;
    } catch (_) {
      throw const ValidationException(
        'Пересчитанный % жира должен быть числом больше 0. Проверьте рост и параметры тела.',
      );
    }
  }

  String _dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _ProfileBodyValues {
  const _ProfileBodyValues({
    required this.weightKg,
    required this.neckCm,
    required this.waistCm,
    required this.hipsCm,
    this.dayKey,
  });

  final double weightKg;
  final double neckCm;
  final double waistCm;
  final double hipsCm;
  final String? dayKey;

  factory _ProfileBodyValues.fromLocal(BodyMeasurement measurement) {
    return _ProfileBodyValues(
      dayKey: measurement.dayKey,
      weightKg: measurement.weightKg,
      neckCm: measurement.neckCm,
      waistCm: measurement.waistCm,
      hipsCm: measurement.hipsCm,
    );
  }

  static _ProfileBodyValues? fromProfileMap(Map<String, dynamic> row) {
    final weightKg = _doubleFromAny(row['latest_weight_kg']);
    final neckCm = _doubleFromAny(row['latest_neck_cm']);
    final waistCm = _doubleFromAny(row['latest_waist_cm']);
    final hipsCm = _doubleFromAny(row['latest_hips_cm']);

    if (weightKg == null ||
        neckCm == null ||
        waistCm == null ||
        hipsCm == null) {
      return null;
    }

    if (weightKg <= 0 || neckCm <= 0 || waistCm <= 0 || hipsCm <= 0) {
      return null;
    }

    return _ProfileBodyValues(
      dayKey: row['latest_measurement_day_key'] as String?,
      weightKg: weightKg,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  static double? _doubleFromAny(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }
}
