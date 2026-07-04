# OPC Task — PDF Memorandum/Header Logo Layout Report

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- implementation and documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no; PDFs remain derived from PREDMET

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no; the shared PDF source presentation is changed without platform behavior changes

Future OPC Web affected:
- no

Terminology drift risk:
- no; no document text or terminology changed

Implementation allowed:
- yes, limited to the owner-requested PDF memorandum/logo presentation boundary

Required gate before implementation:
- product terminology and manifest scope check; passed without terminology changes

## Branch and commits

- Branch: `task/OPC-PDF-MEMORANDUM-HEADER-LOGO-LAYOUT`
- Base commit: `5e833a2ba5213fbca34233f383b016e6684e18be`
- Final commit: `HEAD` — the single final task commit; its immutable hash is recorded in the final Codex handoff because embedding a commit's own hash would change that hash.

## Source-learning summary

The PREDMET DOKUMENTI actions in `predmet_screen.dart` call six dedicated PDF
export entry points. Each exporter loads its own required PREDMET-related data,
builds a document-specific PDF body and header, and saves through the shared
KORICE export utility. There is no shared complete memorandum/header builder.

All six header builders do share `memorandum_logo.dart`. Firma logo bytes come
from the nullable `FirmaPodaci.logo` database field, populated through
PODEŠAVANJA. Before this correction, every exporter passed a small fixed logo
slot (72–76 x 52–56 points), and the helper added 12 points of left margin.

Header variants are source-confirmed:

- LISTA: title followed by `Broj predmeta`; no header date.
- NALOG ZA OPREMANJE, PREDRAČUN, and SPECIFIKACIJA TROŠKOVA: title then
  `Broj predmeta` on the left, date on the right.
- RAČUN: `brojPredmeta` is embedded in `RAČUN BR: ...`; issue date is right-aligned.
- PREDMET: title followed by a combined `Broj predmeta`, export date, and status line.

The shared logo correction safely affects all six documents. Complete header
unification and a uniform `Broj predmeta` move are not safe within this task.

## Exact source paths inspected

- `lib/features/predmeti/presentation/predmet_screen.dart` — PDF action/UI entry points.
- `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart` — PREDMET builder and header.
- `lib/features/predmeti/pdf/lista_pdf_export.dart` — LISTA builder and header.
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart` — NALOG builder and header.
- `lib/features/predmeti/pdf/predracun_pdf_export.dart` — PREDRAČUN builder, header, and IPS QR area.
- `lib/features/predmeti/pdf/racun_pdf_export.dart` — RAČUN builder and header.
- `lib/features/predmeti/pdf/specifikacija_troskova_pdf_export.dart` — specification builder and header.
- `lib/features/predmeti/pdf/memorandum_logo.dart` — shared logo rendering and sizing.
- `lib/features/predmeti/pdf/lista_pdf_data_builder.dart` — shared prepared PREDMET/IRiU/finance document data.
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_data_builder.dart` — NALOG prepared data.
- `lib/core/database/tables/firma_podaci_table.dart` — nullable persisted logo bytes.
- `lib/features/podesavanja/presentation/podesavanja_screen.dart` — logo selection/persistence UI.
- `lib/core/utils/export_utils.dart` — shared KORICE PDF naming/saving behavior.
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` and
  `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` — existing Logos PDF learning layer.

## Diagnosis before fix

The logo appeared too small because fixed per-document width/height arguments
capped it at 72–76 x 52–56 points. `BoxFit.contain` correctly preserved aspect
ratio, but it could not exceed that slot. The helper's 12-point left margin also
consumed memorandum-row width. The constraint was therefore fixed dimensions
plus separation margin, not image distortion, table cells, or logo-source data.

One shared correction is safe because every relevant header delegates only logo
rendering to the same helper. No document-specific logo treatment is needed.
Dates are document-specific: four compact headers place a date on the right,
LISTA has none, and PREDMET includes export date in metadata.

Moving `Broj predmeta` above the title was not applied. It is not structurally
uniform: RAČUN makes the number part of its title, PREDMET combines it with date
and status, and LISTA lacks the right-side date layout. Forcing the move without
runtime visual acceptance could alter established wording and cause wrapping or
crowding. Blind header changes also risk long firm-name overflow and damage to
financial/legal readability or adjacent IPS QR/body space.

## Implemented correction

`memorandum_logo.dart` now owns shared constants for a 96 x 60 point slot and a
10-point left margin. The six exporters no longer carry divergent logo sizes.
The image remains proportionally contained and right-aligned. No title,
`Broj predmeta`, date, content, or export behavior changed.

## Business meaning

The larger shared logo slot gives the funeral company identity more appropriate
presence in formal PDFs while preserving every PREDMET-derived business fact.
PREDMET remains the master business truth; PDFs remain user-facing derivatives.

## Risk analysis and safe upgrade boundary

The change is intentionally bounded to moderate shared logo dimensions and two
points less internal separation. It does not redesign headers or globally alter
fonts. Remaining risk is visual: unusually long company data or unusual logo
aspect ratios require later exported-PDF review. That review is explicitly
deferred and no visual PASS is claimed.

Protected and unchanged: export set/order, filenames, RAČUN/PREDRAČUN/LISTA/
SPECIFIKACIJA/NALOG/PREDMET business logic, PREDMET fields, IRiU, finance,
IPS QR, payer/recipient data, JSON, catalog, packages, reminders, GDPR,
STATISTIKA, STANJE ROBE, platform runners, saving, and runtime flow.

## Exact source paths changed

- `lib/features/predmeti/pdf/memorandum_logo.dart`
- `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
- `lib/features/predmeti/pdf/lista_pdf_export.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart`
- `lib/features/predmeti/pdf/predracun_pdf_export.dart`
- `lib/features/predmeti/pdf/racun_pdf_export.dart`
- `lib/features/predmeti/pdf/specifikacija_troskova_pdf_export.dart`

## Pseudocode/docs learning layer

- `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md` — added export flow,
  shared-vs-specific header mapping, logo source/sizing, metadata variants,
  implemented correction, and protected boundary.
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` — added `OPC-PSEUDO-INDEX-037`.
- This task report records diagnosis, evidence, validation, and manifest compliance.

## Validation commands and results

- `dart format` on all seven changed Dart files: PASS.
- `C:\flutter\bin\flutter.bat analyze --no-pub`: PASS, `No issues found!`.
- `C:\flutter\bin\flutter.bat test --no-pub`: PASS, 110 tests, `All tests passed!`.
- `python scripts/validate_opc_manifest_gate.py --base 5e833a2`: PASS, one changed task report validated.

The initial sandboxed analyzer invocation could not write Flutter SDK/telemetry
files. Validation was rerun with authorized SDK access; orphaned analyzer
processes from the timed-out attempt were stopped before the successful clean run.

## Build/runtime status

- Windows build was not run.
- Android build was not run.
- Runtime was not run.
- PDF visual acceptance was not claimed.
- Build/runtime validation is deferred by owner decision until the wider correction group is completed.

Status: `SOURCE/TEST PASS — BUILD DEFERRED BY OWNER DECISION — PDF VISUAL REVIEW REQUIRED LATER`.

## Manifest compliance

The task preserved OPC purpose, PREDMET ownership/meaning, local database
ownership, platform parity, JSON transfer, protected terminology, document set,
and future Web compatibility. Source and documentation changes remain inside the
authorized PDF memorandum/logo presentation boundary.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS
