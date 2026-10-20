import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/citulje/data/citulje_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/citulje/domain/citulje_models.dart';
import 'package:opc_v4/features/predmeti/citulje/pdf/citulja_pdf_export.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('POLITIKA and NOVOSTI use the canonical ČITULJA labels', () {
    expect(cituljaArticleDisplayValue('CITULJA_POLITIKA'), 'ČITULJA POLITIKA');
    expect(cituljaArticleDisplayValue('CITULJA_NOVOSTI'), 'ČITULJA NOVOSTI');
  });

  test('singleton ČITULJA filenames use the PREDMET identity and type', () async {
    final predmet = await _insertPredmet(
      prezime: 'PREZIME',
      ime: 'IME',
      brojPredmeta: '123',
    );
    final politika = _preparation(
      occurrence: 'politika-1',
      articleType: 'CITULJA_POLITIKA',
      predmetId: predmet.id,
    );
    final novosti = _preparation(
      occurrence: 'novosti-1',
      articleType: 'CITULJA_NOVOSTI',
      predmetId: predmet.id,
    );

    expect(
      cituljaPdfFilename(
        predmet,
        politika,
        currentSameTypeOccurrenceIds: const ['politika-1'],
      ),
      'PREZIME_IME_123_CITULJA_POLITIKA.pdf',
    );
    expect(
      cituljaPdfFilename(
        predmet,
        novosti,
        currentSameTypeOccurrenceIds: const ['novosti-1'],
      ),
      'PREZIME_IME_123_CITULJA_NOVOSTI.pdf',
    );
  });

  test('multiple same-type occurrences use sorted output-only suffixes', () {
    final predmet = _predmetData();
    final first = _preparation(
      occurrence: 'z-occurrence',
      articleType: 'CITULJA_POLITIKA',
    );
    final second = _preparation(
      occurrence: 'a-occurrence',
      articleType: 'CITULJA_POLITIKA',
    );

    const currentIds = ['z-occurrence', 'a-occurrence'];
    final firstFilename = cituljaPdfFilename(
      predmet,
      first,
      currentSameTypeOccurrenceIds: currentIds,
    );
    final secondFilename = cituljaPdfFilename(
      predmet,
      second,
      currentSameTypeOccurrenceIds: currentIds,
    );

    expect(firstFilename, 'PREZIME_IME_123_CITULJA_POLITIKA_B.pdf');
    expect(secondFilename, 'PREZIME_IME_123_CITULJA_POLITIKA_A.pdf');
    expect(firstFilename, isNot(contains('z-occurrence')));
    expect(secondFilename, isNot(contains('a-occurrence')));
  });

  test('PDF prepared data contains only the persisted contract fields', () {
    final row = _preparation(
      occurrence: 'news-1',
      articleType: 'CITULJA_NOVOSTI',
      publicationDate: '2026-09-06',
      publicationText: 'Prva rečenica.\nDruga rečenica.',
    );

    final prepared = prepareCituljaPdfData(row);

    expect(prepared.articleLabel, 'ČITULJA NOVOSTI');
    expect(prepared.publicationDate, '06.09.2026');
    expect(prepared.publicationText, row.publicationText);
    expect(prepared.toString(), isNot(contains('Broj predmeta')));
    expect(prepared.toString(), isNot(contains('portableOccurrenceId')));
  });

  test(
    'long publication text builds a valid wrapping PDF without extra source data',
    () async {
      final text = List<String>.filled(
        900,
        'Ovo je dugačka rečenica publikacije koja mora ostati potpuna.',
      ).join(' ');
    final prepared = CituljaPdfPreparedData(
        articleLabel: 'ČITULJA POLITIKA',
        publicationDate: '06.09.2026',
        publicationText: text,
      );

    final bytes = await buildCituljaPdf(prepared);

    expect(bytes.take(4).toList(), orderedEquals(<int>[37, 80, 68, 70]));
      expect(bytes.length, greaterThan(5000));
      expect(prepared.articleLabel, isNot(contains('PREDMET')));
      expect(prepared.publicationText, text);
    },
  );

  test(
    'PDF preparation reads current persisted values, not a UI draft',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(brojPredmeta: const Value('R4-001')),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: 'CITULJA_POLITIKA',
              portableOccurrenceId: const Value('persisted-1'),
            ),
          );
      final repository = CituljePreparationRepository(db);
      final row = (await repository.ensureCurrentForPredmet(predmetId)).single;
      await repository.configure(
        preparationId: row.id,
        mode: CituljeParteTextMode.ne,
        publicationDate: '2026-09-06',
        publicationText: 'Sačuvani tekst A',
      );

      final persisted = await repository.findByOccurrence(
        predmetId: predmetId,
        portableOccurrenceId: 'persisted-1',
      );
      final prepared = prepareCituljaPdfData(persisted!);

      expect(prepared.publicationText, 'Sačuvani tekst A');
      expect(prepared.publicationText, isNot('Nesnimljeni tekst B'));
    },
  );

  test('PDF format uses the current concrete KATALOG article name', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(PredmetiCompanion.insert(brojPredmeta: const Value('CIT-PDF')));
    await db.into(db.iriu).insert(
      IriuCompanion.insert(
        predmetId: predmetId,
        interniNaziv: 'CITULJA_NOVOSTI',
        nazivPrikaz: const Value('Posebna novinska forma'),
        katalogStableArticleId: const Value('CIT-N-001'),
        portableOccurrenceId: const Value('citulja-concrete-pdf-1'),
      ),
    );
    final repository = CituljePreparationRepository(db);
    final preparation =
        (await repository.ensureCurrentForPredmet(predmetId)).single;
    final currentIriu = await repository.findCurrentIriuForPreparation(
      preparation,
    );

    final prepared = prepareCituljaPdfData(
      preparation,
      currentIriu: currentIriu,
    );

    expect(prepared.articleLabel, 'Posebna novinska forma');
  });
}

