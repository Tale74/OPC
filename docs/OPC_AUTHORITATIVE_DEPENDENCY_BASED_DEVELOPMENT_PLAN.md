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

### 2.2 Current one-line dependency order

**Documentation reconciliation → release-risk integrity closure (Windows
single-instance and remaining PREDMET/referential acceptance) → evidence-first
performance closure → SCENARIO JSON carrier parity → complete signal/lifecycle
model and full PODSETNIK upgrade → remaining JSON/document/theme/UI work →
MODUL DVE VALUTE → final Windows/Android business-semantic parity and
backup/restore rehearsal → app identity/version/update-channel decision → First
Product-Line Gate for stable OPC v.1 → optional non-blocking debt/Stage 2
cleanup → `OPC_v.1_Int` architecture/localization/country/multicurrency work →
signing and professional handover.**

This order replaces every older “next dependency” statement, including future
SCENARIO application wiring and SCENARIO-under-PODEŠAVANJA wording.

## 3. Reality matrix

| Program / dependency | Actual state | Windows | Android | Remaining work / dependency decision | Old premise |
| --- | --- | --- | --- | --- | --- |
| Documentation/continuity governance | `COMPLETED — TECHNICAL PASS` for zero-baseline classification; this reconciliation restores current sequencing | N/A | N/A | Maintain plan/report/current-state parity per task | Gate 0 activation wording is historical/superseded |
| Code/architecture review | `COMPLETED — TECHNICAL PASS` | N/A | N/A | Refactor only where evidence proves need | Mandatory broad rewrite/refactor is false |
| PREDMET authority/dependency protection | `PARTIAL` | Core truth and SCENARIO hand-off proven | Core truth and SCENARIO hand-off proven | Finish referential/lifecycle acceptance and carrier parity; do not reopen proven scenario ownership | Future snapshot/provenance premise is superseded |
| Database/referential integrity | `PARTIAL` | Hard-delete runtime PASS; scoped restore history exists | Hard-delete DB/isolation PASS; scoped restore PASS on prior artifact | Remaining RI owner gates, FK/orphan strategy if pursued, current-tip final rehearsal | Isolated PODSETNIK orphan patch is superseded by coordinated program |
| Windows single-instance | `OPEN — BLOCKING FOR OPC v.1` | No native guard | N/A | Implement locked named-mutex/installer coordination contract; runtime accept | “Audit pending” is false; audit done, implementation open |
| Windows startup/exit performance | `PARTIAL` | Installed baseline about 8–9 s to login; slow exit observed; current-tip instrumented acceptance absent | N/A | Measure current release lane, agree target, correct only proven bottlenecks if gate fails | Later runtime work does not prove performance closure |
| Android PARTE performance | `PARTIAL` | N/A | Source risks known; latest focused profiler/acceptance not performed | Reproduce/profile on representative devices; fix only if measured | No full/partial rewrite is authorized by source audit alone |
| IRiU/KATALOG performance | `PARTIAL` | Repository characterization exists; owner slowdown not decomposed | Same shared path; no measured platform acceptance | Separate repository, first-frame, photo read/decode timing before correction | Synthetic timing is diagnostic only |
| PREDMET `ZAVRŠEN` lifecycle | `COMPLETED — TECHNICAL PASS / RUNTIME OWED` | Focused runtime not separately recorded | Focused runtime not separately recorded | Include lifecycle in final platform semantic acceptance | Old unresolved lifecycle queue is superseded |
| SCENARIO implementation | `COMPLETED — TECHNICAL PASS` | See runtime row | See runtime row | Protect; do not repeat | Hard-coded/future-wiring chronology is superseded |
| SCENARIO Windows runtime | `COMPLETED — OWNER RUNTIME PASS` | PASS | N/A | Only regression protection | Future wiring premise false |
| SCENARIO Android runtime | `COMPLETED — OWNER RUNTIME PASS` | N/A | PASS on physical Android 15 device | Only regression protection | Runtime-pending premise false |
| SCENARIO JSON carriers | `PARTIAL — BLOCKING FOR OPC v.1` | Pure envelope/adapter contracts exist; production carrier not wired | Same shared implementation | Integrate snapshot + complete provenance into Single-PREDMET and full backup roots, schema bump/fail-closed old client, round-trip/rollback/parity proof | “Carrier support complete” would be false |
| KATALOG/IRiU price model | `COMPLETED — TECHNICAL PASS` | Build/technical evidence | Build/technical evidence | Include in final runtime business parity; do not redesign | Future FIKSNA/amount premise superseded |
| Completion/signal model | `OPEN` | Not complete | Not complete | Inventory all derived completeness/due/missed/lifecycle signals; owner confirms business meaning | Must precede full PODSETNIK |
| PODSETNIK full upgrade | `OPEN — REQUIRED PREDECESSOR` | In-app/notification behavior requires full model | OS notification exists; new notification for a `ZAVRŠEN` PREDMET is a retained finding | One lifecycle-aware informed-reminder program; no isolated status patch | Standalone reminder fix is rejected |
| Single-PREDMET JSON relocation | `OPEN` | Move export/import action to PREDMET three-dot menu | Same | Preserve schema/legacy behavior and separate from full backup | Still valid |
| Full backup/restore final rehearsal | `OPEN — BLOCKING FOR GATE` | Prior successful incidents are partial evidence | Prior scoped PASS is partial evidence | Current-tip, release-candidate, separate-platform final rehearsal with SCENARIO carrier | Prior restore does not close release gate |
| NALOG CVEĆARI | `OPEN — OWNER DECISION REQUIRED` | No standalone generator proven | No standalone generator proven | Source/business inventory, owner content and PDF/DOCX scope, then implementation/acceptance if required | “Nearly complete” is unsupported |
| Standard PDF typography | `OPEN` | Current documents exist | Shared generation | Per-document restrained refinement and visual/print acceptance; PARTE excluded | Still valid |
| PDF RAČUN availability/business scope | `PARTIAL — OWNER DECISION REQUIRED` | RAČUN PDF currently available under standard document entitlement | Same shared product behavior | Decide FIRMA availability/default and confirm present limited business scope; no VAT/tax/fiscal inference | “RAČUN absent” is false; availability-policy work remains |
| System theme parity | `PARTIAL` | Shared `ThemeMode.system` exists; Windows runtime parity audit not closed | System theme path exists | Verify runtime changes/contrast/accessibility; no Windows-only selector without proved obstacle + owner decision | “Implement theme” is false; verify existing behavior |
| Full UI/UX audit | `OPEN` | Only short SCENARIO impression | Only bounded runtime impressions | Full Windows/Android audit; concise working screens; hierarchy/terminology/interaction carry clarity | Runtime smoke is not full UX acceptance |
| Contextual Help/User Guide | `DEFERRED PRODUCT DIRECTION` | Not designed | Not designed | Evaluate screen-contextual `Pomoć`/`Uputstvo` after UX audit; no immediate implementation authority | New direction, not current task |
| MODUL DVE VALUTE | `OPEN — BLOCKING FOR OPC v.1` | Not implemented | Not implemented | Implement and prove contract in section 7 before product-line gate | Moving it to Int is prohibited |
| Progressive refactor / partial rewrite | `DEFERRED / EVIDENCE-GATED` | Some bounded refactors already landed | Shared | Only where stability, maintainability, parity or localization evidence requires it | Roadmap-wide refactor predecessor is superseded |
| Stage 2 package/licensing cleanup | `NON-BLOCKING BEFORE OPC v.1` | Dead compatibility code may remain | Same | Optional exact-scope cleanup; never restore restrictions | Not a gate predecessor |
| Final platform business-semantic parity | `OPEN — BLOCKING FOR GATE` | Separate final acceptance required | Separate final acceptance required | Release-candidate matrix including lifecycle, JSON, reminders, documents, currency and theme | Scenario parity alone is insufficient |
| App identity/version/update channel | `OWNER DECISION REQUIRED — BLOCKING FOR GATE` | Installer/update identity unresolved | Current technical identity `com.tale.opc_v4`, `4.0.0+1` is fact, not final owner policy | Decide release identity/version/update channel; product name stays OPC | `OPC Srbija` must not become app name |
| First Product-Line Gate | `OPEN` | Required | Required | Close checklist in section 9 | Old gate wording was not actionable enough |
| `OPC_v.1_Int` and international profiles | `DEFERRED` | Not started | Not started | Begins only after First Product-Line Gate | No early localization implementation |
| Signing/professional handover | `POST-GATE / RELEASE CLOSURE` | Open | Open | Signing identity/key custody, release continuity, handover package | Still valid, sequenced after product decisions |

