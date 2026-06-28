# OPC Implementation Stop-List

Status: active until replaced by an owner-approved architecture/task.

The following work is blocked by default. It requires a separate explicit task, the relevant manifest gate, and owner-approved scope before implementation.

| Stop item | Why blocked now | Required gate before work |
| --- | --- | --- |
| Web runner creation | OPC Web architecture is not selected. | Technical architecture audit; data ownership gate. |
| Backend/API service | Server role must not become implicit `PREDMET` master. | Data ownership/repository identity gate. |
| Sync implementation | Replica/conflict rules are not extracted. | Existing business logic extraction; data ownership gate. |
| Browser storage adapter | OPFS/IndexedDB/SQLite WASM/local agent/hybrid choice is unresolved. | Technical architecture audit with current research. |
| Database migrations | Current task is docs-only. | Technical task with migration review and tests. |
| Import/restore guard implementation | Identity model details are unresolved. | JSON safety and repository identity audit. |
| Firm-scoped `brojPredmeta` identity guard | Owner clarified `brojPredmeta` is unique only within a firm; safe scope is `PIB + Matični broj + brojPredmeta`, but no guard/constraint is authorized here. | JSON safety, repository identity, data ownership, and migration review. |
| Single-PREDMET JSON filename identity use | Filename is human-readable only and must not become canonical system identity. | Product terminology/source-of-truth audit before any import/export wording or behavior change. |
| Older/newer single-PREDMET JSON overwrite guard changes | Freshness audit found displayed metadata and explicit keep/replace/cancel choice, but no automatic older/newer block in the inspected import path. Guard behavior now requires owner decision and implementation design before changes. | JSON safety, repository identity, data ownership, and platform parity gates. |
| Backup/restore behavior changes | Current public policy is a summary, not an implementation authorization; PIB/Matični broj guard design is unresolved. | JSON safety, repository identity, and data ownership gate. |
| `FirmaPodaci` history implementation | `FirmaPodaci` is editable/hybrid and history design is not implemented. | Technical identity audit and migration review. |
| `narucilac`/`Platilac` compatibility cleanup | Current state is mixed across UI/PDF/source/database/JSON/template ids. | Product terminology gate plus source/database/PDF/JSON compatibility plan. |
| Payment/subscription implementation | Business/legal/payment model is not baseline-approved. | Payment/access gate. |
| Package restructuring | Package terms are canonical, but implementation changes are not authorized. | Payment/access gate and owner decision. |
| Administrator/Savetnik role implementation | Stable IDs and firm/license model need audit. | Technical identity audit. |
| Source-code package restructuring | Outside continuity-baseline scope. | Dedicated architecture/refactor task. |
| Private/customer/export/runtime data inclusion | Public repo must remain sanitized. | Never allowed in public docs without explicit sanitization review. |

## Allowed Next Work

Allowed next work is documentation/audit only: owner review of local docs, public-safe local-doc summaries, terminology lineage fact-check, current technical identity/import/restore audit, and OPC Web local-data architecture research.
