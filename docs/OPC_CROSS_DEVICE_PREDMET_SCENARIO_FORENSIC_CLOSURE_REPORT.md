# OPC Cross-device PREDMET / SCENARIO / IRiU forensic closure

**Scope:** Windows → Single-PREDMET JSON → Android, `JOVIĆ ŽIVKO / 120826_1949`.

**Audit mode:** evidence-first, documentation-only. No application source, schema,
JSON, canonical database, Android live data, or duplicate data was changed.

**Audit branch:** `task/OPC-CROSS-DEVICE-PREDMET-SCENARIO-FORENSIC-CLOSURE`

**Control baseline:** `task/OPC-AUTHORITATIVE-PLAN-REALITY-RECONCILIATION`,
`36368c9b7b20adde17b2ec9d61aa82083e188976` (clean and equal to origin before this
report branch was created).

## A. Baseline and evidence inventory

The supplied evidence root was inventoried at
`C:\Projekti\OPC\OPC v.1\RUNTIME`. The incident-specific files are:

- `Android_PREDMET.jpg`;
- `Android_IRIU_1.jpg` through `Android_IRIU_7.jpg`;
- `Android_SCENARIO_1.jpg` and `Android_SCENARIO_2.jpg`;
- `Crnina_IRIU.jpg`, `Crnina_Katalog.jpg`, `Katalog.PNG`;
- `IRIU1.PNG`, `IRIU2.PNG`, `IRIU3.PNG`;
- `SCENARIO1.PNG`, `SCENARIO2.PNG`;
- `LISTA_PDF_1.PNG` through `LISTA_PDF_5.PNG`;
- `JOVIC_ZIVKO_120826_1949_v1.json`;
- `JOVIC_ZIVKO_120826_1949_LISTA_v1.pdf`.

The read-only database evidence copies are under
`RUNTIME\forensic_db`, including the staged handoff set
`handoff_db_forensics_20260811\{canonical_before,stageA_at_rest,stageB_before_open,stageC_seed_idempotent}.sqlite`,
`release_runtime_resolution_before.sqlite`, and `opc_v4_release_copy.sqlite`.
No copy contains PREDMET `120826_1949`; Android private storage was not acquired.
Consequently, Android database statements below are source/runtime-inferred, not
Android-DB-proven.

The PDF was rendered read-only with Poppler and visually checked against the
provided PNG captures. No application build or test was run merely to create
activity.

## B. Runtime event timeline

| Event | Evidence / production caller | Persisted or derived effect | Status |
|---|---|---|---|
| PREDMET creation | JSON `predmet.datumKreiranja` is `2026-08-12T19:49:00...`; `brojPredmeta=120826_1949`, status `OTVOREN`, `businessScenarioId=default_funeral_ceremony_policy` | PREDMET facts are the business source | Source-proven, exact UI click time unavailable |
| SCENARIO derivation and Windows IRiU formation | Windows `SCENARIO1.PNG`, `SCENARIO2.PNG`, `IRIU*.PNG`, `Crnina_IRIU.jpg` | 18 IRiU rows in the supplied JSON, including two concrete CRNINA selections and six condition rows | Runtime + JSON proven |
| Windows local edits | `Crnina_Katalog.jpg` shows the CRNINA catalog; `Crnina_IRIU.jpg` shows category-like IRiU labels | JSON preserves concrete `nazivPrikaz`, stable article ID, quantity, price, amount | Proven |
| JSON export | `JOVIC_ZIVKO_120826_1949_v1.json`, file write 20:21:11; serializer path `json_export_import.dart:_serijalizujPredmet` | PREDMET, IRiU, contacts only (plus optional stock-consequence block) | Proven |
| LISTA PDF generation | `JOVIC_ZIVKO_120826_1949_LISTA_v1.pdf`, PDF creation metadata 21:17:37 | Two-page derivative; visible IRiU list excludes citation row while total includes it | Proven |
| Android import | `Android_PREDMET.jpg`, `Android_SCENARIO_1.jpg` | PREDMET remains selectable and OPEN | Runtime proven; Android DB unavailable |
| First Android IRiU open | `Android_IRIU_1.jpg` shows `Ponuda je usklađena: +1 / −0 STAVKI.` | `IriuSegment.initState` starts `_runScenarioSync`; missing default-package category is materialized | Caller and reason proven; exact Android row ID unavailable |
| Android SCENARIO open | `Android_SCENARIO_2.jpg` shows current axes and `PRIMENJENI SCENARIO SNAPSHOT` | Snapshot is read from `predmetScenarioSnapshots` after reconciliation, not from the supplied JSON | Origin proven by source path and event order; not DB-proven |
| Android KATALOG inspection | `Crnina_Katalog.jpg`/`Katalog.PNG` equivalents show CRNINA and KOMPLET categories with zero articles and reduced citation counts | Global KATALOG is intentionally not transferred by Single-PREDMET JSON | Proven |
| Later Windows delete/add ordering incident | Owner runtime observation: delete CITULJA_NOVOSTI, add concrete CRNINA article, then ordering regresses | `IriuRepository` rebuild plus `IriuOrderingService` mixed managed/manual branch is the responsible layer | Source-proven mechanism; target DB state unavailable |

