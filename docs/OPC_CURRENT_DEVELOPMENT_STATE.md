# OPC current development state

**Status:** `CURRENT RECONCILED CONTINUITY SUMMARY`

**Reality-reconciliation baseline:** `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`
**Current documentation baseline:** `4e74772f72da921a2c94207a48c5530bfcc59e61`

**Reconciled:** 2026-08-17

This is the concise current-state entry point. Detailed dependency ordering is
in `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`; forensic
evidence and the full reality matrix are in
`docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`.

## Phase 1 documentation navigation

The current product/engineering information homes are:

- `docs/OPC_PRODUCT_AND_DOMAIN.md` — product purpose, PREDMET authority, derivatives and invariants;
- `docs/OPC_ARCHITECTURE.md` — current architecture, deployment and source responsibility boundaries;
- `docs/OPC_DEVELOPMENT.md` — development, local+GitHub authority and validation workflow;
- `docs/OPC_QUALITY_RELEASE.md` — quality, regression, runtime and release gaps;
- `docs/OPC_ENGINEERING_PROFILE.md` — adopted tailored engineering profile;
- `docs/OPC_PHASE1_DOCUMENTATION_MIGRATION_AUTHORITY_MANIFEST.csv` — per-file migration/authority evidence.
- `docs/OPC_INTERNAL_DEVELOPMENT_CONTROL_REGISTER.md` — public boundary record for local-only pseudocode control;

This document remains a detailed continuity/dependency summary. The Phase 1
homes are the compact navigation layer; older chronology and supporting reports
remain classified by the migration manifest and are not silently deleted. Task
review indexes remain local, non-authoritative convenience layers and are not
part of the current product-documentation navigation.

The application/product name is `OPC`. `OPC Srbija` is internal shorthand only
for the stable Serbian-market product-line gate and is not a rename.

## Current proven baseline

- OPC is a functional Windows/Android Flutter application with local
  Drift/SQLite and user-controlled JSON transfer.
- `PREDMET` remains the sole business truth.
- Architecture decision: retain the codebase as the current baseline; evidence may
  justify retain, move, split, merge, refactor, partial rewrite, full
  reconstruction or removal while preserving business truth, verified behavior,
  compatibility, migrations, interoperability contracts and regression
  guarantees.
- Automatic `ZAVRŠEN` is retired. The implemented transition is explicit
  `OTVOREN → ZATVOREN → ZAVRŠEN`; final state is immutable for direct edits and
  reopening. Focused tests pass; separate final platform runtime acceptance is
  still required.
- SCENARIO is an operational module under `MODULI`, not `PODEŠAVANJA`.
- SCENARIO implements user-editable OSNOVNI PAKET + additional scenario package,
  1,008 owner-map combinations, PREDMET-derived conditions, PREDMET-owned
  snapshot/provenance, controlled reconciliation, manual/legacy row protection
  and non-retroactivity.
- Windows live release runtime and a physical Android 15 device both passed the
  production `MODULI → SCENARIO` OPEN-PREDMET selector, derived/current versus
  applied snapshot and required IRiU behavior.
- Full eight-axis GRADSKO/LOKALNO consistency passed cross-platform. The earlier
  mismatch report was a selected-state reading error, not a source/DB defect.
- Independent 1,008 golden and production E2E gates pass 1,008/1,008 with zero
  key, item, status or ordering mismatches.
- KATALOG/IRiU FIKSNA pricing, CRNINA as KATALOŠKA, applied price snapshot,
  `KOM × CENA = IZNOS`, manual amount override and OSNOVNI pricing are
  technically implemented and tested.
- Latest inherited technical baseline: analyzer PASS; complete suite 393
  passed, 7 skipped, 0 failed; Windows and Android release builds PASS.

## Important partial/open state

