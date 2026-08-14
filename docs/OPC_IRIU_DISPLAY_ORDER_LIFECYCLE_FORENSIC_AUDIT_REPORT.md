# OPC IRiU display-order lifecycle forensic audit

Date: 2026-08-14

Audit branch: `task/OPC-IRIU-DISPLAY-ORDER-LIFECYCLE-FORENSIC-AUDIT`

Baseline branch: `task/OPC-OVERNIGHT-POST-RECOVERY-STABILIZATION`

Baseline SHA: `30cf577cf00594f01c413cc2de89f52dbde4274b`

This is an audit only. No production source, schema, migration, historical
PREDMET row or canonical KATALOG row was changed.

## A. Baseline/source reviewed

Local HEAD and `origin/task/OPC-OVERNIGHT-POST-RECOVERY-STABILIZATION` were both
verified at `30cf577cf00594f01c413cc2de89f52dbde4274b`; the worktree was clean.
The complete overnight report and evidence were read first. The relevant
authoritative sources included:

- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`;
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`;
- `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`;
- `docs/OPC_SCENARIO_IRIU_CHANGE_DIFF_LIFECYCLE_REPORT.md`;
- `docs/OPC_RUNTIME_RECONCILIATION_SCENARIO_PERSISTED_MAP_OSNOVNI_PRICE_REPORT.md`;
- `docs/OPC_CROSS_DEVICE_PREDMET_SCENARIO_FORENSIC_CLOSURE_REPORT.md`;
- `docs/OPC_CANONICAL_KATALOG_IRIU_PIPELINE_WINDOWS_CLOSURE_REPORT.md`;
- the IRiU repository, ordering, truth, UI, SCENARIO, transfer, migration and
  PDF callers named below.

The locked owner decision is applied: display order is derived presentation
metadata, not a historically immune PREDMET business snapshot. Historical
article identity/name/price, quantity and amount remain immune.

## B. Owner runtime evidence

Reviewed current `RUNTIME/IRIU1.PNG`, `RUNTIME/IRIU2.PNG`, the three supplied
KATALOG screenshots, the earlier five LISTA screenshots and
`JOVIC_ZIVKO_120826_1949_LISTA_v1.pdf`. The current images show one complete
18-row IRiU list and no duplicated citation KATALOG rows. `Marama` is the
owner's intentionally added future CRNINA article and was not selected or
modified.

## C. Real Computer Use lifecycle

Computer Use targeted exactly one installed window:
`C:\Program Files\OPC\OPC.exe`, title
`OPC ORGANIZATOR POGREBNE CEREMONIJE`.

Observed without save/edit:

1. opened the first exact card `JOVIĆ ŽIVKO`, `120826_1949`;
2. opened `7 Roba i usluge`;
3. accessibility exposed 18 row editor groups and the list was scrolled through
   to its final rows;
4. the supplied same-build screenshots supplied the text values that Flutter's
   accessibility tree omits;
5. no `SAČUVAJ` or `ZATVORI PREDMET` action was invoked.

The installed app's exit guard explicitly reported that the PREDMET remained
open. The process was then stopped to release the DB before isolated testing.
The owner single-PREDMET JSON was later compared field-for-field with the
canonical 18 rows and was identical, proving no historical IRiU business value
changed during this observation.

## D. Failing PREDMET identity

| Field | Value |
|---|---|
| DB `predmeti.id` | `113` |
| Broj predmeta | `120826_1949` |
| Name | `JOVIĆ ŽIVKO` |
| Status | `OTVOREN` |
| Created | `2026-08-12T19:49:00.835878` |
| Scenario | `MAP_PRIRODNA_DOM_ZA_STARE_KREMACIJA_NE_PRIMENJUJE_SE_NE_PRIMENJUJE_SE_DA_NE_NE` |
| IRiU rows | `18` |

## E. Complete runtime IRiU sequence

The installed UI consumes stored `redosled` and displayed this exact sequence:

1. Agencijske usluge
2. ČITULJA POLITIKA I/90 mm — Cela zemlja
3. Cveće SUZA SU 1/1
4. SVETOSAVSKI KRST Topola/Hrast
5. Peškir za krst
6. Pokrov garnitura BORDO
7. Posmrtne parte
8. Sanduk V-4
9. Slika
10. Transportna vreća
11. Iznošenje
12. Prevoz do hladnjače
13. Hladnjača
14. Spremanje pokojnika
15. Prevoz do groblja
16. Komplet 80
17. Crnina
18. Ešarpa

## F. DB row/order dump

