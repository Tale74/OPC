# OPC database referential integrity and PREDMET dependency audit

Status: `CODE-FIRST + FIXTURE-CONFIRMED AUDIT PASS — IMPLEMENTATION NOT AUTHORIZED`

Audit date: 2026-07-26

Base branch: `task/OPC-GATE-0-PODSETNIK-ORPHAN-REFERENCE-AUDIT`

Base SHA: `86687c53dec1d0ccf0b2a89b1c23d54f9140c804`

Task branch: `task/OPC-GATE-0-DATABASE-REFERENTIAL-INTEGRITY-AUDIT`

## 1. Purpose and boundary

This docs-only audit closes one foundational code-review unit:

- actual SQLite foreign-key enforcement;
- all current physical and logical PREDMET dependencies;
- hard-delete, anonymization, replacement and full-restore behavior;
- orphan and privacy risks;
- safe correction/migration order;
- architecture/rewrite implication.

No application source, schema, migration, production database, JSON contract,
test suite or runtime behavior is changed.

PREDMET remains the sole authoritative business truth. Derivative and
operational rows must either remain validly attached to a current PREDMET,
become explicitly classified non-PII technical history, or be removed through
a controlled lifecycle.

## 2. Evidence method

The audit inspected:

- all Drift table declarations under `lib/core/database/tables/`;
- custom tables and migration/recovery logic in
  `lib/core/database/database.dart`;
- PREDMET repository lifecycle methods;
- PARTE preparation/media lifecycle;
- PODSETNIK reminder/database/OS lifecycle;
- STANJE ROBE effect/consequence lifecycle;
- individual JSON import/replacement;
- full-backup serialization and restore;
- user-reference guards;
- current migration, reminder, PARTE, stock and JSON tests;
- resolved local Drift and `drift_flutter` connection source.

A temporary characterization test was created outside the Git repository and
executed with:

`flutter test --no-pub <external-audit-fixture>`

It changed no repository file and is not a production test addition.

## 3. Executed fixture evidence

### 3.1 Hard-delete probe

The isolated current-schema fixture:

1. opened `AppDatabase.forTesting(NativeDatabase.memory())`;
2. read `PRAGMA foreign_keys`;
3. created one PREDMET;
4. added reminder configuration/notification IDs;
5. added a completed PARTE preparation;
6. called current `PredmetiRepository.obrisiPredmet`;
7. queried remaining rows and `PRAGMA foreign_key_check`.

Observed result:

```text
foreign_keys=0
remaining_reminder_rows=1
remaining_parte_rows=1
foreign_key_violations=2
```

The characterization assertions passed.

### 3.2 Anonymization probe

The isolated fixture created:

- a PREDMET containing a synthetic JMBG;
- scheduled reminder IDs;
- a completed PARTE draft containing that synthetic JMBG;
- a raw `logIzmena` save snapshot containing that synthetic JMBG.

After current `anonimizujPredmet`:

```text
reminder_ids=[201,202]
parte_contains_jmbg=true
log_contains_jmbg=true
```

The characterization assertions passed.

No real person, canonical owner database or private project data was used.

## 4. Actual foreign-key state

OPC declares physical foreign keys for:

- `kontakt_lica.predmet_id -> predmeti.id`;
- `iriu.predmet_id -> predmeti.id`;
- `stanje_robe_posledice.predmet_id -> predmeti.id`;
- `stanje_robe_posledice.iriu_id -> iriu.id`;
- `parte_pripreme.predmet_id -> predmeti.id`;
- `log_izmena.predmet_id -> predmeti.id`;
- `iriu_lifecycle_decisions.predmet_id -> predmeti.id`;
- `ceremony_reminder_settings.predmet_id -> predmeti.id`.

Every listed relation declares `ON DELETE CASCADE`.

OPC production connection uses `driftDatabase(name: kDatabaseName)` without a
native setup callback. Test connections use `NativeDatabase` without setup.
`database.dart` never executes `PRAGMA foreign_keys = ON`.

The fixture proves the effective current mode is `0` for the tested current
connection. Declared cascades are therefore schema intent, not enforced
runtime protection.

## 5. Logical references without physical foreign keys

The following are deliberate or current logical links and require different
policies, not blind cascade conversion:

