import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../core/nutrition_calculator.dart';
import '../entities/local_entities.dart';
import '../repositories/diary_repository.dart';
import '../repositories/measurements_repository.dart';
import '../repositories/profile_repository.dart';

final diaryDayLoaderProvider = Provider<DiaryDayLoader>((ref) {
  return DiaryDayLoader(
    diaryRepository: ref.watch(diaryRepositoryProvider),
    measurementsRepository: ref.watch(measurementsRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

class DiaryDayData {
  const DiaryDayData({
    required this.dayKey,
    required this.meals,
    required this.norms,
  });

  final String dayKey;
  final List<Meal> meals;
  final MacroNorms? norms;
}

class DiaryDayLoader {
  const DiaryDayLoader({
    required this.diaryRepository,
    required this.measurementsRepository,
    required this.profileRepository,
  });

  final DiaryRepository diaryRepository;
  final MeasurementsRepository measurementsRepository;
  final ProfileRepository profileRepository;

  Future<DiaryDayData> loadDay({
    required String dayKey,
    required DateTime date,
  }) async {
    await diaryRepository.ensureMealsForDay(dayKey);

    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.measurementForNormDay(dayKey),
      diaryRepository.mealsForDay(dayKey),
    ]);

    final user = result[0] as LocalUser?;
    final measurement = result[1] as BodyMeasurement?;
    final meals = result[2] as List<Meal>;

    return DiaryDayData(
      dayKey: dayKey,
      meals: meals,
      norms: _dailyNormsOrNull(
        user: user,
        measurement: measurement,
        date: date,
      ),
    );
  }

  MacroNorms? _dailyNormsOrNull({
    required LocalUser? user,
    required BodyMeasurement? measurement,
    required DateTime date,
  }) {
    if (user == null ||
        user.sex == null ||
        user.goal == null ||
        user.activityLevel == null ||
        user.dateOfBirth == null ||
        user.heightCm == null ||
        measurement == null) {
      return null;
    }

    return NutritionCalculator.dailyNorms(
      sex: Sex.values.firstWhere((e) => e.name == user.sex),
      goal: Goal.values.firstWhere((e) => e.name == user.goal),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == user.activityLevel,
      ),
      weightKg: measurement.weightKg,
      heightCm: user.heightCm!,
      dob: user.dateOfBirth!,
      deficitKcal: user.deficitKcal,
      today: date,
    );
  }
}