`mode=ro` SQLite inspection returned integrity `ok`, zero foreign-key
violations and contiguous unique stored ranks 0-17. Contiguous does not mean
authoritative: the last two rows carry OSNOVNI metadata.

| stored | id | internal/display | origin | section/order | managed |
|---:|---:|---|---|---:|---|
| 0 | 1724 | AGENCIJSKE_USLUGE / Agencijske usluge | OSNOVNI_PAKET | 1/0 | yes |
| 1 | 1721 | CITULJA_POLITIKA / ČITULJA POLITIKA I/90 mm — Cela zemlja | OSNOVNI_PAKET | 1/2 | yes |
| 2 | 1720 | CVECE / Cveće SUZA SU 1/1 | OSNOVNI_PAKET | 1/4 | yes |
| 3 | 1715 | OBELEZJE / SVETOSAVSKI KRST Topola/Hrast | OSNOVNI_PAKET | 1/5 | yes |
| 4 | 1717 | PESKIR_ZA_KRST / Peškir za krst | OSNOVNI_PAKET | 1/6 | yes |
| 5 | 1716 | POKROV_GARNITURA / Pokrov garnitura BORDO | OSNOVNI_PAKET | 1/7 | yes |
| 6 | 1718 | POSMRTNE_PARTE / Posmrtne parte | OSNOVNI_PAKET | 1/8 | yes |
| 7 | 1714 | SANDUK / Sanduk V-4 | OSNOVNI_PAKET | 1/9 | yes |
| 8 | 1723 | SLIKA / Slika | OSNOVNI_PAKET | 1/10 | yes |
| 9 | 1731 | TRANSPORTNA_VRECA / Transportna vreća | SCENARIO_PAKET | 2/10 | yes |
| 10 | 1727 | IZNOSENJE / Iznošenje | SCENARIO_PAKET | 2/20 | yes |
| 11 | 1729 | PREVOZ_DO_HLADNJACE / Prevoz do hladnjače | SCENARIO_PAKET | 2/30 | yes |
| 12 | 1726 | HLADNJACA / Hladnjača | SCENARIO_PAKET | 2/40 | yes |
| 13 | 1730 | SPREMANJE_POKOJNIKA / Spremanje pokojnika | SCENARIO_PAKET | 2/50 | yes |
| 14 | 1728 | PREVOZ_DO_GROBLJA / Prevoz do groblja | SCENARIO_PAKET | 2/60 | yes |
| 15 | 1725 | KOMPLET_ZA_OPELO / Komplet 80 | absent | 6/0 | no |
| 16 | 1732 | CRNINA / Crnina | OSNOVNI_PAKET | 1/3 | yes |
| 17 | 1733 | CRNINA / Ešarpa | OSNOVNI_PAKET | 1/3 | yes |

Physical/row-ID order is different again:
`Sanduk, Obeležje, Pokrov, Peškir, Parte, Cveće, Politika, Slika,
Agencijske, Komplet, Hladnjača, Iznošenje, Prevoz do groblja,
Prevoz do hladnjače, Spremanje, Transportna, Crnina, Ešarpa`.
No production consumer should treat that insertion order as display authority.

## G. Exact expected authoritative sequence

The applied snapshot, provenance, `poslovnaCelina/poslovniRedosled`, existing
`IriuOrderingService` partition and the prior owner-approved closure all agree
on `OSNOVNI → SCENARIO → manual/other` with stable stored order as a tie-breaker:

1. Agencijske usluge — OSNOVNI 1/0.
2. ČITULJA POLITIKA I/90 mm — Cela zemlja — OSNOVNI 1/2.
3. Crnina — OSNOVNI 1/3, first of the two equal-rank concrete snapshots.
4. Ešarpa — OSNOVNI 1/3, stable tie after Crnina.
5. Cveće SUZA SU 1/1 — OSNOVNI 1/4.
6. SVETOSAVSKI KRST Topola/Hrast — OSNOVNI 1/5.
7. Peškir za krst — OSNOVNI 1/6.
8. Pokrov garnitura BORDO — OSNOVNI 1/7.
9. Posmrtne parte — OSNOVNI 1/8.
10. Sanduk V-4 — OSNOVNI 1/9.
11. Slika — OSNOVNI 1/10.
12. Transportna vreća — SCENARIO 2/10.
13. Iznošenje — SCENARIO 2/20.
14. Prevoz do hladnjače — SCENARIO 2/30.
15. Hladnjača — SCENARIO 2/40.
16. Spremanje pokojnika — SCENARIO 2/50.
17. Prevoz do groblja — SCENARIO 2/60.
18. Komplet 80 — the applied snapshot declares `KOMPLET_ZA_OPELO` as the
    scenario consequence at order 70. Its row lacks provenance/business
    metadata, but both correct adoption and the current manual-after-scenario
    fallback place it last.

