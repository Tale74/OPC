# OPC — SCENARIO FINAL CROSS-PLATFORM SPACING CORRECTION

## Final handoff

- Branch: `task/OPC-SCENARIO-FINAL-SPACING-CORRECTION-BEFORE-LOCK`
- Predecessor/base SHA: `0cbff68884378f54cda94bb3a91a19636df926fe`
- Final source/test SHA: `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
- Documentation SHA: this report's publication commit
- Scope: one authorized spacing correction before module lock. No module lock is declared here.

## Owner scope and protected behavior

The owner-approved finding was limited to insufficient vertical separation between the new-scenario `USLOVI` heading and the first `UZROK SMRTI` condition field. The wizard chips remain removed; `USLOVI SCENARIJA`, `PRIMENJENE STAVKE`, scenario semantics, business ordering, persistence, and all other UI/business behavior are unchanged.

## Source finding and correction

Source inspection located the new-scenario heading in `_ScenarioDialogState.build` at `scenario_module_screen.dart:2217`, immediately followed by `_BusinessConditionPicker`; its first field is `UZROK SMRTI` (`:2688`). There was no local spacing widget between those two elements. This source/layout relationship, rather than screenshot naming, is the proven cause.

The only production correction is a keyed `const SizedBox(height: 8)` (`scenario-new-condition-section-gap`) rendered only for a new scenario, between the `USLOVI` heading and `_BusinessConditionPicker`. The focused narrow responsive test now asserts that the gap exists and is positive; it does not hard-code a brittle pixel golden.

## Validation sequence and results

The required order was executed:

1. Focused test: `flutter test --no-pub test/scenario_module_narrow_responsive_test.dart --concurrency=1 --reporter expanded` — PASS (`+1`).
2. Full `flutter analyze --no-pub` — PASS, `No issues found!` (a first orchestration wrapper expired while the analyzer child continued; a fresh run completed conclusively in 56.9 s).
3. Full machine suite: `flutter test --machine --concurrency=1 --no-pub` — PASS, JSON `done.success=true`, `testDone=507`, failures `0`, skips `10`, parse errors `0`.
4. Final Windows release build.
5. Final Android release APK build.

No source/test tracked files changed during validation or builds beyond the two files in the source commit above.

## Windows release artifact and hygiene evidence

The first clean Windows attempt compiled but failed only in CMake install because a stale `.dart_tool/flutter_build/install_code_assets.stamp` caused Flutter to skip creation of `build/native_assets/windows`; direct CMake replay identified the missing path. The exact generated `.dart_tool/flutter_build` cache was removed and the Windows build was rerun. This was build-output/cache cleanup, not a source or business fix.

The rerun passed: `√ Built build\\windows\\x64\\runner\\Release\\OPC.exe` (331.4 s). The final release directory contains 37 files, all expected Flutter/OPC runtime or asset files; no test-only, debug/diagnostic, stale/temp, backup/restore, sentinel/state, or hang-diagnostic artifacts were found. `NativeAssetsManifest.json` declares the Windows sqlite asset and `sqlite3.dll` is present.

- Release directory: `build/windows/x64/runner/Release`
- `OPC.exe`: SHA-256 `A187FE4BC96FF6D36AAFFCFF141D107CCBA9DBC437374B8A7F5937048C786D2B`
- `data/app.so`: SHA-256 `DEA56826DB000A0CD98B33C3660CCA8E45C9E23EC60CCCE7BBDF002653B85625`
- `sqlite3.dll`: SHA-256 `15B1E7BEE3FEDE1C90EAB94C7EB9BB36AE29C33AA2D61BDC0DE546326AE6C089`

## Android release artifact

The final warm release invocation completed with `√ Built build\\app\\outputs\\flutter-apk\\app-release.apk (74.8MB)` after the initial long Gradle lifecycle completed. The final APK is:

- Path: `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`
- SHA-256: `A8EABB887B4EDFAE232B7486346472DD68CF3E9F0010650DC6841342B6017C50`
- Size: `78,403,503` bytes (74.8 MB)
- Timestamp: `2026-08-16T16:44:00.9798295+02:00`

## Runtime acceptance and verdict

- Windows interactive runtime: inherited owner baseline PASS; this task did not perform a new interactive runtime session.
- Android narrow runtime: the owner must still confirm that the spacing finding is resolved after this correction; build success is not runtime acceptance.

Final status: **IMPLEMENTED — MODULE LOCK PENDING OWNER RUNTIME ACCEPTANCE**. This report does not declare the SCENARIO module locked.

