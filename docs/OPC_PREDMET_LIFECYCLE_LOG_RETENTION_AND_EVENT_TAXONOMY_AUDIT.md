# OPC PREDMET lifecycle, log retention and event taxonomy audit

Current-authority reconciliation (2026-08-21): this document records the
pre-implementation baseline. The bounded same-identity replacement seam now
preserves destination-local `logIzmena` and appends `IMPORT_REPLACE`
transactionally; checkpoint/event-store separation, privacy migration and
new-import event work remain future scope.

Status: `CODE-FIRST TECHNICAL AUDIT PASS — IMPLEMENTATION NOT AUTHORIZED`

Audit date: 2026-07-26

Base branch: `task/OPC-GATE-0-LOCAL-USER-IDENTITY-TRANSFER-REBIND-AUDIT`

Base SHA: `aa2eeb89898bd3a5ebd62a4f1555d90c18a33ee4`

Task branch: `task/OPC-GATE-0-PREDMET-LIFECYCLE-LOG-RETENTION-AUDIT`

## 1. Scope and control boundary

This docs-only Gate 0 audit resolves the technical questions remaining under
`ODQ-PREDMET-HISTORY-004`:

- retention of business-visible PREDMET events;
- behavior of the local log on anonymization and hard deletion;
- final minimum event taxonomy;
- separation of hidden technical checkpoints from user-visible audit events;
- legacy-row migration constraints;
- suitability of `Pregled i potvrda` as the review location.

No application source, database schema, migration, test, build configuration or
runtime behavior is changed by this audit.

The governing constants remain:

- PREDMET is the sole authoritative business truth;
- the log explains local actions but does not become a second PREDMET;
- individual PREDMET JSON does not transfer local audit history;
- full backup restores the complete local database family;
- Windows and Android must expose equivalent business meaning;
- raw previous/new PREDMET values are not user-visible audit data;
- technical questions are answered from source before any owner question.

## 2. Source evidence

### 2.1 Current table mixes two responsibilities

`lib/core/database/tables/log_izmena_table.dart` defines one `logIzmena` table
with `predmetId`, `korisnikId`, `timestamp`, `polje`, `staraVrednost` and
`novaVrednost`.

`lib/features/predmeti/data/predmeti_repository.dart` uses that table both for:

- lifecycle entries such as `radni_ciklus`; and
- raw JSON snapshots identified by `__save_commit_snapshot__` and
  `__confirmed_close_snapshot__`.

The snapshot is broad PREDMET-row data and contains personal/business values.
It is not a safe user-facing audit event.

### 2.2 Current lifecycle behavior

`lib/features/predmeti/data/predmeti_repository.dart` confirms:

- close writes a confirmed-close snapshot, save checkpoint and
  `radni_ciklus` event;
- reopen writes `radni_ciklus` and establishes missing checkpoints;
- ordinary save writes a raw save checkpoint;
- automatic `ZAVRŠEN` mutation uses the generic update path and does not write
  a dedicated lifecycle event;
- anonymization changes/redacts PREDMET/contact data and status but does not
  receive an actor and does not append an anonymization event;
- hard deletion explicitly removes `logIzmena` and other dependent PREDMET
  data;
- replacement import currently deletes the local log before replacing the
  business state.

`lib/features/predmeti/presentation/predmet_screen.dart` and
`lib/features/predmeti/presentation/lista_predmeta_screen.dart` pass the local
actor for close/reopen but not for anonymization or deletion.

The same screens communicate hard deletion as permanent deletion of PREDMET
and dependent data. Anonymization leaves the PREDMET present with
`ANONIMIZOVAN` status.

### 2.3 Import and backup boundary

`lib/core/utils/json_export_import.dart` and
`lib/features/predmeti/data/predmeti_repository.dart` confirm:

