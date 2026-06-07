import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/preferences.dart';
import 'package:shapeup/core/shared/numbers.dart';
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart' as domain;
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/local/entity_mappers.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

const _explicitSignOutKey = 'auth_explicit_sign_out';
const _startedButUnfinishedOnboardingKey =
    'auth_started_but_unfinished_onboarding';
const _lastSignedInUserIdKey = 'auth_last_signed_in_user_id';
const _authRequestTimeout = Duration(seconds: 12);
const _profilePushTimeout = Duration(seconds: 8);

class AuthRepositoryImpl implements domain.AuthRepository {
  AuthRepositoryImpl(
    this.client,
    this.db,
    this.preferences,
    this.credentialsStore,
  );

  final SupabaseClient client;
  final AppDatabase db;
  final PreferencesService preferences;
  final AuthLocalCredentialsStore credentialsStore;

  User? _offlineUser;
  Future<void>? _remoteSessionWarmUp;

  User? get _remoteUser =>
      client.auth.currentSession?.user ?? client.auth.currentUser;

  @override
  String? get activeRemoteUserId => client.auth.currentSession?.user.id;

  @override
  User? get currentUser => _remoteUser ?? _offlineUser;
  @override
  String? get currentUserId => currentUser?.id;
  @override
  String? get currentEmail => currentUser?.email;

  @override
  Future<User?> waitForRestoredCurrentUser({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final user = currentUser;
      if (user != null) return user;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return currentUser;
  }

  @override
  Future<bool> wasExplicitlySignedOut() async {
    return preferences.getBool(_explicitSignOutKey);
  }

  Future<void> _setExplicitSignOut(bool value) async {
    await preferences.setBool(_explicitSignOutKey, value);
  }

  @override
  Future<bool> hasStartedButUnfinishedOnboarding() {
    return preferences.getBool(_startedButUnfinishedOnboardingKey);
  }

  @override
  Future<void> markOnboardingStarted() {
    return preferences.setBool(_startedButUnfinishedOnboardingKey, true);
  }

  @override
  Future<void> clearStartedButUnfinishedOnboarding() {
    return preferences.remove(_startedButUnfinishedOnboardingKey);
  }

  @override
  Future<void> signOutAfterInterruptedOnboarding() async {
    await signOut(explicit: true);
    await clearStartedButUnfinishedOnboarding();
  }

  Future<void> _saveLastSignedInUser({
    required String userId,
    required String email,
  }) async {
    await preferences.setString(_lastSignedInUserIdKey, userId);
  }

  Future<LocalUserEntity?> _localUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final rows = await db.select(db.localUsers).get();

    for (final row in rows) {
      if (row.email.trim().toLowerCase() == normalized) {
        return row.toEntity();
      }
    }

    return null;
  }