This sequence changes no name, identity, price, quantity, amount or row
existence.

## H. Persisted vs derived order

- `redosled`: persisted display rank; unique but stale/wrong.
- `poslovnaCelina/poslovniRedosled`: derived scenario business metadata;
  correct for 17 rows, absent/stale for Komplet 80.
- provenance: correct OSNOVNI/SCENARIO identity for the same 17 rows, absent
  for Komplet 80.
- snapshot: authoritative package composition includes all OSNOVNI categories
  and `KOMPLET_ZA_OPELO` as consequence order 70.
- row ID: physical identity only.

Verdict: metadata is `MIXED`, not absent.

## I. Formation/materialization lifecycle

`PredmetiRepository.inicijalizujIriu` materializes OSNOVNI categories in
module-list order with incremental `redosled`. `IriuRepository.syncScenarioRows`
then evaluates PREDMET facts, writes business section/order, provenance and the
assignment snapshot, and adds SCENARIO consequences at the tail before calling
`_rebuildBusinessOrdering` only for additions/removals.

The historical PREDMET was created before commit `e9d26841` introduced the
provenance-aware partition. Its later CRNINA rows were appended. Installing new
code did not repair them because reopen is not an order-recalculation boundary.

## J. Reopen/load lifecycle

`watchIriu` and `getIriu` execute only `ORDER BY iriu.redosled`. The UI maps that
list directly. Reopen can call `syncScenarioRows`, but provenance adoption or
business-metadata correction alone is not included in the
`removals.isNotEmpty || additions.isNotEmpty` rebuild gate. Therefore a stale
rank survives reopen.

The isolated current-source characterization proved exactly that a newly added
base-category row is adopted as `OSNOVNI_PAKET` on reopen while its persisted
position remains after SCENARIO. The same rows, passed to
`IriuOrderingService`, derive the opposite and correct position.

## K. KATALOG/manual/reselection lifecycle

`_applyLiveCatalogSelection` inserts a new concrete selection with default
manual/unclassified business fields and no provenance, then immediately
rebuilds. In a managed PREDMET the new row is therefore classified as manual
and appended after SCENARIO even when its category belongs to OSNOVNI. That is
the first incorrect transition for current writes.

On later SCENARIO sync the base-category adoption writes provenance and managed
fields but omits an order rebuild. Reselection updates the snapshot fields and
does not rebuild. A truly manual row correctly remains in the final partition.

The isolated lifecycle covered CRNINA add, another OSNOVNI category (`CVECE`),
manual add, CRNINA reselection, close/reopen and OSNOVNI+SCENARIO coexistence.
Both new base-category rows remained wrongly behind SCENARIO; the manual row
correctly remained last.

## L. SCENARIO/OSNOVNI order semantics

The applied snapshot defines OSNOVNI membership and SCENARIO consequence
orders. `IriuOrderingService` has the intended partitions and sorts managed
members by section, business order and stored rank. It is a write-time helper,
not a shared read-time authority. `KOMPLET_ZA_OPELO` also exposes an adoption
gap: it is a scenario consequence in the snapshot but is stored as unprovenanced
manual data.

## M. Import/restore/migration semantics

- Single-PREDMET export serializes raw IRiU rows and `redosled`; the carrier
  maps provenance by transfer index. Import inserts raw snapshots and restores
  provenance but does not derive display order.
- FULL backup/restore emits and reinserts raw IRiU, snapshot and provenance
  rows; it preserves stale rank.
- schema migration only ensures the business-order columns/tables. It has no
  order backfill and no historical rank migration.
- import/restore are consumers/preservers, not the first writer of this defect.

No canonical DB rewrite is required for the repair. Import/restore tests must
prove that the shared derived presentation order works even when raw historical
`redosled` is stale.

## N. UI ordering path

`IriuSegment` → `IriuRepository.watchIriu(predmetId)` → SQL
`ORDER BY redosled` → direct row tiles. No UI-local `.sort` corrects it. A
UI-only hardcoded sort would leave every derivative path inconsistent and is
not acceptable.

## O. PDF/LISTA/document ordering path

LISTA, PREDRAČUN, RAČUN and SPECIFIKACIJA load by stored `redosled` but pass the
rows into `ListaPdfDataBuilder` → `PredmetIriuTruthService`. That service
independently sorts:

- managed row: `poslovnaCelina * 10000 + poslovniRedosled`;
- un-managed row: raw `redosled` (or the protected-anchor exception).

