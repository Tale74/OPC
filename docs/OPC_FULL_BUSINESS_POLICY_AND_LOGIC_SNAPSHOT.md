# OPC Full Business Policy And Logic Snapshot

Status: public business atlas / audit snapshot.

This document is documentation only. It records current OPC business policy, source/test evidence, gaps, and preservation rules. It does not authorize implementation, schema, UI, PDF, JSON, Web, sync, storage, payment, role, package, or migration changes.

## 1. Purpose And Scope

Purpose: give Logos and future tasks a complete repository-grounded snapshot of OPC as a product, across business domains and flows.

Scope: public docs, task reports, source files under `lib/`, and tests under `test/` were inspected as evidence. No source or test behavior was changed.

## 2. Evidence Classification Legend

Allowed labels used here:

- `OWNER DECISION`: explicit owner decision recorded in public docs/task reports.
- `OWNER CLARIFICATION`: explicit owner clarification, usually about meaning or future-safe interpretation.
- `OWNER-REPORTED BEHAVIOR`: owner-reported behavior not independently proven by source/test/runtime in this snapshot.
- `DOCUMENTED POLICY`: public docs define the rule.
- `SOURCE-CONFIRMED`: source code supports the rule or current behavior.
- `TEST-CONFIRMED`: tests cover the rule or behavior.
- `RUNTIME-CONFIRMED`: manual runtime evidence exists; not newly produced here.
- `POLICY EXISTS / IMPLEMENTATION NOT FOUND`: policy exists but inspected source did not prove implementation.
- `IMPLEMENTATION EXISTS / POLICY NOT DOCUMENTED`: source exists but policy needs documentation.
- `PARTIALLY IMPLEMENTED`: part exists, gaps remain.
- `NOT IMPLEMENTED`: no implementation evidence found.
- `IMPLEMENTATION REQUIRED`: owner/policy requires future implementation.
- `TECHNICAL AUDIT REQUIRED`: deeper source/runtime/design audit required before implementation.
- `FACT CHECK REQUIRED`: evidence or owner meaning needs confirmation.
- `OWNER DECISION REQUIRED`: owner decision still needed.
- `TEST GAP`: tests do not sufficiently cover the rule.
- `RUNTIME GAP`: runtime smoke/manual parity not confirmed.
- `CONTRADICTION FOUND`: documented or source evidence conflicts.
- `UNCLEAR / NEEDS OWNER REVIEW`: evidence is ambiguous.

## 3. OPC Product Summary

OPC is a local-first Flutter/Dart product for organizing funeral ceremony cases through `PREDMET` as the central business truth for a firm that owns its own database.

