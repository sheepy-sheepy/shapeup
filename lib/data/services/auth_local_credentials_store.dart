import 'package:drift/drift.dart' as drift;

import '../local/app_database.dart';

const _localAuthCredentialsTable = 'local_auth_credentials';

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
