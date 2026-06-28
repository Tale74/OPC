# OPC Business Domain And Flow Map

Status: public domain/flow map for OPC business logic.

This document is documentation only. It maps domains, ownership, dependencies, source files, tests, and text flows. It does not define implementation work.

## 1. Domain List

| Domain | Data owner | Main current implementation evidence |
| --- | --- | --- |
| PREDMET core | `Predmeti` table | `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart` |
| Deceased person data | PREDMET columns | `preminulo_lice_segment.dart`; PDF builders |
| Platilac / narucilac | PREDMET `naru*` fields | `narucilac_segment.dart`; terminology docs |
| JKP payer | PREDMET `jkp*` fields | `narucilac_segment.dart`; PDF builders |
| Ceremony/cemetery | PREDMET ceremony fields | `ceremonija_segment.dart`; `business_policy_evaluator.dart` |
| Religious/display/parte | PREDMET display fields | `parte_segment.dart` |
| PIO/refund | PREDMET + settings | `finansije_segment.dart`; `podesavanja_screen.dart` |
| Finance/payment | PREDMET + IRIU | `FinancialTruthService`; PDF builders |
| IRIU/articles/services | `Iriu` rows | `iriu_table.dart`; core_v2 services |
| STANJE ROBE | stock/effect/consequence tables | `features/stanje_robe/*` |
| Contacts | `KontaktLica` rows | `kontakt_lica_table.dart`; `kontakt_lica_repository.dart` |
| Users/roles | `Korisnici` rows | `auth_repository.dart`; `session_service.dart` |
| Firma | `FirmaPodaci` singleton | `firma_podaci_table.dart`; `podesavanja_repository.dart` |
| Packages/licensing | entitlement payload/policy | `opc_entitlement_policy.dart`; license tests |
| JSON transfer | transfer utility/core | `json_export_import.dart`; `predmet_json_transfer_core.dart` |
| Backup/restore | transfer utility | `json_export_import.dart` |
| PDF/documents | PDF builders | `lib/features/predmeti/pdf/*` |
| Windows/Android parity | shared Dart source + adapters | manifest; `json_export_import.dart` |
| Future OPC Web/sync | policy only | manifest; stop-list |

## 2. Domain Ownership Of Data

- PREDMET owns case business truth.
- IRIU owns selected article/service rows for one PREDMET, while catalog owns catalog truth.
- Kontakt lica owns contact rows for one PREDMET.
- STANJE ROBE owns operational stock state and consequences, not PREDMET truth.
- FirmaPodaci owns editable firm display/business data but is not stable identity history by itself.
- Korisnici owns local users/roles; future stable firm/license identities are unresolved.
- JSON/PDF own transfer/rendering representations only, not master truth.

## 3. Domain Inputs

| Domain | Inputs |
| --- | --- |
| PREDMET | user creation/edit, import, lifecycle actions, adviser/session |
| Deceased person | user fields, anonymization rules, document display flags |
| Platilac/JKP | physical/legal payer fields, same-JKP flag, refund choice |
| Ceremony | cemetery, ceremony, opelo, burial/urn/out-of-country/reception fields |
| IRIU | catalog config, business policy evaluation, user row edits |
| STANJE ROBE | IRIU selections, entitlement, operational toggle, stock quantities |
| Finance | IRIU financial truth, PIO refund, advance, JKP costs, discount |
| JSON | PREDMET, IRIU, contacts, metadata, stock consequence block |
| Backup | broad database tables |
| PDF | PREDMET, IRIU, firm, adviser, settings |

## 4. Domain Outputs

| Domain | Outputs |
| --- | --- |
| PREDMET | lifecycle state, version, logs, JSON/PDF/list/report source data |
| IRIU | selected rows, financial basis, operational documents, stock consequences |
| STANJE ROBE | applied/restored/unresolved/superseded consequence records |
| Finance | displayed/payment document totals |
| JSON | single-PREDMET transfer or full backup file |
| PDF | PREDMET-derived documents |
| Auth/users | session role and adviser metadata |
| Entitlement | visible modules/settings/document actions |

## 5. Domain Dependencies

- PREDMET depends on local users for adviser/created/modified metadata.
- IRIU depends on PREDMET and catalog config.
- STANJE ROBE depends on entitlement, settings toggle, and IRIU rows.
- Finance depends on IRIU rows, PREDMET finance/refund fields, and settings.
- PDF depends on PREDMET, IRIU, FirmaPodaci, and adviser/user data.
- JSON depends on PREDMET, IRIU, contacts, and selected STANJE ROBE consequence state.
- Future Web/sync depends on unresolved identity, replica, version, and data ownership rules.

## 6. Domain Source Files / Modules

| Domain | Source files/modules |
| --- | --- |
| PREDMET core | `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lista_predmeta_screen.dart` |
| Deceased person | `preminulo_lice_segment.dart`; `predmeti_table.dart`; PDF builders |
| Platilac/JKP | `narucilac_segment.dart`; `predmeti_table.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart` |
| Ceremony | `ceremonija_segment.dart`; `business_policy_evaluator.dart`; `business_policy_models.dart` |
| Parte/citulje | `parte_segment.dart`; `predmeti_repository.dart`; `iriu_table.dart`; entitlement policy |
| IRIU | `iriu_table.dart`; `iriu_repository.dart`; `core_v2/business_policy/*`; `core_v2/services/*`; `core_v2/rules/*` |
| STANJE ROBE | `features/stanje_robe/application/*`; `features/stanje_robe/data/*`; `core/database/tables/stanje_robe_*` |
| Contacts | `kontakt_lica_table.dart`; `kontakt_lica_repository.dart` |
| Users | `korisnici_table.dart`; `auth_repository.dart`; `session_service.dart`; auth presentation |
| Firma | `firma_podaci_table.dart`; `podesavanja_repository.dart`; `podesavanja_screen.dart` |
| Entitlement | `core/entitlements/*` |
| JSON/backup | `core/utils/json_export_import.dart`; `core/json_transfer/predmet_json_transfer_core.dart`; `core/format/app_filename_format.dart` |
| PDF | `features/predmeti/pdf/*` |

