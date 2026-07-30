# OPC task report - post-zero PREDMET lifecycle/referential design

**Status:** `RI-1 THROUGH RI-5 DESIGN PASS - IMPLEMENTATION NOT AUTHORIZED`
**Date:** 2026-07-30

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- audit / design / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no - protected as the sole business truth

Database ownership affected:
- no - analyzed under canonical-data restrictions

JSON transfer affected:
- no - restore/replacement boundaries designed only

Windows/Android parity affected:
- no - parity proof specified

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- no

Required gate before implementation:
- RI-1 characterization authorization; later data ownership, backup/restore,
  migration, parity and post-zero owner decisions where applicable

## 1. Git baseline

- Base branch:
  `task/OPC-POST-ZERO-ARCHITECTURE-DECISION-GATE-SYNTHESIS`
- Base SHA: `6acd5ac663b5fd4527375923463169784cd27d07`
- Task branch:
  `task/OPC-POST-ZERO-PREDMET-LIFECYCLE-REFERENTIAL-DESIGN`
- Final SHA: pushed task-branch tip containing this report; exact SHA is
  recorded in the Git completion handoff.

## 2. Evidence method

The task read the current post-zero authority, latest report, architecture
synthesis, referential audit, dependent-data matrix, PODSETNIK orphan audit,
lifecycle/log audit and migration policy.

Current source/tests were then inspected for:

- all declared and custom PREDMET foreign keys;
- FK connection setup;
- hard delete and anonymization;
- single-PREDMET replacement;
- full-backup clear/restore order;
- PARTE preparation/media deletion and compensation;
- reminder persistence/cancellation;
- STANJE ROBE delete/replacement compensation;
- current committed test coverage and gaps.

No canonical, backup or private runtime database was opened.

## 3. Confirmed technical result

The current application has reusable safe seams:

- STANJE ROBE delete/replacement compensation;
- recoverable PARTE media stage/restore/purge;
- stored scoped reminder notification IDs;
- transaction-capable PREDMET and restore repositories.

The missing boundary is one lifecycle coordinator that orders those seams
around authoritative PREDMET mutation.

Confirmed gaps remain:

- FK enforcement is off;
- hard delete leaves PARTE/reminder/OS paths outside explicit cleanup;
- anonymization can leave derivative/raw-log PII;
- replacement can retain stale PARTE/reminder state;
- full restore does not first clear every child/device-local dependency while
  FK enforcement is off.

These findings support progressive refactor, not rewrite.

## 4. Design result

`docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md` defines:

- exact dependency classification;
- coordinator and collaborator contracts;
- hard-delete, anonymization, replacement and restore ordering;
- external-side-effect compensation;
- RI-1 through RI-5 task boundaries;
- fixture/failure/idempotency matrix;
- backup, rollback and live-canonical gate;
- technical acceptance and stop conditions.

`PRAGMA foreign_keys` remains off through RI-2 and RI-3. It may be enabled only
in RI-4 after exact inventory, lifecycle correction, orphan recovery and zero
unexpected FK violations.

## 5. Post-zero owner gates

Four later affected boundaries require actual post-zero business/privacy/
transfer decisions:

1. anonymization retention/sanitization of completed PARTE and user-visible
   history;
2. destination-local history behavior during individual replacement;
3. portability of logical reminder preferences in full backup;
4. destination-versus-backup behavior for installation security settings and
   auth audit.

RI-1 does not depend on these answers. No pre-zero answer was treated as
current owner authority.

## 6. Next dependency

Next:

`RI-1 COMMITTED CHARACTERIZATION AND DEPENDENCY/ORPHAN INVENTORY`

RI-1 changes tests/tooling only and must not:

- change production behavior;
- enable foreign keys;
- add a production migration;
- open canonical data;
- delete or relink an orphan;
- claim that characterized current behavior is approved future policy.

Before RI-1 changes the application/test tree, the owner must be notified and a
separate task branch must be used.

## 7. Validation

- application/source/test/configuration change: none;
- canonical/backup/runtime data access: none;
- `flutter analyze`: not repeated; documentation-only task;
- complete `flutter test`: not repeated; application tree unchanged;
- build: not started;
- manifest gate against exact base SHA: PASS;
- repository diff check: PASS;
- .NET UTF-8/no-BOM validation: PASS for all changed documents;
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
- yes - documentation only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS subject to repository checks, commit, push, origin equality and clean
  worktree completion
