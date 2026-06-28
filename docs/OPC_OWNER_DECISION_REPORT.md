# OPC Owner Decision Report

Status: public continuity baseline.

This document records confirmed owner decisions that future OPC tasks must treat as the current public decision baseline. It does not implement architecture, Web runtime, sync, storage, payment, package, migration, or source-code changes.

## Confirmed Decisions

| Area | Owner decision | Current effect |
| --- | --- | --- |
| Product name | `OPC` remains the product. | Do not rename the product around Web, SaaS, sync, or package terminology. |
| Future Web runtime | The canonical term is `OPC Web`. | `OPC Web Pristup` is historical/supporting wording; use `OPC Web` in new public docs. |
| SaaS wording | `SaaS` is not the primary OPC product description. | Do not describe OPC or OPC Web primarily as SaaS. Existing `saas` code/doc labels are cleanup candidates only. |
| Runtime parity | Windows and Android are equal runtime forms. | No Windows-master/admin vs Android-field/slave split. |
| OPC Web relationship | OPC Web is complementary OS-proof commercial access/runtime. | It is not a replacement for Windows/Android and not a server-master `PREDMET` database. |
| Server role | A server may host access, licensing, package, backup, transfer, signaling, or mediation functions. | Server must not be presumed to own or master `PREDMET` data without future owner-approved architecture. |
| Business user | The firm is the primary business user. | Firm identity and database ownership must be preserved in future architecture. |
| Master truth | `PREDMET` remains the central and only master business truth. | PDFs, JSON, lists, statistics, reminders, Web, sync, and packages stay derived or operational. |
| Firma data | `FirmaPodaci` is important but editable/hybrid. | Stable identity must not rely only on editable display fields; change history is required before stronger identity flows. |
| Import/restore guard | PIB/Matični broj mismatch must block import/restore. | No exception inside the import/restore guard without a later explicit owner decision. |
| Transfer model | Single `PREDMET` JSON and full database/backup JSON remain basic local transfer/backup forms. | Stronger identity and guard audits are required before Web/sync work. |
| PREDMET identity scope | `brojPredmeta` is unique only within the same firm, not globally across all OPC firms/users. | Future safe conflict identity scope is `PIB + Matični broj + brojPredmeta`; do not use `brojPredmeta` alone as global identity. |
| Single PREDMET JSON filename | `PREZIME_IME_brojPredmeta_vN.json` is a user-facing, human-readable filename pattern. | Filename helps users recognize a case but must not become canonical system identity. |
| Roles | Future Administrator/Savetnik roles are tied to firm/license. | Do not implement role architecture until baseline audits are complete. |
| Packages | Canonical package terms are `Osnovni`, `Srednji`, `Potpuni`. | OPC is built as Potpuni; functions/services can be disabled by paid package without changing `PREDMET` truth. |
| Current milestone | Next milestone is documentation/continuity baseline only. | No implementation until source-of-truth and technical audit queue are clear. |

## Open Queue

| Queue | Status | Required next action |
| --- | --- | --- |
| naručilac/narucilac/klijent/Platilac terminology lineage | FACT CHECK REQUIRED | Confirm business meaning and canonical owner wording before UI/PDF/JSON label changes. |
| PROJECT_DOCS master/current selection | FACT CHECK REQUIRED | Owner must identify which local docs are true master/current before direct promotion. |
| Administrator/Savetnik stable ID | TECHNICAL AUDIT REQUIRED | Audit current user/role identity before firm/license role work. |
| PREDMET opener signature model | TECHNICAL AUDIT REQUIRED | Define how a `PREDMET` opening actor is captured without corrupting existing history. |
| Single `PREDMET` JSON vs full database/backup JSON distinction | TECHNICAL AUDIT REQUIRED | Keep transfer/backup semantics explicit before changing guards. |
| Identity/import/restore guard details | TECHNICAL AUDIT REQUIRED | Design firm/database identity checks before implementation. |
| OPC Web local data architecture | TECHNICAL ARCHITECTURE AUDIT REQUIRED | Research browser storage vs external DB/local agent/hybrid/offline replica options. |
| Replica conflict rules | EXISTING BUSINESS LOGIC EXTRACTION REQUIRED | Extract current `PREDMET` lifecycle and related-data rules before Web/sync design. |

