const int podsetnikObligationTransferSchemaVersion = 1;
const String podsetnikObligationTransferKey = 'podsetnikObaveze';

class PodsetnikObligationTransferState {
  const PodsetnikObligationTransferState({
    required this.stableRuleId,
    required this.phase,
    required this.kind,
    required this.parentRuleId,
    required this.sourceFingerprint,
    required this.completed,
    required this.completedAt,
  });

  final String stableRuleId;
  final String phase;
  final String kind;
  final String? parentRuleId;
  final String sourceFingerprint;
  final bool completed;
  final String? completedAt;

  factory PodsetnikObligationTransferState.fromJsonMap(
    Map<String, dynamic> map,
  ) {
    final id = _text(map, 'stableRuleId');
    final phase = _text(map, 'phase');
    final kind = _text(map, 'kind');
    final fingerprint = _text(map, 'sourceFingerprint');
    final completed = map['completed'];
    if (completed is! bool ||
        (map['parentRuleId'] != null && map['parentRuleId'] is! String) ||
        (map['completedAt'] != null && map['completedAt'] is! String)) {
      throw const FormatException('Invalid PODSETNIK obligation transfer row.');
    }
    return PodsetnikObligationTransferState(
      stableRuleId: id,
      phase: phase,
      kind: kind,
      parentRuleId: map['parentRuleId'] as String?,
      sourceFingerprint: fingerprint,
      completed: completed,
      completedAt: map['completedAt'] as String?,
    );
  }

  Map<String, dynamic> toJsonMap() => <String, dynamic>{
    'stableRuleId': stableRuleId,
    'phase': phase,
    'kind': kind,
    if (parentRuleId != null) 'parentRuleId': parentRuleId,
    'sourceFingerprint': sourceFingerprint,
    'completed': completed,
    if (completedAt != null) 'completedAt': completedAt,
  };
}

class PodsetnikObligationTransferBlock {
  const PodsetnikObligationTransferBlock({required this.items});

  final List<PodsetnikObligationTransferState> items;

  factory PodsetnikObligationTransferBlock.fromJsonMap(
    Map<String, dynamic> map,
  ) {
    if (map['schemaVersion'] != podsetnikObligationTransferSchemaVersion ||
        map['policy'] != 'predmet_owned_completion_v1' ||
        map['items'] is! List) {
      throw const FormatException(
        'Unsupported PODSETNIK obligation transfer block.',
      );
    }
    final items = (map['items'] as List)
        .map((raw) {
          if (raw is! Map) {
            throw const FormatException('Invalid transfer item.');
          }
          return PodsetnikObligationTransferState.fromJsonMap(
            raw.cast<String, dynamic>(),
          );
        })
        .toList(growable: false);
    final ids = <String>{};
    if (items.any((item) => !ids.add(item.stableRuleId))) {
      throw const FormatException('Duplicate PODSETNIK obligation identity.');
    }
    return PodsetnikObligationTransferBlock(items: items);
  }

  Map<String, dynamic> toJsonMap() => <String, dynamic>{
    'schemaVersion': podsetnikObligationTransferSchemaVersion,
    'policy': 'predmet_owned_completion_v1',
    'items': items.map((item) => item.toJsonMap()).toList(growable: false),
  };
}

String _text(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw FormatException('PODSETNIK transfer $key must be non-empty text.');
}
