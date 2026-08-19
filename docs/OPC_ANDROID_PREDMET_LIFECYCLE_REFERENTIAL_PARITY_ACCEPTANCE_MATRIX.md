# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Matrix

| Area | Evidence required | Current evidence | Status | Successor / boundary |
|---|---|---|---|---|
| Device readiness | Physical Android target, ADB and Flutter visibility | LGN LX1, Android 15/API 35, ADB `device`, Flutter target visible | PASS | None |
| Acceptance-lane identity | Shared implementation with inspectable disposable database | Accepted representativeness audit: same `AppDatabase`, schema 27, migrations, repair, lifecycle, RR-005 cleanup and backup/restore; database identity is `opc_v4_android_test` | PASS (audit) | Physical ANDROID_TEST execution evidence remains required |
| ANDROID_TEST build/inspectability | Debug artifact and `run-as` access | Debug build PASS; package `com.tale.opc_v4`, `debuggable=true`, certificate matches; device became ADB `offline` before installation, so `run-as` and DB capture were not attempted | INCOMPLETE — DEVICE OFFLINE | Re-establish device connectivity, then capture disposable DB |
| Build identity | Accepted current-tip Android release artifact | Default/no-define `PRODUCTION` release APK, package `com.tale.opc_v4`, SHA `C7A0A2CB9B98516838F41DA7DE51E50C4D0287C493195F2F88CF0372612C2DD4`; release DB `opc_v4_release.sqlite` | PASS | None |
| Fresh business KATALOG | Fresh DB has no business KATALOG rows | Focused contract tests and physical fresh lane show empty business list | PASS | None |
| Existing KATALOG preservation | Existing rows survive reopen and repair/index paths | Explicit existing-row and unique-index tests pass | PASS | None |
| Database initialization | Setup creates/opens schema coherently | Fresh lane completes first-run setup; prior `user_version 0` mismatch no longer reproduces | PASS | None |
| Authenticated main state | Owner login reaches `OPC — LISTA PREDMETA` | Owner-entered private PIN plus `POTVRDI` reached authenticated main state | PASS | None |
| PREDMET lifecycle | Create/close/reopen/relaunch | Synthetic `Test_A` and `Test_B` created/saved; normal exit confirmation exercised; release relaunch/authentication returned to `OPC — LISTA PREDMETA` with `Prikazano 2 od 2` | PASS (bounded) | Android physical referential/backup/DB-integrity acceptance completion |
| Provenance cleanup | Delete/replacement leaves no orphan provenance | Automated contract coverage; representative physical proof not completed | INCOMPLETE | Same bounded successor |
| Snapshot cleanup | Hard-delete leaves no orphan snapshots | Automated contract coverage; direct Android DB proof not available in release lane | INCOMPLETE | Same bounded successor |
| Replacement regression | RR-005 replacement/orphan contract | Not executed as a physical Android case in this wave | INCOMPLETE | Same bounded successor; RR-008 remains owner-gated |
| Backup/restore | Bounded disposable Android restore | Not executed in this correction wave | INCOMPLETE | Same bounded successor |
| Background/relaunch | Foreground/background/reopen integrity | Home/background and normal relaunch returned to authenticated main state | PASS (bounded) | None |
| Android DB integrity | `user_version=27`, integrity and FK evidence | Release APK is non-debuggable; the later authorized ANDROID_TEST debug build produced a debuggable APK, but the target device was ADB `offline` before installation, so direct query/copy was not attempted | INCOMPLETE — DEVICE OFFLINE | Same bounded successor |
| Canonical Windows DB | Pre/post SHA equality | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` pre/post | PASS | None |
| Protected implementation surfaces | Source/SCENARIO/tests/config unchanged outside authorized correction | Runner hash unchanged; no unrelated protected surface changed | PASS | None |
