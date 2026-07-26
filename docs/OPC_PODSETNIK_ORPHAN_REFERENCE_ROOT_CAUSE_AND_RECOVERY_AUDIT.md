# OPC PODSETNIK orphan reference root-cause and recovery audit

Status: `CODE-FIRST ROOT-CAUSE AUDIT PASS — IMPLEMENTATION NOT AUTHORIZED`

Audit date: 2026-07-26

Base branch: `task/OPC-GATE-0-PREDMET-LIFECYCLE-LOG-RETENTION-AUDIT`

Base SHA: `3a893b2b868036128f9b71f01086753a0a989bc0`

Task branch: `task/OPC-GATE-0-PODSETNIK-ORPHAN-REFERENCE-AUDIT`

## 1. Scope

This docs-only audit determines why PODSETNIK can retain a reference to a
deleted PREDMET and defines the minimum safe correction/recovery boundary.

It does not implement reminders, notifications, database changes, tests,
builds or runtime behavior. It does not decide the later expanded PODSETNIK
business-tracking model.

PREDMET remains the sole authoritative business truth. PODSETNIK owns only
local reminder configuration and delivery infrastructure derived from current
PREDMET facts.

## 2. Source evidence

### 2.1 Reminder persistence

`lib/core/database/database.dart` creates
`ceremony_reminder_settings` with:

- `predmet_id` as primary key;
- a declared foreign key to `predmeti(id) ON DELETE CASCADE`;
- enabled state;
- delivery times;
- scheduled platform-notification IDs;
- update timestamp.

`lib/features/predmeti/reminders/ceremony_reminder_repository.dart` reads and
writes this table through custom SQL.

### 2.2 Foreign-key enforcement is not enabled

`lib/core/database/database.dart` opens production storage through
`driftDatabase(name: kDatabaseName)` and test storage through
`NativeDatabase`, but contains no `PRAGMA foreign_keys = ON` and supplies no
native connection setup that enables it.

The resolved `drift_flutter` connection implementation uses the optional
`DriftNativeOptions.setup` callback when supplied; OPC does not supply one.
The resolved Drift source documents explicit `PRAGMA foreign_keys = ON` as the
application action required to enforce declared foreign keys.

Therefore the declared `ON DELETE CASCADE` is not a proven runtime cleanup
mechanism. Current `PredmetiRepository.obrisiPredmet` explicitly deletes
several dependent tables, but does not explicitly delete
`ceremony_reminder_settings`.

Result: a local SQLite reminder row can remain after its PREDMET is deleted.

This finding also requires a future broader foreign-key integrity audit before
global enforcement is enabled. Global enforcement must not be introduced as an
unreviewed side effect of the narrow PODSETNIK correction.

### 2.3 Android notifications are external to SQLite

`lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`:

- reads stored notification IDs;
- explicitly cancels them only during `reschedule`;
- schedules Android notifications with payload `predmet:<local-id>`;
- saves the resulting platform IDs back into SQLite.

`lib/features/predmeti/reminders/ceremony_notification_gateway.dart` exposes
explicit `cancel(id)` and `schedule(...)`.

`PredmetiRepository.obrisiPredmet`, the detail screen and the list screen do
not invoke the reminder coordinator/gateway before deletion.

Deleting a SQLite row cannot cancel an already scheduled Android OS
notification. After the row is deleted, OPC also loses the stored IDs needed
for direct cancellation.

Result: an Android notification containing deleted-PREDMET identity and
`predmet:<id>` payload can remain scheduled after hard deletion.

### 2.4 Startup/resume does not recover orphans

`lib/features/predmeti/presentation/lista_predmeta_screen.dart` runs reminder
reconciliation at startup/resume, but iterates only over PREDMET rows that still
exist. It reschedules those PREDMET records and never enumerates:

- orphan `ceremony_reminder_settings` rows;
- platform pending notifications whose payload references a missing PREDMET.

The resolved `flutter_local_notifications` 22.0.1 API supports
`pendingNotificationRequests()`, but the current OPC gateway does not expose
it.

### 2.5 Full-backup restore creates an additional orphan/collision path

`lib/core/utils/json_export_import.dart` does not export or import
`ceremony_reminder_settings`.

During full restore it deletes/replaces PREDMET and multiple related tables,
but it neither:

- cancels current-device pending ceremony notifications;
- clears `ceremony_reminder_settings`;
- restores logical reminder configuration;
- reschedules reminders for the restored PREDMET family.

Because reminder rows are keyed only by local integer `predmet_id`, a stale row
may later become associated with a different restored PREDMET using the same
local ID. Scheduled OS payloads may likewise refer to an ID whose business
identity has changed after restore.

This is a data-integrity defect, not merely a stale visual reference.

### 2.6 Current tests

`test/ceremony_reminder_system_test.dart` proves:

- scheduling windows;
- reschedule cancellation/replacement;
- configuration persistence;
- idempotent saving of identical notification IDs.

It does not prove:

- delete cancellation;
- deletion of reminder settings;
- foreign-key enforcement;
- startup orphan recovery;
- restore cleanup/rebinding;
- payload validation against current PREDMET existence;
- Android closed-app delivery after deletion.

`test/canonical_database_migration_recovery_test.dart` proves the reminder table
exists in relevant migration fixtures, but does not characterize its foreign
key or orphan behavior.

## 3. Root-cause conclusion

The observed orphan behavior has two independent, source-confirmed causes:

