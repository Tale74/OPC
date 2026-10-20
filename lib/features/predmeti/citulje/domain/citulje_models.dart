import '../../parte/domain/parte_composer.dart';
import '../../parte/domain/parte_models.dart';

const String cituljeTransferPolicy = 'predmet_citulje_preparation_v1';
const int cituljeTransferSchemaVersion = 1;

const Set<String> cituljeArticleTypes = {
  'CITULJA_POLITIKA',
  'CITULJA_NOVOSTI',
};

enum CituljeParteTextMode {
  da('DA'),
  ne('NE');

  const CituljeParteTextMode(this.dbValue);
  final String dbValue;

  static CituljeParteTextMode? fromDb(String? value) {
    for (final item in values) {
      if (item.dbValue == value) return item;
    }
    return null;
  }
}

enum CituljePreparationState {
  unconfigured('UNCONFIGURED'),
  waitingForPartePreview('WAITING_FOR_PARTE_PREVIEW'),
  parteSnapshotAvailable('PARTE_SNAPSHOT_AVAILABLE'),
  independentText('INDEPENDENT_TEXT');

  const CituljePreparationState(this.dbValue);
  final String dbValue;

  static CituljePreparationState fromDb(String value) => values.firstWhere(
    (item) => item.dbValue == value,
    orElse: () => unconfigured,
  );
}

/// The confirmed textual source copied from the PARTE render plan.
class ParteConfirmedPlainText {
  const ParteConfirmedPlainText({
    required this.text,
    required this.sourceFingerprint,
  });

  final String text;
  final String sourceFingerprint;
}

/// The portable ČITULJE business payload. It deliberately excludes local
/// database ids and local PARTE preparation ids.
class CituljePreparationTransfer {
  const CituljePreparationTransfer({
    required this.portableOccurrenceId,
    required this.articleType,
    required this.parteTextMode,
    required this.publicationDate,
    required this.publicationText,
    required this.note,
    required this.state,
    required this.finalized,
    required this.finalizedAt,
    required this.parteSnapshotFingerprint,
  });

  factory CituljePreparationTransfer.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != cituljeTransferSchemaVersion ||
        json['policy'] != cituljeTransferPolicy) {
      throw const FormatException('ČITULJE transfer schema nije podržana.');
    }
    final occurrence = _requiredText(json, 'portableOccurrenceId');
    final articleType = _requiredText(json, 'articleType');
    if (!cituljeArticleTypes.contains(articleType)) {
      throw const FormatException('Nepoznata ČITULJA kategorija.');
    }
    final rawMode = json['parteTextMode'];
    final mode = rawMode == null
        ? null
        : CituljeParteTextMode.fromDb(rawMode.toString());
    if (rawMode != null && mode == null) {
      throw const FormatException('Nepoznat PARTE TEKST režim.');
    }
    final rawState = _requiredText(json, 'state');
    final state = CituljePreparationState.values.firstWhere(
      (item) => item.dbValue == rawState,
      orElse: () => throw const FormatException('Nepoznato ČITULJE stanje.'),
    );
    final text = _optionalText(json, 'publicationText');
    final fingerprint = _optionalTextOrNull(json, 'parteSnapshotFingerprint');
    if (state == CituljePreparationState.waitingForPartePreview &&
        mode != CituljeParteTextMode.da) {
      throw const FormatException('ČITULJE čekanje zahteva PARTE TEKST=DA.');
    }
    if (state == CituljePreparationState.parteSnapshotAvailable &&
        (mode != CituljeParteTextMode.da ||
            text.trim().isEmpty ||
            fingerprint == null)) {
      throw const FormatException('ČITULJE snapshot nije potpun.');
    }
    if (state == CituljePreparationState.independentText &&
        mode != CituljeParteTextMode.ne) {
      throw const FormatException('Nezavisni tekst zahteva PARTE TEKST=NE.');
    }
    return CituljePreparationTransfer(
      portableOccurrenceId: occurrence,
      articleType: articleType,
      parteTextMode: mode,
      publicationDate: _optionalTextOrNull(json, 'publicationDate'),
      publicationText: text,
      note: _optionalText(json, 'note'),
      state: state,
      finalized: json['finalized'] == true,
      finalizedAt: _optionalTextOrNull(json, 'finalizedAt'),
      parteSnapshotFingerprint: fingerprint,
    );
  }

  final String portableOccurrenceId;
  final String articleType;
  final CituljeParteTextMode? parteTextMode;
  final String? publicationDate;
  final String publicationText;
  final String note;
  final CituljePreparationState state;
  final bool finalized;
  final String? finalizedAt;
  final String? parteSnapshotFingerprint;

  Map<String, dynamic> toJson() => {
    'schemaVersion': cituljeTransferSchemaVersion,
    'policy': cituljeTransferPolicy,
    'portableOccurrenceId': portableOccurrenceId,
    'articleType': articleType,
    'parteTextMode': parteTextMode?.dbValue,
    'publicationDate': publicationDate,
    'publicationText': publicationText,
    'note': note,
    'state': state.dbValue,
    'finalized': finalized,
    'finalizedAt': finalizedAt,
    'parteSnapshotFingerprint': parteSnapshotFingerprint,
  };
}

String cituljeConfirmedPlainTextFromPlan(Iterable<ParteRenderBlock> blocks) {
  final lines = <String>[];
  for (final block in blocks) {
    if (block.kind != ParteBlockKind.text ||
        block.visible != true ||
        block.exportEligible != true) {
      continue;
    }
    final text = block.resolvedText.toString().trim();
    if (text.isNotEmpty) lines.add(text);
  }
  return lines.join('\n');
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim();
  if (value == null || value.isEmpty) {
    throw FormatException('ČITULJE polje $key je prazno.');
  }
  return value;
}

String _optionalText(Map<String, dynamic> json, String key) =>
    json[key]?.toString() ?? '';

String? _optionalTextOrNull(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}
