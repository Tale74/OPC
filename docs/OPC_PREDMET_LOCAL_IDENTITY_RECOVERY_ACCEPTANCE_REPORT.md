# PREDMET Local-Identity / Recovery Acceptance Report

## Result

This bounded implementation pass applies the existing one-local-database / one-FIRMA model. It does not create portable user identity, a new FIRMA identity subsystem, or a new individual-PREDMET FIRMA block.

Implementation state: `IMPLEMENTED — FOCUSED ACCEPTANCE PASS`.

Overall review state: `PREDMET LOCAL-IDENTITY / RECOVERY ACCEPTANCE COMPLETE — CASE-2 MERGE/RECONCILIATION SUCCESSOR RETAINED — READY FOR LOGOS REVIEW`.

The focused acceptance evidence is complete. The full Flutter suite then reached natural completion with `443 PASS` and `10` expected skips, with no test failure or tooling hang. Release-build gates completed serially.

## Scope and protected boundaries

- Current local `Korisnici.id` values remain database-local and are never treated as cross-device identity.
- PREDMET remains the sole business truth; RR-008 derived-state and replacement `logIzmena` contracts remain unchanged.
- Full backup remains distinct from individual PREDMET transfer and keeps its complete local database-family semantics.
- No schema/migration, dependency, SCENARIO, platform, canonical-database or private-data change was made.
- `IMPORT_NEW` remains a separate audit-taxonomy concern: new import now records truthful local creator/modifier ownership, but no new `IMPORT_NEW` event was invented.
- Existing cancel/keep/replace conflict behavior and multiple-match fail-closed behavior remain intact.

## Implemented controls

| Control | Evidence and result |
|---|---|
| Destination-local new import | Active local ADMINISTRATOR/SAVETNIK is required; `savetnikId`, creator and last modifier are bound to that local actor. Foreign numeric IDs are not authority. |
| Same-identity replacement | Stable local PREDMET id, local adviser and creator, existing local history, and local replacement actor are preserved; imported business state and `IMPORT_REPLACE` semantics remain. |
| Actor gate | Missing, inactive or ineligible actor fails before individual-import mutation. |
| Permanent deletion guard | `savetnikId`, `createdByKorisnikId`, `lastBusinessModifiedByKorisnikId` and `logIzmena.korisnikId` all block permanent deletion; deactivation/role change does not rewrite attribution. |
| Full-backup identity preflight | Four states are explicit: matching PIB/MB proceeds; mismatching PIB/MB is blocked; a fresh local database may establish a complete backup identity; missing/incomplete backup FIRMA identity is fail-closed when local business state exists. Missing identity is never treated as a match. |
| Case-2 boundary | `EXISTING LOCAL STATE + BACKUP FIRMA IDENTITY MISSING/INCOMPLETE` is safely blocked before destructive write. Merge/reconciliation is out of scope and remains owned by `FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY — USER FALLBACK + SAFE MERGE/RECONCILIATION DESIGN AND ACCEPTANCE`. |
| Case-3 fresh recovery | A fresh local database can be initialized from a complete backup identity; this is a legitimate recovery path and is independently covered by focused proof. |
| Collision-safe creation | Existing minute-based candidate is checked and deterministic `-2`, `-3`, … suffixes are allocated inside the creation transaction. Existing legacy duplicates are preserved and not renumbered. |
| Conflict presentation | Local-ID labels make adviser/modifier fields non-portable identity claims without redesigning the dialog. |

## QA evidence

| Sequence | Result |
|---|---|
| Focused acceptance + transfer/lifecycle regression | `PASS — 44/44 tests` |
| `flutter analyze --no-pub` | `PASS — No issues found (31.1s)` |
| `flutter test --no-pub --concurrency=1` | `PASS — 443 tests passed; 10 expected skips; natural completion` |
| `flutter build windows --release` | `PASS — build\windows\x64\runner\Release\OPC.exe` (190.5s); SHA-256 `CFC5578443C3F38041A169D9A046B393A284967AAC943895A58EF2EAD7E7D255`. |
| `flutter build apk --release` | `PASS — app-release.apk`, 78,403,503 bytes (883.9s); SHA-256 `001A9B948A2BE835C158D40BF3B37869B81A21EBB031F4BF3E3F1B0FB8FDC283`. |

The prior targeted tests, replacement failure-path tests and JSON compatibility tests remain part of the protected baseline and were included in the focused run. No Flutter/Dart/Gradle process was run in parallel. Analyzer, tests and both release builds were allowed to reach natural completion; no arbitrary timeout was used.

## Validation and protected surfaces

- `git diff --check`: PASS (after documentation reconciliation).
- Canonical database: not opened for mutation; SHA remained the protected current baseline.
- Windows runner: unchanged; protected SHA remains `FFD03CCA5821FB1813CDF2D9CAADB687C79DB1E8AFA0CB27976EE8C379885863`.
- SCENARIO: unchanged and locked.
- Source/test delta is limited to the files listed in the completion package; no dependencies, schema, migration, CI, platform configuration, runtime/private data or `SOURCE\REVIEW` artifact changed.

## Authority reconciliation

The current authority set now records destination-local rebinding, deletion-reference coverage, collision-safe creation and bounded full-backup identity preflight as implemented. Case 2 (existing local state plus missing/incomplete backup FIRMA identity) is intentionally fail-closed and remains out of scope for merge/reconciliation; its single successor is `FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY — USER FALLBACK + SAFE MERGE/RECONCILIATION DESIGN AND ACCEPTANCE`. Case 3 (fresh local state plus complete backup identity) remains a legitimate recovery path. Historical audits retain their original pre-implementation findings and are superseded for current state by this report and the updated current registers. Broader JSON/database migration, platform parity, PARTE, KATALOG, STANJE ROBE, IRiU, PODSETNIK and policy/finance successors remain separate and unchanged.

## Review handoff

The external Layer-4 package is `OPC_PREDMET_LOCAL_IDENTITY_RECOVERY_LOGOS_REVIEW.zip` under the repository-level `REVIEW` directory. It contains the defect map, implementation/report evidence, changed-file list, hashes, validation summary and no database, private data or build artifacts.

No commit, push or successor task was started. The package is ready for Logos review; the full-suite natural PASS and expected skips remain visible to the reviewer.
