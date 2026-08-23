# OPC current development state

**Status:** `CURRENT RECONCILED CONTINUITY SUMMARY`

**Reality-reconciliation baseline:** `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`
**Current documentation baseline:** `4e74772f72da921a2c94207a48c5530bfcc59e61`

**Reconciled:** 2026-08-17

This is the concise current-state entry point. Detailed dependency ordering is
in `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`; forensic
evidence and the full reality matrix are in
`docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`.

README is navigation only. The five substantive current OPC authority homes
are Product/Domain, Architecture, Development, Quality/Release and the
Engineering Profile. Supporting reports and historical records remain
subordinate evidence and must not create parallel mutable current authority.

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

## Case-2 full-backup fallback closure

The former Case-2 successor is now closed by a bounded selective fallback.
When an established local database receives a schema-9 `OPC_BACKUP` whose
FIRMA identity is incomplete, destructive replacement remains blocked. After
explicit user confirmation, only new and unambiguous PREDMET families are
imported through the existing single-PREDMET transfer seam, with destination-
local actor rebinding and one outer transaction. Same-identity, duplicate and
ambiguous rows remain local. FIRMA, users, catalog/configuration/templates,
PARTE, reminders, `logIzmena` and SCENARIO global/snapshot/provenance state are
not merged. Case 1 and fresh Case 3 recovery remain unchanged.

Evidence home: `docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_ACCEPTANCE_REPORT.md`
and its acceptance matrix. The explicit Case-2 successor is closed; broader
migration, recovery and cross-platform rehearsal remain separate.

## RR-005 closure reconciliation

RR-005 correction is `CLOSED — FULL ACCEPTANCE PASS — NO RR-005-SPECIFIC
SUCCESSOR`. Earlier disposable migration/recovery rehearsal records that say
`ACCEPTANCE INCONCLUSIVE` remain historical/separately scoped evidence; they
do not reopen RR-005 or create a competing current fact. Broader database,
JSON, migration or recovery work remains separately classified by the
operative roadmap and release controls.

## Important partial/open state

### RR-011 current-fact reconciliation — 2026-08-19

The current RR-011 fact is: `CLOSED — FULL ANDROID STRUCTURAL ACCEPTANCE PASS`. Device connectivity, authenticated synthetic execution, direct schema/integrity/FK checks, provenance cleanup, scenario-snapshot cleanup and supported full-backup export/import/restore are proven on the disposable `ANDROID_TEST` lane. The earlier ADB `offline` / Windows `10060` attempt is historical evidence only.

The final physical wave also exercised the separate single-PREDMET replacement path with a real snapshot/provenance precondition, stable PREDMET identity, dependent-row recreation, relaunch persistence and integrity/FK pass. The `OPC_PREDMET` JSON format does not carry scenario snapshot/provenance rows; that boundary is documented. RR-011 has no remaining successor; no SCENARIO or owner semantic state is changed.

| Area | Current state | Next evidence/action |
| --- | --- | --- |
| SCENARIO JSON | Production `OPC_PREDMET` now carries an optional hashed Single-PREDMET snapshot/provenance block; `OPC_BACKUP` carries snapshot/provenance sections. Legacy schema 6/7 remains readable without falsely claiming imported continuity. | Complete full analyze/build and Windows/Android round-trip acceptance; Android physical transfer remains deferred. |
| PREDMET/referential lifecycle | Hard-delete and scoped restore work have technical/runtime evidence; FK remains off and some RI owner gates remain. | Close only release-required risks; classify deferred RI work explicitly. |
| Windows single-instance / installer | Native singleton and Inno Setup running-app protection are `CLOSED — FULL ACCEPTANCE PASS`; I1/I2/I3 passed with the accepted compiled installer. | No RR-012 successor; reopen only for a proven regression or new owner decision. |
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

Documentation reconciliation → remaining PREDMET/referential/release obligations → evidence-first performance closure → SCENARIO
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

## RR-008 same-identity replacement — implemented acceptance

The accepted owner oracle is `CURRENT PREDMET TRUTH → CURRENT DERIVED STATE`.
The single-PREDMET replacement seam now stages and purges app-owned PARTE media,
removes stale PARTE preparation state, cancels old reminder IDs, and preserves
the local reminder configuration while reconciling stale reminder state against
current PREDMET truth. RR-008 does not define future PODSETNIK trigger,
scheduling or recreation semantics. Focused replacement integration, analyzer,
full-suite and Windows release-build evidence pass. Broader PARTE/notification product characterization remains a
separate concern; no SCENARIO or canonical-data behavior was changed.

## PREDMET local identity / recovery correction — bounded implementation

Individual PREDMET transfer now requires an active local ADMINISTRATOR or
SAVETNIK. New imports preserve the portable business responsible SAVETNIK
snapshot and bind a local adviser only on a unique name+role match; creator and
last modifier remain destination-local actor fields. Source-database numeric
user IDs remain non-portable. Permanent deletion checks adviser,
creator, last modifier and `logIzmena` references. Full-backup identity now has
four explicit states: matching PIB/MB proceeds; mismatch blocks; a fresh local
database may establish a complete backup identity; and missing/incomplete
backup identity is fail-closed when local business state exists. Case 2 is not
treated as a match. The former `FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY
— USER FALLBACK + SAFE MERGE/RECONCILIATION DESIGN AND ACCEPTANCE` successor
is historical context and is closed by the bounded, user-confirmed selective
fallback documented above; it is not a current open successor. Case 3 remains
a legitimate fresh-install recovery path. Minute-based local creation resolves
collisions transactionally with suffixes and preserves legacy duplicates.
Focused acceptance is 44/44 PASS, analyzer PASS and the historical pre-task
full Flutter suite was 445 PASS with 10 expected skips. Windows and Android
release builds also PASS. The later portable-responsibility runtime claim is
superseded by the incident forensic audit and must not be read as current
acceptance. Broader migration/recovery and runtime parity remain separate
successors.

## Portable responsibility correction — source-learned and implemented

The prior schema-28 / PREDMET JSON-8 portable-responsibility experiment and its
synthetic bidirectional runtime claim are withdrawn. The evidence freeze
`OPC_TRANSFER_INTEGRITY_INCIDENT_FREEZE_20260822` established that `PERSON A`
was written by a direct test-fixture insertion without a registered
`Korisnici` row, serialized through the test-only JSON seam with
`exportVerzija=0`, and transported outside the normal KORICE production export
path. The Android and Windows captures showed no registered `PERSON A`; the
native local users were `SYNTHETIC_ADMIN` and `SAŠA ANDONOV`.

The experiment also created a derivative truth split: PREDMET UI/STATISTIKA
preferred the free-text snapshot while LISTA PDF continued to resolve
`savetnikId`. The
schema/fields, serializer extension, repository snapshotting, UI/statistics
preference and synthetic test fixture were removed as incident cleanup. Native
PREDMET `savetnikId`/creator/modifier and `logIzmena` semantics remain. The
historical incident snapshot used database schema 27 and individual PREDMET
JSON compatibility at the published 6/7 boundary. A clean SAME-FIRMA identical-database baseline
is a future acceptance prerequisite; no transfer acceptance was executed by
the forensic recovery task.

Current authority supersedes the historical incident wording above: the
accepted owner oracle requires portable SAVETNIK business truth across equal
OPC devices. The implemented correction uses additive schema 28 fields
`businessResponsibleName`/`businessResponsibleRole`, JSON root schema 8,
unique local name+role binding, replacement preservation and portable-name-first
PREDMET/detail UI, LISTA PDF, PREDMET PDF and relevant STATISTIKA resolution.
There is no separate business derivative named `LISTA`. Numeric local IDs never become portable
authority; legacy schema 6/7 JSON remains readable with unknown responsibility
when the fields are absent, and full-backup schema 9 is unchanged.

The 2026-08-23 V1 harness continuation closed two source defects in that
correction: schema/startup no longer infers portable responsibility from a
legacy local `savetnikId`, and destination binding requires both name and role
with exactly one exact match. The schema migration fixture now removes the
schema-28 columns when simulating older physical schemas. Focused responsibility
and migration tests, analyzer, the full serialized suite, and both release
builds pass.

Subsequent normal-product physical acceptance closed the bounded runtime gate:

`PHYSICAL SAME-FIRMA WINDOWS ↔ ANDROID PEER RESPONSIBILITY TRANSFER ACCEPTANCE — PASS`

Android → Windows passed with no destination local name+role binding: the
portable `SYNTHETIC_ADMIN / SAVETNIK` snapshot remained responsible while
`SAŠA ANDONOV / ADMINISTRATOR` remained the distinct importer and local audit
actor. Windows → Android passed with the unique exact
`SAŠA ANDONOV / ADMINISTRATOR` match bound locally while
`SYNTHETIC_ADMIN / ADMINISTRATOR` remained the distinct importer and local
creator/modifier. The owner's clarification that SAVETNIK cannot import is
accepted role policy and not a defect. PREDMET/detail UI, LISTA PDF, PREDMET PDF
and relevant STATISTIKA remained consistent with PREDMET responsibility truth
in both directions.

This closes only same-FIRMA peer responsibility-transfer acceptance. It does
not establish general database ownership, global user identity, full-backup
acceptance, all Windows/Android runtime parity or overall release readiness.
The controlling boundary classifications remain:

- `DATABASE OWNERSHIP — NOT EXPLICITLY MODELED`
- `FIRMA BUSINESS-NAMESPACE HYPOTHESIS — PARTIALLY SUPPORTED`
