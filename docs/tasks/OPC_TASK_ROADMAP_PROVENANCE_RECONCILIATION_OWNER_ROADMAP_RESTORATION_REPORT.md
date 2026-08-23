# OPC roadmap provenance reconciliation — owner roadmap restoration

Status: `ROADMAP PROVENANCE RECONCILIATION — PASS`

Date: 2026-08-23

This report is supporting evidence for the current authoritative development
plan. It does not create a second roadmap authority.

## 1. Authority and provenance method

The current evidence order is:

1. later explicit owner decisions and instructions;
2. current source and protecting tests;
3. latest scoped runtime/task evidence;
4. the dependency plan for ordering and release controls;
5. older reports and history.

The original post-zero owner roadmap is reconstructed from:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_DRAFT.md`, dated
  2026-07-23 and explicitly marked owner-review required;
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_FINAL_CANDIDATE.md`
  and its owner-review findings;
- the revised-plan publication at Git commit
  `36368c9b7b20adde17b2ec9d61aa82083e188976`;
- `docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`;
- current product/domain, current-state, quality/release and source-of-truth
  homes;
- later explicit owner decisions recorded in current authority and accepted
  runtime/source baselines.

The draft/final-candidate documents are provenance, not authority by
themselves. The current plan remains an ordering/control document and may not
invent product scope.

### Later explicit owner additions and changes

The later owner-controlled decisions that legitimately changed or clarified
the roadmap are:

- `PREDMET` remains the sole business truth and SCENARIO belongs to the
  concrete PREDMET; FIRMA defaults/templates act prospectively.
- Existing scenarios are user-editable after correction; completed PREDMETI do
  not receive retroactive scenario/KATALOG changes.
- Windows and Android remain equal standalone local applications with the same
  business result; OPC Web is outside current scope.
- Automatic completion was retired in favor of explicit lifecycle handling;
  detailed lifecycle/reopen treatment remains owner-gated where unresolved.
- PAKETI restrictions remain retired for the current native product; Stage 2 is
  later non-blocking cleanup.
- The product name remains `OPC`; Serbian Latin and Serbian Cyrillic are part
  of the Serbian-market baseline and Albanian is excluded from the later
  multilingual direction.
- MODUL DVE VALUTE remains required before stable OPC v.1; EUR activation
  timing and treatment of open PREDMETI remain owner decisions.
- The later engineering-standardization decision made the composite profile,
  proportional QA, traceability and documentation controls permanent support
  for the owner roadmap.

The accepted same-FIRMA responsibility transfer, session refresh, corrected
Windows packaging and bounded Windows backup/restore are later
incident/acceptance corrections and baselines. They are not new product
roadmap features and do not authorize reopening closed behavior.

## 2. Reconstructed owner roadmap matrix

