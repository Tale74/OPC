# OPC IRiU production/test ordering discrepancy forensic audit

## A. Baseline and source reviewed

Audit branch: `audit/OPC-IRIU-PRODUCTION-TEST-ORDERING-DISCREPANCY`.

The clean starting point was `f265231e36eb11f68963d226182eaed8b788bd06` on `task/OPC-TEMP-MEDIA-TEST-FIX-FULL-SUITE-FINAL-BUILDS`; the tracked remote branch resolved to the same SHA. The visibility commit `9d733b144200028dee4ca2908735e6af61ec2124` was available remotely. The implementation report/evidence, final-build report/evidence, visibility report, preceding lifecycle audit, current service, repository, UI consumer, snapshot parser, and exact golden test were read rather than inferred from summaries.

Installed and built artifacts are byte-identical:

| Artifact | SHA-256 |
|---|---|
| `C:\Program Files\OPC\OPC.exe` and release `OPC.exe` | `DCB784346DA415ED19FE6AD458E5917A1E83F5F58F2363A8400E68F1F5115A7C` |
| installed and release `data\app.so` | `031B3075BE289521823811B39AD4399C9429CBAA5D0F84D94C4237139CD067C5` |

The process observed at audit start began at 2026-08-14 14:53:10 local, after the release `app.so` timestamp. A stale installed artifact is therefore disproven.

## B. Owner runtime failure confirmation

The task locks the owner's post-build observation as a fact: the historical PREDMET still displays the wrong order. This audit does not reinterpret that report. Archived runtime captures `RUNTIME\IRIU1.PNG` and `IRIU2.PNG` independently show the same PREDMET and the wrong sequence, but their timestamps (06:37 local) precede the final build; they prove the historical symptom, not post-build artifact behavior.

## C. Real Computer Use lifecycle

Computer Use attached to the single installed window owned by `C:\Program Files\OPC\OPC.exe`, opened `JOVIĆ ŽIVKO`, entered `ROBA I USLUGE`, observed 18 three-field row groups, exited without saving, reopened the same PREDMET in-session, and returned to the same 18-row editor.

The Windows capture backend failed twice, including the prescribed refresh/reselect retry, with `SetIsBorderRequired failed: No such interface supported (0x80004002)`. Accessibility exposed the row controls but not their values. Consequently, Computer Use could prove identity, section, row count, no grouping/filtering, and reopen lifecycle, but could not independently transcribe the current post-build names/order.

A real cold restart was completed: the old window id `15598396` closed and the relaunched process produced window id `15729468`. The relaunched app stopped at the SAŠA ANDONOV PIN screen. No PIN was guessed or bypassed, so a cold-restart reopen of the PREDMET was not completed.

## D. Exact real runtime sequence

The exact wrong sequence visible in the archived real-runtime captures is:

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

The captures are SHA-256 `317DCECE679FDAAD5FE344C55B7F986C19D2508AC27D4E6637C928C5DB684B80` and `7D7D041D36367AA3F0CFBF96CAE49A799234D3CDC69D1B939A9731195249013D`. Because they predate the build and current value capture failed, the exact current post-build rendered sequence remains not independently captured.

## E. Real DB row/context dump

Canonical PREDMET id `113` is `JOVIĆ ŽIVKO / 120826_1949`, status `OTVOREN`, scenario `business/default`, death place `DOM ZA STARE`, ceremony `KREMACIJA`, cemetery `NOVO, GRADSKO`, and `opelo=DA`.

Raw stored rows are stale-order rows:

