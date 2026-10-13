import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opc_v4/core/widgets/opc_page_chrome.dart';

void main() {
  testWidgets('narrow Android stacks identity and keeps only tools in chrome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          appBar: OpcPageChrome(
            narrowAndroid: true,
            identity: const Text('TEST IDENTITY'),
            status: const Chip(label: Text('OTVOREN')),
            primaryActions: [
              FilledButton(onPressed: () {}, child: const Text('PRIMARNO')),
            ],
            tools: [
              IconButton(
                tooltip: 'Alat',
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.toolbarHeight, 84);
    expect(find.text('TEST IDENTITY'), findsOneWidget);
    expect(find.text('OTVOREN'), findsOneWidget);
    expect(find.text('PRIMARNO'), findsNothing);
    expect(find.byTooltip('Alat'), findsOneWidget);
  });

  testWidgets('wide chrome keeps status and primary actions on the AppBar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.windows),
        home: Scaffold(
          appBar: OpcPageChrome(
            title: const Text('ROUTE TITLE'),
            identity: const Text('TEST IDENTITY'),
            status: const Chip(label: Text('ZATVOREN')),
            primaryActions: [
              FilledButton(onPressed: () {}, child: const Text('IZMENI')),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, isNull);
    expect(find.text('TEST IDENTITY'), findsOneWidget);
    expect(find.text('ROUTE TITLE'), findsOneWidget);
    expect(find.text('ZATVOREN'), findsOneWidget);
    expect(find.text('IZMENI'), findsOneWidget);
  });

  testWidgets(
    'Android wide keeps long identity, status and actions at enlarged text scale',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            appBar: OpcPageChrome(
              identity: const Text(
                'PORODICA I PRIJATELJI — SVETOZAR PRŠIĆ, DUGAČAK IDENTITET PREDMETA',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              status: const Chip(label: Text('OTVOREN')),
              primaryActions: [
                FilledButton(onPressed: () {}, child: const Text('SAČUVAJ')),
              ],
              tools: [
                IconButton(
                  tooltip: 'Više',
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('OTVOREN'), findsOneWidget);
      expect(find.text('SAČUVAJ'), findsOneWidget);
      expect(find.byTooltip('Više'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
