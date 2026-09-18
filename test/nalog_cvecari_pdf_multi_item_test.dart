import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/pdf/nalog_cvecari_pdf_export.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keeps each Cvećari item tuple and source order for 1/2/3/10 items', () async {
    for (final count in <int>[1, 2, 3, 10]) {
      final prepared = NalogCvecariPdfPreparedData(
        fullName: 'Test PREDMET',
        godinaRodjenja: '1970',
        vrstaCeremonije: 'KREMACIJA',
        mestoCeremonije: 'Novo groblje',
        datumCeremonije: '31.08.2026.',
        vremeCeremonije: '09:00',
        flowers: List.generate(
          count,
          (index) => NalogCvecariPdfFlower(
            articleName: 'CVEĆE ${index + 1}',
            ribbonText: index.isEven ? 'TRAKA ${index + 1}' : '',
            imageBytes: _imageBytes(index),
          ),
          growable: false,
        ),
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
      expect(prepared.flowers, hasLength(count));
      for (var index = 0; index < count; index++) {
        expect(prepared.flowers[index].articleName, 'CVEĆE ${index + 1}');
        expect(prepared.flowers[index].imageBytes, isNotNull);
      }
    }
  });
}

Uint8List _imageBytes(int index) {
  final image = img.Image(width: 40, height: 30);
  img.fill(image, color: img.ColorRgb8(120 + index % 100, 150, 130));
  return Uint8List.fromList(img.encodePng(image));
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
