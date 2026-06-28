# OPC Locked Rules Public Summary

Status: public-safe summary of local locked rules.

This document summarizes rules that are safe to expose publicly. It does not copy raw local `PROJECT_DOCS` text and does not authorize source, database, Web, sync, payment, role, package, or storage implementation.

## Core Locked Rules

| Area | Public-safe locked rule | Status |
| --- | --- | --- |
| `PREDMET` truth | `PREDMET` is the central and only master business truth for OPC case work. UI, PDFs, JSON, statistics, reports, reminders, and operational warnings are derived/read/render/transfer layers. | MASTER / CURRENT |
| Platform parity | Windows and Android are equal runtime forms of the same OPC product. UX may differ by platform, but shared business truth must remain shared. | MASTER / CURRENT |
| OPC Web | OPC Web is a possible future complementary OS-proof runtime/access model. It is not a replacement for Windows/Android. | MASTER / CURRENT |
| Server boundary | OPC Web or server components must not be presumed to be a server-master `PREDMET` database. | MASTER / CURRENT |
| Database ownership | The firm/user owns and controls its OPC database. No database is automatically central/master. | MASTER / CURRENT |
| Local-first transfer | Current local app principles include local Drift/SQLite, single `PREDMET` JSON transfer, full database/backup JSON transfer, manual/user-controlled transfer, and no mandatory network sync. | MASTER / CURRENT |
| JSON transfer | Single `PREDMET` JSON is not the same as full database/backup JSON. Future work must preserve that distinction. | MASTER / CURRENT / TECHNICAL AUDIT REQUIRED |
| Firm-scoped case number | `brojPredmeta` is unique within the same firm only. Future-safe conflict scope is firm identity plus `brojPredmeta`, not global `brojPredmeta`. | OWNER DECISION |
| Single-PREDMET JSON filename | `PREZIME_IME_brojPredmeta_vN.json` is a human-readable filename pattern, not canonical identity. | OWNER CLARIFICATION |
| Terminology | Do not describe OPC primarily as SaaS. Old local SaaS-ready wording is historical/superseded unless explicitly re-approved by owner. | MASTER / CURRENT |
| Scope discipline | No implementation beyond approved task scope. Source changes require an explicit implementation task and relevant manifest gate. | MASTER / CURRENT |
| Public repo hygiene | Do not include private/customer/export/runtime data, secrets, signing material, local databases, build artifacts, or raw chat transcripts in the public repo. | MASTER / CURRENT |
| Identity/Web/sync/licensing | No identity, Web, sync, licensing/payment, role, package, backend/API, storage-adapter, or migration implementation before required audits. | ACTIVE STOP |

## Business Logic Constraints Preserved From Local Docs

| Area | Public-safe summary | Status |
| --- | --- | --- |
| PREDMET lifecycle | Current lifecycle concepts include open/closed/edit flows, confirmed-close semantics, and guarded navigation/exit behavior. Full extraction remains required before Web/sync architecture. | PARTIALLY EXTRACTED |
| PREDMET conflict replacement | Current single-`PREDMET` conflict flow is keyed by `brojPredmeta`; replacement behavior must not silently duplicate or corrupt local related data. | PARTIALLY EXTRACTED |
| PREDMET future conflict scope | Future conflict/identity checks must use `PIB + Matični broj + brojPredmeta` unless a later owner-approved architecture supersedes it. | DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED |
| STANJE ROBE relationship | Inventory state must not become parallel `PREDMET` truth. Operational consequences may be business-visible only through explicit rules. | PARTIALLY EXTRACTED |
| STANJE ROBE single-`PREDMET` JSON | Local rules say single-`PREDMET` JSON must not transfer warehouse quantities or inventory ledger as business truth. | PARTIALLY EXTRACTED |
| KATALOG relationship | KATALOG owns catalog article truth; selected PREDMET/IRiU snapshot fields remain business-visible at the time of selection. | PARTIALLY EXTRACTED |
| Role/package/payment | Entitlement/package/role rules must fail closed and must not change `PREDMET` truth. Implementation remains blocked by separate gates. | PARTIALLY EXTRACTED |

## Superseded Or Owner-Review Language

| Local wording / implication | Public treatment |
| --- | --- |
| `SaaS-ready` as product identity | SUPERSEDED by `OPC Web` and "not primarily SaaS" owner decision. |
| Any central/master server database implication | SUPERSEDED unless future owner-approved architecture explicitly changes database ownership. |
| Windows as admin app / Android as field app | FORBIDDEN DRIFT. |
| `naručilac` as current user-facing canonical term | OWNER REVIEW REQUIRED because evidence shows visible `Platilac` surfaces and internal `narucilac` compatibility names. |
| Any task text that bypasses public manifest gates | INVALID; public manifest and owner decisions control future tasks. |

## Provenance

| Local document | Folder source | Classification | Public summary target | Raw copied? | Private data excluded? | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | MASTER / CURRENT MIXED WITH HISTORY | This document | NO | YES | Summarized only; old task-specific and licensing/key details not copied. |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | SUPPORTING | This document | NO | YES | Used for PREDMET truth, platform parity, JSON, and module-boundary rules. |
| `OPC_v1_PROJECT_SOUL.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | MASTER / CURRENT, PARTLY SUPERSEDED | This document and manifest | NO | YES | Core identity retained; old SaaS wording superseded. |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | `SOURCE/PROJECT_DOCS` and byte-identical control copy | HISTORICAL / SUPPORTING | This document | NO | YES | Used only as chronological evidence for locked boundaries. |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | `SOURCE/PROJECT_DOCS` only | SUPPORTING | This document | NO | YES | Used for current-state evidence and risk boundaries. |

## Conflict Handling

No local rule was promoted when it conflicted with the public manifest or owner decision baseline. Conflicting or stale local language is treated as historical/superseded or owner-review material, not as current public truth.
