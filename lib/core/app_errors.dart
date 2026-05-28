class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

const String genericErrorMessage = 'Произошла ошибка. Повторите попытку.';
const String noInternetMessage =
    'Нет интернет-соединения. Проверьте подключение и повторите попытку.';
const String unauthorizedMessage = 'Пользователь не авторизован';
const String userNotFoundMessage = 'Пользователь не найден';
const String localProfileNotFoundMessage =
    'Локальный профиль не найден. Выполните загрузку данных.';
const String localProfileLoginAgainMessage =
    'Локальный профиль не найден. Выполните вход заново.';

const String loginCredentialsNotFoundMessage =
    'Пользователь с такой почтой и паролем не найден.';
const String invalidCurrentPasswordMessage = 'Неверный текущий пароль.';
const String emailNotConfirmedMessage =
    'Почта не подтверждена. Введите код из письма.';
const String emailAlreadyRegisteredMessage =
    'Аккаунт с такой почтой уже существует.';
const String invalidEmailMessage = 'Введите корректную почту.';
const String loginFailedMessage =
    'Не удалось выполнить вход. Повторите попытку.';
const String registerFailedMessage =
    'Не удалось выполнить регистрацию. Повторите попытку.';

const String registerPasswordRequirementsMessage =
    'Пароль не соответствует требованиям. Используйте минимум 6 символов.';
const String newPasswordRequirementsMessage =
    'Новый пароль не соответствует требованиям. Используйте минимум 6 символов.';
const String passwordChangedMessage = 'Пароль изменен';
const String measurementsSavedMessage = 'Сохранено';
const String passwordFieldsRequiredMessage = 'Введите старый и новый пароль';
const String samePasswordMessage = 'Новый пароль должен отличаться от старого';
const String passwordChangeFailedMessage =
    'Не удалось изменить пароль. Повторите попытку.';

const String requiredFieldMessage = 'Обязательное поле';
const String enterNumberMessage = 'Введите число';
const String positiveValueMessage = 'Значение должно быть больше 0';
const String nonNegativeValueMessage = 'Значение не может быть отрицательным';
const String enterPositiveNumberMessage = 'Введите положительное число';
const String gramsPositiveMessage = 'Граммы должны быть больше 0';
const String waterVolumePositiveMessage =
    'Введите положительный объем воды в мл';
const String dateFormatMessage = 'Введите дату в формате ДД.ММ.ГГГГ';
const String dateInvalidMessage = 'Введите корректную дату';
const String invalidDateFormatTechnicalMessage = 'Invalid date format';
const String deficitRangeMessage = 'Дефицит должен быть от 50 до 1000';

const String calculatedBodyFatInvalidMessage =
    'Рассчитанный % жира должен быть числом больше 0. Проверьте рост и параметры тела.';
const String recalculatedBodyFatInvalidMessage =
    'Пересчитанный % жира должен быть числом больше 0. Проверьте рост и параметры тела.';
const String bodyFatInputsInvalidMessage =
    'Для расчета процента жира все параметры тела должны быть числами больше 0.';
const String bodyParametersPositiveMessage =
    'Все параметры должны быть больше 0';
const String measurementParametersPositiveMessage =
    'Заполните все параметры положительными числами';
const String bodyFatMustBePositiveMessage = '% жира должен быть больше 0';
const String bodyFatInvalidMessage =
    'Процент жира должен быть числом больше 0. Проверьте рост и обхваты.';
const String bodyFatInvalidFallbackMessage =
    'Процент жира должен быть числом больше 0. Проверьте введенные параметры.';
const String invalidBodyFatTechnicalMessage = 'Invalid body fat';
const String maleWaistGreaterThanNeckMessage =
    'Для мужчин талия должна быть больше шеи.';
const String femaleWaistHipsGreaterThanNeckMessage =
    'Для женщин сумма талии и бедер должна быть больше шеи.';
const String noBodyValuesForFatRecalculationMessage =
    'Для пересчета % жира нет сохраненных параметров тела.';
const String fetchBodyValuesForFatRecalculationFailedMessage =
    'Не удалось получить параметры тела для пересчета % жира.';

const String onboardingNeedsInternetMessage =
    'Для завершения onboarding нужно интернет-соединение. Проверьте подключение и повторите попытку.';
const String onboardingSaveFailedMessage =
    'Не удалось сохранить данные onboarding. Повторите попытку.';
const String onboardingSupabaseFinishFailedMessage =
    'Не удалось завершить onboarding в Supabase. Повторите попытку.';
const String profileSaveFailedMessage =
    'Не удалось сохранить параметры пользователя. Проверьте интернет и повторите попытку.';

const String productDuplicateCustomMessage =
    'Продукт с таким названием уже есть в своих продуктах';
const String productDuplicateBaseMessage =
    'Продукт с таким названием уже есть в готовой базе продуктов';
const String recipeDuplicateMessage =
    'Рецепт с таким названием уже есть в своих рецептах';
const String recipeMinDifferentProductsMessage =
    'В рецепте должно быть минимум 2 разных продукта';

