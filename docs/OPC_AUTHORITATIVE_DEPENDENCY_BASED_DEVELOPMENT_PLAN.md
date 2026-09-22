# OPC — authoritative dependency-based development plan

**Status:** `CURRENT OPERATIVE DEPENDENCY MAP`

**Reality-reconciliation baseline:** `78e04f40a6e4448fe8e4f9b2bfd1ef671a34a6d9`

**Reconciled:** 2026-08-12

**Application name:** `OPC`

**Market gate:** stable OPC v.1 for the Serbian market

**Later product-line working identity:** `OPC_v.1_Int`

This document is the current control plane for remaining OPC development. It
supersedes stale status and sequencing statements in its pre-reconciliation
version while preserving their owner decisions and audit provenance through
Git history at the baseline SHA above and through section 12 below.

It is an ordering and release-control document, not an authority to create new
owner product requirements. Product scope comes from the reconstructed owner
roadmap and later explicit owner decisions; technical findings must remain
attached to a named owner-planned item or be classified outside the active
roadmap.

`OPC Srbija` is planning shorthand only for the Serbian-market product-line
gate. It is not the product name and must not be added to application UI,
package-facing identity, installer identity or documentation as a rename.

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

The locked product-line prerequisite relationship remains:

**MODUL DVE VALUTE → stable OPC v.1 product-line gate → later
`OPC_v.1_Int` work → signing and professional handover.**

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
established product-line boundary; this plan does not reorder them.

### 2.5 Later, non-blocking and historical classifications

`OPC_v.1_Int`, app identity/version/update decisions, signing/handover,
contextual help and Stage 2 cleanup retain their later/deferred status. Broad
RI-3/FK expansion, broad rewrite, isolated PODSETNIK patches and other
unparented technical chains are not active roadmap items. Historical withdrawn
transfer claims and obsolete Gate 0/future-SCENARIO wording remain provenance
only.

## 3. Reality matrix

| Program / dependency | Actual state | Windows | Android | Remaining work / dependency decision | Old premise |
| --- | --- | --- | --- | --- | --- |
| Documentation/continuity governance | `COMPLETED — TECHNICAL PASS` for zero-baseline classification; this reconciliation restores current sequencing | N/A | N/A | Maintain plan/report/current-state parity per task | Gate 0 activation wording is historical/superseded |
| Code/architecture review | `COMPLETED — TECHNICAL PASS` | N/A | N/A | Refactor only where evidence proves need | Mandatory broad rewrite/refactor is false |
| PREDMET authority/dependency protection | `PARTIAL` | Core truth and SCENARIO hand-off proven | Core truth and SCENARIO hand-off proven | Finish referential/lifecycle acceptance and carrier parity; do not reopen proven scenario ownership | Future snapshot/provenance premise is superseded |
| Database/referential integrity | `PARTIAL` | Hard-delete runtime PASS; scoped restore history exists | Hard-delete DB/isolation PASS; scoped restore PASS on prior artifact | Remaining RI owner gates, FK/orphan strategy if pursued, current-tip final rehearsal | Isolated PODSETNIK orphan patch is superseded by coordinated program |
| Windows single-instance | Native singleton and installer/update protection `CLOSED — FULL ACCEPTANCE PASS` | Native `Local\\OPC_ORGANIZATOR_POGREBNE_CEREMONIJE_SINGLE_INSTANCE` guard is published and accepted; Inno Setup declares the same mutex with `CloseApplications=no` | Native W1–W6 PASS; Inno Setup compile and I1/I2/I3 PASS | None — RR-012 closed; reopen only for proven regression | Native singleton and installer protection remain separate controls |
| Windows startup/exit performance | `PARTIAL` | Installed baseline about 8–9 s to login; slow exit observed; current-tip instrumented acceptance absent | N/A | Measure current release lane, agree target, correct only proven bottlenecks if gate fails | Later runtime work does not prove performance closure |
| Android PARTE performance | `PARTIAL` | N/A | Source risks known; latest focused profiler/acceptance not performed | Reproduce/profile on representative devices; fix only if measured | No full/partial rewrite is authorized by source audit alone |
| IRiU/KATALOG performance | `PARTIAL` | Repository characterization exists; owner slowdown not decomposed | Same shared path; no measured platform acceptance | Separate repository, first-frame, photo read/decode timing before correction | Synthetic timing is diagnostic only |
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
| Standard PDF typography | `OPEN` | Current documents exist | Shared generation | Per-document restrained refinement and visual/print acceptance; PARTE excluded | Still valid |
| RAČUN toggle, DOCX and shared data model — normal-roadmap Member 3 | `COMPLETED — OWNER RUNTIME ACCEPTED; PUBLISHED` | FIRMA toggle is the sole availability condition for PDF and DOCX; both adapters consume one canonical RAČUN data model; snapshot action/exporter retired; Word 2019 direct open, one-page render and print/layout parity accepted | Same bounded PREDMET/FIRMA/IRiU/SAVETNIK-derived model | Preserve exact OWNER text/defaults, Article 33, Backup behavior and unchanged Single-PREDMET JSON; no broader FIRMA/legal inference | Published in commit `d5ec4350b143607068f430f9ae3d352aa578f0a0`. Final Word defect: nested signature-label table required a trailing paragraph; corrected with `_requiredTrailingParagraph()`; no broader document-set acceptance is implied |
| Windows light/dark theme | `COMPLETE — OWNER RUNTIME PASS` | Shared `ThemeMode.system` and owner runtime acceptance prove the supported light/dark behavior is closed | Owner runtime authority: `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED` | No further theme implementation, audit or roadmap dependency; reopen only for a proven regression or new owner decision | Older partial/pending theme wording is superseded |
| Full UI/UX audit | `OPEN` | Only short SCENARIO impression | Only bounded runtime impressions | Full Windows/Android audit; concise working screens; hierarchy/terminology/interaction carry clarity | Runtime smoke is not full UX acceptance |
| Contextual Help/User Guide | `DEFERRED PRODUCT DIRECTION` | Not designed | Not designed | Evaluate screen-contextual `Pomoć`/`Uputstvo` after UX audit; no immediate implementation authority | New direction, not current task |
| MODUL DVE VALUTE | `OPEN — BLOCKING FOR OPC v.1` | Not implemented | Not implemented | Implement and prove contract in section 7 before product-line gate | Moving it to Int is prohibited |
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

