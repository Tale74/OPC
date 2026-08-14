import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';

void main() {
  test(
    'real JOVIC ZIVKO forensic copy follows shared repository ordering',
    skip: Platform.environment['OPC_IRIU_FORENSIC_COPY'] == null
        ? 'Set OPC_IRIU_FORENSIC_COPY to an isolated copy of the canonical DB.'
        : null,
    () async {
      final file = File(Platform.environment['OPC_IRIU_FORENSIC_COPY']!);
      expect(file.existsSync(), isTrue);
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final rows = await IriuRepository(db).getIriu(113);

      expect(rows.map((row) => row.id), <int>[
        1724,
        1721,
        1732,
        1733,
        1720,
        1715,
        1717,
        1716,
        1718,
        1714,
        1723,
        1731,
        1727,
        1729,
        1726,
        1730,
        1728,
        1725,
      ]);
      expect(rows.map((row) => row.nazivPrikaz), <String>[
        'Agencijske usluge',
        'ČITULJA POLITIKA I/90 mm — Cela zemlja',
        'Crnina',
        'Ešarpa',
        'Cveće SUZA SU 1/1',
        'SVETOSAVSKI KRST Topola/Hrast',
        'Peškir za krst',
        'Pokrov garnitura BORDO',
        'Posmrtne parte',
        'Sanduk V-4',
        'Slika',
        'Transportna vreća',
        'Iznošenje',
        'Prevoz do hladnjače',
        'Hladnjača',
        'Spremanje pokojnika',
        'Prevoz do groblja',
        'Komplet 80',
      ]);
    },
  );
}
