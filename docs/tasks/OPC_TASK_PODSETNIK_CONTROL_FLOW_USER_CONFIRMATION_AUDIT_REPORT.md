# OPC Task — PODSETNIK Control-Flow Expansion And User-Confirmed Steps Audit

## Identity

- Branch: `task/OPC-PODSETNIK-CONTROL-FLOW-USER-CONFIRMATION-AUDIT`
- Verified base commit: `83b8395ffbb36f9712ef403a229ef77cb68b547d`
- Base verification: local `HEAD`, upstream tracking ref, and GitHub `ls-remote`
  agreed on the Windows Administrator persistence audit commit before this
  branch was created.
- Final commit: recorded in the final handoff after commit creation.
- Repository: `https://github.com/Tale74/OPC`
- GitHub branch URL:
  `https://github.com/Tale74/OPC/tree/task/OPC-PODSETNIK-CONTROL-FLOW-USER-CONFIRMATION-AUDIT`
- GitHub commit URL: recorded in the final handoff after commit creation.
- GitHub report URL:
  `https://github.com/Tale74/OPC/blob/task/OPC-PODSETNIK-CONTROL-FLOW-USER-CONFIRMATION-AUDIT/docs/tasks/OPC_TASK_PODSETNIK_CONTROL_FLOW_USER_CONFIRMATION_AUDIT_REPORT.md`
- Task class: audit / documentation only.

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- audit

Core purpose preserved:
- yes

PREDMET meaning affected:
- risk audited only; no implementation. Candidate control steps would be
  authoritative PREDMET facts.

Database ownership affected:
- no implementation; future normalized control data would remain in the
  user/firma-owned local OPC database.

JSON transfer affected:
- risk audited only; no JSON behavior changed.

Windows/Android parity affected:
- risk audited only; shared business meaning is required, while delivery may
  remain platform-specific.

Future OPC Web affected:
- no implementation; future projections must not use local technical ids as
  cross-device business identity.

Terminology drift risk:
- yes, controlled. The source has no standalone `NAPOMENE` PREDMET segment and
  no candidate replacement name is approved.

Implementation allowed:
- `AUDIT ONLY — NO IMPLEMENTATION`

Required gate before implementation:
- PREDMET ownership, schema/migration, JSON/versioning, role, entitlement,
  platform parity, terminology, and owner-decision gates.

### Required impact classification

- PREDMET impact: future business-model impact; audit only.
- NAPOMENE impact: current semantic/location conflict; audit only.
- PODSETNIK module impact: candidate expansion; audit only.
- Database/schema impact: future migration required for structured facts; none
  in this task.
- JSON/versioning impact: future explicit decision required; none in this task.
- Role/entitlement impact: current gaps and future decisions identified; none
  changed in this task.
- Implementation allowance: `AUDIT ONLY — NO IMPLEMENTATION`.

## Executive result

The safe answer to the core question is: a PODSETNIK surface may initiate an
explicit completion action, but the command must commit the completion fact at
the PREDMET domain boundary. PODSETNIK then refreshes its projection and changes
only technical delivery state. A notification tap, read, acknowledgement,
postponement, or dismissal cannot substitute for that business transaction.

The audit found three source/documentation conflicts that require owner
decisions before implementation:

1. Current source has no standalone PREDMET segment named `NAPOMENE`; it has one
   general `napomena` field inside `Roba i usluge`, plus a different payment
   note in `Finansije`.
2. Older locked local documentation says ADMINISTRATOR adjusts reminder time
   and content. Current source exposes per-PREDMET enable/time controls without
   a role gate, while reminder content is fixed.
3. OSNOVNI locks the module and PREDMET shortcut, but startup/resume reminder
   reconciliation and the due dialog do not consult entitlement. This known
   issue is recorded, not corrected.
4. `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md` retained a
   superseded sentence saying CEREMONIJA was the reminder settings owner. This
   audit corrects that documentation-only drift to the source-confirmed
   `MODULI / PODSETNIK` ownership.

## Evidence and source paths inspected

