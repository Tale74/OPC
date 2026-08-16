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

### Validation-sequence correction

The predecessor handoff built Windows and Android artifacts before a demonstrated full-suite Flutter gate. That was a validation-sequence violation: the artifacts were diagnostic/preliminary and are not treated as the final validation artifacts for this continuation.

For the preceding validation continuation, the owner issued a one-time decision not to create new builds when the required full analyze and full test were green. That decision has now been superseded by an explicit owner instruction to create new final builds from the clean, post-gate source HEAD below. The superseding instruction applies only to this final build continuation.

The corrected sequence was:

1. full `flutter analyze` — PASS, `No issues found!`;
2. full `flutter test --machine --concurrency=1 --no-pub` — PASS, authoritative JSON `done.success=true`;
3. no new build, because both required gates were green under the owner decision.

The following focused checks passed after the correction:

- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "SCENARIO module opens with base package and scenario sections"` — PASS.
- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "SCENARIO cards and preview remain bounded on narrow width"` — PASS.
- `flutter test --no-pub test/scenario_module_screen_test.dart --plain-name "legacy partial block is hidden and applied scenario is PREDMET scoped"` — PASS.
- `flutter test --no-pub test/iriu_catalog_display_name_resolution_test.dart` — PASS (11 tests).
- `flutter test --no-pub test/scenario_editable_business_policy_test.dart test/scenario_module_repository_test.dart` — PASS (11 tests).
- full `flutter analyze` rerun after the validation correction — PASS: `No issues found!`.

Full machine-readable evidence:

- Evidence: `C:\Projekti\OPC\OPC v.1\RUNTIME\OPC_SCENARIO_RESPONSIVE_CARD_UI_RUNTIME_CORRECTION_FULL_FLUTTER_TEST_MACHINE_FINAL_20260815.jsonl`
- Command: `flutter test --machine --concurrency=1 --no-pub`
- `done.success`: `true`
- total `testDone`: `507`
- failures: `0`
- skips: `10`
- JSON parse errors: `0`

The first full run reached 500 successful test completions but never emitted `done.success`; it was correctly classified as NOT PASS. Root cause was a test-isolate lifecycle conflict: multiple widget tests in one file created sequential `NativeDatabase.memory()` instances, and the next test blocked at `createTestDatabase()`. The narrow responsive and bounded open-PREDMET tests were moved to isolated test files; the historical inline test is retained as an explicit skipped characterization. The split validation passed, and the corrected full run then reached `done.success=true`.

The final build continuation used the already-proven green gates above without rerunning analyze/test because source and test state were unchanged. The owner then explicitly authorized new final builds from source HEAD `4072ddee3af500f351a661134de9285bd716e763`, run strictly in this order: Windows release, then Android release. These artifacts are distinct from the earlier pre-gate diagnostic build outputs.

Final build evidence from source/build SHA `4072ddee3af500f351a661134de9285bd716e763`:

- Windows: `flutter build windows --release` — PASS.
  - `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release\OPC.exe`
  - SHA-256: `DCB784346DA415ED19FE6AD458E5917A1E83F5F58F2363A8400E68F1F5115A7C`
  - `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release\data\app.so`
  - SHA-256: `FFEA8633FBB12B1F14AD4C78BC5D53C2F928C5CFC02FDC11EF7F45AE031690B1`
- Android: `flutter build apk --release` — PASS.
  - APK: `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`
  - SHA-256: `D3364C46438B4FB165FD735938BB3DC0E1889F178B95F658F03676E392C6B514`
  - Size: `78,403,503` bytes (74.8 MB reported by Flutter)
  - Build timestamp: `2026-08-16` (filesystem timestamp recorded at artifact verification)

Build success is artifact evidence only; it does not establish Windows or Android interactive runtime acceptance.

## WINDOWS RELEASE BUILD HYGIENE

An independent read-only inventory of the pre-clean release directory found 49 files. Twelve were not part of the distributive bundle: eleven same-payload copies named `sqlite3.dll.*-stale` (`final-suite-stale`, `fullsuite-stale`, `pair-stale`, `pair2-stale`, `pair3-stale`, `pair4-stale`, `sequential-stale`, `split-stale`, `split2-stale`, `stale`, and `validation-stale`) plus a top-level `native_assets.json`. Every stale SQLite copy was 1,665,536 bytes, had timestamp `2026-08-15T15:53:07+02:00`, and SHA-256 `15B1E7BEE3FEDE1C90EAB94C7EB9BB36AE29C33AA2D61BDC0DE546326AE6C089`, identical to the active `sqlite3.dll` payload. They were test/diagnostic snapshot copies, not runtime dependencies.

Root-cause evidence: no tracked source, test, build script, or Git history reference generates any of these names; the names and common timestamp correlate with the earlier full-suite/split/pair diagnostic period, while the controlled clean build below never emitted them. Therefore `flutter build windows --release` does not generate these files and the pre-clean build had only retained external diagnostic/stale files in its output directory. The top-level `native_assets.json` was likewise absent from the clean output and has no tracked project reference; the runtime bundle uses `data/flutter_assets/NativeAssetsManifest.json` instead.

The contaminated build output was removed with `flutter clean` (build-output cleanup only), then rebuilt from the unchanged source payload validated at `4072ddee3af500f351a661134de9285bd716e763` (current HEAD differs only by the documentation commit). The clean Windows release build completed PASS. The final release directory contains 37 files in 10 standard Flutter/OPC subdirectories, with zero test-only, debug, diagnostic, backup, sentinel, state, temporary, or stale artefacts.

Final clean-bundle integrity:

- `OPC.exe` — SHA-256 `9640AF33967BFAB4E81A8F738A69BF816C129BFA48863AC1CA4E0024C47AC0A8`
- `data/app.so` — SHA-256 `FFEA8633FBB12B1F14AD4C78BC5D53C2F928C5CFC02FDC11EF7F45AE031690B1`
- `sqlite3.dll` — SHA-256 `15B1E7BEE3FEDE1C90EAB94C7EB9BB36AE29C33AA2D61BDC0DE546326AE6C089`

`sqlite3.dll` is the expected runtime DLL and was not replaced or corrupted by a test artefact. No full analyze/test rerun was required because tracked source/test content remained unchanged.

`WINDOWS RELEASE BUNDLE HYGIENE — PASS`

The three active SCENARIO widget tests pass when isolated. Running them together on this Windows Flutter tester instance remained a harness/lifecycle hang; it produced no assertion failure and was not represented as a product PASS. The test teardown now closes nested preview, SCENARIJI and PREDMET dialogs explicitly.

## WINDOWS RUNTIME ACCEPTANCE

`WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — NOT PROVEN`

No owner-executed Computer Use/runtime session is available in this task to prove wide and narrow Windows interactive behavior. Build or widget-test success must not be promoted to Windows interactive PASS.

## ANDROID NARROW ACCEPTANCE

`ANDROID NARROW ACCEPTANCE — NOT PROVEN`

The narrow-width widget test is a bounded layout regression check, not an Android device/emulator acceptance session. Android interactive acceptance remains open until owner evidence is executed.

## FINAL STATUS

Source correction and automated evidence are documented. Interactive runtime acceptance remains explicitly unproven for both Windows and Android and requires owner execution.