| id | category | display | stored `redosled` | business section/order | managed |
|---:|---|---|---:|---|---|
| 1724 | AGENCIJSKE_USLUGE | Agencijske usluge | 0 | 1/0 | yes |
| 1721 | CITULJA_POLITIKA | ČITULJA POLITIKA I/90 mm — Cela zemlja | 1 | 1/2 | yes |
| 1720 | CVECE | Cveće SUZA SU 1/1 | 2 | 1/4 | yes |
| 1715 | OBELEZJE | SVETOSAVSKI KRST Topola/Hrast | 3 | 1/5 | yes |
| 1717 | PESKIR_ZA_KRST | Peškir za krst | 4 | 1/6 | yes |
| 1716 | POKROV_GARNITURA | Pokrov garnitura BORDO | 5 | 1/7 | yes |
| 1718 | POSMRTNE_PARTE | Posmrtne parte | 6 | 1/8 | yes |
| 1714 | SANDUK | Sanduk V-4 | 7 | 1/9 | yes |
| 1723 | SLIKA | Slika | 8 | 1/10 | yes |
| 1731 | TRANSPORTNA_VRECA | Transportna vreća | 9 | 2/10 | yes |
| 1727 | IZNOSENJE | Iznošenje | 10 | 2/20 | yes |
| 1729 | PREVOZ_DO_HLADNJACE | Prevoz do hladnjače | 11 | 2/30 | yes |
| 1726 | HLADNJACA | Hladnjača | 12 | 2/40 | yes |
| 1730 | SPREMANJE_POKOJNIKA | Spremanje pokojnika | 13 | 2/50 | yes |
| 1728 | PREVOZ_DO_GROBLJA | Prevoz do groblja | 14 | 2/60 | yes |
| 1725 | KOMPLET_ZA_OPELO | Komplet 80 | 15 | 6/0 | no |
| 1732 | CRNINA | Crnina | 16 | 1/3 | yes |
| 1733 | CRNINA | Ešarpa | 17 | 1/3 | yes |

## F. Golden fixture data/context dump

`test/iriu_shared_derived_ordering_test.dart` calls `IriuOrderingService` directly with 18 synthetic IDs, an explicitly injected base set, scenario set, scenario section/order maps, and an empty provenance map. Its row identities already encode the expected sequence 1..18 even though `redosled` is scrambled. It represents Ešarpa as category `ESARPA`, while the real row is a second `CRNINA`; it also uses a non-production spelling/encoding for the Cveće category.

## G. Field-by-field golden vs real comparison

| FIELD | GOLDEN TEST | REAL PREDMET | DIFFERENCE | EFFECT ON ORDERING |
|---|---|---|---|---|
| row IDs | synthetic 1..18 | 1714..1733 | different identity domain | tie-break differs only when ranks tie |
| Ešarpa category | `ESARPA` | duplicate `CRNINA` | material shape mismatch | both real CRNINA rows tie at 1/3, then stale order/id retains Crnina before Ešarpa |
| Cveće category | synthetic encoded spelling | `CVECE` | mismatch | real snapshot category matches production row |
| provenance | explicitly empty map | 17/18 rows present | golden bypasses provenance | real branch has stronger classification |
| Komplet provenance | none | none | same gap | snapshot classifies it as scenario; origins-only fallback leaves it manual-last |
| applied snapshot | synthetic context, no parsing | persisted schema-v1 snapshot | production must parse/validate | repository run proves it succeeds sufficiently |
| base membership | explicitly injected | snapshot includes CRNINA and other base categories | real has category membership, not row identity | both CRNINA rows classify base |
| scenario membership | explicitly injected | seven consequences in snapshot | same business meaning | produces 2/10..2/70 sequence |
| business section/order | fixture values | persisted values plus snapshot override | Komplet stored 6/0 vs snapshot default 2/70 | snapshot moves Komplet to scenario tail |
| stored `redosled` | deliberately scrambled | exact historical stale sequence | different values | used only as deterministic tie/fallback order |
| stable article IDs | synthetic helper values | production stable IDs present | fixture is simplified | no adverse effect in captured service path |
| legacy/default values | one deliberate Komplet gap | Komplet unmanaged and unprovenanced | real gap reproduced | output still correct |

The golden fixture does not match the real metadata shape, but the mismatch does not reproduce the reported wrong current output.

## H. Applied snapshot availability

