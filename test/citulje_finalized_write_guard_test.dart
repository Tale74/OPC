import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/citulje/data/citulje_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/citulje/domain/citulje_models.dart';

import 'test_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'finalized human corrections preserve finalization and PARTE provenance',
    () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final repository = CituljePreparationRepository(db);
        final predmetId = await db
            .into(db.predmeti)
            .insert(
              PredmetiCompanion.insert(brojPredmeta: const Value('R3-GUARD')),
            );
        await db
            .into(db.iriu)
            .insert(
              IriuCompanion.insert(
                predmetId: predmetId,
                interniNaziv: 'CITULJA_POLITIKA',
                portableOccurrenceId: const Value('r3-guard'),
              ),
            );
        final row = (await repository.ensureCurrentForPredmet(
          predmetId,
        )).single;
        final configured = await repository.configure(
          preparationId: row.id,
          mode: CituljeParteTextMode.da,
          publicationText: 'Prvi tekst',
          publicationDate: '2026-09-06',
          note: 'Izvorna beleška',
        );
        expect(configured.publicationDate, '2026-09-06');
        expect(configured.note, 'Izvorna beleška');
        final edited = await repository.savePublicationText(
          preparationId: row.id,
          publicationText: 'Sačuvan tekst',
        );
        expect(edited.publicationText, 'Sačuvan tekst');
        expect(edited.finalized, isFalse);
        await (db.update(
          db.cituljePripreme,
        )..where((item) => item.id.equals(row.id))).write(
          const CituljePripremeCompanion(
            state: Value('PARTE_SNAPSHOT_AVAILABLE'),
            parteSnapshotFingerprint: Value('finalized-fingerprint'),
          ),
        );

        final frozen = await repository.finalizePreparation(
          preparationId: row.id,
        );
        final corrected = await repository.saveHumanCorrections(
          preparationId: row.id,
          publicationDate: '2030-01-01',
          publicationText: 'Ručna korekcija',
          note: 'Korigovana beleška',
        );
        expect(corrected.publicationDate, '2030-01-01');
        expect(corrected.publicationText, 'Ručna korekcija');
        expect(corrected.note, 'Korigovana beleška');
        expect(corrected.finalized, isTrue);
        expect(corrected.finalizedAt, frozen.finalizedAt);
        expect(corrected.parteSnapshotFingerprint, 'finalized-fingerprint');

      },
    );

  test('finalized preparation removal preserves IRiU and recreates fresh', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repository = CituljePreparationRepository(db);
    final predmetId = await db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(brojPredmeta: const Value('R3-REMOVE')),
        );
    await db.into(db.iriu).insert(
      IriuCompanion.insert(
        predmetId: predmetId,
        interniNaziv: 'CITULJA_POLITIKA',
        portableOccurrenceId: const Value('remove-1'),
      ),
    );
    final row = (await repository.ensureCurrentForPredmet(predmetId)).single;
    await repository.configure(
      preparationId: row.id,
      mode: CituljeParteTextMode.ne,
      publicationText: 'Stari završeni tekst',
    );
    final finalized = await repository.finalizePreparation(
      preparationId: row.id,
    );
    expect(await repository.removeFinalizedPreparation(
      preparationId: finalized.id,
    ), isTrue);
    expect(await (db.select(db.cituljePripreme)..where(
      (item) => item.id.equals(finalized.id),
    )).getSingleOrNull(), isNull);
    expect(
      await (db.select(db.iriu)..where(
        (item) => item.portableOccurrenceId.equals('remove-1'),
      )).getSingleOrNull(),
      isNotNull,
    );

    final fresh = (await repository.ensureCurrentForPredmet(predmetId)).single;
    expect(fresh.id, isNot(finalized.id));
    expect(fresh.finalized, isFalse);
    expect(fresh.publicationText, isEmpty);
    expect(fresh.parteSnapshotFingerprint, isNull);
    expect(fresh.state, CituljePreparationState.unconfigured.dbValue);
  });

  test(
    'finalization requires a real publication text and valid preparation state',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repository = CituljePreparationRepository(db);
      final predmetId = await db
          .into(db.predmeti)
          .insert(
            PredmetiCompanion.insert(brojPredmeta: const Value('R3-FINALIZE')),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: 'CITULJA_POLITIKA',
              portableOccurrenceId: const Value('finalize-ne'),
            ),
          );
      await db
          .into(db.iriu)
          .insert(
            IriuCompanion.insert(
              predmetId: predmetId,
              interniNaziv: 'CITULJA_NOVOSTI',
              portableOccurrenceId: const Value('finalize-da'),
            ),
          );
      final rows = await repository.ensureCurrentForPredmet(predmetId);
      final unconfigured = rows.first;
      final waiting = rows.last;
      await expectLater(
        repository.finalizePreparation(preparationId: unconfigured.id),
        throwsA(isA<StateError>()),
      );
      await repository.configure(
        preparationId: waiting.id,
        mode: CituljeParteTextMode.da,
      );
      await expectLater(
        repository.finalizePreparation(preparationId: waiting.id),
        throwsA(isA<StateError>()),
      );
      final emptyIndependent = await repository.configure(
        preparationId: unconfigured.id,
        mode: CituljeParteTextMode.ne,
      );
      await expectLater(
        repository.finalizePreparation(preparationId: emptyIndependent.id),
        throwsA(isA<StateError>()),
      );
      final validIndependent = await repository.configure(
        preparationId: unconfigured.id,
        mode: CituljeParteTextMode.ne,
        publicationText: 'Validan nezavisni tekst',
      );
      expect(
        (await repository.finalizePreparation(
          preparationId: validIndependent.id,
        )).finalized,
        isTrue,
      );
      final validDa = await repository.configure(
        preparationId: waiting.id,
        mode: CituljeParteTextMode.da,
      );
      await (db.update(
        db.cituljePripreme,
      )..where((row) => row.id.equals(validDa.id))).write(
        const CituljePripremeCompanion(
          publicationText: Value('Potvrđeni DA tekst'),
          state: Value('PARTE_SNAPSHOT_AVAILABLE'),
          parteSnapshotFingerprint: Value('fixture-fingerprint'),
        ),
      );
      expect(
        (await repository.finalizePreparation(
          preparationId: validDa.id,
        )).finalized,
        isTrue,
      );
    },
  );
}