### 4.2 Evidence-first performance closure

Performance work starts with current-tip release measurements. It does not
start with a presumed refactor.

- Windows: cold/warm process start to first window/usable screen, DB/open work,
  exit, and second-launch behavior.
- Android PARTE: module open, editing, media-heavy pan/zoom/drag, frame/jank
  evidence on at least representative weaker and middle device classes where
  available.
- IRiU/KATALOG: repository wait, first dialog frame, photo read and image decode.

Owner confirms an acceptance target after baseline evidence. If current
behavior meets the target, close by evidence with no code change.

### 4.3 SCENARIO carrier parity

Production JSON integration must implement the already accepted carrier
contract rather than invent a second model:

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

### 4.4 Remaining product completeness

- preserve the accepted PDF-only NALOG CVEĆARI unit; DOCX is not an open option;
- refine standard PDF typography document by document;
- perform a full Windows/Android UI/UX audit;
- evaluate, but do not automatically implement, contextual `Pomoć`/`Uputstvo`.

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

- Single-PREDMET JSON and full backup JSON remain distinct products.
- A restore success from an earlier artifact is evidence, not the final gate.
- RAČUN's FIRMA `RAČUN` toggle, PDF/DOCX pair, shared canonical data model,
  Backup preservation and unchanged Single-PREDMET JSON are implemented under
  Member 3. The toggle is the sole availability condition; the OWNER-approved
  Article 33 sentence remains in both outputs. Runtime/visual acceptance stays
  separate.
- NALOG CVEĆARI is an accepted PDF-only unit; DOCX is not an open option.
- Standard PDF typography work excludes PARTE and preserves document formation.
- Windows light/dark theme is closed by explicit owner runtime authority:
  `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED`. Do not add a
  Windows-only selector or reopen a theme gate unless a new regression is
  proven or the owner issues a new decision.
- Working screens remain concise. Do not add explanatory prose to compensate
  for weak hierarchy, grouping, terminology or interactions.
