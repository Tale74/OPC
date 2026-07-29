# OPC task report — Phase 1 complete SCENARIO/IRiU audit

Status:
`SOURCE AUDIT COMPLETE — BOUNDED SCENARIO/CONFIGURATION PARTIAL REWRITE JUSTIFIED — TWO OWNER BUSINESS FIXTURES REMAIN — IMPLEMENTATION NOT STARTED`

Audit date: 2026-07-29

## 1. Git baseline

- Base branch: `task/OPC-PHASE-1-ANDROID-PARTE-PERFORMANCE-AUDIT`
- Base SHA: `b4f9b7f9a81c175e505934cb38933bc4f727357d`
- Task branch: `task/OPC-PHASE-1-SCENARIO-IRIU-COMPLETE-AUDIT`
- Scope: source, tests, Git history, backup evidence and documentation audit
  only

The base worktree was clean and the base branch was synchronized with origin
at divergence `0/0` before this task branch was created.

## 2. Protected boundary

- Application source, tests, database, migrations, build configuration and
  runtime behavior were not changed.
- No canonical owner database was opened.
- No Flutter analyze, test or build command was run.
- PREDMET remains the sole authoritative business truth.
- SCENARIO remains part of PREDMET; FIRMA settings may only provide prospective
  templates/defaults.
- Windows and Android business results remain equal.
- Local `PROJECT_DOCS` were not changed.
- Before any application-code implementation, Codex must stop and continue in
  a new chat within Projects after notifying the owner.

## 3. Executive conclusion

The current source does not contain a user-configurable scenario system.
It contains:

1. one stored scenario ID:
   `default_funeral_ceremony_policy`;
2. several hard-coded condition families;
3. PREDMET-owned stored IRiU rows;
4. a derived truth layer that marks rows active, recommended or suppressed;
5. UI lifecycle flows that add rows, suppress them and sometimes ask the user
   to keep/remove or add/skip them.

The existing PREDMET, IRiU, evaluator and derivative foundations are reusable.
A full rewrite is not supported. A simple targeted patch is insufficient,
because safe automatic scenario reconciliation requires persisted information
that does not exist today.

Recommended architecture:

`RETAIN PREDMET/IRiU CORE + BOUNDED PARTIAL REWRITE OF THE SCENARIO/CONFIGURATION BOUNDARY`

## 4. Current scenario identity and storage

### 4.1 One scenario ID, many condition families

Evidence:

- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart:8`
- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`

`BusinessScenarioId.values` contains one value. Unknown or empty values resolve
to the same default. The source therefore has no implemented set of distinct,
named, editable scenarios.

The operational business variants are condition combinations inside the
default policy:

| Family | PREDMET inputs | Current IRiU consequence |
| --- | --- | --- |
| Death place | `mestoSmrti` | non-hospital service block or hospital transport |
| Burial/override | ceremony, grave type, cause | limeni uložak and lemovanje |
| Cemetery type | `tipGroblja` | prevoz sprovoda |
| Opelo | `opelo` | komplet za opelo |
| International burial | `sahranaVanSrbije` | international transport/documentation and balsamovanje |
| Reception | `docekPosmrtnihOstataka` | cargo troškovi |
| KATALOG basic policy | FIRMA catalog configuration at new-PREDMET creation | prospective basic IRiU rows |

KATALOG basic policy is not itself SCENARIO. It supplies the applicable basic
block and must remain independent from scenario predicates and ordering.

### 4.2 PREDMET persistence and JSON

Evidence:

- `lib/core/database/tables/predmeti_table.dart:12`
- `lib/core/database/database.dart:129`
- `lib/features/predmeti/data/predmeti_repository.dart:127`
- `lib/core/json_transfer/predmet_json_transfer_core.dart:80`

`businessScenarioId` was added at schema 11, defaults to the one built-in ID
and is transferred in single-PREDMET JSON. Missing legacy JSON values receive
the default.

Not implemented:

- scenario definition snapshot;
- scenario version/provenance;
- FIRMA scenario-template table;
- FIRMA individual/default scenario-set mapping;
- scenario template import/export;
- PODEŠAVANJA scenario UI;
- validation of a referenced editable scenario definition.

