# OPC task report - RI-2 hard-delete lifecycle coordination

**Status:** `TECHNICAL IMPLEMENTATION PASS - OWNER RUNTIME ACCEPTANCE SEPARATE`
**Date:** 2026-07-30

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- production implementation / lifecycle coordination / tests / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no - PREDMET remains the sole authoritative business truth

Database ownership affected:
- yes - hard-delete ordering only; no schema/FK/migration change

JSON transfer affected:
- no

Windows/Android parity affected:
- yes - both native lanes use the same application coordinator; Android owns
  the actual notification side effect and Windows gateway behavior remains safe

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes - owner continued after RI-1 closure and was notified before source change

Explicitly closed:
- anonymization behavior;
- individual replacement behavior;
- full restore behavior;
- FK enablement;
- orphan recovery/live canonical execution;
- OPC Web and OPC_v.1_Int.

## 1. Git baseline

- Base branch:
  `task/OPC-RI-1-PREDMET-LIFECYCLE-CHARACTERIZATION-INVENTORY`
- Base SHA:
  `a2fa812b2ca605a83385cf2c7244a3a2df92b6aa`
- Task branch:
  `task/OPC-RI-2-HARD-DELETE-LIFECYCLE-COORDINATION`
- Final result SHA:
  `d27fa7600db3d96ac3a852cc1261688131eda288`
- Report closure SHA:
  recorded in the Git completion handoff and visible from Git alone

## 2. Evidence and data boundary

The task re-confirmed branch/origin equality, clean worktree and the controlling
post-zero authority, incident register, current state, plan, manifest, RI
design and latest RI-1 report.

Current source and tests established the reusable seams:

- `StanjeRobeLifecycleService.reconcileFullPredmetDelete`;
- `ParteMediaStore.stageOwnedDeletion` with restore/purge;
- exact stored ceremony notification IDs;
- existing repository transaction.

Only fresh in-memory SQLite databases and task-owned temporary media folders
were used. Canonical, backup, private-input and production runtime data were not
opened.

## 3. Implemented outcome

`PredmetHardDeleteCoordinator` now:

1. loads the authoritative PREDMET and exact PARTE/reminder inventory;
2. determines exclusive versus shared app-owned media references;
3. stages only exclusive media;
4. cancels only stored/scoped notification IDs;
5. invokes one authoritative repository transaction;
6. restores media and reschedules reminders if cancellation/DB mutation fails;
7. purges staged media after a successful commit.

The repository transaction now explicitly deletes:

- active STANJE ROBE consequences after existing stock compensation;
- `ceremony_reminder_settings`;
- `parte_pripreme`;
- `log_izmena`;
- `kontakt_lica`;
- `iriu`;
- `iriu_lifecycle_decisions`;
- the authoritative `predmeti` row.

Both actual UI delete paths now call the coordinator. Confirmation dialog,
success message and navigation behavior are preserved.

## 4. Failure and anti-drift proof

Focused tests prove:

- all seven declared PREDMET child families are removed;
- `foreign_key_check` is clean after success;
- exact stored reminder IDs are the only cancellation targets;
- exclusive media is deleted and shared media survives;
- forced DB failure rolls back DB rows, restores staged media and reschedules
  reminder state;
- forced notification cancellation failure leaves DB rows and media intact and
  runs reminder compensation.

The IRIU ordering incident boundary is unaffected. No technical PASS is treated
as owner approval of a business change.

## 5. Deliberate non-changes

- `PRAGMA foreign_keys` remains off;
- schema version remains 22;
- no migration or orphan repair exists;
- no canonical data was inspected or mutated;
- anonymization, replacement and restore retain their RI-1 characterized state;
- no notification `cancelAll` is used;
- no package restriction, Web scope or internationalization work was opened.

## 6. Validation

- focused RI-2 + RI-1 regression tests: PASS, 8 passed, 0 failed;
- `flutter analyze --no-pub`: PASS, no issues;
- complete `flutter test --no-pub`: PASS, 255 passed, 1 skipped, 0 failed;
- build: not started;
- manifest diff gate against exact base SHA: PASS;
- .NET UTF-8/no-BOM validation: PASS for all changed text files;
- technical PASS and owner Windows/Android runtime acceptance: separate.

## 7. Next dependency

After technical/Git closure, owner Windows and Android runtime acceptance should
confirm actual hard delete with a disposable synthetic PREDMET containing PARTE
media and (on Android) a scheduled reminder.

No further RI-2 behavior is automatically authorized. Anonymization,
replacement and restore must remain stopped at their recorded post-zero owner
gates. RI-3 remains dependent on closed RI-2 scope and isolated-copy migration
authorization.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes - explicit hard-delete lifecycle only

Windows/Android parity preserved:
- yes - common DB/filesystem ordering and platform-scoped notification gateway

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

OPC Web remains outside current implementation scope:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS subject to complete validation, repository checks, commit, push, origin
  equality and clean worktree completion