- Contextual help is a future design direction, not implementation authority.

## 7. MODUL DVE VALUTE — required predecessor of stable OPC v.1

`LOCKED OWNER DECISION — REQUIRED PREDECESSOR OF STABLE OPC v.1`

One runtime-capable module must support:

1. initial `RSD primary / EUR informative`;
2. later owner-controlled `EUR primary / RSD informative` activation without a
   new coding/build cycle.

Required contract:

- FINANSIJE may optionally show informative EUR;
- manual rate is `1 EUR = ___ RSD`;
- informative EUR equals `RSD / kurs`;
- informative display never mutates authoritative business amounts;
- FIRMA has an owner-controlled global primary mode;
- every PREDMET persists its primary currency, relevant rate/date/provenance and
  history needed for stable documents;
- open-PREDMET conversion is explicit and controlled; locked history is stable;
- Windows, Android and JSON semantics are equal;
- RSD and EUR document formation is prepared before activation;
- no automatic external exchange rate;
- no VAT, tax or fiscalization implication.

Open owner decisions: activation timing and the permitted treatment of PREDMETI
that are open at activation. `OPC_v.1_Int` later reuses/extends this proven
contract for country and multicurrency profiles.

## 8. Active owner decision queue

Only unresolved current decisions are active:

| Decision | Needed before | Status |
| --- | --- | --- |
| Measurable acceptance targets after current-tip Windows startup/exit and Android PARTE profiling | Any performance correction acceptance | `OPEN OWNER DECISION` |
| EUR global activation timing and treatment/conversion of eligible open PREDMETI | Currency activation/release contract | `OPEN OWNER DECISION` |
| Final OPC app identity/version/update channel (name remains OPC) | First Product-Line Gate | `OPEN OWNER DECISION` |
| Release baseline branch/tag policy and publisher/signing-key custody | Release/handover closure | `OPEN OWNER DECISION` |

The exact F-09 triggers and child relationship are resolved OWNER meaning, not
an open decision-queue item. Their bounded implementation is complete under
the separately OWNER-selected Member 1 task; OWNER runtime/release acceptance
remains separate and broader unspecified FINANSIJE reminder scope remains
deferred. No new decision ID is created by this status reconciliation.

Removed from the active queue as already decided:

- `ZATVOREN/ZAVRŠEN` lifecycle and retirement of automatic completion;
- historical auto-completed behavior as a continuing automatic rule;
- SCENARIO placement, package model, PREDMET ownership, application and
  non-retroactivity;
- Windows/Android equality and system-theme rule;
- MODUL DVE VALUTE belonging before `OPC_v.1_Int`;
- product name remaining `OPC`.

Pre-zero owner-decision indexes remain historical/navigation evidence under
the post-zero authority inventory. They are not silently promoted into this
active queue.

## 9. First Product-Line Gate — stable OPC v.1

The gate closes only when every required item is evidenced:

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
- [ ] MODUL DVE VALUTE passes Windows, Android, JSON and document formation;
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

## 10. Non-blocking debt and evidence-gated work

The following may remain after the stable OPC v.1 gate when explicitly recorded
and when no current evidence promotes it to a blocker:

- Stage 2 physical removal of dead package/licensing compatibility code;
- broad RI-3 orphan recovery or global FK enforcement not required by the final
  release rehearsal;
- progressive refactor of stable code without a concrete stability,
  maintainability, parity or localization need;
- contextual help implementation beyond an accepted design;
- OPC Web research and implementation;
- international language/country/profile implementation.

Stable code is not rewritten for roadmap aesthetics.

## 11. OPC v.1 → OPC_v.1_Int boundary

`OPC_v.1_Int` starts only after section 9 closes. Before that gate there is no
international localization implementation, physical source fork, country
profile rollout or international release identity.

After the gate, architecture work may define shared core/profiles/flavors and
add supported languages/country/document/business-policy profiles. Serbian
Latin and Cyrillic remain supported. The proven dual-currency contract is
extended rather than duplicated. Tax, VAT, fiscalization and legal-form policy
still require separate owner authority.

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
- dual currency is being deferred to `OPC_v.1_Int`;
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
