import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_module_screen.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_composer_screen.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_print_profile_store.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('MODUL PARTE lists only open PREDMET with required PARTE', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Sintetički savetnik',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-07-12T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    await _insert(db, 'ELIGIBLE-001', 'Otvoreno', parte: true);
    await _insert(db, 'NO-PARTE-002', 'BezParte', parte: false);
    await _insert(
      db,
      'CLOSED-003',
      'Zatvoreno',
      parte: true,
      status: 'ZATVOREN',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ParteModuleScreen(
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('TEKSTUALNI BLOKOVI').evaluate().isNotEmpty) break;
    }

    expect(find.text('MODUL PARTE'), findsOneWidget);
    expect(find.text('Otvoreno Lice'), findsOneWidget);
    expect(find.textContaining('ELIGIBLE-001'), findsOneWidget);
    expect(find.textContaining('NO-PARTE-002'), findsNothing);
    expect(find.textContaining('CLOSED-003'), findsNothing);
  });

  testWidgets('narrow composer has collapsible setup and persistent designer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(520, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Sintetički savetnik',
            uloga: 'SAVETNIK',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-07-17T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    await _insert(db, 'COMPOSER-004', 'Sintetičko', parte: true);
    final predmet = await (db.select(
      db.predmeti,
    )..where((row) => row.brojPredmeta.equals('COMPOSER-004'))).getSingle();
    await tester.pumpWidget(
      MaterialApp(
        home: ParteComposerScreen(
          predmetId: predmet.id,
          predmetiRepository: PredmetiRepository(db),
          actor: actor,
          printProfileStore: _MemoryPrintProfileStore(),
          entitlement: const OpcEntitlementPolicy.fromSource(
            OpcDemoTestEntitlementSource(packageLevel: OpcPackageLevel.potpun),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 40; attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('TEKSTUALNI BLOKOVI').evaluate().isNotEmpty) break;
    }

    expect(find.text('TEKSTUALNI BLOKOVI'), findsOneWidget);
    expect(find.text('FORMAT I ZONA ŠTAMPE (mm)'), findsOneWidget);
    expect(find.text('Zona – X'), findsNothing);
    expect(find.text('Zona – Y'), findsNothing);
    expect(find.text('Zona štampe – širina'), findsOneWidget);
    expect(find.text('Zona štampe – visina'), findsOneWidget);
    expect(find.textContaining('min '), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('TEKSTUALNI BLOKOVI'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('PRECIZNO POMERANJE I STIL'), findsOneWidget);
    expect(find.byKey(const Key('parte-compact-font-row')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('PREGLED PRIPREME'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('PREGLED PRIPREME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _insert(
  AppDatabase db,
  String broj,
  String ime, {
  required bool parte,
  String status = 'OTVOREN',
}) => db
    .into(db.predmeti)
    .insert(
      PredmetiCompanion.insert(
        brojPredmeta: Value(broj),
        datumKreiranja: const Value('2026-07-12T10:00:00.000'),
        ime: Value(ime),
        prezime: const Value('Lice'),
        partePotrebna: Value(parte),
        status: Value(status),
      ),
    )
    .then((_) {});

class _MemoryPrintProfileStore extends PartePrintProfileStore {
  _MemoryPrintProfileStore()
    : super(rootDirectory: () async => Directory.current);

  PartePrintProfile _profile = const PartePrintProfile();

  @override
  Future<PartePrintProfile> load() async => _profile;

  @override
  Future<void> save(PartePrintProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> reset() async {
    _profile = const PartePrintProfile();
  }
}