const String recipeFormRequiredMessage =
    'Укажите название, минимум 2 разных продукта, вес тары и вес готового блюда с тарой';
const String profileSavedMessage = 'Данные пользователя были успешно сохранены';
const String tareWeightNonNegativeMessage = 'Вес тары не может быть меньше 0';
const String cookedWithTareWeightNonNegativeMessage =
    'Вес готового блюда с тарой не может быть меньше 0';
const String cookedWeightPositiveMessage =
    'Итоговый вес готового блюда должен быть больше 0';
const String recipeCookedWeightMissingMessage =
    'У рецепта не указан итоговый вес готового блюда';

const String allPhotosRequiredMessage = 'Нужно добавить все 4 фото';
const String photosAlreadyAddedTodayMessage =
    'Фото за текущий день уже добавлены';
const String photoSavedMessage = 'Фото сохранены';
const String photoAccessDeniedMessage = 'Нет доступа к фото';
const String photoAccessSettingsMessage =
    'Нет доступа к фото. Разрешите доступ к фото в настройках приложения.';
const String photoOpenGalleryFailedMessage =
    'Не удалось открыть галерею. Проверьте разрешение на доступ к фото.';
const String invalidJpegMessage =
    'Неверный формат файла. Разрешены только изображения JPG или JPEG.';

const String baseFoodsLoadErrorTitle = 'Ошибка загрузки базы продуктов';
const String productsLoadErrorTitle = 'Ошибка загрузки продуктов';
const String recipesLoadErrorTitle = 'Ошибка загрузки рецептов';
const String diaryLoadErrorTitle = 'Ошибка загрузки дневника';
const String diaryTotalsLoadErrorTitle = 'Ошибка итогов дня';
const String waterLoadErrorTitle = 'Ошибка загрузки воды';
const String mealLoadErrorTitle = 'Ошибка загрузки приема пищи';
const String measurementsLoadErrorTitle = 'Ошибка загрузки';
const String photosLoadErrorTitle = 'Ошибка загрузки фото';
const String profileLoadErrorTitle = 'Ошибка загрузки профиля';

const String analyticsLoadErrorTitle = 'Ошибка загрузки аналитики';
const String registrationStatusNotFoundMessage = 'Статус регистрации не найден';
const String emailUnknownMessage = 'Не удалось определить почту пользователя.';
const String otpIncompleteMessage = 'Введите полный 6-значный код из цифр.';
const String otpInvalidMessage =
    'Код неверный или срок действия кода истек. Попробуйте проверить правильность кода или нажать на "Отправить код повторно".';
const String otpResendRateLimitedMessage =
    'Повторная отправка доступна не чаще одного раза в 60 секунд.';
const String otpResentMessage = 'Код отправлен повторно.';
const String otpResendFailedMessage =
    'Не удалось отправить код повторно. Повторите попытку.';
const String authRepositoryNotConnectedMessage =
    'AuthRepository должен быть подключен в data-слое';
const String diaryRepositoryNotConnectedMessage =
    'DiaryRepository должен быть подключен в data-слое';
const String measurementsRepositoryNotConnectedMessage =
    'MeasurementsRepository должен быть подключен в data-слое';
const String photosRepositoryNotConnectedMessage =
    'PhotosRepository должен быть подключен в data-слое';
const String productsRepositoryNotConnectedMessage =
    'ProductsRepository должен быть подключен в data-слое';
const String profileRepositoryNotConnectedMessage =
    'ProfileRepository должен быть подключен в data-слое';
const String recipesRepositoryNotConnectedMessage =
    'RecipesRepository должен быть подключен в data-слое';
const String nothingFoundMessage = 'Ничего не найдено';

String fieldPositiveMessage(String fieldName) =>
    '$fieldName должно быть больше 0';

String fieldNonNegativeMessage(String fieldName) =>
    '$fieldName не может быть отрицательным';

String fieldMinCountMessage(String fieldName, int min) =>
    '$fieldName должно быть не меньше $min';

String fieldRequiredMessage(String fieldName) => '$fieldName обязательно';

String photoFileNotFoundMessage(String path) => 'Файл фото не найден: $path';

String photoSlotNotSelectedMessage(int slot) => 'Не выбрано фото $slot';

String photoSlotFileNotFoundMessage(int slot) => 'Файл фото $slot не найден';

String operationFailedMessage(String operationName) =>
    'Не удалось выполнить $operationName. Проверьте интернет и повторите попытку.';

String errorWithTitle(String title, Object? error) {
  return '$title: ${russianErrorMessage(error)}';
}

String otpErrorMessage(Object error) {
  if (isNetworkError(error)) return noInternetMessage;
  return otpInvalidMessage;
}

String resendOtpErrorMessage(Object error) {
  final text = error.toString().toLowerCase();
  final isRateLimited = text.contains('rate limit') ||
      text.contains('60 seconds') ||
      text.contains('wait') ||
      text.contains('too many requests');

  if (isRateLimited) return otpResendRateLimitedMessage;
  if (isNetworkError(error)) return noInternetMessage;
  return otpResendFailedMessage;
}

