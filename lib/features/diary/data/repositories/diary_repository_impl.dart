import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart';
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart' as auth_domain;
import 'package:shapeup/features/diary/domain/repositories/diary_repository.dart' as domain;
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/local/entity_mappers.dart';
import 'dart:math' as math;
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/diary/domain/entities/meal_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart';

class DiaryRepositoryImpl implements domain.DiaryRepository {
  DiaryRepositoryImpl(this.db, this.auth);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final _uuid = const Uuid();

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Future<void> ensureMealsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AppException(unauthorizedMessage);
    }

    for (final mealType in _mealTypes) {
      final rows = await (db.select(db.meals)
            ..where((t) =>
                t.userId.equals(user.id) &
                t.dayKey.equals(dayKey) &
                t.mealType.equals(mealType)))
          .get();

      if (rows.isEmpty) {
        await db.into(db.meals).insert(
              MealsCompanion.insert(
                id: _uuid.v4(),
                userId: user.id,
                dayKey: dayKey,
                mealType: mealType,
              ),
            );
        continue;
      }

      if (rows.length > 1) {
        final keep = rows.first;

        for (final duplicate in rows.skip(1)) {
          await (db.update(db.mealItems)
                ..where((t) => t.mealId.equals(duplicate.id)))
              .write(
            MealItemsCompanion(
              mealId: drift.Value(keep.id),
            ),
          );

          await (db.delete(db.meals)..where((t) => t.id.equals(duplicate.id)))
              .go();
        }
      }
    }

    final diaryRows = await (db.select(db.diaryDays)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .get();

    if (diaryRows.isEmpty) {
      await db.into(db.diaryDays).insert(
            DiaryDaysCompanion.insert(
              id: _uuid.v4(),
              userId: user.id,
              dayKey: dayKey,
              waterMl: const drift.Value(0),
            ),
          );
    } else if (diaryRows.length > 1) {
      final keep = diaryRows.first;

      final maxWater =
          diaryRows.map((e) => e.waterMl).fold<double>(keep.waterMl, math.max);

      await (db.update(db.diaryDays)..where((t) => t.id.equals(keep.id))).write(
        DiaryDaysCompanion(
          waterMl: drift.Value(maxWater),
        ),
      );

      for (final duplicate in diaryRows.skip(1)) {
        await (db.delete(db.diaryDays)..where((t) => t.id.equals(duplicate.id)))
            .go();
      }
    }
  }

  @override
  Future<List<MealEntity>> mealsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return [];

    final rows = await (db.select(db.meals)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .get();

    final byType = <String, Meal>{};
    for (final row in rows) {
      byType[row.mealType] ??= row;
    }

    final ordered = <MealEntity>[];
    for (final type in _mealTypes) {
      final meal = byType[type];
      if (meal != null) ordered.add(meal.toEntity());
    }
    return ordered;
  }

  @override
  Future<List<MealItemEntity>> mealItems(String mealId) async {
    final rows = await (db.select(db.mealItems)
          ..where((t) => t.mealId.equals(mealId)))
        .get();
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<void> addMealItem({
    required String mealId,
    required String sourceType,
    required String sourceId,
    required String name,
    required double grams,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  }) async {
    await db.into(db.mealItems).insert(
          MealItemsCompanion.insert(
            id: _uuid.v4(),
            mealId: mealId,
            sourceType: sourceType,
            sourceId: sourceId,
            nameSnapshot: name,
            grams: grams,
            caloriesSnapshot: calories,
            proteinsSnapshot: proteins,
            fatsSnapshot: fats,
            carbsSnapshot: carbs,
          ),
        );
  }

  @override
  Future<void> updateMealItemGrams({
    required String mealItemId,
    required double grams,
  }) async {
    await (db.update(db.mealItems)..where((t) => t.id.equals(mealItemId)))
        .write(
      MealItemsCompanion(
        grams: drift.Value(grams),
      ),
    );

    final item = await (db.select(db.mealItems)
          ..where((t) => t.id.equals(mealItemId)))
        .getSingleOrNull();

    if (item != null) {}
  }

  @override
  Future<void> deleteMealItem(String mealItemId) async {
    final item = await (db.select(db.mealItems)
          ..where((t) => t.id.equals(mealItemId)))
        .getSingleOrNull();

    await (db.delete(db.mealItems)..where((t) => t.id.equals(mealItemId))).go();

    if (item != null) {}
  }

  @override
  Future<void> updateWater(String dayKey, double waterMl) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AppException(unauthorizedMessage);
    }

    final existing = await (db.select(db.diaryDays)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.diaryDays)..where((t) => t.id.equals(existing.id)))
          .write(
        DiaryDaysCompanion(
          waterMl: drift.Value(waterMl),
        ),
      );
    } else {
      await db.into(db.diaryDays).insert(
            DiaryDaysCompanion.insert(
              id: _uuid.v4(),
              userId: user.id,
              dayKey: dayKey,
              waterMl: drift.Value(waterMl),
            ),
          );
    }
  }

  @override
  Future<DiaryTotalsEntity> totalsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) {
      return const DiaryTotalsEntity(
        calories: 0,
        proteins: 0,
        fats: 0,
        carbs: 0,
        waterMl: 0,
      );
    }

    final meals = await (db.select(db.meals)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .get();

    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;

    for (final meal in meals) {
      final items = await (db.select(db.mealItems)
            ..where((t) => t.mealId.equals(meal.id)))
          .get();

      for (final item in items) {
        final ratio = item.grams / 100.0;
        calories += item.caloriesSnapshot * ratio;
        proteins += item.proteinsSnapshot * ratio;
        fats += item.fatsSnapshot * ratio;
        carbs += item.carbsSnapshot * ratio;
      }
    }

    final diaryDay = await (db.select(db.diaryDays)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .getSingleOrNull();

    return DiaryTotalsEntity(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      waterMl: diaryDay?.waterMl ?? 0,
    );
  }
}