| Owner-planned item / apparent item | Provenance | Primary class | Current status | Necessary remaining work | Disposition |
| --- | --- | --- | --- | --- | --- |
| Serbian-market OPC v.1 product-line stabilization and gate | Original Program F / Phase 1 product-line gate; later owner decision retains `OPC` name and Serbian-market boundary | `OWNER-PLANNED` | `OPEN` | Complete its genuinely required product work and attached release controls; owner decides final identity/version/update channel | Remains primary product destination |
| PREDMET authority, lifecycle and configurable SCENARIO | Original Programs A/B; later owner decisions lock PREDMET ownership, prospective defaults, editable scenarios and explicit completion | `OWNER-PLANNED` | `PARTIAL` | Protect closed SCENARIO/runtime baseline; close production carrier round-trip and owed lifecycle runtime evidence | Product work remains, but technical core is not reopened |
| Complete PODSETNIK and derived completion/signal model | Original Program C; current owner-decision pseudocode keeps signal meanings open | `OWNER-PLANNED` | `OWNER DECISION REQUIRED` | Owner-confirm signal semantics, then implement one lifecycle-aware reminder program | Recommended next package is the bounded signal-model decision/contract package |
| Single-PREDMET JSON UX relocation | Original Program D1; current plan still records relocation as open | `OWNER-PLANNED` | `OPEN` | Move action to PREDMET menu without schema change; preserve legacy/interchange tests | Remains next-stage product work |
| NALOG CVEĆARI | Original Program D2 | `OWNER-PLANNED` | `OWNER DECISION REQUIRED` | Owner defines business content and PDF/DOCX scope before implementation | Remains later product work |
| Standard PDF/document refinement | Original Program D3; PARTE explicitly excluded | `OWNER-PLANNED` | `OPEN` | Per-document typography/render acceptance | Remains product-completeness work |
| RAČUN availability policy | Original Program D4; later owner decision keeps it availability-only with no tax/legal inference | `OWNER-PLANNED` | `OWNER DECISION REQUIRED` | Decide existing-installation default, then bounded implementation if required | Remains owner-gated product work |
| Full Windows/Android UI/UX review | Original Program E2 | `OWNER-PLANNED` | `OPEN` | Evidence-first cross-platform audit; no automatic redesign | Remains product work, not a current implementation mandate |
| Windows system theme behavior | Original Program E1; later owner runtime decision closed it | `OWNER-PLANNED` | `CLOSED` | Reopen only for regression | Do not re-add to active roadmap |
| Progressive refactor / architecture decision gate | Original Program E3/E4 and later engineering standardization | `ENGINEERING-STANDARDIZATION SUPPORT` | `EVIDENCE-GATED` | Refactor only for a proven maintainability/stability boundary; full rewrite requires owner decision | Not a standalone product predecessor |
| MODUL DVE VALUTE | Original Program G2 / later locked pre-`OPC_v.1_Int` owner direction | `OWNER-PLANNED` | `OPEN` | Implement/prove RSD/EUR contract; owner decides activation timing and open-PREDMET treatment | Blocking before stable OPC v.1, but not next before signal semantics |
| Future multilingual `OPC_v.1_Int` | Original Program G3; later owner direction starts only after stable OPC v.1 | `OWNER-PLANNED` | `DEFERRED` | Architecture/localization/country-profile decision after Serbia gate | Not current scope |
| Signing, publisher custody and professional handover | Original Program H; release closure control | `RELEASE / ACCEPTANCE CONTROL` | `POST-GATE` | Signing identity, custody, provenance and handover package after product-line gate | Not a product feature or current predecessor |
| Remaining referential/lifecycle/FK/RI-3/anonymization work | Technical findings and plan reality matrix, not an owner feature | `TECHNICAL PRECONDITION` | `PARTIAL` | Keep only items proven necessary for a named owner item or release gate; defer broad FK/RI-3/anonymization without such proof | Attached to PREDMET/Serbia release; not standalone roadmap work |
| Repaired KATALOG→IRiU visual/runtime proof | Concrete runtime/release evidence gap | `TECHNICAL PRECONDITION` | `EVIDENCE INCOMPLETE` | Prove only the named repaired artifact and protected-lane behavior required by the Serbia gate | Attached to Serbia gate; not a feature |
| SCENARIO JSON carrier round-trip | Source/test and release-risk evidence | `TECHNICAL PRECONDITION` | `OPEN` | Integrate/prove production roots, rollback and Windows/Android round-trip | Parent: SCENARIO/PREDMET product and Serbia gate |
| Current-tip Windows/Android performance measurement | Original plan acceptance support, not a feature | `TECHNICAL PRECONDITION` | `OWNER DECISION REQUIRED` | Measure first; owner sets target; correct only if target fails | Parent: Serbia gate/UI/UX; no speculative profiling program |
| Final release-candidate backup/restore rehearsal | Product-line acceptance checklist | `RELEASE / ACCEPTANCE CONTROL` | `OPEN` | Run after its named carrier/parity/referential prerequisites | Parent: Serbian-market product-line gate |
| Final Windows/Android semantic parity | Product-line acceptance criterion | `RELEASE / ACCEPTANCE CONTROL` | `OPEN` | Execute the applicable final matrix after product work is ready | Parent: Serbian-market product-line gate |
| App identity/version/update channel | Later explicit owner decision queue | `OWNER DECISION REQUIRED` | `OWNER DECISION REQUIRED` | Decide name/version/update/baseline policy; current technical IDs are facts only | Parent: Serbian-market product-line gate |
| V1 harness, engineering profile and documentation controls | Later owner decision to standardize OPC engineering | `ENGINEERING-STANDARDIZATION SUPPORT` | `CLOSED / CONTINUOUS` | Apply proportionately; retain zero-orphan and evidence controls | Governs how work is done, not what product is required |
| Accepted responsibility/session/backup corrections | Concrete incidents and owner/runtime evidence | `INCIDENT-DERIVED CORRECTION` | `CLOSED` | Protect against regression; do not reopen without evidence | Attached corrections, not new roadmap features |
| Stage 2 package/licensing cleanup | Later technical cleanup direction | `TECHNICAL DEBT — NON-BLOCKING` | `DEFERRED` | Optional bounded cleanup after module-boundary evidence | Outside critical path |
| Broad standalone RI-3/FK program, broad rewrite, immediate Android parity, isolated PODSETNIK patch, or signing/distribution before the product gate | No current owner provenance or proven immediate necessity as standalone work | `UNJUSTIFIED ROADMAP ADDITION` | `REMOVED FROM ACTIVE ROADMAP` | Preserve evidence; reintroduce only with owner parent and proof | Must not drive sequencing |
| Withdrawn synthetic transfer/incident claims and obsolete Gate 0/future-SCENARIO wording | Historical reports and superseded plan text | `HISTORICAL / SUPERSEDED` | `PRESERVE ONLY` | None; current authority explicitly supersedes them | Not active work |

## 3. Reverse-coverage result

Every original owner-program item is represented above:

- Program A integrity/lifecycle and performance items are represented as
  technical prerequisites or acceptance controls attached to the Serbia gate,
  PREDMET/SCENARIO or PODSETNIK parent.
