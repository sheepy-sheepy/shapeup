class LocalUserEntity {
  const LocalUserEntity({
    required this.userId,
    required this.email,
    required this.registrationStatus,
    required this.name,
    required this.sex,
    required this.goal,
    required this.activityLevel,
    required this.heightCm,
    required this.deficitKcal,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String email;
  final String registrationStatus;
  final String? name;
  final String? sex;
  final String? goal;
  final String? activityLevel;
  final double? heightCm;
  final double deficitKcal;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
}