### Production source

- `lib/core/database/database.dart`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/database/tables/log_izmena_table.dart`
- `lib/core/database/tables/korisnici_table.dart`
- `lib/core/database/tables/stanje_robe_posledice_table.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `lib/core/entitlements/opc_runtime_entitlement_resolver.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/domain/session_service.dart`
- `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/core_v2/business_policy/`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/`
- `lib/features/predmeti/reminders/`
- `lib/features/stanje_robe/data/stanje_robe_posledice_repository.dart`

Generated Drift code was checked only as schema corroboration and was not used
as the primary architecture authority.

### Tests

- `test/ceremony_reminder_system_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/presentation_potpun_entitlement_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/json_transfer_regression_test.dart`
- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- all remaining repository tests as full-suite regression coverage.

### Git-tracked documentation

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md` (documentation-only
  anti-drift correction)
- `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md`
- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
- `docs/OPC_PRE_POINT_4_CORRECTIONS_AUDIT_PSEUDOCODE.md`
- `docs/OPC_PRESENTATION_POTPUN_BUILD_PSEUDOCODE.md`
- PREDMET workflow, lifecycle, version, completion, dependency, gap and owner
  review documents under `docs/`.
- Relevant PREDMET, business-policy, reminder, MODULI/PAKETI/PODSETNIK,
  pre-build, pre-Point-4, presentation, and JSON task reports under
  `docs/tasks/`.

## Local documentation findings

The audit inspected `PROJECT_DOCS`, `RESTORE_POINTS`, `BACKUPS`, and
`SMOKE_LOGS` under `C:\Projekti\OPC\OPC v.1`.

| Local finding | Classification | Audit use |
| --- | --- | --- |
| PREDMET is core/master truth; modules may not create parallel truth | already migrated to GitHub | enforced by manifest and recommendation |
| PODSETNIK is one Srednji/Potpun operational/package module | already migrated to GitHub | confirmed against entitlement source |
| ADMINISTRATOR must adjust notification time and content | authoritative but not fully migrated/implemented; conflicts with current source | summarized here; owner role/content decision required |
| May project map says OS/background notifications are not implemented | obsolete historical note | current Android local gateway/source supersedes it |
| Older notes describe PODSETNIK as planned work | obsolete historical note | current source and July Git reports supersede them |
| Restore-point notes | obsolete historical checkpoint evidence | no product rule migrated |
| July 4 backup ZIP | historical preservation snapshot duplicating older source/docs | no archive content promoted as current authority |
| SMOKE_LOGS | no relevant current control-flow facts found | no migration |

No local document defines an approved structured-step schema, completion
semantics, responsible-user rule, status interaction, JSON model, or final UI
name. Those remain owner decisions.

## Current-state map — PREDMET

### Owned facts

`Predmeti` stores lifecycle and identity metadata, assigned `savetnikId`,
business version/source metadata, deceased-person and death facts, payer/contact
context, ceremony facts, parte fields, finance fields, general/payment notes,
and JSON export metadata. Related IRiU, contacts, stock consequences and logs
remain linked records around the PREDMET.

### Lifecycle and statuses

- `OTVOREN`: editable working state.
- `ZATVOREN`: manually confirmed/closed working cycle; may be reopened.
- `ZAVRŠEN`: automatic date-driven terminal work state.
- `ANONIMIZOVAN`: protected data redaction state after explicit GDPR action.

Manual close sets `ZATVOREN`. Automatic finish occurs when
`datumCeremonije < today` for every non-`ZAVRŠEN`, non-`ANONIMIZOVAN` PREDMET,
including an `OTVOREN` or `ZATVOREN` one. It is invoked when the list startup
side effects refresh all statuses and when a PREDMET screen loads. There is no
user action that directly marks `ZAVRŠEN`.

“Active” is context-dependent in current source:

- reminder due-event eligibility means `OTVOREN` or `ZATVOREN`;
- the PODSETNIK selector includes every status except `ANONIMIZOVAN`, including
  `ZAVRŠEN`;
