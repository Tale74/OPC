# OPC Post-Recovery Stabilization Forensic Audit

Date: 2026-08-13

Role: Codex 5.6 Sol High — audit/forensics only

Source baseline: `9f111064557bd870399d5931e621626f188bd5ee`

Audit branch: `audit/OPC-POST-RECOVERY-STABILIZATION-FORENSIC-AUDIT`

## A. Baseline and evidence reviewed

The published recovery branch and remote SHA were confirmed before the audit as
`9f111064557bd870399d5931e621626f188bd5ee`; local HEAD matched and the working
tree was clean. The audit read the complete recovery report, the preceding Sol
forensic report, current plan/state/source-of-truth/owner-decision documents,
the complete recovery commit diff and all committed recovery manifests.

Private evidence was inspected read-only:

- canonical DB: `C:\Users\Steva\Documents\opc_v4_release.sqlite`;
- clean schema-9 backup:
  `C:\Users\Steva\Downloads\KORICE\OPC_backup_LUNA_CLEAN_13082026_2021.json`;
- retained clean-room DB/export artifacts under
  `C:\Users\Steva\AppData\Local\Temp\opc_luna_recovery_20260813`;
- installed runtime under `C:\Program Files\OPC`;
- application-owned PARTE media store under
  `%APPDATA%\com.tale\OPC\parte_media`.

The sanitized machine-readable evidence is
`docs/artifacts/OPC_POST_RECOVERY_FORENSIC_AUDIT_EVIDENCE.json`.

## B. Recovery report claim-by-claim verification

| Recovery claim | Independent audit result | Evidence level |
|---|---|---|
| 47 PREDMET rows | verified | canonical SQL |
| 631 IRiU rows | verified | canonical SQL |
| 138 KATALOG rows | verified | canonical SQL |
| 34 Politika + 17 Novosti | verified | canonical SQL |
| zero citation duplicate tuples | verified | canonical SQL |
| `integrity_check=ok` | verified | canonical SQL |
| `foreign_key_check=0` | verified | canonical SQL |
| one scenario snapshot / 17 provenance rows | verified | canonical SQL |
| historical snapshot mutation removed | verified in source; focused test is green | source/test |
| clean backup SHA/schema/counts | verified | independent JSON parse/hash |
| clean-room restore FK/integrity | verified | retained disposable DB |
| export→restore→export equality except timestamp | verified | independent JSON comparison |
| full unfiltered suite | not PASS; completes with one failure | sequential full test |
| Windows/Android builds | artifacts were built before full-suite PASS | diagnostic build evidence only |
| installed normal canonical runtime | not proven; installed build is `WINDOWS_TEST` | binary/runtime evidence |
| schema-9 FULL losslessness | overstated for PARTE media/output portability | source/policy/filesystem evidence |
| one KATALOG→IRiU semantic path | overstated; one DTO fronts several writers | production caller audit |

The recovery itself is materially successful at the SQL and clean logical
restore levels. This audit narrows several labels; it does not downgrade the
clean canonical database.

## C. Real canonical Windows runtime acceptance

`C:\Program Files\OPC\OPC.exe` cold-started and reached the adviser/PIN login
screen. Authentication was not automated because the audit must not handle the
owner's PIN.

More importantly, the installed folder is not a normal production/canonical
artifact:

- installed `OPC.exe`, `flutter_windows.dll`, `data/app.so` and asset manifest
  are byte-identical to the local diagnostic release folder;
- installed `data/app.so` contains compiled `WINDOWS_TEST`, `WINDOWS TEST`,
  `MIGRATION_TEST_DATABASE_PATH`, `LUNA_MIGRATION_TEST.sqlite` and
  `opc_v4_windows_test` values;
- its database selector therefore targets the isolated LUNA migration-test
  file rather than normal `opc_v4_release.sqlite`.

The diagnostic database changed from the repaired-copy baseline to 180 KATALOG
rows after the installed start because the `WINDOWS_TEST` full-photo seed added
42 non-citation rows. Citation counts stayed 34/17 with zero duplicate tuples.
The canonical DB hash did not change.

Consequently, the installed launch proves executable startup to login, but it
does not prove any requested canonical KATALOG/PREDMET/IRiU/SCENARIO/LISTA/PDF
runtime behavior. Normal production build/deployment and owner login are
required later.

## D. Canonical DB before/after runtime comparison