1. **SQLite lifecycle gap** — reminder settings rely on a declared cascade that
   is not runtime-proven/enabled, while explicit PREDMET deletion omits the
   reminder table.
2. **OS lifecycle gap** — scheduled Android notifications are external side
   effects and are never cancelled before PREDMET deletion.

Full-backup restore adds a third trigger path by replacing PREDMET identity
without clearing/cancelling/rebuilding reminder state.

The earlier description “source-supported candidate” can now be replaced with
`ROOT CAUSE CONFIRMED FROM SOURCE`.

Runtime reproduction remains required for acceptance, but it is not needed to
ask the owner to choose among technical causes.

## 4. Minimum safe correction architecture

### 4.1 PREDMET deletion orchestration

Both PREDMET deletion entry points must call one application-level deletion
orchestrator. The orchestrator must:

1. load the authoritative PREDMET and its reminder configuration/notification
   IDs;
2. initialize the platform gateway;
3. cancel every stored notification ID idempotently;
4. delete reminder settings explicitly;
5. execute the existing PREDMET/dependent-data deletion;
6. report failure without claiming successful deletion.

The repository must remain responsible for database truth. The application
service coordinates the non-transactional OS side effect.

### 4.2 Failure and crash semantics

SQLite and the Android notification scheduler cannot share one transaction.
The safe order is cancellation before loss of IDs/PREDMET.

- If cancellation fails, hard deletion must stop and return a clear error.
- Repeated cancellation must be safe.
- If cancellation succeeds but database deletion fails, PREDMET remains
  authoritative and startup/resume reconciliation must restore its eligible
  reminders.
- If the process terminates between cancellation and database deletion,
  startup/resume reconciliation likewise repairs the still-existing PREDMET.

This favors retained PREDMET truth over an orphan notification.

### 4.3 Existing-orphan recovery

Startup/resume reconciliation must perform two scoped checks:

1. SQLite:
   - find reminder rows whose `predmet_id` has no PREDMET;
   - cancel their stored IDs;
   - delete those orphan rows.
2. Platform:
   - enumerate pending OPC notification requests;
   - strictly parse only current OPC ceremony payloads
     `predmet:<positive-local-id>`;
   - cancel only those whose PREDMET no longer exists.

It must not call a broad `cancelAll`, because future or existing unrelated OPC
notifications must remain intact.

Unknown or malformed payloads must not be guessed or relinked.

### 4.4 Full-backup behavior

A full local database backup should preserve logical user configuration but
must not transfer device-local scheduled notification IDs.

Required future behavior:

- export `enabled` and normalized delivery times for valid PREDMET rows;
- exclude/reset `scheduled_notification_ids`;
- before restore, cancel current-device pending OPC ceremony notifications;
- clear current reminder rows;
- import only configs whose restored PREDMET exists;
- reschedule from restored authoritative PREDMET facts on the destination
  device;
- reject or ignore orphan config rows without guessed relinking.

This gives Windows and Android the same saved business preference while
allowing different OS delivery mechanisms.

### 4.5 Foreign-key boundary

The narrow correction must explicitly clean reminder rows and must not depend
only on cascade behavior.

Before a future task enables `PRAGMA foreign_keys = ON` globally, it must:

- inventory every declared/implicit relationship;
- run `PRAGMA foreign_key_check` against supported canonical databases;
- define cleanup for existing orphans;
- characterize current manual deletion order;
- prove migrations, full restore and replacement under enforcement;
- prevent startup failure or silent data deletion.

That broader integrity audit is a technical prerequisite, not an owner business
question.

## 5. Payload and navigation guard

Current notification initialization does not implement a PREDMET navigation
callback. Future closed-app/tap implementation must:

- parse the payload strictly;
- load the current PREDMET before navigation;
- do nothing except dismiss/cancel when the PREDMET is missing;
- never reconstruct or relink a PREDMET from notification text/payload;
- never treat notification acknowledgement as business completion.

This guard is defense in depth. It does not replace cancellation/recovery.

## 6. Future implementation proof

A separately authorized implementation task must add:

- repository test proving no reminder row remains after hard delete;
- fake-gateway test proving cancellation precedes database deletion;
- cancellation-failure test proving PREDMET is retained;
- database-delete-failure compensation/reconciliation test;
- startup SQLite orphan cleanup test;
- pending-platform orphan payload cleanup test;
- malformed/unrelated payload preservation test;
- full-backup logical-config round trip without platform IDs;
- restore test preventing stale local-ID reassociation;
- migration tests with existing orphan rows;
- Android device proof that deleted-PREDMET notifications are not delivered;
- Windows proof of equivalent logical cleanup despite a different/no-op OS
  scheduling mechanism.

Validation order remains:

1. final `flutter analyze --no-pub` PASS;
2. complete `flutter test --no-pub` PASS;
3. builds only after owner approval;
4. technical PASS distinct from owner runtime acceptance.

## 7. Decision disposition

No new owner decision is required to correct the orphan reference.

The separate `ODQ-PODSETNIK-001` business-tracking questions remain open for
the later expansion of PODSETNIK. They do not block this integrity correction.

## 8. Final status

`PODSETNIK ORPHAN ROOT CAUSE CONFIRMED — SQLITE AND OS LIFECYCLES BOTH INCOMPLETE — SAFE DELETION/RECOVERY/RESTORE BOUNDARY DEFINED — IMPLEMENTATION NOT AUTHORIZED`