These incomparable numeric domains put un-managed Komplet 80 (`15`) before all
managed rows (`>=10000`). The owner LISTA visually proves the resulting 17-row
document order:

`Komplet 80, Agencijske, Crnina, Ešarpa, Cveće, Obeležje, Peškir, Pokrov,
Parte, Sanduk, Slika, Transportna, Iznošenje, Prevoz do hladnjače, Hladnjača,
Spremanje, Prevoz do groblja`.

Politika is independently excluded by the existing document-scoped policy; it
is not an ordering omission. `PREDMET PDF` renders raw `iriuStavke` and therefore
inherits the UI/stored defect. NALOG uses the same truth service and category
projection, so it is also exposed to the competing truth order.

Therefore PDF/LISTA is an independent ordering defect, not merely propagation
of the UI sequence. UI-only and PDF-only fixes are each insufficient.

## P. Historical snapshot boundary

The owner JSON exported on 2026-08-12 and the current canonical 18 rows are
identical across internal/display name, stable article identity, unit price,
quantity, amount, business flags and stored rank. Reordering can be derived at
read time from existing snapshot/provenance metadata. No KATALOG refresh,
startup rewrite or historical name/price update is required.

## Q. Ordering-mechanism caller map

| Path | Classification | Mechanism/result |
|---|---|---|
| initial OSNOVNI formation | competing writer | incremental `redosled` |
| SCENARIO materialization | competing writer | append then conditional rebuild |
| KATALOG add | first bad current writer | inserted unclassified, rebuilt as manual |
| reselection | hidden gap | snapshot update, no order rebuild |
| manual add/edit | authoritative for manual tie | stored rank; manual final partition |
| reopen/load | consumer | raw SQL `ORDER BY redosled` |
| `_rebuildBusinessOrdering` | intended authority, write-time only | provenance partition service |
| Single-PREDMET import | legacy/preserving writer | raw rank + carrier index |
| FULL restore | legacy/preserving writer | raw row snapshot |
| migrations | hidden absence | columns only, no rank derivation |
| UI | consumer | stored order |
| LISTA/PREDRAČUN/RAČUN/SPECIFIKACIJA | redundant competing re-sort | mixed-domain `truthOrder` |
| PREDMET PDF | consumer | raw stored order |
| NALOG | competing re-sort/projection | truth service/category projection |

Verdict: `IRiU ORDERING MECHANISM — MULTIPLE`.

## R. Root cause

The exact root cause is twofold:

1. **Persisted/UI lifecycle defect.** A live concrete KATALOG add is initially
   written without applied-snapshot membership/provenance. The write-time
   ordering service classifies it as manual and persists it after SCENARIO.
   Later SCENARIO adoption changes it to OSNOVNI but the rebuild gate ignores
   adoption-only changes. Load/UI trust the stale persisted rank. Historical
   CRNINA/Ešarpa therefore remain at 16/17 instead of 2/3.
2. **Derivative defect.** `PredmetIriuTruthService` independently mixes raw
   manual ranks with section-scaled managed ranks. Komplet 80 is therefore put
   first in LISTA, while UI puts it sixteenth.

The first incorrect transition for the failing persisted chain is the writer
that assigns/appends `redosled` before the row's true OSNOVNI provenance is
known. The first missed repair transition is provenance adoption without a
rebuild. The PDF's first incorrect transition is its mixed-domain independent
sort.

## S. Blast radius

Affected:

- historical and current mixed OSNOVNI/SCENARIO/concrete selection PREDMETs;
- reopen after provenance adoption;
- UI IRiU editor;
- LISTA, PREDRAČUN, RAČUN, SPECIFIKACIJA, PREDMET snapshot and NALOG order;
- imported/restored stale-rank PREDMETs.

Not affected by the proposed order-only repair: row identity/existence, names,
prices, quantities, totals, scenario facts, stock effects and KATALOG contents.

## T. Correct repair layer

Create one shared derived ordering authority based on applied snapshot,
provenance, business section/order and stable manual tie order. Feed its output
to UI and every PDF/document builder. Narrow `redosled` to a stable tie/manual
sequence rather than treating it as universal display truth.

The repair must also:

- classify live KATALOG additions from applied OSNOVNI/snapshot membership
  before rebuilding;
- treat provenance adoption and classification changes as order-invalidating;
- adopt existing SCENARIO consequence rows such as Komplet 80 correctly;
- remove/narrow the mixed numeric `truthOrder` comparator;
- keep import/restore raw data untouched and derive correct presentation after
  load.

**No schema migration and no historical/canonical DB rewrite are needed.** A
read-time derived rank is sufficient. Any optional persisted-rank normalization
would be a separate, owner-authorized forensic-copy migration, not a requirement
for this repair.