| Area | Current state | Next evidence/action |
| --- | --- | --- |
| SCENARIO JSON | Production `OPC_PREDMET` now carries an optional hashed Single-PREDMET snapshot/provenance block; `OPC_BACKUP` carries snapshot/provenance sections. Legacy schema 6/7 remains readable without falsely claiming imported continuity. | Complete full analyze/build and Windows/Android round-trip acceptance; Android physical transfer remains deferred. |
| PREDMET/referential lifecycle | Hard-delete and scoped restore work have technical/runtime evidence; FK remains off and some RI owner gates remain. | Close only release-required risks; classify deferred RI work explicitly. |
| Windows single-instance | Audit proved concurrent canonical DB risk; no native process guard exists. | Implement the locked named-mutex and installer running-app contract; runtime accept. |
| Windows startup/exit | Installed baseline reached login in about 8–9 s and slow exit was observed. | Current-tip instrumented measurement and owner target before any correction. |
| Android PARTE performance | Source risks are mapped; focused current-device profiling acceptance is absent. | Reproduce/profile before choosing a correction. |
| IRiU/KATALOG performance | Repository behavior is characterized; owner-observed slowdown is not decomposed. | Time repository, first frame, photo read and decode separately. |
| PODSETNIK | Prior orphan/restore corrections exist; complete signal/informed-reminder model does not. | Full lifecycle-aware program after owner-confirmed signal model. The Android notification for a `ZAVRŠEN` PREDMET belongs here, not in an isolated patch. |
| Backup/restore release gate | Prior successful incidents are scoped evidence. | Repeat final rehearsal on release-candidate artifacts after SCENARIO carrier integration. |
| Documents | RAČUN PDF exists; NALOG CVEĆARI standalone generator is not proven; standard PDF typography refinement remains. | Owner decisions for RAČUN availability/default and NALOG content/scope; bounded document work. |
| Windows light/dark theme | `COMPLETE — OWNER RUNTIME PASS`; owner authority is `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED`. | No theme work remains. Reopen only for a proven regression or new owner decision. Full cross-platform UI/UX audit remains a separate open area. Contextual help is a later design direction. |
| MODUL DVE VALUTE | Not implemented. | Mandatory before stable OPC v.1 and before `OPC_v.1_Int`. |
| App identity/release | Current technical Android identity is `com.tale.opc_v4`, version `4.0.0+1`; this is not a final owner release decision. | Decide version/update channel/release baseline; visible name remains OPC. |

## Current dependency order

Documentation reconciliation → Windows single-instance and remaining
release-risk integrity closure → evidence-first performance closure → SCENARIO
continuity carrier/order/KATALOG/PDF fidelity closure → complete signal model and full PODSETNIK upgrade →
remaining JSON/document/UI work → MODUL DVE VALUTE → final
Windows/Android semantic parity and backup/restore rehearsal → app
identity/version/update channel → stable OPC v.1 product-line gate → optional
non-blocking debt → `OPC_v.1_Int` → signing/professional handover.

## Active owner decisions

- performance acceptance targets after measurement;
- complete signal meanings for PODSETNIK;
- NALOG CVEĆARI content and PDF/DOCX scope;
- RAČUN FIRMA availability/default;
- EUR activation timing and eligible open-PREDMET treatment;
- final app version/update channel and release baseline;
- publisher/signing-key custody.

Windows light/dark theme is not an active owner decision or roadmap dependency.
Its previous partial/pending wording is superseded by the explicit owner runtime
authority `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED`. This closure
does not claim that the broader Windows/Android UI/UX audit is complete.

Already decided and not returned to the active queue: explicit completion
lifecycle, SCENARIO ownership/placement/application, application name `OPC`,
dual currency before `OPC_v.1_Int`, and non-blocking Stage 2 cleanup.

Windows real-runtime closure remains partial: installed cold start/reopen,
target OPEN PREDMET/IRiU loading, and repaired-state startup/PREDMET loading
pass; citation non-growth remains closed. The source-level canonical
KATALOG→IRiU snapshot contract and bounded malformed-row repair now pass
focused tests/analyzer/build, but the repaired build is not deployed to the
protected install. Rendered concrete KATALOG names, IRiU order, SCENARIO
viewing, LISTA visual acceptance and canonical deduplication remain explicit
release gates. See
`docs/OPC_CANONICAL_KATALOG_IRIU_PIPELINE_WINDOWS_CLOSURE_REPORT.md`.

## Prohibitions

No current authority permits application renaming, Web implementation,
international localization, automatic exchange rates, tax/VAT/fiscalization,
package restriction restoration, isolated PODSETNIK status patching or
canonical database replacement. Any future structural choice, including
retain/move/split/merge/refactor/partial rewrite/full reconstruction/removal,
requires evidence and an authorized scope that preserves business truth,
verified behavior, compatibility, migrations, interoperability contracts and
regression guarantees.

