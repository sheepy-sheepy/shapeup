import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/diary_totals.dart';
import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/diary_repository.dart' as domain;
import '../local/app_database.dart';
import 'dart:math' as math;

final diaryRepositoryProvider = Provider<domain.DiaryRepository>((ref) {
  return DiaryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
  );
});

class DiaryRepository implements domain.DiaryRepository {
  DiaryRepository(this.db, this.auth);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final _uuid = const Uuid();

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Future<void> ensureMealsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    // 1. Чиним meal'ы за день: по каждому mealType должна быть ровно 1 запись
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

        // переносим meal_items со всех дублей на сохраняемую запись
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

    // 2. Чиним diary_day за день: должна быть ровно 1 запись
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

      // если в дублях есть больше воды — сохраняем максимум
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
  Future<List<Meal>> mealsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return [];

    final rows = await (db.select(db.meals)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey)))
        .get();

    final byType = <String, Meal>{};
    for (final row in rows) {
      byType[row.mealType] ??= row;
    }

    final ordered = <Meal>[];
    for (final type in _mealTypes) {
      final meal = byType[type];
      if (meal != null) ordered.add(meal);
    }
    return ordered;
  }

  @override
  Future<List<MealItem>> mealItems(String mealId) async {
    return (db.select(db.mealItems)..where((t) => t.mealId.equals(mealId)))
        .get();
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
      throw Exception('Пользователь не авторизован');
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
  Future<DiaryTotals> totalsForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) {
      return const DiaryTotals(
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

    return DiaryTotals(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      waterMl: diaryDay?.waterMl ?? 0,
    );
  }
}
