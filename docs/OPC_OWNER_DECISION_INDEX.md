# OPC Owner Decision Index

## Purpose

This register gives every recorded owner decision a stable identifier. It is a navigation and traceability aid, not implementation authorization. The authoritative wording is in `docs/OPC_OWNER_DECISION_GUIDE.md`; executable-style boundaries and fallbacks are in `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md`.

| Decision ID | Segment | Decision title | Status | Guide section | Pseudocode section | Implementation status | Unresolved dependency |
|---|---|---|---|---|---|---|---|
| `OPC-OD-GLOBAL-001` | GLOBAL | Mandatory explicit fallback | OWNER-APPROVED — NOT YET IMPLEMENTED | 2 | 2 | Documentation only | Per-decision owner fallback where still unknown |
| `OPC-OD-ARCH-001` | ARCHITECTURE | PREDMET authority and PODSETNIK boundary | PARTIALLY IMPLEMENTED | 3 | 3 | Current reminder boundary exists; structured obligations do not | Future storage/history and entitlement UX |
| `OPC-OD-STA-001` | STATUSI | POL-driven grammar and spouse initialization | PARTIALLY IMPLEMENTED | 4.1 | 4.1 | Current source infers a default in unresolved cases | No-inference correction and review UX |
| `OPC-OD-STA-002` | STATUSI | Business meaning of work statuses | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.2 | 4.2 | Status choices exist; structured semantics do not | Legal/advisory content authority |
| `OPC-OD-STA-003` | STATUSI | One family-pension organizational right | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.3 | 4.3 | Not implemented | Beneficiary detail and possible future service module |
| `OPC-OD-STA-004` | STATUSI | Right tri-state | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.4 | 4.4 | Current fields are mostly booleans | Migration and UI specification |
| `OPC-OD-STA-005` | STATUSI | Right and FIRMA obligation independence | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.5 | 4.5 | Not implemented | Data model and history |
| `OPC-OD-STA-006` | STATUSI | Submission date plus OPC timestamp | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.6 | 4.6 | Not implemented | Validation/time-zone specification |
| `OPC-OD-STA-007` | STATUSI | ZAVRŠEN blocking and 24-hour correction | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.7 | 4.7 | Not implemented | Full completion-state integration |
| `OPC-OD-STA-008` | STATUSI | Revocation and timer reset | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.8 | 4.8 | Not implemented | Immutable history model |
| `OPC-OD-STA-009` | STATUSI / CEREMONIJA | Military-honors handoff and obligation | PARTIALLY IMPLEMENTED | 4.9 | 4.9 | DA/NE fact exists; handoff obligation does not | Ceremony obligation implementation |
| `OPC-OD-STA-010` | STATUSI | Remove free work-status note | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.10 | 4.10 | Existing note remains | Owner-approved legacy-content migration |
| `OPC-OD-STA-011` | STATUSI / LISTA | Overlapping POSTCEREMONIJALNI TOK category | OWNER-APPROVED — NOT YET IMPLEMENTED | 4.11 | 4.11 | Not implemented | Membership and completed-history projection |
| `OPC-OD-CER-001` | CEREMONIJA | Ceremony facts and military-honors input | PARTIALLY IMPLEMENTED | 5.1 | 5.1 | Existing facts implemented; new handoff absent | Structured fact validation |
| `OPC-OD-CER-002` | CEREMONIJA | Three possible pre-ceremony obligations | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.2 | 5.2 | Not implemented | Source-condition lifecycle integration |
| `OPC-OD-CER-003` | CEREMONIJA | Possibility versus explicit acceptance/execution | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.3 | 5.3 | Not implemented | Data model and UI |
| `OPC-OD-CER-004` | CEREMONIJA | Automatic execution timestamp | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.4 | 5.4 | Not implemented | Time-zone/clock policy |
| `OPC-OD-CER-005` | CEREMONIJA | Pre-ceremony completion blocker | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.5 | 5.5 | Not implemented | Completion-state integration |
| `OPC-OD-CER-006` | CEREMONIJA | Option B ceremony-plus-24-hour cutoff | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.6 | 5.6 | Not implemented | Invalid/rescheduled ceremony handling |
| `OPC-OD-CER-007` | CEREMONIJA | Source-condition change lifecycle | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.7 | 5.7 | Not implemented | History/cancellation storage |
| `OPC-OD-CER-008` | CEREMONIJA | Cancellation success/failure evidence | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.8 | 5.8 | Not implemented | Reason validation and history UI |
| `OPC-OD-CER-009` | CEREMONIJA | Ceremony datetime business event | OWNER-APPROVED — NOT YET IMPLEMENTED | 5.9 | 5.9 | Current source directly saves fields | Event versioning/linkage model |
| `OPC-OD-CER-010` | CEREMONIJA / IRIU | International/reception IRIU grouping | CURRENTLY IMPLEMENTED | 5.10 | 5.10 | SAHRANA owns conditional BALSAMOVANJE; DOČEK owns CARGO and MESTO/DATUM/VREME | Accepted/executed source-change lifecycle remains future owner pass |
| `OPC-OD-CER-011` | CEREMONIJA / PARTE | PARTE remains derivative | CURRENTLY IMPLEMENTED | 5.11 | 5.11 | Implemented | Preserve boundary during future change |
| `OPC-OD-XSG-001` | CROSS-SEGMENT | Final vehicle departure is derived readiness | OWNER-APPROVED — NOT YET IMPLEMENTED | 6.1 | 6.1 | Not implemented | Full readiness matrix |
| `OPC-OD-XSG-002` | CROSS-SEGMENT | No manual readiness override | OWNER-APPROVED — NOT YET IMPLEMENTED | 6.2 | 6.2 | Not implemented | Blocker taxonomy and source routing |
| `OPC-OD-XSG-003` | CROSS-SEGMENT / DOČEK | Reception readiness and temporal order | OWNER-APPROVED — NOT YET IMPLEMENTED | 6.3 | 6.3 | Date/readiness model absent | Full reception conditions |
| `OPC-OD-XSG-004` | CROSS-SEGMENT / DOČEK | Explicit reception completion | OWNER-APPROVED — NOT YET IMPLEMENTED | 6.4 | 6.4 | Not implemented | History and revocation decision if required |
| `OPC-OD-XSG-005` | CROSS-SEGMENT | Stage-two final departure readiness | OWNER-APPROVED — NOT YET IMPLEMENTED | 6.5 | 6.5 | Not implemented | CEREMONIJA/IRIU/cross-segment matrix |
| `OPC-OD-XSG-006` | CROSS-SEGMENT / IRIU | Remaining readiness decisions | OWNER DECISION STILL REQUIRED | 6.6 | 6.6 | Deliberately undefined | Next ROBA I USLUGE / IRIU owner pass |
| `OPC-OD-PARTE-001` | PREDMET / PARTE / PDF | Controlled derivative PARTE print preparation | CURRENTLY IMPLEMENTED — REAL-DEVICE RUNTIME SMOKE PENDING | 8.5 | `OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` 20-27 | Restart-safe preparation, content-free FIRMA templates, app-owned media, shared WYSIWYG plan, KORICE PDF, blocker and cleanup implemented | Owner/device Windows and Android runtime smoke |