| Source | Logical target | Current meaning |
| --- | --- | --- |
| PREDMET `savetnikId`, creator, modifier | local `korisnici.id` | local authorship/ownership metadata |
| `logIzmena.korisnikId` | local `korisnici.id` | local audit actor |
| auth audit actor/target IDs | former/current local users | installation security audit |
| STANJE ROBE applied effect PREDMET/IRiU IDs | lifecycle source selection | operational reconciliation/history |
| IRiU catalog stable ID | KATALOG article stable ID | knowledge/snapshot link |
| stock stable ID | catalog stable ID | operational catalog identity |
| PARTE preparation `templateId` | built-in/user template | snapshot-assisted provenance |
| FIRMA default PARTE template ID | built-in/user template | prospective default |
| PARTE template `firmaId` | singleton FIRMA | local configuration ownership |

These links cannot all receive the same FK/delete action:

- actor/security history may intentionally outlive an active user;
- PARTE retains a template snapshot so deletion/change of a template does not
  rewrite an existing preparation;
- stock reconciliation history may retain non-current, non-PII evidence after
  restoring stock;
- stable IDs are portability identities, not local numeric foreign keys.

## 6. Current lifecycle matrix and defects

### 6.1 Hard delete

Current explicit behavior:

- reconciles current stock effects and deletes active consequences;
- deletes `logIzmena`;
- deletes contacts;
- deletes IRiU;
- deletes IRiU lifecycle decisions;
- deletes PREDMET.

Missing behavior under the proven FK-off runtime:

- PARTE preparation row is retained;
- app-owned PARTE media may be retained;
- reminder settings are retained;
- Android scheduled notifications are retained.

The resulting PARTE/reminder rows are confirmed FK violations. They may retain
personal data after the authoritative PREDMET is gone.

STANJE ROBE applied-effect rows are intentionally converted to
`RESTORED`/`CLEARED` and retained. They carry stable article/quantity/status
evidence but no PREDMET raw person fields. Their retention must remain explicit
and excluded from current-effect queries and portable backup unless a future
policy changes it.

### 6.2 Anonymization

Current code redacts selected PREDMET/contact fields and retains PREDMET with
`ANONIMIZOVAN` status.

It does not:

- cancel Android notifications whose body already contains person identity;
- clear reminder IDs/config;
- delete/sanitize completed PARTE draft/media;
- remove/transform raw `logIzmena` snapshots.

The fixture confirms all three retained PII-bearing mechanisms.

This conflicts with existing anonymization meaning and with the already closed
privacy-safe log design. No new owner decision is needed to prevent redacted
data from surviving in technical derivatives.

External user-exported PDF/DOCX/image files are outside the local database and
cannot be silently deleted by this lifecycle. The application must not claim
otherwise.

### 6.3 Individual replacement import

Current replacement:

- reconciles stock;
- deletes log, contacts, IRiU and IRiU lifecycle decisions;
- replaces the PREDMET row under the preserved local ID;
- inserts imported contacts/IRiU.

It does not reconcile:

- PARTE preparation/media derived from the replaced business state;
- reminder schedule/body/config derived from old ceremony facts.

It also deletes the local log, contrary to the separately closed owner rule
that local history is retained and a local replacement event is appended.

Safe future behavior:

- preserve only valid local audit history/configuration;
- cancel old notification IDs and reschedule from replaced PREDMET truth;
- invalidate or safely delete stale PARTE preparation through its media-aware
  lifecycle;
- never present a pre-replacement derivative as current;
- never import foreign local IDs/history.

### 6.4 Full-backup restore

Current full backup includes PREDMET, IRiU, contacts, users, FIRMA, catalog,
settings, document/PARTE templates, log and stock tables.

It omits:

- ceremony reminder configuration;
- PARTE preparations;
- installation security settings/auth audit, which currently behave as
  installation-local state.

Current destructive restore deletes many tables but does not explicitly clear:

- `kontakt_lica`;
- `iriu`;
- `ceremony_reminder_settings`;
- pending Android notifications.

Because foreign keys are off, deleting PREDMET does not clear those rows.
Subsequent `insertOrReplace` imports can leave unmatched old rows or associate
old child rows/reminder state with a restored PREDMET that reuses the same
local ID.

This is a confirmed source-level cross-PREDMET and potentially cross-FIRMA
integrity risk.

Logical reminder preferences should be portable in full backup, while
device-local scheduled IDs must never be portable. Installation security
settings/auth audit need a separately explicit installation-retention
contract; they must not be accidentally swept into PREDMET cascade cleanup.

## 7. Required architecture: lifecycle orchestration

The defects do not justify a full rewrite. They show that domain repositories
and external derivative/OS side effects need one progressive-refactor
boundary.

A future application-level PREDMET lifecycle orchestrator should coordinate:

- repository transaction for authoritative PREDMET/child data;
- STANJE ROBE compensation;
- PARTE preparation/media cleanup or invalidation;
- PODSETNIK OS cancellation/reschedule;
- privacy-safe audit event/checkpoint lifecycle;
- explicit failure and recovery result.

