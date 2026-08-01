# OPC Phase 4 MODULI/SCENARIO Contract Audit

**Task branch:** `task/OPC-PHASE4-MODULE-SCENARIO-CONTRACT-AND-UI`

**Base SHA:** `95603aeb44764216c9b7c5226e7a8e5a65a8790e`

**Scope:** source and documentation audit for the owner-requested move from
hard-coded scenarios to module-owned, UI-defined scenarios. No production
source, schema, migration, database, JSON, UI or runtime behavior was changed.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

The authoritative plan, module contracts, current state and Incident/Anti-Drift
Register were read. INC-001 remains preserved; no ordering correction is
silently included in this audit.

## Owner authority recorded

- Every scenario owns a defined IRiU consequence set.
- A criterion change must inform the user, create newly applicable
  consequences and remove every no-longer-applicable scenario-owned row/value;
  stale scenario consequences are not acceptable.
- SCENARIO is part of PREDMET authority: no valid PREDMET exists without a
  selected scenario snapshot.
- MODULI own scenario definitions, defaults and UI configuration. The selected
  scenario and applied immutable snapshot remain PREDMET-owned.
- Existing hard-coded scenarios are first exposed as module defaults and then
  made UI-upgradeable. Editing a module default must never silently rewrite an
  existing PREDMET.

## Current source facts

1. `ModuliScreen` and the settings module tab are static presentation routes;
   there is no persisted module registry or scenario-template repository.
2. `OpcModule.businessPolicyScenario` is an entitlement enum. Native access is
   currently unrestricted by package policy; entitlement is not a domain
   scenario owner.
3. `AppDatabase` is schema version 22. The only persisted global module switch
   found is the STANJE ROBE operational flag.
4. `predmeti.businessScenarioId` is the only scenario persistence. The current
   registry contains one ID, and unknown/empty IDs resolve to the default.
5. `BusinessPolicyEvaluator` resolves that ID but applies hard-coded rules.
   The rules read PREDMET facts (`mestoSmrti`, `uzrokSmrti`, ceremony,
   cemetery/grave, international/reception and opelo) and produce IRiU and
   operational consequences.
6. `iriu` rows have no provenance. The database cannot currently distinguish a
   basic, catalog, scenario-managed or manual row, so safe stale removal is not
   implementable by an isolated delete.
7. Single-PREDMET JSON transfers only `businessScenarioId`; they do not carry a
   scenario version/snapshot or IRiU provenance. Existing backup/restore lanes
   likewise need an explicit compatibility contract before schema change.

## Minimum safe domain contract

The implementation must introduce additive, versioned data rather than
reinterpreting `businessScenarioId`:

- **Module definition:** stable module ID, display metadata, scope/owner,
  schema version, status and audit fields. Entitlement/package availability is
  not module business truth.
- **Scenario definition/version:** stable scenario ID, module ID, immutable
  published version, draft/published/retired state, name, description,
  default/lineage metadata and audit.
- **Criteria DSL:** declarative, deterministic rows/AST referencing only a
  whitelist of normalized PREDMET fields. Operators and unknown/empty behavior
  are validated; no arbitrary code and no derivative-as-input rule.
- **Consequence DSL:** stable IRiU/KATALOG target, action (required/create,
  recommend or suppress), managed policy, ordering boundary, display snapshot
  and consequence reference. Module definitions do not own PREDMET facts,
  prices or stock truth.
- **PREDMET assignment:** module ID, scenario ID/version, canonical immutable
  snapshot/hash, assigned actor/time and business-version linkage. Published
  default edits never mutate an existing PREDMET implicitly.
- **IRiU provenance:** origin kind, module/scenario/version/rule IDs and
  lifecycle operation metadata, so only scenario-owned rows can be removed.
- **Reconciliation/recovery:** operation ID, old/new snapshot, pending/applied/
  failed/compensated state, compensation payload and retry evidence. Changes
  are explicit, one-confirmation, atomic or safely compensating, and forbidden
  for completed/locked PREDMETI.
- **Transfer/migration:** schema/version compatibility, module/scenario
  references, self-contained PREDMET snapshot and provenance for Windows and
  Android. Unknown definitions must remain readable from the snapshot or fail
  before destination mutation.

## Required dependency order

1. Owner confirms module scope and scenario/default ownership.
2. Additive schema/data-contract design and migration fixtures.
3. Migrate the current hard-coded default into an immutable published module
   scenario version without changing current outputs.
4. Add pure evaluator tests for criteria/consequence DSL parity.
5. Add PREDMET assignment/snapshot and IRiU provenance.
6. Implement one-confirmation reconciliation (remove stale, create new,
   reverse operational consequences, retry/rollback).
7. Add UI for module defaults/scenario editing and eligible PREDMET scenario
   change only after the domain contract is proven.
8. Add JSON/backup/restore parity tests; runtime/build remain cumulative owner
   acceptance, not technical proof.

## Owner decisions still required before production source change

Recommended defaults are shown first:

1. **Module scope:** one always-available core `SCENARIO` module with
   module-owned defaults; no package restriction. Alternative: firm-level
   activation switch.
2. **Default model:** one published default per module plus copy/version; editing
   creates a new version and never rewrites existing PREDMETI.
3. **Criteria language:** whitelist the currently observed PREDMET fields and
   operators `equals`, `in`, `not`, range and AND/OR groups; no arbitrary code.
4. **Consequence actions:** `REQUIRED`/create, `RECOMMENDED`, and
   `SUPPRESSED`; scenario-owned rows are removable, while manual/catalog rows
   remain outside automatic cleanup.
5. **Scenario change:** eligible `OTVOREN` only, one business confirmation,
   stale scenario rows/values removed, new rows empty, no restore on returning
   to an old scenario, and STANJE ROBE compensation/retry hidden from the user.
6. **Scope/import:** module definitions are firm/device configuration, while a
   PREDMET transfer carries its self-contained selected snapshot and provenance.

Until these six choices are confirmed, production UI/schema implementation is
blocked by a real business-contract gap. This audit intentionally leaves the
functional baseline unchanged.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

PASS / NOT PASS: PASS

No canonical database, backup, restore point, Git history or protected
`BACKUPS` content was modified.