The same read-only snapshot was obtained before and after the installed
runtime observation:

| Measure | Before | After |
|---|---:|---:|
| SHA-256 | `812aa438...bc51c` | `812aa438...bc51c` |
| PREDMET | 47 | 47 |
| IRiU | 631 | 631 |
| KATALOG | 138 | 138 |
| Politika / Novosti | 34 / 17 | 34 / 17 |
| duplicate citation tuples | 0 | 0 |
| scenario snapshots / provenance | 1 / 17 | 1 / 17 |
| FK violations | 0 | 0 |
| integrity check | `ok` | `ok` |

This proves the audit did not mutate canonical data. It does not constitute
normal canonical use because the installed diagnostic artifact selected the
test DB.

## E. Full Flutter suite forensic diagnosis

### Preflight findings

Before the audit rerun, one orphan `flutter_tester.exe` from the prior interrupted
suite remained alive without a `flutter` parent. It and an idle Gradle daemon
were stopped before new toolchain work. This proves that interruption can leak
children and that child-process cleanup must be an explicit gate.

The first targeted file exposed a deterministic source/test mismatch:

`test/parte_print_preparation_json_test.dart`

still contains the schema-8 assertion named
`full backup includes user templates but excludes draft and media`, requiring
`partePripreme` to be absent. Schema 9 intentionally exports that section, so
the assertion fails.

The command output contained `Some tests failed`, but the shell boundary
reported exit code 0. That mismatch was reproduced by the full run: the JSON
report ended with `{"success":false,"type":"done"}`, while the shell again
reported exit code 0.

### Full-suite run

The default Flutter runner internally started two `flutter_tester` workers.
Because this task locks heavy execution to one process, that diagnostic run was
interrupted and its exact children were stopped. It is not an acceptance run.

The authoritative diagnostic command was:

```text
flutter test --no-pub --concurrency=1 --reporter silent \
  --file-reporter json:<temporary-audit-log>
```

It completed naturally in 2,081.8 seconds (34 min 41.8 s):

- 480 `testDone` events;
- 479 success events;
- 1 failure;
- 7 tests marked skipped;
- final JSON `done.success=false`;
- reported shell exit code 0.

The only failure is the stale PARTE backup assertion above. The longest file,
`canonical_database_migration_recovery_test.dart`, took 465.4 seconds. The
suite continued steadily through all files; no deadlock, starvation or test
pollution was demonstrated.

The prior 30-minute termination occurred before the natural sequential runtime
of 34:42. It was not evidence of a hang. The proven infrastructure defect is
the unreliable process/exit-status reporting boundary plus leaked child
process after interruption.

Required classification under the task's fixed taxonomy:

`FULL TEST SUITE — WRAPPER DEFECT PROVEN`

This classification does not hide the independent source/test failure.

## F. Process/toolchain concurrency findings

No competing Flutter/Dart/Gradle command was intentionally launched by the
audit. Nevertheless:

- the default full-test command internally launched two `flutter_tester`
  workers;
- a prior interrupted command left one orphan worker;
- `--concurrency=1` produced exactly one worker and completed naturally;
- all subsequent heavy work must use explicit concurrency 1 where supported;
- after every interruption/completion, `dart`, `dartvm`, `dartaotruntime`,
  `flutter_tester`, `java` and Gradle children must be confirmed exited.

Therefore the literal audit verdict is `DETECTED`, followed by a proven safe
sequential mode.

## G. Schema-9 JSON completeness

The clean JSON and clean-room DB claims were independently verified:

- schema 9 and SHA `16df8b3c...f2a3910`;
- 47 PREDMET, 631 IRiU, 138 KATALOG;
- 1,021 scenario definitions and one module;
- one live scenario snapshot and 17 provenance rows;
- one PARTE preparation;
- restored DB `integrity_check=ok`, FK 0;
- re-export equal in every section except `exportDatum`.

This is strong logical-database recovery proof. It is not proof that the JSON
alone contains all external recovery material.

## H. PARTE media recovery-policy assessment

`ParteMediaStore` stores normalized OPC-owned PNG files under application
support `parte_media`, outside SQLite and JSON. Three such PNGs currently exist
on the machine. Schema 9 serializes `photoMediaKey` and
`customSymbolMediaKey` metadata but has no media-byte section.

During FULL restore, `FullBackupRestoreCoordinator` stages current local media,
performs the DB restore and then purges the staged files. On a fresh machine,
restored keys cannot resolve unless a separate media package is supplied. No
official separate media package/export/restore procedure is implemented or
documented.

