# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Matrix

| Area | Evidence required | Current evidence | Status | Successor / boundary |
|---|---|---|---|---|
| Device readiness | Physical Android target, ADB and Flutter visibility | LGN LX1, Android 15/API 35, ADB `device`, Flutter target visible | PASS | None |
| Acceptance-lane identity | Shared implementation with inspectable disposable database | Accepted representativeness audit plus completed physical ANDROID_TEST execution: same `AppDatabase`, schema 27, migrations, repair, lifecycle, RR-005 cleanup and backup/restore; database identity is `opc_v4_android_test` | PASS (bounded physical) | Scenario-snapshot precondition and separate single-PREDMET replacement remain |
| ANDROID_TEST build/inspectability | Debug artifact and `run-as` access | Debug build PASS; package `com.tale.opc_v4`, `debuggable=true`, certificate matches; in-place install preserved data and `run-as` succeeded | PASS | None |
| Build identity | Accepted current-tip Android release artifact | Default/no-define `PRODUCTION` release APK, package `com.tale.opc_v4`, SHA `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4`; release DB `opc_v4_release.sqlite` | PASS | None |
| Fresh business KATALOG | Fresh DB has no business KATALOG rows | Focused contract tests and physical fresh lane show empty business list | PASS | None |
| Existing KATALOG preservation | Existing rows survive reopen and repair/index paths | Explicit existing-row and unique-index tests pass | PASS | None |
| Database initialization | Setup creates/opens schema coherently | Fresh lane completes first-run setup; prior `user_version 0` mismatch no longer reproduces | PASS | None |
| Authenticated main state | Owner login reaches `OPC — LISTA PREDMETA` | Owner-entered private PIN plus `POTVRDI` reached authenticated main state | PASS | None |
| PREDMET lifecycle | Create/close/reopen/relaunch | Synthetic `Test_A` and `Test_B` created/saved; normal exit confirmation exercised; release relaunch/authentication returned to `OPC — LISTA PREDMETA` with `Prikazano 2 od 2` | PASS (bounded) | RR-011 Android scenario-snapshot precondition and single-PREDMET replacement structural acceptance completion |
| Provenance cleanup | Delete/replacement leaves no orphan provenance | `Test_A` delete had 11 IRiU + 11 provenance rows before action; normal hard-delete removed all owned rows; post-action orphans 0 | PASS (bounded) | None |
| Snapshot cleanup | Hard-delete leaves no orphan snapshots | `predmet_scenario_snapshots` was zero-row before and after; no precondition existed | INCOMPLETE — PRECONDITION ABSENT | RR-011 Android scenario-snapshot precondition and single-PREDMET replacement structural acceptance completion |
| Replacement regression | RR-005 replacement/orphan contract | Full-backup replacement path passed; separate single-PREDMET replacement was not exercised | INCOMPLETE | RR-011 Android scenario-snapshot precondition and single-PREDMET replacement structural acceptance completion; RR-008 remains owner-gated |
| Backup/restore | Bounded disposable Android restore | Supported `OPC_BACKUP` schema 9 export/import passed after controlled synthetic delete; post-restore structural checks pass | PASS (bounded) | None |
| Background/relaunch | Foreground/background/reopen integrity | Home/background and normal relaunch returned to authenticated main state | PASS (bounded) | None |
| Android DB integrity | `user_version=27`, integrity and FK evidence | Captured `opc_v4_android_test.sqlite`: schema 27, `integrity_check=ok`, zero FK violations, no WAL/SHM sidecars | PASS (ANDROID_TEST) | None |
| Canonical Windows DB | Pre/post SHA equality | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` pre/post | PASS | None |
| Protected implementation surfaces | Source/SCENARIO/tests/config unchanged outside authorized correction | Runner hash unchanged; no unrelated protected surface changed | PASS | None |
