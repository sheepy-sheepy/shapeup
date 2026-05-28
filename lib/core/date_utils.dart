import 'app_errors.dart';

String dayKeyFromDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final _ruDatePattern = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$');

bool hasRuDateFormat(String value) {
  return _ruDatePattern.firstMatch(value.trim()) != null;
}

DateTime? tryParseRuDate(String value) {
  final trimmed = value.trim();

  final match = _ruDatePattern.firstMatch(trimmed);
  if (match == null) return null;

  final day = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final year = int.tryParse(match.group(3)!);

  if (day == null || month == null || year == null) return null;

  final parsed = DateTime(year, month, day);

  if (parsed.day != day || parsed.month != month || parsed.year != year) {
    return null;
  }

  return parsed;
}

DateTime parseRuDate(String value) {
  final parsed = tryParseRuDate(value);
  if (parsed == null) {
    throw FormatException(invalidDateFormatTechnicalMessage, value);
  }
  return parsed;
}

String toRuDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
