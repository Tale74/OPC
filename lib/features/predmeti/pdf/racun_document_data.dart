import '../../../core/database/database.dart';
import '../../../core/utils/export_utils.dart';
import '../data/iriu_repository.dart';
import 'lista_pdf_data_builder.dart';

const racunArticle33Sentence =
    'Poreski obveznik nije u sistemu PDV-a na osnovu člana 33. '
    'Zakona o porezu na dodatu vrednost.';

final class RacunDocumentLabels {
  const RacunDocumentLabels();

  String get documentTitle => 'RAČUN';
  String get filenameToken => 'RACUN';
  String get issueDate => 'Datum izdavanja:';
  String get patientSection => 'PREMINULO LICE';
  String get payerSection => 'PLATILAC';
  String get itemsSection => 'IRIU: IZABRANA ROBA I USLUGE';
  String get itemName => 'NAZIV';
  String get itemQuantity => 'KOM';
  String get itemAmount => 'IZNOS';
  String get emptyItems => 'Nema poslovno relevantnih IRIU stavki za prikaz.';
  String get emptyPayer => 'Nema evidentiranih podataka.';
  String get article33 => racunArticle33Sentence;
  String get signature => 'Potpis';
  String get stamp => 'MP';
  String get advisor => 'Savetnik';
  String get status => 'Status';
  String get caseVersion => 'Verzija predmeta';
}

/// One source-derived semantic snapshot consumed by both RAČUN output adapters.
/// It carries no business authority of its own; PREDMET/FIRMA/IRiU and the
/// current OWNER rule remain authoritative.
final class RacunDocumentData {
  RacunDocumentData._({
    required this.predmet,
    required this.firma,
    required this.app,
    required this.caseNumber,
    required this.issueDate,
    required this.advisorName,
    required this.statusValue,
    required this.documentVersion,
    required this.deceasedName,
    required this.payerTitle,
    required this.payerDetails,
    required this.items,
    required this.financialRows,
    required this.labels,
  });

  final PredmetiData predmet;
  final FirmaPodaciData firma;
  final AppPodesavanjaData app;
  final String caseNumber;
  final DateTime issueDate;
  final String advisorName;
  final String statusValue;
  final String documentVersion;
  final String deceasedName;
  final String payerTitle;
  final List<ListaPdfLabelValue> payerDetails;
  final List<ListaPdfIriuRenderItem> items;
  final List<ListaPdfLabelValue> financialRows;
  final RacunDocumentLabels labels;

  String get title => labels.documentTitle;

  String get headerTitle => caseNumber.isNotEmpty
      ? '${labels.documentTitle} BR: $caseNumber'
      : labels.documentTitle;

  String get deceasedHeading =>
      '${labels.patientSection}: ${deceasedName.toUpperCase()}';

  String get payerHeading =>
      '${labels.payerSection}: ${payerTitle.toUpperCase()}';

  String get advisorFooter => '${labels.advisor}: ${advisorName.trim()}';

  String get statusFooter =>
      '${labels.status}: $statusValue · ${labels.caseVersion}: $documentVersion';

  String filenameFor(String extension) => koriceDokumentDerivatFajlNaziv(
    predmet,
    labels.filenameToken,
    extension,
    includePredmetVersion: true,
  );

