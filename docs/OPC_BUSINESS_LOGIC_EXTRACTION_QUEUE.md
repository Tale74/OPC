# OPC Business Logic Extraction Queue

Status: active extraction queue before future Web, sync, identity, import/restore, or storage architecture.

This document lists business rules that must be extracted or technically audited before implementation. It is not an implementation spec.

| Area | Existing rule / question | Status | Required next action |
| --- | --- | --- | --- |
| Same `PREDMET` conflict rules | Current single-`PREDMET` import conflict flow uses `brojPredmeta`; replacement must not silently duplicate or corrupt related data. | PARTIALLY EXTRACTED | Extract exact conflict UI, replace/keep/cancel behavior, and related-data handling. |
| PREDMET lifecycle | Open/closed/edit, save/autosave, confirmed-close, exit/back, and reopen semantics exist and must be preserved. | EXISTING BUSINESS LOGIC EXTRACTION REQUIRED | Produce lifecycle state machine with allowed actions and effects. |
| PREDMET opener/signature | Future identity must distinguish current display name, stable internal user/license id, role, and historical PREDMET signature. | TECHNICAL AUDIT REQUIRED | Audit current user/session/PREDMET fields. |
| JSON single `PREDMET` transfer | Single `PREDMET` JSON is separate from full backup and may carry only approved case/business/consequence data. | PARTIALLY EXTRACTED | Define compatibility matrix and allowed blocks. |
| Full database/backup JSON | Full backup/import is broader recovery behavior and can be destructive; identity guard is missing. | TECHNICAL AUDIT REQUIRED | Design PIB/Matični broj and repository/firma guard. |
| FirmaPodaci history | `FirmaPodaci` is editable/hybrid and must not be the only stable identity. | TECHNICAL AUDIT REQUIRED | Design history and continuity model. |
| Platilac/narucilac compatibility | `Platilac` is current display term; `narucilac` remains internal code/database/JSON/template terminology. | OWNER REVIEW REQUIRED | Decide whether future cleanup preserves compatibility names or migrates them. |
| PDF snapshot labels | Main PDFs use `PLATILAC`; snapshot/export labels still include `NARUČILAC`. | OWNER REVIEW REQUIRED | Decide PDF cleanup separately. |
| STANJE ROBE consequence rules | Inventory must not become parallel PREDMET truth; unresolved consequences and close-block behavior must be explicit. | PARTIALLY EXTRACTED | Extract user-visible warning/confirmation/close-block and transfer rules. |
| STANJE ROBE import/restore | Current local rules separate single-PREDMET JSON from warehouse quantities and full backup/import behavior. | TECHNICAL AUDIT REQUIRED | Define full backup/import stock handling and reconciliation. |
| KATALOG selected item truth | KATALOG owns catalog truth; PREDMET/IRiU selected snapshot fields remain business-visible. | PARTIALLY EXTRACTED | Document snapshot vs catalog identity and update behavior. |
| Windows/Android parity | Platform UX may differ, business rules must remain equivalent. | EXTRACTED PUBLIC SUMMARY | Keep parity checks in future task acceptance criteria. |
| OPC Web local data behavior | Future Web must preserve local ownership, PREDMET truth, manual transfer, and no implicit server-master database. | TECHNICAL ARCHITECTURE AUDIT REQUIRED | Research architecture options before implementation. |
| Licensing/package behavior | Entitlement/package logic must not change `PREDMET` truth and must fail closed. | PARTIALLY EXTRACTED | Payment/access gate before any implementation. |
| Private/public data boundary | Public repo must exclude private/customer/runtime/export data. | EXTRACTED PUBLIC SUMMARY | Keep as mandatory review item. |

## Open Queue Summary

TECHNICAL AUDIT REQUIRED:

- Administrator/Savetnik stable internal ID;
- PREDMET opener signature model;
- JSON single `PREDMET` vs full database backup distinction;
- identity/import/restore guard design;
- `FirmaPodaci` history implementation;
- `narucilac` internal compatibility cleanup.

TECHNICAL ARCHITECTURE AUDIT REQUIRED:

- OPC Web local data architecture;
- browser storage vs database outside browser;
- offline/local-replica behavior;
- current internet technical research for OPC Web implementation options.

EXISTING BUSINESS LOGIC EXTRACTION REQUIRED:

- same `PREDMET` conflict rules;
- complete PREDMET lifecycle state machine;
- local app rules OPC Web must preserve.

OWNER REVIEW REQUIRED:

- which local docs should eventually be fully promoted;
- conflicts between local docs and public docs;
- final canonical implementation terminology for `Platilac`/`narucilac`;
- PDF snapshot label cleanup decision.
