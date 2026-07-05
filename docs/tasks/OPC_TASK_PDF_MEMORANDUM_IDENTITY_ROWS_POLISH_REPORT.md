# OPC Task — PDF Memorandum/Header Identity Rows Polish

## Identity

- Branch: `task/OPC-PDF-MEMORANDUM-IDENTITY-ROWS-POLISH`
- Base commit: `0eb2751cf0313ec8cc46cdc29f3466ab0c090a22`
- Final commit: commit containing this report; immutable SHA follows in final handoff.
- GitHub branch: `https://github.com/Tale74/OPC/tree/task/OPC-PDF-MEMORANDUM-IDENTITY-ROWS-POLISH`
- GitHub commit: `https://github.com/Tale74/OPC/commit/<final-commit-sha>`
- GitHub report: `https://github.com/Tale74/OPC/blob/task/OPC-PDF-MEMORANDUM-IDENTITY-ROWS-POLISH/docs/tasks/OPC_TASK_PDF_MEMORANDUM_IDENTITY_ROWS_POLISH_REPORT.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: yes.

- Task class: narrow implementation + tests + documentation.
- PREDMET impact classification: none; PDFs remain derivatives of PREDMET.
- PDF derivative impact classification: presentation-only identity rows.
- PDF business-logic impact classification: none.
- DOKUMENTI navigation impact classification: none.
- Database/JSON/platform/package/module impact: none.
- Implementation allowance: yes, only memorandum identity-row rendering and label spelling.

## Source learning and local documentation

Inspected the manifest, A–H audit report/pseudocode, PDF pseudocode/index, prior PDF reports, all PDF exporters under `lib/features/predmeti/pdf`, every `PIB`/`MB`/`Racun`/`Račun` match and available tests.

Inspected local `PROJECT_DOCS`, `RESTORE_POINTS`, `BACKUPS`, and `SMOKE_LOGS`. Local architecture documents confirm PDF is PREDMET-derived and that business/snapshot truth must not be altered. Those rules are already migrated into Git manifest/pseudocode. Restore points and backups are historical/preservation evidence, not newer header-format authority. No conflict or owner decision is required.

## Diagnosis before implementation

Business-info is rendered inside private `_buildHeader` functions in six exporters:

1. `predmet_pdf_snapshot_export.dart` — PREDMET
2. `lista_pdf_export.dart` — LISTA
3. `nalog_za_opremanje_pdf_export.dart` — NALOG ZA OPREMANJE
4. `predracun_pdf_export.dart` — PREDRAČUN
5. `racun_pdf_export.dart` — RAČUN
6. `specifikacija_troskova_pdf_export.dart` — SPECIFIKACIJA TROŠKOVA

The complete header is duplicated; only `buildMemorandumLogo` is shared. Each header hardcodes PIB, MB and account labels into a list, joins them using ` | `, then renders one `pw.Text`. LISTA alone uses the forbidden visible label `Racun`; other `Racun` source matches are identifiers/filename tokens and are not visible-label defects. The other five headers use `Račun` literally or via Unicode escape.

No existing PDF-focused test covers this structure. The minimal safe correction is to add one small shared identity-row text builder beside the shared memorandum helper, have all six duplicated headers render its three entries as separate text widgets, and test the pure builder. This proves consistent labels/ordering/empty-field omission without brittle PDF golden output.

Only the six header blocks, shared helper, a new focused test and documentation should change. Logo constraints, page/title/date/case-number layout, PDF totals/items, PREDMET/IRiU/catalog snapshots, finance, RAČUN legal meaning, JSON and DOKUMENTI navigation must remain unchanged.

## Implementation and evidence

Added `buildMemorandumIdentityRows` to the existing memorandum helper. It trims existing values, omits empty fields, returns PIB/MB/Račun in stable order and always uses `Račun`. All six exporters now iterate those entries and create one `pw.Text` per entry. No fixed header height or logo constraint changed; the existing flexible memorandum column naturally accommodates the extra rows.

Changed source files:

- `lib/features/predmeti/pdf/memorandum_logo.dart`
- `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
- `lib/features/predmeti/pdf/lista_pdf_export.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart`
- `lib/features/predmeti/pdf/predracun_pdf_export.dart`
- `lib/features/predmeti/pdf/racun_pdf_export.dart`
- `lib/features/predmeti/pdf/specifikacija_troskova_pdf_export.dart`

Changed test: `test/pdf_memorandum_identity_rows_test.dart`.

Changed docs: PDF header pseudocode, A–H audit pseudocode, Logos pseudocode index and this report.

Focused structural tests prove three distinct list entries exactly equal `PIB 123456789`, `MB 12345678`, and `Račun 160-1-01`; no entry contains the former ` | ` identity separator or starts with forbidden `Racun`. Empty values are omitted without merging remaining rows. Source search confirms the former LISTA visible label is removed; remaining `Racun` tokens are Dart identifiers/file tokens, not affected PDF labels.

The diff changes no totals, calculations, item builders, snapshots, document bodies, title/date/case-number blocks, logo constants, export navigation or data reads. Therefore PDF business logic and PREDMET truth are unchanged. IRiU, catalog snapshot, RAČUN legal/business model, finance, JSON, DOKUMENTI navigation, PODSETNIK, STATISTIKA, STANJE ROBE and Windows exit files are untouched.

- Focused test: PASS, 2 tests.
- `flutter analyze`: pending.
- `flutter test`: pending.
- Manifest gate/GitHub verification: pending.
- Build/runtime/smoke: not run.

## OPC MANIFEST COMPLIANCE — TASK END

Pending final validation and GitHub gate.
