# OPC v1.5 — Extended COR-05 implementation traceability

**Date:** 2026-10-12\
**Status:** `READY FOR LOGOS/OWNER REVIEW`\
**Authority:** Attached OWNER task; HUMAN GATE pre-authorized\
**Scope:** About presentation, full-screen offline RAD U APLIKACIJI guide, one shared guide source, explicit contextual POMOĆ across Windows/Android Narrow/Android Wide, required focused/full QA and release builds.\
**Excluded:** Physical runtime, business/data/operational changes, rebaseline, commit and push.

## Outcome

The About screen retains the approved identity, exact description, developer,
license and note text, and no longer renders the LICENCA/AKTIVACIJA or
DIJAGNOSTIKA BAZE panels. Existing identity, licensing, installation,
diagnostic and security mechanisms remain in source. `RAD U APLIKACIJI` now
opens a full-screen guide. The full guide and contextual POMOĆ share one
bundled Serbian JSON resource, loaded on demand and without network access.
Contextual help pushes a guide route above the current screen and opens a
screen- or segment-specific chapter. The visible raspberry circle is 32×32 px;
the InkWell target is 48×48 px and the regression taps its outer area. It does
not save or mutate the underlying screen's data or selection.

The exact approved About copy is:

> OPC pomaže u organizaciji i vođenju pogrebnih poslova. Na jednom mestu
> omogućava pregled predmeta, pripremu dokumentacije, praćenje obaveza i
> evidenciju robe i usluga.

No fallback three-dot menu was required. Header tests cover narrow Android,
wide Android and Windows viewport presentations while preserving existing
controls. Platform differences concern presentation only.

## Source learning and affected implementation

| Area | Current implementation / effect |
|---|---|
| About / settings | `lib/features/podesavanja/presentation/podesavanja_screen.dart`: approved short copy displayed with app identity; full-screen guide action; obsolete diagnostic/license-activation panels removed from visible About content only. |
| Shared content | `assets/opc_user_guide.json`: versioned offline resource, 33 unique chapter IDs. |
| Loading and validation | `lib/core/help/opc_guide_repository.dart`: on-demand asset loading, JSON parsing, version and duplicate/empty ID checks. |
| Full-screen guide | `lib/core/help/opc_guide_screen.dart`: chapter and subsection navigation, responsive navigation, safe back to prior route. |
| Context mapping/action | `lib/core/help/opc_help.dart`: explicit POMOĆ button/title wrapper, raspberry visual, screen action and ten-segment mapping. |
| Shared chrome | `lib/core/widgets/opc_page_chrome.dart`: title-level help integration while retaining existing chrome actions. |
| Screen entry points | Auth, settings, modules, statistics, PREDMET, SCENARIO, reminders, stock, PARTE and ČITULJE screen implementations listed in the affected-file evidence matrix. |
| Asset registration | `pubspec.yaml`: registers the single guide resource for both release targets. |

No business rule, data model, database/schema, backup/JSON contract, network
dependency, permission rule or protected SCENARIO/IRiU/PARTE/ČITULJE operation
was changed to support documentation.

## Guide chapter inventory and screen mapping

The resource has **33 distinct chapter IDs**, each with an intro and practical
sections. User-facing headings follow OPC screen/segment labels; editable case
or catalog data does not determine guide structure.

| Guide IDs | OPC screen / workflow |
|---|---|
| `overview` | RAD U APLIKACIJI overview and navigation |
| `first_launch`, `login`, `forced_pin` | First launch, PRIJAVA and required PIN change |
| `lista` | LISTA PREDMETA and its main actions |
| `predmet` | PREDMET overview, save/return and lifecycle boundaries |
| `predmet.preminulo_lice` | Segment 1 — PREMINULO LICE |
| `predmet.cinjenice_o_smrti` | Segment 2 — ČINJENICE O SMRTI |
| `predmet.statusi` | Segment 3 — STATUSI |
| `predmet.platilac` | Segment 4 — PLATILAC |
| `predmet.ceremonija` | Segment 5 — CEREMONIJA |
| `predmet.parte` | Segment 6 — PARTE |
| `predmet.roba_i_usluge` | Segment 7 — ROBA I USLUGE |
| `predmet.finansije` | Segment 8 — FINANSIJE |
| `predmet.dokumenti` | Segment 9 — DOKUMENTI |
| `predmet.pregled_i_potvrda` | Segment 10 — PREGLED I POTVRDA |
| `moduli` | MODULI |
| `settings` | PODEŠAVANJA overview |
| `settings.company` | PODACI FIRME |
| `settings.refundacija` | REFUNDACIJA PIO |
| `settings.modules` | MODULI settings |
| `settings.payment` | UPUTSTVO ZA PLAĆANJE |
| `settings.catalog` | KATALOG |
| `settings.users` | KORISNICI |
| `settings.about` | O APLIKACIJI and RAD U APLIKACIJI |
| `statistics` | STATISTIKA |
| `scenario` | SCENARIO |
| `reminders` | PODSETNIK |
| `parte.list`, `parte.preparation` | MODUL PARTE and PARTE PRIPREMA |
| `citulje.list`, `citulje.preparation` | MODUL ČITULJE and ČITULJE preparation |
| `stock` | STANJE ROBE |

The 33 IDs are resource-validated for uniqueness and the ten segment mappings
are covered by widget tests. Help call sites also include login/first launch,
settings tabs/catalog/users, PREDMET screens, MODULI, statistics, SCENARIO,
PODSETNIK, STANJE ROBE, PARTE and ČITULJE. Exact source paths and per-screen
chapter choices are also recorded in `HELP_PLACEMENT_MATRIX.md` in the review
ZIP.

