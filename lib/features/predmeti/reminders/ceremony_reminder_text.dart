String buildCeremonyReminderText({
  required String ceremonyType,
  required String deceasedFirstName,
  required String deceasedLastName,
  required String ceremonyDate,
  required String ceremonyTime,
  String? ceremonyLocation,
}) {
  final fullName = '$deceasedFirstName $deceasedLastName'.trim();
  final location = ceremonyLocation == null
      ? ''
      : (ceremonyLocation.trim().isEmpty
          ? 'Groblje nije uneto'
          : ceremonyLocation.trim());
  final locationSuffix = location.isEmpty ? '' : ' NA GROBLJU $location';
  return '${ceremonyType.trim()} ZA $fullName JE '
      '${ceremonyDate.trim()} U ${ceremonyTime.trim()}$locationSuffix. '
      'DOVRŠITE NEOPHODNE PRIPREME.';
}
