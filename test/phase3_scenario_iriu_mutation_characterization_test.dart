import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/constants/iriu_constants.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart';
import 'package:opc_v4/features/predmeti/core_v2/rules/iriu_truth_rules.dart';
import 'package:opc_v4/features/predmeti/data/iriu_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';

import 'test_bootstrap.dart';

void main() {
  group('Phase 3 SCENARIO/IRiU mutation characterization', () {
    test(
      'MESTO SMRTI sync is idempotent and preserves a manual IRiU row',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetiRepo = PredmetiRepository(db);
        final iriuRepo = IriuRepository(db);
        final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(predmetId);
        await predmetiRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final predmet = await predmetiRepo.getPredmet(predmetId);

        await iriuRepo.dodajStavku(
          predmetId: predmetId,
          interniNaziv: 'RUCNI_PHASE3_ROW',
          nazivPrikaz: 'Ručna Phase 3 stavka',
          redosled: 999,
        );
        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: const MestoSmrtiIriuLifecycleService(),
        );
        final afterFirstSync = await iriuRepo.getIriu(predmetId);
        final firstIds = afterFirstSync.map((row) => row.id).toList();

        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: const MestoSmrtiIriuLifecycleService(),
        );
        final afterSecondSync = await iriuRepo.getIriu(predmetId);

        expect(afterSecondSync.map((row) => row.id).toList(), firstIds);
        expect(
          afterSecondSync.where(
            (row) => row.interniNaziv == 'RUCNI_PHASE3_ROW',
          ),
          hasLength(1),
        );
        for (final category in IriuTruthRules.mestoSmrtiManagedCategories) {
          expect(
            afterSecondSync.where((row) => row.interniNaziv == category),
            hasLength(1),
          );
        }
      },
    );

    test(
      'manual dismissal suppresses re-addition until explicit user insertion',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetiRepo = PredmetiRepository(db);
        final iriuRepo = IriuRepository(db);
        final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(predmetId);
        await predmetiRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final predmet = await predmetiRepo.getPredmet(predmetId);
        const lifecycle = MestoSmrtiIriuLifecycleService();

        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );
        final managedRow = (await iriuRepo.getIriu(
          predmetId,
        )).firstWhere((row) => row.interniNaziv == IriuK.hladnjaca);
        await iriuRepo.obrisiStavkuSaLifecycleMemorijom(
          predmetId: predmetId,
          row: managedRow,
        );
        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );

        expect(
          await iriuRepo.getDismissedMestoSmrtiCategories(predmetId),
          contains(IriuK.hladnjaca),
        );
        expect(
          (await iriuRepo.getIriu(
            predmetId,
          )).where((row) => row.interniNaziv == IriuK.hladnjaca),
          isEmpty,
        );

        await iriuRepo.dodajStavku(
          predmetId: predmetId,
          interniNaziv: IriuK.hladnjaca,
          nazivPrikaz: IriuK.naziviPrikaz[IriuK.hladnjaca]!,
        );
        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );
        expect(
          (await iriuRepo.getIriu(
            predmetId,
          )).where((row) => row.interniNaziv == IriuK.hladnjaca),
          hasLength(1),
        );
      },
    );

    test(
      'condition change currently leaves stale managed rows for Phase 4 cleanup design',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetiRepo = PredmetiRepository(db);
        final iriuRepo = IriuRepository(db);
        final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(predmetId);
        await predmetiRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('DOM ZA STARE')),
        );
        final qualifying = await predmetiRepo.getPredmet(predmetId);
        const lifecycle = MestoSmrtiIriuLifecycleService();

        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: qualifying,
          lifecycleService: lifecycle,
        );
        final managedBeforeChange = (await iriuRepo.getIriu(predmetId))
            .where(
              (row) => IriuTruthRules.mestoSmrtiManagedCategories.contains(
                row.interniNaziv,
              ),
            )
            .toList(growable: false);
        expect(managedBeforeChange, isNotEmpty);

        await predmetiRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(mestoSmrti: Value('')),
        );
        final changed = await predmetiRepo.getPredmet(predmetId);
        await iriuRepo.syncMestoSmrtiManagedRows(
          predmetId: predmetId,
          predmet: changed,
          lifecycleService: lifecycle,
        );

        final storedAfterChange = await iriuRepo.getIriu(predmetId);
        expect(
          storedAfterChange.map((row) => row.id),
          containsAll(managedBeforeChange.map((row) => row.id)),
        );
        final snapshot = const PredmetIriuTruthService().evaluate(
          predmet: changed,
          storedRows: storedAfterChange,
        );
        for (final row in snapshot.rows.where(
          (row) => IriuTruthRules.mestoSmrtiManagedCategories.contains(
            row.storedRow.interniNaziv,
          ),
        )) {
          expect(row.active, isFalse);
        }
      },
    );

    test(
      'BLOK 2 sync is idempotent and remembers an explicit dismissal',
      () async {
        final db = createTestDatabase();
        addTearDown(db.close);
        final predmetiRepo = PredmetiRepository(db);
        final iriuRepo = IriuRepository(db);
        final predmetId = await predmetiRepo.kreirajPredmet(savetnikId: 1);
        await predmetiRepo.inicijalizujIriu(predmetId);
        await predmetiRepo.azurirajPredmet(
          predmetId,
          const PredmetiCompanion(
            mestoSmrti: Value('STAN'),
            uzrokSmrti: Value('PRIRODNA'),
            tipGroblja: Value('GRADSKO'),
            grobnoMesto: Value('POSTOJECE'),
            tipGrobnogMesta: Value('GROBNICA'),
            vrstaCeremonije: Value('SAHRANA'),
          ),
        );
        final predmet = await predmetiRepo.getPredmet(predmetId);
        const lifecycle = Blok2IriuLifecycleService();

        await iriuRepo.syncBlok2ManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );
        final first = await iriuRepo.getIriu(predmetId);
        final firstIds = first.map((row) => row.id).toList();
        expect(
          first.where((row) => row.interniNaziv == IriuK.limeniUlozak),
          hasLength(1),
        );
        expect(
          first.where((row) => row.interniNaziv == IriuK.lemovanje),
          hasLength(1),
        );

        await iriuRepo.syncBlok2ManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );
        expect(
          (await iriuRepo.getIriu(predmetId)).map((row) => row.id).toList(),
          firstIds,
        );

        final lemovanje = (await iriuRepo.getIriu(
          predmetId,
        )).firstWhere((row) => row.interniNaziv == IriuK.lemovanje);
        await iriuRepo.obrisiStavkuSaLifecycleMemorijom(
          predmetId: predmetId,
          row: lemovanje,
        );
        await iriuRepo.syncBlok2ManagedRows(
          predmetId: predmetId,
          predmet: predmet,
          lifecycleService: lifecycle,
        );
        expect(
          (await iriuRepo.getDismissedBlok2Categories(predmetId)),
          contains(IriuK.lemovanje),
        );
        expect(
          (await iriuRepo.getIriu(
            predmetId,
          )).where((row) => row.interniNaziv == IriuK.lemovanje),
          isEmpty,
        );
      },
    );
  });
}