- the main PREDMET list contains all statuses unless filtered.

### Reminder behavior after `ZAVRŠEN`

Due-event collection and startup reminder reconciliation skip `ZAVRŠEN`.
Current source does not run an explicit cancellation command at the status
transition, does not clear stored scheduled ids, and does not delete reminder
configuration. Because automatic finish is after the ceremony date, normally
computed occurrences are already past, but this is not a formal cancellation
contract.

### Versioning and history

The save/confirmed-close snapshot covers business fields from
`PredmetiData.toJson()`, including ceremony and both notes, while excluding
status, version/export metadata and source/modifier metadata. A later confirmed
close increments `verzija` only when the business snapshot changed after a
prior confirmed close. `logIzmena` stores save/close snapshots, version rows,
and work-cycle rows; current UI does not expose a complete change log. Automatic
`ZAVRŠEN` does not create a dedicated log entry.

### JSON

Single-PREDMET JSON serializes the full PREDMET row, IRiU, contacts, and an
optional approved unresolved STANJE ROBE consequence block. Therefore ceremony,
assignment, notes, status and version fields are included. Reminder settings
and scheduled notification ids are not included. Full backup includes PREDMET
and `logIzmena`, but current serializer also omits
`ceremony_reminder_settings`.

Any future structured control facts require an explicit schema version,
single-PREDMET export/import, full-backup, conflict/replacement, migration and
version-history decision. Relying on current automatic `toJson()` coverage
without those decisions would be unsafe.

## Current-state map — NAPOMENA / NAPOMENE

- Current source has `predmeti.napomena`, a single free-text column.
- It is edited by a three-line text field labelled `NAPOMENA` inside
  `IriuSegment`, whose PREDMET navigation label is `Roba i usluge`.
- Current source has no standalone `NAPOMENE` navigation segment.
- `napomenaPlacanja` is a separate free-text field under `Finansije`.
- General `napomena` enters single-PREDMET JSON, save/close snapshots, and the
  LISTA PDF as `Opšta napomena`.
- It can contain prose or an operational instruction only as unparsed text. It
  cannot represent multiple distinct actions, responsible user, deadline,
  state, confirmer, confirmation time, reopen history, or stable item identity.

Adding structured records “inside NAPOMENE” cannot mean extending the existing
text column. It would require a separate structured model and clear UI
separation. Keeping the current general note for commentary preserves meaning;
mixing it with action state would blur documents, JSON, version snapshots, and
user expectations.

## Current-state map — PODSETNIK

### What it reads

- PREDMET id/number and deceased-person identity;
- ceremony type, date, time and cemetery;
- status eligibility and anonymization boundary.

The module selector lists all non-anonymized PREDMET records. Its settings card
shows ceremony facts as read-only inputs. Ceremony fields remain editable only
inside PREDMET/CEREMONIJA. The coordinator uses ceremony type, deceased name,
date and time to create reminder text and occurrences.

### What it persists

`ceremony_reminder_settings`, keyed by local `predmet_id`, stores enabled state,
delivery clock times, scheduled notification ids, update time, and a legacy
frequency column. The active model/repository uses delivery times. Default is
enabled with `09:00` when no row exists.

Business/technical classification:

- ceremony facts and any future obligation/completion are PREDMET business
  facts;
- reminder enabled/time values are local operational preferences;
- scheduled ids, scheduled times, permission and delivery/cancellation results
  are technical state.

### Derivation and delivery

- occurrences are derived for two days before, one day before, and ceremony
  day at selected clock times, future-only and not after the ceremony;
- reschedule cancels stored ids, creates replacement events, and persists new
  ids;
- Android uses local `zonedSchedule`, private visibility and
  `inexactAllowWhileIdle`;
- startup and resume reschedule eligible PREDMET records;
- a due app-open dialog is session-deduplicated per active slot;
- Windows also has a separate 2/1/0-day banner whose dismissal lasts only for
  the current session.

