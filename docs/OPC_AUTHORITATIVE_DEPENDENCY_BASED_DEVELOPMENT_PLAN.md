# OPC — authoritative dependency-based development plan

**Status:** `DEPENDENCY MAP — OWNER-ACCEPTED OPC v1.5 DEVELOPMENT CLOSED 2026-10-13`

**Reality-reconciliation baseline:** `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`

**Reconciled:** 2026-09-25

**Application name:** `OPC`

**Market gate:** stable OPC v.1 for the Serbian market

**Later product-line working identity:** `OPC_v.1_Int`

This document records the dependency and release map as of its reconciliation
date. OWNER's 2026-10-13 final v1.5 closure below supersedes its former active
development sequencing, while preserving owner decisions and audit provenance
through the unchanged historical sections and Git history at the baseline SHA.

It is an ordering and release-control document, not an authority to create new
owner product requirements. Product scope comes from the reconstructed owner
roadmap and later explicit owner decisions; technical findings must remain
attached to a named owner-planned item or be classified outside the active
roadmap.

`OPC Srbija` is planning shorthand only for the Serbian-market product-line
gate. It is not the product name and must not be added to application UI,
package-facing identity, installer identity or documentation as a rename.

## 0. Later OWNER closure authority — 2026-10-13

OWNER has accepted the current OPC v1.5 product as stable, functionally correct
and final. The 2026-10-12 OWNER-approved final guide integration was the last
v1.5 development/correction task. This later decision supersedes this plan's
older active sequencing and completion prerequisites for IMENIK, DVE VALUTE,
or other pending feature/correction work as v1.5 development obligations.
Those older statements remain historical decision/provenance records; they
must not be erased, interpreted as current work authorization, or silently
transferred wholesale to OPC Int. See the current-state entry
`OPC_CURRENT_DEVELOPMENT_STATE.md` and `OPC_V15_ROADMAP_SUPERSESSION_MATRIX.md`.

The scoped Android Narrow/Wide delta-runtime dated 2026-10-13 was accepted by
OWNER within the executed scope; its source report remains `PARTIAL` for
comprehensive guide chapter/context-route coverage. No Windows physical
runtime, signing, distribution or formal handover is implied. No OPC Int audit
or implementation is authorized by the closure decision.

The earlier dependency sections below are retained as historical provenance
and completed-product evidence. They no longer select or authorize another
OPC v1.5 product-development task.

## 1. Authority and interpretation

### 1.1 Evidence order

When statements conflict, use this order:

1. current post-zero owner decisions and later explicit owner instructions;
2. current source and tests for implemented technical behavior;
3. the latest task/runtime report within its exact proven scope;
4. this plan for dependency ordering and release-gate control;
5. older reports and pre-reconciliation plan text as historical evidence.

A technical PASS is not owner runtime acceptance. A Windows PASS is not an
Android PASS. A pure contract is not carrier/runtime integration. A successful
restore incident is not the final product-line backup/restore rehearsal.

### 1.2 Decision classes

Every material statement in this plan is one of:

- `LOCKED OWNER DECISION` — business outcome; Codex must not reinterpret it;
- `SOURCE/TEST FACT` — current implementation proven by source/tests;
- `RUNTIME FACT` — owner/live evidence tied to a platform and artifact;
- `TECHNICAL RECOMMENDATION` — evidence-based but not business authority;
- `OPEN OWNER DECISION` — the owner must decide before affected work closes;
- `HISTORICAL/SUPERSEDED` — retained for provenance, not current instruction.

New evidence may supersede a technical premise or ordering. It may not silently
rewrite a locked business decision.

### 1.3 Permanent product boundaries

- `PREDMET` is the sole business truth. Documents, JSON, SCENARIO, PODSETNIK,
  PARTE, IRiU views and statistics are derivatives or controlled application
  layers, never parallel masters.
- Windows and Android are equal standalone local applications using local
  Drift/SQLite and user-controlled JSON transfer. No mandatory network sync is
  introduced.
- The designated user database is never replaced by a test/prepared database.
- PAKETI/licensing restrictions remain retired for the current native product.
- OPC Web and `OPC_v.1_Int` are outside current implementation scope.
- The application/product name remains `OPC`.

### 1.4 Permanent owner-roadmap provenance control

The owner-planned OPC roadmap is the primary development roadmap. Additional
technical, standards, QA, documentation, incident, acceptance or release work
is permitted only when it is demonstrably necessary, safe and proportionate
to execute, verify or release a named owner-planned item, or to apply the
adopted engineering standardization decision.

Every additional active item must therefore have a provenance class and, where
it is a technical prerequisite or control, an explicit owner-roadmap parent.
Release/acceptance controls are gates attached to product work, not product
features. Non-blocking debt remains outside the critical path. A new product
meaning or scope question stops at `OWNER DECISION REQUIRED`; Codex/Logos may
not promote an observation into business authority. Standards govern how
planned work is performed and proven, not what the owner must build.

Avoid speculative, weakly justified or recursively generated successor chains.
Proportionality, time/token/rework efficiency and unattended evidence capture
are governance goals alongside correctness. Historical and superseded evidence
is preserved but cannot silently remain active roadmap instruction.

## 2. Current state at a glance

### 2.1 Completed work that must not be repeated

| Area | Current classification | Evidence boundary |
| --- | --- | --- |
| Documentation authority reset and architecture review | `COMPLETED — TECHNICAL PASS` | Post-zero authority inventory, full architecture review and decision synthesis select retain + progressive refactor; full rewrite is rejected. |
| PREDMET authority and scenario ownership model | `COMPLETED — SOURCE/TEST FACT` | Definitions/defaults live in MODULI; selected/applied snapshot and provenance are PREDMET-owned. |
| Explicit completion lifecycle | `COMPLETED — TECHNICAL PASS` | Automatic `ZAVRŠEN` is retired; only explicit `OTVOREN → ZATVOREN → ZAVRŠEN`; final state is immutable for direct edit/reopen. Platform runtime acceptance is not separately proven for this focused lifecycle. |
| SCENARIO business implementation | `COMPLETED — TECHNICAL PASS` | Editable OSNOVNI PAKET + scenario additional packages, 1,008 combinations, data-driven evaluation, protected manual/legacy rows, PREDMET snapshot/provenance and controlled reconciliation are implemented. |
| SCENARIO Windows runtime | `COMPLETED — OWNER RUNTIME PASS` | Real release path `MODULI → SCENARIO`, OPEN-PREDMET selection, persisted snapshot, IRiU and non-retroactivity proven. |
| SCENARIO Android runtime | `COMPLETED — OWNER RUNTIME PASS` | Physical Android device proves startup, selector, complete tuple, applied snapshot and scenario IRiU. |
| Cross-platform GROBLJE finding | `HISTORICAL / NO ACTION` | Reported GRADSKO→LOKALNO mismatch was an acceptance-reading error; full eight-axis equality passed on both platforms. |
| 1,008 consistency gates | `COMPLETED — TECHNICAL PASS` | Independent owner-map golden plus production-path E2E pass 1,008/1,008 with zero key/item/status/order mismatch. |
| KATALOG/IRiU price model | `COMPLETED — TECHNICAL PASS` | FIKSNA price, CRNINA KATALOŠKA, applied price snapshot, `KOM × CENA = IZNOS`, manual override and OSNOVNI pricing are covered. |
| Android release build/startup | `COMPLETED — OWNER RUNTIME PASS` | Fresh release APK, in-place upgrade, cold/warm startup, login/navigation and stability smoke passed. |
| Full technical regression baseline | `COMPLETED — TECHNICAL PASS` | Latest inherited baseline: analyze PASS; full suite 393 passed, 7 skipped, 0 failed; Windows and Android release builds PASS. |
| Scenario ↔ KATALOG clean-start baseline and category-delete protection | `COMPLETED — OWNER ACCEPTED; PUBLISHED` | Fresh databases seed the exact 29 system-required category configurations with no business articles; user edits remain extensible; persisted SCENARIO references protect built-in and custom categories from physical deletion. Focused/full QA, analyzer, Windows/Android release builds and OWNER Windows/Android package acceptance passed. Broader release gates remain separate. |

These items reopen only for a new source/runtime finding, a regression, or an
explicit new owner business decision.

### 2.2 Current roadmap and locked product-line prerequisites

The normal OWNER roadmap is active. This dependency plan does not create or
select roadmap members. OWNER separately selected normal-roadmap Member 3 for
the bounded RAČUN document package; its implementation, QA, Windows/Android
release builds and OWNER Word 2019 runtime review are complete, and publication
is recorded in commit `d5ec4350b143607068f430f9ae3d352aa578f0a0`. No member
after Member 3 is selected. The earlier sequence
beginning with a broad lifecycle-aware PODSETNIK program is superseded as
current sequencing authority.

The pre-closure product-line proposal was:

**DVE VALUTE preparation/design → final OPC v1.5 finalization (implementation
deferred) → finalized product version 2.0 with SRB distinction → later
`OPC Int` product-line evolution → signing and professional handover.**

OWNER's 2026-10-13 closure supersedes that proposal as active v1.5 development
sequencing: DVE VALUTE is not a v1.5 development obligation, its unresolved
design choices remain historical, and the closure does not transfer it
wholesale to OPC Int. No DVE implementation or finalization task is selected.
Separate release and handover gates remain distinct and open where identified
below.

This prerequisite chain does not select the next task or order other owner-
planned work. The separately OWNER-selected F-09 Member 1 implementation and
the prior Member 2 publication are recorded below; this plan does not select a
member after Member 3.

PREDMET/referential/lifecycle, SCENARIO-carrier, performance, parity,
backup/restore, identity and other technical/release items are attached
controls only when necessary for one of those owner-planned parents. The full
provenance matrix and reverse-coverage record are in
`docs/tasks/OPC_TASK_ROADMAP_PROVENANCE_RECONCILIATION_OWNER_ROADMAP_RESTORATION_REPORT.md`.

This current-roadmap status supersedes older “next dependency” statements that
promoted technical preparation or acceptance controls into product scope,
while preserving their underlying evidence and history. The current Member 3
publication comes from separate OWNER authorization; this plan does not select
a successor to Member 3.

### 2.3 Owner roadmap — current status

OWNER-selected normal-roadmap Member 3 is the completed and published bounded
implementation package; no member after it is selected. The post-drift recovery
sequence is formally closed and is not current sequencing authority.

The bounded F-09 target is implemented under the separate OWNER selection of
normal-roadmap Member 1: FINANSIJE is the PRE-CEREMONY parent; PLATITI RAČUN
and NAPLATITI OBAVEZE are sibling PRE-CEREMONY children. PLATITI RAČUN exists iff
`TROŠKOVI JKP > 0 AND jkpPlacaSamostalno == false`; NAPLATITI OBAVEZE exists
when `ZA NAPLATU > 0`. Both use generic manual-completion and REVIEW BAR
semantics. Source, focused/regression/full tests, analyzer and Windows/Android
builds passed; OWNER runtime/release acceptance remains separate. Broader
unspecified FINANSIJE reminder scope remains deferred.

The separately selected normal-roadmap Member 2 applies OWNER's corrected
same-PREDMET menu invariant: list-row and opened/expanded detail three-dot
menus expose the same action set under the same existing status/business
conditions, with no valid option lost, through one shared canonical action
definition. Single-PREDMET JSON EXPORT is present in both menus and absent
from `DOKUMENTI`; JSON IMPORT remains exclusively in `PODEŠAVANJA`. Existing
navigation, GDPR and permanent-delete actions are preserved, and `ZAVRŠEN`
uses the same existing lifecycle path, with Segment 10 and narrow Android
duplicates absent. Transfer contracts and lifecycle business rules are
unchanged. Focused tests, relevant regressions, full serialized suite,
analyzer and Windows/Android release builds pass; the Member 2 publication is
already recorded separately and is not reopened by Member 3.

### 2.4 Owner roadmap — next-member selection

`NO OWNER-ROADMAP MEMBER AFTER MEMBER 3 SELECTED`.

The bounded F-09 Member 1 implementation is complete under its explicit OWNER
selection and does not authorize broader finance scope. Member 2 is published
under its separate explicit OWNER authorization. Member 3 is now published with
OWNER Word 2019 runtime acceptance. This does not select a successor or
authorize currency work, broader document scope, or other future product work.
The stable-product and release prerequisites remain attached to their
established product-line boundary; this plan does not select a new
implementation member. The first unfinished evidence-gated candidate now
preceding finalization is `SCENARIO JSON CARRIER — FINAL PLATFORM
ROUND-TRIP ACCEPTANCE`: production carrier wiring exists, while release-candidate
Windows/Android round-trip evidence remains open. This is a release/runtime
acceptance candidate, not authorization to change SCENARIO or start a new
implementation package.

### 2.5 Later, non-blocking and historical classifications

`OPC_v.1_Int`, app identity/version/update decisions, signing/handover and
Stage 2 cleanup retain later/deferred status. Contextual POMOĆ and the accepted
33-chapter guide are implemented; no further v1.5 help work is authorized.
Broad RI-3/FK expansion, broad rewrite, isolated PODSETNIK patches and other
unparented technical chains are not active roadmap items. Historical withdrawn
transfer claims and obsolete Gate 0/future-SCENARIO wording remain provenance
only.

## 3. Reality matrix

The following matrix records the reconciled state before the 2026-10-13 OWNER
closure. Its release-gate distinctions and completed evidence remain useful;
unfinished v1.5 development/correction items are superseded by §0 and the
dated closure matrix. Do not read historical `OPEN` or `PARTIAL` development
rows as current authorization to implement.

| Program / dependency | Actual state | Windows | Android | Remaining work / dependency decision | Old premise |
| --- | --- | --- | --- | --- | --- |
| Documentation/continuity governance | `COMPLETED — TECHNICAL PASS` for zero-baseline classification; this reconciliation restores current sequencing | N/A | N/A | Maintain plan/report/current-state parity per task | Gate 0 activation wording is historical/superseded |
| Code/architecture review | `COMPLETED — TECHNICAL PASS` | N/A | N/A | Refactor only where evidence proves need | Mandatory broad rewrite/refactor is false |
| PREDMET authority/dependency protection | `PARTIAL` | Core truth and SCENARIO hand-off proven | Core truth and SCENARIO hand-off proven | Finish referential/lifecycle acceptance and carrier parity; do not reopen proven scenario ownership | Future snapshot/provenance premise is superseded |
| Database/referential integrity | `PARTIAL` | Hard-delete runtime PASS; scoped restore history exists | Hard-delete DB/isolation PASS; scoped restore PASS on prior artifact | Remaining RI owner gates, FK/orphan strategy if pursued, current-tip final rehearsal | Isolated PODSETNIK orphan patch is superseded by coordinated program |
| Windows single-instance | Native singleton and installer/update protection `CLOSED — FULL ACCEPTANCE PASS` | Native `Local\\OPC_ORGANIZATOR_POGREBNE_CEREMONIJE_SINGLE_INSTANCE` guard is published and accepted; Inno Setup declares the same mutex with `CloseApplications=no` | Native W1–W6 PASS; Inno Setup compile and I1/I2/I3 PASS | None — RR-012 closed; reopen only for proven regression | Native singleton and installer protection remain separate controls |
| Windows startup/exit performance | `PARTIAL — HISTORICAL DEVELOPMENT CANDIDATE` | Installed baseline about 8–9 s to login; slow exit observed; current-tip instrumented acceptance absent | N/A | No v1.5 performance correction is authorized by the 2026-10-13 closure; no performance PASS is inferred | Later runtime work does not prove performance closure |
| Android PARTE performance | `PARTIAL — HISTORICAL DEVELOPMENT CANDIDATE` | N/A | Source risks known; latest focused profiler/acceptance not performed | No v1.5 performance correction is authorized by the 2026-10-13 closure; no performance PASS is inferred | No full/partial rewrite is authorized by source audit alone |
| IRiU/KATALOG performance | `PARTIAL — HISTORICAL DEVELOPMENT CANDIDATE` | Repository characterization exists; owner slowdown not decomposed | Same shared path; no measured platform acceptance | No v1.5 performance correction is authorized by the 2026-10-13 closure; no performance PASS is inferred | Synthetic timing is diagnostic only |
| PREDMET `ZAVRŠEN` lifecycle | `COMPLETED — TECHNICAL PASS / RUNTIME OWED` | Focused runtime not separately recorded | Focused runtime not separately recorded | Include lifecycle in final platform semantic acceptance | Old unresolved lifecycle queue is superseded |
| SCENARIO implementation | `COMPLETED — TECHNICAL PASS` | See runtime row | See runtime row | Protect; do not repeat | Hard-coded/future-wiring chronology is superseded |
| SCENARIO Windows runtime | `COMPLETED — OWNER RUNTIME PASS` | PASS | N/A | Only regression protection | Future wiring premise false |
| SCENARIO Android runtime | `COMPLETED — OWNER RUNTIME PASS` | N/A | PASS on physical Android 15 device | Only regression protection | Runtime-pending premise false |
| SCENARIO JSON carriers | `COMPLETED — TECHNICAL PASS / RELEASE ACCEPTANCE OPEN` | Production Single-PREDMET and full-backup snapshot/provenance carriers are wired; targeted contracts pass | Same shared implementation | Complete final analyze/build and platform round-trip/release rehearsal; Android physical transfer remains deferred | “Carrier not wired” premise is superseded |
| IRiU/KATALOG concrete labels | `PARTIAL — WINDOWS RUNTIME BLOCKING` | Canonical stored snapshot contract and bounded malformed-row repair are source-proven; owner-observed installed Flor→Crnina defect remains pending repaired-build runtime proof | Shared implementation | Deploy repaired build, verify Flor/Ešarpa and other-category runtime displays, then close Windows visual gate | Previous technical PASS is superseded by owner-observed runtime evidence |
| LISTA/PDF item fidelity | `COMPLETED — TECHNICAL PASS` | Financially included citation rows remain visible in LISTA/shared itemized derivatives; NALOG scope remains intentional | Same shared implementation | Protect with reconciliation test and visual release acceptance | Hidden citation-row premise is superseded |
| Windows real runtime/canonical closure | `PARTIAL — BLOCKING FOR WINDOWS GATE` | Installed cold/reopen and target PREDMET/IRiU open pass; repaired-state startup/PREDMET open pass; recurrence is closed; repaired KATALOG pipeline build is not deployed to protected install and concrete visual/SCENARIO/LISTA gates remain unproven | N/A | Complete safe owner deployment, obtain rendered visual/document proof, then re-evaluate repaired-state safety and canonical repair; Android remains gated | “Windows startup unverified” is superseded within proven scope |
| KATALOG/IRiU price model | `COMPLETED — TECHNICAL PASS` | Build/technical evidence | Build/technical evidence | Include in final runtime business parity; do not redesign | Future FIKSNA/amount premise superseded |
| Generic completion/signal infrastructure | `PARTIALLY IMPLEMENTED; BROADER SIGNAL SCOPE DEFERRED` | Current generic obligation infrastructure exists; F-06 and URNA/PEPEO are separately bounded | Same shared source | Preserve existing behavior; no broad FINANSIJE signal meanings or implementation order are created here | Current F-09 status is recorded separately below; historical readiness order is not current authority |
| PODSETNIK / F-09 Member 1 | `IMPLEMENTED — SOURCE/TEST/ANALYZE/WINDOWS+ANDROID BUILD PASS; RUNTIME/RELEASE OPEN` | FINANSIJE PRE-CEREMONY parent and both PRE-CEREMONY sibling rules exist in current source; generic refresh observes PREDMET, IRiU, stock and completion inputs | Same shared source; no schema/JSON change | Preserve exact predicates, phase placement and generic obligation behavior; broader FINANSIJE reminder scope remains deferred | Owner-selected Member 1 is complete; no child-to-child sequence or successor selection is implied |
| Single-PREDMET JSON export relocation / PREDMET `ZAVRŠEN` action consolidation | `IMPLEMENTED — SOURCE/TEST/ANALYZE/FULL SUITE/WINDOWS+ANDROID RELEASE BUILD PASS; OWNER RUNTIME/PUBLICATION OPEN` | Export-only action is in canonical detail/KORICE overflow; JSON import stays exclusively in PODEŠAVANJA; completion action reuses the existing lifecycle path | Same shared implementation | No transfer-contract or lifecycle change; complete OWNER runtime/release acceptance only through its separate gate | The old export/import relocation scope is superseded by the binding export-only OWNER correction |
| Full backup/restore final rehearsal | `OPEN — BLOCKING FOR GATE` | Prior successful incidents are partial evidence | Prior scoped PASS is partial evidence | Current-tip, release-candidate, separate-platform final rehearsal with SCENARIO carrier | Prior restore does not close release gate |
| NALOG CVEĆARI | `CLOSED — ACCEPTED PDF-ONLY UNIT` | Accepted current PDF unit in the native PREDMET → DOKUMENTI route | Shared implementation | Preserve the accepted PDF-only scope; DOCX is not an open option | Older open-scope wording is superseded |
| Standard PDF typography | `HISTORICAL OPEN — V1.5 OBLIGATION SUPERSEDED` | Current documents exist | Shared generation | Further per-document refinement is not a v1.5 completion obligation; no new work is authorized | Previously listed as remaining product completeness |
| RAČUN toggle, DOCX and shared data model — normal-roadmap Member 3 | `COMPLETED — OWNER RUNTIME ACCEPTED; PUBLISHED` | FIRMA toggle is the sole availability condition for PDF and DOCX; both adapters consume one canonical RAČUN data model; snapshot action/exporter retired; Word 2019 direct open, one-page render and print/layout parity accepted | Same bounded PREDMET/FIRMA/IRiU/SAVETNIK-derived model | Preserve exact OWNER text/defaults, Article 33, Backup behavior and unchanged Single-PREDMET JSON; no broader FIRMA/legal inference | Published in commit `d5ec4350b143607068f430f9ae3d352aa578f0a0`. Final Word defect: nested signature-label table required a trailing paragraph; corrected with `_requiredTrailingParagraph()`; no broader document-set acceptance is implied |
| Windows light/dark theme | `COMPLETE — OWNER RUNTIME PASS` | Shared `ThemeMode.system` and owner runtime acceptance prove the supported light/dark behavior is closed | Owner runtime authority: `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED` | No further theme implementation, audit or roadmap dependency; reopen only for a proven regression or new owner decision | Older partial/pending theme wording is superseded |
| Full UI/UX audit | `HISTORICAL OPEN — V1.5 OBLIGATION SUPERSEDED` | Narrow correction/runtime evidence exists within named task scopes | Same; 2026-10-13 delta runtime accepted within executed scope and remains `PARTIAL` comprehensively | No broad v1.5 audit or correction is authorized; preserve unperformed checks as unverified | Runtime smoke is not full UX acceptance |
| Contextual Help/User Guide | `IMPLEMENTED — FINAL V1.5 TASK COMPLETED` | Final 33-chapter offline guide content, italic presentation and contextual help are integrated and accepted within the final v1.5 task | The accepted Android Narrow/Wide delta runtime confirms its executed scope; comprehensive chapter/context-route coverage remains `PARTIAL`, and no Windows physical runtime is claimed | No further v1.5 help implementation is authorized by this closure; preserve the stated runtime limits and treat any further work as a separately authorized task | Supersedes the earlier deferred product-direction entry; current evidence is in current-state §24, final-guide traceability and the accepted Android runtime package |
| MODUL DVE VALUTE | `CANCELLED AS V1.5 DEVELOPMENT OBLIGATION — NOT IMPLEMENTED` | Source-learning, authority reconciliation and implementation design remain historical preparation; product implementation not started | Same | Preserve the accepted preparation package; any future product decision requires separate OWNER authority and must not be inferred from this closure | No v1.5 implementation; no wholesale transfer or implementation under OPC Int is authorized |
| Progressive refactor / partial rewrite | `DEFERRED / EVIDENCE-GATED` | Some bounded refactors already landed | Shared | Only where stability, maintainability, parity or localization evidence requires it | Roadmap-wide refactor predecessor is superseded |
| Stage 2 package/licensing cleanup | `NON-BLOCKING BEFORE OPC v.1` | Dead compatibility code may remain | Same | Optional exact-scope cleanup; never restore restrictions | Not a gate predecessor |
| Final platform business-semantic parity | `OPEN — BLOCKING FOR GATE` | Separate final acceptance required | Separate final acceptance required | Release-candidate matrix including lifecycle, JSON, reminders, documents and currency; theme closure is already recorded | Scenario parity alone is insufficient |
| App identity/version/update channel | `OWNER DECISION REQUIRED — BLOCKING FOR GATE` | Installer/update identity unresolved | Current technical identity `com.tale.opc_v4`, `4.0.0+1` is fact, not final owner policy | Decide release identity/version/update channel; product name stays OPC | `OPC Srbija` must not become app name |
| First Product-Line Gate | `OPEN` | Required | Required | Close checklist in section 9 | Old gate wording was not actionable enough |
| `OPC_v.1_Int` and international profiles | `DEFERRED` | Not started | Not started | Begins only after First Product-Line Gate | No early localization implementation |
| Signing/professional handover | `POST-GATE / RELEASE CLOSURE` | Open | Open | Signing identity/key custody, release continuity, handover package | Still valid, sequenced after product decisions |

## 4. Required predecessors of stable OPC v.1

### 4.1 Release-risk integrity closure

1. Preserve the published Windows process-level single-instance ownership
   guard, which acquires the named mutex before Flutter, plugins and SQLite
   initialize. Its W1–W6 acceptance is closed. The separate installer/update protection is also closed by accepted Inno Setup AppMutex and I1/I2/I3 evidence; preserve its refusal of program-file replacement while OPC is running and non-mutation of canonical database identity/content. Reopen only for a proven regression or new owner decision.
2. Consolidate the remaining PREDMET dependency/referential work actually
   required for release. Do not reopen completed hard-delete, scoped restore or
   same-identity audit-history preservation work without a finding. Explicitly
   classify deferred anonymization, RI-3 recovery and FK enablement.
3. Include the explicit `ZAVRŠEN` lifecycle in final Windows and Android runtime
   semantic acceptance; focused tests alone do not create platform PASS.

### 4.2 Historical evidence-first performance proposal — no current v1.5 task

The following proposal was recorded before final OWNER acceptance. It does not
authorize a new v1.5 profiling/correction task. No performance target or
closure result is inferred from the current development acceptance.

- Windows: cold/warm process start to first window/usable screen, DB/open work,
  exit, and second-launch behavior.
- Android PARTE: module open, editing, media-heavy pan/zoom/drag, frame/jank
  evidence on at least representative weaker and middle device classes where
  available.
- IRiU/KATALOG: repository wait, first dialog frame, photo read and image decode.

Owner confirms an acceptance target after baseline evidence. If current
behavior meets the target, close by evidence with no code change.

### 4.3 SCENARIO carrier contract and separate release-evidence boundary

Production JSON integration implements the accepted carrier contract rather
than a second model:

- Single-PREDMET JSON carries the PREDMET snapshot and complete STAVKA
  provenance through transfer-index reassociation;
- full backup carries SCENARIO module definitions/defaults, PREDMET snapshots
  and provenance with preserved database identity semantics;
- `COMPLETE` and `UNAVAILABLE` remain distinct; unavailable provenance never
  permits automatic deletion;
- matching Single-PREDMET import offers explicit new/replace choice;
- newer roots fail closed on older clients; legacy inputs remain supported;
- preflight, transaction/rollback, Windows/Android round-trip and non-
  retroactivity are proven.

Source reality at this final-closure baseline: `json_export_import.dart` emits
the optional hashed Single-PREDMET snapshot/provenance carrier and full-backup
snapshot/provenance sections. Legacy schema 6/7 inputs remain readable without
claiming imported continuity; final platform round-trip acceptance remains a
release gate.

### 4.4 Historical remaining-product-completeness candidates — superseded

- preserve the accepted PDF-only NALOG CVEĆARI unit; DOCX is not an open option;
- standard PDF typography refinement is no longer a v1.5 completion obligation;
- a broad Windows/Android UI/UX audit is not authorized by this closure;
- contextual `Pomoć`/`Uputstvo` has since been implemented in the accepted final
  guide task; no further help implementation is authorized here.

## Bounded F-09 owner authority and Member 1 implementation — 2026-09-20

The current OWNER-authorized F-09 target is limited to two sibling children of
the FINANSIJE PRE-CEREMONY parent; both children are PRE-CEREMONY:

- `PLATITI RAČUN` exists exactly when
  `TROŠKOVI JKP > 0 AND jkpPlacaSamostalno == false`; no additional JKP payer
  identity/type field or other finance signal participates;
- `NAPLATITI OBAVEZE` derives when `ZA NAPLATU > 0`;
- both are manually completable and participate in the general REVIEW BAR
  while relevant and unfinished.

The earlier arrow notation is not a child ordering: neither obligation depends
on or precedes the other. OWNER separately selected and authorized this bounded
target as normal-roadmap Member 1; both rules are now implemented on the
generic obligation/reconciliation architecture. The shared receivable
calculation and generic input watch preserve live refresh without a finance-
specific parallel mechanism. Source/test/QA/build evidence is complete; runtime
acceptance, release and publication remain separate. The broader unspecified
FINANSIJE reminder scope remains deferred. This does not select a successor
member, create a broad PODSETNIK upgrade, or introduce new signal meanings.

## RAČUN toggle, shared document model and snapshot retirement — Member 3, 2026-09-21

OWNER resolved RAČUN availability for the bounded normal-roadmap Member 3:
the FIRMA `RAČUN` toggle is the only machine condition, with `DA` defaults for
new data, migrated existing data and legacy full Backup omission. Its exact
user information text is `Račun može da se formira ukoliko je pravno lice
preduzetnik i nije u sistemu PDV`; OPC does not evaluate legal status or add
preduzetnik/PDV fields. Article 33 remains `KEEP` content.

Separate adjacent RAČUN PDF and DOCX actions in `PREDMET → DOKUMENTI` share one
canonical RAČUN data model, availability condition and filename base. Full
Backup preserves the toggle; Single-PREDMET JSON is unchanged. The obsolete
`PREDMET PDF SNAPSHOT` is retired from the offer and production wiring. Technical
validation, both release builds and OWNER Word 2019 runtime/visual acceptance
passed; publication is complete in commit
`d5ec4350b143607068f430f9ae3d352aa578f0a0`. The proven Word defect was a nested
signature-label table without its required trailing paragraph, corrected with
`_requiredTrailingParagraph()`. For the common helper audit, NALOG CVEĆARI remains
unchanged and conformant; SPECIFIKACIJA TROŠKOVA, PREDRAČUN, LISTA, NALOG ZA
OPREMANJE and RAČUN were each left unchanged because equivalence was not proven.

## 5. SCENARIO closed contract

The following is current and protected:

- SCENARIO is under operational `MODULI`, not hidden `PODEŠAVANJA`;
- user-owned OSNOVNI PAKET plus scenario-specific additional package;
- 1,008 eight-axis scenario combinations backed by an independent golden;
- editable definitions and user-preserved edits;
- PREDMET facts are the sole source of scenario conditions;
- no user manual scenario selection/application; selecting an OPEN PREDMET in
  SCENARIO invokes the controlled production reconciliation boundary;
- current/derived state is distinct from the applied persisted snapshot;
- snapshot and scenario row provenance are PREDMET-owned;
- completed/historical snapshots are non-retroactive;
- additions/changes/removals are controlled; manual, legacy, unknown and other-
  module rows are protected;
- KATALOG stable identity and OSNOVNI/FIKSNA pricing are resolved at application;
- Windows and Android full eight-axis runtime acceptance passed;
- GRADSKO and LOKALNO remain distinct; the reported mismatch was not a defect.

No “future SCENARIO wiring,” direct PREDMET menu action, manual user application
button, or `PODEŠAVANJA` placement may be reintroduced from historical text.

## 6. Documents, JSON, theme and UX boundaries

This section preserves pre-closure constraints and evidence. Read it with §0
and the dated closure matrix; a historical proposal below does not reopen a
v1.5 correction task or contradict the accepted product state.

- Single-PREDMET JSON and full backup JSON remain distinct products.
- A restore success from an earlier artifact is evidence, not the final gate.
- RAČUN's FIRMA `RAČUN` toggle, PDF/DOCX pair, shared canonical data model,
  Backup preservation and unchanged Single-PREDMET JSON are implemented under
  Member 3. The toggle is the sole availability condition; the OWNER-approved
  Article 33 sentence remains in both outputs. Runtime/visual acceptance stays
  separate.
- NALOG CVEĆARI is an accepted PDF-only unit; DOCX is not an open option.
- Standard PDF typography refinement was a pre-closure candidate. It is no
  longer a v1.5 development obligation; no additional document-format or
  print-acceptance result is claimed.
- Windows light/dark theme is closed by explicit owner runtime authority:
  `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED`. Do not add a
  Windows-only selector or reopen a theme gate unless a new regression is
  proven or the owner issues a new decision.
- Working screens remain concise. Do not add explanatory prose to compensate
  for weak hierarchy, grouping, terminology or interactions.
- Contextual POMOĆ and the 33-chapter `RAD U APLIKACIJI` guide are implemented
  in the accepted final v1.5 state. No additional help implementation is
  authorized by this closure.

## 7. DVE VALUTE — historical preparation; implementation obligation superseded 2026-10-13

`DESIGN/PREPARATION COMPLETE — V1.5 IMPLEMENTATION OBLIGATION CANCELLED BY OWNER`

The completed preparation package records the current OWNER model without
creating implementation behavior:

- one durable operative currency per PREDMET; existing PREDMETI never change
  currency retroactively;
- ZAVRŠEN and ANONIMIZOVAN PREDMETI remain terminal/non-financially mutable;
- first RSD→EUR activation is controlled, manually initiated and blocked while
  mutable PREDMETI exist;
- the user-entered rate initializes parallel EUR KATALOG layers while the RSD
  layer is preserved; later KATALOG editing is independent;
- KATALOG→PREDMET price flow remains one-way and manual PREDMET/IRiU edits never
  update KATALOG;
- `PODEŠAVANJA → VALUTA` is the sole operative currency authority, while any
  KATALOG currency selector is view/edit only;
- documents use the stored PREDMET currency, and an EUR PREDMET must not emit a
  relabeled RSD NBS IPS QR.

The following choices had remained open in the old v1.5 finalization package:
rounding mode/scale/precision, conversion-rate provenance, transition wording,
KATALOG dual-currency presentation and preference persistence, EUR QR/payment
behavior, mixed-currency reporting, and later switching warnings. They are
retained as historical unresolved design, not active v1.5 obligations and not
automatically transferred to OPC Int. No implementation is authorized by this
closure.

## 8. Owner decision queue as of 2026-09-25 — superseded for v1.5 by OWNER closure

The following records the queue before the 2026-10-13 final product acceptance.
Its v1.5 development entries are historical; separate release/market decisions
remain separate from development closure.

| Decision | Earlier trigger / status | 2026-10-13 disposition |
| --- | --- | --- |
| Measurable acceptance targets after current-tip Windows startup/exit and Android PARTE profiling | Any performance correction acceptance — `OPEN OWNER DECISION` | No v1.5 correction task authorized; no target or performance result inferred. |
| DVE VALUTE finalization choices listed in section 7 | Final OPC v1.5 finalization — `DEFERRED WITH IMPLEMENTATION` | `CANCELLED AS A V1.5 DEVELOPMENT OBLIGATION`; design remains historical; implementation not authorized. |
| Final OPC app identity/version/update channel (name remains OPC) | First Product-Line Gate — `OPEN OWNER DECISION` | Remains a separate release/market decision; this task does not resolve it. |
| Release baseline branch/tag policy and publisher/signing-key custody | Release/handover closure — `OPEN OWNER DECISION` | Remains a separate release/handover decision; this task does not create a tag or signing identity. |

The exact F-09 triggers and child relationship are resolved OWNER meaning, not
an open decision-queue item. Their bounded implementation is complete under
the separately OWNER-selected Member 1 task; OWNER runtime/release acceptance
remains separate and broader unspecified FINANSIJE reminder scope remains
deferred. No new decision ID is created by this status reconciliation.

The following previously closed business decisions remain closed:

- `ZATVOREN/ZAVRŠEN` lifecycle and retirement of automatic completion;
- historical auto-completed behavior as a continuing automatic rule;
- SCENARIO placement, package model, PREDMET ownership, application and
  non-retroactivity;
- Windows/Android equality and system-theme rule;
- DVE VALUTE preparation is historical; its v1.5 implementation obligation is
  superseded by the later OWNER closure and is not moved to `OPC Int`;
- product name remaining `OPC`.

Pre-zero owner-decision indexes remain historical/navigation evidence under
the post-zero authority inventory. They are not silently promoted into this
active queue.

## 9. Separate First Product-Line / release gate — not equivalent to development closure

The following is a separate product-line/release gate, not this v1.5
development-closure checklist. Its remaining items are not silently declared
complete or cancelled by the OWNER's acceptance of current product behavior.
Conversely, listed historical feature/correction work is not renewed as a v1.5
implementation obligation.

- [ ] application name and visible product identity remain `OPC`;
- [ ] Windows and Android release builds come from the release baseline;
- [ ] Serbian Latin and Serbian Cyrillic support required by the current
      Serbian-market baseline are accepted;
- [ ] standalone local operation, SQLite ownership and canonical migration
      compatibility are proven;
- [ ] PREDMET authority and scenario history/provenance remain intact;
- [ ] 1,008 golden and production E2E remain green;
- [ ] Single-PREDMET and full-backup JSON carry SCENARIO state/provenance with
      legacy/fail-closed compatibility;
- [x] Installer/update running-app program-file protection passes I1–I3; native Windows single-instance is already closed by full acceptance;
- [ ] explicit completion and the full signal/PODSETNIK lifecycle pass;
- [x] DVE VALUTE is not a v1.5 development obligation under the 2026-10-13
      OWNER closure; no implementation is claimed or authorized;
- [ ] remaining required documents/policies are closed or explicitly classified;
- [x] Windows light/dark theme runtime behavior is owner-confirmed closed;
      final business-semantic parity remains a separate gate;
- [ ] final backup/restore rehearsal passes on release-candidate artifacts;
- [ ] analyze, full tests and release builds pass successively;
- [ ] known issues are divided into blockers and non-blocking debt;
- [ ] owner decides app identity/version/update channel;
- [ ] owner runtime acceptance is recorded separately for Windows and Android;
- [ ] release commit, branch/tag and rollback/handover evidence are recorded.

Stage 2 package/licensing cleanup is not a default predecessor.

## 10. Non-blocking debt and future evidence-gated work — no v1.5 successor selected

The following may remain after the stable OPC v.1 gate when explicitly recorded
and when no current evidence promotes it to a blocker:

- Stage 2 physical removal of dead package/licensing compatibility code;
- broad RI-3 orphan recovery or global FK enforcement not required by the final
  release rehearsal;
- progressive refactor of stable code without a concrete stability,
  maintainability, parity or localization need;
- further contextual-help or guide expansion beyond the accepted 33-chapter
  guide; no v1.5 follow-up task is selected or authorized;
- OPC Web research and implementation;
- international language/country/profile implementation.

Stable code is not rewritten for roadmap aesthetics.

## 11. OPC v.1 → OPC_v.1_Int boundary

`OPC Int` starts only after section 9 closes and the final product-line
finalization is complete. Before that gate there is no SRB implementation
change, international localization implementation, physical source fork,
country profile rollout or international release identity.

After the separate product-line gate, any architecture work or currency-design
reuse requires a new explicit OWNER roadmap item and authority. The 2026-10-13
closure does not transfer the prepared DVE VALUTE design wholesale to OPC Int
and does not authorize its implementation. Serbian Latin and Cyrillic remain
supported. Tax, VAT, fiscalization and legal-form policy still require
separate owner authority.

## 12. Historical provenance and superseded chronology

The pre-reconciliation plan at Git baseline
`78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9` preserves the complete original
Gate 0 and Phase 1–11 chronology. The following statements from that version
are historical only:

- Gate 0 closure/activation pending and `develop/opc-v1` as the next action;
- SCENARIO as hard-coded future configuration under `PODEŠAVANJA`;
- Phase 9 UI, Phase 10 pure planner and Phase 11 pure gate as current end state;
- “next dependency” being future PREDMET-side SCENARIO wiring;
- missing scenario snapshot/provenance as current architecture;
- SCENARIO Windows/Android runtime being pending;
- unresolved `ZATVOREN/ZAVRŠEN` business policy;
- broad progressive refactor/partial rewrite as a mandatory predecessor;
- wording that could imply the application should be renamed `OPC Srbija`.

Historical audit reports remain evidence and must not be rewritten to pretend
they knew later results.

## 13. Plan-change and anti-drift rules

Every future change to this plan records:

- exact base and final Git evidence;
- reason and source/runtime evidence;
- affected dependency and classification;
- owner-decision status;
- PREDMET, migration, JSON and platform-parity impact;
- changed authority documents;
- validation, commit, push, remote SHA and clean-tree result.

New incidental findings are classified as:

- `BLOCKING FOR OPC v.1`;
- `NON-BLOCKING BEFORE OPC v.1`;
- `BELONGS TO EXISTING FUTURE PROGRAM`;
- `HISTORICAL / NO ACTION`;
- `OWNER DECISION REQUIRED`.

A finding joins the correct existing program; it does not automatically create
a standalone patch task.

## 14. Stop conditions

Stop affected work when:

- owner business meaning is unresolved or would be silently changed;
- canonical data safety, backup/readability or rollback is not proven;
- PREDMET authority, locked history, JSON compatibility or platform parity is
  threatened;
- technical PASS is being presented as owner runtime PASS;
- a performance hypothesis is treated as a root cause without measurement;
- a pure contract/test is being presented as production wiring;
- completed SCENARIO work is being repeated without a new finding;
- an isolated PODSETNIK patch would pre-empt the complete signal/lifecycle model;
- `OPC Srbija` is being used to rename the application;
- The pre-closure DVE VALUTE sequencing statement is historical and superseded:
  its implementation is not a v1.5 obligation, and no wholesale transfer or
  implementation under `OPC Int` is authorized by the 2026-10-13 closure;
- Web, internationalization, tax, VAT or fiscalization enters current scope
  without the required gate and owner decision.

## LUNA recovery completion — 2026-08-13

The canonical data-recovery work is complete for this scope: the promoted
canonical DB is FK/integrity-clean, live PREDMET/IRiU business truth is
preserved, CITULJE deduplication and restore recurrence closure are proven,
and schema-9 clean backup/restore is semantically idempotent. Future work must
not reintroduce startup snapshot repair or category-specific KATALOG writers.

## RR-008 same-identity replacement completion

The replacement dependency seam now enforces `CURRENT PREDMET TRUTH → CURRENT
DERIVED STATE`: stale PARTE preparation/media is invalidated with recoverable
staging, reminder IDs are cancelled, and stale reminder state is reconciled
against current PREDMET truth. RR-008 does not define future PODSETNIK trigger,
scheduling or recreation semantics. Focused integration, analyzer, full-suite
and Windows release-build evidence pass; no architecture migration or SCENARIO
change is implied.