The file-system times are artifact times, not a transaction log. The screen clocks
and source caller order prove the `+1` event occurred during the first IRiU
presentation, before the captured SCENARIO snapshot view; they do not prove every
human action time to the second.

## C. Single-PREDMET JSON carrier reality

`JOVIC_ZIVKO_120826_1949_v1.json` is:

- `format: OPC_PREDMET`;
- `schemaVersion: 6`;
- `entityType: PREDMET`;
- `sourceExpectations.jsonTransfer.includes: [predmet, iriu, kontaktLica]`;
- root keys only `predmet`, `iriu`, and `kontaktLica` (plus transfer metadata).

It contains 18 IRiU rows. It has no `scenarioModules`,
`scenarioDefinitions`, `predmetScenarioSnapshots`, `iriuProvenance`, assignment
snapshot, scenario version, rule ID, or provenance coverage block. The JSON has
no scenario/provenance/snapshot-named root key.

The production serializer in `lib/core/utils/json_export_import.dart` (the
`_serijalizujPredmet` map) emits schema 6 or the stock-consequence variant and
never emits SCENARIO lifecycle state. The backup serializer also does not include
the SCENARIO tables. The production parser
`_procitajPredmetTransferPayload` reads only PREDMET, IRiU, contacts, and the
optional STANJE ROBE consequence block. Import calls
`PredmetiRepository.uveziPredmetSaPovezanimPodacima` or
`zameniPredmetSaPovezanimPodacima`; neither writes a scenario snapshot or
provenance row.

There is a pure, tested `SinglePredmetScenarioCarrierBlock` contract under
`lib/features/predmeti/core_v2/scenario/`, but it is not wired into this
production JSON serializer/parser. Therefore a passing carrier-contract test is
not evidence that the live JSON transfer carries SCENARIO state.

## D. Android post-import mutation path

The `+1 / −0` is a real mutation, not a display-only count.

1. The default editable package in
   `ScenarioModuleRepository._defaultOsnovniPaket` contains both
   `CITULJA_POLITIKA` and `CITULJA_NOVOSTI`.
2. The supplied source JSON contains `CITULJA_POLITIKA` but **does not** contain
   `CITULJA_NOVOSTI`.
3. `IriuSegment.initState` immediately calls `_runScenarioSync`.
4. `IriuRepository.syncScenarioRows` computes
   `desired.difference(existingNames)`. With no transferred snapshot/provenance,
   `CITULJA_NOVOSTI` is desired and absent, so it is an addition.
5. `_insertStavka` is called with `redosled = sledeciredosled(predmetId)` and no
   explicit price/amount. The default amount and price are zero; the UI therefore
   displays an empty amount.
6. The method backfills `iriuProvenance` for base rows, calls
   `_rebuildBusinessOrdering` when additions are present, and writes a new
   `predmetScenarioSnapshots` row when the owner result is complete and no prior
   snapshot exists.
7. The widget then shows the observed snackbar.

The first no-snapshot reconciliation is therefore not a harmless preview: the
`applyScenarioChange: false` call still materializes additions and writes the
local snapshot. This is the exact ownership boundary of the Android mutation.

## E. Applied SCENARIO snapshot/provenance origin

The Android snapshot shown in `Android_SCENARIO_2.jpg` was reconstructed locally
from the imported PREDMET facts and the receiver's local SCENARIO module/defaults:

- `ScenarioRuntimeReconciliationService.reconcileOpenPredmet` loads local module
  definitions and calls `syncScenarioRows` for the selected PREDMET;
