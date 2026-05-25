class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class AuthRequiredException extends AppException {
  const AuthRequiredException() : super('Пользователь не авторизован');
}

class SyncException extends AppException {
  const SyncException(super.message);
}

const String noInternetMessage =
    'Нет интернет-соединения. Проверьте подключение и повторите попытку.';

const String loginCredentialsNotFoundMessage =
    'Пользователь с такой почтой и паролем не найден.';

const String registerPasswordRequirementsMessage =
    'Пароль не соответствует требованиям. Используйте минимум 6 символов.';

String russianErrorMessage(
  Object? error, {
  String fallback = 'Произошла ошибка. Повторите попытку.',
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (_isNetworkErrorText(lower)) return noInternetMessage;

  if (lower.contains('invalid login credentials') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid email or password') ||
      lower.contains('email not confirmed')) {
    return 'Неверный текущий пароль.';
  }

  if (lower.contains('same password') ||
      lower.contains('different password') ||
      lower.contains('new password should be different')) {
    return 'Новый пароль должен отличаться от старого.';
  }

  if (_isPasswordStandardsErrorText(lower)) {
    return 'Новый пароль не соответствует требованиям. Используйте минимум 6 символов.';
  }

  return _messageWithoutExceptionPrefix(rawText) ?? fallback;
}

String russianLoginErrorMessage(
  Object? error, {
  String fallback = 'Не удалось выполнить вход. Повторите попытку.',
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (_isNetworkErrorText(lower)) return noInternetMessage;

  if (_isInvalidLoginCredentialsText(lower) || _isUserNotFoundText(lower)) {
    return loginCredentialsNotFoundMessage;
  }

  if (lower.contains('email not confirmed') ||
      lower.contains('email_not_confirmed') ||
      lower.contains('confirm your email') ||
      lower.contains('подтверд')) {
    return 'Почта не подтверждена. Введите код из письма.';
  }

  return _messageWithoutExceptionPrefix(rawText) ?? fallback;
}

String russianRegisterErrorMessage(
  Object? error, {
  String fallback = 'Не удалось выполнить регистрацию. Повторите попытку.',
}) {
  if (error == null) return fallback;
  if (error is AppException) return error.message;

  final rawText = error.toString().trim();
  final lower = rawText.toLowerCase();

  if (_isNetworkErrorText(lower)) return noInternetMessage;
  if (_isPasswordStandardsErrorText(lower)) {
    return registerPasswordRequirementsMessage;
  }

  if (lower.contains('user already registered') ||
      lower.contains('already registered') ||
      lower.contains('already exists') ||
      lower.contains('email address is already registered')) {
    return 'Аккаунт с такой почтой уже существует.';
  }

  if (lower.contains('invalid email')) return 'Введите корректную почту.';

  return _messageWithoutExceptionPrefix(rawText) ?? fallback;
}

bool isNetworkError(Object? error) {
  if (error == null) return false;
  return _isNetworkErrorText(error.toString().toLowerCase());
}

void ensurePositive(double value, String fieldName) {
  if (value <= 0) throw ValidationException('$fieldName должно быть больше 0');
}

void ensureNonNegative(double value, String fieldName) {
  if (value < 0) throw ValidationException('$fieldName не может быть отрицательным');
}

void ensureMinCount(int value, int min, String fieldName) {
  if (value < min) throw ValidationException('$fieldName должно быть не меньше $min');
}

void ensureNotEmpty(String value, String fieldName) {
  if (value.trim().isEmpty) throw ValidationException('$fieldName обязательно');
}

String? _messageWithoutExceptionPrefix(String rawText) {
  const prefixes = ['Exception: ', 'ValidationException: '];
  for (final prefix in prefixes) {
    if (rawText.startsWith(prefix)) {
      final message = rawText.substring(prefix.length).trim();
      if (message.isNotEmpty) return message;
    }
  }
  return null;
}

bool _isNetworkErrorText(String lower) {
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

bool _isInvalidLoginCredentialsText(String lower) {
  return lower.contains('invalid login credentials') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid email or password') ||
      lower.contains('invalid password') ||
      lower.contains('wrong password');
}

bool _isUserNotFoundText(String lower) {
  return lower.contains('user not found') ||
      lower.contains('email not found') ||
      lower.contains('no user found') ||
      lower.contains('account not found') ||
      lower.contains('user does not exist');
}

bool _isPasswordStandardsErrorText(String lower) {
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
