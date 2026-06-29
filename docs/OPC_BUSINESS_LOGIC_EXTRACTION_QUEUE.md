# OPC Business Logic Extraction Queue

Status: active extraction queue before future Web, sync, identity, import/restore, or storage architecture.

This document lists business rules that must be extracted or technically audited before implementation. It is not an implementation spec.

| Area | Existing rule / question | Status | Required next action |
| --- | --- | --- | --- |
| Same `PREDMET` conflict rules | Single-`PREDMET` import conflict flow uses trimmed non-empty `brojPredmeta`; one local match opens keep/replace/cancel UI; multiple local matches block replacement; replacement keeps local technical `id` and replaces connected IRIU/contact rows. Owner decision: future safe conflict scope is firm identity plus `brojPredmeta`, not globally unique `brojPredmeta`. | PARTIALLY EXTRACTED | Still extract runtime-confirmed Windows/Android UI behavior, non-import duplicate creation behavior, and firm-scoped conflict guard design. |
| PREDMET lifecycle | Creation, open/edit, save snapshot, confirmed close, reopen-for-edit, auto-finish, anonymize, delete, exit/back guard, and STANJE ROBE close-block behavior are source-confirmed. | PARTIALLY EXTRACTED | Produce owner-reviewed lifecycle state diagram and broaden test coverage. |
| PREDMET opener/signature | Future identity must distinguish current display name, stable internal user/license id, role, and historical PREDMET signature. | TECHNICAL AUDIT REQUIRED | Audit current user/session/PREDMET fields. |
| JSON single `PREDMET` transfer | Single `PREDMET` JSON is separate from full backup and may carry only approved case/business/consequence data. | PARTIALLY EXTRACTED | Define compatibility matrix and allowed blocks. |
| Single-PREDMET JSON filename semantics | Filename pattern `PREZIME_IME_brojPredmeta_vN.json` is human-readable and user-facing. Filename is not canonical identity; `PREZIME_IME` is not a conflict key. | EXTRACTED PUBLIC SUMMARY | Preserve this distinction in future import/export docs and audits. |
| Single-PREDMET JSON import freshness/overwrite guard | Source audit found same-`brojPredmeta` conflict UI with cancel/keep/replace and displayed freshness metadata, but no automatic older/newer block in the inspected import path. Owner-reported protection remains unresolved until owner review or implementation audit decides the intended guard. | PARTIALLY EXTRACTED / OWNER REVIEW REQUIRED | Decide authoritative freshness field and guard behavior; implement only under a separate JSON safety / repository identity task. |
| Full database/backup JSON | Full backup/import is broader recovery behavior and can be destructive; identity guard is missing. | TECHNICAL AUDIT REQUIRED | Design PIB/Matični broj and repository/firma guard. |
| FirmaPodaci history | `FirmaPodaci` is editable/hybrid and must not be the only stable identity. | TECHNICAL AUDIT REQUIRED | Design history and continuity model. |
| Platilac/narucilac compatibility | `Platilac` is current display term; `narucilac` remains internal code/database/JSON/template terminology. | OWNER REVIEW REQUIRED | Decide whether future cleanup preserves compatibility names or migrates them. |
| PDF snapshot labels | Main PDFs use `PLATILAC`; snapshot/export labels still include `NARUČILAC`. | OWNER REVIEW REQUIRED | Decide PDF cleanup separately. |
| STANJE ROBE consequence rules | Inventory must not become parallel PREDMET truth; unresolved consequences and close-block behavior must be explicit. | PARTIALLY EXTRACTED | Extract user-visible warning/confirmation/close-block and transfer rules. |
| Business policy evaluator ceremony guidance | Current evaluator derives condition flags and drives IRiU/finance consequences, but complete ceremony guidance, review checklist, PIO/refund guidance, JKP/payer guidance, document requirement graph, and stock consequence contract are not evaluator-complete. | PARTIALLY EXTRACTED / TECHNICAL AUDIT REQUIRED | Use the evaluator deep audit, scenario matrix, consequence graph, and completion matrix before any evaluator, IRiU, finance, document, STANJE ROBE, or Web/sync behavior changes. |
| STANJE ROBE import/restore | Current local rules separate single-PREDMET JSON from warehouse quantities and full backup/import behavior. | TECHNICAL AUDIT REQUIRED | Define full backup/import stock handling and reconciliation. |
| KATALOG selected item truth | KATALOG owns catalog truth; PREDMET/IRiU selected snapshot fields remain business-visible. | PARTIALLY EXTRACTED | Document snapshot vs catalog identity and update behavior. |
| Windows/Android parity | Platform UX may differ, business rules must remain equivalent. | EXTRACTED PUBLIC SUMMARY | Keep parity checks in future task acceptance criteria. |
| OPC Web local data behavior | Future Web must preserve local ownership, PREDMET truth, manual transfer, and no implicit server-master database. | TECHNICAL ARCHITECTURE AUDIT REQUIRED | Research architecture options before implementation. |
| Licensing/package behavior | Entitlement/package logic must not change `PREDMET` truth and must fail closed. | PARTIALLY EXTRACTED | Payment/access gate before any implementation. |
| Private/public data boundary | Public repo must exclude private/customer/runtime/export data. | EXTRACTED PUBLIC SUMMARY | Keep as mandatory review item. |
| Full product business rule inventory | Public baseline inventory now records documented/source/test-confirmed rules, owner decisions, implementation gaps, test gaps, and future Web/sync risk areas. | EXTRACTED PUBLIC BASELINE | Use `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md` as audit baseline before future implementation tasks; keep gaps open until dedicated audits/implementation tasks close them. |
| Logos product knowledge transfer | Public knowledge-transfer package now explains OPC as a functional PREDMET-centered modular product and gives Logos a source-learning path plus grouped child-illness upgrade candidates. | EXTRACTED PUBLIC BASELINE | Use the Logos knowledge base, module relationship map, source learning index, and child-illness register before future orchestration; do not treat findings as automatic strategy. |
| PREDMET `verzija` import conflict semantics | Owner decision recorded: `verzija` is PREDMET business-version signal, not export time, filename identity, or firm identity; it may inform future conflict UI but must not remove keep/replace/cancel choice without later owner decision. Higher/lower/same/missing/malformed policies are now recorded as owner decision. | OWNER DECISION RECORDED / IMPLEMENTATION REQUIRED | Design comparator/warning behavior in a separate version/import implementation task before source changes. |
| PREDMET version conflict policy and change-log overview | Owner decision recorded: higher/lower/same/missing/malformed `verzija` cases must warn or classify state, preserve keep/replace/cancel unless later hard-block approval exists, reject `exportDatum` as authority, and require a future PREDMET version/change-log overview in `Pregled i potvrda`. | OWNER DECISION RECORDED / IMPLEMENTATION REQUIRED | Audit current `verzija` increments, import/export/replace survival, change-log data sources, `Pregled i potvrda` structure, and Windows/Android parity before implementation. |

