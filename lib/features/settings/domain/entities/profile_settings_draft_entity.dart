import 'package:shapeup/core/shared/enums.dart';

class ProfileSettingsDraftEntity {
  const ProfileSettingsDraftEntity({
    required this.name,
    required this.heightCm,
    required this.deficitKcal,
    required this.dateOfBirth,
    required this.sex,
    required this.goal,
    required this.activity,
  });

  final String name;
  final double? heightCm;
  final double? deficitKcal;
  final DateTime? dateOfBirth;
  final Sex sex;
  final Goal goal;
  final ActivityLevel activity;
}