One parseable applied snapshot exists for PREDMET 113. It identifies scenario `MAP_PRIRODNA_DOM_ZA_STARE_KREMACIJA_NE_PRIMENJUJE_SE_NE_PRIMENJUJE_SE_DA_NE_NE`, contains base membership including `CRNINA`, contains all seven consequence categories, and supplies consequence business order 10..70 (section defaults to 2 where omitted). Context is complete for ordering this PREDMET.

## I. Provenance completeness

Provenance exists for 17 of 18 rows. `KOMPLET_ZA_OPELO` id 1725 is the sole missing row. This is partial provenance, but it is not causal: the applied snapshot classifies Komplet, and even the origins-only fallback places the unclassified/manual Komplet last.

## J. Repository/provider production caller path

`PredmetScreen` constructs `IriuRepository(widget.predmetiRepo.db)` (`predmet_screen.dart:147,176`) and passes it to `IriuSegment` (`:1380-1394`). `IriuSegment` subscribes to `watchIriu(predmetId)` (`iriu_segment.dart:554-555`). `watchIriu` applies `_orderedProjection` (`iriu_repository.dart:61-68`); `_orderedProjection` builds `_orderingContext` and calls the shared service (`:575-584`). `getIriu` uses the same projection (`:563-565`). No historical-screen bypass was found.

Required verdict: `REAL HISTORICAL UI CALLER USES SHARED ORDERING SERVICE — YES`.

## K. Shared ordering service input/output in production-shaped run

An SQLite online backup of the live canonical DB was opened through `AppDatabase.forTesting(NativeDatabase(file))`, then the exact production repository call `IriuRepository(db).getIriu(113)` was executed. Output IDs were:

`1724,1721,1732,1733,1720,1715,1717,1716,1718,1714,1723,1731,1727,1729,1726,1730,1728,1725`.

That is the exact authoritative order: Agencijske, Politika, Crnina, Ešarpa, Cveće, Obeležje, Peškir, Pokrov, Parte, Sanduk, Slika, Transportna, Iznošenje, Prevoz do hladnjače, Hladnjača, Spremanje, Prevoz do groblja, Komplet 80. The test passed in 42.1 seconds with `--concurrency=1`.

## L. Post-service UI transformations

`IriuSegment` maps `stavke` directly to `IriuRowTile` (`iriu_segment.dart:613-614`). `_resolveTruthState` computes/caches metadata but does not reorder the list. No downstream `.sort()`, grouping, filtering, or list reconstruction was found. Therefore source says post-service order is preserved; actual post-build rendered values could not be captured, so runtime preservation is not proven.

## M. Cache/state analysis

The repository stream recomputes `_orderedProjection` for each raw DB emission. The screen owns a stable repository instance, but no memoized row order was found. In-session reopen was exercised and produced a fresh 18-row editor. A new process/window was launched, but authentication prevented returning to the PREDMET. Cache contribution is not proven.

## N. Fallback branch analysis

With managed context, rows partition into base, scenario, managed-unclassified, and manual lists; business section/order ranks dominate, then stale `redosled` and id break ties. Null provenance alone does not trigger the legacy category fallback when a provenance map/context exists. Duplicate CRNINA rows tie and remain Crnina/Ešarpa. Missing Komplet provenance is covered by snapshot membership; without snapshot parsing it remains manual-last. No real-shaped branch falls back to the complete stale sequence.

## O. Characterization test

`test/iriu_production_test_ordering_discrepancy_characterization_test.dart` runs the exact repository path against an isolated copy selected by `OPC_IRIU_FORENSIC_COPY`. It asserts real row IDs and display names. Contrary to the task's suspected regression, it passes. A deliberately false failing assertion was not created.

## P. First divergence point

The observed chain is:

`REAL DB DATA (stale redosled + usable snapshot/provenance)` → `LOADER` → `CONTEXT BUILD` → `IriuOrderingService INPUT` → `CORRECT OUTPUT` → `CORRECT REPOSITORY OUTPUT` → `UI source maps without sorting` → `CURRENT RENDER VALUES NOT CAPTURED`.

The golden chain also produces the correct output, despite its simplified shape. No first production/test divergence is established in current source/artifact evidence.