Current PODSETNIK has no read, acknowledgement, postpone, dismiss-history,
user-confirmed completion, responsible-user, deadline, checklist, or workflow
model.

## Current-state map — roles and assignment

- A newly created PREDMET receives the current session user's id as
  `savetnikId` and `createdByKorisnikId`.
- The PREDMET list repository is unfiltered; source does not restrict SAVETNIK
  to only assigned PREDMET records. Both ADMINISTRATOR and SAVETNIK can see the
  same list under the current UI flow.
- PREDMET edit/save/close/reopen actions use the current user id for metadata
  but are not role-gated in the PREDMET screens.
- ADMINISTRATOR alone receives top-level settings/statistics access; user
  management is ADMINISTRATOR-only.
- PODSETNIK PREDMET shortcut access is entitlement/anonymization-gated, not
  role-gated. The per-PREDMET enable/time controls are not role-gated inside
  the module screen.
- No per-step responsibility model exists.

Therefore current `savetnikId` can be a candidate input for grouping or a
default responsible person, but it is not evidence that only that SAVETNIK may
edit or confirm a future step. Create/confirm/override permissions remain owner
decisions.

## Required conceptual distinctions

### 1. Authoritative business facts

A required organizational step, its responsible person, due time, business
state, confirmer/time, exception and relation to a PREDMET section would have
business meaning. The category belongs to the PREDMET domain. The exact fields
are not approved by this audit.

The physical schema may use a normalized child table referencing PREDMET, but
domain ownership—not table placement—must remain PREDMET. The only authoritative
copy cannot be owned by PODSETNIK.

### 2. Derived control observations

Approaching ceremony, missing source data, inconsistency, overdue deadline and
changed ceremony time may be recalculated from PREDMET plus an approved policy.
Persisting them is unnecessary when the observation is reproducible. If the
owner requires acknowledgement history, exception reasons, or stable audit
evidence, only that explicit interaction/history should persist, without
turning the derived warning into a competing source fact.

### 3. Technical notification state

Platform id, schedule time, delivery attempt, cancellation/reschedule and
permission belong to PODSETNIK infrastructure. They must not satisfy a business
step, alter PREDMET version, or determine `ZAVRŠEN`.

### 4. User interaction state

`read`, `acknowledged`, `postponed`, `dismissed`, and `confirmed complete` have
different meanings. Only an explicit approved completion command may change a
business step. Notification dismissal or tap is never automatic completion.

## Existing checklist-like concepts

Current source contains useful but non-equivalent patterns:

- PREDMET section progress derives `notStarted`, `needsMore`, and `ready` from
  UI-local field checks. It is not persisted business progress and is not a
  close gate.
- CEREMONIJA and payer fields show touched-field validation such as `Obavezno`,
  but those validators are UI-local and are not a centralized control policy.
- `BusinessPolicyEvaluator` and `IriuTruthRules` derive scenario and IRiU
  recommendations from PREDMET facts.
- IRiU lifecycle dialogs explicitly ask whether to add/remove/keep managed
  rows and persist narrow dismissal memory in `iriu_lifecycle_decisions`.
- STANJE ROBE persists unresolved/resolved/cleared/superseded consequences;
  unresolved stock can block manual PREDMET close.

These patterns may inform future design, but none is a general organizational
step model. UI-local progress must not be promoted into business truth, and a
PODSETNIK task table must not be justified by analogy with technical reminder
or stock state.

## Architecture options

### Option A — structured tracking items inside NAPOMENE

Advantages:

- keeps commentary and follow-up context close;
- may minimize top-level navigation growth;
- could present free text and structured items in one user area.

Risks/impact:

- current source has no `NAPOMENE` segment, only a general note under `Roba i
  usluge`;
- overloading that note blurs commentary and actionable truth;
- a structured model still requires new schema/migration, stable item identity,
  JSON/backup/import rules, version history, and explicit UI separation;
- LISTA PDF currently renders the field as `Opšta napomena`, so silently
  changing its meaning would affect a derivative.

Classification: possible only after owner clarifies the intended segment and
semantics; not safe as an extension of the existing text column.