- individual PREDMET JSON does not carry `logIzmena`;
- new individual import does not append a local import event;
- replacement deletes the existing local log and appends no replacement event;
- full backup exports/imports the complete `logIzmena` table together with the
  local user/PREDMET database family.

### 2.4 Review UI

`lib/features/predmeti/presentation/predmet_screen.dart` defines the existing
`Pregled i potvrda` segment and already presents lifecycle status, business
version, saved/unsaved state and lifecycle actions.

This is source-confirmed as the correct future location for a concise
business-event overview. No separate technical/debug screen is required.

### 2.5 Test evidence

No focused tests were found that lock:

- anonymization event and retention behavior;
- deletion retention behavior;
- import-new/import-replace events;
- separation of checkpoint and audit data;
- migration of legacy raw snapshots;
- complete event taxonomy;
- Windows/Android review parity.

Existing PARTE preparation tests only prove lifecycle blocking while a PARTE
preparation is incomplete. They do not characterize the local audit model.

## 3. Technical conclusions

### 3.1 Two stores are required

The current table must not remain both a technical comparison mechanism and a
user audit surface.

Future authorized implementation should use two explicit responsibilities:

1. hidden PREDMET business checkpoints used only for save/close/version
   comparison;
2. local PREDMET audit events used for the user-visible review.

The exact physical table names are an implementation detail. The required
semantic separation is not optional.

### 3.2 Hidden checkpoint model

A checkpoint should contain only data needed to prove equality/change:

- local `predmetId`;
- checkpoint kind, at minimum working-save and confirmed-close;
- canonical aggregate hash;
- optional per-segment hashes needed to derive changed segment identifiers;
- business version;
- aggregate coverage/schema version;
- creation timestamp.

It must not contain raw PREDMET, SCENARIO, IRiU or contact values.

The canonical aggregate must follow the separately closed business-version
decision and cover authoritative PREDMET truth, including SCENARIO and
applicable IRiU/contact business data. A hash is comparison evidence, not a
second source of truth.

### 3.3 Local audit-event model

An audit event should contain:

- local `predmetId`;
- event type;
- local actor reference;
- local timestamp;
- version before/after where applicable;
- status before/after where applicable;
- identifiers of changed business segments where useful;
- local/import source classification.

It must not contain raw old/new business values. Actor, time and event metadata
explain the local action; they do not replace PREDMET content.

## 4. Minimum event taxonomy

The minimum event taxonomy supported by current owner decisions and source
behavior is:

- `CREATED`;
- `CLOSED_CONFIRMED`;
- `REOPENED`;
- `MANUALLY_FINISHED` after the separately planned removal of automatic
  `ZAVRŠEN`;
- `ANONYMIZED`;
- `IMPORT_NEW`;
- `IMPORT_REPLACE`.

The following are not user-visible business events:

- ordinary save;
- technical checkpoint creation/upgrade;
- export of an individual PREDMET;
- automatic background comparison.

Two additional events are justified only where the corresponding explicit
business action already exists:

- `SCENARIO_CHANGED`;
- `ADVISER_REASSIGNED`.

They record the action and changed segment identifiers, never the raw values.

The planned removal of automatic `ZAVRŠEN` means this audit does not preserve or
legitimize the current silent automatic-finish path. The future manual action
requires a local actor and dedicated event.

## 5. Retention policy derived from current product semantics

### 5.1 Active, closed and anonymized PREDMET

Audit events and privacy-safe checkpoints are retained for the lifetime of the
local PREDMET, including after `ANONIMIZOVAN`.

Anonymization must:

- append `ANONYMIZED` with local actor/time;
- preserve only privacy-safe event metadata and hashes;
- remove or irreversibly transform legacy raw snapshots that would otherwise
  retain data the anonymization action claims to remove.

This is required by the current anonymization meaning and does not create a new
owner policy.

### 5.2 Hard-deleted PREDMET

Hard deletion removes PREDMET, audit events and checkpoints together.

