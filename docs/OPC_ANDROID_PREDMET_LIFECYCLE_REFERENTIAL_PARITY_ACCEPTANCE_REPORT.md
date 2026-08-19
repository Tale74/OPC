# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Report

## Result

`RR-011 PHYSICAL ACCEPTANCE INCOMPLETE — ANDROID_TEST EXECUTION DEVICE OFFLINE — BOUNDED SUCCESSOR RETAINED — READY FOR LOGOS REVIEW`

The Android initialization defect was corrected by removing automatic business-KATALOG creation from fresh lifecycle paths while preserving existing-data repair and normalization. The fresh disposable Android lane reaches the authenticated main screen, and prior accepted PRODUCTION release evidence remains preserved. The current execution wave formalized the inspectable `ANDROID_TEST` lane and built its debug artifact successfully, but the full RR-011 referential/provenance, replacement, bounded backup/restore and direct Android DB-integrity evidence set could not begin because the designated device was ADB `offline`; reconnect to `192.168.100.74:38765` failed with Windows error `10060`.

## Baseline and protected surfaces

- Branch: `task/OPC-RR011-ANDROID-TEST-LANE-INITIALIZATION-CORRECTION`
- Published RR-011 correction commit: `91a0b6f6567966d15d6d6c5d93430594f207aaf5`; parent: `9a25c114e4f01175c871cf4f8383a3b0ca69d478`.
- Windows canonical database SHA-256 pre/post: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` (unchanged).
- `windows/runner/main.cpp` SHA-256: `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863` (unchanged).
- SCENARIO, database schema/migrations, dependencies, Windows/Android platform behavior and private data were not changed.

## Evidence-source separation

PRODUCTION remains authoritative for release APK identity, packaging, first-admin setup, authentication and end-user runtime behavior. The formally accepted `ANDROID_TEST` lane is the dedicated synthetic, disposable and inspectable physical structural-acceptance environment. Because the representativeness audit proved shared `AppDatabase`, schema version 27, migrations, repair, RR-005 cleanup, PREDMET/IRiU/SCENARIO persistence and JSON backup/restore authority, direct structural database evidence from `opc_v4_android_test` may complete the remaining RR-011 invariants without weakening PRODUCTION protection. No owner data, credentials, owner backup or private export may enter that lane.

The existing `ANDROID_TEST` debug artifact built successfully with `flutter build apk --debug --no-pub --dart-define=BUILD_VARIANT=ANDROID_TEST` (natural completion, 839.3 seconds). It is package `com.tale.opc_v4`, `debuggable=true`, signed by the accepted Android Debug certificate (`787B56DCD4650B4B33EDE6CC7A32C09CC5A4E45AB006E58064B728652A8F531A`). Physical installation and `run-as` inspection could not begin because the wireless device entered ADB `offline`; reconnect to `192.168.100.74:38765` failed with error `10060`. No package, database or device data was mutated.

## Correction boundary

- `onCreate` no longer writes business KATALOG rows.
- Migration paths below schema 22 no longer synthesize business KATALOG rows; existing rows remain authoritative.
- `beforeOpen` no longer seeds an empty catalog; existing repair/normalization and the stable-ID uniqueness index remain active.
- The retained seed helper is unused legacy forensic code; no production lifecycle path invokes it.
- Test-only scenarios now call an explicit fixture helper. The default test database remains empty.

## Automated evidence

- Focused fresh/reopen/existing-catalog/unique-index contract tests: PASS (4 tests).
- KATALOG/stock affected group: PASS (45 tests).
- Migration/recovery suite: PASS (41 tests).
- JSON/full-backup/RR-005 group: PASS (33 tests).
- Scenario targeted groups: PASS.
- `flutter analyze --no-pub`: PASS — after the local REVIEW handoff was relocated outside SOURCE, the repository-wide analyzer completed naturally with exit code `0` and `No issues found!`; `analysis_options.yaml` remained unchanged and no exclusion or workaround was introduced.
- Full `flutter test --no-pub --concurrency=1`: PASS — natural completion, 426 passed, 10 skipped, 0 failed.
- Windows release build: PASS — `flutter build windows --release`, executed serially after analyzer and full-test PASS.
- Android release build: PASS — `flutter build apk --release`, executed serially after Windows PASS.

## Android physical evidence

- Device: LGN LX1, Android 15/API 35, ADB state `device`; package `com.tale.opc_v4`.
- Accepted release APK SHA-256: `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4`.
- Build identity: default/no-define PRODUCTION (`com.tale.opc_v4`, database `opc_v4_release.sqlite`); this was not the ANDROID_TEST variant.
- Release certificate: Android debug signing certificate, SHA-256 `787B56DCD4650B4B33EDE6CC7A32C09CC5A4E45AB006E58064B728652A8F531A`.
- Fresh disposable lane after uninstall/install showed `Korak 1 od 2 — Administrator`, then `Korak 2 od 2 — Postavite PIN`, and after the owner-entered private PIN plus `POTVRDI`, `OPC — LISTA PREDMETA` with no schema/index error.
- Synthetic PREDMETs `Test_A` and `Test_B` were created and saved through the supported UI. Normal exit confirmation (`Izlaz iz aplikacije` -> `IZAĐI`) was exercised; after relaunch and private owner authentication, `OPC — LISTA PREDMETA` showed both records (`Prikazano 2 od 2`). The final instance was normally exited and force-stopped only after UI close for evidence capture.
- An earlier authorized debug inspection attempt did not produce an APK and remains historical tooling-hang evidence: the Gradle client main thread remained in `SocketInputStream.read`/`DaemonClient.monitorBuild` for approximately 1,850 seconds while the Gradle daemon main thread was in `DaemonStateCoordinator.awaitStop`, worker queues were waiting, no `app-debug.apk` existed, and Gradle output ceased updating at 07:39. A later authorized `ANDROID_TEST` debug build completed successfully and produced the verified inspectable APK; physical installation and inspection were then blocked by the device-offline condition recorded above.
- No personal name, PIN, database copy or private business data was collected.

## Acceptance matrix state

| Area | Status | Evidence / boundary |
|---|---|---|
| Fresh business KATALOG | PASS | Fresh/reopen disposable DB remains empty; no lifecycle seed path writes business rows. |
| Existing KATALOG preservation | PASS | Existing rows survive reopen; repair/normalization and unique stable-ID index preserved. |
| Android setup/authentication | PASS | Clean disposable lane reaches authenticated `OPC — LISTA PREDMETA`. |
| PREDMET create/close/reopen/relaunch | PASS (bounded) | Synthetic `Test_A` and `Test_B` created/saved; normal exit confirmation exercised; release relaunch/authentication returned to `OPC — LISTA PREDMETA` with `Prikazano 2 od 2`. |
| Referential/provenance/snapshot cleanup | INCOMPLETE | Automated contract evidence exists; full physical Android representative-data proof not completed. |
| Replacement and bounded backup/restore | INCOMPLETE | Not executed in this correction wave. |
| Android DB integrity (`user_version=27`, integrity/FK) | INCOMPLETE — DEVICE OFFLINE | Release APK is not debuggable; the later authorized ANDROID_TEST inspection build produced a debuggable APK, but the target device was offline before installation, so no protected sandbox or database copy was accessed. |
| Background/relaunch | PASS (bounded) | Home/background and normal relaunch returned to authenticated main state. |
| Canonical Windows DB / protected source | PASS | Canonical and runner hashes unchanged; no protected implementation surfaces changed. |

## Bounded successor

The automatic initialization defect is closed by this correction. Exactly one bounded successor remains for the uncompleted acceptance evidence:

`Android physical RR-011 referential/backup/DB-integrity acceptance completion`

It must use a disposable lane only, preserve the canonical Windows database, and complete representative provenance/snapshot cleanup, replacement, bounded backup/restore and direct Android integrity evidence. RR-005/RR-010 closed state, RR-008 semantics, SCENARIO and all unrelated successors remain unchanged.

## Control validation

The earlier analyzer attempt and its 845 diagnostics against flattened REVIEW snapshots are retained as superseded historical root-cause evidence only. REVIEW was a local project-boundary contamination issue; it was relocated to the project-root REVIEW directory and the old SOURCE/REVIEW path was removed after equivalence verification. The automated QA PASS does not close the remaining physical referential, backup/restore or direct Android DB-integrity acceptance.

- CROSS-PHASE CONTINUITY CHECK: PASS.
- SOURCE COVERAGE CHECK: PASS (authority inventory unchanged at its published baseline; correction files are covered by the existing control set).
- ORPHAN/GAP SCAN: PASS (zero orphan items; one concrete RR-011 successor).
- FORWARD-ACTION OWNERSHIP CHECK: PASS (no successor-less defect or inconclusive outcome; active Phase 5 successors remain `0`).
- `git diff --check`: PASS.

No commit or push was performed. No Phase 5 work began.