- the IRiU screen has an equivalent first-open caller;
- `_ownerScenarioSnapshot` derives the snapshot from the owner policy kernel;
- `_writeScenarioSnapshot` persists it only in
  `predmetScenarioSnapshots`.

The supplied carrier could not have imported the displayed snapshot because it
contains no snapshot or provenance block. The equivalent axes in the two
platform screenshots are therefore a consequence of shared PREDMET facts and
compatible local policy, not proof of cross-device snapshot continuity. A future
receiver with different definitions could display a different derived result or
request a different mutation.

## F. IRiU ordering regression

The import path itself preserves the serialized IRiU fields. The repository
inserts each imported row with a new local primary key but retains
`redosled`, `poslovnaCelina`, `poslovniRedosled`, `scenarioUpravlja`,
`katalogStableArticleId`, `nazivPrikaz`, quantity, price, and amount. Import does
not call `_rebuildBusinessOrdering`.

The later Windows regression is a separate lifecycle/order defect:

- `IriuRepository.syncScenarioRows` backfills provenance and changes base rows to
  `scenarioUpravlja: true`; additions/removals invoke `_rebuildBusinessOrdering`.
- Manual catalog add (`dodajStavku`), delete, and several auto-sync paths also
  invoke `_rebuildBusinessOrdering`.
- `IriuOrderingService.orderedRows` has a global branch: if **any** row is
  `scenarioUpravlja`, all managed rows are first sorted by
  `poslovnaCelina`/`poslovniRedosled`, and all non-managed rows are appended after
  them. It does not implement the owner's intended stable partition of
  OSNOVNI PAKET → SCENARIO additional package → other/manual rows.
- `watchIriu`/`getIriu` read rows by stored `redosled` only; the presentation maps
  that raw stream directly to tiles. Thus a rebuild changes persisted display
  order, while a mixed managed/manual state can make the order appear to jump
  when a catalog article is added or a citation row is deleted.

The observed “scenario rows at the top / base rows in the scenario location” is
therefore source-proven as a combination of reconciliation rewrite and the
mixed-ownership ordering comparator. It is not caused by the concrete CRNINA
article name itself and it was not visibly reproduced by JSON import alone.
The exact post-incident persisted row values cannot be DB-proven because the
target PREDMET is absent from the supplied database copies.

## G. KATALOG article-name/category projection

The JSON correctly preserves two layers of identity for CRNINA:

- category: `interniNaziv = CRNINA`;
- selected article snapshot: `nazivPrikaz` (`Crnina` or `Ešarpa` in the two rows),
  `katalogStableArticleId`, quantity, price, and amount.

The current IRiU editor intentionally resolves display text in this order in
`iriu_display_name_resolver.dart`:

1. current `iriuKatalogConfig.nazivPrikaz` (category name);
2. built-in category name;
3. stored non-technical `nazivPrikaz`.

`IriuRowTile` passes both the category map and stored name, so a CRNINA row is
shown as category-like “Crnina” even when the stored selected article is
“Ešarpa”. This matches `Crnina_IRIU.jpg` and is a UI projection choice.

The LISTA builder uses `row.storedRow.nazivPrikaz.trim()` and therefore shows
the concrete names “Crnina” and “Ešarpa” from the PREDMET snapshot. It is not
reading a different business truth.

The owner interpretation that a selected concrete article should remain
historically identifiable, with category as metadata, is technically supported
by the stored fields and PDF projection. The final UI policy (whether the editor
must always show the concrete selected name) remains an owner confirmation item.

## H. Cross-device KATALOG referential continuity

Single-PREDMET JSON deliberately does not carry global KATALOG rows. The Android
screens show the expected configuration divergence: CRNINA and KOMPLET categories
have zero local articles, while citation counts differ materially from Windows.

For an imported row, the selected article snapshot remains usable because the
IRiU row stores name, quantity, price, amount, and stable article ID. If the
stable ID is not present in the receiver's global KATALOG:

- the row remains editable and its stored name remains available to the PDF;
- the catalog picker queries the receiver category and reports “Nema artikala”
  when the category has no local articles;
- reselecting an article is the action that can intentionally replace the stored
  stable ID/name; ordinary text/amount saves preserve the stable ID unless the
  user explicitly selects another catalog item.

