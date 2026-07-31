# OPC task report - INC-003 backup derivative compatibility correction

**Status:** `TECHNICAL PASS - BUILD NOT RUN BY OWNER DECISION - ANDROID OWNER
RUNTIME RETEST OWED`
**Date:** 2026-07-31

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- production backup/restore compatibility correction, tests and documentation

Core purpose and PREDMET authority preserved:
- yes

Implementation boundary:
- reminder/history transfer ownership, restore lifecycle and evidence only

## 1. Git identity

- Branch: `task/OPC-INC-003-BACKUP-REMINDER-COMPATIBILITY`
- Base SHA: `9473cd0b0f52b10760a31aa1768cdaf5a6fc4830`
- Result SHA: `e7633959ad733fca96347aaeec01fee82d06655e`
- Application/source zero baseline remains
  `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`.

The task started from a clean base branch equal to its upstream. The correction
uses no canonical/live database, migration, FK enablement or history rewrite.

## 2. Runtime incident and confirmed cause

Owner Android full restore failed before destination mutation with a safe
backup reminder-section error. Read-only inspection of the exact supplied
schema-8 file confirmed:

- 46 PREDMET rows;
- 9 reminder configuration rows, of which 2 have no PREDMET in the backup;
- no malformed reminder type/time/duplicate/device-ID-key finding;
- after reminder compatibility was corrected, 230 change-history rows, of
  which 6 have no PREDMET in the backup.

The application-produced file was rejected because export included FK-off
parentless derivatives while import required transferred PREDMET ownership.
The second history finding is retained as an INC-003 transfer-contract
subfinding; it is not promoted to a live repair or RI-3 migration claim.

## 3. Implemented bounded correction

- Export captures the exact exported PREDMET ID set and includes only reminder
  and change-history rows owned by that set.
- Schema-8 import fully validates rows first, then skips only a structurally
  valid row whose PREDMET is absent from the backup.
- A destination PREDMET with the same local ID cannot validate or receive a
  backup orphan row.
- Device-local notification IDs remain excluded from backup.
- Restore inventories and scoped-cancels every destination reminder ID,
  including an ID held by a destination orphan row.
- Restored scheduling and rollback compensation operate only on configured
  reminders owned by an existing PREDMET.
- Users/PIN hashes remain portable. Destination security settings and previous
  audit remain local; one `full_backup_restore` audit event is appended.
- User warnings use plain Serbian wording and do not expose table names or
  internal relationship terminology.

No live cleanup, relinking, synthesized PREDMET, FK enablement, migration,
canonical database access, broad `cancelAll`, RI-3 recovery, Web work or
`OPC_v.1_Int` scope was introduced.

## 4. Reminder trigger clarification and anti-drift result

Source learning confirmed two separate meanings that must never again be
reported as one result:

```text
buildCeremonyReminderOccurrences:
    prepares future platform delivery slots for ceremony days -2 / -1 / 0

activeCeremonyReminderSlot:
    answers whether a configured reminder trigger is active now

future platform slot exists != active trigger now
```

The supplied backup preflight at the recorded 2026-07-31 evidence moment has
zero active triggers. Restore correctly rebuilds three future platform delivery
slots under owner policy 3A. Status was not introduced as a restore trigger
criterion, and the speculative local date/status gates were removed before the
final gate.

Code comments, focused tests and pseudocode now preserve this distinction.

## 5. Supplied-backup isolated preflight

Privacy-safe evidence retained in test output only:

- SHA-256:
  `128a282e4732e8d5843e4798d7d873bd187c49536bf0ac53d3bcbce53e41d459`;
- bytes: `106771315`;
- PREDMETI: `46`;
- reminders: `9 total / 7 transferred / 2 skipped`;
- active triggers at preflight: `0`;
- future platform schedules rebuilt and persisted: `3`;
- history: `230 total / 224 transferred / 6 skipped`;
- destination security/audit preserved;
- exactly one local restore audit event;
- referential check: clean.

No private path, PREDMET identity, personal data or backup payload is retained
in Git.

## 6. Test and failure matrix

Focused evidence covers:

- clean policy-3A reminder and policy-4A user/PIN/security/audit transfer;
- dirty FK-off export and coordinated round-trip;
- already-produced schema-8 orphan compatibility and reused-ID protection;
- malformed orphan, forbidden device IDs, duplicates, invalid types and missing
  required section remain blocking;
- coordinated validation failure preserves destination DB/media and
  compensates valid old reminders;
- destination orphan cancellation failure preserves DB/media and does not
  reactivate the orphan;
- schema-7 production coordinator cancellation and no invented settings;
- database failure transaction/media/reminder rollback;
- post-commit platform scheduling failure keeps restored DB/audit committed and
  returns a manual-check warning;
- future platform scheduling versus current-trigger separation.

Validation:

- focused reminder/lifecycle tests: PASS, `19/19`;
- related lifecycle/JSON/reminder regressions: PASS, `45/45`;
- exact supplied-backup preflight: PASS;
- `flutter analyze --no-pub`: PASS, no issues;
- complete `flutter test --no-pub`: PASS, `264 passed / 1 skipped / 0 failed`;
- Windows release build: PASS on final SHA; `build\\windows\\x64\\runner\\Release\\OPC.exe` present;
- Android release build: PASS on final SHA; `build\\app\\outputs\\flutter-apk\\app-release.apk` present.

The owner-provided build PASS is technical artifact evidence only; it is not
runtime acceptance. The Windows and Android runtime checks remain separate.

## 7. Independent controls

Three read-only watchdog roles were used before the final gate:

- contract review: final PASS; no unauthorized status/date policy change;
- incident review: required the history-row subfinding, plain user wording and
  explicit Git documentation;
- pre-runtime adversarial review: required coordinated schema-7/invalid paths,
  portable synthetic PIN-hash proof, post-commit scheduling failure evidence,
  exact three-slot persistence and trigger/scheduling separation.

Watchdog PASS is supporting evidence only. Source, focused tests, supplied-file
preflight and final automated gates remain the controlling technical evidence.

## 8. Remaining owner runtime acceptance

Android full restore must be repeated with a correction artifact. Technical
PASS does not predeclare runtime PASS. The runtime check must confirm:

- import completes without the previous safety error;
- restored PREDMET and unrelated data are usable;
- installation-local security remains local;
- reminder behavior follows restored configuration without immediate false
  trigger presentation;
- restart remains stable.

Windows and Android release artifacts have now been built successfully. No
additional PARTE, performance, mojibake/font-size, empty-content, RI-3,
anonymization or replacement scope is opened by this correction.

## 9. Completion boundary

This task is Git-complete only after the result commit and documentation closure
are pushed, local HEAD equals origin and the worktree is clean. The immutable
branch-tip SHA is also recorded in the final Git handoff because a commit cannot
contain its own hash.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

PREDMET remains authoritative:
- yes

Canonical/live database unchanged:
- yes

Windows/Android shared business logic preserved:
- yes

Unapproved Web, internationalization, migration or RI-3 scope introduced:
- no

PASS / NOT PASS:
- PASS, subject to Git completion and separate owner Android runtime retest
