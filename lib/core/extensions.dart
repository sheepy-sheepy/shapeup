import 'enums.dart';

extension SexX on Sex {
  String get label => this == Sex.male ? 'Мужской' : 'Женский';
}

extension GoalX on Goal {
  String get label => switch (this) {
        Goal.loseWeight => 'Похудеть',
        Goal.gainWeight => 'Набрать массу',
        Goal.maintain => 'Поддерживать вес',
      };
}

extension ActivityLevelX on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Сидячий образ жизни',
        ActivityLevel.light => 'Тренировки 1-3 раза в неделю',
        ActivityLevel.moderate => 'Тренировки 3-5 раз в неделю',
        ActivityLevel.high => 'Тренировки 6-7 раз в неделю',
        ActivityLevel.extreme => 'Профессиональный спорт или физическая работа',
      };
}

extension MealTypeX on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Завтрак',
        MealType.lunch => 'Обед',
        MealType.dinner => 'Ужин',
        MealType.snack => 'Перекус',
      };
}

String kbzhuPer100Text({
  required double calories,
  required double proteins,
  required double fats,
  required double carbs,
}) {
  return 'К: ${calories.toStringAsFixed(2)} '
      'Б: ${proteins.toStringAsFixed(2)} '
      'Ж: ${fats.toStringAsFixed(2)} '
      'У: ${carbs.toStringAsFixed(2)} / 100 г';
}

String kbzhuForGramsText({
  required double grams,
  required double caloriesPer100,
  required double proteinsPer100,
  required double fatsPer100,
  required double carbsPer100,
}) {
  final ratio = grams / 100.0;

  final calories = caloriesPer100 * ratio;
  final proteins = proteinsPer100 * ratio;
  final fats = fatsPer100 * ratio;
  final carbs = carbsPer100 * ratio;

  return '${grams.toStringAsFixed(1)} г '
      'К: ${calories.toStringAsFixed(2)} '
      'Б: ${proteins.toStringAsFixed(2)} '
      'Ж: ${fats.toStringAsFixed(2)} '
      'У: ${carbs.toStringAsFixed(2)}';
}