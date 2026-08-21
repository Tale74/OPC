# PREDMET Local-Identity / Recovery Acceptance Matrix

| ID | Requirement | Focused proof | Result |
|---|---|---|---|
| T1 | New import ignores foreign numeric user identity | Source and destination IDs intentionally collide; destination actor owns all local attribution | PASS |
| T2 | Source user absent locally | Valid local actor imports successfully | PASS |
| T3 | Replacement preserves local adviser/creator/history | Stable local id, ownership and `IMPORT_REPLACE` actor/history verified | PASS |
| T4 | Missing/inactive actor | Import fails before PREDMET mutation | PASS |
| T5 | Creator-only deletion reference | Permanent deletion blocked | PASS |
| T6 | Last-modifier-only deletion reference | Permanent deletion blocked | PASS |
| T7 | Deactivation/role change | Historical PREDMET and `logIzmena` attribution unchanged | PASS |
| T8 | Matching full-backup identity | Existing restore path accepts matching PIB/MB after preflight | PASS |
| T9 | Mismatching full-backup identity | Preflight blocks before destructive write; local FIRMA remains unchanged | PASS |
| T10 | Case 2: existing local state + missing/incomplete full-backup identity | Fail-closed before destructive write; local FIRMA/business state remains unchanged; merge/reconciliation is not attempted | PASS — bounded fail-closed |
| T10b | Case 3: fresh local state + complete full-backup identity | Fresh local database accepts the complete backup identity and restores the supported database family | PASS |
| T11 | Same-minute collision | Deterministic suffix allocation preserves legacy duplicate rows | PASS |
| T12 | Existing duplicate compatibility | No uniqueness migration or renumbering was introduced; legacy duplicates remain readable | PASS — bounded source/test proof |
| T13 | Existing conflict behavior | Existing transfer regression suite remains green; keep/replace/cancel and multiple-match guard unchanged | PASS |
| T14 | `IMPORT_NEW` taxonomy boundary | New import does not invent a new log event | PASS — separate taxonomy concern preserved |
| T15 | Full-suite gate | Full Flutter runner reached natural completion with 443 PASS and 10 expected skips | PASS |

Focused sequence: `flutter test --no-pub --concurrency=1 test/predmet_local_identity_recovery_acceptance_test.dart test/json_transfer_regression_test.dart test/predmet_lifecycle_referential_characterization_test.dart` — 44/44 PASS. `flutter analyze --no-pub` PASS (31.1s). Full suite: 443 PASS, 10 expected skips. Windows release PASS; Android release PASS, SHA-256 `001A9B948A2BE835C158D40BF3B37869B81A21EBB031F4BF3E3F1B0FB8FDC283`.

Case 2 remains explicitly owned by the single successor `FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY — USER FALLBACK + SAFE MERGE/RECONCILIATION DESIGN AND ACCEPTANCE`; no merge engine or automatic fallback is implemented. Case 3 is a supported fresh-install recovery path.

The implementation preserves the one-database/one-FIRMA architecture and does not make local numeric user IDs portable.
