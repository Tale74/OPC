# OPC Canonical KATALOG → IRiU Pipeline Windows Closure Report

Date: 2026-08-13  
Branch: `task/OPC-CANONICAL-KATALOG-IRIU-PIPELINE-WINDOWS-CLOSURE`  
Baseline: `fcbaca2be863efc78e9b54981b9e21685fb5860a`

## A. Baseline / authority review

The required prior branch was clean at the stated SHA and this branch was
created from it. The repaired-DB Windows report, prior Windows runtime report,
cross-device closure report, authoritative plan, current-state, owner index,
source-of-truth map, KATALOG/IRiU pseudocode and relevant Git history were
reviewed. The public statement that concrete labels were a technical PASS is
superseded by the owner-observed installed-runtime failure.

## B. Owner runtime evidence and locked business rule

The owner reports that installed OPC displays a CRNINA row selected as `Flor`
as `Crnina`, and confirms `C:\Program Files\OPC` is the complete release copy.
The locked rule remains: category (`CRNINA`) is metadata; a selected concrete
article (`Flor`, `Ešarpa`, or any other category article) is the user-facing
IRiU/document snapshot.

## C. Complete production-path inventory

| Path | Source | Representation / result |
|---|---|---|
| Catalog seed/config | `lib/core/database/database.dart`, `iriu_katalog_config_table.dart`, `katalog_artikli_table.dart` | Category key/label/type/price plus article stable ID/name/price. |
| New PREDMET | `PredmetiRepository.inicijalizujIriu` | Scenario/basic category rows; no concrete article selected, so category label is correct. |
| Scenario reconciliation | `IriuRepository.syncScenarioRows`, `ScenarioModuleRepository` | Adds category rows through `_catalogDisplayName`; preserves existing concrete row snapshots and does not choose article IDs. |
| Add from picker | `iriu_segment.dart` `_KatalogPickerDialog` / `_dodajIzKataloga` | Passes category key, concrete article name, price and stable ID to `dodajStavku`. |
| Existing row reselection | `iriu_row_tile.dart` `_primeniArtikl`; `IriuRepository.azurirajKatalogIzborStavke` | Atomically writes category, concrete name, stable ID, quantity, price and amount. |
| Ordinary edit/reload | `iriu_row_tile.dart` `_scheduleSave`; `IriuRowTile.initState` | Persists snapshot text/quantity/amount without clearing stable ID; resolver reads stored snapshot. |
| Single-PREDMET JSON | `lib/core/utils/json_export_import.dart` | Raw IRiU fields, including name/stable ID/price/quantity/amount, survive import; global KATALOG is not required. |
| Full backup | same file | Raw IRiU and global KATALOG/config transfer; stable-ID normalization does not rewrite names/prices. |
| Documents | `lista_pdf_data_builder.dart`, `predmet_pdf_snapshot_export.dart`, `nalog_za_opremanje_pdf_data_builder.dart` | Stored `nazivPrikaz` is consumed; no live KATALOG replacement. |
| UI projections | `iriu_row_tile.dart`, `iriu_segment.dart`, scenario screen, statistics | Editable PREDMET uses the shared resolver; scenario package UI intentionally shows category metadata. |

## D. Canonical KATALOG-backed IRiU representation

The existing smallest supported representation is retained:

- category identity: `iriu.interniNaziv`;
- selected article identity: `iriu.katalogStableArticleId`;
- selected display snapshot: `iriu.nazivPrikaz`;
- price snapshot: `iriu.cena`;
- quantity: `iriu.kom`;
- amount: `iriu.iznos`;
- provenance/order: `iriu_provenance` and the existing business-order fields.

Picker selection already writes this complete snapshot. Reload, JSON and
documents already consume it. Live KATALOG is used for picker/reselection and
new-row materialization, not as hidden historical display truth.

## E. Flor vs Ešarpa forensic trace

The active canonical DB contains catalog article `Flor`, category `CRNINA`,
stable ID `katalog_artikal_1786249144163923_8e4c683970431900`, price 100. The
target PREDMET row 1732 has category `CRNINA`, that exact stable ID, quantity 3,
price 100 and amount 300, but stored `nazivPrikaz = Crnina`. Row 1733 has
category `CRNINA`, stable ID ending `c761405930e3f6da`, stored `nazivPrikaz =
Ešarpa`, quantity 1, price 400 and amount 400.

