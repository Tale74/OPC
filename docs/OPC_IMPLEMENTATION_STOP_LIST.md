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
| Payment/subscription implementation | Business/legal/payment model is not baseline-approved. | Payment/access gate. |
| Package restructuring | Package terms are canonical, but implementation changes are not authorized. | Payment/access gate and owner decision. |
| Administrator/Savetnik role implementation | Stable IDs and firm/license model need audit. | Technical identity audit. |
| Source-code package restructuring | Outside continuity-baseline scope. | Dedicated architecture/refactor task. |
| Private/customer/export/runtime data inclusion | Public repo must remain sanitized. | Never allowed in public docs without explicit sanitization review. |

## Allowed Next Work

Allowed next work is documentation/audit only: owner review of local docs, terminology lineage fact-check, current technical identity/import/restore audit, and OPC Web local-data architecture research.
