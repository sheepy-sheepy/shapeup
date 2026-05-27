import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LocalUsers extends Table {
  TextColumn get userId => text()();
  TextColumn get email => text()();
  TextColumn get registrationStatus => text()();
  TextColumn get name => text().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get goal => text().nullable()();
  TextColumn get activityLevel => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get deficitKcal => real().withDefault(const Constant(300))();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get calories => real()();
  RealColumn get proteins => real()();
  RealColumn get fats => real()();
  RealColumn get carbs => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomProducts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get calories => real()();
  RealColumn get proteins => real()();
  RealColumn get fats => real()();
  RealColumn get carbs => real()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get tareWeightGrams => real().withDefault(const Constant(0.0))();
  RealColumn get cookedWithTareWeightGrams =>
      real().withDefault(const Constant(0.0))();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get nameSnapshot => text()();
  RealColumn get grams => real()();
  RealColumn get caloriesSnapshot => real()();
  RealColumn get proteinsSnapshot => real()();
  RealColumn get fatsSnapshot => real()();
  RealColumn get carbsSnapshot => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get dayKey => text()();
  RealColumn get weightKg => real()();
  RealColumn get neckCm => real()();
  RealColumn get waistCm => real()();
  RealColumn get hipsCm => real()();
  RealColumn get bodyFatPercent => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, dayKey},
      ];
}

class DiaryDays extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get dayKey => text()();
  RealColumn get waterMl => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Meals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get dayKey => text()();
  TextColumn get mealType => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class MealItems extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get nameSnapshot => text()();
  RealColumn get grams => real()();
  RealColumn get caloriesSnapshot => real()();
  RealColumn get proteinsSnapshot => real()();
  RealColumn get fatsSnapshot => real()();
  RealColumn get carbsSnapshot => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ProgressPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get dayKey => text()();
  IntColumn get slot => integer()();
  TextColumn get localPath => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalUsers,
    Foods,
    CustomProducts,
    Recipes,
    RecipeIngredients,
    BodyMeasurements,
    DiaryDays,
    Meals,
    MealItems,
    ProgressPhotos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(recipes, recipes.tareWeightGrams);
            await m.addColumn(recipes, recipes.cookedWithTareWeightGrams);
          }

          if (from < 3) {
            await m.addColumn(mealItems, mealItems.createdAt);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'shapeup.sqlite'));
    return NativeDatabase(file);
  });
}

final appDatabaseProvider =
    Provider<AppDatabase>((ref) => throw UnimplementedError());
