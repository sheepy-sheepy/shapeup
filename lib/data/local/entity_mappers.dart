import 'package:shapeup/features/diary/domain/entities/meal_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/food_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';
import 'database.dart' as db;

extension LocalUserMapper on db.LocalUser {
  LocalUserEntity toEntity() {
    return LocalUserEntity(
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
    );
  }
}

extension FoodMapper on db.Food {
  FoodEntity toEntity() {
    return FoodEntity(
      id: id,
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }
}

extension CustomProductMapper on db.CustomProduct {
  CustomProductEntity toEntity() {
    return CustomProductEntity(
      id: id,
      userId: userId,
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      deleted: deleted,
      updatedAt: updatedAt,
    );
  }
}

extension RecipeMapper on db.Recipe {
  RecipeEntity toEntity() {
    return RecipeEntity(
      id: id,
      userId: userId,
      name: name,
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
      deleted: deleted,
      updatedAt: updatedAt,
    );
  }
}

extension RecipeIngredientMapper on db.RecipeIngredient {
  RecipeIngredientEntity toEntity() {
    return RecipeIngredientEntity(
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
    );
  }
}

extension BodyMeasurementMapper on db.BodyMeasurement {
  BodyMeasurementEntity toEntity() {
    return BodyMeasurementEntity(
      id: id,
      userId: userId,
      dayKey: dayKey,
      weightKg: weightKg,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
      bodyFatPercent: bodyFatPercent,
    );
  }
}

extension MealMapper on db.Meal {
  MealEntity toEntity() {
    return MealEntity(
      id: id,
      userId: userId,
      dayKey: dayKey,
      mealType: mealType,
      updatedAt: updatedAt,
    );
  }
}

extension MealItemMapper on db.MealItem {
  MealItemEntity toEntity() {
    return MealItemEntity(
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
    );
  }
}

extension ProgressPhotoMapper on db.ProgressPhoto {
  ProgressPhotoEntity toEntity() {
    return ProgressPhotoEntity(
      id: id,
      userId: userId,
      dayKey: dayKey,
      slot: slot,
      localPath: localPath,
    );
  }
}