## U. Required implementation tests

1. exact 18-row historical fixture and expected sequence;
2. duplicate concrete OSNOVNI category tie stability;
3. CRNINA and another category add before/after SCENARIO;
4. same-category and category-changing reselection;
5. manual row remains after OSNOVNI+SCENARIO;
6. provenance adoption triggers derived-order change without snapshot changes;
7. Komplet consequence adoption/order 70;
8. save, reopen and process restart;
9. old and new Single-PREDMET carriers;
10. FULL restore with stale `redosled`;
11. migration from missing business metadata without data rewrite;
12. identical shared sequence in UI, LISTA, PREDRAČUN, RAČUN, SPECIFIKACIJA,
    PREDMET PDF and NALOG;
13. historical name/price/quantity/amount byte-for-byte immunity;
14. canonical hash and logical-row safety on a forensic copy.

Audit test evidence:

- existing isolated regression set: 39/39 success, 0 failure, JSON
  `done.success=true`, natural completion, shell 0;
- dedicated temporary characterization: 2/2 success, 0 failure, JSON
  `done.success=true`; it proved the defect and was removed before commit;
- all workloads ran with `--concurrency=1`; post-process count 0.

## V. Required post-fix Computer Use acceptance

On a protected forensic copy/build first, then owner-approved production:

1. open `JOVIĆ ŽIVKO / 120826_1949` and verify the exact sequence in G;
2. scroll first-to-last, save/reopen, restart and verify no drift;
3. generate LISTA and every other IRiU derivative and verify the same shared
   relative sequence (subject only to explicit document exclusions);
4. add the owner-reserved `Marama` only when the owner authorizes that test;
5. exercise another category, manual add and reselection;
6. compare all historical snapshot fields and totals before/after;
7. stop on any KATALOG refresh, row creation/deletion or price/name change.

## W. Luna implementation handoff

Implementation-ready files/functions:

- `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart` — make
  the partition/rank the shared pure authority with snapshot/provenance context;
- `lib/features/predmeti/data/iriu_repository.dart` — ordered read stream,
  classify live add before rebuild, rebuild/derive on adoption and reselection;
- `lib/features/predmeti/data/predmeti_repository.dart` — preserve OSNOVNI
  materialization semantics, do not refresh concrete snapshots;
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart` —
  remove mixed-domain independent display sorting;
- `lib/features/predmeti/presentation/segments/iriu_segment.dart` — consume the
  shared ordered stream only;
- `lib/features/predmeti/pdf/lista_pdf_data_builder.dart` and all six PDF
  exporters named in O — consume the same ordered projection;
- `lib/core/utils/json_export_import.dart` — preserve raw transfer but add
  derived-order acceptance after import/restore;
- tests named in U.

Stop conditions: any historical name/price/identity change, any canonical
rewrite, separate UI/PDF hardcoded sorts, startup repair, or inability to prove
one sequence across all consumers.

## X. Git completion

Only this report and its JSON evidence are intended for commit. No temporary
test, DB, PDF rendering, build output or production source belongs in the
commit. Final commit/push/remote SHA and clean-worktree evidence are recorded
after publication.

## Y. Final verdict

- `REAL WINDOWS IRiU ORDER FAILURE — CONFIRMED`
- `FAILING PREDMET — IDENTIFIED`
- `EXPECTED ORDER — PROVEN`
- `CURRENT RUNTIME ORDER — CAPTURED`
- `DB ORDER METADATA — MIXED`
- `FIRST INCORRECT LIFECYCLE TRANSITION — IDENTIFIED`
- `IRiU ORDERING MECHANISM — MULTIPLE`
- `HISTORICAL NAME/PRICE SNAPSHOT IMMUNITY — PRESERVABLE`
- `DISPLAY ORDER HISTORICAL PROTECTION — NOT APPLICABLE`
- `CURRENT NEW-WRITE ORDER — FAIL`
- `REOPEN ORDER — FAIL`
- `PDF/LISTA ORDER PROPAGATION — INDEPENDENT DEFECT`
- `UI-ONLY FIX SUFFICIENT — NO`
- `HIDDEN STARTUP REPAIR REQUIRED — NO`
- `CANONICAL DB MUTATED — NO` (logical business data; byte hash is not compared
  to the stale pre-owner-Marama baseline)
- `LUNA IMPLEMENTATION HANDOFF — READY`
- `WORKING TREE — CLEAN` after commit/push verification
- `REMOTE SHA — CONFIRMED` after push verification

Overall: `AUDIT PASS — IRiU ORDER ROOT CAUSE PROVEN — LUNA REPAIR READY`.