Evidence:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` - `DOCUMENTED POLICY`
- `docs/OPC_OWNER_DECISION_REPORT.md` - `OWNER DECISION`
- `lib/core/database/database.dart`; `lib/core/database/tables/*.dart` - `SOURCE-CONFIRMED`

Windows and Android are equal runtime forms of the same product logic. Future `OPC Web` is complementary browser access, not a replacement and not an implicit server-master PREDMET database. `SaaS` is not primary product terminology.

## 4. Master Business Truth Model

`PREDMET` is the only master business truth. PDFs, JSON transfers, lists, statistics, reminders, IRIU rows, contacts, stock consequences, and documents derive from or organize around PREDMET.

Evidence:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 5. Business Domain Inventory

| Domain | Main ownership | Main evidence | Classification |
| --- | --- | --- | --- |
| PREDMET core | `Predmeti` table and `PredmetiRepository` | `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart` | `SOURCE-CONFIRMED` |
| Deceased person data | PREDMET columns | `predmeti_table.dart`; `preminulo_lice_segment.dart`; PDF builders | `SOURCE-CONFIRMED` |
| Platilac / narucilac | PREDMET `naru*` fields, visible Platilac surfaces | `narucilac_segment.dart`; `predmeti_table.dart`; terminology docs | `SOURCE-CONFIRMED / OWNER REVIEW REQUIRED` |
| JKP party | PREDMET `jkp*` fields and `naruIstiZaJkp` | `predmeti_table.dart`; `narucilac_segment.dart`; `lista_pdf_data_builder.dart` | `SOURCE-CONFIRMED` |
| Ceremony/cemetery | PREDMET ceremony columns | `predmeti_table.dart`; `ceremonija_segment.dart`; `business_policy_evaluator.dart` | `SOURCE-CONFIRMED` |
| Religious/display/parte | PREDMET `simbol`, `pismo`, `parteIme`, `ozaloseni` | `predmeti_table.dart`; `parte_segment.dart` | `SOURCE-CONFIRMED / TEST GAP` |
| PIO/refund/pensioner | PREDMET status/refund fields and settings | `predmeti_table.dart`; `finansije_segment.dart`; `podesavanja_screen.dart` | `SOURCE-CONFIRMED / TEST GAP` |
| Finance/payment | PREDMET finance fields and IRIU truth | `finansije_segment.dart`; `FinancialTruthService`; PDF builders | `SOURCE-CONFIRMED / TEST GAP` |
| IRIU/articles/services | `Iriu` table and core_v2 services | `iriu_table.dart`; `business_policy_iriu_critical_scenarios_test.dart` | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| STANJE ROBE | stock tables/repositories/lifecycle service | `stanje_robe_*`; `stanje_robe_operational_toggle_test.dart` | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Parte | PREDMET/IRiU derivative UI/document data | `parte_segment.dart`; `json_export_import.dart` | `SOURCE-CONFIRMED / TEST GAP` |
| Citulje | IRIU/document derivative area | `iriu_table.dart`; `parte_segment.dart`; rule inventory | `PARTIALLY IMPLEMENTED / TEST GAP` |
| Contacts | `KontaktLica` table/repository | `kontakt_lica_table.dart`; `kontakt_lica_repository.dart`; JSON tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Users/advisers/admins | `Korisnici` table/auth repository/session | `korisnici_table.dart`; `auth_repository.dart`; auth screens/tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Firma/FirmaPodaci | singleton firm table/settings | `firma_podaci_table.dart`; `podesavanja_repository.dart` | `PARTIALLY IMPLEMENTED` |
| Packages/licensing | entitlement policy and local license parser | `opc_entitlement_policy.dart`; license tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| JSON transfer | single PREDMET and full backup JSON | `json_export_import.dart`; `predmet_json_transfer_core.dart`; JSON tests | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Backup/restore | full backup import/export | `json_export_import.dart`; backup policy docs | `PARTIALLY IMPLEMENTED` |
| PDF/documents | PREDMET-derived PDF builders | `lib/features/predmeti/pdf/*` | `SOURCE-CONFIRMED / TEST GAP` |
| Windows/Android parity | shared Dart logic plus platform adapters | `json_export_import.dart`; manifest | `SOURCE-CONFIRMED / RUNTIME GAP` |
| Future Web/sync | policy only | manifest, stop-list, owner report | `DOCUMENTED POLICY / NOT IMPLEMENTED` |

## 6. End-To-End PREDMET Flow

Creation: UI creates PREDMET through `PredmetiRepository.kreirajPredmet`, generating `brojPredmeta`, status `OTVOREN`, `verzija = 1`, `businessScenarioId`, `sourceIdentity`, and adviser/user metadata. UI-created PREDMET then initializes IRIU rows.

Edit/save: segment edits update PREDMET fields; `sacuvajPredmet` records save snapshots in `logIzmena` and business-modified metadata when changed.

Review/close: `zatvoriPredmet` sets `ZATVOREN`, writes confirmed-close snapshots, and increments `verzija` only when a prior confirmed snapshot exists and business data changed.

Reopen: `otvoriPredmet` returns status to `OTVOREN`, preserving snapshots and writing work-cycle logs.

Finish/anonymize/delete: past ceremony can auto-finish to `ZAVRŠEN`; only finished PREDMET can be anonymized; delete removes/reconciles logs, contacts, IRIU, lifecycle decisions, stock consequences, and the PREDMET row.

Evidence: `lib/features/predmeti/data/predmeti_repository.dart`; lifecycle task report. Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 7. PREDMET Identity And Firm Scope

Current implementation:

- technical `id` is local DB identity;
- `brojPredmeta` is generated and used by current single-PREDMET JSON conflict lookup;
- no table-level unique constraint for `brojPredmeta` was confirmed;
- current import lookup uses `brojPredmeta` only.

Policy:

- `brojPredmeta` is unique only within a firm;
- future-safe identity/conflict scope is `PIB + Matični broj + brojPredmeta`;
- filename and deceased name are not canonical identity.

Evidence: `predmeti_table.dart`; `json_export_import.dart`; `docs/OPC_OWNER_DECISION_REPORT.md`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.

Classification: `SOURCE-CONFIRMED / OWNER DECISION / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## 8. Deceased Person Data Logic

PREDMET stores identity/personal/display fields: `ime`, `prezime`, `srednje`, maiden surname, `jmbg`, sex, birth/death dates/places, cause of death, address, parents, spouse, marital status, profession, title, rank, nickname, and flags controlling whether some values appear on parte.

Business-critical fields affect case identity, documents, ceremony context, parte, PDF output, JSON transfer, anonymization, and business policy evaluation. Display-only flags include fields such as `zanimanjeNaParti`, `titulaIspred`, `cinNaParti`, `srednjeNaParti`, and nickname display flags.

Evidence: `lib/core/database/tables/predmeti_table.dart`; `preminulo_lice_segment.dart`; `predmet_pdf_snapshot_export.dart`; `lista_pdf_data_builder.dart`; JSON export source.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 9. Platilac / Narucilac / JKP Party Logic

Visible business term: `Platilac`.

Internal compatibility layer: `naru*`, `narucilac*`, `NarucilacSegment`, and document/template internals remain in code/database/JSON. `klijent` is not canonical for PREDMET party meaning.

PREDMET stores payer as physical/legal person variants with identity/contact fields. JKP payer has a parallel set of `jkp*` physical/legal fields. `naruIstiZaJkp` indicates the primary payer is also JKP payer; `jkpPlacaSamostalno` affects financial responsibility. Owner clarification says payer/business parties may change their mind, so import conflict logic must preserve human keep/replace/cancel choice.

Evidence: `predmeti_table.dart`; `narucilac_segment.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`; `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`.

Classification: `SOURCE-CONFIRMED / OWNER CLARIFICATION / OWNER REVIEW REQUIRED`.

## 10. Ceremony And Cemetery Logic

PREDMET stores cemetery and ceremony facts: `groblje`, `tipGroblja`, `vrstaCeremonije`, ceremony date/time, `opelo`, opelo place/time, ispracaj time, grave/place fields, burial/placement type, urn fields, out-of-country burial fields, and reception-of-remains fields.

Business policy evaluator derives conditions such as cremation, hospital death, local/gradsko cemetery, international case, reception of remains, infectious/violent/undefined death override, and biohazard precautions.

Evidence: `predmeti_table.dart`; `ceremonija_segment.dart`; `business_policy_evaluator.dart`; `business_policy_iriu_critical_scenarios_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED` for IRIU policy scenarios; full UI/runtime ceremony validation remains `TEST GAP`.

## 11. Religious, Symbolic, And Document-Display Logic

PREDMET stores `simbol`, `pismo`, `parteIme`, and `ozaloseni`. These drive parte/document display and transfer with PREDMET data. `pismo` defaults differ between DB default and creation path: table default is `LATINICA`; `kreirajPredmet` sets `CIRILICA`.

Evidence: `predmeti_table.dart`; `predmeti_repository.dart`; `parte_segment.dart`; PDF builders.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 12. PIO / Refund / Pensioner Logic

PREDMET stores `radniStatus`, legacy pensioner flags, military honors, `posmrtnaPomoc`, `refundacijaPio`, `narucilacRefundira`, spouse-right fields, and notes. Settings store the refund amount, and UI/PDF logic uses refund context when calculating displayed payment state. Refund decreases amount only when active and when payer does not refund independently.

Evidence: `predmeti_table.dart`; `finansije_segment.dart`; `podesavanja_screen.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`; `package_downgrade_migration_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST GAP`, with migration/package tests touching refund fields.

## 13. Financial / Payment Logic

Financial fields are `avans`, `troskoviJkp`, `jkpPlacaSamostalno`, `popust`, `nacinPlacanja`, `napomenaPlacanja`, and `napomena`. IRIU positive active/suppressed state determines `ROBA I USLUGE` financial truth; PDF builders calculate refund, advance, JKP obligation, discount, and final payable display.

Evidence: `FinancialTruthService`; `iriu_truth_models.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 14. IRIU / Articles / Services Logic

IRIU rows belong to PREDMET and store catalog stable article id, internal category name, display name, quantity text, amount, checked state, and order. Catalog owns catalog truth; selected IRIU rows remain business-visible snapshots. New PREDMET initializes locked Blok 0 rows plus user catalog rows. Core v2 services evaluate required/suppressed/financial state and lifecycle effects.

Evidence: `iriu_table.dart`; `iriu_repository.dart`; `predmet_iriu_truth_service.dart`; `business_policy_evaluator.dart`; `business_policy_iriu_critical_scenarios_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 15. STANJE ROBE Logic

STANJE ROBE is operational consequence logic, not a second PREDMET truth. Operational availability depends on entitlement and settings toggle. Lifecycle service applies/restores/records effects for covered IRIU categories and records unresolved consequences when stock is insufficient. Single-PREDMET JSON can carry unresolved consequence transfer blocks, not warehouse quantities.

Evidence: `stanje_robe_lifecycle_service.dart`; `stanje_robe_operational_availability.dart`; `stanje_robe_repository.dart`; `stanje_robe_posledice_repository.dart`; `json_export_import.dart`; `stanje_robe_operational_toggle_test.dart`; `json_transfer_regression_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / DOCUMENTED POLICY`.

## 16. Parte Logic

Parte is a derivative of PREDMET fields such as symbol, script, display name, ceremony time, and mourners. It must remain faithful to PREDMET and must not become independent source of truth. Advanced parte package/add-on gating exists in entitlement policy, but exact feature coverage needs separate audit.

Evidence: `parte_segment.dart`; `predmeti_table.dart`; `opc_entitlement_policy.dart`; rule inventory.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 17. Citulje Logic

`cituljaP` appears as an initialized IRIU category. Entitlement policy includes `cituljeSaDeklaracijom`. Current public baseline treats citulje as PREDMET/IRiU derivatives, not independent truth. Exact citulje data dependencies and placeholder rules need deeper audit.

Evidence: `predmeti_repository.dart`; `iriu_table.dart`; `opc_entitlement_policy.dart`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.

Classification: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED / TEST GAP`.

## 18. Contacts Logic

Contact persons are child rows of PREDMET with `blok`, name, phone, email, note, and order. Contacts are imported/exported with single-PREDMET JSON and are deleted/reinserted on replacement using the local PREDMET id. Anonymization redacts contact phone/email.

Evidence: `kontakt_lica_table.dart`; `kontakt_lica_repository.dart`; `predmeti_repository.dart`; `json_export_import.dart`; `json_transfer_regression_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 19. Users / Advisers / Administrators Logic

Current app has local `Korisnici` with name, role `ADMINISTRATOR`/`SAVETNIK`, PIN hash, active flag, creation date, session service, first admin creation, user management, and administrator-only controls in some modules. PREDMET stores `savetnikId`, `createdByKorisnikId`, and `lastBusinessModifiedByKorisnikId`. Stable cross-device firm/license identity is not implemented.

Evidence: `korisnici_table.dart`; `auth_repository.dart`; `session_service.dart`; `korisnici_screen.dart`; `login_screen_smoke_test.dart`; `stanje_robe_operational_toggle_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 20. Firma / FirmaPodaci Logic

`FirmaPodaci` is singleton-like firm data with name, address, PIB, MB, activity code, phone, responsible person, email, website, and logo. It is editable settings data. Owner policy says it is important but hybrid/editable; stable identity and history are not implemented and cannot rely only on editable display fields.

Evidence: `firma_podaci_table.dart`; `podesavanja_repository.dart`; `podesavanja_screen.dart`; owner report; backup policy summary.

Classification: `PARTIALLY IMPLEMENTED / OWNER DECISION / IMPLEMENTATION REQUIRED`.

## 21. Packages / Licensing Logic

Canonical packages are `Osnovni`, `Srednji`, `Potpuni`; code enum names are `osnovni`, `srednji`, `potpun`. Entitlement policy controls modules, settings visibility, document actions, add-ons, and fail-closed fallback. `saas` exists as internal source kind/cleanup candidate, not product terminology. Payment/subscription implementation remains blocked.

Evidence: `opc_entitlement_policy.dart`; `opc_local_license_parser.dart`; `opc_local_license_parser_test.dart`; `package_downgrade_migration_test.dart`; `podesavanja_screen_smoke_test.dart`.

Classification: `OWNER DECISION / SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 22. JSON Transfer Logic

Single-PREDMET JSON:

- format `OPC_PREDMET`;
- carries root metadata including schema/version/export metadata;
- carries `predmet`, `iriu`, `kontaktLica`, and allowed unresolved STANJE ROBE consequence transfer block;
- imports as new PREDMET or same-`brojPredmeta` conflict;
- conflict UI preserves cancel / keep local / replace imported;
- replacement keeps local technical id and replaces related rows.

Full backup JSON:

- format `OPC_BACKUP`;
- carries broader database sections;
- import is destructive after explicit confirmation.

Gaps:

- firm-scoped `PIB + Matični broj + brojPredmeta` guard is policy but not confirmed implemented;
- `exportDatum` is metadata only;
- `verzija` conflict matrix is owner decision but not implemented.

Evidence: `json_export_import.dart`; `predmet_json_transfer_core.dart`; `app_filename_format.dart`; `json_transfer_regression_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## 23. Backup / Restore Logic

Full backup import/export exists and is distinct from single-PREDMET transfer. It exports broad tables and imports after destructive confirmation. Backup/restore firm identity mismatch block is owner policy but implementation was not confirmed in inspected source. STANJE ROBE backup payload has safety checks and tests.

Evidence: `json_export_import.dart`; `json_transfer_regression_test.dart`; `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`.

Classification: `PARTIALLY IMPLEMENTED / POLICY EXISTS / IMPLEMENTATION NOT FOUND / TEST-CONFIRMED`.

## 24. PDF / Document Output Logic

PDFs are derivatives of PREDMET, IRIU, firm, and user/adviser data. Existing PDF outputs include snapshot, list, predracun, racun, specifikacija troskova, nalog za opremanje, and related builders. Main payer PDFs use `PLATILAC`; snapshot PDF contains mixed legacy `NARUČILAC` labels. PDFs should not become independent business truth.

Evidence: `lib/features/predmeti/pdf/*`; `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`; rule inventory.

Classification: `SOURCE-CONFIRMED / DOCUMENTED POLICY / TEST GAP / OWNER REVIEW REQUIRED`.

## 25. Windows / Android Parity

Most business logic is shared Dart source. Platform differences are file access, storage adapters, screen size/layout, picker behavior, and OS APIs. JSON file read paths differ by platform, but format/repository behavior is shared. No fresh Windows/Android runtime smoke was run in this docs-only task.

Evidence: manifest; `json_export_import.dart`; shared `lib/`; tests under `test/`.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED / RUNTIME GAP`.

## 26. Future OPC Web / Sync Preservation Map

Future Web/sync must preserve:

- firm-owned database;
- no implicit server-master PREDMET database;
- PREDMET as master truth;
- firm-scoped conflict identity;
- explicit conflict user choice where business truth requires human decision;
- single-PREDMET JSON vs full backup distinction;
- version conflict matrix and `exportDatum` non-authority;
- STANJE ROBE as consequence logic only;
- package/role gates that do not alter PREDMET truth;
- Windows/Android/Web parity of business meaning.

Classification: `DOCUMENTED POLICY / OWNER DECISION / NOT IMPLEMENTED`.

## 27. Consistency Findings

- PREDMET master truth is consistent across manifest, owner report, rule inventory, source organization, JSON, and PDF derivative rules.
- Current source confirms a broad local PREDMET-centric model.
- `Platilac` visible terminology and internal `narucilac` compatibility names are mixed but documented.
- Single-PREDMET JSON and full backup JSON are distinct in source and policy.
- Version semantics are now policy-complete enough for future implementation design but not implemented.

## 28. Contradictions And Gaps

| Gap | Classification | Evidence |
| --- | --- | --- |
| Firm-scoped identity is required but current import conflict lookup uses `brojPredmeta` only. | `POLICY EXISTS / IMPLEMENTATION NOT FOUND` | owner report; `json_export_import.dart` |
| PIB/MB import/restore mismatch block is required but not source-confirmed. | `POLICY EXISTS / IMPLEMENTATION NOT FOUND` | backup policy; JSON source audit |
| `FirmaPodaci` is editable but stable history is required. | `IMPLEMENTATION REQUIRED` | firm table; owner report |
| `Platilac` vs internal `narucilac` remains mixed. | `UNCLEAR / NEEDS OWNER REVIEW` | terminology lineage; source |
| PREDMET change-log overview is required but not implemented. | `IMPLEMENTATION REQUIRED` | owner report; rule inventory |
| Runtime Windows/Android parity not freshly smoke-tested. | `RUNTIME GAP` | this task did not run runtime smoke |
| Finance/PDF/parte/citulje tests are incomplete. | `TEST GAP` | test inventory |

No new `CONTRADICTION FOUND` was promoted by this snapshot; known mixed terminology and policy/implementation gaps remain classified rather than resolved.

## 29. Policy-Only Rules

- Future OPC Web is complementary and not server-master.
- Firm-scoped identity is `PIB + Matični broj + brojPredmeta`.
- `exportDatum` is not freshness authority.
- Version conflict matrix preserves keep / replace / cancel unless later hard-block decision exists.
- PREDMET change-log overview belongs in future `Pregled i potvrda`.
- PIB/MB mismatch must block import/restore.

## 30. Source-Confirmed Rules

- PREDMET table holds central business fields.
- PREDMET lifecycle repository creates, saves, closes, reopens, auto-finishes, anonymizes, deletes, imports, and replaces.
- IRIU and contacts are PREDMET child rows.
- JSON transfer exports/imports single PREDMET and full backup formats.
- Entitlement policy fail-closes unsafe/unsupported payloads.
- PDF builders derive document data from PREDMET/IRiU/firma/user data.

## 31. Test-Confirmed Rules

- JSON import/export/replacement and STANJE ROBE consequence transfer behavior: `test/json_transfer_regression_test.dart`.
- STANJE ROBE operational toggle, consequences, and admin restrictions: `test/stanje_robe_operational_toggle_test.dart`.
- IRIU business policy critical scenarios: `test/business_policy_iriu_critical_scenarios_test.dart`.
- License parser/fail-closed and package migration behavior: `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart`.
- Smoke tests for login, settings, and PREDMET list: `test/login_screen_smoke_test.dart`; `test/podesavanja_screen_smoke_test.dart`; `test/lista_predmeta_screen_smoke_test.dart`.

## 32. Runtime Gaps

- No fresh Windows runtime smoke.
- No fresh Android runtime smoke.
- Conflict dialog behavior is source-confirmed, not runtime-confirmed here.
- PDF visual output not freshly rendered.
- Full end-to-end UI PREDMET lifecycle smoke not freshly run.

## 33. Owner-Decision Gaps

- final internal cleanup strategy for `narucilac`/`Platilac`;
- whether UI-created duplicate `brojPredmeta` should be blocked or regenerated;
- exact user-facing warning wording for version conflict matrix;
- exact PREDMET change-log content and retention;
- exact hard-block policy if owner later wants any version-based block.

## 34. Technical Audit Queue

- firm identity metadata in single-PREDMET JSON;
- PIB/MB guard implementation design;
- FirmaPodaci history;
- PREDMET version increment coverage;
- import/export/replace version survival;
- `Pregled i potvrda` suitability for version/change-log display;
- finance calculation tests;
- PDF terminology cleanup plan;
- citulje full rule extraction;
- Windows/Android runtime parity smoke.

## 35. Implementation Stop-List Summary

Blocked until explicit tasks and gates:

- Web runner/backend/API/sync/storage;
- database migrations and firm identity constraints;
- import/restore guard implementation;
- version comparator/hard-block UI;
- change-log DB/model/UI;
- JSON schema changes;
- filename-generation changes;
- payment/subscription/licensing implementation;
- role architecture implementation;
- terminology renames across source/database/PDF/JSON.

Evidence: `docs/OPC_IMPLEMENTATION_STOP_LIST.md`.

## 36. Recommended Next Steps

Recommended next task: `OPC TECHNICAL AUDIT - FIRM IDENTITY GUARD AND JSON/BACKUP RESTORE IMPLEMENTATION GAP`.

Reason: the largest release-safety gap is that owner policy requires firm-scoped identity and PIB/MB mismatch blocking, while current public evidence does not prove implementation. This must be resolved before Web/sync, broader transfer, or version comparator implementation.
