import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';

void main() {
  test(
    'citation catalog seed is idempotent across database reopen',
    timeout: Timeout.none,
    () async {
      final directory = await Directory.systemTemp.createTemp('opc-seed-');
      final file = File(
        '${directory.path}${Platform.pathSeparator}seed.sqlite',
      );
      try {
        final first = AppDatabase.forTesting(NativeDatabase(file));
        final firstCount =
            await (first.select(first.katalogArtikli)..where(
                  (row) => row.interniNazivKategorije.isIn([
                    'CITULJA_POLITIKA',
                    'CITULJA_NOVOSTI',
                  ]),
                ))
                .get();
        await first.close();

        final second = AppDatabase.forTesting(NativeDatabase(file));
        final secondCount =
            await (second.select(second.katalogArtikli)..where(
                  (row) => row.interniNazivKategorije.isIn([
                    'CITULJA_POLITIKA',
                    'CITULJA_NOVOSTI',
                  ]),
                ))
                .get();
        await second.close();

        expect(secondCount.length, firstCount.length);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