## Addendum - Question 5/36 Terminology Evidence

Current evidence partially resolves the `naručilac` / `narucilac` / `klijent` / `Platilac` lineage:

- `Platilac` is the current visible PREDMET UI/PDF/business display term in the inspected payer surfaces.
- `narucilac` remains a current internal code/database/JSON term and appears in one PDF snapshot/export evidence path.
- The evidence supports a mixed state: older/internal `narucilac` naming was not fully removed after visible terminology moved toward `Platilac`.
- `klijent` is not a current PREDMET party term and must not replace either `narucilac` or `Platilac`.

Owner still needs to decide whether future cleanup should preserve internal `narucilac` names for compatibility or migrate source/database/PDF/JSON terminology under a separate explicit implementation plan.

## Addendum - Locked Rules And Backup/Restore Public Summaries

Public-safe summaries now exist for locked rules and backup/restore policy:

- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`

No local raw `PROJECT_DOCS` document was copied. Old local SaaS wording, central-master interpretations, and implementation-before-audit implications are superseded by the public manifest and owner decisions.

Technical follow-ups remain open: PIB/Matični broj import/restore guard design, `FirmaPodaci` history, single `PREDMET` JSON vs full database backup distinction, Web/sync identity model, and `narucilac` internal compatibility cleanup.

## Addendum - Firm-Scoped BrojPredmeta And Single-PREDMET Filename Semantics

Owner decision: `brojPredmeta` is unique within the same firm only. It is not globally unique across all OPC users/firms.

Future-safe identity scope for PREDMET conflict/import/restore/sync/Web logic is:

```text
PIB + Matični broj + brojPredmeta
```

Owner clarification: a single-PREDMET JSON export filename such as `PREZIME_IME_brojPredmeta_vN.json` is a human-readable filename pattern. The user recognizes the file by person first, then by `brojPredmeta`/date-time/version. `PREZIME_IME` and the filename are not canonical conflict keys. The actual case number is `predmet.brojPredmeta` inside the JSON, but even that must be scoped by firm identity for future safe conflict handling.

Owner-reported behavior: OPC currently protects against an older single-PREDMET JSON overwriting a newer local PREDMET. This report records that as `OWNER-REPORTED BEHAVIOR`; it is not promoted to source/test/runtime-confirmed status here. Future audit required: `OPC BUSINESS LOGIC EXTRACTION - SINGLE-PREDMET JSON IMPORT FRESHNESS AND OVERWRITE GUARD`.

## Addendum - Import Choice, Filename UX, Export Metadata, And Version Signal

Owner clarification: keep / replace / cancel during same-`brojPredmeta` single-PREDMET JSON import is intentional business behavior, not a defect. There may be real business situations where `Platilac` changes their mind or later human/business choice determines which version remains correct. Future guards or warnings must not remove explicit user choice unless a later owner decision changes this rule.

Owner clarification: `Ime_Prezime` / `PREZIME_IME` in a single-PREDMET JSON filename is a user-facing recognition aid for the deceased person/case. It is not system identity, conflict key, freshness key, or canonical PREDMET identity.

Owner decision: `exportDatum` records when the JSON file was exported. It is not business freshness authority and must not be treated as proof that the exported PREDMET is newer or more correct.

Owner decision: `verzija` is the relevant field for future version comparison / version reasoning. This does not mean current implementation already uses `verzija` correctly or that it is sufficient by itself. Actual `verzija` behavior remains a technical audit/design item before implementation changes.

## Stop Boundary

This report authorizes documentation continuity only. It does not authorize Web runner creation, backend/API work, sync, storage adapter work, database migrations, package restructuring, payment/subscription implementation, role implementation, or source-code changes.
