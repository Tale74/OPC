import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('IRiU/KATALOG picker repository characterization', () {
    test(
      'global lightweight load preserves visible category and article order',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        await _insertCategory(
          db,
          key: 'GATE2_CATEGORY_A',
          label: 'Gate 2 A',
          order: -20,
        );
        await _insertCategory(
          db,
          key: 'GATE2_CATEGORY_B',
          label: 'Gate 2 B',
          order: -10,
        );
        final firstId = await _insertArticle(
          db,
          category: 'GATE2_CATEGORY_A',
          stableId: 'gate2-a-1',
          name: 'A prvi',
          price: 12.5,
          hasPhoto: true,
        );
        final secondId = await _insertArticle(
          db,
          category: 'GATE2_CATEGORY_A',
          stableId: 'gate2-a-2',
          name: 'A drugi',
          price: 18.75,
          hasPhoto: false,
        );
        await _insertArticle(
          db,
          category: 'GATE2_CATEGORY_B',
          stableId: 'gate2-b-1',
          name: 'B prvi',
          price: 27,
          hasPhoto: false,
        );

        final repository = PodesavanjaRepository(db);
        final coldWatch = Stopwatch()..start();
        final entries = await repository.getKatalogSaArtiklimaLightweight();
        coldWatch.stop();
        final warmWatch = Stopwatch()..start();
        final warmEntries = await repository.getKatalogSaArtiklimaLightweight();
        warmWatch.stop();
        // Diagnostic evidence only: synthetic in-memory timings have no
        // hardware threshold and do not establish the runtime root cause.
        // ignore: avoid_print
        print(
          '[GATE2A] global lightweight cold=${coldWatch.elapsedMilliseconds}ms '
          'warm=${warmWatch.elapsedMilliseconds}ms '
          'categories=${entries.length} articles=${entries.fold<int>(0, (count, entry) => count + entry.artikli.length)}',
        );
        expect(warmEntries.length, entries.length);
        final a = entries.singleWhere(
          (entry) => entry.config.interniNaziv == 'GATE2_CATEGORY_A',
        );
        final b = entries.singleWhere(
          (entry) => entry.config.interniNaziv == 'GATE2_CATEGORY_B',
        );

        expect(entries.indexOf(a), lessThan(entries.indexOf(b)));
        expect(a.artikli.map((article) => article.id).toList(), [
          firstId,
          secondId,
        ]);
        expect(a.artikli[0].stableArticleId, 'gate2-a-1');
        expect(a.artikli[0].naziv, 'A prvi');
        expect(a.artikli[0].cena, 12.5);
        expect(a.artikli[0].hasPhoto, isTrue);
        expect(a.artikli[1].hasPhoto, isFalse);
        expect(b.artikli.single.stableArticleId, 'gate2-b-1');
        expect(
          await repository.getKatalogArticlePhotoById(firstId),
          orderedEquals([1, 2, 3]),
        );
      },
    );

    test('scoped lightweight load excludes unrelated categories', () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      await _insertCategory(
        db,
        key: 'GATE2_SCOPE_A',
        label: 'Scope A',
        order: -30,
      );
      await _insertCategory(
        db,
        key: 'GATE2_SCOPE_B',
        label: 'Scope B',
        order: -29,
      );
      await _insertCategory(
        db,
        key: 'GATE2_SCOPE_OTHER',
        label: 'Scope Other',
        order: -28,
      );
      await _insertArticle(
        db,
        category: 'GATE2_SCOPE_A',
        stableId: 'gate2-scope-a',
        name: 'Scope A article',
        price: 1,
        hasPhoto: false,
      );
      await _insertArticle(
        db,
        category: 'GATE2_SCOPE_OTHER',
        stableId: 'gate2-scope-other',
        name: 'Scope Other article',
        price: 2,
        hasPhoto: false,
      );

      final entries = await PodesavanjaRepository(db)
          .getKatalogSaArtiklimaLightweightZaKategorije(const {
            'GATE2_SCOPE_A',
            'GATE2_SCOPE_B',
          });

      expect(entries.map((entry) => entry.config.interniNaziv), [
        'GATE2_SCOPE_A',
        'GATE2_SCOPE_B',
      ]);
      expect(entries.first.artikli.single.stableArticleId, 'gate2-scope-a');
      expect(entries.last.artikli, isEmpty);
      expect(
        entries
            .expand((entry) => entry.artikli)
            .map((article) => article.stableArticleId),
        isNot(contains('gate2-scope-other')),
      );
    });
  });
}

Future<void> _insertCategory(
  AppDatabase db, {
  required String key,
  required String label,
  required int order,
}) {
  return db
      .into(db.iriuKatalogConfig)
      .insert(
        IriuKatalogConfigCompanion.insert(
          interniNaziv: key,
          nazivPrikaz: label,
          vidljiv: const Value(true),
          tip: const Value('KATALOSKA'),
          redosled: Value(order),
        ),
      );
}

Future<int> _insertArticle(
  AppDatabase db, {
  required String category,
  required String stableId,
  required String name,
  required double price,
  required bool hasPhoto,
}) {
  return db
      .into(db.katalogArtikli)
      .insert(
        KatalogArtikliCompanion.insert(
          stableArticleId: Value(stableId),
          interniNazivKategorije: category,
          naziv: name,
          cena: Value(price),
          fotografija: hasPhoto
              ? Value(Uint8List.fromList([1, 2, 3]))
              : const Value.absent(),
        ),
      );
}