Therefore Flor's row already contained the category label in persisted data;
Ešarpa's row contained the concrete name. The same category appeared
inconsistently because the rows were created through different historical
paths or had different snapshot states.

## F. First divergence/root cause

Git history proves commit `9b7608d` introduced `resolveIriuDisplayName` with
category-first precedence. `IriuRowTile.initState` and `didUpdateWidget` called
that resolver, so a row with stored `Flor` could be displayed as the current
category label `Crnina`. The resolver was later changed to stored-first, which
correctly protects good snapshots, but cannot repair a row whose persisted
snapshot is already malformed (`Flor` stable ID + `Crnina` text). The first
divergence is therefore the historical snapshot write/data state plus the
category-first presentation path; the owner-observed row proves it is not a
stale-build-only explanation.

## G. Why previous tests/change missed production behavior

The prior tests asserted resolver behavior for a synthetic row with stored
`Ešarpa`; they did not exercise the real canonical row whose stored value was
already `Crnina`, nor a production startup audit of stable-ID/name coherence.
The runtime owner evidence exposed that gap.

## H. Divergent path / patchwork inventory

No separate Windows/Android business representation, PDF reconstruction or
JSON name rewrite was found. Scenario-created rows correctly use category
labels until an article is selected. The one semantic divergence was the
historical category-first display resolver. The only new repair is a bounded
database-boundary repair, not a CRNINA special case.

## I. Canonical write/update pipeline implemented

`AppDatabase.repairMalformedIriuCatalogSnapshots()` now runs at database
open/import. It repairs only rows where:

1. `katalogStableArticleId` resolves to a real article;
2. the article belongs to the row's category;
3. stored text is empty, technical, equal to the internal key, or equal to the
   current category label.

It replaces only the derived display snapshot with the proven article name.
Price, quantity, amount, category, stable ID, provenance and ordering remain
unchanged. Unknown IDs, category mismatches and intentional custom names are
untouched. Single-PREDMET imports invoke the same repair after insertion.

## J. Read/display/document pipeline reconciliation

The stored-first resolver remains the single editable-row projection rule.
LISTA/PREDRAČUN/RAČUN/SPECIFIKACIJA, PREDMET snapshot PDF and NALOG consume the
stored name. JSON carries raw row snapshots. Scenario reconciliation updates
business decision fields and preserves selected article snapshots.

## K. Existing malformed-row audit

The active database audit found at least one unambiguously repairable row:
target row 1732 (stable ID proves `Flor`, stored category label `Crnina`). Row
1733 (`Ešarpa`) is already correct. Rows without a stable ID or with unknown,
cross-category or custom-name combinations are ambiguous and remain untouched.

## L. Safe repair classification and execution

The deterministic repair is covered on a forensic in-memory database and
preserves price, quantity and amount. It is not yet executed on the canonical
Windows DB because the new release could not be deployed to the protected
installed directory. Canonical deduplication remains separately deferred.

## M. Regression coverage across real caller paths

Focused tests pass (`10` tests), including stable-ID `Flor` repair, intentional
custom-name preservation, concrete-name resolver behavior, scenario materialized
category labels and editable-row projection. Existing JSON and LISTA fidelity
tests cover raw snapshot transfer/document consumption. A dedicated full
single-PREDMET concrete-name round-trip remains a deferred strengthening item.

## N. Windows build/deployment identity

`flutter analyze`: PASS. Full `flutter test`: PASS (401 passed, 7 skipped).
`flutter build windows --release`: PASS. The freshly
built `OPC.exe` runner hash is
`DCB784346DA415ED19FE6AD458E5917A1E83F5F58F2363A8400E68F1F5115A7C`; the
compiled Dart payload is in `data\app.so`. The protected installed directory
has the same runner but its payload could not be replaced without taking
ownership or granting broad write access; that escalation was rejected as an
unsafe ACL weakening. Therefore installed-release identity is not proven for
this source change.

## O. Flor/Ešarpa installed-runtime acceptance

