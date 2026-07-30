# OPC task report - RI-2 full-restore lifecycle coordination

**Status:** `CUMULATIVE TECHNICAL PASS - OWNER RUNTIME ACCEPTANCE DEFERRED /
OWED`
**Date:** 2026-07-30

## OPC MANIFEST CHECK - TASK START

Manifest read:
- yes

Task class:
- production implementation / backup-restore lifecycle / tests /
  documentation

Core purpose and PREDMET authority preserved:
- yes

Post-zero owner authority:
- 3A and 4A explicitly accepted by the owner before implementation

Explicitly closed:
- anonymization and individual replacement;
- FK enablement and migration/orphan repair;
- canonical/live database access;
- OPC Web and `OPC_v.1_Int`.

## 1. Git baseline

- Base branch:
  `task/OPC-RI-2-HARD-DELETE-LIFECYCLE-COORDINATION`
- Base SHA:
  `7c93fddc9f11f901fba2983feca8b54ed7f0355c`
- Task branch:
  `task/OPC-RI-2-FULL-RESTORE-LIFECYCLE-COORDINATION`
- Implementation result SHA:
  `1adbb05260e245dbac7c72dfb6cb0db133e0110e`
- Report closure SHA:
  recorded by the Git completion handoff and readable from branch history

The base branch was equal to its upstream and the worktree was clean before
this task branch was created.

## 2. Owner decisions applied

Policy 3A:

- full backup carries reminder `enabled` and delivery times;
- device-local scheduled notification IDs never enter the backup;
- restore cancels destination IDs, clears their rows and generates new local
  IDs from restored PREDMET truth where scheduling is possible.

Policy 4A:

- users and PIN hashes remain portable;
- destination `security_settings`, including recovery material, remains local;
- existing destination `auth_audit_log` remains local;
- successful restore appends a destination-local `full_backup_restore` audit
  event.

These decisions do not supply authority for owner gates 1 or 2.

## 3. Implemented outcome

Full backup schema is advanced from 7 to 8 while single-PREDMET schema remains
7. Schema-7 full backups remain readable.

Before PREDMET IDs can be reused, restore explicitly clears:

- STANJE ROBE consequences/effects/items;
- IRiU lifecycle decisions and change log;
- reminder settings and PARTE preparations;
- contacts and IRiU rows;
- PREDMET rows and the remaining portable database families.

Logical reminder settings are validated against backup PREDMET IDs and imported
with an empty scheduled-ID list. The application restore coordinator:

1. inventories destination PREDMET reminders and owned PARTE media;
2. stages media through the recoverable trash mechanism;
3. cancels only stored/scoped notification IDs;
4. performs the full database replacement transaction;
5. purges staged media best-effort after commit;
6. rebuilds reminder schedules and reports per-PREDMET scheduling warnings.

All backup normalization/backfill work and the local audit append are now
inside the same DB transaction. A pre-commit failure restores media and
re-establishes the previous reminder schedule.

## 4. Focused proof

Only fresh in-memory SQLite databases and task-owned temporary media folders
were used. Canonical, backup and production runtime data were not opened.

Focused tests prove:

- schema 8 exports logical reminder configuration without device IDs;
- destination child/reminder/PARTE state cannot silently reassociate by reused
  local ID;
- new local reminder IDs are generated from restored truth;
- destination recovery material and prior auth audit survive;
- one successful-restore audit event is appended;
- schema-7 backup compatibility clears stale reminders without inventing
  settings;
- forced DB failure rolls back rows, restores staged media and reschedules the
  old reminder;
- representative JSON and RI-1 referential regressions remain green;
- `PRAGMA foreign_key_check` is clean in the isolated fixtures.

Result:

- focused Flutter tests: `PASS`, 29 passed, 0 failed;
- .NET strict UTF-8/no-BOM validation: `PASS`;
- `git diff --check`: `PASS`.

One initial focused-test invocation was terminated by an accidentally short
tool timeout before any result and was repeated correctly. A later
file-targeted `dart analyze` attempt produced no analysis result because the
tool could not write its telemetry/session file outside the workspace. Neither
attempt is classified as PASS or application failure.

## 5. Deliberate non-changes

- no schema-22 database migration;
- `PRAGMA foreign_keys` remains off;
- no orphan recovery or live/canonical database work;
- no anonymization or individual replacement behavior change;
- no notification `cancelAll`;
- no transfer of security recovery material or auth audit history;
- no Web, package, internationalization or IRiU ordering change.

The Incident/Anti-Drift Register remains controlling. Technical PASS is not
owner approval of any unrecorded business behavior.

## 6. Owner-provided cumulative technical gate - 2026-07-30

The owner manually executed the agreed PowerShell gate from the task branch at
final/report SHA `a1ec31fcd4b2113740a9e118a29c94a556f4243c`.

Git evidence:

- branch:
  `task/OPC-RI-2-FULL-RESTORE-LIFECYCLE-COORDINATION`;
- local HEAD:
  `a1ec31fcd4b2113740a9e118a29c94a556f4243c`;
- upstream:
  `a1ec31fcd4b2113740a9e118a29c94a556f4243c`;
- worktree output contained no changed-file entry.

Owner-provided command results:

- `flutter analyze --no-pub`: `PASS`, no issues, 47.8 s;
- complete `flutter test --no-pub`: `PASS`, 258 passed, 1 skipped,
  0 failed, 16:55;
- Windows release build: `PASS`, 152.4 s;
- Windows artifact: `build/windows/x64/runner/Release/OPC.exe`,
  89,088 bytes;
