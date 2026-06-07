import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/diary/domain/entities/diary_day_entity.dart';
import 'package:shapeup/features/diary/domain/repositories/diary_repository.dart';
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart';
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';

export 'package:shapeup/features/diary/domain/entities/diary_day_entity.dart' show DiaryDayEntity;

class LoadDiaryDayUseCase {
  const LoadDiaryDayUseCase({
    required this.diaryRepository,
    required this.measurementsRepository,
    required this.profileRepository,
  });

  final DiaryRepository diaryRepository;
  final MeasurementsRepository measurementsRepository;
  final ProfileRepository profileRepository;

  Future<DiaryDayEntity> loadDay({
    required String dayKey,
    required DateTime date,
  }) async {
    await diaryRepository.ensureMealsForDay(dayKey);

    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.measurementForNormDay(dayKey),
      diaryRepository.mealsForDay(dayKey),
    ]);

    final user = result[0] as LocalUserEntity?;
    final measurement = result[1] as BodyMeasurementEntity?;
    final meals = result[2] as List<MealEntity>;

    return DiaryDayEntity(
      dayKey: dayKey,
      meals: meals,
      norms: _dailyNormsOrNull(
        user: user,
        measurement: measurement,
        date: date,
      ),
    );
  }

  MacroNormsEntity? _dailyNormsOrNull({
    required LocalUserEntity? user,
    required BodyMeasurementEntity? measurement,
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

    return NutritionCalculationUseCase.dailyNorms(
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
