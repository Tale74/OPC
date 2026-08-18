# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Report

## Result

`ANDROID PREDMET LIFECYCLE / REFERENTIAL PARITY DEFECT PROVEN — BOUNDED ANDROID CORRECTION SUCCESSOR REQUIRED — READY FOR LOGOS REVIEW`

The current-tip Android test-lane acceptance was stopped at the authenticated setup boundary. The connected LGN LX1 device and the Android test APK were usable, but completion of first-run setup reproduced an Android-specific database-initialization failure. No production correction was made.

## Baseline and protected surfaces

- Branch: `task/OPC-RR011-ANDROID-PHYSICAL-PARITY-ACCEPTANCE`
- HEAD / published base: `e4735e8896ca91f154eb21f78ba138532dcb9a0c`
- Initial and final worktree: clean apart from the RR-011 documentation/control changes listed in the review index.
- Windows canonical database SHA-256 (pre/post): `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` (unchanged).
- `windows/runner/main.cpp` SHA-256: `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863` (unchanged).
- SOURCE inventory remains `337 rows × 38 columns`; completeness ledger remains 37 rows.
- SCENARIO, production source, tests, schema/migrations, dependencies, platform behavior and private data were not modified.

## Device and build identity

- Device: `LGN LX1` / model `LGN_LX1`
- Android: 15 / API 35 / `android-arm64`
- ADB endpoint: `192.168.100.74:38765`; state `device`
- Flutter target: `LGN LX1 (mobile)`
- Package: `com.tale.opc_v4`, version `4.0.0`, version code `1`
- Disposable lane: `BUILD_VARIANT=ANDROID_TEST`, database name selected by existing configuration: `opc_v4_android_test`
- Build command: `flutter build apk --release --no-pub --dart-define=BUILD_VARIANT=ANDROID_TEST`
- Build elapsed: `1358.019 s` wrapper elapsed; Gradle reported `1347.1 s`
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- APK SHA-256: `48C3DBA1EF52E84755FB08B9BB3696F67233B292EA2BDF94B42F9E9054076364`
- APK size: `78,403,503` bytes
- APK install: `adb install -r` completed with `Success`; no uninstall, clear, reset or database mutation was used. `am force-stop` was used only to establish a clean launch baseline and is not acceptance evidence.

## Runtime evidence

1. The application launched successfully on the physical Android target and displayed the expected first-launch administrator flow (`Korak 1 od 2 — Administrator`).
2. A non-personal disposable test name was entered. The owner entered the PIN privately on-device; the PIN was neither requested nor captured.
3. The owner-authorized `POTVRDI` action was invoked through the visible control.
4. The flow then displayed the persistent error:

   `OPC database schema mismatch: database has user_version 0 but already contains table "app_podesavanja"; automatic creation is unsafe`

   The error remained visible in the `Korak 2 od 2 — Postavite PIN` view and the setup could not advance to authenticated main state. The same test lane had also shown a prior unique-index creation error during an earlier setup attempt; that transient observation is retained as evidence but is not a separate control classification.
5. Because authenticated main state was not reached, no PREDMET lifecycle, hard-delete, provenance/snapshot cleanup, replacement, backup/restore or Android background/relaunch acceptance was executed. No unsafe direct database mutation was attempted.

## Decision and bounded successor

This is a reproducible Android-specific current-tip test-lane initialization/schema-version failure at the first-run setup boundary. RR-011 is therefore `DEFECT PROVEN`, not PASS and not merely an evidence gap.

Exactly one successor is retained:

`Android test-lane database initialization/schema-version correction + physical RR-011 re-acceptance`

The successor must establish a safe disposable database lane, preserve the existing production lane and canonical Windows database, then repeat the complete RR-011 physical acceptance. RR-008 semantics, SCENARIO, migration/recovery, JSON/database architecture and all unrelated successors remain unchanged.

## Control validation

- CROSS-PHASE CONTINUITY CHECK: PASS (RR-005 and RR-010 remain closed; RR-008 preserved; no unrelated successor removed).
- SOURCE COVERAGE CHECK: PASS (`337 × 38` authority inventory unchanged).
- ORPHAN/GAP SCAN: PASS (zero orphan control items; one concrete RR-011 successor).
- FORWARD-ACTION OWNERSHIP CHECK: PASS (no successor-less defect or inconclusive outcome; active Phase 5 successors remain `0`).
- `git diff --check`: PASS.

No commit or push was performed. No implementation or Phase 5 work began.
