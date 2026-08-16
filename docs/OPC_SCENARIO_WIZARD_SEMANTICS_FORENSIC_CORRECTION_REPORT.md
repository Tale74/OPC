# OPC SCENARIO Wizard Semantics Forensic Correction Report

## HANDOFF

- Task: `OPC — SCENARIO WIZARD SEMANTICS FORENSICS AND PREVIEW TERMINOLOGY CORRECTION`
- Branch: `task/OPC-SCENARIO-WIZARD-SEMANTICS-FORENSIC-CORRECTION`
- Base SHA: `2da90e78c26f7de467e073d07280c4c70d2a8109`
- Final source SHA: `e2ad06ec8969c83dd52a585c78e899b29a199f86`
- Documentation SHA: recorded in the final Git handoff after this report commit.
- Scope: source-grounded classification of the wizard-like display and exactly two locked preview-heading corrections.

## OBSERVED PRODUCT BEHAVIOR

Owner Windows runtime evidence showed a wizard-like presentation with the labels
`1 USLOVI`, `2 STAVKE`, `3 PREGLED`, and `4 ČUVANJE`, while the owner could not
reproduce corresponding wizard navigation or stage functionality. The evidence
establishes the visual symptom only. It does not establish root cause.

Runtime evidence reviewed:

- `C:\Projekti\OPC\OPC v.1\RUNTIME\Scenario1.PNG`
- `C:\Projekti\OPC\OPC v.1\RUNTIME\Scenario2.PNG`
- predecessor report `docs/OPC_SCENARIO_LIGHT_RESPONSIVE_UI_POLISH_REPORT.md`

The screenshots remain runtime-behavior evidence, not owner authority for source
semantics or root cause.

## WIZARD FORENSICS

### Rendering implementation

The four labels were rendered by private widget `_WizardProgress` in
`lib/features/predmeti/core_v2/scenario/scenario_module_screen.dart`.
It returned a `Wrap` containing four plain `Chip` widgets:

```text
1 USLOVI
2 STAVKE
3 PREGLED
4 ČUVANJE
```

The chips had no `onTap`, `onPressed`, `onDeleted`, selection callback or
navigation callback. They were not buttons, tabs, a `Stepper`, or a progress
controller.

### Interaction and state authority

Source inspection found no `PageController`, `TabController`, `Stepper` state,
`currentStep`, page index, route index, stage enum or wizard state machine for
this display. `_ScenarioDialogState` owns ordinary editor state (`_condition`,
`_consequences`, `_error`) inside one `AlertDialog` and one
`SingleChildScrollView`/`Column`.

The editor is therefore one continuous form. The visible sections are the
condition picker, selected/available item lists, and final save/cancel actions.
The `PREGLED` action belongs to scenario result cards and opens a separate
preview dialog; it is not a step transition from the four chips.

### Actual meaning of each numbered label

| Label | Proven meaning |
| --- | --- |
| `1 USLOVI` | Static visual sequence label; the form contains a condition subsection. |
| `2 STAVKE` | Static visual sequence label; the form contains selected/available item subsections. |
| `3 PREGLED` | Static visual sequence label; no direct navigation from the chip exists. Preview is a separate result-card action. |
| `4 ČUVANJE` | Static visual sequence label; saving is the final `SAČUVAJ NOVI SCENARIO` action, not a distinct screen/stage. |

### Persistence semantics

Condition and consequence edits remain local dialog state until validation passes.
`_save` rejects an incomplete condition, then returns a draft to
`_dodajIliIzmeniScenario`; only after that does
`ScenarioModuleRepository.saveDefinition(...)` persist the scenario. There is
no separate user-visible “ČUVANJE” stage.

### Controlled behavior

The focused narrow widget test opened the scenario management flow and preview,
then opened `NOVI SCENARIO`. It verified:

- preview contains `USLOVI SCENARIJA` and `PRIMENJENE STAVKE`;
- old preview headings are absent;
- the new-scenario editor contains no numbered chips and no `Chip` widgets;
- the ordinary `USLOVI` and `DODATNE STAVKE SCENARIJA` editor sections remain;
- no exception occurs.

## FORENSIC CLASSIFICATION

Primary classification: **C — STATIC VISUAL SEQUENCE**.

The four labels were purely presentational and did not track or navigate real
state. The apparent wizard affordance was caused by a static `Wrap` of numbered
chips placed above a continuous editor. This is not a broken functional wizard;
no wizard functionality was implemented or promised by the source path.

## CORRECTION

The minimum authorized presentation correction was applied:

1. Removed the static `_WizardProgress` chip sequence from the new-scenario
   editor. No wizard functionality was invented.