No orphan tombstone or external local-history record should remain. Keeping one
would contradict the current permanent-delete UI promise, create identity and
privacy questions, and risk a parallel record after the sole authoritative
PREDMET no longer exists.

Therefore no pre-delete audit event is retained after successful hard deletion.
The delete operation itself may be operationally logged only if a future
separate application-level, data-free security log is explicitly authorized;
that is outside this audit.

### 5.3 Transfer

- Individual JSON excludes checkpoints and local audit events.
- New import creates local `IMPORT_NEW`.
- Replacement preserves the destination-local audit events, replaces business
  state under the existing local identity, then appends local
  `IMPORT_REPLACE`.
- Full backup carries both responsibilities as part of restoration of the
  complete local database family.

## 6. Legacy migration constraint

The current raw confirmed-close snapshot does not cover the complete canonical
PREDMET aggregate: SCENARIO and child IRiU/contact rows are outside that raw
PREDMET-row snapshot.

Consequently migration must not invent a historical full-aggregate hash or
historical changed segments.

Required safe migration behavior:

1. derive a hash from any valid legacy snapshot only at its proven coverage;
2. mark it explicitly as `legacy_predmet_row_only` or equivalent;
3. do not synthesize historic audit events or segment changes;
4. establish the first full canonical checkpoint under the new coverage model
   without incrementing the business version solely because checkpoint
   coverage changed;
5. preserve any independently provable PREDMET-row business change;
6. remove raw legacy snapshot values only after transactional migration,
   rollback/recovery and compatibility tests prove equivalence.

A technical checkpoint-coverage upgrade is hidden and is not a user business
event.

## 7. `Pregled i potvrda` presentation boundary

The future overview should show:

- localized event label;
- local actor display name, including retained/deactivated users where
  applicable;
- timestamp;
- version/status transition where applicable;
- changed business segment labels where useful.

It must not show:

- raw old/new values;
- JSON snapshot content;
- every save/keystroke;
- checkpoint hashes;
- internal table or database identifiers.

Responsive presentation may differ between Android narrow, Android wide and
Windows, but the event meaning and ordering must remain equal.

## 8. Implementation proof required before runtime change

A future separately authorized implementation task must prove:

- additive schema migration and rollback/recovery safety;
- no raw PREDMET data in the new event/checkpoint stores;
- canonical aggregate coverage and version equivalence;
- legacy coverage handling without false version increments;
- `CREATED`, close, reopen, manual finish, anonymize, import-new and
  import-replace event behavior;
- replacement preserves destination-local events;
- hard delete removes all dependent event/checkpoint rows;
- anonymization leaves no legacy raw snapshot PII;
- individual JSON excludes both stores;
- full-backup round trip preserves both stores and user references;
- `Pregled i potvrda` ordering, labels and Android/Windows parity;
- current and historical database migration compatibility.

Validation remains:

1. final `flutter analyze --no-pub` PASS;
2. then complete `flutter test --no-pub` PASS;
3. builds only after owner approval;
4. technical PASS remains distinct from owner runtime acceptance.

## 9. Owner decision disposition

No new owner business decision is required for this technical closure.

Existing owner decisions already determine:

- significant lifecycle/import events;
- changed segments where useful;
- no raw old/new values;
- no per-keystroke history;
- hidden, separate checkpoints;
- local log excluded from individual transfer;
- replacement retention and local actor/time;
- PREDMET as sole truth.

`ODQ-PREDMET-HISTORY-004` can therefore close as:

`TECHNICAL DESIGN COMPLETE — NO NEW OWNER DECISION — IMPLEMENTATION BLOCKED`

## 10. Final audit status

`PREDMET LIFECYCLE LOG RETENTION AND EVENT TAXONOMY AUDIT PASS — CHECKPOINT/AUDIT SEPARATION DEFINED — RETENTION AND LEGACY MIGRATION BOUNDARIES DEFINED — IMPLEMENTATION NOT AUTHORIZED`