- Program B SCENARIO/PREDMET work is represented as owner-planned product work
  with carrier/lifecycle controls attached.
- Program C PODSETNIK/signals is represented as the next owner-planned item,
  currently blocked only by the unresolved owner meaning decision.
- Program D JSON, NALOG, PDF and RAČUN work is represented individually.
- Program E theme, UI/UX and refactor work is represented with theme closed and
  refactor classified as engineering support.
- Program F Serbian-market product-line stabilization and gate is represented
  as the primary product destination.
- Program G currency and later multilingual work is represented with the
  correct gate/deferred status.
- Program H signing and handover is represented as post-gate release control.

No owner-planned item was silently dropped. Owner-intent orphan count: `0`.

## 4. Roadmap inflation finding

The current apparent queue grew when technical audits, incident corrections,
acceptance controls and release evidence were written as sequential roadmap
items. The work was often legitimate, but its control-plane class was lost.
The correction is classification and parent linkage, not deletion of evidence:

- audits and standards remain support for planned product work;
- build/runtime/parity/backup/signing items remain gates attached to a parent;
- concrete incident fixes remain bounded corrections;
- unresolved business meanings stop at owner decision;
- non-blocking debt remains visible outside the critical path;
- unsupported standalone chains are removed from active sequencing.

## 5. Corrected owner roadmap

### OWNER ROADMAP — NOW

`PODSETNIK / completion-signal model owner-decision and contract package`

This is the next coherent owner-planned package because the original roadmap
places the complete PODSETNIK/signal program before its implementation, and
current authority proves that the signal meanings remain unresolved. It should
produce the owner decision matrix, PREDMET/SCENARIO/IRiU traceability and a
bounded contract; it must not implement notifications or invent business
semantics.

### OWNER ROADMAP — NEXT

1. Implement and accept the lifecycle-aware PODSETNIK/reminder program after
   the signal contract is owner-approved.
2. Complete remaining approved JSON/document/UI work: Single-PREDMET menu
   relocation, NALOG CVEĆARI, standard PDF refinement, RAČUN policy and full
   Windows/Android UI/UX review.
3. Implement and prove MODUL DVE VALUTE for stable OPC v.1.
4. Close the Serbian-market product-line gate, including the attached release
   controls and final semantic parity.

### LATER / OWNER DECISION

- app identity/version/update channel and release-baseline policy;
- multilingual `OPC_v.1_Int` architecture and product identity;
- publisher/signing-key custody and handover decisions;
- contextual `Pomoć/Uputstvo` direction after UX evidence.

### ATTACHED TECHNICAL / RELEASE CONTROLS

Only when demonstrably necessary for a named parent:

- PREDMET/referential/lifecycle/repaired-state evidence for the Serbia gate;
- SCENARIO carrier round-trip and rollback proof for SCENARIO/Serbia gate;
- current-tip performance measurement for Serbia/UI/UX acceptance;
- final semantic parity, release-candidate backup/restore and artifact
  identity controls for the Serbia gate;
- V1 engineering-profile, QA, traceability and documentation controls for all
  planned work.

### NON-BLOCKING TECHNICAL DEBT

Stage 2 cleanup, broad refactor without a failing boundary, broad RI-3/FK
expansion, cosmetic work and future Web work remain outside the critical path.

### HISTORICAL / SUPERSEDED / REMOVED FROM ACTIVE ROADMAP

Withdrawn incident claims, obsolete Gate 0 activation wording, future-SCENARIO
placement assumptions, isolated PODSETNIK patches and unsupported standalone
technical chains remain available only for provenance.

## 6. Standards-chain boundary

The composite engineering chain remains active:

`business/domain → requirements/traceability → architecture/data contract → implementation → verification → runtime/acceptance → quality/release → current-state documentation`

It governs how an owner-planned item is safely performed and proven. It does
not independently decide what OPC product features the owner must build.

## 7. Closure validation

- Owner roadmap reverse coverage: `PASS — ZERO ORPHANS`.
- Additional technical items have parent linkage or are demoted/removed.
- Historical/superseded items are not active instructions.
- Standards remain active and subordinate to owner product scope.
- Current Git/source facts are not rewritten for documentation convenience.
- No product source, test, runtime or database mutation occurred.
- No commit or push occurred.

Final status:

`ROADMAP PROVENANCE RECONCILIATION — PASS`

`OWNER PRODUCT ROADMAP — RESTORED AS PRIMARY DEVELOPMENT CONTROL`

`TECHNICAL / STANDARDIZATION / RELEASE WORK — RECLASSIFIED AS SUBORDINATE SUPPORT WHERE APPLICABLE`

`OWNER ROADMAP COVERAGE — ZERO ORPHANS`

`UNJUSTIFIED ROADMAP EXPANSION — REMOVED FROM ACTIVE CONTROL`

`NEXT WORK PACKAGE — DERIVED FROM OWNER ROADMAP / PROVEN NECESSITY`