### Option B — new structured PREDMET segment

Advantages:

- clean separation between commentary and actionable facts;
- clear PREDMET domain ownership;
- natural place for item identity, responsibility, deadline, completion and
  history after owner approval;
- simpler JSON/versioning semantics than hiding structured data in prose.

Risks/impact:

- new schema/migration and UI navigation;
- single-PREDMET and backup JSON compatibility work;
- version/log/replacement-import rules;
- final name and automatic/manual catalog remain undecided.

Classification: architecturally clearer than A; final choice/name remains an
owner decision.

### Option C — PODSETNIK-owned operational tasks

Attractive because it gives the module independent storage, UI and scheduling
iteration. It is unsafe for the only copy of an obligation or completion fact:
package degradation, module disablement, notification cleanup, export omission
or technical rescheduling could then lose or contradict business history.

Safe PODSETNIK ownership is narrow: delivery ids/times/results, platform
permission, display grouping/filter preference, and possibly non-business
session state.

### Option D — hybrid

PREDMET owns structured business-control steps and confirmation history.
PODSETNIK reads them, derives warnings, groups/prioritizes them, opens the
authoritative PREDMET view, and stores only technical delivery state.

This best satisfies the manifest and current owner direction while keeping
PODSETNIK a separate evolving module. It is the audit recommendation, not a
final owner decision.

## User-confirmation semantics matrix

| Scenario | Authoritative PREDMET change | Persist/version/JSON | Notification/status effect | Owner decision |
| --- | --- | --- | --- | --- |
| User completes a manual step | yes | persist; version/history/JSON policy required | may cancel related delivery after commit; must not directly set PREDMET status | required |
| User confirms an automatically required step | only if completion is a real business fact distinct from source validation | persist only with approved semantics; version/JSON required | warning may stop only if source rule or approved override is satisfied | required |
| Source PREDMET data automatically resolves warning | source edit is already authoritative; derived warning need not persist | source edit follows current version/JSON flow | reschedule/cancel derivative after source commit; no independent status change | policy required |
| User acknowledges warning | normally no | optional interaction history only; not business completion | may suppress presentation; source warning remains | required |
| User postpones step | if due date/state has business meaning, yes | persist/version/JSON required | reschedule only after authoritative commit | required |
| User reopens completed step | yes | persist new state and history; version/JSON required | may reschedule; no direct PREDMET status mutation | required |
| ADMINISTRATOR overrides confirmation | yes if allowed | actor/reason/history required; version/JSON required | derivative update after commit | required |
| Completion restricted to responsible SAVETNIK | authorization rule around PREDMET fact | failed attempts must not mutate; successful actor history required | no special status authority | required |
| Completion history recorded | yes | must persist; retention/version/export/import scope required | independent of notification delivery | required |

## Automatic versus manual control items

### Automatic

Current reusable source evidence includes field progress/validation, business
policy evaluation, IRiU truth/lifecycle rules, stock consequences, and ceremony
term parsing. These are fragmented rules with different authority levels. A
future automatic control layer may reuse only centralized, side-effect-safe
domain rules. UI-private checks must first be extracted/approved before they
become module-wide policy.

An unresolved automatic warning must not be permanently “completed” by a
notification action while its source fact remains invalid. The safe choices are
source correction, explicit acknowledged/dismissed presentation state, or an
owner-approved PREDMET exception/override fact.

### Manual

Examples such as call family, confirm cemetery, obtain document, order goods,
verify payment or contact an external service are business-organizational facts
once the user relies on them. Their only authoritative copy must be linked to
PREDMET. Minimum structure cannot be finalized without owner decisions, but
plain free text is insufficient for distinct identity, responsibility,
deadline, state and confirmation history.

## Relationship to `ZAVRŠEN`

Current automatic finish depends only on ceremony date before today and ignores
future tracking items. Open structured items do not currently block
`ZAVRŠEN`; no such items exist. PODSETNIK must never set or change status.

