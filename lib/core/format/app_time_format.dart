String? _normalizeTimeValue(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final normalizedSeparators = trimmed.replaceAll('.', ':');
  final parts = normalizedSeparators.split(':');
  if (parts.length != 2) return null;

  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  if (hours == null || minutes == null) return null;
  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;

  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

String normalizeTimeInput(String input) => _normalizeTimeValue(input) ?? '';

String formatTimeUi(String input) {
  final normalized = normalizeTimeInput(input);
  if (normalized.isEmpty) return '';
  return normalized;
}

String formatTimeForSentence(String input) => formatTimeUi(input);

String offsetNormalizedTime(String input, int minutesOffset) {
  final normalized = normalizeTimeInput(input);
  if (normalized.isEmpty) return '';

  final parts = normalized.split(':');
  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);
  if (hours == null || minutes == null) return '';

  const minutesPerDay = 24 * 60;
  final totalMinutes =
      (hours * 60 + minutes + minutesOffset) % minutesPerDay;
  final normalizedMinutes =
      totalMinutes < 0 ? totalMinutes + minutesPerDay : totalMinutes;

  final nextHours = normalizedMinutes ~/ 60;
  final nextMinutes = normalizedMinutes % 60;
  return '${nextHours.toString().padLeft(2, '0')}:${nextMinutes.toString().padLeft(2, '0')}';
}

String subtract30Minutes(String input) => offsetNormalizedTime(input, -30);

String subtract60Minutes(String input) => offsetNormalizedTime(input, -60);

String addMinutes(String input, int minutesOffset) =>
    offsetNormalizedTime(input, minutesOffset);