The current canonical preparation happens to have null media keys, but it is a
completed derivative whose recorded external PDF path no longer exists in
`Downloads\KORICE`. Its preparation/draft metadata is recoverable and may be
capable of regenerating output; the actual exported file is not present in the
JSON.

The old PARTE test explicitly encoded “excludes draft and media”; recovery
changed draft/preparation portability without reconciling that test or
formalizing media portability. Thus:

- schema-9 JSON alone is not lossless;
- no complete OPC recovery package is proven;
- the recovery report's unqualified `FULL BACKUP LOSSLESSNESS ... PROVEN`
  wording must be narrowed to logical DB state excluding external PARTE media
  and derivatives, or the backup contract must be extended and tested.

## I. KATALOG→IRiU production caller-path audit

The live add picker and existing-row reselection now both construct
`IriuCatalogSelection`. That is a useful shared value shape. However it is not
one writer implementation:

| Path | Actual writer |
|---|---|
| add selected KATALOG article | `dodajKatalogSelection` → public `dodajStavku` → `_insertStavka` |
| reselect existing article | `azurirajKatalogSelection` → public `azurirajKatalogIzborStavke` |
| ordinary row edits | public `azurirajStavku` with raw `IriuCompanion` |
| manual row | public `dodajStavku` without selection type |
| OSNOVNI initialization | direct `_db.into(_db.iriu)` |
| SCENARIO reconciliation | repository/lifecycle raw companion writers |
| Single-PREDMET new/replace | direct raw IRiU inserts in `PredmetiRepository` |
| FULL restore | direct raw IRiU insert in `json_export_import.dart` |

Add and reselection still have separate picker implementations and separate
stock/amount/order mutation code. The compatibility methods remain public and
production-callable. Import/restore correctly preserve transferred historical
snapshots, but they are additional semantic boundaries rather than the shared
live selection command.

The honest verdict is `MULTIPLE`. There is one shared DTO for live concrete
selection, not one production semantic path.

## J. Compatibility/legacy path risk

- The automatic historical snapshot repair is absent; no hidden equivalent was
  found.
- `IriuCatalogSelection.copyWith` cannot explicitly clear a stable ID because
  nullable replacement uses `??`; this is a small domain-contract defect.
- Public low-level KATALOG methods can bypass the typed selection value.
- Display resolution remains stored-snapshot-first, which is correct; live
  category fallback must remain presentation-only.
- Restore dedup is bounded to the two citation categories, which is correct.
- Single-PREDMET and FULL restore raw insertion must remain transfer-specific
  historical paths, but require explicit invariants/tests rather than being
  counted as the live selection pipeline.
- The locked PIB/MB restore identity guard remains documented as not
  implemented and is still a separate destructive-restore risk.

## K. Build-evidence classification under new execution standard

The prior Windows and Android artifacts were created before a confirmed full
suite PASS. The full suite now proves one failing test at the same source HEAD.
The Windows artifact was also compiled as `WINDOWS_TEST` and installed into the
normal Program Files location.

Both prior builds are therefore:

`PRE-FULL-TEST DIAGNOSTIC`

They must not be promoted as final acceptance artifacts. Fresh production
builds are allowed only after targeted tests, analyzer and full suite all pass
in the mandated order.

## L. Remaining defects and risks

1. Stale PARTE schema-8 test fails against schema 9.
2. Flutter/shell exit boundary returns 0 while JSON test result is false.
3. Interrupted suite can leave orphan `flutter_tester` processes.
4. Default runner concurrency violates the machine's locked sequential rule.
5. Schema-9 JSON omits app-owned PARTE media bytes and external derivative
   files; restore can create dangling media keys and purge the old local copy.
6. Recovery documentation overstates full-backup losslessness.
7. Installed Program Files artifact is a migration-test build, not normal
   canonical production runtime.
8. Real post-recovery KATALOG/PREDMET/IRiU/SCENARIO/LISTA/PDF runtime remains
   unproven.
9. One typed selection DTO fronts multiple picker/writer implementations.
10. PIB/MB destructive-restore identity guard remains open.

No finding requires canonical DB mutation.

## M. Technical-rule inventory for documentation task

The later engineering-standard document must codify:

- Sol audit / Luna implementation separation;
- owner business decisions locked, technical premises source-verified;
- no patchwork and no PASS-by-new-test circularity;
- trace real production callers, not only helper names;
- current state authoritative and user deletion final;
- no preservation of ownerless technical orphans;
- PREDMET snapshot immunity from current KATALOG;
- canonical DB path/identity protection;
- forensic-copy repair and late promotion for risky data work;
- verified rollback hashes before promotion;
- clean export plus clean-room restore proof;
- backup contract must name external/local/derivative exclusions;
- sequential Flutter/Dart/Gradle execution;
- explicit `--concurrency=1` where necessary;
- targeted tests → analyze → full tests → final builds → runtime;
- no artificial timeout PASS;
- interruption/hang is not PASS;
- parse machine-readable test completion, not shell code alone;
- confirm all child processes exited;
- distinguish source/test/analyzer/build/copy/canonical/runtime/restore evidence;
- routine push authorization and remote SHA verification;
- runtime proof outranks source/build claims within its exact artifact/path;
- protected installs never receive diagnostic database selectors.

## N. Public engineering-standard research topics for later documentation

The later documentation task should research and cite primary/authoritative
material for:

- official Flutter/Dart architecture, testing, isolates and performance tools;
- Drift/SQLite migrations, transactions, integrity, FK enforcement and backup;
- deterministic test isolation, cleanup and CI exit-status handling;
- structured logging, error taxonomy and recovery-safe failure handling;
- Windows/Android performance and cross-platform parity;
- Git branching, reproducible release builds, signing and artifact provenance;
- OWASP/platform security and privacy for local personal/business data;
- dependency/dead-code/legacy reduction without semantic drift;
- readable APIs, ownership boundaries and commercial maintainability;
- release/handover runbooks, rollback drills and supportability.

No public-standard implementation is authorized by this audit.

## O. Overnight-suitable work

Safe owner-independent overnight scope:

- correct and extend schema-9 PARTE tests;
- make test-result acceptance use JSON `done.success`, not only process code;
- add deterministic child-process pre/postflight documentation/tooling;
- run all Flutter work sequentially with concurrency 1;
- formalize or implement a bounded PARTE media portability contract on test and
  disposable DB/media stores only;
- narrow inaccurate backup-losslessness documentation if media portability is
  not implemented;
- consolidate KATALOG selection writers without changing business semantics;
- make low-level concrete-selection methods private/internal where possible;
- add caller-path assertions/tests;
- run targeted/analyze/full suite in order;
- only after full PASS, create fresh production Windows and Android builds;
- generate audit/acceptance manifests and reports;
- do read-only canonical SQL/hash verification.

Not safe overnight without owner presence:

- canonical migration/replacement;
- Program Files UAC deployment;
- login/PIN entry;
- business-policy decisions;
- physical Windows visual/PDF/print acceptance;
- Android physical or wireless-debugging acceptance.

## P. Owner-action/deferred items

`DEFERRED — OWNER ACTION REQUIRED`

- deploy the final production build through the normal protected-folder lane;
- log in with the owner's PIN;
- visually accept Politika/Novosti counts, concrete selections, OPEN/ZAVRŠEN/
  ANONIMIZOVAN PREDMETs, SCENARIO non-mutation and LISTA/PDF fidelity;
- perform Android physical acceptance only in a later explicitly authorized
  task.

## Q. Luna High overnight implementation handoff

### Exact baseline

Start from published source SHA
`9f111064557bd870399d5931e621626f188bd5ee` plus this audit report commit.
Do not touch `C:\Users\Steva\Documents\opc_v4_release.sqlite` except read-only
hash/SQL checks.

### Exact defects to fix

1. Reconcile `test/parte_print_preparation_json_test.dart` with schema 9.
2. Define the intended portable representation of PARTE preparations and
   app-owned media. If media bytes remain excluded, never restore dangling keys
   or call JSON alone lossless; emit an explicit warning/policy result.
3. Add checksum/size/path validation if media bytes are transferred. Work only
   with disposable media roots in tests.
4. Treat JSON reporter `done.success` as the acceptance result; nonzero failure
   must not be hidden by a zero shell code.
5. Ensure interruption cleanup and preflight process checks.
6. Consolidate live concrete KATALOG add/reselection behind one repository
   command/semantic implementation; keep category-only and historical transfer
   paths explicit and separately tested.
7. Remove or restrict public compatibility writers that can bypass concrete
   selection invariants.