This is the minimal, non-over-engineered model: PREDMET-owned selected-article
snapshots cross with the PREDMET; global KATALOG parity remains a separate
explicit full-backup/restore or future dedicated configuration-sync concern. A
Single-PREDMET transfer must not silently merge global KATALOG data.

## I. CITULJA POLITIKA / CITULJA NOVOSTI duplication root cause

Read-only SQL over the supplied copies found a stable business tuple cardinality
of 34 unique `CITULJA_POLITIKA` tuples and 17 unique `CITULJA_NOVOSTI` tuples.
The release copy contains 2,958 and 1,476 rows respectively; every Politics
tuple occurs 87 times, while News tuples occur 86 or 87 times. The Android
screens show the same multiplication at a different repetition count (about
1,938 and 969), so the platforms do not have the same number of repeated seed
executions, but they share the same data shape.

The stage evidence isolates the creator:

- `stageA_at_rest.sqlite`: 2,924 Politics / 1,459 News;
- `stageB_before_open.sqlite`: 2,958 / 1,476 (the old open/close path adds 51
  citation rows);
- `stageC_seed_idempotent.sqlite`: returns to the stage-A counts under the
  tuple-guarded seed path.

The prior live-proof report records the exact old defect: citation seeding used a
generated stable ID with `insertOrIgnore`; a new generated ID never matched the
existing row on the next startup. The current source now matches immutable
business tuple `(interniNazivKategorije, naziv, cena)` before inserting, which
proves recurrence was fixed for new opens. It does not remove historical rows.

The table has a unique index on `stable_article_id`, but no unique tuple index.
Therefore duplicate rows have distinct stable IDs and are not rejected by the
database. This is one shared `KATALOG DATA DUPLICATION` root cause for both
categories, not two independent article defects.

The release copy also contains 13 IRiU stable-ID references that no longer
resolve to a catalog row (across 12 PREDMETs). That is additional evidence that
catalog repair must preserve PREDMET snapshots and remap references carefully;
it is not evidence that target PREDMET `120826_1949` was in the copy.

## J. Safe duplicate cleanup strategy

Cleanup is **not executed** in this audit. A safe future repair is:

1. Freeze and hash a database copy; inventory every duplicate tuple, every IRiU
   reference, stock-consequence reference, and any serialized snapshot that
   contains a stable article ID.
2. For each exact `(category, name, price)` tuple, choose a canonical survivor
   deterministically: prefer a row referenced by the most existing PREDMET/stock
   records; tie-break by earliest stable catalog identity/row ID. If photos or
   other business metadata differ, stop for owner review rather than silently
   merging.
3. Preserve each PREDMET's stored `nazivPrikaz`, price, amount, and historical
   article snapshot. Remap references to the survivor only when the business
   tuple is identical; retain a reference map for audit/recovery.
4. Repair all dependent tables in one transaction, then remove only unreferenced
   duplicate catalog rows. Never use an unqualified `DELETE duplicates`.
5. Add a recurrence guard at the seed boundary (the current tuple check) and a
   database-level uniqueness constraint/index only after the existing data is
   normalized and verified.
6. Reopen repeatedly on Windows and Android, export/import PREDMET fixtures,
   and prove no new rows, no broken references, and unchanged PDF/article
   snapshots.

Strategy status is **READY**; execution still requires a separate authorized
data-repair task and owner approval of the canonical-survivor rule.

## K. LISTA PDF fidelity

### K.1 Missing CITULJA_POLITIKA row

The supplied JSON has 18 IRiU rows whose amounts sum to **153,630 RSD**. The
`CITULJA_POLITIKA` row is 3,500 RSD. The visible PDF IRiU table intentionally
filters both citation categories through
`IriuDerivativeExclusion.documentScopedOut`; the remaining visible rows sum to
**150,130 RSD**. `FinancialTruthService` deliberately uses the broader financial
row set (`active && finansijskiUkljuceno && iznos > 0` for scenario-managed rows),
so the financial panel reports 153,630 RSD.

This is an explainable source split, not arithmetic corruption, but the PDF does
not label the 3,500 RSD document-scoped aggregation. It therefore violates the
stronger derivative invariant that every total component must be explainable
from displayed rows unless an explicit labeled aggregation rule is present. A
future correction must either show the citation row or add an explicit labeled
“document-scoped citation included” line; the correction is presentation-only
after business truth is stabilized.

