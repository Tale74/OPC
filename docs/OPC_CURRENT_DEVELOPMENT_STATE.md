# OPC Current Development State

Status: public baseline snapshot from prior audits and local project documentation.

This document is a continuity summary, not a new technical audit and not a build certification.

| Area | Current public state | Risk / next action |
| --- | --- | --- |
| Product runtime | Flutter/Dart app with Windows and Android lanes. | Preserve platform parity. |
| Web runtime | No Web runner is authorized by this baseline. | OPC Web architecture audit required before implementation. |
| Backend/API | No backend/API is authorized by this baseline. | Server role must be owner-approved and not presumed master `PREDMET` DB. |
| Database | Local Drift/SQLite model; schema version evidence exists in prior audits. | Identity/history guard audit required before changing database behavior. |
| PREDMET | Central master business truth. | Do not redefine through Web, sync, package, PDF, JSON, or UI work. |
| PREDMET versioning | `verzija` is the owner-approved future business-version signal; current implementation displays/exports/imports it but does not compare it for import conflicts. Owner decision now records higher/lower/same/missing/malformed warning/classification policy. | Comparator/warning implementation, validation boundaries, and platform parity require design before source changes. |
| PREDMET change-log overview | Owner requires a future version/change-log overview for business review in `Pregled i potvrda`; no implementation is authorized by this baseline. | Audit current logs/lifecycle records, `verzija` increment coverage, import/export/replace survival, and Windows/Android UI parity before implementation. |
| Firma identity | `FirmaPodaci` exists and is important but editable/hybrid. | Stable identity cannot rely only on editable fields. |
| JSON transfer | Single `PREDMET` JSON and full backup/database JSON remain baseline transfer/backup forms. | Distinction and guards require technical audit. |
| Import/restore | PIB/Matični broj mismatch must block in future guard design. | Implementation details unresolved. |
| Roles | Administrator/Savetnik terms exist. | Stable role identity and firm/license relationship require audit. |
| Packages | Osnovni/Srednji/Potpuni are canonical terms. | Payment/access implementation is blocked. |
| Terminology | OPC Web is canonical; SaaS is not primary product terminology. | Existing `saas` labels are cleanup candidates, not current task changes. |
| Local docs | `SOURCE/PROJECT_DOCS` and control copy contain continuity memory. | Owner review and sanitization required before promotion. |
| Tests/build | Prior task reports are evidence; this docs-only task runs manifest gate only. | No source build is required by this baseline task. |
| Business policy snapshot | Full business-policy and domain/flow atlas now exists for public learning and future audit continuity. | Use `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md` and `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md` before future Web/sync/identity/JSON/version implementation tasks. |
| PREDMET workflow atlas | User/business workflow atlas, dependency map, and completion-state matrix now document actual PREDMET UI points and waiting items. | Use `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`, `docs/OPC_PREDMET_DEPENDENCY_MAP.md`, and `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md` before changing PREDMET UI, documents, JSON, finance, IRiU, STANJE ROBE, or lifecycle behavior. |

## Current Prohibitions

This baseline does not authorize source changes, Web runner, backend/API, sync, browser storage adapter, migrations, payment/subscription work, role implementation, or package restructuring.