## 4. Required predecessors of stable OPC v.1

### 4.1 Release-risk integrity closure

1. Implement Windows process-level single-instance ownership before Flutter,
   plugins and SQLite initialize. A second launch focuses the existing instance
   where reliable or exits safely with a clear message. Installer/update must
   refuse program-file replacement while OPC is running and must never modify
   canonical database identity/content.
2. Consolidate the remaining PREDMET dependency/referential work actually
   required for release. Do not reopen completed hard-delete or scoped restore
   work without a finding. Explicitly classify deferred anonymization,
   replacement, RI-3 recovery and FK enablement.
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

Source reality at this reconciliation baseline: the pure envelope and
Single-PREDMET adapter exist, but `json_export_import.dart` still emits
Single-PREDMET schema 6/7 and full-backup schema 8 without the SCENARIO carrier.

### 4.4 Complete signal model and PODSETNIK

Do not implement the observed `ZAVRŠEN` notification as an isolated patch.

First define the full derived signal model from PREDMET/SCENARIO/IRiU:

- empty/partial/complete and N/A/optional semantics;
- lifecycle eligibility;
- due/missed/completed/cancelled semantics;
- scenario-dependent required fields and IRiU exceptions;
- no parallel stored business truth.

Then implement one informed reminder program covering DB ownership, OS
scheduling/cancellation, restart/reboot, permission denial, duplicates, valid
tap target, restore/reschedule, and Windows/Android business parity. The Android
notification created for an already `ZAVRŠEN` PREDMET is an acceptance fixture
for this program.

### 4.5 Remaining product completeness

- relocate Single-PREDMET JSON to the PREDMET three-dot menu;
- decide and, if required, implement NALOG CVEĆARI content/output;
- refine standard PDF typography document by document;
- decide RAČUN FIRMA availability/default while preserving its current limited
  scope and avoiding VAT/tax/fiscal/legal inference;
- verify shared system-theme runtime parity;
- perform a full Windows/Android UI/UX audit;
- evaluate, but do not automatically implement, contextual `Pomoć`/`Uputstvo`.

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
- RAČUN PDF exists today. Open work concerns FIRMA availability/default and
  business scope, not recreation of the exporter.
- NALOG CVEĆARI remains unproven as a standalone generator and needs an owner
  content decision.
- Standard PDF typography work excludes PARTE and preserves document formation.
- Shared source already uses `ThemeMode.system`; close by runtime verification
  or a proven bounded correction, not by adding a Windows-only selector.
- Working screens remain concise. Do not add explanatory prose to compensate
  for weak hierarchy, grouping, terminology or interactions.
- Contextual help is a future design direction, not implementation authority.

## 7. MODUL DVE VALUTE — mandatory before OPC_v.1_Int

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
| NALOG CVEĆARI business content and PDF/DOCX scope | Its implementation/closure | `OPEN OWNER DECISION` |
| RAČUN FIRMA availability and default for existing installations | Availability-policy implementation | `OPEN OWNER DECISION` |
| Complete signal meanings used by informed reminders | PODSETNIK implementation | `OPEN OWNER DECISION` |
| EUR global activation timing and treatment/conversion of eligible open PREDMETI | Currency activation/release contract | `OPEN OWNER DECISION` |
| Final OPC app identity/version/update channel (name remains OPC) | First Product-Line Gate | `OPEN OWNER DECISION` |
| Release baseline branch/tag policy and publisher/signing-key custody | Release/handover closure | `OPEN OWNER DECISION` |

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
- [ ] Windows single-instance and installer/update database protection pass;
- [ ] explicit completion and the full signal/PODSETNIK lifecycle pass;
- [ ] MODUL DVE VALUTE passes Windows, Android, JSON and document formation;
- [ ] remaining required documents/policies are closed or explicitly classified;
- [ ] system-theme and final business-semantic parity pass separately on Windows
      and Android;
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
