import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/citulje/data/citulje_preparation_repository.dart';
import 'package:opc_v4/features/predmeti/citulje/domain/citulje_concrete_format_projection.dart';

import 'test_bootstrap.dart';

void main() {
  test('category-only ČITULJE use their canonical category labels', () {
    expect(
      resolveCituljeConcreteFormatDisplay(
        articleType: 'CITULJA_POLITIKA',
        currentDisplayName: 'Čitulja Politika',
      ),
      'ČITULJA POLITIKA',
    );
    expect(
      resolveCituljeConcreteFormatDisplay(
        articleType: 'CITULJA_NOVOSTI',
        currentDisplayName: 'Čitulja Novosti',
      ),
      'ČITULJA NOVOSTI',
    );
  });

  test('concrete selection follows current IRiU display without price input', () {
    expect(
      resolveCituljeConcreteFormatDisplay(
        articleType: 'CITULJA_POLITIKA',
        currentDisplayName: 'Porodična čitulja',
      ),
      'Porodična čitulja',
    );
  });

  test('reselection and category reversion follow current IRiU truth', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final predmetId = await db
        .into(db.predmeti)
        .insert(PredmetiCompanion.insert(brojPredmeta: const Value('CIT-02')));
    await db.into(db.iriu).insert(
      IriuCompanion.insert(
        predmetId: predmetId,
        portableOccurrenceId: const Value('citulja-1'),
        interniNaziv: 'CITULJA_POLITIKA',
        nazivPrikaz: const Value('Prva forma'),
        katalogStableArticleId: const Value('CIT-P-001'),
      ),
    );

    final repository = CituljePreparationRepository(db);
    final preparation =
        (await repository.ensureCurrentForPredmet(predmetId)).single;
    expect(await repository.currentCituljaDisplayValue(preparation), 'Prva forma');

    await (db.update(db.iriu)..where((row) => row.predmetId.equals(predmetId)))
        .write(
          const IriuCompanion(
            nazivPrikaz: Value('Druga forma'),
            katalogStableArticleId: Value('CIT-P-002'),
          ),
        );
    expect(await repository.currentCituljaDisplayValue(preparation), 'Druga forma');

    await (db.update(db.iriu)..where((row) => row.predmetId.equals(predmetId)))
        .write(
          const IriuCompanion(
            nazivPrikaz: Value('CITULJA_POLITIKA'),
            katalogStableArticleId: Value(null),
          ),
        );
    expect(
      await repository.currentCituljaDisplayValue(preparation),
      'ČITULJA POLITIKA',
    );
    expect(preparation.articleType, 'CITULJA_POLITIKA');
  });
}