## Documentation truth recovery — 2026-08-14

The active IRiU business invariant is package-based and generic:

```text
ordered OSNOVNI PAKET
  -> ordered applied SCENARIO PAKET
  -> manual/unpredicted items
```

`OSNOVNI PAKET` here means the editable SCENARIO goods/services composition
block. It is not the abandoned native licensing/entitlement terminology
`Osnovni/Srednji/Potpuni`.

Package membership and the configured order inside each package are the
business authority. Package contents may change by user, scenario and time.
Concrete item names, item counts, persisted `redosled`, provenance, current
source output and golden fixtures are technical evidence only and must not
become a universal business order.

The recent IRiU ordering reports and tests are therefore classified as
technical or historical evidence. They may prove that an implementation
matches an expectation, but they cannot establish that expectation. Any
fixture that lacks a package-authority reference is characterization only and
does not open an implementation or acceptance gate.

The active synthesis must be read with this correction: the earlier statement
that the owner-required IRiU target was unknown is superseded at the model
level. The generic package invariant is established; concrete package content
is intentionally not part of the ordering algorithm.

Known separate technical debt remains open and unimplemented:

```text
IriuSegment.initState
  -> _runScenarioSync
  -> ScenarioModuleRepository.ensureModuleAndDefaults()
  -> _ensureOwnerMapDefinitions()
  -> _repairKnownOwnerMapProtectiveEquipmentGap()
  -> identical scenario_definitions payload UPDATE (updated_at only)
```

This documentation correction does not authorize a code patch, canonical
database rewrite, test-fixture rewrite or runtime acceptance claim.

## IRiU package-authority display ordering implementation — 2026-08-14

The approved generic invariant is now implemented on the shared production
projection used by the IRiU table:

```text
ordered OSNOVNI PAKET
  -> ordered applied SCENARIO PAKET
  -> manual/unpredicted items
```

The implementation consumes ordered editable OSNOVNI package JSON and the
active applied SCENARIO package membership/order. It does not use concrete
item lists, persisted `redosled`, provenance sequence, current output or
golden fixtures as business authority. Rows outside both package memberships
remain in the final manual/unpredicted partition. No canonical database,
historical snapshot, package membership, or SCENARIO no-op debt path was
changed. See
`docs/OPC_IRIU_PACKAGE_AUTHORITY_DISPLAY_ORDER_IMPLEMENTATION_REPORT.md`.

## LUNA canonical recovery reconciliation — 2026-08-13

The canonical recovery execution supersedes the scoped Windows deployment
deferral for this data-recovery scope. The promoted canonical database is
integrity-clean, all current PREDMET/IRiU business rows are preserved, the
citation catalogue is deduplicated, and schema-9 clean backup/clean-room
restore equivalence is proven. Historical PREDMET snapshots are immune to
later KATALOG changes. The installed protected-folder visual gate remains a
separate owner deployment concern; no ACL or ownership change was attempted.

## SCENARIO module lock — 2026-08-16

The accepted SCENARIO implementation is now a locked module baseline. The
locked production source is
`a8218537c1aa85b61fe5c85c21dbd03672f6e77c`; the lock governance documents are
`docs/OPC_SCENARIO_MODULE_LOCK.md` and
`docs/OPC_SCENARIO_MODULE_LOCK_REPORT.md`.

Owner acceptance is recorded for both platforms:

```text
WINDOWS INTERACTIVE RUNTIME ACCEPTANCE — PASS
ANDROID NARROW INTERACTIVE ACCEPTANCE — PASS
```

Future SCENARIO production changes must explicitly cross the lock boundary by
owner-authorized unlock, proven regression correction or authoritative new
business policy. The locked regression contract is impact-based: Tier 1 is
task-targeted, Tier 2 is the documented 12-file SCENARIO contract, and Tier 3
is full/deep regression for unlocks, shared PREDMET/IRiU/KATALOG/database/JSON
impact, broad refactors, milestones, release candidates, uncertain impact or
owner request. Existing tests remain available and none were deleted.

The lock task did not create a backup or restore point. A fresh verified
post-lock backup/restore-point task is the next separate authorized step.