## Verification

Focused final regressions, run individually after an earlier grouped run met
an existing native-assets copy collision:

| Command | Result |
|---|---|
| `flutter test --no-pub test/opc_user_guide_test.dart` | 6/6 pass |
| `flutter test --no-pub test/podesavanja_screen_smoke_test.dart` | 7/7 pass |
| `flutter test --no-pub test/opc_page_chrome_test.dart` | 3/3 pass |
| `flutter test --no-pub test/predmet_compact_chrome_test.dart` | 4/4 pass |
| `flutter test --no-pub test/parte_module_screen_test.dart` | 4/4 pass |
| **Focused total** | **24/24 pass** |

The initial full suite exposed one stale PARTE widget assertion that assumed
the app-bar title had to be a bare `Text`. It was updated to assert the
`OpcHelpTitle`, the unchanged inner title and the contextual help control; the
focused PARTE test and final full suite then passed. No existing product
behavior assertion was weakened.

| Gate | Final result |
|---|---|
| `flutter analyze --no-pub` | PASS; `No issues found!`; exit 0; 345.3 s; 2026-10-12 09:20:57.928+02:00 → 09:26:51.458+02:00 |
| `flutter test --no-pub --concurrency=1` | PASS; 662 passed, 9 skipped, 0 failed; exit 0; 1,701.9 s; 2026-10-12 09:27:08.961+02:00 → 09:55:30.819+02:00 |
| Skip interpretation | 9 existing environment/private-copy/forensic gated skips; not counted as executed passes |
| Windows release | PASS; `flutter build windows --release --no-pub`; exit 0; 234.3 s; 2026-10-12 09:55:58.583+02:00 → 10:00:01.118+02:00 |
| Android production release | PASS; `flutter build apk --release --flavor production --no-pub`; exit 0; 803.7 s; 2026-10-12 10:00:27.244+02:00 → 10:13:50.949+02:00 |
| Physical runtime | Not authorized or run |

Build artifact identities:

| Artifact | Size | SHA-256 |
|---|---:|---|
| `build/app/outputs/flutter-apk/app-production-release.apk` | 79,360,017 bytes | `541DADBE326E7C9E616DA62D3C01C7EB4AC1EA570609817F6C705917B0369E51` |
| `build/windows/x64/runner/Release/OPC.exe` | 89,600 bytes | `E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD` |
| `build/windows/x64/runner/Release/data/app.so` | 13,140,912 bytes | `435F687502EA1E38A43D9ACDEFBC5FEB4F73FB26009CFB2ADDE9284950D3E16A` |
| Windows bundled guide asset | 18,739 bytes | `01F2920F1F49C0186419D959B4EE1564401BA828D2B4B4E45B3E7F1D0DB7C70E` |

The APK ZIP listing contains `assets/flutter_assets/assets/opc_user_guide.json`.
The Windows release contains the bundled guide in `data/flutter_assets`. These
are packaging checks, not on-device or interactive runtime acceptance. The
Windows runner executable's timestamp predates this task because its native
runner source did not change; the current Flutter payload and guide asset were
produced by the authorized release build.

## Documentation delta and evidence boundaries

Updated current-state traceability in `OPC_ARCHITECTURE.md`,
`OPC_CURRENT_DEVELOPMENT_STATE.md`, `OPC_QUALITY_RELEASE.md` and
`OPC_SOURCE_OF_TRUTH_MAP.md`; no product/domain policy or business-critical
pseudocode was changed. There is no data-contract or operational mechanism
impact. The initial Serbian guide is a complete source-grounded draft, but its
wording remains subject to OWNER review. No physical validation was done for
touch sizing, navigation context restoration or actual narrow/wide installed
layouts; widget/responsive tests and builds do not close that gap.

The previously accepted active-source intake result was 20/28 with its known
eight provenance-resolved differences. It is historical pre-task evidence,
not a substitute for current verification. A fresh post-edit literal comparison
of all 28 rows returned 20 matches and the same eight paths. The tracked CSV
SHA-256 remains
`3FA780EE45874434E11B9B198A5D8855250541CEEE1E5AC543EB8E652EF1CE26` and was
not changed. This is not a rebaseline; exact expected and observed hashes are
in `ACTIVE_SOURCE_POST_EDIT_LITERAL_CHECK.md`. The unchanged rows retain their
already accepted provenance; three tracked source rows also include authorized
contextual-help integration and two tracked documents include current Docs-as-
Code updates. The existing 162-row mixed worktree was preserved; no reset,
restore, stash, cleanup, commit or push was done.

## Incidental finding disposition

INC-01 is retained in the external task's `INCIDENTAL_FINDINGS.json`: two
PREDMET blocker messages still contain the retired KORICE PDF / PRIPREMA
ZAVRŠENA wording. This is outside the guide/About scope and does not alter the
guide's content. It was not changed; it is preserved for Logos/OWNER comparison
with prior COR-01 scope. It creates no new authority and has a non-orphaned
review disposition. See the artifact for exact source paths and evidence.

## Handoff

Canonical external package: `C:\Projekti\OPC_v1.5\REVIEW\CURRENT_TASK\OPC_V15_EXTENDED_COR05_IMPLEMENTATION_20261012.zip`.
The package is expected to include source-learning, placement/content matrices,
QA/build JSON evidence, documentation delta, incidental finding, review index,
and the canonical package manifest/integrity report. Package integrity and
completion-validator outcomes are reported in the final handoff; they are not
OWNER acceptance. **Status: `READY FOR LOGOS/OWNER REVIEW`.**