## Open Queue Summary

TECHNICAL AUDIT REQUIRED:

- Administrator/Savetnik stable internal ID;
- PREDMET opener signature model;
- JSON single `PREDMET` vs full database backup distinction;
- single-PREDMET JSON import freshness and overwrite guard implementation design;
- PREDMET `verzija` comparator/warning implementation design for higher/lower/same/missing/malformed cases;
- PREDMET version/change-log overview data source and `Pregled i potvrda` suitability;
- current `verzija` increment coverage and import/export/replace survival;
- business policy evaluator ceremony guidance, PIO/refund, JKP/payer, document requirement, and STANJE ROBE consequence ownership;
- firm-scoped `PIB + Matični broj + brojPredmeta` conflict identity;
- identity/import/restore guard design;
- `FirmaPodaci` history implementation;
- `narucilac` internal compatibility cleanup.

TECHNICAL ARCHITECTURE AUDIT REQUIRED:

- OPC Web local data architecture;
- browser storage vs database outside browser;
- offline/local-replica behavior;
- current internet technical research for OPC Web implementation options.

EXISTING BUSINESS LOGIC EXTRACTION REQUIRED:

- same `PREDMET` conflict rules and runtime import dialog behavior;
- complete PREDMET lifecycle state machine and runtime smoke evidence;
- local app rules OPC Web must preserve.

OWNER REVIEW REQUIRED:

- which local docs should eventually be fully promoted;
- conflicts between local docs and public docs;
- final canonical implementation terminology for `Platilac`/`narucilac`;
- PDF snapshot label cleanup decision.
