# Release-Risk Defect / No-Defect Decision Register

| ID | Decision | Evidence basis | Immediate correction? | Successor |
|---|---|---|---|---|
| RR-001 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | `windows/runner/main.cpp` acquires an OPC-specific mutex before console/COM/Flutter/Dart/database initialization; W1/W2/W3/W4/W5/W6 pass; exact analyzer reports no issues; exact full suite passes 419 tests | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-002 | CONTRACT CONFIRMED — canonical path/name | `app_config.dart`, `database.dart` | No | Release-candidate path recheck |
| RR-003 | CONTRACT CONFIRMED — test lane rejects canonical aliases | Selector source + 9 passing tests | No | Keep release gate |
| RR-004 | CONTRACT CONFIRMED — disposable-copy integrity | SHA/integrity check and unchanged canonical hash | No | Repeat before recovery rehearsal |
| RR-005 | DEFECT PROVEN — current-tip referential-integrity violation | Canonical 34 provenance + 2 snapshot findings; current FK mode=0; current hard-delete omits both child tables; disposable current-flow reproduction 2/2 creates equivalent orphans; no parent reconstruction authorized | No | RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance |
| RR-006 | CONTRACT CONFIRMED — explicit PREDMET lifecycle | 5 passing completion tests | No | Windows/Android runtime acceptance |
| RR-007 | CONTRACT CONFIRMED — tested delete/restore referential flows | 5 + 4 + 8 passing tests | No | Release acceptance with representative data |
| RR-008 | INCONCLUSIVE — replacement-derived-state semantics | 5 passing tests expose retention, but no release oracle | No | Business-meaning acceptance for derived reminder/PARTE state |
| RR-009 | WINDOWS SINGLETON DEFECT — FULL ACCEPTANCE PASS | Disposable-lane W2/W3/W4/W5/W6 evidence proves duplicate safety, normal release/reacquisition and disposable integrity; exact analyzer reports no issues; exact full suite passes 419 tests | No | None — acceptance complete; remaining release/migration work is tracked separately |
| RR-010 | INCONCLUSIVE — current-tip Windows runtime timings | Historical baseline only | No | Reproducible current-tip startup/exit measurement |
| RR-011 | INCONCLUSIVE — Android physical parity | Shared Dart evidence only | No | Android device/emulator lifecycle/referential acceptance |
