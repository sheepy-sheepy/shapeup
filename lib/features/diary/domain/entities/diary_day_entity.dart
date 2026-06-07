import 'package:shapeup/domain/entities/macro_norms_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_entity.dart';

class DiaryDayEntity {
  const DiaryDayEntity({
    required this.dayKey,
    required this.meals,
    required this.norms,
  });

  final String dayKey;
  final List<MealEntity> meals;
  final MacroNormsEntity? norms;
}
