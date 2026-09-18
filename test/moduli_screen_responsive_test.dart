import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/podesavanja/data/podesavanja_repository.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/moduli_screen.dart';

void main() {
  const moduleKeys = [
    'moduli-scenario-card',
    'moduli-podsetnik-card',
    'moduli-parte-card',
    'moduli-citulje-card',
    'moduli-stanje-robe-card',
  ];

  testWidgets('MODULI uses two columns when wide space is available', (
    tester,
  ) async {
    final db = _createResponsiveTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(_screen(db));
    await tester.pumpAndSettle();

    for (final key in moduleKeys) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    final scenario = find.byKey(const ValueKey('moduli-scenario-card'));
    final podsetnik = find.byKey(const ValueKey('moduli-podsetnik-card'));
    final parte = find.byKey(const ValueKey('moduli-parte-card'));
    final citulje = find.byKey(const ValueKey('moduli-citulje-card'));
    final stanjeRobe = find.byKey(
      const ValueKey('moduli-stanje-robe-card'),
    );

    expect(
      tester.getTopLeft(scenario).dy,
      closeTo(tester.getTopLeft(podsetnik).dy, 0.1),
    );
    expect(
      tester.getTopLeft(parte).dy,
      greaterThan(tester.getTopLeft(scenario).dy),
    );
    expect(
      tester.getTopLeft(parte).dx,
      lessThan(tester.getTopLeft(citulje).dx),
    );
    expect(
      tester.getTopLeft(stanjeRobe).dy,
      greaterThan(tester.getTopLeft(parte).dy),
    );
    expect(tester.getSize(scenario).width, greaterThan(300));
    expect(
      tester.getSize(scenario).width,
      closeTo(tester.getSize(podsetnik).width, 0.1),
    );
  });

  testWidgets('MODULI remains one column and scrollable on narrow space', (
    tester,
  ) async {
    final db = _createResponsiveTestDatabase();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(_screen(db));
    await tester.pumpAndSettle();

    for (final key in moduleKeys) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    final scenario = find.byKey(const ValueKey('moduli-scenario-card'));
    final podsetnik = find.byKey(const ValueKey('moduli-podsetnik-card'));
    final parte = find.byKey(const ValueKey('moduli-parte-card'));

    expect(
      tester.getSize(scenario).width,
      closeTo(tester.getSize(parte).width, 0.1),
    );
    expect(
      tester.getTopLeft(podsetnik).dy,
      greaterThan(tester.getTopLeft(scenario).dy),
    );
    expect(
      tester.getTopLeft(podsetnik).dx,
      closeTo(tester.getTopLeft(scenario).dx, 0.1),
    );

    await tester.ensureVisible(find.byKey(const ValueKey('moduli-citulje-card')));
    await tester.tap(find.text('ČITULJE'));
    await tester.pumpAndSettle();
    expect(find.text('MODUL ČITULJE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _screen(AppDatabase db) => MaterialApp(
  home: ModuliScreen(
    predmetiRepository: PredmetiRepository(db),
    podesavanjaRepository: _StaticPodesavanjaRepository(db),
    session: SessionService(),
    entitlementPolicy: const OpcEntitlementPolicy.fromSource(
      OpcDemoTestEntitlementSource(
        packageLevel: OpcPackageLevel.potpun,
      ),
    ),
  ),
);

AppDatabase _createResponsiveTestDatabase() => AppDatabase.forTesting(
  DatabaseConnection(
    NativeDatabase.memory(),
    closeStreamsSynchronously: true,
  ),
);

class _StaticPodesavanjaRepository extends PodesavanjaRepository {
  _StaticPodesavanjaRepository(super.db);

  @override
  Stream<bool> watchStanjeRobeOperativnoOmoguceno() => Stream.value(false);
}
