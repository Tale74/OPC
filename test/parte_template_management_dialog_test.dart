import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_template_repository.dart';
import 'package:opc_v4/features/predmeti/parte/domain/parte_models.dart';
import 'package:opc_v4/features/predmeti/parte/presentation/parte_template_management_dialog.dart';

import 'test_bootstrap.dart';

void main() {
  testWidgets('long template name stays readable without status suffixes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = createTestDatabase();
    addTearDown(db.close);
    final actorId = await db
        .into(db.korisnici)
        .insert(
          KorisniciCompanion.insert(
            imePrezime: 'Sintetički administrator',
            uloga: 'ADMINISTRATOR',
            pinHash: 'synthetic-hash',
            datumKreiranja: '2026-10-04T10:00:00.000',
          ),
        );
    final actor = await (db.select(
      db.korisnici,
    )..where((row) => row.id.equals(actorId))).getSingle();
    const longName =
        'OPC SUZA 2 – PODRAZUMEVANI – TRENUTNO PRIMENJEN – DUGAČAK NAZIV';
    final repository = ParteTemplateRepository(db);
    final custom = await repository.createUserTemplate(
      actor: actor,
      name: longName,
      technicalSource: ParteTemplate.builtInStandard,
    );
    await repository.setDefault(templateId: custom.id, actor: actor);
    const standard = ParteTemplate.builtInStandard;
    final draft = ParteDraft(
      textByBlock: const {},
      blocks: standard.blocks,
      widthMm: standard.widthMm,
      heightMm: standard.heightMm,
      symbolId: 'test-symbol',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ParteTemplateManagementDialog(
                  repository: repository,
                  actor: actor,
                  currentDraft: draft,
                  activeTemplateId: custom.id,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text(longName), findsOneWidget);
    expect(find.text('PODRAZUMEVAN'), findsOneWidget);
    expect(find.text('TRENUTNO PRIMENJEN'), findsOneWidget);
    expect(
      find.textContaining('$longName – PODRAZUMEVAN'),
      findsNothing,
    );
    expect(
      tester.getRect(find.byType(DropdownButtonFormField<String>)).width,
      greaterThan(0),
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text(longName), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
