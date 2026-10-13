import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/help/opc_guide_repository.dart';
import 'package:opc_v4/core/help/opc_help.dart';
import 'package:opc_v4/core/help/opc_guide_screen.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';
import 'package:opc_v4/features/auth/domain/session_service.dart';
import 'package:opc_v4/features/predmeti/data/predmeti_repository.dart';
import 'package:opc_v4/features/predmeti/presentation/predmet_screen.dart';

import 'opc_guide_test_bundle.dart';
import 'test_bootstrap.dart';

void main() {
  test(
    'the bundled guide covers all routed screens and ten PREDMET segments',
    () async {
      final chapters = await const OpcGuideRepository().load();
      final byId = {for (final chapter in chapters) chapter.id: chapter};
      expect(byId.length, chapters.length);
      expect(chapters.length, 33);
      for (var segment = 1; segment <= 10; segment++) {
        final chapterId = predmetGuideChapterIdForSegment(segment);
        expect(byId, contains(chapterId));
        expect(byId[chapterId]!.sections, isNotEmpty);
      }
      expect(
        byId.keys,
        containsAll([
          'first_launch',
          'login',
          'forced_pin',
          'lista',
          'moduli',
          'settings',
          'settings.catalog',
          'settings.users',
          'settings.about',
          'statistics',
          'scenario',
          'reminders',
          'parte.list',
          'parte.preparation',
          'citulje.list',
          'citulje.preparation',
          'stock',
        ]),
      );
      expect(byId['lista']!.title, 'PREDMETI');
      expect(
        byId['predmet.dokumenti']!.sections
            .singleWhere(
              (section) => section.title == 'Kako da pripremite dokument',
            )
            .text,
        contains('NALOG CVEĆARI PDF'),
      );
      expect(
        byId['predmet.dokumenti']!.sections
            .singleWhere(
              (section) => section.title == 'Kako da pripremite dokument',
            )
            .text,
        isNot(contains('PONUDA')),
      );
      expect(
        byId['predmet.roba_i_usluge']!.sections
            .singleWhere(
              (section) =>
                  section.title == 'SCENARIO i automatski unos robe i usluga',
            )
            .text,
        allOf(
          contains('OSNOVNOG PAKETA'),
          contains('dodatnih paketa'),
          contains('konkretne artikle iz KATALOGA'),
          contains('ručno dodali'),
        ),
      );
      final guideText = chapters
          .expand(
            (chapter) => [
              chapter.title,
              chapter.intro,
              ...chapter.sections.expand(
                (section) => [section.title, section.text],
              ),
            ],
          )
          .join('\n');
      expect(guideText, contains('naloge osoba koje će raditi'));
      expect(guideText, isNot(contains('naloge ljudi')));
      expect(
        guideText,
        contains('obratite se administratoru ili servisnoj podršci'),
      );
      expect(guideText, isNot(contains('morati da obrišete bazu')));
      expect(byId['predmet']!.intro, contains('osam poslovnih segmenata'));
      expect(byId['predmet']!.intro, contains('DOKUMENTI i PREGLED I POTVRDA'));
      expect(
        byId['settings']!.sections
            .singleWhere(
              (section) => section.title == 'Prenos i rezervne kopije',
            )
            .text,
        contains('Uvoz jednog PREDMETA'),
      );
      expect(
        chapters
            .expand(
              (chapter) => [
                chapter.title,
                chapter.intro,
                ...chapter.sections.expand(
                  (section) => [section.title, section.text],
                ),
              ],
            )
            .join('\n'),
        isNot(contains('—')),
      );
    },
  );

  testWidgets('all visible guide text, including headings, is italic', (
    tester,
  ) async {
    final guideBundle = await loadOpcGuideTestAssetBundle(tester);
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: guideBundle,
        child: const MaterialApp(
          home: OpcGuideScreen(initialChapterId: 'lista'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final visibleText = tester.widgetList<Text>(find.byType(Text)).toList();
    expect(visibleText, isNotEmpty);
    for (final text in visibleText) {
      final textFinder = find.byWidget(text);
      final inheritedStyle = DefaultTextStyle.of(
        tester.element(textFinder),
      ).style;
      expect(
        inheritedStyle.merge(text.style).fontStyle,
        FontStyle.italic,
        reason: 'Guide text must be italic: ${text.data}',
      );
    }
  });

  testWidgets(
    'help is explicit, contextual, and returns to its unchanged page',
    (tester) async {
      final guideBundle = await loadOpcGuideTestAssetBundle(tester);
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: guideBundle,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const OpcHelpTitle(
                  title: Text('PRIJAVA'),
                  chapterId: 'login',
                ),
              ),
              body: const Text('Zadržan ekran prijave'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('opc-help-button-login')), findsOneWidget);
      final helpButton = find.byKey(const Key('opc-help-button-login'));
      expect(tester.getSize(helpButton), const Size(48, 48));
      expect(find.text('Zadržan ekran prijave'), findsOneWidget);
      expect(find.text('Izbor korisnika'), findsNothing);

      await tester.tapAt(tester.getCenter(helpButton) + const Offset(20, 0));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('opc-guide-content-login')),
      );
      expect(find.byKey(const Key('opc-guide-content-login')), findsOneWidget);
      expect(find.text('Kako da se prijavite'), findsWidgets);
      expect(find.text('Zadržan ekran prijave'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Zadržan ekran prijave'), findsOneWidget);
      expect(find.byKey(const Key('opc-help-button-login')), findsOneWidget);
    },
  );

  testWidgets(
    'PREDMET help follows the active Narrow segment and preserves it',
    (tester) async {
      final guideBundle = await loadOpcGuideTestAssetBundle(tester);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = PredmetiRepository(db);
      final admin = await AuthRepository(
        db,
      ).kreirajPrvogAdmina(imePrezime: 'Uputstvo test', pin: '1234');
      final session = SessionService()..prijavi(admin);
      final id = await repo.kreirajPredmet(savetnikId: admin.id);

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: guideBundle,
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: PredmetScreen(
              predmetId: id,
              predmetiRepo: repo,
              session: session,
              openCeremony: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('predmet-segment-title-5')), findsOneWidget);
      final before = await repo.getPredmet(id);
      expect(
        find.byKey(const Key('opc-help-button-predmet.ceremonija')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('opc-help-button-predmet.ceremonija')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('opc-guide-content-predmet.ceremonija')),
      );
      expect(
        find.byKey(const Key('opc-guide-content-predmet.ceremonija')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('opc-guide-section-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groblje i mesto').last);
      await tester.pumpAndSettle();
      expect(find.text('Groblje i mesto'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('predmet-segment-title-5')), findsOneWidget);
      expect(
        find.byKey(const Key('opc-help-button-predmet.ceremonija')),
        findsOneWidget,
      );
      final after = await repo.getPredmet(id);
      expect(after.ime, before.ime);
      expect(after.prezime, before.prezime);
      expect(after.status, before.status);
      expect(after.brojPredmeta, before.brojPredmeta);
      expect(after.datumKreiranja, before.datumKreiranja);
      expect(tester.takeException(), isNull);
    },
  );

  for (final viewport in const [
    (TargetPlatform.android, Size(390, 844)),
    (TargetPlatform.android, Size(1280, 900)),
    (TargetPlatform.windows, Size(1200, 900)),
  ]) {
    testWidgets('help header fits ${viewport.$1} at ${viewport.$2.width}px', (
      tester,
    ) async {
      tester.view.physicalSize = viewport.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: viewport.$1),
          home: Scaffold(
            appBar: AppBar(
              title: const OpcHelpTitle(
                title: Text(
                  'DUGAČAK NAZIV EKRANA',
                  overflow: TextOverflow.ellipsis,
                ),
                chapterId: 'settings.catalog',
              ),
              actions: [
                IconButton(
                  tooltip: 'Postojeća radnja',
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('opc-help-button-settings.catalog')),
        findsOneWidget,
      );
      expect(find.byTooltip('Postojeća radnja'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsOneWidget);
}
