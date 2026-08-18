# Release-Risk Defect / No-Defect Decision Register

| ID | Decision | Evidence basis | Immediate correction? | Successor |
|---|---|---|---|---|
| RR-001 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | `windows/runner/main.cpp` acquires an OPC-specific mutex before console/COM/Flutter/Dart/database initialization; W1/W2/W3/W4/W5/W6 pass; exact analyzer reports no issues; exact full suite passes 419 tests | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-002 | CONTRACT CONFIRMED — canonical path/name | `app_config.dart`, `database.dart` | No | Release-candidate path recheck |
| RR-003 | CONTRACT CONFIRMED — test lane rejects canonical aliases | Selector source + 9 passing tests | No | Keep release gate |
| RR-004 | CONTRACT CONFIRMED — disposable-copy integrity | SHA/integrity check and unchanged canonical hash | No | Repeat before recovery rehearsal |
| RR-005 | CORRECTION CLOSED — FULL ACCEPTANCE PASS | Bounded hard-delete, replacement and startup cleanup pass focused/disposable evidence; migration/recovery 40/40, analyzer no issues, full suite 422 passed/10 skipped and Android release build pass; Windows build evidence remains valid; canonical SHA unchanged. | No | None — RR-005 correction closed |
| RR-006 | CONTRACT CONFIRMED — explicit PREDMET lifecycle | 5 passing completion tests | No | Windows/Android runtime acceptance |
| RR-007 | CONTRACT CONFIRMED — tested delete/restore referential flows | 5 + 4 + 8 passing tests | No | Release acceptance with representative data |
| RR-008 | INCONCLUSIVE — replacement-derived-state semantics | 5 passing tests expose retention, but no release oracle | No | Business-meaning acceptance for derived reminder/PARTE state |
| RR-009 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | Disposable-lane W2/W3/W4/W5/W6 evidence proves duplicate safety, normal release/reacquisition and disposable integrity; exact analyzer reports no issues; exact full suite passes 419 tests | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-010 | CURRENT-TIP WINDOWS STARTUP / LOGIN / EXIT ACCEPTANCE — FULL ACCEPTANCE PASS | Five owner-authorized login transitions reached `OPC — LISTA PREDMETA`; five normal exits; three relaunch cycles; singleton regression pass; disposable `user_version=27`, `integrity_check=ok`, `foreign_key_check=0`; canonical SHA unchanged | No | None — Windows timing acceptance complete |
| RR-011 | DEFECT PROVEN — Android physical parity blocked by test-lane schema initialization | Current-tip Android_TEST APK on LGN LX1 reached first-run setup; after owner-confirmed `POTVRDI`, the UI reproduced `database has user_version 0 but already contains table "app_podesavanja"; automatic creation is unsafe`; no production correction was made | No | Android test-lane database initialization/schema-version correction + physical RR-011 re-acceptance |
