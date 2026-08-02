# OPC Phase 4 MODULI/SCENARIO Contract Audit

**Task branch:** `task/OPC-PHASE4-MODULE-SCENARIO-CONTRACT-AND-UI`

**Base SHA:** `95603aeb44764216c9b7c5226e7a8e5a65a8790e`

**Final implementation SHA:** `89228d95026e389eb3d13684d8089aa4da2bf629`

**Characterization evidence SHA:** `7d7eee1d87fc6cf382819a5d649d5e03d3c532bc`

**Persistence hardening evidence SHA:** `857f7fa3b8fdb6c18d855bc7c0ac9e4b7c8b903a`

The final implementation SHA is the pushed commit that contains the schema
23 persistence boundary and its migration evidence. The report-closure commit
contains documentation only.

No new application mutation begins without the protected rollback evidence in
`docs/tasks/OPC_RESTORE_POINT_PHASE4_DEFAULT_MIGRATION_20260801.md` and its
corresponding `BACKUPS/` archive.

**Scope:** source/documentation audit plus bounded domain and additive
persistence-contract slices for the owner-requested move from hard-coded
scenarios to module-owned, UI-defined scenarios. Schema 23 migration tables
were added without seed rows or runtime/UI materialization; JSON,
reconciliation and scenario-management UI remain unchanged.

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

## Package boundary clarified by the owner

The SCENARIO module owns two user-facing package layers:

1. **OSNOVNI PAKET ROBE I USLUGA** — the firm's user-defined base set for new
   PREDMETI;
2. **SCENARIO PAKET** — the additional or changed set selected by the active
   scenario criteria.

The UI calls every materialized line simply **STAVKA**. It does not expose
`IRIU`, `scenario-owned` or other technical provenance terms.

KATALOG remains the master dictionary of standard categories, articles,
stable IDs, labels, prices and photographs. SCENARIO selects KATALOG entries
into the OSNOVNI PAKET or a scenario package; it does not redefine the same
article/category. The existing KATALOG policy switch
`osnovnaUSvakomPredmetu` is therefore a candidate for migration into the
OSNOVNI PAKET and removal from the KATALOG policy UI, not deletion of KATALOG
definitions.

Existing PREDMET rows remain untouched during this migration. Their future
provenance must distinguish OSNOVNI PAKET, SCENARIO PAKET and RUČNA STAVKA;
manual one-PREDMET additions remain valid exceptions and are never removed by
scenario reconciliation.

SCENARIO is configuration only. It defines package membership and criteria;
the selected scenario is evaluated and applied for the concrete PREDMET during
the ROBA I USLUGE/IRiU work flow. It must not silently rewrite every PREDMET
when the module configuration changes.

The current hard-coded gap `PRIVATNA BOLNICA` is corrected in the same bounded
source step: the MESTO SMRTI selector exposes it, and its current package is
the same as `STAN` and `DOM ZA STARE`. A focused business-policy regression
test protects this equivalence while the broader scenario engine remains under
the contract migration.

The first pure domain slice is now present in
`lib/features/predmeti/core_v2/scenario/scenario_contract.dart`. It models
whitelisted PREDMET criteria, AND/OR conditions, KATALOG category references,
required/recommended/suppressed actions, OSNOVNI PAKET and scenario-package
resolution. It is deliberately not wired to persistence or UI yet, so the
functional runtime path remains unchanged.

## Bounded implementation evidence

Focused command:

```text
C:\flutter\bin\flutter.bat test --no-pub test/scenario_package_contract_test.dart test/business_policy_iriu_critical_scenarios_test.dart
```

Result: **13 passed, 0 failed**.

Targeted static command:

```text
C:\flutter\bin\flutter.bat analyze --no-pub lib/features/predmeti/core_v2/scenario/scenario_contract.dart lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart test/scenario_package_contract_test.dart test/business_policy_iriu_critical_scenarios_test.dart
```

Result: **PASS — no issues found**.

Full suite command:

```text
C:\flutter\bin\flutter.bat test --no-pub
```

Result: **288 passed, 0 failed, 1 skipped**. The single skipped test is the
pre-existing documented skip. The suite completed without a failure after
the scenario contract, persistence contract and `PRIVATNA BOLNICA` source
correction.

## Second bounded contract slice

`lib/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart`
defines the non-UI persistence boundary: a PREDMET-owned immutable
scenario assignment snapshot, canonical content hash, self-contained scenario
definition/package data and STAVKA provenance (`OSNOVNI_PAKET`,
`SCENARIO_PAKET`, `RUČNA STAVKA`, `LEGACY`). The contract rejects unsupported
schema versions, tampered snapshots and incomplete scenario-owned provenance.
Schema 23 now stores the additive table boundary; it is not yet wired to
repository materialization, JSON import/restore or reconciliation.

Schema migration evidence:

```text
C:\flutter\bin\flutter.bat test --no-pub test/canonical_database_migration_recovery_test.dart
```

Result: **39 passed, 0 failed**. Targeted schema 23 fresh-create, 22-to-23
upgrade and future-version rejection tests also passed.

Focused persistence command:

```text
C:\flutter\bin\flutter.bat test --no-pub test/scenario_package_contract_test.dart test/scenario_persistence_contract_test.dart test/business_policy_iriu_critical_scenarios_test.dart
```

Result: **17 passed, 0 failed**.

Focused persistence analyze:

```text
C:\flutter\bin\flutter.bat analyze --no-pub lib/features/predmeti/core_v2/scenario/scenario_contract.dart lib/features/predmeti/core_v2/scenario/scenario_persistence_contract.dart test/scenario_package_contract_test.dart test/scenario_persistence_contract_test.dart
```

Result: **PASS — no issues found**.

## Current source facts

