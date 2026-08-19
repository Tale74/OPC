# RR-011 Android PREDMET Lifecycle / Referential Parity Acceptance Matrix

| Area | Evidence required | Current evidence | Status | Successor / boundary |
|---|---|---|---|---|
| Device readiness | Physical Android target, ADB and Flutter visibility | LGN LX1, Android 15/API 35, ADB `device`, Flutter target visible | PASS | None |
| Build identity | Current-tip Android test artifact | `ANDROID_TEST` release APK built/installed; SHA recorded in report | PASS | None |
| Fresh business KATALOG | Fresh DB has no business KATALOG rows | Focused contract tests and physical fresh lane show empty business list | PASS | None |
| Existing KATALOG preservation | Existing rows survive reopen and repair/index paths | Explicit existing-row and unique-index tests pass | PASS | None |
| Database initialization | Setup creates/opens schema coherently | Fresh lane completes first-run setup; prior `user_version 0` mismatch no longer reproduces | PASS | None |
| Authenticated main state | Owner login reaches `OPC — LISTA PREDMETA` | Owner-entered private PIN plus `POTVRDI` reached authenticated main state | PASS | None |
| PREDMET lifecycle | Create/close/reopen/hard-delete | Disposable `Test Lice` created, closed, reopened, relaunched and permanently deleted; list returned empty | PASS (bounded) | Android physical referential/backup/DB-integrity acceptance completion |
| Provenance cleanup | Delete/replacement leaves no orphan provenance | Automated contract coverage; representative physical proof not completed | INCOMPLETE | Same bounded successor |
| Snapshot cleanup | Hard-delete leaves no orphan snapshots | Automated contract coverage; direct Android DB proof not available in release lane | INCOMPLETE | Same bounded successor |
| Replacement regression | RR-005 replacement/orphan contract | Not executed as a physical Android case in this wave | INCOMPLETE | Same bounded successor; RR-008 remains owner-gated |
| Backup/restore | Bounded disposable Android restore | Not executed in this correction wave | INCOMPLETE | Same bounded successor |
| Background/relaunch | Foreground/background/reopen integrity | Home/background and normal relaunch returned to authenticated main state | PASS (bounded) | None |
| Android DB integrity | `user_version=27`, integrity and FK evidence | Release APK is non-debuggable; direct query not available without protected-data access | INCONCLUSIVE | Same bounded successor |
| Canonical Windows DB | Pre/post SHA equality | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` pre/post | PASS | None |
| Protected implementation surfaces | Source/SCENARIO/tests/config unchanged outside authorized correction | Runner hash unchanged; no unrelated protected surface changed | PASS | None |