### 4.3 Business version/log gap

Evidence:

- `lib/features/predmeti/data/predmeti_repository.dart:421`

`snapshotZaSaveCommit` explicitly removes `businessScenarioId`, and the
snapshot contains only `PredmetiData`, not child IRiU rows. A future scenario
change could therefore alter scenario identity and IRiU truth without entering
the present PREDMET-only save/confirmed comparison.

The future boundary must treat controlled SCENARIO replacement and its IRiU
reconciliation as one PREDMET business change. It must use the owner-approved
local log/version policy without storing a second historical PREDMET copy.

## 5. IRiU row classes and missing provenance

Evidence:

- `lib/core/database/tables/iriu_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart:145`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/core_v2/models/iriu_truth_models.dart`

The same `iriu` table stores:

- built-in basic rows;
- FIRMA-configured basic rows snapshotted into a new PREDMET;
- scenario/condition-created rows;
- catalog-selected rows;
- manually added rows;
- multiple rows of the same category.

Persisted columns do not identify which mechanism owns a row. `managedKind` is
derived later from `interniNaziv`; it is not row provenance. A manually or
catalog-added row can share a category with a scenario-generated row.

Consequently, implementing owner-required “remove every row no longer
applicable” by category alone can delete a row the scenario did not create.
This is a PREDMET data-loss risk and a hard stop for an isolated delete patch.

## 6. Current condition-change behavior versus owner authority

### 6.1 Death-place and Blok-2 flows

Evidence:

- `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart:285`

Current behavior:

- a no-longer-applicable managed row becomes suppressed;
- the user receives `ZADRŽI/UKLONI`;
- some new Blok-2 rows require `DODAJ/NE DODAJ`;
- dismissal memory can prevent later automatic re-addition.

### 6.2 International, reception and opelo flows

Evidence:

- `lib/features/predmeti/presentation/segments/iriu_segment.dart:314`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart:181`

UI triggers add rows only on `false → true` / `NE → DA`. On reversal, stored
rows remain and the truth layer marks them suppressed. There is no complete
automatic physical reconciliation.

### 6.3 Newer owner decision

Authority:

- `docs/OPC_GATE_0_SEMANTIC_OWNER_DECISION_RECORD_01.md`

`ODQ-SCENARIO-001` supersedes the older dialog/keep/archive assumptions:

- only an eligible `OTVOREN` PREDMET may change scenario;
- the user receives one business confirmation;
- OPC automatically removes no-longer-applicable rows and their user values;
- no inactive/history copy is retained;
- returning to an old scenario does not restore removed values;
- all new required rows are automatically created empty;
- operational consequences are automatically reversed;
- unresolved technical reversal uses hidden, non-financial
  `RECONCILIATION_PENDING`, retry and recovery;
- the user does not resolve technical consequences.

The authoritative plan still contained older preview/keep/archive wording.
This task corrects that documentation conflict without implementing it.

## 7. Known defect findings

### 7.1 Basic/scenario row-order incident — confirmed

Authority:

- `docs/tasks/OPC_TASK_IRIU_BASIC_SCENARIO_ORDER_REGRESSION_AUDIT_REPORT.md`

Current source:

- `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart:7`
- `test/iriu_catalog_basic_category_policy_test.dart:160`

Commit `c6fae079482097231f4513f683367d30f4e13f58` moved scenario rows ahead of
the basic block and added a test that protects the wrong behavior.

Owner-locked result:

1. `SANDUK` first;
2. complete applicable basic block;
3. scenario-dependent rows;
4. user-configurable basic behavior preserved without changing SCENARIO.

No isolated correction is authorized. Locked/completed PREDMET truth must not
be rewritten by a global data migration.

### 7.2 Stale/unneeded rows — confirmed

The current suppress/dialog behavior is proven by source and tests. It does not
meet `ODQ-SCENARIO-001`. The implementation dependency is not merely UI:

- reliable row provenance;
- scenario snapshot/version;
- STANJE ROBE compensation;
- transaction/retry recovery;
- derivative and financial exclusion while pending;
- business version/log integration.

### 7.3 Urn `MESTO CEREMONIJE` — semantic/UI gap confirmed

Evidence:

- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart:417`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart:658`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_data_builder.dart:132`

`GROBLJE` is currently displayed for every ceremony type and stored in
`Predmeti.groblje`. Urn-specific controls appear only for cremation variants,
not for `SMESTAJ_URNE`. Downstream code already interprets `groblje` first as
`mestoCeremonije`.

The missing user-visible business contract is confirmed. One owner semantic
gate remains:

> Is urn `MESTO CEREMONIJE` the same PREDMET fact already stored as `groblje`,
> with a scenario-appropriate label/UI, or is it a distinct business fact?

If it is the same fact, reusing the existing field avoids a migration and keeps
reminders/statistics/documents aligned. If distinct, a new field and migration
are required. Codex must not choose the business meaning.

### 7.4 `JAVNO MESTO/NEDEFINISANO` — exact bug not yet reproducible

Evidence:

- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart:125`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart:127`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart:256`
- `test/business_policy_iriu_critical_scenarios_test.dart`

Current and two pre-regression backup source versions:

- normalize `ULICA` and `JAVNO MESTO` to `ULICA / JAVNO MESTO`;
- store the cause option as `NEDEFINISANA`;
- for non-cremation, `NEDEFINISANA` activates limeni uložak/lemovanje;
- death place independently activates the non-hospital service block.

There is no focused combined `JAVNO MESTO + NEDEFINISANA` test. More
importantly, public documentation names the defect but does not record the
observed wrong result and required correct result. The audit therefore does
not falsely declare a root cause.

Required owner fixture before implementation:

- exact field/value combination;
- actual unwanted IRiU rows or missing rows;
- required correct rows and order;
- cremation/non-cremation and grave-type context if relevant.

This is a business-result clarification, not a request for the owner to infer
technical behavior.

## 8. Downstream consequence map

| Consumer | Current dependency | Risk when SCENARIO changes |
| --- | --- | --- |
| IRiU UI | stored rows plus derived truth | stale/suppressed rows and wrong order |
| FINANSIJE | active positive IRiU rows | wrong totals if pending/stale row remains active |
| NALOG ZA OPREMANJE | PREDMET plus truth-filtered rows | wrong DA/NE or duplicate-category selection |
| Other PDF documents | Lista/financial prepared data | current derivatives can change with evaluator behavior |
| STANJE ROBE | selected covered IRiU rows and effects | deletion requires reversal/compensation |
| JSON | PREDMET scenario ID and IRiU rows | no scenario definition/provenance transfer today |
| Future completion signals | not implemented as a complete model | required fields must be derived from the PREDMET-owned scenario snapshot |
| FIRMA/KATALOG | prospective defaults/knowledge | must not rewrite existing PREDMET truth |

## 9. Test evidence and gaps

Existing focused evidence covers:

- grob/grobnica and cause overrides;
- cremation exclusion;
- current removal/add confirmation behavior;
- dismissal behavior;
- international/BALSAMOVANJE, reception/CARGO and opelo suppression;
- current inverted ordering expectation;
- scenario ID JSON preservation/defaulting.

Missing contract coverage:

- exact `JAVNO MESTO + NEDEFINISANA` result;
- full death-place transition matrix;
- international/reception/opelo physical reconciliation;
- row provenance and duplicate-category safety;
- PREDMET business version/log behavior on scenario change;
- completed/locked PREDMET stability;
- scenario template/set import/export;
- Windows/Android scenario-result parity;
- urn `MESTO CEREMONIJE`;
- `RECONCILIATION_PENDING` recovery;
- basics-first behavior across every mutation path.

No tests were run because this is a no-code audit and several existing tests
encode current behavior rather than the owner-required future contract.

## 10. Architecture option comparison