## 7. Domain Tests

| Domain | Tests |
| --- | --- |
| JSON/backup/contacts/IRIU/stock transfer | `test/json_transfer_regression_test.dart` |
| STANJE ROBE | `test/stanje_robe_operational_toggle_test.dart` |
| IRIU business policy | `test/business_policy_iriu_critical_scenarios_test.dart` |
| Licensing/packages | `test/opc_local_license_parser_test.dart`; `test/package_downgrade_migration_test.dart` |
| Settings/license display | `test/podesavanja_screen_smoke_test.dart` |
| Auth/login | `test/login_screen_smoke_test.dart` |
| PREDMET list smoke | `test/lista_predmeta_screen_smoke_test.dart` |

Known test gaps: full PREDMET lifecycle UI, finance calculations, PDF outputs, parte/citulje, Windows/Android runtime parity, firm identity guard.

## 8. Domain Documents / PDF / JSON Effects

- PREDMET fields feed all PDFs and JSON.
- Platilac/JKP fields feed payer sections and financial documents.
- Ceremony fields feed documents, IRIU policy, parte display, and scheduling.
- IRIU feeds finance, operational documents, JSON, and STANJE ROBE.
- Contacts feed JSON transfer and may appear in operational context.
- FirmaPodaci feeds PDFs/settings/backup and future identity risk.
- Entitlement controls visibility/actions but must not change PREDMET truth.

## 9. Domain Web / Sync Sensitivity

High sensitivity:

- PREDMET identity and firm scope;
- JSON import/replace;
- backup/restore;
- version conflicts;
- FirmaPodaci history;
- users/advisers/admin stable identity;
- STANJE ROBE consequences;
- package/role enforcement;
- offline/local replica rules.

Future OPC Web/sync must preserve business meaning and must not create a hidden server-master database.

## 10. Text Flow Diagrams

### PREDMET Creation

```text
User selects new PREDMET
-> PredmetiRepository.kreirajPredmet(savetnikId)
-> generated brojPredmeta + OTVOREN + verzija 1 + metadata
-> inicijalizujIriu(predmetId)
-> UI opens PredmetScreen
-> PREDMET becomes editable business truth
```

### PREDMET Review / Confirmation

```text
Open PREDMET edits
-> segment updates write PREDMET fields
-> Sacuvaj records save snapshot and modified metadata
-> Pregled i potvrda / close action
-> zatvoriPredmet
-> compare current snapshot to last confirmed close snapshot
-> if changed after prior confirmation, increment verzija
-> write confirmed-close snapshot + work-cycle log
-> status ZATVOREN
```

### PREDMET JSON Export

```text
User exports single PREDMET
-> read PREDMET + IRIU + kontakt lica + unresolved stock consequences
-> build OPC_PREDMET root metadata
-> include sourceExpectations
-> include predmet / iriu / kontaktLica
-> include unresolved consequence block when safe
-> generate human-readable filename
-> file is transfer artifact, not identity source
```

### PREDMET JSON Import

```text
User imports JSON
-> parse supported OPC_PREDMET / legacy format
-> normalize candidate PREDMET metadata
-> if imported brojPredmeta is empty: create new local PREDMET
-> else find local PREDMET rows with same brojPredmeta
-> zero matches: create new local PREDMET
-> one match: show keep / replace / cancel conflict choice
-> multiple matches: block unsafe replacement
```

### PREDMET Replace

```text
User chooses replace imported
-> keep local technical PREDMET id
-> reconcile STANJE ROBE replacement effects
-> delete local log/kontakt/IRiU/lifecycle rows for that PREDMET
-> replace PREDMET row with imported business state under local id
-> insert imported IRIU rows under local id
-> insert imported kontakt lica under local id
-> apply imported unresolved stock consequence transfer if present
```

### Backup / Restore

```text
User exports full backup
-> collect broad database sections
-> write OPC_BACKUP root metadata

User imports full backup
-> parse supported backup payload
-> require destructive confirmation
-> delete/replace broad local tables
-> import backup sections
-> current policy requires PIB/MB mismatch block, but implementation proof is missing
```

### Stock Consequence Flow

```text
IRIU selected/changed for covered category
-> entitlement and operational toggle checked
-> stock lifecycle service evaluates quantity
-> enough stock: apply effect and reduce/restore stock as appropriate
-> insufficient stock: record unresolved consequence
-> PREDMET close can be blocked by unresolved consequence
-> single-PREDMET JSON may transfer unresolved consequence context, not warehouse stock quantities
```

### Version / Change-Log Future Flow

```text
Current: PREDMET close can increment verzija and write logs/snapshots
-> Future audit: verify all business-relevant changes and version survival
-> Future design: define change-log source/model
-> Future UI: show version/change-log overview in Pregled i potvrda
-> Future import: show version conflict matrix warnings while preserving keep / replace / cancel
```
