# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Report

## Result

`RR-011 EMPTY-BUSINESS-KATALOG CORRECTION PASS — PHYSICAL RE-ACCEPTANCE INCOMPLETE — BOUNDED RR-011 SUCCESSOR RETAINED — READY FOR LOGOS REVIEW`

The Android initialization defect was corrected by removing automatic business-KATALOG creation from fresh lifecycle paths while preserving existing-data repair and normalization. The fresh disposable Android lane now completes first-run setup and reaches the authenticated main screen. Physical lifecycle evidence is positive for disposable PREDMET create, normal close, reopen, relaunch and hard-delete, but the full RR-011 referential/provenance, replacement, bounded backup/restore and direct Android DB-integrity evidence set was not completed in this wave.

## Baseline and protected surfaces

- Branch: `task/OPC-RR011-ANDROID-TEST-LANE-INITIALIZATION-CORRECTION`
- HEAD / published base: `9a25c114e4f01175c871cf4f8383a3b0ca69d478`
- Windows canonical database SHA-256 pre/post: `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` (unchanged).
- `windows/runner/main.cpp` SHA-256: `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863` (unchanged).
- SCENARIO, database schema/migrations, dependencies, Windows/Android platform behavior and private data were not changed.

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
- APK SHA-256: `6CA9F6F0C44C195FA1A0950539F0D8CD6968E6366C75CF82181D86884F6FE15C`.
- Fresh disposable lane after uninstall/install showed `Korak 1 od 2 — Administrator`, then `Korak 2 od 2 — Postavite PIN`, and after the owner-entered private PIN plus `POTVRDI`, `OPC — LISTA PREDMETA` with no schema/index error.
- Disposable PREDMET `Test Lice` was created, normally closed to `ZATVOREN`, reopened, relaunched to the authenticated main screen, then permanently deleted through the supported UI. The list returned to `Nema predmeta`.
- No personal name, PIN, database copy or private business data was collected.

## Acceptance matrix state

| Area | Status | Evidence / boundary |
|---|---|---|
| Fresh business KATALOG | PASS | Fresh/reopen disposable DB remains empty; no lifecycle seed path writes business rows. |
| Existing KATALOG preservation | PASS | Existing rows survive reopen; repair/normalization and unique stable-ID index preserved. |
| Android setup/authentication | PASS | Clean disposable lane reaches authenticated `OPC — LISTA PREDMETA`. |
| PREDMET create/close/reopen/hard-delete | PASS (bounded) | Disposable `Test Lice` lifecycle and supported hard-delete completed; list returned empty. |
| Referential/provenance/snapshot cleanup | INCOMPLETE | Automated contract evidence exists; full physical Android representative-data proof not completed. |
| Replacement and bounded backup/restore | INCOMPLETE | Not executed in this correction wave. |
| Android DB integrity (`user_version=27`, integrity/FK) | INCONCLUSIVE | Release APK is not debuggable; direct disposable-lane query was not available without protected-data access. |
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