  Future<LocalUserEntity?> _lastLocalUser() async {
    final userId = await preferences.getString(_lastSignedInUserIdKey);

    if (userId == null || userId.isEmpty) return null;

    final row = await (db.select(db.localUsers)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
    return row?.toEntity();
  }

  void _enableOfflineUser({
    required String userId,
    required String email,
  }) {
    _offlineUser = User.fromJson({
      'id': userId,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<RegistrationStatus?> restoreLastLocalSessionIfAllowed() async {
    if (await wasExplicitlySignedOut()) return null;

    final row = await _lastLocalUser();
    if (row == null) return null;

    _enableOfflineUser(userId: row.userId, email: row.email);
    return RegistrationStatus.fromValue(row.registrationStatus);
  }

  @override
  Future<RegistrationStatus?> signInLocalIfExists({
    required String email,
    String? password,
    bool warmUpRemoteSession = false,
  }) async {
    final row = await _localUserByEmail(email);
    if (row == null) return null;

    if (password != null) {
      final credentialState = await credentialsStore.checkPassword(
        userId: row.userId,
        email: row.email,
        password: password,
      );

      switch (credentialState) {
        case LocalPasswordCheck.match:
          break;
        case LocalPasswordCheck.mismatch:
          throw const AppException(loginCredentialsNotFoundMessage);
        case LocalPasswordCheck.missing:
          await _verifyLocalUserPasswordThroughSupabaseAndCache(
            row: row,
            email: email,
            password: password,
          );
          break;
      }
    }

    _enableOfflineUser(userId: row.userId, email: row.email);
    await _saveLastSignedInUser(userId: row.userId, email: row.email);
    await _setExplicitSignOut(false);

    if (warmUpRemoteSession && password != null && password.isNotEmpty) {
      startRemoteSessionWarmUpForLocalAccount(
        email: row.email,
        password: password,
      );
    }

    return RegistrationStatus.fromValue(row.registrationStatus);
  }

  @override
  void startRemoteSessionWarmUpForLocalAccount({
    required String email,
    required String password,
  }) {
    _remoteSessionWarmUp = _signInRemoteAndPushLocalChanges(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> waitForRemoteSessionWarmUp({
    Duration maxWait = const Duration(seconds: 4),
  }) async {
    final pending = _remoteSessionWarmUp;
    if (pending == null) return;

    try {
      await pending.timeout(maxWait);
    } catch (_) {}
  }

  Future<void> _signInRemoteAndPushLocalChanges({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _withAuthTimeout(
        client.auth.signInWithPassword(email: email, password: password),
      );
      final user = response.user ?? _remoteUser;
      if (user == null) return;

      _offlineUser = null;
      await _saveLastSignedInUser(userId: user.id, email: user.email ?? email);
      await credentialsStore.savePassword(
        userId: user.id,
        email: user.email ?? email,
        password: password,
      );
      await _setExplicitSignOut(false);
      _pushLocalProfileInBackground();
    } catch (_) {}
  }

  @override
  Future<void>
      pushLocalProfileAndLatestMeasurementToSupabaseIfPossible() async {
    final user = _remoteUser;
    if (user == null || client.auth.currentSession?.user == null) return;

    final local = await (db.select(db.localUsers)
          ..where((t) => t.userId.equals(user.id)))
        .getSingleOrNull();

    if (local != null) {
      final payload = <String, dynamic>{
        'email': local.email,
        'registration_status': local.registrationStatus,
        'name': local.name,
        'sex': local.sex,
        'goal': local.goal,
        'activity_level': local.activityLevel,
        'height_cm': _roundTo1OrNull(local.heightCm),
        'deficit_kcal': local.deficitKcal,
        'date_of_birth': _dateOnlyOrNull(local.dateOfBirth),
      };

      payload.removeWhere((_, value) => value == null);

      if (payload.isNotEmpty) {
        await client.from('profiles').update(payload).eq('id', user.id);
      }
    }
  }

  @override
  Future<void> cacheLocalPasswordForCurrentUser({
    required String password,
  }) async {
    final user = currentUser;
    final email = user?.email ?? currentEmail;

    if (user == null || email == null || email.isEmpty) return;

    await credentialsStore.savePassword(
      userId: user.id,
      email: email,
      password: password,
    );

    await _saveLastSignedInUser(userId: user.id, email: email);
    await _setExplicitSignOut(false);
  }

  double? _roundTo1OrNull(double? value) {
    if (value == null) return null;
    return roundTo1(value);
  }

  String? _dateOnlyOrNull(DateTime? value) {
    if (value == null) return null;
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _verifyLocalUserPasswordThroughSupabaseAndCache({
    required LocalUserEntity row,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _withAuthTimeout(
        client.auth.signInWithPassword(email: row.email, password: password),
      );
      final remoteUser = response.user ?? _remoteUser;

      if (remoteUser == null || remoteUser.id != row.userId) {
        throw const AppException(loginCredentialsNotFoundMessage);
      }

      await credentialsStore.savePassword(
        userId: row.userId,
        email: row.email,
        password: password,
      );

      _offlineUser = null;
      await _saveLastSignedInUser(userId: row.userId, email: row.email);
      await _setExplicitSignOut(false);
      _enableOfflineUser(userId: row.userId, email: row.email);
      _pushLocalProfileInBackground();
    } on AuthException catch (e) {
      if (isInvalidLoginCredentialsError(e)) {
        throw const AppException(loginCredentialsNotFoundMessage);
      }
      if (isNetworkError(e)) {
        throw const AppException(noInternetMessage);
      }
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const AppException(noInternetMessage);
      }
      if (russianLoginErrorMessage(e) == loginCredentialsNotFoundMessage) {
        throw const AppException(loginCredentialsNotFoundMessage);
      }
      rethrow;
    }
  }

  @override
  Future<RegistrationStatus?> localStatusForCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final localUser = await (db.select(db.localUsers)
          ..where((t) => t.userId.equals(user.id)))
        .getSingleOrNull();

    if (localUser == null) return null;

    return RegistrationStatus.fromValue(localUser.registrationStatus);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    final alreadyExists = await isEmailRegisteredInSupabase(email);
    if (alreadyExists) {
      throw const AppException(emailAlreadyRegisteredMessage);
    }

    final response = await _withAuthTimeout(
      client.auth.signUp(email: email, password: password),
    );
    final user = response.user ?? currentUser;

    if (user != null) {
      await credentialsStore.savePassword(
        userId: user.id,
        email: user.email ?? email,
        password: password,
      );
    }
  }

  @override
  Future<bool> isEmailRegisteredInSupabase(String email) async {
    try {
      final result = await _withAuthTimeout(
        client.rpc(
          'is_email_registered',
          params: {'p_email': email.trim().toLowerCase()},
        ),
      );

      if (result is bool) return result;
      if (result is String) return result.toLowerCase() == 'true';
      return result == true;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const AppException(noInternetMessage);
      }

      final text = e.toString().toLowerCase();
      final functionMissing = text.contains('is_email_registered') &&
          (text.contains('not found') ||
              text.contains('could not find') ||
              text.contains('schema cache') ||
              text.contains('42883'));

      if (functionMissing) return false;
      rethrow;
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _withAuthTimeout(
        client.auth.signInWithPassword(email: email, password: password),
      );
    } on AuthException catch (e) {
      if (isInvalidLoginCredentialsError(e)) {
        throw const AppException(loginCredentialsNotFoundMessage);
      }
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const AppException(noInternetMessage);
      }
      rethrow;
    }

    final user = currentUser;
    if (user != null) {
      await _saveLastSignedInUser(
        userId: user.id,
        email: user.email ?? email,
      );
      await credentialsStore.savePassword(
        userId: user.id,
        email: user.email ?? email,
        password: password,
      );
    }

    _offlineUser = null;
    await _setExplicitSignOut(false);
    _pushLocalProfileInBackground();
  }

  Future<T> _withAuthTimeout<T>(Future<T> request) {
    return request.timeout(
      _authRequestTimeout,
      onTimeout: () => throw TimeoutException(noInternetMessage),
    );
  }

  void _pushLocalProfileInBackground() {
    unawaited(
      pushLocalProfileAndLatestMeasurementToSupabaseIfPossible()
          .timeout(_profilePushTimeout)
          .catchError((_) {}),
    );
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    await client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );

    final user = currentUser;
    if (user != null) {
      await _saveLastSignedInUser(
        userId: user.id,
        email: user.email ?? email,
      );
    }

    _offlineUser = null;
    await _setExplicitSignOut(false);
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await client.auth.resend(type: OtpType.signup, email: email);
  }

  @override
  Future<void> signOut({bool explicit = true}) async {
    if (explicit) {
      await _setExplicitSignOut(true);
    }
    _remoteSessionWarmUp = null;
    _offlineUser = null;
    await client.auth.signOut();
  }

  static const _profileSelectColumns =
      'registration_status, email, name, sex, goal, activity_level, '
      'height_cm, deficit_kcal, date_of_birth, created_at, updated_at, '
      'latest_measurement_day_key, latest_weight_kg, latest_neck_cm, '
      'latest_waist_cm, latest_hips_cm, latest_body_fat_percent';

  @override
  Future<RegistrationStatus?> fetchRemoteProfileAndSaveLocal() async {
    final user = currentUser;
    if (user == null) return null;

    final map = await _fetchOrCreateRemoteProfileRow(user);
    final statusText = map['registration_status'] as String?;
    final status = statusText == null
        ? RegistrationStatus.onboardingNotDone
        : RegistrationStatus.fromValue(statusText);

    await _saveLocalProfileFromRemoteRow(
      userId: user.id,
      authEmail: user.email ?? '',
      row: {
        ...map,
        'registration_status': status.value,
      },
    );

    await _saveLastSignedInUser(
      userId: user.id,
      email: user.email ?? (map['email'] as String? ?? ''),
    );

    await _saveLatestMeasurementFromRemoteProfile(
      userId: user.id,
      row: map,
    );

    return status;
  }

  Future<Map<String, dynamic>> _fetchOrCreateRemoteProfileRow(User user) async {
    final existing = await _withAuthTimeout(
      client
          .from('profiles')
          .select(_profileSelectColumns)
          .eq('id', user.id)
          .maybeSingle(),
    );

    if (existing != null) {
      return Map<String, dynamic>.from(existing as Map);
    }

    final email = user.email ?? '';

    final created = await _withAuthTimeout(
      client
          .from('profiles')
          .upsert(
            {
              'id': user.id,
              'email': email,
              'registration_status': RegistrationStatus.onboardingNotDone.value,
            },
            onConflict: 'id',
          )
          .select(_profileSelectColumns)
          .single(),
    );

    return Map<String, dynamic>.from(created as Map);
  }

  @override
  Future<void> saveLocalStatus({
    required String userId,
    required String email,
    required RegistrationStatus status,
  }) async {
    await db.into(db.localUsers).insertOnConflictUpdate(
          LocalUsersCompanion.insert(
            userId: userId,
            email: email,
            registrationStatus: status.value,
          ),
        );

    if (status == RegistrationStatus.fullyRegistered) {
      await _saveLastSignedInUser(userId: userId, email: email);
    }
  }

  @override
  Future<void> updateStatusRemoteThenLocal(RegistrationStatus status) async {
    final user = currentUser;
    if (user == null) throw const AppException(unauthorizedMessage);

    await client
        .from('profiles')
        .update({'registration_status': status.value}).eq('id', user.id);

    await saveLocalStatus(
      userId: user.id,
      email: user.email ?? '',
      status: status,
    );
  }

  Future<void> _saveLocalProfileFromRemoteRow({
    required String userId,
    required String authEmail,
    required Map<String, dynamic> row,
  }) async {
    final statusText = row['registration_status'] as String?;
    if (statusText == null) return;

    await db.into(db.localUsers).insertOnConflictUpdate(
          LocalUsersCompanion.insert(
            userId: userId,
            email: (row['email'] as String?) ?? authEmail,
            registrationStatus: statusText,
            name: drift.Value(row['name'] as String?),
            sex: drift.Value(row['sex'] as String?),
            goal: drift.Value(row['goal'] as String?),
            activityLevel: drift.Value(row['activity_level'] as String?),
            heightCm: drift.Value(_doubleOrNull(row['height_cm'])),
            deficitKcal:
                drift.Value(_doubleOrDefault(row['deficit_kcal'], 300)),
            dateOfBirth: drift.Value(_dateTimeOrNull(row['date_of_birth'])),
            createdAt: drift.Value(
              _dateTimeOrNull(row['created_at']) ?? DateTime.now(),
            ),
            updatedAt: drift.Value(
              _dateTimeOrNull(row['updated_at']) ?? DateTime.now(),
            ),
          ),
        );
  }

  Future<void> _saveLatestMeasurementFromRemoteProfile({
    required String userId,
    required Map<String, dynamic> row,
  }) async {
    final dayKey = (row['latest_measurement_day_key'] as String?)?.trim();
    final weightKg = _doubleOrNull(row['latest_weight_kg']);
    final neckCm = _doubleOrNull(row['latest_neck_cm']);
    final waistCm = _doubleOrNull(row['latest_waist_cm']);
    final hipsCm = _doubleOrNull(row['latest_hips_cm']);
    final bodyFatPercent = _doubleOrNull(row['latest_body_fat_percent']);

    if (dayKey == null || dayKey.isEmpty) return;
    if (weightKg == null || weightKg <= 0) return;
    if (neckCm == null || neckCm <= 0) return;
    if (waistCm == null || waistCm <= 0) return;
    if (hipsCm == null || hipsCm <= 0) return;
    if (bodyFatPercent == null || bodyFatPercent <= 0) return;

    await db.into(db.bodyMeasurements).insertOnConflictUpdate(
          BodyMeasurementsCompanion.insert(
            id: _profileLatestMeasurementId(userId, dayKey),
            userId: userId,
            dayKey: dayKey,
            weightKg: weightKg,
            neckCm: neckCm,
            waistCm: waistCm,
            hipsCm: hipsCm,
            bodyFatPercent: bodyFatPercent,
          ),
        );
  }

  String _profileLatestMeasurementId(String userId, String dayKey) {
    return 'profile_latest_${userId}_$dayKey';
  }

  double? _doubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double _doubleOrDefault(dynamic value, double fallback) {
    return _doubleOrNull(value) ?? fallback;
  }

  DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

enum LocalPasswordCheck { match, mismatch, missing }

class AuthLocalCredentialsStore {
  const AuthLocalCredentialsStore(this.db);

  final AppDatabase db;

  Future<void> savePassword({
    required String userId,
    required String email,
    required String password,
  }) async {
    await _ensureTable();

    final normalized = normalizeEmail(email);
    final passwordHash = localPasswordHash(
      email: normalized,
      password: password,
    );
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await db.customStatement(
      '''
      insert into $_localAuthCredentialsTable (
        user_id, email, email_normalized, password_hash, updated_at
      ) values (?, ?, ?, ?, ?)
      on conflict(user_id) do update set
        email = excluded.email,
        email_normalized = excluded.email_normalized,
        password_hash = excluded.password_hash,
        updated_at = excluded.updated_at
      ''',
      [userId, email, normalized, passwordHash, nowMs],
    );
  }

  Future<LocalPasswordCheck> checkPassword({
    required String userId,
    required String email,
    required String password,
  }) async {
    await _ensureTable();

    final rows = await db.customSelect(
      '''
      select password_hash
      from $_localAuthCredentialsTable
      where user_id = ? or email_normalized = ?
      limit 1
      ''',
      variables: [
        drift.Variable<String>(userId),
        drift.Variable<String>(normalizeEmail(email)),
      ],
    ).get();

    if (rows.isEmpty) return LocalPasswordCheck.missing;

    final savedHash = rows.first.data['password_hash'] as String?;
    final enteredHash = localPasswordHash(email: email, password: password);

    if (savedHash == enteredHash) return LocalPasswordCheck.match;
    return LocalPasswordCheck.mismatch;
  }

  Future<void> _ensureTable() async {
    await db.customStatement('''
      create table if not exists $_localAuthCredentialsTable (
        user_id text primary key not null,
        email text not null,
        email_normalized text not null unique,
        password_hash text not null,
        updated_at integer not null
      )
    ''');
  }

  String normalizeEmail(String email) => email.trim().toLowerCase();

  String localPasswordHash({
    required String email,
    required String password,
  }) {
    final source = 'shapeup_local_auth ${normalizeEmail(email)}|$password';
    const int fnvPrime = 0x01000193;
    var hash = 0x811c9dc5;

    for (final unit in source.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xffffffff;
    }

    for (var i = 0; i < 2048; i++) {
      hash ^= (hash >> 13);
      hash = (hash * fnvPrime) & 0xffffffff;
      hash ^= i;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }
}

const _localAuthCredentialsTable = 'local_auth_credentials';
