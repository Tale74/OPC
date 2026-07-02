String buildCeremonyReminderText({
  required String ceremonyType,
  required String deceasedFirstName,
  required String deceasedLastName,
  required String ceremonyDate,
  required String ceremonyTime,
}) {
  final fullName = '$deceasedFirstName $deceasedLastName'.trim();
  return 'CEREMONIJA (${ceremonyType.trim()}) ZA ($fullName) JE '
      '(${ceremonyDate.trim()}) U (${ceremonyTime.trim()}). '
      'DOVRŠITE NEOPHODNE PRIPREME.';
}
