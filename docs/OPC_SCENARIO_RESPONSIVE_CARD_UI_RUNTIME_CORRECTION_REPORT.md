# OPC SCENARIO Responsive Card UI Runtime-Acceptance Correction Report

## DOCUMENTATION / MANIFEST COMPLIANCE

- Task: `OPC — SCENARIO Responsive Card UI Runtime-Acceptance Correction and Terminology Recovery`
- Dedicated branch: `task/OPC-SCENARIO-RESPONSIVE-CARD-UI-RUNTIME-CORRECTION`
- Predecessor baseline: `0bb1261540053a7fc1c9327dd78bc8ceae357064`
- Business-kernel scope: unchanged. IRiU package authority, PREDMET truth, snapshots, manual rows, FINANSIJE, 1.008 MAP definitions and canonical DB contracts were not reimplemented.
- This report supersedes only the predecessor UI/runtime-acceptance conclusion; it does not rewrite the predecessor historical evidence.

## PREDECESSOR CLAIM / IMPLEMENTATION

The predecessor implementation introduced SCENARIO cards and open-PREDMET semantics, but its source/test state was not sufficient to establish the requested compact responsive architecture in the owner runtime. The predecessor runtime acceptance was therefore not treated as proof of the final UI.

## OWNER RUNTIME OBSERVATION

Owner-provided Windows evidence (Scenario1.PNG–Scenario11.PNG) showed the actual failure that the predecessor report did not close:

- SCENARIJI policy/filter content remained permanently expanded on the main page.
- OTVORENI PREDMETI was pushed below the expanded content.
- Selecting a PREDMET appended a long inline detail block instead of opening a bounded detail context.
- The preview exposed a long technical/concatenated summary and technical condition wording.
- The visible legacy label `Spremanje pokojnika` remained in the owner runtime.

These screenshots are current owner runtime-behavior evidence, not root-cause authority by themselves. They supersede the predecessor UI acceptance observation while preserving its historical record.

## ACCEPTANCE CORRECTION

The required correction is a compact closed-card main page with bounded drill-in contexts:

1. OSNOVNI PAKET, SCENARIJI, NOVI SCENARIO and OTVORENI PREDMETI are concise functional cards.
2. SCENARIJI policy/filter/editor content opens in a bounded responsive dialog.
3. Open PREDMET selection opens a bounded list/detail dialog; detail is not appended to the main page.
4. Scenario preview is concise and contains no technical `SVE`, `nije DA`, or `≠` wording.
5. The layout adapts to narrow Windows/Android widths without trailing-control overflow.
6. `Spremanje pokojnika` is not emitted as the current user-facing catalog/editor label; stable IDs and persisted historical snapshot values remain unchanged.

## ROOT-CAUSE ANALYSIS

The observed failure was architectural presentation state, not an IRiU ordering or business-kernel failure. The main route rendered management content inline and reused the page as the PREDMET detail surface. Terminology resolution also allowed a legacy current-facing label to remain visible in editor/policy projections. No evidence establishes that a persisted historical snapshot should be rewritten; the correction is presentation-only.

## IMPLEMENTED CORRECTION

- Replaced the main inline SCENARIO management block with four compact adaptive launcher cards.
- Added bounded `SCENARIJI` management dialog and bounded open-PREDMET list/detail dialog.
- Added narrow-width card layout that stacks the action below the title/subtitle instead of overflowing a `ListTile` trailing slot.
- Added a concise PREDMET case summary inside the bounded detail context.
- Reworked preview title and conditions to short business-facing labels while retaining consequence data and order.
- Added presentation-only terminology recovery to the current catalog/editor projections: `SPREMANJE_POKOJNIKA` displays as `Spremanje preminulog lica`. No database write or snapshot rewrite is performed.
- Preserved the existing scenario repository, reconciliation service, snapshot, provenance and IRiU contracts.

## VALIDATION EVIDENCE

The following focused checks passed after the correction:

- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "SCENARIO module opens with base package and scenario sections"` — PASS.
- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "SCENARIO cards and preview remain bounded on narrow width"` — PASS.
- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "legacy partial block is hidden and applied scenario is PREDMET scoped"` — PASS.
- `flutter test --no-pub test/iriu_catalog_display_name_resolution_test.dart` — PASS (11 tests).
- `flutter test --no-pub test/scenario_editable_business_policy_test.dart test/scenario_module_repository_test.dart` — PASS (11 tests).
- `flutter analyze` — PASS: `No issues found!`.
- `flutter build windows --release` — PASS (`build/windows/x64/runner/Release/OPC.exe`).
- `flutter build apk --release` — PASS (`build/app/outputs/flutter-apk/app-release.apk`, 74.8 MB).

The three active SCENARIO widget tests pass when isolated. Running them together on this Windows Flutter tester instance remained a harness/lifecycle hang; it produced no assertion failure and was not represented as a product PASS. The test teardown now closes nested preview, SCENARIJI and PREDMET dialogs explicitly.

## WINDOWS RUNTIME ACCEPTANCE

`WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — NOT PROVEN`

No owner-executed Computer Use/runtime session is available in this task to prove wide and narrow Windows interactive behavior. Build or widget-test success must not be promoted to Windows interactive PASS.

## ANDROID NARROW ACCEPTANCE

`ANDROID NARROW ACCEPTANCE — NOT PROVEN`

The narrow-width widget test is a bounded layout regression check, not an Android device/emulator acceptance session. Android interactive acceptance remains open until owner evidence is executed.

## FINAL STATUS

Source correction and automated evidence are documented. Interactive runtime acceptance remains explicitly unproven for both Windows and Android and requires owner execution.
