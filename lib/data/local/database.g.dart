// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registrationStatusMeta =
      const VerificationMeta('registrationStatus');
  @override
  late final GeneratedColumn<String> registrationStatus =
      GeneratedColumn<String>('registration_status', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
      'goal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activityLevelMeta =
      const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
      'activity_level', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deficitKcalMeta =
      const VerificationMeta('deficitKcal');
  @override
  late final GeneratedColumn<double> deficitKcal = GeneratedColumn<double>(
      'deficit_kcal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(300));
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        email,
        registrationStatus,
        name,
        sex,
        goal,
        activityLevel,
        heightCm,
        deficitKcal,
        dateOfBirth,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('registration_status')) {
      context.handle(
          _registrationStatusMeta,
          registrationStatus.isAcceptableOrUnknown(
              data['registration_status']!, _registrationStatusMeta));
    } else if (isInserting) {
      context.missing(_registrationStatusMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
          _activityLevelMeta,
          activityLevel.isAcceptableOrUnknown(
              data['activity_level']!, _activityLevelMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('deficit_kcal')) {
      context.handle(
          _deficitKcalMeta,
          deficitKcal.isAcceptableOrUnknown(
              data['deficit_kcal']!, _deficitKcalMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      registrationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}registration_status'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex']),
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal']),
      activityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_level']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      deficitKcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}deficit_kcal'])!,
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String userId;
  final String email;
  final String registrationStatus;
  final String? name;
  final String? sex;
  final String? goal;
  final String? activityLevel;
  final double? heightCm;
  final double deficitKcal;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUser(
      {required this.userId,
      required this.email,
      required this.registrationStatus,
      this.name,
      this.sex,
      this.goal,
      this.activityLevel,
      this.heightCm,
      required this.deficitKcal,
      this.dateOfBirth,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['email'] = Variable<String>(email);
    map['registration_status'] = Variable<String>(registrationStatus);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    map['deficit_kcal'] = Variable<double>(deficitKcal);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      userId: Value(userId),
      email: Value(email),
      registrationStatus: Value(registrationStatus),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      deficitKcal: Value(deficitKcal),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String>(json['email']),
      registrationStatus:
          serializer.fromJson<String>(json['registrationStatus']),
      name: serializer.fromJson<String?>(json['name']),
      sex: serializer.fromJson<String?>(json['sex']),
      goal: serializer.fromJson<String?>(json['goal']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      deficitKcal: serializer.fromJson<double>(json['deficitKcal']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String>(email),
      'registrationStatus': serializer.toJson<String>(registrationStatus),
      'name': serializer.toJson<String?>(name),
      'sex': serializer.toJson<String?>(sex),
      'goal': serializer.toJson<String?>(goal),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'heightCm': serializer.toJson<double?>(heightCm),
      'deficitKcal': serializer.toJson<double>(deficitKcal),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUser copyWith(
          {String? userId,
          String? email,
          String? registrationStatus,
          Value<String?> name = const Value.absent(),
          Value<String?> sex = const Value.absent(),
          Value<String?> goal = const Value.absent(),
          Value<String?> activityLevel = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          double? deficitKcal,
          Value<DateTime?> dateOfBirth = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalUser(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        registrationStatus: registrationStatus ?? this.registrationStatus,
        name: name.present ? name.value : this.name,
        sex: sex.present ? sex.value : this.sex,
        goal: goal.present ? goal.value : this.goal,
        activityLevel:
            activityLevel.present ? activityLevel.value : this.activityLevel,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        deficitKcal: deficitKcal ?? this.deficitKcal,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      registrationStatus: data.registrationStatus.present
          ? data.registrationStatus.value
          : this.registrationStatus,
      name: data.name.present ? data.name.value : this.name,
      sex: data.sex.present ? data.sex.value : this.sex,
      goal: data.goal.present ? data.goal.value : this.goal,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      deficitKcal:
          data.deficitKcal.present ? data.deficitKcal.value : this.deficitKcal,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('goal: $goal, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('heightCm: $heightCm, ')
          ..write('deficitKcal: $deficitKcal, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      email,
      registrationStatus,
      name,
      sex,
      goal,
      activityLevel,
      heightCm,
      deficitKcal,
      dateOfBirth,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.registrationStatus == this.registrationStatus &&
          other.name == this.name &&
          other.sex == this.sex &&
          other.goal == this.goal &&
          other.activityLevel == this.activityLevel &&
          other.heightCm == this.heightCm &&
          other.deficitKcal == this.deficitKcal &&
          other.dateOfBirth == this.dateOfBirth &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> userId;
  final Value<String> email;
  final Value<String> registrationStatus;
  final Value<String?> name;
  final Value<String?> sex;
  final Value<String?> goal;
  final Value<String?> activityLevel;
  final Value<double?> heightCm;
  final Value<double> deficitKcal;
  final Value<DateTime?> dateOfBirth;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.goal = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.deficitKcal = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String userId,
    required String email,
    required String registrationStatus,
    this.name = const Value.absent(),
    this.sex = const Value.absent(),
    this.goal = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.deficitKcal = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        email = Value(email),
        registrationStatus = Value(registrationStatus);
  static Insertable<LocalUser> custom({
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? registrationStatus,
    Expression<String>? name,
    Expression<String>? sex,
    Expression<String>? goal,
    Expression<String>? activityLevel,
    Expression<double>? heightCm,
    Expression<double>? deficitKcal,
    Expression<DateTime>? dateOfBirth,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (registrationStatus != null) 'registration_status': registrationStatus,
      if (name != null) 'name': name,
      if (sex != null) 'sex': sex,
      if (goal != null) 'goal': goal,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (heightCm != null) 'height_cm': heightCm,
      if (deficitKcal != null) 'deficit_kcal': deficitKcal,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith(
      {Value<String>? userId,
      Value<String>? email,
      Value<String>? registrationStatus,
      Value<String?>? name,
      Value<String?>? sex,
      Value<String?>? goal,
      Value<String?>? activityLevel,
      Value<double?>? heightCm,
      Value<double>? deficitKcal,
      Value<DateTime?>? dateOfBirth,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalUsersCompanion(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      heightCm: heightCm ?? this.heightCm,
      deficitKcal: deficitKcal ?? this.deficitKcal,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (registrationStatus.present) {
      map['registration_status'] = Variable<String>(registrationStatus.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (deficitKcal.present) {
      map['deficit_kcal'] = Variable<double>(deficitKcal.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('name: $name, ')
          ..write('sex: $sex, ')
          ..write('goal: $goal, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('heightCm: $heightCm, ')
          ..write('deficitKcal: $deficitKcal, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinsMeta =
      const VerificationMeta('proteins');
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
      'proteins', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
      'fats', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, calories, proteins, fats, carbs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(Insertable<Food> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('proteins')) {
      context.handle(_proteinsMeta,
          proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta));
    } else if (isInserting) {
      context.missing(_proteinsMeta);
    }
    if (data.containsKey('fats')) {
      context.handle(
          _fatsMeta, fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta));
    } else if (isInserting) {
      context.missing(_fatsMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      proteins: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}proteins'])!,
      fats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class Food extends DataClass implements Insertable<Food> {
  final String id;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  const Food(
      {required this.id,
      required this.name,
      required this.calories,
      required this.proteins,
      required this.fats,
      required this.carbs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<double>(calories);
    map['proteins'] = Variable<double>(proteins);
    map['fats'] = Variable<double>(fats);
    map['carbs'] = Variable<double>(carbs);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      calories: Value(calories),
      proteins: Value(proteins),
      fats: Value(fats),
      carbs: Value(carbs),
    );
  }

  factory Food.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<double>(json['calories']),
      proteins: serializer.fromJson<double>(json['proteins']),
      fats: serializer.fromJson<double>(json['fats']),
      carbs: serializer.fromJson<double>(json['carbs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<double>(calories),
      'proteins': serializer.toJson<double>(proteins),
      'fats': serializer.toJson<double>(fats),
      'carbs': serializer.toJson<double>(carbs),
    };
  }

  Food copyWith(
          {String? id,
          String? name,
          double? calories,
          double? proteins,
          double? fats,
          double? carbs}) =>
      Food(
        id: id ?? this.id,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        proteins: proteins ?? this.proteins,
        fats: fats ?? this.fats,
        carbs: carbs ?? this.carbs,
      );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteins: data.proteins.present ? data.proteins.value : this.proteins,
      fats: data.fats.present ? data.fats.value : this.fats,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, calories, proteins, fats, carbs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.proteins == this.proteins &&
          other.fats == this.fats &&
          other.carbs == this.carbs);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> calories;
  final Value<double> proteins;
  final Value<double> fats;
  final Value<double> carbs;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteins = const Value.absent(),
    this.fats = const Value.absent(),
    this.carbs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    required String id,
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        calories = Value(calories),
        proteins = Value(proteins),
        fats = Value(fats),
        carbs = Value(carbs);
  static Insertable<Food> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? proteins,
    Expression<double>? fats,
    Expression<double>? carbs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (proteins != null) 'proteins': proteins,
      if (fats != null) 'fats': fats,
      if (carbs != null) 'carbs': carbs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? calories,
      Value<double>? proteins,
      Value<double>? fats,
      Value<double>? carbs,
      Value<int>? rowid}) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomProductsTable extends CustomProducts
    with TableInfo<$CustomProductsTable, CustomProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinsMeta =
      const VerificationMeta('proteins');
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
      'proteins', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
      'fats', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, calories, proteins, fats, carbs, deleted, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_products';
  @override
  VerificationContext validateIntegrity(Insertable<CustomProduct> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('proteins')) {
      context.handle(_proteinsMeta,
          proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta));
    } else if (isInserting) {
      context.missing(_proteinsMeta);
    }
    if (data.containsKey('fats')) {
      context.handle(
          _fatsMeta, fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta));
    } else if (isInserting) {
      context.missing(_fatsMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomProduct(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      proteins: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}proteins'])!,
      fats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomProductsTable createAlias(String alias) {
    return $CustomProductsTable(attachedDatabase, alias);
  }
}

class CustomProduct extends DataClass implements Insertable<CustomProduct> {
  final String id;
  final String userId;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final bool deleted;
  final DateTime updatedAt;
  const CustomProduct(
      {required this.id,
      required this.userId,
      required this.name,
      required this.calories,
      required this.proteins,
      required this.fats,
      required this.carbs,
      required this.deleted,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<double>(calories);
    map['proteins'] = Variable<double>(proteins);
    map['fats'] = Variable<double>(fats);
    map['carbs'] = Variable<double>(carbs);
    map['deleted'] = Variable<bool>(deleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomProductsCompanion toCompanion(bool nullToAbsent) {
    return CustomProductsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      calories: Value(calories),
      proteins: Value(proteins),
      fats: Value(fats),
      carbs: Value(carbs),
      deleted: Value(deleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomProduct.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomProduct(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<double>(json['calories']),
      proteins: serializer.fromJson<double>(json['proteins']),
      fats: serializer.fromJson<double>(json['fats']),
      carbs: serializer.fromJson<double>(json['carbs']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<double>(calories),
      'proteins': serializer.toJson<double>(proteins),
      'fats': serializer.toJson<double>(fats),
      'carbs': serializer.toJson<double>(carbs),
      'deleted': serializer.toJson<bool>(deleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomProduct copyWith(
          {String? id,
          String? userId,
          String? name,
          double? calories,
          double? proteins,
          double? fats,
          double? carbs,
          bool? deleted,
          DateTime? updatedAt}) =>
      CustomProduct(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        proteins: proteins ?? this.proteins,
        fats: fats ?? this.fats,
        carbs: carbs ?? this.carbs,
        deleted: deleted ?? this.deleted,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomProduct copyWithCompanion(CustomProductsCompanion data) {
    return CustomProduct(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteins: data.proteins.present ? data.proteins.value : this.proteins,
      fats: data.fats.present ? data.fats.value : this.fats,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomProduct(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, name, calories, proteins, fats, carbs, deleted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomProduct &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.proteins == this.proteins &&
          other.fats == this.fats &&
          other.carbs == this.carbs &&
          other.deleted == this.deleted &&
          other.updatedAt == this.updatedAt);
}

class CustomProductsCompanion extends UpdateCompanion<CustomProduct> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> calories;
  final Value<double> proteins;
  final Value<double> fats;
  final Value<double> carbs;
  final Value<bool> deleted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomProductsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteins = const Value.absent(),
    this.fats = const Value.absent(),
    this.carbs = const Value.absent(),
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomProductsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        calories = Value(calories),
        proteins = Value(proteins),
        fats = Value(fats),
        carbs = Value(carbs);
  static Insertable<CustomProduct> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? calories,
    Expression<double>? proteins,
    Expression<double>? fats,
    Expression<double>? carbs,
    Expression<bool>? deleted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (proteins != null) 'proteins': proteins,
      if (fats != null) 'fats': fats,
      if (carbs != null) 'carbs': carbs,
      if (deleted != null) 'deleted': deleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? calories,
      Value<double>? proteins,
      Value<double>? fats,
      Value<double>? carbs,
      Value<bool>? deleted,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomProductsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomProductsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('proteins: $proteins, ')
          ..write('fats: $fats, ')
          ..write('carbs: $carbs, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tareWeightGramsMeta =
      const VerificationMeta('tareWeightGrams');
  @override
  late final GeneratedColumn<double> tareWeightGrams = GeneratedColumn<double>(
      'tare_weight_grams', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cookedWithTareWeightGramsMeta =
      const VerificationMeta('cookedWithTareWeightGrams');
  @override
  late final GeneratedColumn<double> cookedWithTareWeightGrams =
      GeneratedColumn<double>(
          'cooked_with_tare_weight_grams', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        tareWeightGrams,
        cookedWithTareWeightGrams,
        deleted,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<Recipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tare_weight_grams')) {
      context.handle(
          _tareWeightGramsMeta,
          tareWeightGrams.isAcceptableOrUnknown(
              data['tare_weight_grams']!, _tareWeightGramsMeta));
    }
    if (data.containsKey('cooked_with_tare_weight_grams')) {
      context.handle(
          _cookedWithTareWeightGramsMeta,
          cookedWithTareWeightGrams.isAcceptableOrUnknown(
              data['cooked_with_tare_weight_grams']!,
              _cookedWithTareWeightGramsMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tareWeightGrams: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}tare_weight_grams'])!,
      cookedWithTareWeightGrams: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}cooked_with_tare_weight_grams'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String userId;
  final String name;
  final double tareWeightGrams;
  final double cookedWithTareWeightGrams;
  final bool deleted;
  final DateTime updatedAt;
  const Recipe(
      {required this.id,
      required this.userId,
      required this.name,
      required this.tareWeightGrams,
      required this.cookedWithTareWeightGrams,
      required this.deleted,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['tare_weight_grams'] = Variable<double>(tareWeightGrams);
    map['cooked_with_tare_weight_grams'] =
        Variable<double>(cookedWithTareWeightGrams);
    map['deleted'] = Variable<bool>(deleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      tareWeightGrams: Value(tareWeightGrams),
      cookedWithTareWeightGrams: Value(cookedWithTareWeightGrams),
      deleted: Value(deleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      tareWeightGrams: serializer.fromJson<double>(json['tareWeightGrams']),
      cookedWithTareWeightGrams:
          serializer.fromJson<double>(json['cookedWithTareWeightGrams']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'tareWeightGrams': serializer.toJson<double>(tareWeightGrams),
      'cookedWithTareWeightGrams':
          serializer.toJson<double>(cookedWithTareWeightGrams),
      'deleted': serializer.toJson<bool>(deleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Recipe copyWith(
          {String? id,
          String? userId,
          String? name,
          double? tareWeightGrams,
          double? cookedWithTareWeightGrams,
          bool? deleted,
          DateTime? updatedAt}) =>
      Recipe(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        tareWeightGrams: tareWeightGrams ?? this.tareWeightGrams,
        cookedWithTareWeightGrams:
            cookedWithTareWeightGrams ?? this.cookedWithTareWeightGrams,
        deleted: deleted ?? this.deleted,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      tareWeightGrams: data.tareWeightGrams.present
          ? data.tareWeightGrams.value
          : this.tareWeightGrams,
      cookedWithTareWeightGrams: data.cookedWithTareWeightGrams.present
          ? data.cookedWithTareWeightGrams.value
          : this.cookedWithTareWeightGrams,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('tareWeightGrams: $tareWeightGrams, ')
          ..write('cookedWithTareWeightGrams: $cookedWithTareWeightGrams, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, tareWeightGrams,
      cookedWithTareWeightGrams, deleted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.tareWeightGrams == this.tareWeightGrams &&
          other.cookedWithTareWeightGrams == this.cookedWithTareWeightGrams &&
          other.deleted == this.deleted &&
          other.updatedAt == this.updatedAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> tareWeightGrams;
  final Value<double> cookedWithTareWeightGrams;
  final Value<bool> deleted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.tareWeightGrams = const Value.absent(),
    this.cookedWithTareWeightGrams = const Value.absent(),
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.tareWeightGrams = const Value.absent(),
    this.cookedWithTareWeightGrams = const Value.absent(),
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? tareWeightGrams,
    Expression<double>? cookedWithTareWeightGrams,
    Expression<bool>? deleted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (tareWeightGrams != null) 'tare_weight_grams': tareWeightGrams,
      if (cookedWithTareWeightGrams != null)
        'cooked_with_tare_weight_grams': cookedWithTareWeightGrams,
      if (deleted != null) 'deleted': deleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? tareWeightGrams,
      Value<double>? cookedWithTareWeightGrams,
      Value<bool>? deleted,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RecipesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      tareWeightGrams: tareWeightGrams ?? this.tareWeightGrams,
      cookedWithTareWeightGrams:
          cookedWithTareWeightGrams ?? this.cookedWithTareWeightGrams,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tareWeightGrams.present) {
      map['tare_weight_grams'] = Variable<double>(tareWeightGrams.value);
    }
    if (cookedWithTareWeightGrams.present) {
      map['cooked_with_tare_weight_grams'] =
          Variable<double>(cookedWithTareWeightGrams.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('tareWeightGrams: $tareWeightGrams, ')
          ..write('cookedWithTareWeightGrams: $cookedWithTareWeightGrams, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameSnapshotMeta =
      const VerificationMeta('nameSnapshot');
  @override
  late final GeneratedColumn<String> nameSnapshot = GeneratedColumn<String>(
      'name_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
      'grams', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _caloriesSnapshotMeta =
      const VerificationMeta('caloriesSnapshot');
  @override
  late final GeneratedColumn<double> caloriesSnapshot = GeneratedColumn<double>(
      'calories_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinsSnapshotMeta =
      const VerificationMeta('proteinsSnapshot');
  @override
  late final GeneratedColumn<double> proteinsSnapshot = GeneratedColumn<double>(
      'proteins_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatsSnapshotMeta =
      const VerificationMeta('fatsSnapshot');
  @override
  late final GeneratedColumn<double> fatsSnapshot = GeneratedColumn<double>(
      'fats_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsSnapshotMeta =
      const VerificationMeta('carbsSnapshot');
  @override
  late final GeneratedColumn<double> carbsSnapshot = GeneratedColumn<double>(
      'carbs_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        recipeId,
        sourceType,
        sourceId,
        nameSnapshot,
        grams,
        caloriesSnapshot,
        proteinsSnapshot,
        fatsSnapshot,
        carbsSnapshot
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name_snapshot')) {
      context.handle(
          _nameSnapshotMeta,
          nameSnapshot.isAcceptableOrUnknown(
              data['name_snapshot']!, _nameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_nameSnapshotMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
          _gramsMeta, grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta));
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calories_snapshot')) {
      context.handle(
          _caloriesSnapshotMeta,
          caloriesSnapshot.isAcceptableOrUnknown(
              data['calories_snapshot']!, _caloriesSnapshotMeta));
    } else if (isInserting) {
      context.missing(_caloriesSnapshotMeta);
    }
    if (data.containsKey('proteins_snapshot')) {
      context.handle(
          _proteinsSnapshotMeta,
          proteinsSnapshot.isAcceptableOrUnknown(
              data['proteins_snapshot']!, _proteinsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_proteinsSnapshotMeta);
    }
    if (data.containsKey('fats_snapshot')) {
      context.handle(
          _fatsSnapshotMeta,
          fatsSnapshot.isAcceptableOrUnknown(
              data['fats_snapshot']!, _fatsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_fatsSnapshotMeta);
    }
    if (data.containsKey('carbs_snapshot')) {
      context.handle(
          _carbsSnapshotMeta,
          carbsSnapshot.isAcceptableOrUnknown(
              data['carbs_snapshot']!, _carbsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_carbsSnapshotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      nameSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_snapshot'])!,
      grams: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grams'])!,
      caloriesSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calories_snapshot'])!,
      proteinsSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}proteins_snapshot'])!,
      fatsSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats_snapshot'])!,
      carbsSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_snapshot'])!,
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final String id;
  final String recipeId;
  final String sourceType;
  final String sourceId;
  final String nameSnapshot;
  final double grams;
  final double caloriesSnapshot;
  final double proteinsSnapshot;
  final double fatsSnapshot;
  final double carbsSnapshot;
  const RecipeIngredient(
      {required this.id,
      required this.recipeId,
      required this.sourceType,
      required this.sourceId,
      required this.nameSnapshot,
      required this.grams,
      required this.caloriesSnapshot,
      required this.proteinsSnapshot,
      required this.fatsSnapshot,
      required this.carbsSnapshot});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['name_snapshot'] = Variable<String>(nameSnapshot);
    map['grams'] = Variable<double>(grams);
    map['calories_snapshot'] = Variable<double>(caloriesSnapshot);
    map['proteins_snapshot'] = Variable<double>(proteinsSnapshot);
    map['fats_snapshot'] = Variable<double>(fatsSnapshot);
    map['carbs_snapshot'] = Variable<double>(carbsSnapshot);
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      nameSnapshot: Value(nameSnapshot),
      grams: Value(grams),
      caloriesSnapshot: Value(caloriesSnapshot),
      proteinsSnapshot: Value(proteinsSnapshot),
      fatsSnapshot: Value(fatsSnapshot),
      carbsSnapshot: Value(carbsSnapshot),
    );
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      nameSnapshot: serializer.fromJson<String>(json['nameSnapshot']),
      grams: serializer.fromJson<double>(json['grams']),
      caloriesSnapshot: serializer.fromJson<double>(json['caloriesSnapshot']),
      proteinsSnapshot: serializer.fromJson<double>(json['proteinsSnapshot']),
      fatsSnapshot: serializer.fromJson<double>(json['fatsSnapshot']),
      carbsSnapshot: serializer.fromJson<double>(json['carbsSnapshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'nameSnapshot': serializer.toJson<String>(nameSnapshot),
      'grams': serializer.toJson<double>(grams),
      'caloriesSnapshot': serializer.toJson<double>(caloriesSnapshot),
      'proteinsSnapshot': serializer.toJson<double>(proteinsSnapshot),
      'fatsSnapshot': serializer.toJson<double>(fatsSnapshot),
      'carbsSnapshot': serializer.toJson<double>(carbsSnapshot),
    };
  }

  RecipeIngredient copyWith(
          {String? id,
          String? recipeId,
          String? sourceType,
          String? sourceId,
          String? nameSnapshot,
          double? grams,
          double? caloriesSnapshot,
          double? proteinsSnapshot,
          double? fatsSnapshot,
          double? carbsSnapshot}) =>
      RecipeIngredient(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        nameSnapshot: nameSnapshot ?? this.nameSnapshot,
        grams: grams ?? this.grams,
        caloriesSnapshot: caloriesSnapshot ?? this.caloriesSnapshot,
        proteinsSnapshot: proteinsSnapshot ?? this.proteinsSnapshot,
        fatsSnapshot: fatsSnapshot ?? this.fatsSnapshot,
        carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
      );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      nameSnapshot: data.nameSnapshot.present
          ? data.nameSnapshot.value
          : this.nameSnapshot,
      grams: data.grams.present ? data.grams.value : this.grams,
      caloriesSnapshot: data.caloriesSnapshot.present
          ? data.caloriesSnapshot.value
          : this.caloriesSnapshot,
      proteinsSnapshot: data.proteinsSnapshot.present
          ? data.proteinsSnapshot.value
          : this.proteinsSnapshot,
      fatsSnapshot: data.fatsSnapshot.present
          ? data.fatsSnapshot.value
          : this.fatsSnapshot,
      carbsSnapshot: data.carbsSnapshot.present
          ? data.carbsSnapshot.value
          : this.carbsSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('caloriesSnapshot: $caloriesSnapshot, ')
          ..write('proteinsSnapshot: $proteinsSnapshot, ')
          ..write('fatsSnapshot: $fatsSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      recipeId,
      sourceType,
      sourceId,
      nameSnapshot,
      grams,
      caloriesSnapshot,
      proteinsSnapshot,
      fatsSnapshot,
      carbsSnapshot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.nameSnapshot == this.nameSnapshot &&
          other.grams == this.grams &&
          other.caloriesSnapshot == this.caloriesSnapshot &&
          other.proteinsSnapshot == this.proteinsSnapshot &&
          other.fatsSnapshot == this.fatsSnapshot &&
          other.carbsSnapshot == this.carbsSnapshot);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> nameSnapshot;
  final Value<double> grams;
  final Value<double> caloriesSnapshot;
  final Value<double> proteinsSnapshot;
  final Value<double> fatsSnapshot;
  final Value<double> carbsSnapshot;
  final Value<int> rowid;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.nameSnapshot = const Value.absent(),
    this.grams = const Value.absent(),
    this.caloriesSnapshot = const Value.absent(),
    this.proteinsSnapshot = const Value.absent(),
    this.fatsSnapshot = const Value.absent(),
    this.carbsSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    required String id,
    required String recipeId,
    required String sourceType,
    required String sourceId,
    required String nameSnapshot,
    required double grams,
    required double caloriesSnapshot,
    required double proteinsSnapshot,
    required double fatsSnapshot,
    required double carbsSnapshot,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recipeId = Value(recipeId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        nameSnapshot = Value(nameSnapshot),
        grams = Value(grams),
        caloriesSnapshot = Value(caloriesSnapshot),
        proteinsSnapshot = Value(proteinsSnapshot),
        fatsSnapshot = Value(fatsSnapshot),
        carbsSnapshot = Value(carbsSnapshot);
  static Insertable<RecipeIngredient> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? nameSnapshot,
    Expression<double>? grams,
    Expression<double>? caloriesSnapshot,
    Expression<double>? proteinsSnapshot,
    Expression<double>? fatsSnapshot,
    Expression<double>? carbsSnapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (nameSnapshot != null) 'name_snapshot': nameSnapshot,
      if (grams != null) 'grams': grams,
      if (caloriesSnapshot != null) 'calories_snapshot': caloriesSnapshot,
      if (proteinsSnapshot != null) 'proteins_snapshot': proteinsSnapshot,
      if (fatsSnapshot != null) 'fats_snapshot': fatsSnapshot,
      if (carbsSnapshot != null) 'carbs_snapshot': carbsSnapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeIngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? recipeId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? nameSnapshot,
      Value<double>? grams,
      Value<double>? caloriesSnapshot,
      Value<double>? proteinsSnapshot,
      Value<double>? fatsSnapshot,
      Value<double>? carbsSnapshot,
      Value<int>? rowid}) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      grams: grams ?? this.grams,
      caloriesSnapshot: caloriesSnapshot ?? this.caloriesSnapshot,
      proteinsSnapshot: proteinsSnapshot ?? this.proteinsSnapshot,
      fatsSnapshot: fatsSnapshot ?? this.fatsSnapshot,
      carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (nameSnapshot.present) {
      map['name_snapshot'] = Variable<String>(nameSnapshot.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (caloriesSnapshot.present) {
      map['calories_snapshot'] = Variable<double>(caloriesSnapshot.value);
    }
    if (proteinsSnapshot.present) {
      map['proteins_snapshot'] = Variable<double>(proteinsSnapshot.value);
    }
    if (fatsSnapshot.present) {
      map['fats_snapshot'] = Variable<double>(fatsSnapshot.value);
    }
    if (carbsSnapshot.present) {
      map['carbs_snapshot'] = Variable<double>(carbsSnapshot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('caloriesSnapshot: $caloriesSnapshot, ')
          ..write('proteinsSnapshot: $proteinsSnapshot, ')
          ..write('fatsSnapshot: $fatsSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
      'neck_cm', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _waistCmMeta =
      const VerificationMeta('waistCm');
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
      'waist_cm', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
      'hips_cm', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bodyFatPercentMeta =
      const VerificationMeta('bodyFatPercent');
  @override
  late final GeneratedColumn<double> bodyFatPercent = GeneratedColumn<double>(
      'body_fat_percent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, dayKey, weightKg, neckCm, waistCm, hipsCm, bodyFatPercent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<BodyMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('neck_cm')) {
      context.handle(_neckCmMeta,
          neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta));
    } else if (isInserting) {
      context.missing(_neckCmMeta);
    }
    if (data.containsKey('waist_cm')) {
      context.handle(_waistCmMeta,
          waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta));
    } else if (isInserting) {
      context.missing(_waistCmMeta);
    }
    if (data.containsKey('hips_cm')) {
      context.handle(_hipsCmMeta,
          hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta));
    } else if (isInserting) {
      context.missing(_hipsCmMeta);
    }
    if (data.containsKey('body_fat_percent')) {
      context.handle(
          _bodyFatPercentMeta,
          bodyFatPercent.isAcceptableOrUnknown(
              data['body_fat_percent']!, _bodyFatPercentMeta));
    } else if (isInserting) {
      context.missing(_bodyFatPercentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userId, dayKey},
      ];
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      neckCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}neck_cm'])!,
      waistCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}waist_cm'])!,
      hipsCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hips_cm'])!,
      bodyFatPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}body_fat_percent'])!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final String id;
  final String userId;
  final String dayKey;
  final double weightKg;
  final double neckCm;
  final double waistCm;
  final double hipsCm;
  final double bodyFatPercent;
  const BodyMeasurement(
      {required this.id,
      required this.userId,
      required this.dayKey,
      required this.weightKg,
      required this.neckCm,
      required this.waistCm,
      required this.hipsCm,
      required this.bodyFatPercent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['day_key'] = Variable<String>(dayKey);
    map['weight_kg'] = Variable<double>(weightKg);
    map['neck_cm'] = Variable<double>(neckCm);
    map['waist_cm'] = Variable<double>(waistCm);
    map['hips_cm'] = Variable<double>(hipsCm);
    map['body_fat_percent'] = Variable<double>(bodyFatPercent);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      userId: Value(userId),
      dayKey: Value(dayKey),
      weightKg: Value(weightKg),
      neckCm: Value(neckCm),
      waistCm: Value(waistCm),
      hipsCm: Value(hipsCm),
      bodyFatPercent: Value(bodyFatPercent),
    );
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      neckCm: serializer.fromJson<double>(json['neckCm']),
      waistCm: serializer.fromJson<double>(json['waistCm']),
      hipsCm: serializer.fromJson<double>(json['hipsCm']),
      bodyFatPercent: serializer.fromJson<double>(json['bodyFatPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dayKey': serializer.toJson<String>(dayKey),
      'weightKg': serializer.toJson<double>(weightKg),
      'neckCm': serializer.toJson<double>(neckCm),
      'waistCm': serializer.toJson<double>(waistCm),
      'hipsCm': serializer.toJson<double>(hipsCm),
      'bodyFatPercent': serializer.toJson<double>(bodyFatPercent),
    };
  }

  BodyMeasurement copyWith(
          {String? id,
          String? userId,
          String? dayKey,
          double? weightKg,
          double? neckCm,
          double? waistCm,
          double? hipsCm,
          double? bodyFatPercent}) =>
      BodyMeasurement(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dayKey: dayKey ?? this.dayKey,
        weightKg: weightKg ?? this.weightKg,
        neckCm: neckCm ?? this.neckCm,
        waistCm: waistCm ?? this.waistCm,
        hipsCm: hipsCm ?? this.hipsCm,
        bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      bodyFatPercent: data.bodyFatPercent.present
          ? data.bodyFatPercent.value
          : this.bodyFatPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('weightKg: $weightKg, ')
          ..write('neckCm: $neckCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('bodyFatPercent: $bodyFatPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, dayKey, weightKg, neckCm, waistCm, hipsCm, bodyFatPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dayKey == this.dayKey &&
          other.weightKg == this.weightKg &&
          other.neckCm == this.neckCm &&
          other.waistCm == this.waistCm &&
          other.hipsCm == this.hipsCm &&
          other.bodyFatPercent == this.bodyFatPercent);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> dayKey;
  final Value<double> weightKg;
  final Value<double> neckCm;
  final Value<double> waistCm;
  final Value<double> hipsCm;
  final Value<double> bodyFatPercent;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.bodyFatPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    required String userId,
    required String dayKey,
    required double weightKg,
    required double neckCm,
    required double waistCm,
    required double hipsCm,
    required double bodyFatPercent,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        dayKey = Value(dayKey),
        weightKg = Value(weightKg),
        neckCm = Value(neckCm),
        waistCm = Value(waistCm),
        hipsCm = Value(hipsCm),
        bodyFatPercent = Value(bodyFatPercent);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dayKey,
    Expression<double>? weightKg,
    Expression<double>? neckCm,
    Expression<double>? waistCm,
    Expression<double>? hipsCm,
    Expression<double>? bodyFatPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dayKey != null) 'day_key': dayKey,
      if (weightKg != null) 'weight_kg': weightKg,
      if (neckCm != null) 'neck_cm': neckCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (bodyFatPercent != null) 'body_fat_percent': bodyFatPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? dayKey,
      Value<double>? weightKg,
      Value<double>? neckCm,
      Value<double>? waistCm,
      Value<double>? hipsCm,
      Value<double>? bodyFatPercent,
      Value<int>? rowid}) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayKey: dayKey ?? this.dayKey,
      weightKg: weightKg ?? this.weightKg,
      neckCm: neckCm ?? this.neckCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (bodyFatPercent.present) {
      map['body_fat_percent'] = Variable<double>(bodyFatPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('weightKg: $weightKg, ')
          ..write('neckCm: $neckCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('bodyFatPercent: $bodyFatPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryDaysTable extends DiaryDays
    with TableInfo<$DiaryDaysTable, DiaryDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _waterMlMeta =
      const VerificationMeta('waterMl');
  @override
  late final GeneratedColumn<double> waterMl = GeneratedColumn<double>(
      'water_ml', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, dayKey, waterMl, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_days';
  @override
  VerificationContext validateIntegrity(Insertable<DiaryDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('water_ml')) {
      context.handle(_waterMlMeta,
          waterMl.isAcceptableOrUnknown(data['water_ml']!, _waterMlMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      waterMl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}water_ml'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DiaryDaysTable createAlias(String alias) {
    return $DiaryDaysTable(attachedDatabase, alias);
  }
}

class DiaryDay extends DataClass implements Insertable<DiaryDay> {
  final String id;
  final String userId;
  final String dayKey;
  final double waterMl;
  final DateTime updatedAt;
  const DiaryDay(
      {required this.id,
      required this.userId,
      required this.dayKey,
      required this.waterMl,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['day_key'] = Variable<String>(dayKey);
    map['water_ml'] = Variable<double>(waterMl);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiaryDaysCompanion toCompanion(bool nullToAbsent) {
    return DiaryDaysCompanion(
      id: Value(id),
      userId: Value(userId),
      dayKey: Value(dayKey),
      waterMl: Value(waterMl),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiaryDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryDay(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      waterMl: serializer.fromJson<double>(json['waterMl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dayKey': serializer.toJson<String>(dayKey),
      'waterMl': serializer.toJson<double>(waterMl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiaryDay copyWith(
          {String? id,
          String? userId,
          String? dayKey,
          double? waterMl,
          DateTime? updatedAt}) =>
      DiaryDay(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dayKey: dayKey ?? this.dayKey,
        waterMl: waterMl ?? this.waterMl,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DiaryDay copyWithCompanion(DiaryDaysCompanion data) {
    return DiaryDay(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      waterMl: data.waterMl.present ? data.waterMl.value : this.waterMl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryDay(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('waterMl: $waterMl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, dayKey, waterMl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryDay &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dayKey == this.dayKey &&
          other.waterMl == this.waterMl &&
          other.updatedAt == this.updatedAt);
}

class DiaryDaysCompanion extends UpdateCompanion<DiaryDay> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> dayKey;
  final Value<double> waterMl;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiaryDaysCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryDaysCompanion.insert({
    required String id,
    required String userId,
    required String dayKey,
    this.waterMl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        dayKey = Value(dayKey);
  static Insertable<DiaryDay> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dayKey,
    Expression<double>? waterMl,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dayKey != null) 'day_key': dayKey,
      if (waterMl != null) 'water_ml': waterMl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryDaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? dayKey,
      Value<double>? waterMl,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DiaryDaysCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayKey: dayKey ?? this.dayKey,
      waterMl: waterMl ?? this.waterMl,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (waterMl.present) {
      map['water_ml'] = Variable<double>(waterMl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryDaysCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('waterMl: $waterMl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, dayKey, mealType, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(Insertable<Meal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class Meal extends DataClass implements Insertable<Meal> {
  final String id;
  final String userId;
  final String dayKey;
  final String mealType;
  final DateTime updatedAt;
  const Meal(
      {required this.id,
      required this.userId,
      required this.dayKey,
      required this.mealType,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['day_key'] = Variable<String>(dayKey);
    map['meal_type'] = Variable<String>(mealType);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      userId: Value(userId),
      dayKey: Value(dayKey),
      mealType: Value(mealType),
      updatedAt: Value(updatedAt),
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      mealType: serializer.fromJson<String>(json['mealType']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dayKey': serializer.toJson<String>(dayKey),
      'mealType': serializer.toJson<String>(mealType),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Meal copyWith(
          {String? id,
          String? userId,
          String? dayKey,
          String? mealType,
          DateTime? updatedAt}) =>
      Meal(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dayKey: dayKey ?? this.dayKey,
        mealType: mealType ?? this.mealType,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('mealType: $mealType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, dayKey, mealType, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dayKey == this.dayKey &&
          other.mealType == this.mealType &&
          other.updatedAt == this.updatedAt);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> dayKey;
  final Value<String> mealType;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.mealType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealsCompanion.insert({
    required String id,
    required String userId,
    required String dayKey,
    required String mealType,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        dayKey = Value(dayKey),
        mealType = Value(mealType);
  static Insertable<Meal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dayKey,
    Expression<String>? mealType,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dayKey != null) 'day_key': dayKey,
      if (mealType != null) 'meal_type': mealType,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? dayKey,
      Value<String>? mealType,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MealsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayKey: dayKey ?? this.dayKey,
      mealType: mealType ?? this.mealType,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('mealType: $mealType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealItemsTable extends MealItems
    with TableInfo<$MealItemsTable, MealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
      'meal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceTypeMeta =
      const VerificationMeta('sourceType');
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
      'source_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameSnapshotMeta =
      const VerificationMeta('nameSnapshot');
  @override
  late final GeneratedColumn<String> nameSnapshot = GeneratedColumn<String>(
      'name_snapshot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
      'grams', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _caloriesSnapshotMeta =
      const VerificationMeta('caloriesSnapshot');
  @override
  late final GeneratedColumn<double> caloriesSnapshot = GeneratedColumn<double>(
      'calories_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinsSnapshotMeta =
      const VerificationMeta('proteinsSnapshot');
  @override
  late final GeneratedColumn<double> proteinsSnapshot = GeneratedColumn<double>(
      'proteins_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatsSnapshotMeta =
      const VerificationMeta('fatsSnapshot');
  @override
  late final GeneratedColumn<double> fatsSnapshot = GeneratedColumn<double>(
      'fats_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsSnapshotMeta =
      const VerificationMeta('carbsSnapshot');
  @override
  late final GeneratedColumn<double> carbsSnapshot = GeneratedColumn<double>(
      'carbs_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mealId,
        sourceType,
        sourceId,
        nameSnapshot,
        grams,
        caloriesSnapshot,
        proteinsSnapshot,
        fatsSnapshot,
        carbsSnapshot,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_items';
  @override
  VerificationContext validateIntegrity(Insertable<MealItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_id')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
          _sourceTypeMeta,
          sourceType.isAcceptableOrUnknown(
              data['source_type']!, _sourceTypeMeta));
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name_snapshot')) {
      context.handle(
          _nameSnapshotMeta,
          nameSnapshot.isAcceptableOrUnknown(
              data['name_snapshot']!, _nameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_nameSnapshotMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
          _gramsMeta, grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta));
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calories_snapshot')) {
      context.handle(
          _caloriesSnapshotMeta,
          caloriesSnapshot.isAcceptableOrUnknown(
              data['calories_snapshot']!, _caloriesSnapshotMeta));
    } else if (isInserting) {
      context.missing(_caloriesSnapshotMeta);
    }
    if (data.containsKey('proteins_snapshot')) {
      context.handle(
          _proteinsSnapshotMeta,
          proteinsSnapshot.isAcceptableOrUnknown(
              data['proteins_snapshot']!, _proteinsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_proteinsSnapshotMeta);
    }
    if (data.containsKey('fats_snapshot')) {
      context.handle(
          _fatsSnapshotMeta,
          fatsSnapshot.isAcceptableOrUnknown(
              data['fats_snapshot']!, _fatsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_fatsSnapshotMeta);
    }
    if (data.containsKey('carbs_snapshot')) {
      context.handle(
          _carbsSnapshotMeta,
          carbsSnapshot.isAcceptableOrUnknown(
              data['carbs_snapshot']!, _carbsSnapshotMeta));
    } else if (isInserting) {
      context.missing(_carbsSnapshotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_id'])!,
      sourceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      nameSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_snapshot'])!,
      grams: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grams'])!,
      caloriesSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}calories_snapshot'])!,
      proteinsSnapshot: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}proteins_snapshot'])!,
      fatsSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats_snapshot'])!,
      carbsSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_snapshot'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MealItemsTable createAlias(String alias) {
    return $MealItemsTable(attachedDatabase, alias);
  }
}

class MealItem extends DataClass implements Insertable<MealItem> {
  final String id;
  final String mealId;
  final String sourceType;
  final String sourceId;
  final String nameSnapshot;
  final double grams;
  final double caloriesSnapshot;
  final double proteinsSnapshot;
  final double fatsSnapshot;
  final double carbsSnapshot;
  final DateTime createdAt;
  const MealItem(
      {required this.id,
      required this.mealId,
      required this.sourceType,
      required this.sourceId,
      required this.nameSnapshot,
      required this.grams,
      required this.caloriesSnapshot,
      required this.proteinsSnapshot,
      required this.fatsSnapshot,
      required this.carbsSnapshot,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['name_snapshot'] = Variable<String>(nameSnapshot);
    map['grams'] = Variable<double>(grams);
    map['calories_snapshot'] = Variable<double>(caloriesSnapshot);
    map['proteins_snapshot'] = Variable<double>(proteinsSnapshot);
    map['fats_snapshot'] = Variable<double>(fatsSnapshot);
    map['carbs_snapshot'] = Variable<double>(carbsSnapshot);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealItemsCompanion toCompanion(bool nullToAbsent) {
    return MealItemsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      nameSnapshot: Value(nameSnapshot),
      grams: Value(grams),
      caloriesSnapshot: Value(caloriesSnapshot),
      proteinsSnapshot: Value(proteinsSnapshot),
      fatsSnapshot: Value(fatsSnapshot),
      carbsSnapshot: Value(carbsSnapshot),
      createdAt: Value(createdAt),
    );
  }

  factory MealItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealItem(
      id: serializer.fromJson<String>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      nameSnapshot: serializer.fromJson<String>(json['nameSnapshot']),
      grams: serializer.fromJson<double>(json['grams']),
      caloriesSnapshot: serializer.fromJson<double>(json['caloriesSnapshot']),
      proteinsSnapshot: serializer.fromJson<double>(json['proteinsSnapshot']),
      fatsSnapshot: serializer.fromJson<double>(json['fatsSnapshot']),
      carbsSnapshot: serializer.fromJson<double>(json['carbsSnapshot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mealId': serializer.toJson<String>(mealId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'nameSnapshot': serializer.toJson<String>(nameSnapshot),
      'grams': serializer.toJson<double>(grams),
      'caloriesSnapshot': serializer.toJson<double>(caloriesSnapshot),
      'proteinsSnapshot': serializer.toJson<double>(proteinsSnapshot),
      'fatsSnapshot': serializer.toJson<double>(fatsSnapshot),
      'carbsSnapshot': serializer.toJson<double>(carbsSnapshot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MealItem copyWith(
          {String? id,
          String? mealId,
          String? sourceType,
          String? sourceId,
          String? nameSnapshot,
          double? grams,
          double? caloriesSnapshot,
          double? proteinsSnapshot,
          double? fatsSnapshot,
          double? carbsSnapshot,
          DateTime? createdAt}) =>
      MealItem(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
        nameSnapshot: nameSnapshot ?? this.nameSnapshot,
        grams: grams ?? this.grams,
        caloriesSnapshot: caloriesSnapshot ?? this.caloriesSnapshot,
        proteinsSnapshot: proteinsSnapshot ?? this.proteinsSnapshot,
        fatsSnapshot: fatsSnapshot ?? this.fatsSnapshot,
        carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
        createdAt: createdAt ?? this.createdAt,
      );
  MealItem copyWithCompanion(MealItemsCompanion data) {
    return MealItem(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      sourceType:
          data.sourceType.present ? data.sourceType.value : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      nameSnapshot: data.nameSnapshot.present
          ? data.nameSnapshot.value
          : this.nameSnapshot,
      grams: data.grams.present ? data.grams.value : this.grams,
      caloriesSnapshot: data.caloriesSnapshot.present
          ? data.caloriesSnapshot.value
          : this.caloriesSnapshot,
      proteinsSnapshot: data.proteinsSnapshot.present
          ? data.proteinsSnapshot.value
          : this.proteinsSnapshot,
      fatsSnapshot: data.fatsSnapshot.present
          ? data.fatsSnapshot.value
          : this.fatsSnapshot,
      carbsSnapshot: data.carbsSnapshot.present
          ? data.carbsSnapshot.value
          : this.carbsSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealItem(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('caloriesSnapshot: $caloriesSnapshot, ')
          ..write('proteinsSnapshot: $proteinsSnapshot, ')
          ..write('fatsSnapshot: $fatsSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mealId,
      sourceType,
      sourceId,
      nameSnapshot,
      grams,
      caloriesSnapshot,
      proteinsSnapshot,
      fatsSnapshot,
      carbsSnapshot,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealItem &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.nameSnapshot == this.nameSnapshot &&
          other.grams == this.grams &&
          other.caloriesSnapshot == this.caloriesSnapshot &&
          other.proteinsSnapshot == this.proteinsSnapshot &&
          other.fatsSnapshot == this.fatsSnapshot &&
          other.carbsSnapshot == this.carbsSnapshot &&
          other.createdAt == this.createdAt);
}

class MealItemsCompanion extends UpdateCompanion<MealItem> {
  final Value<String> id;
  final Value<String> mealId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> nameSnapshot;
  final Value<double> grams;
  final Value<double> caloriesSnapshot;
  final Value<double> proteinsSnapshot;
  final Value<double> fatsSnapshot;
  final Value<double> carbsSnapshot;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MealItemsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.nameSnapshot = const Value.absent(),
    this.grams = const Value.absent(),
    this.caloriesSnapshot = const Value.absent(),
    this.proteinsSnapshot = const Value.absent(),
    this.fatsSnapshot = const Value.absent(),
    this.carbsSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealItemsCompanion.insert({
    required String id,
    required String mealId,
    required String sourceType,
    required String sourceId,
    required String nameSnapshot,
    required double grams,
    required double caloriesSnapshot,
    required double proteinsSnapshot,
    required double fatsSnapshot,
    required double carbsSnapshot,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mealId = Value(mealId),
        sourceType = Value(sourceType),
        sourceId = Value(sourceId),
        nameSnapshot = Value(nameSnapshot),
        grams = Value(grams),
        caloriesSnapshot = Value(caloriesSnapshot),
        proteinsSnapshot = Value(proteinsSnapshot),
        fatsSnapshot = Value(fatsSnapshot),
        carbsSnapshot = Value(carbsSnapshot);
  static Insertable<MealItem> custom({
    Expression<String>? id,
    Expression<String>? mealId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? nameSnapshot,
    Expression<double>? grams,
    Expression<double>? caloriesSnapshot,
    Expression<double>? proteinsSnapshot,
    Expression<double>? fatsSnapshot,
    Expression<double>? carbsSnapshot,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (nameSnapshot != null) 'name_snapshot': nameSnapshot,
      if (grams != null) 'grams': grams,
      if (caloriesSnapshot != null) 'calories_snapshot': caloriesSnapshot,
      if (proteinsSnapshot != null) 'proteins_snapshot': proteinsSnapshot,
      if (fatsSnapshot != null) 'fats_snapshot': fatsSnapshot,
      if (carbsSnapshot != null) 'carbs_snapshot': carbsSnapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? mealId,
      Value<String>? sourceType,
      Value<String>? sourceId,
      Value<String>? nameSnapshot,
      Value<double>? grams,
      Value<double>? caloriesSnapshot,
      Value<double>? proteinsSnapshot,
      Value<double>? fatsSnapshot,
      Value<double>? carbsSnapshot,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MealItemsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      grams: grams ?? this.grams,
      caloriesSnapshot: caloriesSnapshot ?? this.caloriesSnapshot,
      proteinsSnapshot: proteinsSnapshot ?? this.proteinsSnapshot,
      fatsSnapshot: fatsSnapshot ?? this.fatsSnapshot,
      carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (nameSnapshot.present) {
      map['name_snapshot'] = Variable<String>(nameSnapshot.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (caloriesSnapshot.present) {
      map['calories_snapshot'] = Variable<double>(caloriesSnapshot.value);
    }
    if (proteinsSnapshot.present) {
      map['proteins_snapshot'] = Variable<double>(proteinsSnapshot.value);
    }
    if (fatsSnapshot.present) {
      map['fats_snapshot'] = Variable<double>(fatsSnapshot.value);
    }
    if (carbsSnapshot.present) {
      map['carbs_snapshot'] = Variable<double>(carbsSnapshot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('caloriesSnapshot: $caloriesSnapshot, ')
          ..write('proteinsSnapshot: $proteinsSnapshot, ')
          ..write('fatsSnapshot: $fatsSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressPhotosTable extends ProgressPhotos
    with TableInfo<$ProgressPhotosTable, ProgressPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
      'slot', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, userId, dayKey, slot, localPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_photos';
  @override
  VerificationContext validateIntegrity(Insertable<ProgressPhoto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
          _slotMeta, slot.isAcceptableOrUnknown(data['slot']!, _slotMeta));
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressPhoto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      slot: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}slot'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
    );
  }

  @override
  $ProgressPhotosTable createAlias(String alias) {
    return $ProgressPhotosTable(attachedDatabase, alias);
  }
}

class ProgressPhoto extends DataClass implements Insertable<ProgressPhoto> {
  final String id;
  final String userId;
  final String dayKey;
  final int slot;
  final String localPath;
  const ProgressPhoto(
      {required this.id,
      required this.userId,
      required this.dayKey,
      required this.slot,
      required this.localPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['day_key'] = Variable<String>(dayKey);
    map['slot'] = Variable<int>(slot);
    map['local_path'] = Variable<String>(localPath);
    return map;
  }

  ProgressPhotosCompanion toCompanion(bool nullToAbsent) {
    return ProgressPhotosCompanion(
      id: Value(id),
      userId: Value(userId),
      dayKey: Value(dayKey),
      slot: Value(slot),
      localPath: Value(localPath),
    );
  }

  factory ProgressPhoto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressPhoto(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      slot: serializer.fromJson<int>(json['slot']),
      localPath: serializer.fromJson<String>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'dayKey': serializer.toJson<String>(dayKey),
      'slot': serializer.toJson<int>(slot),
      'localPath': serializer.toJson<String>(localPath),
    };
  }

  ProgressPhoto copyWith(
          {String? id,
          String? userId,
          String? dayKey,
          int? slot,
          String? localPath}) =>
      ProgressPhoto(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        dayKey: dayKey ?? this.dayKey,
        slot: slot ?? this.slot,
        localPath: localPath ?? this.localPath,
      );
  ProgressPhoto copyWithCompanion(ProgressPhotosCompanion data) {
    return ProgressPhoto(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      slot: data.slot.present ? data.slot.value : this.slot,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressPhoto(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('slot: $slot, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, dayKey, slot, localPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressPhoto &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dayKey == this.dayKey &&
          other.slot == this.slot &&
          other.localPath == this.localPath);
}

class ProgressPhotosCompanion extends UpdateCompanion<ProgressPhoto> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> dayKey;
  final Value<int> slot;
  final Value<String> localPath;
  final Value<int> rowid;
  const ProgressPhotosCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.slot = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressPhotosCompanion.insert({
    required String id,
    required String userId,
    required String dayKey,
    required int slot,
    required String localPath,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        dayKey = Value(dayKey),
        slot = Value(slot),
        localPath = Value(localPath);
  static Insertable<ProgressPhoto> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? dayKey,
    Expression<int>? slot,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dayKey != null) 'day_key': dayKey,
      if (slot != null) 'slot': slot,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressPhotosCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? dayKey,
      Value<int>? slot,
      Value<String>? localPath,
      Value<int>? rowid}) {
    return ProgressPhotosCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayKey: dayKey ?? this.dayKey,
      slot: slot ?? this.slot,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressPhotosCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dayKey: $dayKey, ')
          ..write('slot: $slot, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $CustomProductsTable customProducts = $CustomProductsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements =
      $BodyMeasurementsTable(this);
  late final $DiaryDaysTable diaryDays = $DiaryDaysTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $MealItemsTable mealItems = $MealItemsTable(this);
  late final $ProgressPhotosTable progressPhotos = $ProgressPhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localUsers,
        foods,
        customProducts,
        recipes,
        recipeIngredients,
        bodyMeasurements,
        diaryDays,
        meals,
        mealItems,
        progressPhotos
      ];
}

typedef $$LocalUsersTableCreateCompanionBuilder = LocalUsersCompanion Function({
  required String userId,
  required String email,
  required String registrationStatus,
  Value<String?> name,
  Value<String?> sex,
  Value<String?> goal,
  Value<String?> activityLevel,
  Value<double?> heightCm,
  Value<double> deficitKcal,
  Value<DateTime?> dateOfBirth,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalUsersTableUpdateCompanionBuilder = LocalUsersCompanion Function({
  Value<String> userId,
  Value<String> email,
  Value<String> registrationStatus,
  Value<String?> name,
  Value<String?> sex,
  Value<String?> goal,
  Value<String?> activityLevel,
  Value<double?> heightCm,
  Value<double> deficitKcal,
  Value<DateTime?> dateOfBirth,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get deficitKcal => $composableBuilder(
      column: $table.deficitKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get deficitKcal => $composableBuilder(
      column: $table.deficitKcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get registrationStatus => $composableBuilder(
      column: $table.registrationStatus, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get deficitKcal => $composableBuilder(
      column: $table.deficitKcal, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()> {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> registrationStatus = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double> deficitKcal = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion(
            userId: userId,
            email: email,
            registrationStatus: registrationStatus,
            name: name,
            sex: sex,
            goal: goal,
            activityLevel: activityLevel,
            heightCm: heightCm,
            deficitKcal: deficitKcal,
            dateOfBirth: dateOfBirth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String email,
            required String registrationStatus,
            Value<String?> name = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<String?> activityLevel = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double> deficitKcal = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion.insert(
            userId: userId,
            email: email,
            registrationStatus: registrationStatus,
            name: name,
            sex: sex,
            goal: goal,
            activityLevel: activityLevel,
            heightCm: heightCm,
            deficitKcal: deficitKcal,
            dateOfBirth: dateOfBirth,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()>;
typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  required String id,
  required String name,
  required double calories,
  required double proteins,
  required double fats,
  required double carbs,
  Value<int> rowid,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> calories,
  Value<double> proteins,
  Value<double> fats,
  Value<double> carbs,
  Value<int> rowid,
});

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteins =>
      $composableBuilder(column: $table.proteins, builder: (column) => column);

  GeneratedColumn<double> get fats =>
      $composableBuilder(column: $table.fats, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);
}

class $$FoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodsTable,
    Food,
    $$FoodsTableFilterComposer,
    $$FoodsTableOrderingComposer,
    $$FoodsTableAnnotationComposer,
    $$FoodsTableCreateCompanionBuilder,
    $$FoodsTableUpdateCompanionBuilder,
    (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
    Food,
    PrefetchHooks Function()> {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodsCompanion(
            id: id,
            name: name,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double calories,
            required double proteins,
            required double fats,
            required double carbs,
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodsCompanion.insert(
            id: id,
            name: name,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodsTable,
    Food,
    $$FoodsTableFilterComposer,
    $$FoodsTableOrderingComposer,
    $$FoodsTableAnnotationComposer,
    $$FoodsTableCreateCompanionBuilder,
    $$FoodsTableUpdateCompanionBuilder,
    (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
    Food,
    PrefetchHooks Function()>;
typedef $$CustomProductsTableCreateCompanionBuilder = CustomProductsCompanion
    Function({
  required String id,
  required String userId,
  required String name,
  required double calories,
  required double proteins,
  required double fats,
  required double carbs,
  Value<bool> deleted,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CustomProductsTableUpdateCompanionBuilder = CustomProductsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> calories,
  Value<double> proteins,
  Value<double> fats,
  Value<double> carbs,
  Value<bool> deleted,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomProductsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomProductsTable> {
  $$CustomProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomProductsTable> {
  $$CustomProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteins => $composableBuilder(
      column: $table.proteins, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fats => $composableBuilder(
      column: $table.fats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomProductsTable> {
  $$CustomProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteins =>
      $composableBuilder(column: $table.proteins, builder: (column) => column);

  GeneratedColumn<double> get fats =>
      $composableBuilder(column: $table.fats, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomProductsTable,
    CustomProduct,
    $$CustomProductsTableFilterComposer,
    $$CustomProductsTableOrderingComposer,
    $$CustomProductsTableAnnotationComposer,
    $$CustomProductsTableCreateCompanionBuilder,
    $$CustomProductsTableUpdateCompanionBuilder,
    (
      CustomProduct,
      BaseReferences<_$AppDatabase, $CustomProductsTable, CustomProduct>
    ),
    CustomProduct,
    PrefetchHooks Function()> {
  $$CustomProductsTableTableManager(
      _$AppDatabase db, $CustomProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomProductsCompanion(
            id: id,
            userId: userId,
            name: name,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            deleted: deleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required double calories,
            required double proteins,
            required double fats,
            required double carbs,
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomProductsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            calories: calories,
            proteins: proteins,
            fats: fats,
            carbs: carbs,
            deleted: deleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomProductsTable,
    CustomProduct,
    $$CustomProductsTableFilterComposer,
    $$CustomProductsTableOrderingComposer,
    $$CustomProductsTableAnnotationComposer,
    $$CustomProductsTableCreateCompanionBuilder,
    $$CustomProductsTableUpdateCompanionBuilder,
    (
      CustomProduct,
      BaseReferences<_$AppDatabase, $CustomProductsTable, CustomProduct>
    ),
    CustomProduct,
    PrefetchHooks Function()>;
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<double> tareWeightGrams,
  Value<double> cookedWithTareWeightGrams,
  Value<bool> deleted,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> tareWeightGrams,
  Value<double> cookedWithTareWeightGrams,
  Value<bool> deleted,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tareWeightGrams => $composableBuilder(
      column: $table.tareWeightGrams,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cookedWithTareWeightGrams => $composableBuilder(
      column: $table.cookedWithTareWeightGrams,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tareWeightGrams => $composableBuilder(
      column: $table.tareWeightGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cookedWithTareWeightGrams => $composableBuilder(
      column: $table.cookedWithTareWeightGrams,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get tareWeightGrams => $composableBuilder(
      column: $table.tareWeightGrams, builder: (column) => column);

  GeneratedColumn<double> get cookedWithTareWeightGrams => $composableBuilder(
      column: $table.cookedWithTareWeightGrams, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableAnnotationComposer,
    $$RecipesTableCreateCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder,
    (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
    Recipe,
    PrefetchHooks Function()> {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> tareWeightGrams = const Value.absent(),
            Value<double> cookedWithTareWeightGrams = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion(
            id: id,
            userId: userId,
            name: name,
            tareWeightGrams: tareWeightGrams,
            cookedWithTareWeightGrams: cookedWithTareWeightGrams,
            deleted: deleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<double> tareWeightGrams = const Value.absent(),
            Value<double> cookedWithTareWeightGrams = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            tareWeightGrams: tareWeightGrams,
            cookedWithTareWeightGrams: cookedWithTareWeightGrams,
            deleted: deleted,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecipesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableAnnotationComposer,
    $$RecipesTableCreateCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder,
    (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
    Recipe,
    PrefetchHooks Function()>;
typedef $$RecipeIngredientsTableCreateCompanionBuilder
    = RecipeIngredientsCompanion Function({
  required String id,
  required String recipeId,
  required String sourceType,
  required String sourceId,
  required String nameSnapshot,
  required double grams,
  required double caloriesSnapshot,
  required double proteinsSnapshot,
  required double fatsSnapshot,
  required double carbsSnapshot,
  Value<int> rowid,
});
typedef $$RecipeIngredientsTableUpdateCompanionBuilder
    = RecipeIngredientsCompanion Function({
  Value<String> id,
  Value<String> recipeId,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> nameSnapshot,
  Value<double> grams,
  Value<double> caloriesSnapshot,
  Value<double> proteinsSnapshot,
  Value<double> fatsSnapshot,
  Value<double> carbsSnapshot,
  Value<int> rowid,
});

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grams => $composableBuilder(
      column: $table.grams, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot, builder: (column) => ColumnFilters(column));
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grams => $composableBuilder(
      column: $table.grams, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot,
      builder: (column) => ColumnOrderings(column));
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot, builder: (column) => column);

  GeneratedColumn<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot, builder: (column) => column);

  GeneratedColumn<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot, builder: (column) => column);

  GeneratedColumn<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot, builder: (column) => column);
}

class $$RecipeIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipeIngredientsTable,
    RecipeIngredient,
    $$RecipeIngredientsTableFilterComposer,
    $$RecipeIngredientsTableOrderingComposer,
    $$RecipeIngredientsTableAnnotationComposer,
    $$RecipeIngredientsTableCreateCompanionBuilder,
    $$RecipeIngredientsTableUpdateCompanionBuilder,
    (
      RecipeIngredient,
      BaseReferences<_$AppDatabase, $RecipeIngredientsTable, RecipeIngredient>
    ),
    RecipeIngredient,
    PrefetchHooks Function()> {
  $$RecipeIngredientsTableTableManager(
      _$AppDatabase db, $RecipeIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recipeId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> nameSnapshot = const Value.absent(),
            Value<double> grams = const Value.absent(),
            Value<double> caloriesSnapshot = const Value.absent(),
            Value<double> proteinsSnapshot = const Value.absent(),
            Value<double> fatsSnapshot = const Value.absent(),
            Value<double> carbsSnapshot = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipeIngredientsCompanion(
            id: id,
            recipeId: recipeId,
            sourceType: sourceType,
            sourceId: sourceId,
            nameSnapshot: nameSnapshot,
            grams: grams,
            caloriesSnapshot: caloriesSnapshot,
            proteinsSnapshot: proteinsSnapshot,
            fatsSnapshot: fatsSnapshot,
            carbsSnapshot: carbsSnapshot,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recipeId,
            required String sourceType,
            required String sourceId,
            required String nameSnapshot,
            required double grams,
            required double caloriesSnapshot,
            required double proteinsSnapshot,
            required double fatsSnapshot,
            required double carbsSnapshot,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipeIngredientsCompanion.insert(
            id: id,
            recipeId: recipeId,
            sourceType: sourceType,
            sourceId: sourceId,
            nameSnapshot: nameSnapshot,
            grams: grams,
            caloriesSnapshot: caloriesSnapshot,
            proteinsSnapshot: proteinsSnapshot,
            fatsSnapshot: fatsSnapshot,
            carbsSnapshot: carbsSnapshot,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecipeIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecipeIngredientsTable,
    RecipeIngredient,
    $$RecipeIngredientsTableFilterComposer,
    $$RecipeIngredientsTableOrderingComposer,
    $$RecipeIngredientsTableAnnotationComposer,
    $$RecipeIngredientsTableCreateCompanionBuilder,
    $$RecipeIngredientsTableUpdateCompanionBuilder,
    (
      RecipeIngredient,
      BaseReferences<_$AppDatabase, $RecipeIngredientsTable, RecipeIngredient>
    ),
    RecipeIngredient,
    PrefetchHooks Function()>;
typedef $$BodyMeasurementsTableCreateCompanionBuilder
    = BodyMeasurementsCompanion Function({
  required String id,
  required String userId,
  required String dayKey,
  required double weightKg,
  required double neckCm,
  required double waistCm,
  required double hipsCm,
  required double bodyFatPercent,
  Value<int> rowid,
});
typedef $$BodyMeasurementsTableUpdateCompanionBuilder
    = BodyMeasurementsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> dayKey,
  Value<double> weightKg,
  Value<double> neckCm,
  Value<double> waistCm,
  Value<double> hipsCm,
  Value<double> bodyFatPercent,
  Value<int> rowid,
});

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get neckCm => $composableBuilder(
      column: $table.neckCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waistCm => $composableBuilder(
      column: $table.waistCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hipsCm => $composableBuilder(
      column: $table.hipsCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bodyFatPercent => $composableBuilder(
      column: $table.bodyFatPercent,
      builder: (column) => ColumnFilters(column));
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get neckCm => $composableBuilder(
      column: $table.neckCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waistCm => $composableBuilder(
      column: $table.waistCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hipsCm => $composableBuilder(
      column: $table.hipsCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bodyFatPercent => $composableBuilder(
      column: $table.bodyFatPercent,
      builder: (column) => ColumnOrderings(column));
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPercent => $composableBuilder(
      column: $table.bodyFatPercent, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyMeasurementsTable,
    BodyMeasurement,
    $$BodyMeasurementsTableFilterComposer,
    $$BodyMeasurementsTableOrderingComposer,
    $$BodyMeasurementsTableAnnotationComposer,
    $$BodyMeasurementsTableCreateCompanionBuilder,
    $$BodyMeasurementsTableUpdateCompanionBuilder,
    (
      BodyMeasurement,
      BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>
    ),
    BodyMeasurement,
    PrefetchHooks Function()> {
  $$BodyMeasurementsTableTableManager(
      _$AppDatabase db, $BodyMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<double> neckCm = const Value.absent(),
            Value<double> waistCm = const Value.absent(),
            Value<double> hipsCm = const Value.absent(),
            Value<double> bodyFatPercent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyMeasurementsCompanion(
            id: id,
            userId: userId,
            dayKey: dayKey,
            weightKg: weightKg,
            neckCm: neckCm,
            waistCm: waistCm,
            hipsCm: hipsCm,
            bodyFatPercent: bodyFatPercent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String dayKey,
            required double weightKg,
            required double neckCm,
            required double waistCm,
            required double hipsCm,
            required double bodyFatPercent,
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyMeasurementsCompanion.insert(
            id: id,
            userId: userId,
            dayKey: dayKey,
            weightKg: weightKg,
            neckCm: neckCm,
            waistCm: waistCm,
            hipsCm: hipsCm,
            bodyFatPercent: bodyFatPercent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BodyMeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BodyMeasurementsTable,
    BodyMeasurement,
    $$BodyMeasurementsTableFilterComposer,
    $$BodyMeasurementsTableOrderingComposer,
    $$BodyMeasurementsTableAnnotationComposer,
    $$BodyMeasurementsTableCreateCompanionBuilder,
    $$BodyMeasurementsTableUpdateCompanionBuilder,
    (
      BodyMeasurement,
      BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>
    ),
    BodyMeasurement,
    PrefetchHooks Function()>;
typedef $$DiaryDaysTableCreateCompanionBuilder = DiaryDaysCompanion Function({
  required String id,
  required String userId,
  required String dayKey,
  Value<double> waterMl,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$DiaryDaysTableUpdateCompanionBuilder = DiaryDaysCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> dayKey,
  Value<double> waterMl,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DiaryDaysTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryDaysTable> {
  $$DiaryDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waterMl => $composableBuilder(
      column: $table.waterMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DiaryDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryDaysTable> {
  $$DiaryDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waterMl => $composableBuilder(
      column: $table.waterMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DiaryDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryDaysTable> {
  $$DiaryDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<double> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DiaryDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiaryDaysTable,
    DiaryDay,
    $$DiaryDaysTableFilterComposer,
    $$DiaryDaysTableOrderingComposer,
    $$DiaryDaysTableAnnotationComposer,
    $$DiaryDaysTableCreateCompanionBuilder,
    $$DiaryDaysTableUpdateCompanionBuilder,
    (DiaryDay, BaseReferences<_$AppDatabase, $DiaryDaysTable, DiaryDay>),
    DiaryDay,
    PrefetchHooks Function()> {
  $$DiaryDaysTableTableManager(_$AppDatabase db, $DiaryDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<double> waterMl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryDaysCompanion(
            id: id,
            userId: userId,
            dayKey: dayKey,
            waterMl: waterMl,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String dayKey,
            Value<double> waterMl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryDaysCompanion.insert(
            id: id,
            userId: userId,
            dayKey: dayKey,
            waterMl: waterMl,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiaryDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiaryDaysTable,
    DiaryDay,
    $$DiaryDaysTableFilterComposer,
    $$DiaryDaysTableOrderingComposer,
    $$DiaryDaysTableAnnotationComposer,
    $$DiaryDaysTableCreateCompanionBuilder,
    $$DiaryDaysTableUpdateCompanionBuilder,
    (DiaryDay, BaseReferences<_$AppDatabase, $DiaryDaysTable, DiaryDay>),
    DiaryDay,
    PrefetchHooks Function()>;
typedef $$MealsTableCreateCompanionBuilder = MealsCompanion Function({
  required String id,
  required String userId,
  required String dayKey,
  required String mealType,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$MealsTableUpdateCompanionBuilder = MealsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> dayKey,
  Value<String> mealType,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
    Meal,
    PrefetchHooks Function()> {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealsCompanion(
            id: id,
            userId: userId,
            dayKey: dayKey,
            mealType: mealType,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String dayKey,
            required String mealType,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealsCompanion.insert(
            id: id,
            userId: userId,
            dayKey: dayKey,
            mealType: mealType,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableAnnotationComposer,
    $$MealsTableCreateCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder,
    (Meal, BaseReferences<_$AppDatabase, $MealsTable, Meal>),
    Meal,
    PrefetchHooks Function()>;
typedef $$MealItemsTableCreateCompanionBuilder = MealItemsCompanion Function({
  required String id,
  required String mealId,
  required String sourceType,
  required String sourceId,
  required String nameSnapshot,
  required double grams,
  required double caloriesSnapshot,
  required double proteinsSnapshot,
  required double fatsSnapshot,
  required double carbsSnapshot,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$MealItemsTableUpdateCompanionBuilder = MealItemsCompanion Function({
  Value<String> id,
  Value<String> mealId,
  Value<String> sourceType,
  Value<String> sourceId,
  Value<String> nameSnapshot,
  Value<double> grams,
  Value<double> caloriesSnapshot,
  Value<double> proteinsSnapshot,
  Value<double> fatsSnapshot,
  Value<double> carbsSnapshot,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grams => $composableBuilder(
      column: $table.grams, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealId => $composableBuilder(
      column: $table.mealId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grams => $composableBuilder(
      column: $table.grams, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
      column: $table.sourceType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get nameSnapshot => $composableBuilder(
      column: $table.nameSnapshot, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get caloriesSnapshot => $composableBuilder(
      column: $table.caloriesSnapshot, builder: (column) => column);

  GeneratedColumn<double> get proteinsSnapshot => $composableBuilder(
      column: $table.proteinsSnapshot, builder: (column) => column);

  GeneratedColumn<double> get fatsSnapshot => $composableBuilder(
      column: $table.fatsSnapshot, builder: (column) => column);

  GeneratedColumn<double> get carbsSnapshot => $composableBuilder(
      column: $table.carbsSnapshot, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MealItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableAnnotationComposer,
    $$MealItemsTableCreateCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder,
    (MealItem, BaseReferences<_$AppDatabase, $MealItemsTable, MealItem>),
    MealItem,
    PrefetchHooks Function()> {
  $$MealItemsTableTableManager(_$AppDatabase db, $MealItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mealId = const Value.absent(),
            Value<String> sourceType = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> nameSnapshot = const Value.absent(),
            Value<double> grams = const Value.absent(),
            Value<double> caloriesSnapshot = const Value.absent(),
            Value<double> proteinsSnapshot = const Value.absent(),
            Value<double> fatsSnapshot = const Value.absent(),
            Value<double> carbsSnapshot = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealItemsCompanion(
            id: id,
            mealId: mealId,
            sourceType: sourceType,
            sourceId: sourceId,
            nameSnapshot: nameSnapshot,
            grams: grams,
            caloriesSnapshot: caloriesSnapshot,
            proteinsSnapshot: proteinsSnapshot,
            fatsSnapshot: fatsSnapshot,
            carbsSnapshot: carbsSnapshot,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mealId,
            required String sourceType,
            required String sourceId,
            required String nameSnapshot,
            required double grams,
            required double caloriesSnapshot,
            required double proteinsSnapshot,
            required double fatsSnapshot,
            required double carbsSnapshot,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealItemsCompanion.insert(
            id: id,
            mealId: mealId,
            sourceType: sourceType,
            sourceId: sourceId,
            nameSnapshot: nameSnapshot,
            grams: grams,
            caloriesSnapshot: caloriesSnapshot,
            proteinsSnapshot: proteinsSnapshot,
            fatsSnapshot: fatsSnapshot,
            carbsSnapshot: carbsSnapshot,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableAnnotationComposer,
    $$MealItemsTableCreateCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder,
    (MealItem, BaseReferences<_$AppDatabase, $MealItemsTable, MealItem>),
    MealItem,
    PrefetchHooks Function()>;
typedef $$ProgressPhotosTableCreateCompanionBuilder = ProgressPhotosCompanion
    Function({
  required String id,
  required String userId,
  required String dayKey,
  required int slot,
  required String localPath,
  Value<int> rowid,
});
typedef $$ProgressPhotosTableUpdateCompanionBuilder = ProgressPhotosCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> dayKey,
  Value<int> slot,
  Value<String> localPath,
  Value<int> rowid,
});

class $$ProgressPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get slot => $composableBuilder(
      column: $table.slot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));
}

class $$ProgressPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dayKey => $composableBuilder(
      column: $table.dayKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get slot => $composableBuilder(
      column: $table.slot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));
}

class $$ProgressPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressPhotosTable> {
  $$ProgressPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$ProgressPhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProgressPhotosTable,
    ProgressPhoto,
    $$ProgressPhotosTableFilterComposer,
    $$ProgressPhotosTableOrderingComposer,
    $$ProgressPhotosTableAnnotationComposer,
    $$ProgressPhotosTableCreateCompanionBuilder,
    $$ProgressPhotosTableUpdateCompanionBuilder,
    (
      ProgressPhoto,
      BaseReferences<_$AppDatabase, $ProgressPhotosTable, ProgressPhoto>
    ),
    ProgressPhoto,
    PrefetchHooks Function()> {
  $$ProgressPhotosTableTableManager(
      _$AppDatabase db, $ProgressPhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<int> slot = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProgressPhotosCompanion(
            id: id,
            userId: userId,
            dayKey: dayKey,
            slot: slot,
            localPath: localPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String dayKey,
            required int slot,
            required String localPath,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProgressPhotosCompanion.insert(
            id: id,
            userId: userId,
            dayKey: dayKey,
            slot: slot,
            localPath: localPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProgressPhotosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProgressPhotosTable,
    ProgressPhoto,
    $$ProgressPhotosTableFilterComposer,
    $$ProgressPhotosTableOrderingComposer,
    $$ProgressPhotosTableAnnotationComposer,
    $$ProgressPhotosTableCreateCompanionBuilder,
    $$ProgressPhotosTableUpdateCompanionBuilder,
    (
      ProgressPhoto,
      BaseReferences<_$AppDatabase, $ProgressPhotosTable, ProgressPhoto>
    ),
    ProgressPhoto,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$CustomProductsTableTableManager get customProducts =>
      $$CustomProductsTableTableManager(_db, _db.customProducts);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$DiaryDaysTableTableManager get diaryDays =>
      $$DiaryDaysTableTableManager(_db, _db.diaryDays);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$MealItemsTableTableManager get mealItems =>
      $$MealItemsTableTableManager(_db, _db.mealItems);
  $$ProgressPhotosTableTableManager get progressPhotos =>
      $$ProgressPhotosTableTableManager(_db, _db.progressPhotos);
}