## Q. Root cause

`ROOT CAUSE NOT PROVEN`.

The audit disproves stale installation, missing-context-as-cause, fallback-to-stale-order, repository bypass, and source-level post-sort. The remaining gap is an independently readable post-build render and an authenticated cold-restart reopen. It would be unsound to name cache or UI as root cause without that evidence.

## R. Blast radius

If a post-service runtime divergence is later captured, every historical IRiU screen using this widget may be affected. Source-level PDF/LISTA exporters call `IriuRepository.getIriu`, so the captured repository output for this PREDMET is correct; no independent PDF ordering defect is shown.

## S. Safe repair layer

No repair layer is authorized because root cause is not proven. Do not mutate historical rows, snapshot, provenance, or catalog data. The next audit should first make installed-render values observable and complete the authenticated cold-restart trace.

## T. Luna implementation handoff

Not ready. There is no proven function to change and no failing real-shaped regression target. Handoff stop conditions: do not change ordering logic, add migration, rewrite snapshot/provenance, or hardcode UI order until the first divergence is captured.

## U. Canonical non-mutation proof

The required runtime lifecycle itself caused canonical mutation. The audit-start physical SHA was `7C185E8CB93539A5B74E5999CEF0D883C9A1BF541353A08E9C871810C6B4CA45`; after the cold-restart lifecycle and final close it was `0C3515CA4FA69041E8E52AF2AEC29035D84A3640E2C4C4C09746081D0A4526DF`.

Logical comparison of all 23 non-SQLite tables against the online forensic baseline found exactly one changed table: 36 `scenario_definitions` rows changed only in `updated_at`, from `2026-08-14T12:53:31.560613Z` to `2026-08-14T13:18:43.394232Z`. No row counts or business payload columns changed. PREDMET 113, its 18 IRiU rows, 17 provenance rows, and applied snapshot have identical canonicalized hashes before/after. Integrity is `ok` and FK violations are zero. Nevertheless, the task's literal stop condition is met: `CANONICAL DB MUTATED — YES`. No rollback or further canonical write was attempted.

## V. Git completion

Only this report, the JSON evidence, and the production-shaped characterization test were committed on the audit branch and pushed to `origin`. The final local commit and remote branch SHA were verified equal; the worktree was clean after push.

## W. Final verdict

- `REAL WINDOWS HISTORICAL IRiU ORDER FAILURE — CONFIRMED` (locked owner fact; archived exact sequence; current exact values not independently recaptured)
- `FAILURE REPRODUCES AFTER REOPEN — YES` (owner-locked failure; reopen lifecycle completed, exact values inaccessible)
- `FAILURE REPRODUCES AFTER PROCESS RESTART — NO` (not proven because authentication blocked PREDMET reopen)
- `REAL HISTORICAL UI CALLER USES SHARED ORDERING SERVICE — YES`
- `REAL PREDMET APPLIED SNAPSHOT CONTEXT — COMPLETE`
- `REAL PREDMET PROVENANCE — PARTIAL`
- `GOLDEN FIXTURE MATCHES REAL METADATA SHAPE — NO`
- `IriuOrderingService REAL-SHAPED INPUT — CAPTURED`
- `IriuOrderingService REAL-SHAPED OUTPUT — CORRECT`
- `POST-SERVICE UI ORDER — NOT PROVEN`
- `CACHE/STATE CONTRIBUTION — NOT PROVEN`
- `FALLBACK TO STALE redosled — NO`
- `FIRST PRODUCTION/TEST DIVERGENCE — NOT IDENTIFIED`
- `REAL-PREDMET-SHAPED CHARACTERIZATION TEST — UNEXPECTED PASS`
- `ROOT CAUSE — NOT PROVEN`
- `CANONICAL DB MUTATED — YES`
- `LUNA REPAIR HANDOFF — NOT READY`
- `REMOTE SHA — CONFIRMED`
- `WORKING TREE — CLEAN`

Overall: `STOP — CANONICAL DB MUTATED`.
