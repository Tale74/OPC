# OPC post-zero PREDMET lifecycle and referential-integrity design

**Status:** `DESIGN PASS - IMPLEMENTATION NOT AUTHORIZED`
**Application evidence baseline:**
`e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
**Documentation base:** `6acd5ac663b5fd4527375923463169784cd27d07`
**Date:** 2026-07-30

## 1. Purpose and authority boundary

This document turns the confirmed FK-off/orphan/privacy findings into an exact
RI-1 through RI-5 implementation design. It changes no application source,
test, schema, migration, database, JSON or runtime behavior.

PREDMET remains the sole business truth. The lifecycle coordinator defined
here does not own a second copy of PREDMET. It coordinates database truth with
app-owned filesystem and OS side effects that cannot participate in the same
SQLite transaction.

Pre-zero lifecycle/log/backup business decisions are evidence only. Where this
design reaches an actual business-policy choice, the choice remains explicitly
closed pending post-zero owner authority.

## 2. Confirmed current state

Current source and isolated fixture evidence establish:

- production and test connections do not enable `PRAGMA foreign_keys`;
- the verified current connection reports `foreign_keys=0`;
- declared `ON DELETE CASCADE` relations therefore express schema intent but
  do not provide current runtime cleanup;
- hard delete explicitly handles stock, log, contacts, IRiU and IRiU lifecycle
  decisions, then deletes PREDMET;
- hard delete does not explicitly handle PARTE preparation/media, reminder
  configuration or Android scheduled notifications;
- anonymization redacts selected PREDMET/contact fields but does not sanitize
  PARTE drafts/media, raw log snapshots or reminder payload state;
- individual replacement clears log/contacts/IRiU/IRiU decisions and replaces
  PREDMET under the same local ID, but leaves old PARTE/reminder derivatives;
- full restore deletes PREDMET and selected tables while FK enforcement is off,
  but does not first clear every PREDMET child table or current device
  notification state;
- PARTE already has a recoverable stage/restore/purge media-deletion seam;
- STANJE ROBE already has explicit delete/replacement compensation;
- reminder persistence already retains the exact device notification IDs
  needed for scoped cancellation.

No corruption claim is made. The confirmed result is missing lifecycle
coordination and orphan/privacy risk.

## 3. Exact dependency classification

| Dependency | Class | Physical relation | Portable | Required lifecycle ownership |
| --- | --- | --- | --- | --- |
| `predmeti` | authoritative business truth | parent | yes | PREDMET repository transaction |
| `kontakt_lica` | PREDMET child truth | cascade FK | yes | explicit delete/redact, later cascade defense |
| `iriu` | PREDMET child/operational truth | cascade FK | yes | explicit delete/reconcile, later cascade defense |
| `iriu_lifecycle_decisions` | PREDMET child control state | custom cascade FK | yes where format supports it | explicit delete |
| `log_izmena` | mixed raw checkpoint/audit evidence | cascade FK | full backup only today | explicit privacy-safe treatment; business event model separately gated |
| `parte_pripreme` | PREDMET-derived technical state | cascade FK | no today | invalidate/delete with media-aware compensation |
| PARTE app-owned media | filesystem derivative | logical media key | no | stage, restore on DB failure, purge after commit |
| `ceremony_reminder_settings` | PREDMET-derived logical/device state | custom cascade FK | not today | cancel scoped OS IDs before delete; explicit row cleanup |
| Android pending notification | device OS derivative | payload/local IDs | no | scoped cancel/recovery; never `cancelAll` |
| `stanje_robe_posledice` | current operational consequence | cascade FK to PREDMET/IRiU | supported backup state | existing compensation then explicit cleanup |
| `stanje_robe_applied_effects` | non-PII reconciliation history/current effect | logical IDs | supported backup state | existing restore/clear classification |
| adviser/creator/modifier IDs | local authorship metadata | logical user IDs | depends on transfer form | existing identity/rebind guard; never guessed |
| PARTE template snapshot/reference | technical provenance | logical template ID | preparation not portable today | snapshot preserves historical render input |
| KATALOG/stock stable IDs | knowledge/operational identity | logical stable IDs | yes where supported | no guessed relinking |
| `security_settings` / `auth_audit_log` | installation security state | no PREDMET FK | not PREDMET lifecycle | explicitly outside PREDMET cascade |

Unknown relationships stop RI work. They are not assigned by matching IDs,
names or category text.

## 4. Lifecycle coordinator contract

Introduce one application-level coordinator around existing repositories and
services. Physical class/file names remain implementation details.

Required commands:

```text
deletePredmet(predmetId, actor/context)
anonymizePredmet(predmetId, actor/context)
replacePredmet(predmetId, validatedImport, actor/context)
restoreFullBackup(validatedBackup, actor/context)
recoverInterruptedLifecycle()
```

Required collaborators:

- PREDMET repository/database transaction;
- `StanjeRobeLifecycleService`;
- PARTE preparation repository and media store;
- ceremony reminder repository/coordinator/gateway;
- log/checkpoint adapter;
- backup/restore transaction adapter;
- technical recovery reporter containing counts/status only, never raw PII.

The coordinator owns ordering and compensation. Each collaborator retains its
own data/side-effect responsibility.

## 5. Operation designs

### 5.1 Hard delete

Hard delete has no valid outcome in which a PREDMET-derived child remains
active after PREDMET no longer exists.

Required order:

1. load PREDMET existence and exact derivative inventory;
2. stop if PARTE media ownership is ambiguous;
3. stage exclusively owned PARTE media using the existing recoverable trash
   mechanism;
4. cancel only stored/scoped OPC reminder notification IDs;
5. run one database transaction:
   - reconcile current stock effects;
   - delete reminder configuration explicitly;
   - delete PARTE preparation explicitly;
   - delete log/checkpoints, contacts, IRiU lifecycle decisions and IRiU;
   - delete PREDMET;
6. after commit, purge staged app-owned media;
7. report success only after the authoritative database mutation commits.

Failure rules:

- failure before database commit leaves PREDMET authoritative;
- restore staged media after database failure;
- reschedule eligible reminders from still-existing PREDMET truth after a
  successful cancellation followed by database failure;
- a purge failure after commit becomes scoped app-owned trash recovery, not a
  PREDMET rollback;
- retries are idempotent.

### 5.2 Anonymization

Current technical evidence proves that derivatives can retain values removed
from PREDMET/contact fields.

The coordinator must be able to:

- cancel/delete active reminder state whose payload/text may expose identity;
- delete or irreversibly sanitize app-owned PARTE preparation/media;
- remove or transform raw log/checkpoint PII;
- commit PREDMET/contact redaction atomically where SQLite permits;
- retain only technical/audit metadata explicitly allowed by post-zero policy.

Exact retention of user-visible audit events and completed PARTE output after
anonymization is a post-zero owner business/privacy decision. RI
implementation must not silently choose it.

### 5.3 Individual PREDMET replacement

Required technical outcome:

- no pre-replacement PARTE/reminder derivative may appear current after the
  PREDMET business state is replaced under the same local ID;
- old stock effects are compensated before imported consequences are applied;
- foreign local IDs/history are not imported or guessed;
- imported child truth is validated before mutation.

Required order mirrors hard delete for old derivatives:

1. validate the complete incoming PREDMET/child set without mutation;
2. inventory and stage old app-owned derivatives;
3. cancel old reminder IDs;
4. transactionally reconcile stock, clear old child truth/control state,
   replace PREDMET and insert validated incoming children;
5. purge staged old media after commit;
6. create/reschedule only from the new authoritative truth.

Whether destination-local user-visible audit history is retained across
replacement is a post-zero owner business-history decision. Raw checkpoint PII
cannot remain as if it described the new truth.

### 5.4 Full backup restore

Restore is a complete-family replacement, not a sequence of independent
`insertOrReplace` operations over uncleared PREDMET IDs.

Required preflight:

- validate backup type/version, FIRMA/repository identity rules and every row
  before mutation;
- create and prove a readable SQLite-consistent backup of the isolated target;
- run only on an isolated target copy until live authorization;
- inventory current device-local notification/media state.

Required mutation boundary:

1. stage current app-owned PARTE media that restore will invalidate;
2. cancel scoped current-device OPC reminder notifications;
3. in one transaction, clear exact dependent tables before PREDMET parents;
4. restore portable tables in dependency order;
5. reject orphan or mismatched rows; never relink by coincident local ID;
6. after commit, purge invalidated staged media;
7. rebuild only explicitly portable logical configuration from restored truth;
8. run integrity, row-count, representative-value and business-identity checks.

Whether logical reminder preferences are portable, and which installation-local
security/audit state survives restore, require post-zero owner confirmation.
Device notification IDs are never portable.

## 6. RI-1 through RI-5 delivery sequence

Each stage is a separate task/commit boundary unless its task explicitly proves
that combining stages reduces rather than increases migration risk.

### RI-1 - committed characterization and inventory

No production behavior change.

Deliver:

- committed in-memory tests for current hard-delete, anonymization,
  replacement and restore defects;
- declared-FK inventory using `PRAGMA foreign_key_list`;
- `PRAGMA foreign_keys` and `foreign_key_check` assertions;
- exact table/orphan count helper returning metadata only;
- current media/reminder/stock compensation characterization;
- supported historical/current isolated schema fixtures;
- explicit stop on an unclassified owner/reference.

RI-1 tests lock observed current behavior as evidence. They do not approve that
behavior as future business policy.

RI-1 execution result (2026-07-30):

- committed isolated characterization:
  `test/predmet_lifecycle_referential_characterization_test.dart`;
- seven PREDMET dependencies and metadata-only orphan counters are locked;
- hard delete is proven to leave PARTE/reminder FK orphans;
- anonymization is proven to retain synthetic derivative PII;
- replacement is proven to retain stale local PARTE/reminder state;
- full restore is proven able to silently re-associate a stale reminder by
  reused local ID with a clean `foreign_key_check`;
- no production behavior, schema, migration, FK setting, canonical data or
  business policy changed.

The remaining delivery sequence is unchanged. RI-2 requires separate exact
implementation authorization.

### RI-2 - explicit lifecycle coordination while FK remains off

Only after RI-1 PASS and exact implementation authorization.

Deliver:

- coordinator and collaborator contracts;
- hard-delete coordination first;
- replacement/restore coordination only after their post-zero transfer/history
  gates are closed;
- anonymization derivative handling only after its post-zero privacy gate;
- explicit dependent-row cleanup independent of cascades;
- deterministic failure/compensation results.

`PRAGMA foreign_keys` remains off in RI-2.

RI-2 hard-delete execution result (2026-07-30):

- one application coordinator now owns DB/filesystem/notification ordering;
- both production delete entry points route through it;
- the DB transaction explicitly removes every declared PREDMET child;
- exclusive PARTE media is staged and purged; shared media is retained;
- cancellation is limited to stored OPC notification IDs;
- failure tests prove DB preservation, media restoration and reminder
  rescheduling;
- FK enforcement remains off and no schema/migration was added.

This closes only the hard-delete implementation slice. Anonymization,
replacement and restore remain blocked by their recorded owner gates.

### RI-3 - isolated orphan recovery migration

Only on synthetic and verified isolated copies:

- classify every orphan by table and risk;
- compensate external OS/media state before deleting technical rows where
  possible;
- delete only proven invalid children;
- retain only explicitly classified non-PII technical/security history;
- record counts/status without row content;
- prove idempotent retry and zero unexpected FK violations.

Live canonical execution requires a later exact owner authorization.

### RI-4 - enable referential enforcement

Only after RI-1 through RI-3 PASS:

- enable `PRAGMA foreign_keys = ON` for every supported production and test
  connection;
- assert it on every opened connection;
- prove migration, recovery, seed/backfill and startup behavior under
  enforcement;
- retain explicit lifecycle coordination for files, OS notifications and stock;
- stop on any supported fixture that cannot open without silent deletion.

### RI-5 - restore/import/parity and rollback proof

Prove:

- full restore across every supported backup/schema fixture;
- replacement never retains stale derivatives;
- hard delete leaves no app-owned orphan/media/notification;
- authorized anonymization semantics leave no forbidden PII;
- interruption/retry at each external/transaction boundary;
- backup restoration to the exact pre-task state;
- equivalent Windows and Android business/data results;
- Android device notification proof where applicable.

Only RI-5 can open a later live-canonical/runtime acceptance gate.

## 7. Required test matrix

Minimum fixture axes:

- current schema 22, supported older checkpoints and interrupted migrations;
- no children / every child family / mixed valid and orphan rows;
- no media / exclusive media / shared media / missing media;
- no reminder IDs / valid IDs / stale IDs / malformed unrelated payload;
- no stock effect / applied effect / pending consequence;
- database failure before commit / during transaction / after external
  cancellation;
- media stage failure / restore failure / purge failure;
- new import / replacement / full restore;
- Windows logical no-op notification adapter / Android fake gateway / later
  Android device;
- repeated execution proving idempotency.

Forbidden shortcuts:

- enabling FK first and letting cascade discover cleanup behavior;
- `cancelAll` notifications;
- deleting shared/external media;
- matching an orphan to PREDMET by coincident local ID;
- using canonical data as a fixture;
- treating a focused test as complete-suite PASS;
- changing lifecycle meaning under a refactor label.

## 8. Backup, rollback and live-data gate

Every data-affecting task must:

1. identify exact source/target database lane;
2. close all OPC processes and resolve WAL/SHM state;
3. create a SQLite-consistent backup;
4. prove backup readability and record metadata-only integrity/hash/size/schema
   evidence;
5. execute first on a copy;
6. prove restore rehearsal before accepting migration;
7. define rollback before commit and forward-fix after irreversible external
   effects;
8. never merge a test database into a canonical database;
9. obtain explicit owner authorization before live canonical opening by a
   migration-capable build.

## 9. Post-zero owner decision gates

These are actual business/privacy/transfer choices and are not answered by
source or technical PASS:

1. **Anonymization derivative retention:** after PREDMET/contact redaction,
   must app-owned completed PARTE preparation/media and user-visible audit
   events be deleted, irreversibly sanitized, or retained under a precisely
   stated rule?
2. **Replacement local history:** should destination-local user-visible audit
   history survive individual PREDMET replacement, or should replacement start
   a new local history containing only the replacement event?
3. **Full-backup reminder portability:** should logical reminder enablement and
   delivery times move with a full backup, while device notification IDs are
   always discarded?
4. **Installation-local security state on restore:** should security settings
   and auth audit remain from the destination installation, be restored from
   the backup family, or follow another explicit rule?

RI-1 can proceed without these decisions. A later RI-2/RI-5 implementation
must stop at the affected boundary until the relevant answer is recorded
post-zero.

## 10. Acceptance and completion

Technical acceptance requires:

- zero unexpected `foreign_key_check` rows;
- `foreign_keys=1` only after RI-4;
- no invalid PREDMET child after delete/replacement/restore;
- no forbidden raw PII after authorized anonymization behavior;
- no app-owned exclusive PARTE media after hard delete;
- no pending deleted-PREDMET notification;
- no stale local-ID reassociation after restore;
- proven backup/restore and retry;
- Windows/Android result parity;
- focused tests, analyzer PASS, complete test PASS and authorized builds in the
  required successive order;
- technical PASS and owner runtime acceptance recorded separately.

This design is complete. Application implementation remains closed.