1. `ModuliScreen` and the settings module tab are static presentation routes;
   there is no persisted module registry or scenario-template repository.
2. `OpcModule.businessPolicyScenario` is an entitlement enum. Native access is
   currently unrestricted by package policy; entitlement is not a domain
   scenario owner.
3. `AppDatabase` is schema version 23. Additive tables now exist for module
   definitions, versioned scenarios, PREDMET snapshots and IRiU provenance;
   no rows are seeded and no repository/UI consumes them yet.
4. `predmeti.businessScenarioId` remains the only active scenario reference
   in runtime logic. The current registry contains one ID, and unknown/empty
   IDs resolve to the default.
5. `BusinessPolicyEvaluator` resolves that ID but applies hard-coded rules.
   The rules read PREDMET facts (`mestoSmrti`, `uzrokSmrti`, ceremony,
   cemetery/grave, international/reception and opelo) and produce IRiU and
   operational consequences.
6. Existing `iriu` rows have no backfilled provenance. The new
   `iriu_provenance` table can distinguish future `OSNOVNI_PAKET`,
   `SCENARIO_PAKET`, `RUČNA_STAVKA` and legacy rows; KATALOG-origin data is
   currently represented through the applicable package origin, not a separate
   provenance enum. Safe stale removal is not implemented by this migration.
7. Single-PREDMET JSON transfers only `businessScenarioId`; they do not carry a
   scenario version/snapshot or IRiU provenance. Existing backup/restore lanes
   likewise need an explicit compatibility contract before schema change.

## Default policy characterization gate

Before repository or JSON materialization, the currently shipped default
policy was characterized as an exact output matrix in
`test/scenario_default_policy_characterization_test.dart`. The evidence locks
the existing hard-coded behavior for:

- `MESTO SMRTI`: `STAN`, `DOM ZA STARE`, `PRIVATNA BOLNICA`, `ULICA` and
  `JAVNO MESTO` share the six-row package; `BOLNICA` has only
  `PREVOZ_DO_GROBLJA`; `DRUGO` follows the six-row package; an empty value
  has no automatic rows;
- `BLOK 2`: `GROBNICA` and the `ZARAZNA` cause override produce `LIMENI
  ULOZAK` and `LEMOVANJE`; `NASILNA` and `NEDEFINISANA` are the same cause
  overrides; cremation suppresses both, and a local cemetery recommends
  `PREVOZ_SPROVODA`;
- stored-row truth additionally preserves international transport/documents/
  embalming, doček, opelo, BIOHAZARD and the protected `SANDUK` ordering
  anchor.

Focused command:

```text
C:\flutter\bin\flutter.bat test --no-pub test/scenario_default_policy_characterization_test.dart
```

Result: **4 passed, 0 failed**.

This is characterization evidence only. The current behavior is distributed
across `IriuTruthRules`, `BusinessPolicyEvaluator`, the MESTO SMRTI and BLOK 2
lifecycle services, and the catalog seed policy. The present
`ScenarioDefinition` DSL models criteria and category consequences, but does
not yet express the complete composition/order and lifecycle side effects
(dismissal memory, condition-change conflict and stale-row handling) without
an additional owner-approved rule-composition decision. Therefore no
immutable published default scenario representation was invented and no
repository/JSON wiring was added in this slice.

The follow-up ordered-rule candidate was also rejected before commit. The
existing snapshot serializer/hash still carries only the legacy
condition/consequence shape; accepting a domain-only `rules` field would lose
it during round-trip. A future rule-set slice must version the serializer/hash,
preserve golden schema-1 snapshots and test multi-rule transfer before any
published default or repository materialization is introduced.

## Schema-1 persistence hardening evidence

The existing schema-1 contract was hardened without changing its payload
version or runtime authority: snapshot scenario graphs are deep-frozen before
hashing; explicit legacy wire names are used; unknown root/nested keys and
unknown enum values fail with `ScenarioPersistenceValidationException`;
`assignedByKorisnikId` must be positive; and provenance origin identity follows
the documented LEGACY/OSNOVNI_PAKET/SCENARIO_PAKET/RUCNA_STAVKA matrix.

Focused command:

```text
C:\flutter\bin\flutter.bat test --no-pub test/scenario_persistence_contract_test.dart
```

Result: **16 passed, 0 failed**.

Focused analyze result: **No issues found**. This remains schema-1 hardening
only. `createdAt` alignment with future Drift materialization, v2 envelope/
hash migration, repository/JSON wiring and runtime behavior remain gated.

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
2. Additive schema/data-contract design and migration fixtures. **COMPLETED
   for schema 23 tables and the recovery fixture; JSON/repository parity is
   still open.**
3. Migrate the current hard-coded default into an immutable published module
   scenario version without changing current outputs. **CHARACTERIZED; the
   representation remains owner-gated because the current DSL cannot yet
   encode the full hard-coded composition and lifecycle side effects.**
4. Add pure evaluator tests for criteria/consequence DSL parity.
5. Add PREDMET assignment/snapshot and IRiU provenance.
6. Implement one-confirmation reconciliation (remove stale, create new,
   reverse operational consequences, retry/rollback).
7. Add UI for module defaults/scenario editing and eligible PREDMET scenario
   change only after the domain contract is proven.
8. Add JSON/backup/restore parity tests; runtime/build remain cumulative owner
   acceptance, not technical proof.

## Owner decisions recorded for the next production slice

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

These choices are now the recorded owner boundary for the next production
slice. Additive schema and migration design may proceed, but production UI
materialization remains gated on migration fixtures, provenance tests and
rollback evidence. This audit intentionally leaves the functional baseline
unchanged apart from the explicitly tested `PRIVATNA BOLNICA` correction.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

PASS / NOT PASS: PASS

No canonical database, backup, restore point, Git history or protected
`BACKUPS` content was modified.