The PREDMET repository remains the database truth boundary. The orchestrator
does not create parallel truth; it orders non-transactional side effects around
the authoritative mutation.

## 8. Safe implementation sequence

### Stage RI-1 — characterization and cleanup inventory

- add committed tests equivalent to the external probes;
- enumerate every declared FK with `PRAGMA foreign_key_list`;
- run `PRAGMA foreign_key_check` on isolated copies of all supported canonical
  schema fixtures;
- count/classify orphan rows by table;
- stop on any row whose valid owner cannot be proven;
- never guess a PREDMET, user, catalog item or template link.

### Stage RI-2 — explicit lifecycle correction while FK remains off

- introduce deletion/anonymization/replacement orchestrator;
- add media-aware PARTE cleanup/invalidation;
- add reminder cancel/recovery/reschedule;
- apply privacy-safe log migration design;
- make full restore clear the exact dependent-table set before parent rows;
- preserve only explicitly classified installation-local history;
- transfer logical reminder config without device IDs.

### Stage RI-3 — orphan recovery migration

- transactionally delete invalid PREDMET children after any required external
  OS/media compensation;
- retain only explicitly classified non-PII operational/security history;
- record counts and recovery result without raw PREDMET data;
- verify zero unexpected `foreign_key_check` rows.

### Stage RI-4 — enable enforcement

- enable `PRAGMA foreign_keys = ON` for every production and test connection;
- assert the mode during startup/migration tests;
- keep explicit lifecycle orchestration for external OS/filesystem work;
- do not treat cascade as a replacement for stock/media/notification
  compensation.

### Stage RI-5 — restore/import and parity proof

- prove full restore from every supported backup policy/schema;
- prove replacement does not retain stale derivatives;
- prove hard delete/anonymization privacy behavior;
- prove interruption/retry recovery;
- prove Windows and Android equivalent business result;
- run owner-approved Android device tests for OS notifications/media.

## 9. Stop conditions

Implementation must stop when:

- an orphan row has no proven owner or safe deletion classification;
- a candidate cleanup could delete valid PREDMET truth;
- canonical database copy/recovery is unavailable;
- stock compensation cannot be proven;
- PARTE shared-media ownership is ambiguous;
- an OS notification cannot be scoped to OPC/PREDMET safely;
- security/auth history retention conflicts with privacy policy;
- full restore cannot distinguish installation-local and portable state;
- Windows/Android business parity cannot be maintained;
- any change would redefine PREDMET authority.

## 10. Acceptance gates

Technical acceptance requires:

- zero unexpected `PRAGMA foreign_key_check` results;
- `PRAGMA foreign_keys = 1` on all supported runtime/test connections;
- exact dependent-data lifecycle tests;
- migration/recovery and rollback proof;
- full-backup restore rehearsal;
- no raw PII in retained technical history after anonymization;
- no app-owned PARTE media or notification payload after hard delete;
- no stale derivative after replacement;
- no stale child reassociation after restore;
- Windows/Android parity evidence.

Standard validation remains:

1. final `flutter analyze --no-pub` PASS;
2. complete `flutter test --no-pub` PASS;
3. builds only after owner approval;
4. technical PASS distinct from owner runtime acceptance.

## 11. PODSETNIK continuation boundary

This audit closes only PODSETNIK referential/OS integrity.

The project must return to PODSETNIK after all candidate information signals
are inventoried and their business meaning is owner-approved. The later
informed-reminder model depends on:

- lifecycle signals;
- empty/partial/complete segment signals;
- SCENARIO-dependent required/missing facts;
- IRiU completion/exception signals;
- due/missed/cancelled/completed meanings;
- actor/role and notification-action policy.

Signals remain computed projections from PREDMET/SCENARIO/IRiU and must never
become a parallel stored business truth.

## 12. Architecture/rewrite recommendation

This evidence supports:

`RETAIN CURRENT CODEBASE + PROGRESSIVE LIFECYCLE/REFERENTIAL REFACTOR`

It does not support:

- full rewrite;
- broad schema replacement;
- enabling FK enforcement before cleanup and lifecycle repair;
- isolated PODSETNIK patch that ignores PARTE/log/restore dependencies.

The recommendation must be re-evaluated only after the remaining full
code/architecture review evidence is complete.

## 13. Final status

`DATABASE REFERENTIAL INTEGRITY AUDIT PASS — FK-OFF RUNTIME AND ORPHAN/PRIVACY DEFECTS FIXTURE-CONFIRMED — PROGRESSIVE LIFECYCLE REFACTOR SEQUENCE DEFINED — IMPLEMENTATION NOT AUTHORIZED`
