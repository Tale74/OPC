# OPC task report - RI-1 PREDMET lifecycle characterization and inventory

**Status:** `RI-1 TECHNICAL PASS - PRODUCTION BEHAVIOR UNCHANGED`
**Date:** 2026-07-30

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation / test characterization / tooling / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no - PREDMET remains the sole business truth

Database ownership affected:
- no - only fresh isolated in-memory databases were used

JSON transfer affected:
- no - current restore behavior was observed, not changed

Windows/Android parity affected:
- no production behavior changed

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes - RI-1 test/tooling tree only, after owner notification

Stop conditions:
- any production behavior change;
- FK enablement or migration;
- canonical/backup/private database access;
- orphan deletion/relink;
- unclassified owner/business-policy choice.

None occurred.

## 1. Git baseline

- Base branch:
  `task/OPC-POST-ZERO-PREDMET-LIFECYCLE-REFERENTIAL-DESIGN`
- Base SHA:
  `44e1e7e428ef6f033676d004a2cec1b2b921134f`
- Task branch:
  `task/OPC-RI-1-PREDMET-LIFECYCLE-CHARACTERIZATION-INVENTORY`
- Final result SHA:
  `78ad8d593dc7dfda574e175d7d26944d5aed169b`
- Report closure:
  a following documentation-only commit adds this report; its exact branch-tip
  SHA is recorded in the Git completion handoff and is visible from Git alone.

## 2. Evidence boundary

The task first re-confirmed the post-zero authority documents, incident
register, current state, authoritative plan, anti-drift manifest and latest
relevant task report.

Source/tests were used before any owner question. Pre-zero audit conclusions
were treated as technical/migration evidence only, never as current owner
authority.

All new database evidence uses `AppDatabase.forTesting(NativeDatabase.memory())`.
No canonical database, backup, private input or production runtime database was
opened.

## 3. Committed result

`test/predmet_lifecycle_referential_characterization_test.dart` adds five
focused characterization tests:

1. schema inventory proves current `foreign_keys=0`, enumerates all seven
   PREDMET foreign keys with `PRAGMA foreign_key_list`, and returns exact
   metadata-only orphan counts;
2. hard delete proves current explicit cleanup leaves one PARTE preparation and
   one ceremony-reminder row as FK orphans;
3. anonymization proves PREDMET redaction while synthetic PII remains in a
   completed PARTE draft and log, and notification IDs remain;
4. individual replacement proves stale local PARTE/reminder state survives
   under the retained PREDMET ID;
5. full restore proves a stale destination reminder can silently associate with
   the restored PREDMET that reuses the same local ID while
   `foreign_key_check` remains clean.

This separates visible referential corruption from semantically stale
re-association. A clean FK check is therefore necessary but not sufficient.

Existing committed tests remain the supporting evidence for:

- STANJE ROBE delete/replacement compensation;
- PARTE owned-media staging, rollback and purge;
- reminder ID persistence/idempotency;
- supported historical/current migration fixtures.

RI-1 does not duplicate those already committed broad tests.

## 4. Non-results

RI-1 does not:

- approve the characterized current behavior;
- identify owner-approved retention/history/restore policy;
- implement a lifecycle coordinator;
- change production Dart source;
- enable foreign keys;
- add or run a migration;
- inspect, delete or repair live/canonical rows;
- provide owner runtime acceptance.

## 5. Next dependency

Next dependency:

`RI-2 EXPLICIT LIFECYCLE COORDINATION WHILE FK REMAINS OFF`

RI-2 requires a separate task branch, owner notification and exact
implementation authorization.

Hard-delete coordination is the first technically independent slice. The
anonymization, replacement and restore slices must remain stopped at their
recorded post-zero owner gates before behavior is selected or implemented.

## 6. Validation

- focused RI-1 test:
  `flutter test --no-pub test/predmet_lifecycle_referential_characterization_test.dart`;
- focused result: PASS, 5 passed, 0 failed;
- `flutter analyze --no-pub`: PASS, no issues;
- complete `flutter test --no-pub`: PASS, 252 passed, 1 skipped, 0 failed;
- build: not started and not required for test-only characterization;
- manifest diff gate against exact base SHA: PASS;
- .NET UTF-8/no-BOM validation: PASS for all changed text files;
- technical PASS and owner runtime acceptance: separate.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

OPC Web remains outside current implementation scope:
- yes

Source changes within scope:
- yes - test characterization and documentation only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS subject to successive validation, repository checks, commit, push,
  origin equality and clean worktree completion