2. In `PREGLED SCENARIJA`, changed exactly:
   - `USLOVI PRIMENE` → `USLOVI SCENARIJA`
   - `DODATNE STAVKE SCENARIJA` → `PRIMENJENE STAVKE`

No scenario matching, package membership, package order, status, conditions,
database, JSON, persistence, PREDMET or IRiU behavior was changed.

## VALIDATION

- Focused test:
  `flutter test --no-pub test/scenario_module_narrow_responsive_test.dart --concurrency=1`
  — PASS, 1 test.
- Full analyzer:
  `flutter analyze --no-pub` — PASS, `No issues found!` (51.8 s).
- Full machine-readable suite:
  `flutter test --machine --concurrency=1 --no-pub` — PASS.
- Evidence:
  `C:\Projekti\OPC\OPC v.1\RUNTIME\OPC_SCENARIO_WIZARD_SEMANTICS_FULL_FLUTTER_TEST_MACHINE_FINAL_20260816.jsonl`
- Terminal summary: `done.success=true`.
- `testDone=507`, failures `0`, skips `10`, JSON parse errors `0`.
- The full suite completed naturally in approximately 21 minutes; no artificial
  timeout or interruption was used.

## BUILDS AND BUNDLE HYGIENE

Builds were started only after the final green analyzer and full machine-test
gates.

### Windows

- `flutter clean` — build-output cleanup only.
- `flutter build windows --release` — PASS (`898.8 s`).
- Final release directory:
  `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release`
- Final inventory: 37 files; no test-only, debug, diagnostic, stale,
  temporary, backup, restore-point or top-level retained native-assets files.
- `OPC.exe` SHA-256:
  `6AEC8A2BB3DCE09D7823BCE99A725F711B2750DAB6E0A5D9C09E985BEE1A788A`
- `data/app.so` SHA-256:
  `9ED70AA31620DD3000D1282812369B2B356F95C12A0B74737E931465BAF37A52`
- `sqlite3.dll` SHA-256:
  `15B1E7BEE3FEDE1C90EAB94C7EB9BB36AE29C33AA2D61BDC0DE546326AE6C089`
- `sqlite3.dll` is the expected runtime payload; no test replacement was found.

### Android

- `flutter build apk --release` — PASS.
- Final APK:
  `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`
- SHA-256:
  `0396574989CB4C1349B6D3B9607A9E3BEFF20701416F637728598343A207A2F1`
- Size: `78,403,503` bytes (`74.8 MB`).
- Final timestamp: `2026-08-16T12:12:45.1847145+02:00`.
- The first cold Android invocation exceeded the terminal wrapper while Gradle
  continued; a warm repeat completed with exit code `0` and the PASS summary
  above. No source/test tracked file changed during either build.

## RUNTIME ACCEPTANCE

- `WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — NOT PROVEN`
- `ANDROID NARROW INTERACTIVE ACCEPTANCE — NOT PROVEN`

Build success and widget tests do not constitute interactive runtime acceptance.

## BUSINESS SAFETY

- scenario matching unchanged;
- OSNOVNI/SCENARIO package membership and order unchanged;
- PREDMET unchanged;
- database schema/data unchanged;
- JSON import/export unchanged;
- FINANSIJE unchanged;
- no `Pomoć` mechanism introduced;
- no licensing/entitlement policy changed.

## OPC MANIFEST CHECK — TASK START

- Manifest read: yes
- Task class: forensic audit / narrowly scoped implementation / documentation
- Core purpose preserved: yes
- PREDMET meaning affected: no
- Database ownership affected: no
- JSON transfer affected: no
- Windows/Android parity affected: presentation verification only
- Future Web Pristup affected: no
- Terminology drift risk: yes, limited to the two locked preview headings
- Implementation allowed: only within the proven classification-C presentation scope

## OPC MANIFEST COMPLIANCE — TASK END

- Manifest compliance checked: yes
- Core purpose preserved: yes
- PREDMET meaning preserved: yes
- Database ownership preserved: yes
- Windows/Android parity preserved: yes
- Existing JSON transfer preserved: yes
- Terminology preserved except the two owner-locked preview corrections: yes
- Future Web Pristup not blocked: yes
- Source changes within scope: yes

## FINAL VERDICT

`PASS WITH WINDOWS INTERACTIVE RUNTIME ACCEPTANCE NOT PROVEN AND ANDROID NARROW INTERACTIVE ACCEPTANCE NOT PROVEN`

The wizard-like appearance was proven to be a static visual sequence, not a
partially implemented wizard. The false affordance was removed without adding
new navigation, and the two locked preview terminology corrections were applied.