- Android APK release build: `PASS`, 711.1 s;
- Android artifact: `build/app/outputs/flutter-apk/app-release.apk`,
  77,025,022 bytes (reported by Flutter as 73.5 MB).

This closes the cumulative static/test/build gate as technical `PASS`.
Windows/Android owner runtime acceptance for hard delete and full restore
remains `DEFERRED / OWED`; it is not inferred from successful builds.

## 7. Owner Windows hard-delete runtime result - 2026-07-30

The owner executed the Windows hard-delete acceptance against the built task
result and confirmed:

- deleted synthetic PREDMET disappears from the list;
- the application remains stable;
- restart does not restore the deleted PREDMET;
- other existing PREDMETI and their PARTE remain intact.

Windows hard-delete owner runtime acceptance is therefore `PASS`.

The same runtime session produced three separate PARTE observations. They do
not invalidate hard-delete PASS and are not silently folded into its scope:

1. **PARTE preparation performance:** the owner perceived preparation as
   slower than before. This is an observation only. No timing, comparison
   baseline or profiler evidence currently proves a regression or cause.
2. **Warning mojibake/internal terminology:** screenshot evidence shows
   `Obavezni blok mourners nema sadrÅ¾aj za izvoz.` Source confirms both
   defects in `parte_composer.dart`: a mojibake string literal and direct
   interpolation of the internal block ID. Owner confirms that user-facing
   text must use the Serbian business label `Ožalošćeni`, never `mourners`.
3. **Displayed font-size mismatch:** screenshot evidence and source confirm
   that the editor field displays draft `initialFontSize`, while the preview
   renders the fitted `ParteRenderBlock.fontSize`. Preview block selection also
   changes only the selected ID without synchronizing the controller. The
   displayed value therefore need not represent the actual rendered size.

The screenshots were visually reviewed but are not copied into Git because
they contain runtime photographs and user-visible data. The two source-confirmed
UI defects require a separate owner-notified application task. Performance
requires targeted timing/profiling before any cause or correction is chosen.

## 8. Owner Android hard-delete runtime result - 2026-07-30

The owner confirmed on Android:

- deleted synthetic PREDMET disappears from the list;
- the application remains stable;
- restart does not restore the deleted PREDMET;
- other existing PREDMETI and their PARTE remain intact.

This is `PASS` for the Android UI/database persistence and isolation portion of
hard delete. The report did not state whether a previously scheduled reminder
for the deleted PREDMET was observed not to arrive. Scoped Android notification
cancellation therefore remains an explicit owed acceptance point; it is not
inferred from disappearance of the database row.

Android independently reproduced the same mojibake/internal-`mourners` warning
and initial-versus-rendered font-size mismatch seen on Windows. This confirms
cross-platform visibility of the already source-confirmed defects; it does not
create a second hypothesized cause.

The owner also established a new global PARTE policy and then clarified its
structural boundary: the defined blocks remain mandatory in the template/draft,
but every individual block's content may be empty. A mandatory block with empty
content is omitted from display/export and must not block preparation
confirmation or completion. This includes both the `Ožalošćeni` heading and
content because the family may request no listed names. Source confirms the
current conflict:

- composition initially skips every empty text block;
- `ParteRenderPlan.requiredTextBlockIds` then tests required structure against
  the content-bearing render output and classifies seven empty rendered blocks
  as structurally missing blockers;
- export validation repeats the same structure-versus-content conflation.

The policy decision is recorded as post-zero owner authority. No test/source
was changed to claim implementation or PASS.

## 9. Remaining runtime and next dependency

Android scoped reminder cancellation and Windows/Android full-restore owner
runtime acceptance remain `DEFERRED / OWED`. The next dependency must be
selected from the approved plan after those results are recorded. This task
does not automatically authorize anonymization, individual replacement, RI-3
data repair, FK enforcement, canonical data access or international scope.

## 10. Owner Android full-restore result - 2026-07-30

Android full restore is `FAIL`.

The application displayed a reminder-section safety error and stopped before
destination mutation. The owner supplied the exact generated backup for
read-only diagnosis. The file passed strict .NET UTF-8/no-BOM validation.
Privacy-safe metadata inspection proved:

- format `OPC_BACKUP`, schema version 8;
- 46 transferred PREDMET rows;
- 9 logical reminder rows;
- 2 reminder rows reference no transferred PREDMET;
- 0 non-object rows, invalid IDs, invalid enabled values, invalid delivery-time
  containers/items, duplicate PREDMET reminder rows or forbidden
  `scheduledNotificationIds` keys;
- no transferred `securitySettings` or `authAuditLog` sections, consistent
  with owner policy 4A.

Root cause is confirmed:

1. schema-8 export reads every FK-off `ceremony_reminder_settings` row without
   restricting it to exported PREDMET IDs;
2. the source database contained two pre-existing orphan reminder rows;
3. schema-8 import rejects any reminder whose parent is absent;
4. the application therefore rejected a backup produced by its own exporter.

The fail-safe validation preserved destination data, but full-restore usability
failed. This is recorded as `INC-003`. Correction requires a separate
owner-notified application branch and must cover both future export filtering
and compatibility for already-produced schema-8 backups. Until correction and
Android retest pass, full-restore runtime acceptance is `FAIL`, not merely owed.

## OPC MANIFEST COMPLIANCE - TASK END

Manifest compliance checked:
- yes

PREDMET meaning and derivative boundary preserved:
- yes

Windows/Android business-result design parity preserved:
- yes; owner runtime proof remains owed

Technical PASS and owner runtime acceptance recorded separately:
- yes

Git completion:
- implementation result commit recorded above;
- report closure commit/push/upstream equality/clean worktree recorded in the
  final Git handoff.