| Option | Assessment |
| --- | --- |
| Targeted fixes only | Rejected as complete solution. Can fix labels/order but cannot safely implement automatic reconciliation without provenance and snapshots. |
| Progressive refactor only | Necessary for extracting evaluator and repository responsibilities, but new persistence contracts still create a distinct subsystem boundary. |
| Bounded partial rewrite | Recommended for scenario/configuration persistence, validation, evaluation and reconciliation orchestration while adapting the existing PREDMET/IRiU core. |
| Full project rewrite | Not supported. It creates unnecessary canonical database, JSON, parity and derivative risk. |

## 11. Recommended technical boundary

Names are architectural roles, not final schema identifiers:

1. **FIRMA scenario templates**
   - stable ID;
   - version;
   - user-visible name;
   - validated deterministic definition;
   - individual and scenario-set defaults;
   - schema-versioned import/export.
2. **PREDMET scenario snapshot**
   - selected template stable ID/version/provenance;
   - immutable definition snapshot used by that PREDMET;
   - applied timestamp/actor metadata;
   - included in PREDMET JSON.
3. **IRiU provenance**
   - basic, FIRMA-basic, scenario-created, catalog-selected or manual origin;
   - source scenario snapshot/rule identity where applicable;
   - no inference from category alone.
4. **Reconciliation application service**
   - one owner-approved confirmation boundary;
   - deterministic desired-vs-current plan;
   - automatic delete/add;
   - STANJE ROBE reversal;
   - idempotent retry;
   - hidden `RECONCILIATION_PENDING`;
   - no technical decision burden for the user.
5. **Compatibility adapters**
   - current hard-coded rules become initial editable template content;
   - existing truth/finance/document consumers read the new snapshot through a
     stable adapter during migration.

## 12. Existing-database migration boundary

Current schema is 22. Future migration must be additive and proven on isolated
copies/fixtures.

For existing PREDMET records:

- do not infer and apply a new editable scenario retroactively;
- do not reorder or delete locked/completed PREDMET IRiU rows globally;
- preserve stored PREDMET/IRiU as historical truth;
- mark legacy scenario provenance explicitly where exact creation origin is
  unknowable;
- allow an eligible open PREDMET to adopt a scenario only through the
  controlled owner-approved action;
- new PREDMET records use the current FIRMA default snapshot prospectively.

Unknown legacy row provenance must never be guessed solely from
`interniNaziv`.

## 13. Respectful implementation dependency

No implementation is authorized by this report. The safe future order is:

1. close the two owner business fixtures in section 7;
2. approve the bounded scenario/configuration architecture at the Architecture
   Decision Gate;
3. write characterization tests for current databases, locked PREDMET records,
   derivatives and stock consequences;
4. add scenario template/snapshot/provenance/recovery persistence through
   isolated migration fixtures;
5. introduce the deterministic evaluator/reconciliation adapter;
6. correct ordering, stale-row behavior, urn place and the confirmed
   `JAVNO MESTO/NEDEFINISANO` defect inside this protected boundary;
7. expose corrected scenarios through PODEŠAVANJA;
8. add individual and FIRMA-set defaults and template import/export;
9. prove JSON, Windows/Android, finance, documents, stock and historical
   stability;
10. pass the successive validation/build/runtime gates.

## 14. Owner decision queue

Only two current business decisions/fixtures remain:

1. exact actual-versus-required result for
   `JAVNO MESTO/NEDEFINISANO`;
2. whether urn `MESTO CEREMONIJE` is the existing `groblje` business fact or a
   distinct PREDMET field.

Technical decisions delegated to Codex by the Decision Authority Matrix:

- bounded partial scenario/configuration rewrite;
- snapshot/provenance/reconciliation architecture;
- transaction, retry and recovery mechanism;
- additive migration and compatibility adapter design;
- test decomposition and module boundaries.

These technical choices return to the owner only if they would change a
business result, PREDMET authority or Windows/Android parity.

## 15. Documentation updates

- `docs/tasks/OPC_TASK_PHASE_1_SCENARIO_IRIU_COMPLETE_AUDIT_REPORT.md`
- `docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`

Final commit SHA and remote synchronization evidence are supplied by the Git
completion gate.