Whether open steps block automatic finish, whether completed/overdue history
remains visible, and whether reminders stop/cancel after finish are lifecycle
policy decisions. If steps block `ZAVRŠEN`, that is a PREDMET lifecycle change,
not a PODSETNIK rule. Historical facts should not be deleted at finish.

Audit recommendation: keep all status coupling out of the smallest first phase.

## Package and degradation audit

| Transition | Authoritative PREDMET control data | PODSETNIK UI | Notifications/history |
| --- | --- | --- | --- |
| POTPUN active | preserved/available | entitled | delivery per approved config |
| POTPUN → SREDNJI | preserved unchanged | remains entitled under current policy | preserve history/config; reevaluate only capability differences if later introduced |
| POTPUN/SREDNJI → OSNOVNI | must remain stored and intact | locked/unavailable | no deletion; cancel vs suspend requires owner decision |
| OSNOVNI → SREDNJI/POTPUN | reveal same facts | available again | re-derive current state; reschedule only under approved policy |

Current source behavior does not fully enforce the desired OSNOVNI suppression:
the module and PREDMET shortcut are locked, but startup/resume reconciliation,
Android scheduling and the app-open due dialog are not entitlement-gated. Thus
scheduled notifications/config may survive downgrade and due dialog behavior
may continue. This is a known audit finding, not an authorization to fix it.

Package degradation must never delete authoritative PREDMET facts, completion
history, or manual obligations.

## Notification and control-surface boundary

- Windows dashboard/dialog/banner and Android system notification may present
  the same authoritative item, but delivery success is not business completion.
- notification tap should open OPC or the authoritative PREDMET item unless a
  later owner decision explicitly permits a separate confirmation action;
- dismissal is not completion;
- selected reminder hour is a delivery preference unless an owner-approved
  business deadline model says otherwise;
- cancellation/reschedule follows an authoritative commit, never precedes it as
  proof of completion.

## UI audit — candidate responsibilities only

### MODULI / PODSETNIK dashboard

May display today, overdue, upcoming, missing data and awaiting confirmation;
group by PREDMET or responsible user; filter/prioritize and open authoritative
PREDMET content. Any business edit must execute a PREDMET-domain command, even
when initiated from this module surface.

### PREDMET-level tracking view

Candidate authoritative editing surface for one PREDMET's manual/control
steps, source facts, responsible person, deadlines and confirmation history.
It may provide navigation to the source segment that resolves an automatic
warning.

### NAPOMENA or replacement segment

Free text should remain clearly distinguishable from actionable structured
items. Current `napomena` may display commentary but cannot own structured item
state without a new model. Final placement/name is not designed here.

## Owner-decision queue

1. Should structured control steps live near the current general note or in a
   new PREDMET segment?
2. Is the current `napomena` under `Roba i usluge` intended to become a
   standalone `NAPOMENE` segment, or must its current meaning/location remain?
3. What should the structured segment be called?
4. Which steps are automatic?
5. Which steps may users create manually?
6. Who may create and edit steps?
7. Who may confirm completion?
8. Does completion require the assigned/responsible SAVETNIK?
9. Can ADMINISTRATOR override completion, and is a reason mandatory?
10. Is immutable confirmation/reopen/override history required?
11. Can completed steps be reopened?
12. Can unresolved automatic warnings be acknowledged or dismissed, and for
    how long?
13. Should open steps block manual `ZATVOREN`, automatic `ZAVRŠEN`, both, or
    neither?
14. What happens to reminders and technical scheduled ids after `ZAVRŠEN`?
15. Which step/history fields enter single-PREDMET JSON and full backup?
16. Which changes increment PREDMET `verzija` and appear in `logIzmena`?
17. What happens to PODSETNIK delivery after downgrade to OSNOVNI?
18. Does OSNOVNI preserve but hide all tracking data? Audit recommendation:
    yes, preserve; final UX decision remains open.
19. May a notification action complete a step, or only open OPC/PREDMET?
20. Is a selected hour required for every manual step, or only for notification
    delivery?