The same exclusion rule applies to `CITULJA_NOVOSTI`; other categories are not
excluded by this legacy document-scoped set, though non-positive or suppressed
rows can be excluded by the financial truth rules.

### K.2 Article naming

The PDF uses stored `nazivPrikaz`, so the concrete CRNINA article identity is
preserved. The mismatch with the IRiU editor is the UI resolver policy described
in section G, not a second source of truth.

### K.3 Cremation / urn labels

`lista_pdf_data_builder.dart` maps the correct PREDMET values but labels them
`Urna parcela`, `Urna broj`, and `Urna NPK`. The values are semantically correct;
the repeated “Urna” prefix is a confirmed non-blocking presentation-label defect.

## L. Database evidence comparison

All SQL in this audit used SQLite read-only URI connections against copies. The
target PREDMET was absent from every supplied copy, so no target-row equality
claim is made. The copies nevertheless prove the catalog-seed mechanism and
show the expected scenario tables exist on current release databases.

| Copy | Size / SHA-256 (prefix) | Target PREDMET | Catalog signal |
|---|---:|---:|---|
| `stageA_at_rest.sqlite` | 82,784,256 / `A6022955…` | absent | baseline 2,924 / 1,459 citation rows |
| `stageB_before_open.sqlite` | 82,792,448 / `2E868C34…` | absent | old open adds 51 citation rows, 2,958 / 1,476 |
| `stageC_seed_idempotent.sqlite` | 82,784,256 / `A6022955…` | absent | fixed seed path returns to stage A |
| `release_runtime_resolution_before.sqlite` | 82,771,968 / `0033B47E…` | absent | 2,890 / 1,442 citation rows |
| `opc_v4_release_copy.sqlite` | 104,493,056 / `8D293AE7…` | absent | 2,958 / 1,476; 13 unresolved IRiU stable IDs |

The Windows canonical file and Android app-private database were not opened or
mutated in this audit. Existing runtime reports document that Android `run-as`
acquisition was unavailable; no live-data extraction was attempted here.

## M. Root-cause table

| Finding | Proven symptom | Source path | DB evidence | Root cause | Shared root? | Minimal correction boundary | Owner decision? |
|---|---|---|---|---|---|---|---|
| Android `+1` CITULJA_NOVOSTI | Snackbar and row appears with empty amount | `IriuSegment._runScenarioSync` → `IriuRepository.syncScenarioRows` | Target Android DB unavailable | Receiver reconstructs missing default package from local config because carrier has no snapshot/provenance | SCENARIO continuity | Carry PREDMET-owned applied lifecycle state and gate first-open reconciliation | Yes: compatibility behavior for old JSON |
| Applied snapshot after import without carrier | Android displays applied snapshot | `_ownerScenarioSnapshot` + `_writeScenarioSnapshot` | Not target-DB-proven | Locally reconstructed from PREDMET facts/defaults | Same as above | Same minimal carrier/import/reconciliation boundary | Yes: drift policy on definition change |
| Windows IRiU order regression | Scenario rows move to top after delete/add | `_rebuildBusinessOrdering` + `IriuOrderingService.orderedRows` | Target DB unavailable | Mixed managed/manual comparator and persisted `redosled` rewrite | Separate IRiU root | Fix ordering contract at rebuild/presentation boundary | No business rule change, but acceptance required |
| CRNINA article shown as category in IRiU UI | “Crnina” instead of concrete article | `resolveIriuDisplayName` category-first resolver | JSON proves concrete snapshot exists | UI projection intentionally prioritizes category | Independent UI projection | Preserve concrete selected label where owner requires it | Yes |
| Cross-device unresolved KATALOG refs | Android catalog has 0 articles; picker unavailable | `IriuRowTile` catalog lookup and empty-state snackbar | Other copies show 13 unresolved IDs | Global KATALOG is not part of Single-PREDMET carrier | Independent configuration boundary | Keep immutable row snapshots; explicit catalog-sync remains separate | No, unless owner wants forced re-selection |
| CITULJA_POLITIKA duplication | ~2,958 rows for 34 tuples | old seed generated IDs; current tuple guard | Stage A/B/C proof | Historical startup seeding multiplication | Shared with News | Reference-aware repair + recurrence guard | Yes: survivor policy |
| CITULJA_NOVOSTI duplication | ~1,476 rows for 17 tuples | same seed path | Stage A/B/C proof | Same historical startup multiplication | Shared with Politics | Same repair boundary | Yes: survivor policy |
| LISTA PDF missing CITULJA_POLITIKA | 3,500 included in total but row hidden | `documentScopedOut` filter vs `FinancialTruthService` | JSON arithmetic exact | Intentional derivative filtering lacks labeled aggregation | Independent derivative | Show row or label aggregation | Yes: document presentation policy |
| LISTA PDF urn labels | Values right, labels redundant | `lista_pdf_data_builder.dart:291-294` | JSON PREDMET values match | Presentation wording only | Independent | Relabel after truth closure | No, wording confirmation useful |

