String dayKeyFromDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime parseRuDate(String value) {
  final parts = value.split('.');
  return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}

String toRuDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