21. What belongs in the first implementation phase versus later phases?
22. Is `savetnikId` a default responsibility only, or an authorization rule?
23. Should ADMINISTRATOR still control notification content as older locked
    local docs state, even though current content is fixed?
24. Should per-PREDMET reminder enable/time controls be ADMINISTRATOR-only or
    available to SAVETNIK as current source permits?
25. Must the known startup/resume entitlement bypass be corrected before any
    expanded control model is implemented?
26. Are derived warnings recomputed only, or must selected acknowledgement/
    exception evidence persist?

## Safe architecture recommendation

Recommendation, not fact: choose Option D, with Option B as the clearest
PREDMET information architecture unless the owner explicitly chooses A after
resolving the current NAPOMENA meaning.

Recommended boundary:

- a normalized structured-step aggregate belongs to the PREDMET domain even if
  stored in child tables;
- explicit completion/reopen/override commands record actor/time/history and
  follow approved version/JSON rules;
- PODSETNIK consumes a projection, derives non-authoritative observations,
  presents dashboards, routes edits to PREDMET, and owns technical delivery
  state only;
- package changes affect availability/delivery, never authoritative data;
- `ZAVRŠEN` remains untouched until an explicit lifecycle decision;
- notification interaction remains distinct from completion.

Migration risks: schema backfill, local ids versus transfer identity,
single-PREDMET replacement, full backup, version/log semantics, anonymization,
package downgrade, and currently omitted reminder configuration.

### Smallest safe first implementation phase

Only after owner decisions are locked:

1. introduce PREDMET-owned manual structured steps with stable identity;
2. support explicit complete and reopen commands with history;
3. define migration, PREDMET version and JSON/backup behavior;
4. provide a PREDMET-level editing view;
5. expose only a read-only PODSETNIK projection/open action.

Defer automatic rule warnings, `ZAVRŠEN` coupling, notification completion
actions, postponement/escalation, package-transition automation, and Web/sync.
This is a phase recommendation, not an implementation task.

## Changed documentation and tests

Changed:

- `docs/tasks/OPC_TASK_PODSETNIK_CONTROL_FLOW_USER_CONFIRMATION_AUDIT_REPORT.md`
- `docs/OPC_PODSETNIK_CONTROL_FLOW_AND_USER_CONFIRMATION_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`

Production source changed: no.

Tests added/changed: none. Existing source and tests were sufficient to
characterize ownership and persistence. A new test would have risked freezing
known gaps (NAPOMENA information architecture, role/content control, and the
startup entitlement bypass) before owner decisions.

## Validation

- `flutter analyze`: PASS, `No issues found!`.
- `flutter test`: PASS, all 126 tests.
- Manifest gate: PASS against verified base
  `83b8395ffbb36f9712ef403a229ef77cb68b547d`.
- `git diff --check`: PASS.
- UTF-8 self-check: PASS for all touched documents; no BOM, no `U+FFFD`, and
  no mojibake marker in newly written text.
- Production-file diff check: PASS; no Dart, YAML, JSON, Android, or Windows
  production file changed.
- Build/runtime/Point 4 smoke: not run and not authorized.

## Protected boundaries confirmed

- Production behavior was not changed.
- No database schema or migration was changed.
- No PREDMET/NAPOMENA fields or UI were added.
- No reminder schedule, delivery, app-open dialog or Android gateway changed.
- No package, role, JSON, PDF, status or automatic `ZAVRŠEN` behavior changed.
- No expanded PODSETNIK implementation task was executed.
- The paused Windows Administrator persistence incident was not reopened.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes; recommendation keeps authoritative facts in PREDMET

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes; no behavior changed

Existing JSON transfer preserved:
- yes; no behavior changed

Terminology preserved:
- yes; every candidate name is unapproved and owner-controlled

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes; documentation only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS, subject to the GitHub visibility gate

Status:

`AUDIT PASS — PODSETNIK BUSINESS MODEL CONFLICT REQUIRES OWNER DECISION — NO IMPLEMENTATION AUTHORIZED`