## N. Shared vs independent causes

The `+1` mutation and post-import snapshot share one cross-device root: the
Single-PREDMET carrier is structurally incomplete for already-applied SCENARIO
lifecycle state, and the receiver treats the absence as permission to reconcile
against local defaults. Catalog duplication is a separate historical seed/data
root, although it can change the receiver's local default universe. Ordering is a
separate IRiU lifecycle/comparator root. Article naming and urn labels are
presentation roots. PDF omission is a derivative-policy root.

## O. Minimal safe architecture / anti-over-engineering assessment

The evidence supports a small extension, not continuous synchronization:

- Single-PREDMET JSON should carry a minimal PREDMET-owned applied assignment
  snapshot and per-row provenance/selected-article snapshots, using transfer
  indexes rather than local database IDs.
- Import should map those indexes to newly inserted destination IRiU IDs and
  suppress automatic default-package reconstruction when a valid applied state is
  present.
- A legacy JSON without that block should enter an explicit compatibility path
  (warn/record reconstruction) rather than silently mutate and present a normal
  success snackbar.
- Global KATALOG remains a separate full-backup/configuration concern.
- Ordering must be corrected where the comparator/rebuild currently rewrites
  `redosled`; no broad IRiU rewrite or server is justified by this evidence.

## P. Proposed implementation phases (report only)

### Phase A — data-integrity blockers

Repair the citation seed recurrence guard if any release lane still lacks the
tuple check, then perform the reference-aware duplicate repair from section J.
Schema impact is limited to a uniqueness constraint/index after cleanup. Stop if
photo metadata or conflicting references make tuple merging ambiguous.

### Phase B — cross-device PREDMET/SCENARIO continuity

Wire the existing pure carrier contract into
`json_export_import.dart` and both repository import paths. Add a destination
ID/index preflight, snapshot/provenance coverage validation, and a compatibility
mode for schema-6 JSON. No global KATALOG import. Test Windows and Android
production callers, not just the pure contract.

### Phase C — IRiU order integrity

Define the owner-approved partition and change only the proven ordering/rebuild
layer. Preserve imported `redosled` until an explicit order migration is
authorized. Validate delete, catalog add, manual edit, and scenario-fact change.

### Phase D — KATALOG duplication repair

Execute the staged repair with backups, reference maps, and post-repair
idempotency/open/restart proof. Do not combine it with PREDMET transfer logic.

### Phase E — LISTA PDF / UI projection

After truth/order are stable, align the citation-row aggregation presentation,
make concrete selected article names visible where owner-approved, and relabel
urn fields. Each change needs PDF visual QA and Windows/Android parity proof.

## Q. Backward compatibility

Existing schema-6 Single-PREDMET files remain importable. When the new lifecycle
block is absent, the receiver must not pretend that a snapshot was transferred;
it should explicitly record compatibility reconstruction and surface any
resulting `+N/-N` change. A new root schema version is justified only if the
carrier contract cannot be safely optional; the existing parser already accepts
older schema versions up to its configured maximum. Full backup JSON remains
unchanged as the configuration transfer vehicle.

## R. Required automated tests

Future implementation must exercise production caller paths for:

1. Windows create → export → Android import and the reverse direction;
2. same and deliberately different SCENARIO definitions;
3. receiver without the selected catalog article;
4. valid snapshot/provenance transfer and legacy no-block compatibility;
5. OPEN status/selectability and no silent `+N/-N` after import;
6. order after import, citation delete, concrete catalog add, manual edit, and
   scenario-fact change;
7. repeated citation initialization idempotency;
8. duplicate repair with referenced and unreferenced rows;
9. PDF row-to-total reconciliation, concrete names, and urn labels;
10. Windows/Android semantic parity after restart.

