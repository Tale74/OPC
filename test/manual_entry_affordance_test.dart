import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/widgets/manual_entry_affordance.dart';

void main() {
  testWidgets('empty enabled fields invite input and clear after entry', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    const key = Key('manual-entry-field');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManualEntryAffordance(
            controller: controller,
            enabled: true,
            child: TextFormField(
              key: key,
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Naziv',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
    );

    Theme fieldTheme() => tester.widget<Theme>(
      find.ancestor(of: find.byKey(key), matching: find.byType(Theme)).first,
    );

    final colors = Theme.of(tester.element(find.byKey(key))).colorScheme;
    expect(
      fieldTheme().data.inputDecorationTheme.fillColor,
      colors.secondaryContainer,
    );
    expect(
      fieldTheme().data.inputDecorationTheme.enabledBorder!.borderSide.color,
      colors.primary,
    );

    await tester.enterText(find.byKey(key), 'Groblje');
    await tester.pump();
    expect(
      fieldTheme().data.inputDecorationTheme.fillColor,
      Colors.transparent,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManualEntryAffordance(
            controller: controller,
            enabled: false,
            child: TextFormField(
              key: key,
              controller: controller,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Naziv',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      fieldTheme().data.inputDecorationTheme.fillColor,
      Colors.transparent,
    );
  });
}