## Register rules

1. IDs are permanent; changed decisions receive history, not silent rewriting.
2. `OWNER-APPROVED — NOT YET IMPLEMENTED` never means source behavior exists.
3. `SUPERSEDED` entries remain in history and point to the replacing decision.
4. Every future implementation task must cite the applicable IDs and resolve all listed dependencies/fallbacks in its authorized scope.
5. If source and guide disagree, the discrepancy is reported; production behavior is not changed by this register.

## OPC-OD-NATIVE-DEV-POTPUN-001 — SUPERSEDED

- Decision: Windows/Android development, presentation and runtime validation use
  shared POTPUN mode without local activation until both native apps are final.
- Final licensing return point: after native completion and before final OPC Web
  OS-proof preparation.
- Implementation: `OpcNativeDevelopmentBuildMode`,
  `OpcRuntimeEntitlementResolver`.
- Report: `docs/tasks/OPC_TASK_DEVELOPMENT_POTPUN_RUNTIME_UNLOCK_PARTE_UI_CLEANUP_REPORT.md`.
- Superseded by: `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003`; retained for audit only.

## OPC-OD-PARTE-002

- Decision: internal WYSIWYG/render-plan explanations do not belong in the
  ordinary PARTE working UI; shared composer/PDF architecture remains intact.
- Implementation: technical information card and its exclusive spacing removed
  from `ParteSegment`.
- Report: `docs/tasks/OPC_TASK_DEVELOPMENT_POTPUN_RUNTIME_UNLOCK_PARTE_UI_CLEANUP_REPORT.md`.
# PARTE runtime corrections — CLOSED

See `OPC_OWNER_DECISION_GUIDE.md` and `OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`. Closed scope: MODUL PARTE ownership, eligible OTVOREN selection, deceased-name title, canonical symbol labels, full initial-script normalization with manual mixed-script preservation, reference layout, single-line compressed name, per-block alignment/embedded fonts, preview selection, drag/aspect resize, non-destructive photo controls, explicit reset, `ŠABLONI PARTE`, singular built-in/contextual custom templates, authoritative PDF, optional DOCX, and Windows-first runtime gate.

## OPC-OD-STAGE1-UNRESTRICTED-PARTE-003 — CLOSED

- Decision: PAKETI are permanently abandoned as native business/production policy; all existing Windows/Android functionality is available to every native user.
- Transition: Stage 1 removes functional package restrictions while retaining old technical payload/parser/bootstrap/diagnostic code; Stage 2 physical removal is a separate post-runtime task.
- Boundary: ADMINISTRATOR/SAVETNIK permissions, business prerequisites and PREDMET lifecycle remain active; OPC Web remains future-only.
- Decision: MODULI relocated beside STATISTIKA; settings no longer launches operational modules.
- Decision: completed PARTE is retained, reopenable and deletable only by explicit user action.
- Decision: separate physical margins, deterministic full reflow, calibration PDF, positioned block DOCX and OS-appropriate Android KORICE access.
- Runtime: Windows physical print and DOCX owner acceptance must pass before Android runtime begins.
- Report: `docs/tasks/OPC_TASK_PARTE_RUNTIME_CORRECTIONS_MODULE_WORKFLOW_COMPOSER_DOCX_REPORT.md`.

## OPC-OD-CANONICAL-DB-MIGRATION-004 — LOCKED

The owner-designated `opc_v4_release.sqlite` remains canonical regardless of a
stale schema checkpoint. Supported historical and partially migrated user
databases upgrade in place through validated idempotent application migrations.
Test databases are never substituted or merged automatically. Backup-first
copy proof and explicit owner authorization precede the live canonical upgrade.
See `OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`.

## OPC-OD-IRIU-KATALOG-BASIC-005 — LOCKED

KATALOG owns the persistent `Osnovna u svakom PREDMETU: DA/NE` policy; default
is `NE` and changes affect only future PREDMETI. Existing scenario rules remain
authoritative and unchanged. Existing built-in basics precede `Agencijske
usluge`; enabled user/configurable basics follow it in persistent category
creation order. Manual IRiU addition is PREDMET-local and cannot create or
change KATALOG policy. Implemented in schema 22; see the focused task report.
