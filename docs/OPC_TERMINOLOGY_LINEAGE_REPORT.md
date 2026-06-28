# OPC Terminology Lineage Report

Status: evidence report for `naručilac` / `narucilac` / `klijent` / `Platilac`.

This report does not rename source code, database fields, JSON keys, UI labels, PDF labels, tests, or business logic.

## Executive Finding

The inspected evidence supports a mixed lineage:

- `Platilac` is the current visible UI/PDF/business display term in the PREDMET payer surfaces.
- `narucilac` remains a current internal code/database/JSON/template segment term and appears in one PDF snapshot/export evidence path.
- The current state looks like a historical/internal naming layer that has partly evolved into visible `Platilac`, not a clean fully migrated terminology model.
- `klijent` is not a current PREDMET party term. English `customer` appears in licensing/test/documentation contexts, not as PREDMET payer/orderer terminology.

## Evidence Table

| Term | Exact spelling | Found where | Context | Layer | Current meaning | Current status | Evidence | Required action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Platilac | `Platilac` | `lib/features/predmeti/presentation/predmet_screen.dart` | PREDMET logical section label. | UI | Visible payer section. | CURRENT UI TERM | `_PredmetLogicalSection.platilac`, label `Platilac`. | Preserve; do not rename without owner task. |
| PLATILAC | `PLATILAC ROBE I USLUGA`, `PLATILAC JKP TROŠKOVA` | `lib/features/predmeti/presentation/segments/narucilac_segment.dart` | Segment headings shown to user. | UI | Payer of goods/services and JKP costs. | CURRENT UI TERM | Segment class is internal `NarucilacSegment`, headings are `PLATILAC`. | Keep as display evidence; owner may later decide internal cleanup. |
| Platilac | `Platilac samostalno ostvaruje refundaciju` | `lib/features/predmeti/presentation/segments/finansije_segment.dart` | Refund option text. | UI / business logic | Payer refund responsibility. | CURRENT UI TERM | Field uses `_platilaciRefundira` and DB field `narucilacRefundira`. | Preserve display term; internal field cleanup needs separate task. |
| narucilac | `NarucilacSegment` | `lib/features/predmeti/presentation/segments/narucilac_segment.dart` | Widget/class/file naming. | source model | Internal name for payer segment. | INTERNAL CODE TERM | Class name remains `NarucilacSegment`; visible headings are `PLATILAC`. | Do not rename now; future source cleanup only with compatibility plan. |
| narucilac | `narucilacRefundira` | `lib/core/database/tables/predmeti_table.dart`, `lib/core/utils/json_export_import.dart`, finance/PDF code | Database/export field and logic. | database field / JSON / business logic | Payer refund flag. | INTERNAL CODE TERM | Field is exported and consumed by finance/PDF logic. | Treat as compatibility-sensitive. |
| NARUCILAC | `NARUCILAC` | `lib/core/database/database.dart`, `predlosci_dokumenata_table.dart` | Document template segment ids. | database seed / source model | Internal segment id. | INTERNAL CODE TERM | Seeded segment arrays contain `NARUCILAC`. | Do not change without migration/template audit. |
| Naručilac | `Naručilac opreme i usluga`, `Naručilac troškova JKP` | `lib/core/database/tables/predmeti_table.dart`, `podesavanja_screen.dart` | Table comments and settings text. | database/source/docs-in-code | Older/orderer wording for payer data. | MIXED / OWNER REVIEW REQUIRED | Comments and setting text retain `Naručilac`; payer UI uses `Platilac`. | Owner should decide if visible settings wording should become `Platilac`. |
| NARUČILAC | `NARUČILAC IME`, `NARUČILAC JMBG`, etc. | `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart` | Full audit-style PREDMET snapshot labels. | PDF/export | Legacy/internal field labels inside snapshot export. | PDF LEGACY / MIXED | Section title is `PLATILAC`, field labels remain `NARUČILAC`. | Future PDF cleanup task if owner wants full terminology alignment. |
| PLATILAC | `PLATILAC: ...` | `lista_pdf_data_builder.dart`, `racun_pdf_export.dart`, `predracun_pdf_export.dart`, `specifikacija_troskova_pdf_export.dart` | Main payer PDF sections. | PDF/export | Payer display section. | CURRENT PDF TERM | Main commercial/list PDFs use payer terminology. | Preserve. |
| payer | `payerSection`, `_buildPayerSection` | PDF builders/exporters | English internal helper names. | source model | Internal English payer abstraction. | INTERNAL CODE TERM | Helper names align with `Platilac`. | No action. |
| klijent | `klijent` / `Klijent` | No current PREDMET UI/PDF/business-party source evidence found in inspected non-generated source. | N/A | unknown/docs-only | Not established as payer/orderer term. | NON-CANONICAL FOR PREDMET PARTY | Prior public reports warn not to introduce it as replacement. | Keep forbidden as replacement. |
| customer | `customerId`, `customerLabel`, `Customer` | entitlement parser/model/tests and local docs | License/customer metadata. | licensing/test/docs | Commercial/license customer, not PREDMET payer. | DOCS / LICENSING TERM | License tests use fake `customer-1`; docs discuss customer app/build/license. | Keep separate from PREDMET terminology. |

## Question 5/36 Status

Current status: PARTIALLY RESOLVED, OWNER REVIEW REQUIRED.

`naručilac` / `narucilac` is not cleanly one thing. It is currently:

- a current internal code/database/JSON/template term;
- a legacy or mixed PDF snapshot label;
- an older visible/settings/source comment term in some places;
- likely the historical naming layer behind the current visible `Platilac` surfaces.

It is not safe to declare `narucilac` fully obsolete because it remains in database/export/template logic. It is also not accurate to call it the current primary visible business term because current PREDMET payer UI and main payer PDFs use `Platilac`.

`klijent` remains non-canonical for PREDMET party meaning.

## Required Future Cleanup Boundary

Any cleanup must be a separate implementation task and must explicitly cover:

- source/widget/file names;
- database fields and migrations;
- JSON keys/backward compatibility;
- seeded document segment ids;
- PDF snapshot labels vs main PDF labels;
- settings UI text;
- tests and import/export compatibility.