## S. Required Windows/Android runtime acceptance

Windows acceptance must use a real PREDMET and prove edit, KATALOG selection,
SCENARIO view, IRiU order, JSON counterpart, LISTA PDF, close/reopen, and restart
persistence. Android physical-device acceptance must prove counterpart import /
export, SCENARIO selector, IRiU screen, missing-KATALOG behavior, no silent
post-import mutation, and restart persistence. Technical PASS is not owner
acceptance; the owner must separately approve the selected-article UI policy,
order partition, citation aggregation presentation, and duplicate survivor rule.

## T. New incidental findings

- `zameniPredmetSaPovezanimPodacima` deletes old IRiU rows but does not explicitly
  delete a snapshot keyed by the preserved local PREDMET ID. A replacement into a
  pre-existing local PREDMET therefore needs an explicit snapshot lifecycle
  decision in the future carrier implementation; it was not exercised for the
  supplied Android evidence.
- Import preserves source local adviser/creator IDs. This is an existing
  cross-database identity concern outside the requested PREDMET/IRiU carrier
  closure and should not be conflated with global KATALOG sync.
- The pure SCENARIO carrier tests create a false sense of integration coverage
  until they are attached to the production serializer/import caller.

## U. Owner decisions required

Before implementation, the owner must confirm:

1. the concrete-article label policy in the editable IRiU UI;
2. whether a legacy JSON without lifecycle state may reconstruct with an explicit
   warning or must be blocked;
3. the stable OSNOVNI → SCENARIO → manual order partition;
4. whether LISTA should show citation rows or label their financial aggregation;
5. canonical citation survivor selection when duplicate rows have references or
   differing media metadata;
6. whether replacement import must discard a pre-existing local snapshot.

## V. Documentation / plan impact

The authoritative-plan phrase `production SCENARIO JSON carrier integration` is
too narrow for the proven production boundary. The exact replacement proposed by
this audit is:

> **cross-device PREDMET/SCENARIO continuity + IRiU reconciliation integrity**

This audit changes documentation only. The authoritative plan itself was not
modified because that decision belongs to the plan reconciliation owner.

## W. Final verdicts

- `RUNTIME EVIDENCE INVENTORIED — PASS`
- `WINDOWS→ANDROID TRANSFER TIMELINE — PARTIAL`
- `SINGLE-PREDMET CARRIER CONTENT — PROVEN`
- `ANDROID +1 MUTATION ROOT CAUSE — PROVEN`
- `APPLIED SCENARIO SNAPSHOT ORIGIN AFTER IMPORT — PROVEN`
- `CROSS-DEVICE PREDMET BUSINESS IDENTITY — MUTATED`
- `IRiU ORDER REGRESSION ROOT CAUSE — PROVEN`
- `KATALOG CONCRETE-ARTICLE PROJECTION — PROVEN`
- `KATALOG CROSS-DEVICE REFERENTIAL CONTRACT — PROVEN`
- `CITULJA POLITIKA DUPLICATION ROOT CAUSE — PROVEN`
- `CITULJA NOVOSTI DUPLICATION ROOT CAUSE — PROVEN`
- `SAFE DUPLICATE CLEANUP STRATEGY — READY`
- `LISTA PDF MISSING-ROW ROOT CAUSE — PROVEN`
- `LISTA PDF LABEL DEFECT — CONFIRMED`
- `MINIMAL NON-OVER-ENGINEERED CORRECTION BOUNDARY — DEFINED`
- `OWNER DECISIONS REQUIRED BEFORE IMPLEMENTATION — YES`
- `APPLICATION SOURCE CHANGED — NO`
- `CANONICAL DB MUTATED — NO`
- `ANDROID LIVE DATA MUTATED — NO`
- `REMOTE SHA — NOT CONFIRMED`
- `WORKING TREE — NOT CLEAN`

**Final status: `FORENSIC PARTIAL — SPECIFIC EVIDENCE STILL REQUIRED`**

The remaining evidence gap is specific: the Android app-private database and the
post-incident Windows target-PREDMET database were not supplied, so target-row
IDs, exact persisted post-import order, and Android snapshot/provenance rows
cannot be claimed as direct SQL facts. The source caller, JSON omission, runtime
screens, arithmetic, and staged catalog database proof are sufficient to scope
implementation safely, but not to claim a full forensic PASS.
