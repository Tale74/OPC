class BusinessScenarioId {
  const BusinessScenarioId._(
    this.value, {
    required this.displayName,
    this.description,
  });

  static const BusinessScenarioId defaultFuneralCeremonyPolicy =
      BusinessScenarioId._(
    'default_funeral_ceremony_policy',
    displayName: 'Default funeral ceremony policy',
    description:
        'Current global default business policy for the predmet flow.',
  );

  final String value;
  final String displayName;
  final String? description;

  static const List<BusinessScenarioId> values = <BusinessScenarioId>[
    defaultFuneralCeremonyPolicy,
  ];

  static BusinessScenarioId fromValue(String value) {
    return values.firstWhere(
      (scenario) => scenario.value == value,
      orElse: () => defaultFuneralCeremonyPolicy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessScenarioId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
