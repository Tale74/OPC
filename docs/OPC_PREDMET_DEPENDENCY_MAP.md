# OPC PREDMET Dependency Map

Status: public dependency map / audit-only documentation.

## 1. Purpose

This map shows how PREDMET fields and choices feed later workflow points, documents, JSON, IRiU, STANJE ROBE, finance, PIO/refund, parte/čitulje, and review/confirmation.

## 2. Dependency Legend

Dependency types: `required-before`, `affects-options`, `affects-document`, `affects-finance`, `affects-stock`, `affects-refund`, `affects-review`, `display-only`, `independent`.

Classifications: `SOURCE-CONFIRMED`, `SOURCE-INFERRED`, `TEST-CONFIRMED`, `DOCUMENTED POLICY`, `OWNER DECISION`, `TECHNICAL AUDIT REQUIRED`, `UNCLEAR / NEEDS OWNER REVIEW`.

## 3. Dependency Table Grouped By Source Point

| Source point | Source field/choice | Dependency type | Target point/output | Rule | Evidence | Classification |
| --- | --- | --- | --- | --- | --- | --- |
| Opening/basic metadata | `brojPredmeta` | affects-review | review, JSON import conflict | Current import conflict lookup uses same `brojPredmeta`; owner says future identity must be firm-scoped. | `predmeti_repository.dart`; `json_export_import.dart`; owner report | `SOURCE-CONFIRMED / OWNER DECISION` |
| Opening/basic metadata | `verzija` | affects-review | review, PDF/JSON/version policy | Review shows version; close may increment version; future conflict matrix not implemented. | `predmet_screen.dart`; `predmeti_repository.dart` | `SOURCE-CONFIRMED / IMPLEMENTATION REQUIRED` |
| Preminulo lice | `ime`, `prezime` | required-before | close/review | PREDMET with neither first nor last name cannot remain/close safely. | `predmet_screen.dart`; `lista_predmeta_screen.dart` | `SOURCE-CONFIRMED` |
| Preminulo lice | name/title/nickname/display flags | affects-document | parte/PDF/JSON | Identity and display fields feed documents and JSON; filename person name is UX only. | `preminulo_lice_segment.dart`; `predmeti_table.dart`; PDF source | `SOURCE-CONFIRMED / OWNER CLARIFICATION` |
| Činjenice o smrti | `mestoSmrti`, `uzrokSmrti` | affects-options | IRiU/services | Business policy normalizes death place and evaluates hospital/infectious/violent/undefined conditions. | `preminulo_lice_segment.dart`; `business_policy_evaluator.dart` | `SOURCE-CONFIRMED` |
| Činjenice o smrti | `datumSmrti`, death facts | affects-document | PDFs/JSON | Death facts are serialized and rendered. | `predmeti_table.dart`; `predmet_pdf_snapshot_export.dart`; `json_export_import.dart` | `SOURCE-CONFIRMED` |
| Statusi | `radniStatus` | affects-refund | Finansije / PIO | Pensioner flags derive from work status; Serbian pensioner context makes refund relevant. | `preminulo_lice_segment.dart`; `finansije_segment.dart` | `SOURCE-CONFIRMED` |
| Statusi | spouse fields | affects-options | Platilac/JKP payer | Spouse can be reused as payer/JKP physical-person subtype. | `narucilac_segment.dart`; `preminulo_lice_segment.dart` | `SOURCE-CONFIRMED` |
| Platilac | `naruTip`, physical/legal fields | affects-document | payment PDFs, snapshot, JSON | Visible payer data feeds documents and JSON; internal fields remain `naru*`. | `narucilac_segment.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Platilac | `naruIstiZaJkp` | affects-finance | JKP payer and financial display | Same-payer switch copies payer values into JKP fields or clears JKP fields when unchecked. | `narucilac_segment.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Platilac | contact rows | affects-document | JSON and contact records | Contact rows are child rows and are exported/replaced with PREDMET. | `kontakt_lica_table.dart`; `json_transfer_regression_test.dart` | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Ceremonija | `vrstaCeremonije` | affects-options | opelo, IRiU policy | Ceremony type controls opelo availability and business policy conditions such as cremation. | `ceremonija_segment.dart`; `business_policy_evaluator.dart` | `SOURCE-CONFIRMED` |
| Ceremonija | `tipGroblja`, `groblje` | affects-options | IRiU/policy/documents | Cemetery type feeds local/gradsko policy and document text. | `business_policy_evaluator.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Ceremonija | `datumCeremonije` | affects-review | auto-finish/anonymization availability | Repository can auto-finish past-ceremony PREDMET; anonymization availability uses ceremony date. | `predmeti_repository.dart` | `SOURCE-CONFIRMED` |
| Ceremonija | `opelo`, `opeloMesto`, `vremeOpela`, `vremeIspracaja` | affects-document | lista/nalog documents | Document builders render opelo/ispraćaj details conditionally. | `lista_pdf_data_builder.dart`; `nalog_za_opremanje_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Ceremonija | out-of-country/reception flags | affects-document | PDFs/JSON | Fields are conditionally displayed/exported. | `ceremonija_segment.dart`; `lista_pdf_data_builder.dart`; `json_export_import.dart` | `SOURCE-CONFIRMED` |
| Parte | `simbol`, `pismo`, `parteIme`, `ozaloseni` | affects-document | parte/PDF/JSON | Parte display data derives from PREDMET fields. | `parte_segment.dart`; `predmeti_table.dart` | `SOURCE-CONFIRMED` |
| Roba i usluge | IRiU rows | affects-finance | Finansije and financial PDFs | Positive active rows form `ROBA I USLUGE` financial truth. | `financial_truth_service.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Roba i usluge | covered IRiU categories | affects-stock | STANJE ROBE | Covered categories create apply/restore/unresolved stock consequences. | `stanje_robe_lifecycle_service.dart`; stock tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Roba i usluge | IRiU rows | affects-document | nalog/list/PDF/JSON | IRiU rows are rendered and serialized. | `iriu_table.dart`; `json_export_import.dart`; PDF builders | `SOURCE-CONFIRMED` |
| Finansije | `narucilacRefundira` | affects-refund | payment total/PDF | If payer refunds independently, refund does not reduce payable amount. | `finansije_segment.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Finansije | `jkpPlacaSamostalno` | affects-finance | payment total/PDF | JKP cost is excluded from payable total when JKP pays independently. | `finansije_segment.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Finansije | `avans`, `popust`, `troskoviJkp` | affects-finance | final payment display | Values affect displayed payment rows and final payable amount. | `finansije_segment.dart`; `predmet_pdf_snapshot_export.dart` | `SOURCE-CONFIRMED / TEST GAP` |
| Dokumenti | entitlement policy | affects-options | visible document actions | Entitlement policy controls visible PDF/JSON actions. | `predmet_screen.dart`; `opc_entitlement_policy.dart` | `SOURCE-CONFIRMED` |
| Pregled i potvrda | `SAČUVAJ` | affects-review | log/save state | Save writes save snapshot and modified metadata. | `predmet_screen.dart`; `predmeti_repository.dart` | `SOURCE-CONFIRMED` |
| Pregled i potvrda | `ZATVORI` | affects-review | status/version/logs | Close sets `ZATVOREN`, writes confirmed snapshot, and may increment version. | `predmeti_repository.dart` | `SOURCE-CONFIRMED` |
| Import/replace | replace choice | affects-review | all PREDMET points | Replacement keeps local id and replaces PREDMET, IRiU, contacts, logs/lifecycle data. | `json_export_import.dart`; `predmeti_repository.dart`; JSON tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |

## 4. Dependencies Into Documents / PDF

- Deceased identity, death facts, payer, JKP, ceremony, opelo, IRiU, finance, FirmaPodaci, adviser, and version/status fields feed PDFs.
- Evidence: `lib/features/predmeti/pdf/*`; `predmet_screen.dart`; `lista_pdf_data_builder.dart`.
- Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 5. Dependencies Into JSON

- Single-PREDMET JSON serializes PREDMET, IRiU, contacts, metadata, and safe unresolved STANJE ROBE consequence transfer.
- Evidence: `json_export_import.dart`; `predmet_json_transfer_core.dart`; `test/json_transfer_regression_test.dart`.
- Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 6. Dependencies Into IRiU / Services

- Death/ceremony/cemetery facts feed `BusinessPolicyEvaluator`.
- New PREDMET initializes IRiU rows from catalog config.
- Evidence: `predmeti_repository.dart`; `business_policy_evaluator.dart`; `business_policy_iriu_critical_scenarios_test.dart`.

## 7. Dependencies Into STANJE ROBE

- Covered IRiU categories and operational availability feed stock lifecycle effects.
- Evidence: `stanje_robe_lifecycle_service.dart`; `stanje_robe_operational_availability.dart`; `test/stanje_robe_operational_toggle_test.dart`.

## 8. Dependencies Into Finance / Payment

- IRiU financial truth, refund status, JKP costs/self-pay, advance, discount, and payment notes feed payment display.
- Evidence: `financial_truth_service.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`.

## 9. Dependencies Into PIO / Refund

- Status point produces pensioner/refund flags; settings provide refund amount; finance applies payer refund choice.
- Evidence: `preminulo_lice_segment.dart`; `podesavanja_screen.dart`; `finansije_segment.dart`.

## 10. Dependencies Into Parte / Čitulje

- Parte depends on deceased identity/display flags and ceremony context.
- Čitulje are related to IRiU/category/entitlement but exact workflow remains `TECHNICAL AUDIT REQUIRED`.

## 11. Dependencies Into Review / Confirmation

- All points feed final review by saved/unsaved state and business completeness.
- Minimum identity and STANJE ROBE unresolved blockers can affect close.
- Version/log behavior depends on save/close snapshots.

## 12. Independent Points / Fields

- Payer can be entered before ceremony, though documents combine both.
- Finance payment notes can be entered independently but final totals depend on IRiU/refund/JKP.
- Parte fields are mostly independent of finance.
- Document generation is an output action and should not become master truth.

## 13. Unclear Dependencies Requiring Owner Review

- Exact duplicate `brojPredmeta` creation handling.
- Exact čitulje workflow and data source.
- Exact required fields for business-complete PREDMET beyond minimum close guard.
- Exact future version warning wording and change-log content.
