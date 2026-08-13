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
| `OPC-OD-PARTE-001` | PREDMET / PARTE / PDF | Controlled derivative PARTE print preparation | PARTIALLY SUPERSEDED — SEE `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003` | 8.5 and Locked Stage 1 | Runtime-recovery addendum; historical pseudocode 20-27 | Core derivative/WYSIWYG boundaries remain; fixed 224 × 170 mm, one 5 mm margin and completion cleanup are historical and not implementation authority | Owner/device Windows and Android runtime smoke |

## Register rules

1. IDs are permanent; changed decisions receive history, not silent rewriting.
2. `OWNER-APPROVED — NOT YET IMPLEMENTED` never means source behavior exists.
3. `SUPERSEDED` entries remain in history and point to the replacing decision.
4. Every future implementation task must cite the applicable IDs and resolve all listed dependencies/fallbacks in its authorized scope.
5. If source and guide disagree, the discrepancy is reported; production behavior is not changed by this register.

## Final continuity closure decisions — 2026-08-13

### OPC-OD-IRIU-KATALOG-LABEL-010 — LOCKED

Every KATALOG-backed IRiU row displays the stored concrete selected-article
name when one exists. The category remains classification metadata through
`interniNaziv`; current KATALOG labels are fallback only for rows without a
concrete snapshot.

### OPC-OD-PDF-PREDMET-FIDELITY-011 — LOCKED

If an IRiU row participates in PREDMET financial/business truth and the
derivative presents an itemized list, the row is visible in that list and its
amount reconciles to the displayed total. LISTA and shared itemized derivatives
must not hide financially included citation rows.

### OPC-OD-WINDOWS-CANONICAL-CLOSURE-012 — GATED

Installed Windows cold start/reopen, target PREDMET/IRiU loading, and repaired
state startup/PREDMET loading are accepted as scoped runtime evidence. The
canonical KATALOG→IRiU snapshot contract is source-proven and covered by a
bounded malformed-row repair, but the repaired build could not be deployed to
the protected install. Rendered KATALOG/IRiU, SCENARIO and LISTA proof remains
open. Canonical ČITULJE repair still requires the complete repaired-state
application-runtime gate and a post-repair startup. See
`docs/OPC_CANONICAL_KATALOG_IRIU_PIPELINE_WINDOWS_CLOSURE_REPORT.md`.

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

## OPC-OD-PARTE-004 — PRINTABLE ZONE AND WORD DERIVATIVE

- Outer form and non-centred printable zone are separate millimetre geometry; safe margins are inside the zone.
- One render plan owns preview, bounds and authoritative PDF coordinates. Printer-driver scaling is outside OPC and physical print remains owner acceptance.
- Schema 5 remains backward-compatible with PARTE schema 1–3 through a full-page legacy zone and unchanged block coordinates; schema 4 additionally migrates with optional media-ratio repair metadata absent.
- `PREGLED PRIPREME`, en-dash years, Noto Sans/Noto Serif and collapsible setup sections are current UI policy.
- DOCX remains secondary but must open, save and reopen in Microsoft Word without repair while retaining independent editable blocks.
- Report: `docs/tasks/OPC_TASK_PARTE_PRINTABLE_ZONE_PDF_DOCX_UX_CORRECTION_REPORT.md`.

### PARTE final runtime print-origin and fidelity correction

- User-visible format input excludes raw X/Y and derives a centred zone; owner geometry `224 × 170`, zone `175 × 115`, margins `5 × 5` derives `24.5/27.5` internally.
- Printer correction is machine-local, resettable and PDF-only; it never enters PREDMET, a preparation template or DOCX.
- Schema 5 preserves media source ratio, Noto Serif is the missing-font/new default, guides remain editor-only, and Word media use Behind Text.
- Physical print remains owner acceptance even after electronic and build PASS.

### OPC-OD-PARTE-005 — CANONICAL RENDER AND TEMPLATE STATE

- One canonical render plan owns resolved text, fit status, geometry and media for preview, PDF and DOCX; adapters may not refit, repair punctuation or silently omit a required block.
- The full deceased name remains one line with a `74 pt` maximum and bounded fit; failure is an explicit export blocker. Life years use an en-dash before any exporter.
- `selected`, preparation `active` and persisted `default` template IDs are independent states and independent actions.
- The former removal of all technical explanation around the preparation is
  superseded for placement by `OPC-OD-PARTE-006`; render-plan and non-printing
  boundaries remain unchanged.
- Printer correction stays machine-local and PDF-only; A5/Letter observations do not establish a global offset. Owner physical print remains pending.
- A physically validated correction may be associated locally with a template ID, but its numeric offset never enters portable template JSON; another machine or an unassociated template starts at `0/0`.
- Report: `docs/tasks/OPC_TASK_PARTE_ROOT_CAUSE_RENDER_PIPELINE_CORRECTION_RUNTIME_ACCEPTANCE_REPORT.md`.

### OPC-OD-PARTE-006 — PREVIEW-SIDE TECHNICAL HELP PLACEMENT

- Technical print/editor help is absent from the command panel and appears on
  `PREGLED PRIPREME`, outside the printable canvas.
- The help is application UI only. It never enters the canonical render plan,
  PDF, DOCX, calibration PDF, portable template JSON or physical print.
- Format controls keep sufficient top spacing for complete floating labels on
  Windows and Android narrow layouts.
- The tested Letter / Actual size physical print remains accepted for the local
  per-template `+25/+4 mm` printer profile; this decision does not reopen or
  globalize printer calibration.
- Report: `docs/tasks/OPC_TASK_PARTE_FINAL_TECHNICAL_TEXT_PLACEMENT_UI_REGRESSION_REPORT.md`.

### OPC-OD-PARTE-007 — COMPLETE MULTILINE PDF AND LOCAL OFFSET RANGE

- PDF paints every canonical line in order; `Ceremonija`, `Ožalošćeni` and
  other multiline blocks have no two-line adapter limit.
- The format section heading is exactly `FORMAT I ZONA ŠTAMPE (mm)` without a
  repeated dimension/zone/margin subtitle.
- The local per-template printer correction supports the validated technical
  range `−100..+100 mm`; portable template JSON remains printer-independent.
- Report: `docs/tasks/OPC_TASK_PARTE_MULTILINE_PDF_FORMAT_OFFSET_REGRESSION_REPORT.md`.

### OPC-OD-PARTE-008 — OWNER WINDOWS/ANDROID RUNTIME CLOSURE

- Tested source HEAD: `805ad18865fddb3181bf27e6cfc82d7cfffd5b53`.
- Owner manual validation respected the successive gate: green analyze, green
  complete test, Windows release build PASS, then Android release build PASS.
- Windows runtime: `PRINUĐENI PASS`.
- Android runtime: `FUNCTIONALLY SATISFACTORY`.
- Follow-up: `REFINEMENT FINDINGS MATERIAL IN PREPARATION`.
- The previous correction objective is closed; no refinement implementation is
  authorized until the complete owner findings package is delivered and reviewed.
- The old private evidence folder was intentionally deleted as stale; future
  evidence at that location exists only after explicit owner notice.
- Stop boundary: `DO NOT START PARTE FOLLOW-UP IMPLEMENTATION UNTIL OWNER FINDINGS PACKAGE IS DELIVERED AND REVIEWED.`
- Report: `docs/tasks/OPC_TASK_PARTE_OWNER_WINDOWS_ANDROID_RUNTIME_DOCUMENTATION_CLOSURE_REPORT.md`.

### OPC-OD-PARTE-009 — EDITOR GESTURES, DERIVATIVE DELETION AND PREDMET PARTE SHORTCUT

- PREDMET and its IRiU `POSMRTNE_PARTE` row remain business truth; MODUL PARTE
  owns only the derivative technical preparation.
- Default editor mode gives block drag priority. Canvas pan/pinch exists only in
  the explicit `POMERI PRIKAZ` mode, with visible zoom, fit and centre controls.
- A completed retained preparation may be explicitly and irreversibly deleted
  from MODUL PARTE. The action preserves PREDMET, all IRiU data, reusable
  templates and external PDF/DOCX files, and removes only exclusively owned
  app media through recoverable staging.
- The module shortcut reuses the existing same-PREDMET route and opens PREDMET
  segment 6 `PARTE`; it never redirects to segment 7 `Roba i usluge`.
- Automated implementation validation and builds passed; runtime later exposed
  and corrected the segment-7 navigation regression.
- Report: `docs/tasks/OPC_TASK_PARTE_EDITOR_INTERACTION_PREPARATION_DELETION_IRIU_NAVIGATION_REPORT.md`.

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

## OPC-OD-IRIU-ORDER-INCIDENT-006 — LOCKED

The 2026-07-17 KATALOG basic-category task was authorized only to allow a
user/Administrator to define new KATALOG categories that materialize as basic
IRiU rows. It did not authorize changes to existing SCENARIO business
decisions, logic or IRiU row order.

Commit `c6fae079482097231f4513f683367d30f4e13f58` inverted the protected order
by placing scenario-dependent rows before `SANDUK` and the other basic rows,
then encoded that inference in a new test and task report. The owner classifies
this as an unauthorized Codex business-logic incident. Technical PASS and
owner authorization of the wider task/build do not constitute approval of the
undisclosed order change.

Locked invariant: `SANDUK` and the complete applicable basic IRiU block precede
scenario-dependent IRiU rows.

Correction timing: do not implement an isolated patch in the incident audit.
Correct and protect the ordering when SCENARIO is implemented as a
user-configurable decision through UI, with safe IRiU reconciliation and
historical stability for completed/locked PREDMET records.

Prevention rule: Codex may not change protected business behavior and
simultaneously use a newly changed test or documentation as proof of owner
approval. Any such semantic delta requires an explicit owner decision before
source or protected business-contract tests change.

Evidence:
`docs/tasks/OPC_TASK_IRIU_BASIC_SCENARIO_ORDER_REGRESSION_AUDIT_REPORT.md`.

## OPC-OD-WINDOWS-INSTALL-UPDATE-CANONICAL-DB-007 — LOCKED

OPC v.1 Windows uses the existing Inno Setup lane as the preferred installer
foundation. Manual copying of a release folder is not the target distribution
model.

Install, update and uninstall may change program files only. They must not
change, replace, relocate, reset, delete or reinterpret the canonical user
database. A verified SQLite-consistent pre-update backup is permitted, but
rollback of application files must not overwrite newer canonical database
state.

Windows must acquire a stable OPC product-line named mutex before Flutter,
plugins or SQLite initialize. A second launch must focus the existing instance
where reliable, or report that OPC is already running and exit without opening
the database.

Installer/update must refuse program-file replacement while OPC is running.
MSIX is not selected for OPC v.1 before a separate app-identity/storage audit.
Executable and installer signing remain subject to the later signing gate.

Evidence:
`docs/tasks/OPC_TASK_PHASE_1_WINDOWS_MULTIPLE_INSTANCE_CONCURRENT_DB_AUDIT_REPORT.md`.

## Current recovery decision — 2026-08-13

Current state is authoritative; user deletion is final; technical orphans of
deleted business entities are removed. Existing PREDMET snapshots are not
rewritten from current KATALOG. The schema-9 clean backup and clean-room
restore are the current recovery contract; see the canonical recovery report.
