enum RegistrationStatus {
  emailUnconfirmed,
  onboardingNotDone,
  fullyRegistered;

  String get value => switch (this) {
        RegistrationStatus.emailUnconfirmed => 'email_unconfirmed',
        RegistrationStatus.onboardingNotDone => 'onboarding_not_done',
        RegistrationStatus.fullyRegistered => 'fully_registered',
      };

  static RegistrationStatus fromValue(String value) {
    return RegistrationStatus.values.firstWhere((e) => e.value == value);
  }
}

enum Sex { male, female }

enum Goal { loseWeight, gainWeight, maintain }

enum ActivityLevel { sedentary, light, moderate, high, extreme }

enum MealType { breakfast, lunch, dinner, snack }
