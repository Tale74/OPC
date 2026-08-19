import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';

void main() {
  test('fresh database is valid and business KATALOG is empty', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await _userVersion(db), 27);
    expect(await db.select(db.iriuKatalogConfig).get(), isEmpty);
    expect(await db.select(db.katalogArtikli).get(), isEmpty);
    expect(
      await _hasIndex(db, 'idx_katalog_artikli_stable_article_id'),
      isTrue,
    );
    expect(await _count(db, 'firma_podaci'), 1);
    expect(await _count(db, 'app_podesavanja'), 1);

    final admin = await AuthRepository(
      db,
    ).kreirajPrvogAdmina(imePrezime: 'RR011 TEST ADMIN', pin: '2468');
    expect(admin.imePrezime, 'RR011 TEST ADMIN');
    expect(await db.hasKorisnika(), isTrue);
  });

  test('reopening a fresh database does not reseed business KATALOG', () async {
    final directory = await Directory.systemTemp.createTemp(
      'opc-empty-katalog-',
    );
    final file = File('${directory.path}${Platform.pathSeparator}empty.sqlite');
    try {
      final first = AppDatabase.forTesting(NativeDatabase(file));
      expect(await first.select(first.iriuKatalogConfig).get(), isEmpty);
      expect(await first.select(first.katalogArtikli).get(), isEmpty);
      await first.close();

      final second = AppDatabase.forTesting(NativeDatabase(file));
      expect(await second.select(second.iriuKatalogConfig).get(), isEmpty);
      expect(await second.select(second.katalogArtikli).get(), isEmpty);
      expect(
        await _hasIndex(second, 'idx_katalog_artikli_stable_article_id'),
        isTrue,
      );
      await second.close();
    } finally {
      await _deleteEventually(directory);
    }
  });

  test(
    'existing KATALOG rows and user edits survive reopen without reseeding',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'opc-existing-katalog-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}existing.sqlite',
      );
      try {
        final first = AppDatabase.forTesting(NativeDatabase(file));
        await first
            .into(first.iriuKatalogConfig)
            .insert(
              const IriuKatalogConfigCompanion(
                interniNaziv: Value('USER_CATEGORY'),
                nazivPrikaz: Value('User category'),
                tip: Value('KATALOSKA'),
                jeKorisnicka: Value(true),
              ),
            );
        await first
            .into(first.katalogArtikli)
            .insert(
              const KatalogArtikliCompanion(
                stableArticleId: Value('user-article-001'),
                interniNazivKategorije: Value('USER_CATEGORY'),
                naziv: Value('User article'),
                cena: Value(123.45),
              ),
            );
        await first.close();

        final second = AppDatabase.forTesting(NativeDatabase(file));
        final category =
            await (second.select(second.iriuKatalogConfig)
                  ..where((row) => row.interniNaziv.equals('USER_CATEGORY')))
                .getSingle();
        final article =
            await (second.select(second.katalogArtikli)..where(
                  (row) => row.stableArticleId.equals('user-article-001'),
                ))
                .getSingle();
        expect(category.nazivPrikaz, 'User category');
        expect(category.jeKorisnicka, isTrue);
        expect(article.naziv, 'User article');
        expect(article.cena, 123.45);
        expect(
          (await second.select(second.katalogArtikli).get())
              .where((row) => row.interniNazivKategorije == 'CITULJA_POLITIKA')
              .length,
          0,
        );
        await second.close();
      } finally {
        await _deleteEventually(directory);
      }
    },
  );

  test('stable article IDs remain uniquely constrained', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.katalogArtikli)
        .insert(
          const KatalogArtikliCompanion(
            stableArticleId: Value('duplicate-check'),
            interniNazivKategorije: Value('TEST'),
            naziv: Value('First'),
          ),
        );
    await expectLater(
      db
          .into(db.katalogArtikli)
          .insert(
            const KatalogArtikliCompanion(
              stableArticleId: Value('duplicate-check'),
              interniNazivKategorije: Value('TEST'),
              naziv: Value('Second'),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}

Future<int> _userVersion(AppDatabase db) async =>
    (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
      'user_version',
    );

Future<int> _count(AppDatabase db, String table) async =>
    (await db
            .customSelect('SELECT COUNT(*) AS count FROM "$table"')
            .getSingle())
        .read<int>('count');

Future<bool> _hasIndex(AppDatabase db, String name) async =>
    (await db
        .customSelect(
          "SELECT 1 AS present FROM sqlite_master WHERE type = 'index' AND name = ?",
          variables: [Variable<String>(name)],
        )
        .getSingleOrNull()) !=
    null;

Future<void> _deleteEventually(Directory directory) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      if (await directory.exists()) await directory.delete(recursive: true);
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
}
