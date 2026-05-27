import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/enums.dart';
import '../../core/preferences_service.dart';
import '../../core/number_utils.dart';
import '../../domain/repositories/auth_repository.dart' as domain;
import '../local/app_database.dart';
import '../remote/supabase_provider.dart';
import '../services/auth_local_credentials_store.dart';

const _explicitSignOutKey = 'auth_explicit_sign_out';
const _lastSignedInUserIdKey = 'auth_last_signed_in_user_id';
const _noInternetMessage =
    'Нет интернет-соединения. Проверьте подключение и повторите попытку.';
const _loginCredentialsNotFoundMessage =
    'Пользователь с такой почтой и паролем не найден.';
const _emailAlreadyRegisteredMessage = 'Аккаунт с такой почтой уже существует.';
const _authRequestTimeout = Duration(seconds: 12);
const _profilePushTimeout = Duration(seconds: 8);

final authRepositoryImplProvider = Provider<domain.AuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return AuthRepository(
    ref.watch(supabaseProvider),
    db,
    ref.watch(preferencesServiceProvider),
    AuthLocalCredentialsStore(db),
  );
});

class AuthRepository implements domain.AuthRepository {
  AuthRepository(
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

  Future<void> _saveLastSignedInUser({
    required String userId,
    required String email,
  }) async {
    await preferences.setString(_lastSignedInUserIdKey, userId);
  }

  Future<LocalUser?> _localUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final rows = await db.select(db.localUsers).get();

    for (final row in rows) {
      if (row.email.trim().toLowerCase() == normalized) {
        return row;
      }
    }

    return null;
  }

  Future<LocalUser?> _lastLocalUser() async {
    final userId = await preferences.getString(_lastSignedInUserIdKey);

    if (userId == null || userId.isEmpty) return null;

    return (db.select(db.localUsers)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
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
          throw Exception(_loginCredentialsNotFoundMessage);
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
    required LocalUser row,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _withAuthTimeout(
        client.auth.signInWithPassword(email: row.email, password: password),
      );
      final remoteUser = response.user ?? _remoteUser;

      if (remoteUser == null || remoteUser.id != row.userId) {
        throw Exception(_loginCredentialsNotFoundMessage);
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
      if (_isInvalidLoginError(e)) {
        throw Exception(_loginCredentialsNotFoundMessage);
      }
      if (_isNetworkError(e)) {
        throw Exception(_noInternetMessage);
      }
      rethrow;
    } catch (e) {
      if (_isNetworkError(e)) {
        throw Exception(_noInternetMessage);
      }
      if (e.toString().contains(_loginCredentialsNotFoundMessage)) {
        throw Exception(_loginCredentialsNotFoundMessage);
      }
      rethrow;
    }
  }

  bool _isInvalidLoginError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('invalid login credentials') ||
        text.contains('invalid credentials') ||
        text.contains('invalid email or password') ||
        text.contains('invalid password') ||
        text.contains('wrong password') ||
        text.contains('user not found') ||
        text.contains('email not found') ||
        text.contains('no user found');
  }

  bool _isNetworkError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('connection closed') ||
        text.contains('connection terminated') ||
        text.contains('handshakeexception') ||
        text.contains('authretryablefetchexception') ||
        text.contains('clientexception') ||
        text.contains('failed to fetch') ||
        text.contains('xmlhttprequest error') ||
        text.contains('temporarily unavailable') ||
        text.contains('timed out') ||
        text.contains('timeoutexception') ||
        text.contains('network request failed') ||
        text.contains('no address associated with hostname');
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
      throw Exception(_emailAlreadyRegisteredMessage);
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
      if (_isNetworkError(e)) {
        throw Exception(_noInternetMessage);
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
      if (_isInvalidLoginError(e)) {
        throw Exception(_loginCredentialsNotFoundMessage);
      }
      rethrow;
    } catch (e) {
      if (_isNetworkError(e)) {
        throw Exception(_noInternetMessage);
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
      onTimeout: () => throw TimeoutException(_noInternetMessage),
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
    if (user == null) throw Exception('Пользователь не авторизован');

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
