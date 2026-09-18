import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/pdf/nalog_cvecari_pdf_export.dart';
import 'package:opc_v4/features/predmeti/pdf/opc_pdf_shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NALOG CVEĆARI PDF contract', () {
    test('uses presentation grammar for current ceremony branches', () {
      expect(nalogCvecariCeremonyHeading('SAHRANA'), 'PODACI O SAHRANI');
      expect(nalogCvecariCeremonyHeading('KREMACIJA'), 'PODACI O KREMACIJI');
      expect(nalogCvecariCeremonyHeading('SMESTAJ_URNE'), 'PODACI O SMEŠTAJU URNE');
      expect(nalogCvecariCeremonyHeading('RASIPANJE_PEPELA'), 'PODACI O RASIPANJU PEPELA');
    });

    test('uses the shared PDF typography and neutral pastel labels', () async {
      final theme = await loadOpcPdfTheme();
      expect(theme, isA<pw.ThemeData>());
      expect(opcPdfBodyFontSize, 9.0);
      expect(opcPdfDocumentTitleFontSize, 11.0);
      expect(opcPdfSectionLabelFontSize, 10.0);
      expect(opcPdfPastelSectionBackgroundHex, '#E7EFE5');
      expect(opcPdfPastelSectionBorderHex, '#B4C5B2');
      expect(nalogCvecariRibbonValueForPdf('  '), isEmpty);
    });

    test('renders the bounded content contract without quantity prefix', () async {
      const prepared = NalogCvecariPdfPreparedData(
        fullName: 'Ana Jovanović',
        godinaRodjenja: '1970',
        vrstaCeremonije: 'KREMACIJA',
        mestoCeremonije: 'Novo groblje',
        datumCeremonije: '31.08.2026.',
        vremeCeremonije: '09:00',
        flowers: [NalogCvecariPdfFlower(articleName: 'Ruže', ribbonText: 'Počivaj u miru')],
      );
      final bytes = await buildNalogCvecariPdfBytes(
        firma: _firma,
        app: _app,
        savetnikIme: 'Savetnik',
        status: 'OTVOREN',
        dokumentVerzija: 'v1',
        prepared: prepared,
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(nalogCvecariRibbonValueForPdf(prepared.flowers.single.ribbonText),
          isNot(contains('TEKST TRAKE')));
    });
  });
}

const _firma = FirmaPodaciData(
  id: 1,
  naziv: 'OPC',
  adresa: 'Ulica 1',
  pib: '100',
  mb: '200',
  sifraDelatnosti: '',
  telefon: '',
  odgovornoLice: '',
  email: '',
  sajt: '',
  parteDefaultTemplateId: '',
);

const _app = AppPodesavanjaData(
  id: 1,
  ziroRacun: '',
  nazivBanke: '',
  qrPrimalacNaziv: '',
  qrSifraPlacanja: '',
  qrSvrhaPlacanja: '',
  pozivNaBrojTip: '',
  refundacijaPioIznos: 0,
  stanjeRobeOperativnoOmoguceno: false,
);