8. Correct recovery/backup/pipeline documentation claims.
9. Build a normal production/Windows artifact without migration-test defines.

### Exact tests to add/change

- schema-9 export contains the intended live `partePripreme` representation;
- photo and custom-symbol behavior follows the declared portability policy;
- fresh clean-room restore never leaves an apparently valid dangling media key;
- corrupt/missing/oversized media fails preflight before destructive restore;
- legacy schema 8/9 behavior remains explicit and backward-safe;
- failed test JSON produces a failed gate even if shell code is zero;
- add/reselect CRNINA `Flor`/`Ešarpa` and one other category use identical
  selection semantics;
- stable ID, snapshot name, price, quantity and amount persist/reopen;
- Single-PREDMET and FULL restore preserve historical snapshots without routing
  through live reselection;
- production build selector ignores/contains no migration-test path;
- installed-runtime acceptance is recorded separately from build tests.

### Mandatory sequential command order

1. Confirm no `OPC`, Flutter, Dart, `flutter_tester`, Java or Gradle process is
   active.
2. Run only the affected targeted tests with `--concurrency=1`.
3. Confirm every child exited.
4. Run `flutter analyze --no-pub`.
5. Confirm every child exited.
6. Run full `flutter test --no-pub --concurrency=1` with a JSON file reporter;
   require final `done.success=true` and zero failed tests.
7. Confirm every child exited.
8. Only then run final production Windows release build.
9. Confirm every child exited.
10. Run Android release build if shared Dart changed.
11. Confirm every child exited.
12. Run automated runtime only on disposable copies; canonical checks remain
    read-only.
13. Commit/push/report only after `git diff --check`.

Never run multiple Flutter/Dart/Gradle commands or test workers in parallel.
Do not use default full-test concurrency on this machine.

### Final gates

- targeted tests PASS;
- analyzer PASS;
- full JSON result PASS;
- no orphan child processes;
- fresh production Windows build contains no test DB selector;
- Android build PASS if required;
- clean backup/media policy proven on disposable stores;
- KATALOG caller-path inventory reduced and tests prove no semantic drift;
- canonical hash/counts/FK/integrity unchanged;
- owner-only runtime items marked deferred, not fabricated.

### Stop conditions

Stop if canonical write access is required, media policy requires an unresolved
business choice, full suite still fails, any historical PREDMET field changes,
production build contains a migration-test selector, or test cleanup cannot
guarantee all heavy child processes exited.

### Required overnight report/verdict

Create `docs/OPC_OVERNIGHT_POST_RECOVERY_STABILIZATION_REPORT.md` with exact
source/test/process/media/pipeline/build/runtime evidence. End with explicit
PASS/PARTIAL/FAIL lines for full test, media recovery, pipeline uniqueness,
production build identity, canonical non-mutation, deferred owner runtime,
remote SHA and clean worktree.

## R. Git/report completion

Only this report and the sanitized audit evidence artifact belong in the audit
commit. No production source, test or canonical-data change is made here.

## S. Final verdict

CANONICAL SQL INTEGRITY — PASS

CANONICAL FK INTEGRITY — PASS

CANONICAL ČITULJE DUPLICATION — ZERO

REAL WINDOWS CANONICAL RUNTIME — PARTIAL

HISTORICAL PREDMET SNAPSHOT IMMUNITY — PASS

NEW KATALOG CONCRETE ARTICLE SELECTION — NOT PROVEN

SCENARIO VIEW NON-MUTATION — NOT PROVEN

LISTA/PDF RUNTIME FIDELITY — NOT PROVEN

FULL TEST SUITE — WRAPPER DEFECT PROVEN

HEAVY TOOLCHAIN CONCURRENCY — DETECTED

SCHEMA-9 JSON ALONE — NOT LOSSLESS

FULL OPC RECOVERY PACKAGE — PARTIAL

PRODUCTION KATALOG→IRiU SEMANTIC PATH — MULTIPLE

PREVIOUS WINDOWS/ANDROID BUILDS — PRE-FULL-TEST DIAGNOSTIC

TECHNICAL RULE INVENTORY — COMPLETE

OVERNIGHT LUNA HANDOFF — READY

CANONICAL DB MUTATED DURING AUDIT — NO

WORKING TREE — CLEAN

REMOTE SHA — CONFIRMED

AUDIT PASS — OVERNIGHT LUNA HIGH STABILIZATION READY