PredmetiData _predmetData() {
  return const PredmetiData(
    id: 1,
    brojPredmeta: '123',
    status: 'OTVOREN',
    datumKreiranja: '',
    savetnikId: null,
    businessResponsibleName: null,
    businessResponsibleRole: null,
    verzija: 1,
    businessScenarioId: 'DEFAULT',
    sourceIdentity: 'test',
    createdByKorisnikId: null,
    lastBusinessModifiedByKorisnikId: null,
    lastBusinessModifiedAt: null,
    ime: 'IME',
    prezime: 'PREZIME',
    srednje: '',
    devojackoPrezime: '',
    jmbg: '',
    pol: '',
    datumRodjenja: '',
    mestoRodjenja: '',
    datumSmrti: '',
    mestoSmrti: '',
    uzrokSmrti: '',
    adresa: '',
    imeOca: '',
    imeMajke: '',
    bracnoStanje: '',
    bracniDrugIme: '',
    bracniDrugPrezime: '',
    bracniDrugPol: '',
    bracniDrugJmbg: '',
    bracniDrugDevojacko: '',
    zanimanje: '',
    zanimanjeNaParti: false,
    titula: '',
    titulaIspred: false,
    cin: '',
    cinNaParti: false,
    srednjeNaParti: false,
    nadimak: '',
    nadimakNaParti: false,
    nadimakCrtica: false,
    radniStatus: '',
    penzioner: '',
    penzionerSrbije: '',
    vojniPenzioner: '',
    vojnePocasti: '',
    posmrtnaPomoc: '',
    refundacijaPio: 0,
    narucilacRefundira: '',
    bracniDrugOstvarujePravo: '',
    bracniDrugJePenzioner: '',
    penzionerNapomena: '',
    naruTip: '',
    naruIme: '',
    naruPrezime: '',
    naruImePrezime: '',
    naruJmbg: '',
    naruAdresa: '',
    naruBrojLk: '',
    naruTelefon1: '',
    naruTelefon2: '',
    naruEmail: '',
    naruPlNaziv: '',
    naruPlAdresa: '',
    naruPlPib: '',
    naruPlMb: '',
    naruPlOdgovornoLice: '',
    naruPlTelefon1: '',
    naruPlTelefon2: '',
    naruPlEmail: '',
    naruIstiZaJkp: false,
    jkpTip: '',
    jkpIme: '',
    jkpPrezime: '',
    jkpImePrezime: '',
    jkpJmbg: '',
    jkpAdresa: '',
    jkpBrojLk: '',
    jkpTelefon1: '',
    jkpTelefon2: '',
    jkpEmail: '',
    jkpPlNaziv: '',
    jkpPlAdresa: '',
    jkpPlPib: '',
    jkpPlMb: '',
    jkpPlOdgovornoLice: '',
    jkpPlTelefon1: '',
    jkpPlEmail: '',
    groblje: '',
    grobljePolaganjaUrne: '',
    tipGroblja: '',
    vrstaCeremonije: '',
    datumCeremonije: '',
    vremeCeremonije: '',
    opelo: '',
    obavestitiSvestenika: '',
    opeloMesto: '',
    vremeOpela: '',
    vremeIspracaja: '',
    grobnoMesto: '',
    tipGrobnogMesta: '',
    parcela: '',
    grobBroj: '',
    redGrob: '',
    npk: '',
    grobnica: '',
    urnaSifra: '',
    tipPolaganja: '',
    urnaParcela: '',
    urnaBroj: '',
    urnaRed: '',
    urnaNpk: '',
    sahranaVanSrbije: false,
    svisZemlja: '',
    svisGrad: '',
    docekPosmrtnihOstataka: false,
    promenaSanduka: false,
    docekMesto: '',
    docekDatum: '',
    docekVreme: '',
    partePotrebna: false,
    simbol: '',
    pismo: '',
    parteIme: '',
    ozaloseni: '',
    avans: 0,
    troskoviJkp: 0,
    jkpPlacaSamostalno: false,
    popust: 0,
    nacinPlacanja: '',
    napomenaPlacanja: '',
    napomena: '',
    exportVerzija: 1,
  );
}

Future<PredmetiData> _insertPredmet({
  required String prezime,
  required String ime,
  required String brojPredmeta,
}) async {
  final db = createTestDatabase();
  addTearDown(db.close);
  final id = await db.into(db.predmeti).insert(
        PredmetiCompanion.insert(
          brojPredmeta: Value(brojPredmeta),
          ime: Value(ime),
          prezime: Value(prezime),
        ),
      );
  return (db.select(db.predmeti)..where((row) => row.id.equals(id))).getSingle();
}

CituljePripremeData _preparation({
  required String occurrence,
  required String articleType,
  int predmetId = 1,
  String publicationDate = '2026-09-06',
  String publicationText = 'Tekst ČITULJE',
}) {
  return CituljePripremeData(
    id: 1,
    predmetId: predmetId,
    portableOccurrenceId: occurrence,
    articleType: articleType,
    parteTextMode: 'NE',
    publicationDate: publicationDate,
    publicationText: publicationText,
    note: '',
    state: 'INDEPENDENT_TEXT',
    parteSnapshotFingerprint: null,
    finalized: false,
    finalizedAt: null,
    createdAt: '2026-09-06T10:00:00.000',
    updatedAt: '2026-09-06T10:00:00.000',
  );
}