  static Future<RacunDocumentData> load({
    required AppDatabase db,
    required int predmetId,
  }) async {
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.id.equals(predmetId))).getSingle();
    final firma = await (db.select(
      db.firmaPodaci,
    )..where((row) => row.id.equals(1))).getSingle();
    if (!firma.racunOmogucen) {
      throw StateError('RAČUN nije dostupan za ovu FIRMA konfiguraciju.');
    }
    final iriu = await IriuRepository(db).getIriu(predmetId);
    final app = await (db.select(
      db.appPodesavanja,
    )..where((row) => row.id.equals(1))).getSingle();
    final savetnik = predmet.savetnikId == null
        ? null
        : await (db.select(db.korisnici)
                ..where((row) => row.id.equals(predmet.savetnikId!)))
              .getSingleOrNull();

    return RacunDocumentData.fromSource(
      predmet: predmet,
      iriu: iriu,
      firma: firma,
      app: app,
      savetnik: savetnik,
    );
  }

  factory RacunDocumentData.fromSource({
    required PredmetiData predmet,
    required List<IriuData> iriu,
    required FirmaPodaciData firma,
    required AppPodesavanjaData app,
    required KorisniciData? savetnik,
  }) {
    if (!firma.racunOmogucen) {
      throw StateError('RAČUN nije dostupan za ovu FIRMA konfiguraciju.');
    }
    final prepared = const ListaPdfDataBuilder().build(
      predmet: predmet,
      iriuStavke: iriu,
      firma: firma,
      app: app,
      savetnik: savetnik,
      portableSavetnikName: predmet.businessResponsibleName,
    );
    return RacunDocumentData._fromPreparedData(prepared);
  }

  factory RacunDocumentData._fromPreparedData(ListaPdfPreparedData prepared) {
    final predmet = prepared.predmet;
    final deceasedName = _displayName(predmet.ime, predmet.prezime);
    return RacunDocumentData._(
      predmet: predmet,
      firma: prepared.firma,
      app: prepared.app,
      caseNumber: predmet.brojPredmeta.trim(),
      issueDate: prepared.datumIzvoza,
      advisorName: prepared.savetnikIme,
      statusValue: predmet.status,
      documentVersion: prepared.dokumentVerzija,
      deceasedName: deceasedName,
      payerTitle: _resolvePayerTitle(predmet),
      payerDetails: List<ListaPdfLabelValue>.unmodifiable(
        _buildPayerDetails(predmet),
      ),
      items: List<ListaPdfIriuRenderItem>.unmodifiable(prepared.iriuItems),
      financialRows: List<ListaPdfLabelValue>.unmodifiable(
        _buildFinancialRows(prepared.finansijskiRedovi),
      ),
      labels: const RacunDocumentLabels(),
    );
  }
}

String _displayName(String ime, String prezime) {
  final fullName = [
    ime.trim(),
    prezime.trim(),
  ].where((value) => value.isNotEmpty).join(' ');
  return fullName.isEmpty ? '-' : fullName;
}

String _resolvePayerTitle(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') return predmet.naruPlNaziv.trim();
  final fullName = predmet.naruImePrezime.trim();
  if (fullName.isNotEmpty) return fullName;
  return _displayName(predmet.naruIme, predmet.naruPrezime);
}

List<ListaPdfLabelValue> _buildPayerDetails(PredmetiData predmet) {
  if (predmet.naruTip == 'PRAVNO_LICE') {
    return _compactValues([
      ListaPdfLabelValue('Adresa', predmet.naruPlAdresa),
      ListaPdfLabelValue('PIB', predmet.naruPlPib),
      ListaPdfLabelValue('Matični broj', predmet.naruPlMb),
      ListaPdfLabelValue('Odgovorno lice', predmet.naruPlOdgovornoLice),
      ListaPdfLabelValue('Telefon 1', predmet.naruPlTelefon1),
      ListaPdfLabelValue('Telefon 2', predmet.naruPlTelefon2),
      ListaPdfLabelValue('Email', predmet.naruPlEmail),
    ]);
  }

  return _compactValues([
    ListaPdfLabelValue('JMBG', predmet.naruJmbg),
    ListaPdfLabelValue('LK / pasoš', predmet.naruBrojLk),
    ListaPdfLabelValue('Adresa', predmet.naruAdresa),
    ListaPdfLabelValue('Telefon 1', predmet.naruTelefon1),
    ListaPdfLabelValue('Telefon 2', predmet.naruTelefon2),
    ListaPdfLabelValue('Email', predmet.naruEmail),
  ]);
}

List<ListaPdfLabelValue> _compactValues(List<ListaPdfLabelValue> values) =>
    values
        .where((value) => value.value.trim().isNotEmpty)
        .toList(growable: false);

List<ListaPdfLabelValue> _buildFinancialRows(List<ListaPdfLabelValue> rows) =>
    rows
        .map(
          (row) => row.label.trim() == 'ZA NAPLATU'
              ? ListaPdfLabelValue('UKUPNO', row.value, kind: row.kind)
              : row,
        )
        .toList(growable: false);