String bodyFatValidationMessageFromError(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('талия должна быть больше шеи')) {
    return maleWaistGreaterThanNeckMessage;
  }
  if (text.contains('сумма талии и бедер должна быть больше шеи')) {
    return femaleWaistHipsGreaterThanNeckMessage;
  }
  if (text.contains('% жира должен быть больше 0')) {
    return bodyFatInvalidMessage;
  }
  return bodyFatInvalidFallbackMessage;
}

String russianErrorMessage(
  Object? error, {
  String fallback = genericErrorMessage,
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (isNetworkErrorText(lower)) return noInternetMessage;

  if (isInvalidLoginCredentialsText(lower) ||
      lower.contains('email not confirmed')) {
    return invalidCurrentPasswordMessage;
  }

  if (lower.contains('same password') ||
      lower.contains('different password') ||
      lower.contains('new password should be different')) {
    return samePasswordMessage;
  }

  if (isPasswordStandardsErrorText(lower)) {
    return newPasswordRequirementsMessage;
  }

  return messageWithoutExceptionPrefix(rawText) ?? fallback;
}

String russianLoginErrorMessage(
  Object? error, {
  String fallback = loginFailedMessage,
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (isNetworkErrorText(lower)) return noInternetMessage;

  if (isInvalidLoginCredentialsText(lower) || isUserNotFoundText(lower)) {
    return loginCredentialsNotFoundMessage;
  }

  if (lower.contains('email not confirmed') ||
      lower.contains('email_not_confirmed') ||
      lower.contains('confirm your email') ||
      lower.contains('подтверд')) {
    return emailNotConfirmedMessage;
  }

  return messageWithoutExceptionPrefix(rawText) ?? fallback;
}

String russianRegisterErrorMessage(
  Object? error, {
  String fallback = registerFailedMessage,
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (isNetworkErrorText(lower)) return noInternetMessage;
  if (isPasswordStandardsErrorText(lower)) {
    return registerPasswordRequirementsMessage;
  }

  if (lower.contains('user already registered') ||
      lower.contains('already registered') ||
      lower.contains('already exists') ||
      lower.contains('email address is already registered')) {
    return emailAlreadyRegisteredMessage;
  }

  if (lower.contains('invalid email')) return invalidEmailMessage;

  return messageWithoutExceptionPrefix(rawText) ?? fallback;
}

void ensurePositive(double value, String fieldName) {
  if (value <= 0) throw ValidationException(fieldPositiveMessage(fieldName));
}

void ensureNonNegative(double value, String fieldName) {
  if (value < 0) throw ValidationException(fieldNonNegativeMessage(fieldName));
}

void ensureMinCount(int value, int min, String fieldName) {
  if (value < min) {
    throw ValidationException(fieldMinCountMessage(fieldName, min));
  }
}

void ensureNotEmpty(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw ValidationException(fieldRequiredMessage(fieldName));
  }
}

String? messageWithoutExceptionPrefix(String rawText) {
  const prefixes = ['Exception: ', 'ValidationException: '];
  for (final prefix in prefixes) {
    if (rawText.startsWith(prefix)) {
      final message = rawText.substring(prefix.length).trim();
      if (message.isNotEmpty) return message;
    }
  }
  return null;
}

bool isNetworkError(Object? error) {
  if (error == null) return false;
  return isNetworkErrorText(error.toString().toLowerCase());
}

bool isInvalidLoginCredentialsError(Object? error) {
  if (error == null) return false;
  return isInvalidLoginCredentialsText(error.toString().toLowerCase());
}

bool isUserNotFoundError(Object? error) {
  if (error == null) return false;
  return isUserNotFoundText(error.toString().toLowerCase());
}

bool isNetworkErrorText(String lower) {
  return lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset') ||
      lower.contains('connection closed') ||
      lower.contains('connection terminated') ||
      lower.contains('handshakeexception') ||
      lower.contains('authretryablefetchexception') ||
      lower.contains('clientexception') ||
      lower.contains('failed to fetch') ||
      lower.contains('xmlhttprequest error') ||
      lower.contains('temporarily unavailable') ||
      lower.contains('timed out') ||
      lower.contains('timeoutexception') ||
      lower.contains('network request failed') ||
      lower.contains('no address associated with hostname');
}

bool isInvalidLoginCredentialsText(String lower) {
  return lower.contains('invalid login credentials') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid email or password') ||
      lower.contains('invalid password') ||
      lower.contains('wrong password');
}

bool isUserNotFoundText(String lower) {
  return lower.contains('user not found') ||
      lower.contains('email not found') ||
      lower.contains('no user found') ||
      lower.contains('account not found') ||
      lower.contains('user does not exist');
}

bool isPasswordStandardsErrorText(String lower) {
  return lower.contains('password should be') ||
      lower.contains('password must') ||
      lower.contains('password is too short') ||
      lower.contains('weak password') ||
      lower.contains('password not') ||
      lower.contains('password requirements') ||
      lower.contains('password_strength') ||
      lower.contains('at least 6 characters') ||
      lower.contains('minimum 6 characters') ||
      lower.contains('minimum password length');
}
