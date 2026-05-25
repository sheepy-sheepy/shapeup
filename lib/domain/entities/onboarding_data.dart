import '../../core/enums.dart';

class OnboardingData {
  final String name;
  final double heightCm;
  final double weightKg;
  final double neckCm;
  final double hipsCm;
  final double waistCm;
  final Sex sex;
  final Goal goal;
  final ActivityLevel activityLevel;
  final DateTime dateOfBirth;
  final double deficitKcal;

  const OnboardingData({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.neckCm,
    required this.hipsCm,
    required this.waistCm,
    required this.sex,
    required this.goal,
    required this.activityLevel,
    required this.dateOfBirth,
    this.deficitKcal = 300,
  });
}