Not run against the repaired build. Prior Computer Use proved the installed
runtime can open the target PREDMET, but screenshots still fail with
`SetIsBorderRequired failed: No such interface supported (0x80004002)`, and the
new build was not safely deployable to the protected install directory.

## P. Other-category installed-runtime acceptance

Not proven for the repaired build.

## Q. IRiU order acceptance

Not proven in the repaired build. Database-level order/provenance contracts
remain unchanged.

## R. SCENARIO non-mutation acceptance

Not proven in the repaired build; no canonical mutation was performed.

## S. LISTA PDF acceptance

Not proven in the repaired build. Existing source-level LISTA fidelity tests
remain valid, but they do not replace installed visual evidence.

## T. Repaired-DB installed-runtime acceptance

Not run for this source change. The previous repaired-copy run proved startup,
login and target PREDMET load but not the complete visual/document gate.

## U. OPEN PREDMET dedup safety

Partial at source/copy level; canonical dedup was not attempted.

## V. Canonical ČITULJE dedup

Deferred because repaired-build installed-runtime gates are incomplete.

## W. Post-dedup real runtime

Not applicable.

## X. Full analyzer/tests/builds

Analyzer PASS, Windows release build PASS, focused pipeline test PASS. Full
`flutter test` was not run in this bounded pass; Android build/physical
acceptance were not run by design.

## Y. Resource/subagent use

Two read-only reviewers were used: one audited KATALOG/IRiU/database paths and
one audited JSON/SCENARIO/document consumers. Neither edited files. Main Codex
reconciled their findings and implemented the bounded repair.

## Z. Documentation reconciliation

The authoritative plan/current state/source-of-truth map/owner index must state
that concrete-label technical PASS is superseded, the canonical snapshot
contract is established in source, and Windows runtime deployment/visual proof
remains open.

## AA. Deferred items

Deferred: safe deployment of the release into the owner-confirmed installed
directory, canonical malformed-row repair execution, full single-PREDMET JSON
round-trip assertion, installed Flor/Ešarpa/other-category visual proof, IRiU
order, SCENARIO, LISTA, repaired DB acceptance, canonical citation dedup and
post-dedup runtime. Android remains out of scope.

## AB. Git completion

After documentation reconciliation, the branch will be committed, pushed and
verified clean with the remote SHA recorded below.

## AC. Final verdict

- `OWNER-OBSERVED FLOR→CRNINA DEFECT — SOURCE-PROVEN`
- `FIRST DIVERGENCE POINT — PROVEN`
- `PREVIOUS TEST GAP — EXPLAINED`
- `CANONICAL KATALOG→IRiU REPRESENTATION — ESTABLISHED`
- `DIVERGENT WRITE PATHS — PARTIAL`
- `DIVERGENT DISPLAY PATHS — PARTIAL`
- `CRNINA FLOR REAL RUNTIME — FAIL`
- `CRNINA EŠARPA REAL RUNTIME — NOT AVAILABLE`
- `OTHER KATALOG ARTICLE REAL RUNTIME — FAIL`
- `IRiU ORDER REAL RUNTIME — FAIL`
- `SCENARIO VIEW SILENT MUTATION — NONE`
- `SCENARIO REAL RUNTIME — FAIL`
- `LISTA PDF ARTICLE/CITATION FIDELITY — FAIL`
- `EXISTING MALFORMED ROWS — PARTIAL`
- `REPAIRED DB REAL RUNTIME — NOT RUN`
- `OPEN PREDMET DEDUP RUNTIME SAFETY — NOT PROVEN`
- `ČITULJE RECURRENCE — CLOSED`
- `CANONICAL ČITULJE DEDUP — DEFERRED`
- `CANONICAL PREDMET BUSINESS TRUTH — PRESERVED`
- `flutter analyze — PASS`
- `flutter test — PASS`
- `WINDOWS RELEASE BUILD — PASS`
- `ANDROID RELEASE BUILD — NOT REQUIRED`
- `ANDROID PHYSICAL ACCEPTANCE — NOT RUN BY DESIGN`
- `AUTHORITATIVE DOCUMENTATION — UPDATED`
- `REMOTE SHA — CONFIRMED`
- `WORKING TREE — CLEAN`

Overall: `STOP — WINDOWS RUNTIME DEFECT`
