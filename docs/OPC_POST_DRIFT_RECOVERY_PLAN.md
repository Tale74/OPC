# OPC Post-Drift Recovery Plan

**Status:** `CURRENT RECOVERY-PHASE GOVERNANCE CONTROL`

This document is the canonical continuity and governance plan for the current
post-drift recovery phase. It records the established recovery lineage and
controls task ordering; it does not create new product requirements or replace
the detailed residual, deferred or evidence records.

## 1. Continuation baseline

The continuation baseline is the protected recovered/current SOURCE at:

`C:\Projekti\OPC\OPC v.1\SOURCE`

It remains a mixed local working state. Its current protection and provenance
are evidenced by the current external active-source control package. The
protected recovered-baseline package SHA is:

`5241576752D8F3954D741A3AC0CEEF089863F5AAC2E30F72354264C4FE9ABE5A`

The current active 27-row high-risk baseline SHA is a separate control-file
identity, resolved from the current external package/current-state authority:

`4C974501426B2C9713C67AC8A08812651C66C35B2A475DC227B1FB6450D08E93`

The current external active control package is:

`C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-HIGH-RISK-ACTIVE-BASELINE-CONTROLLED-REBASELINE-20260917-PHASE1-PDF05-CLOSURE\`

Its enclosing ZIP SHA-256 is:

`B550645672750630B5403CE5CB404331CCBCAB7538777325E931A66946D6E27E`

Its PACKAGE_MANIFEST.json SHA-256 is:

`3F0DF0D85D318B775E886B51D94060817541A3120F01B4DF16F8B1B1DFC1D9EA`

Its 04_ACTIVE_SOURCE_AUTHORITY_MANIFEST.json SHA-256 is:

`FF38630EC8E10B4B83FDA835B9964024D058E77D00AB6DDF80B6F72CB8ACE694`

The immediate predecessor package was
`OPC-HIGH-RISK-ACTIVE-BASELINE-CONTROLLED-REBASELINE-20260916-PHASE1-POD05-NARROW-CLOSURE`,
with baseline SHA-256 `8018E994401ACC9D0056C05696E8C110FE4458D2263C3EF7071D319B9D7CC3CF`,
PACKAGE_MANIFEST.json SHA-256 `BDB24A8F73861B5200962689D4DBE9E0253DC142B254E822F60C53EFE8E30B5C`,
and ZIP SHA-256 `B6B2D92F8ED24633F972D36AC79B24B9DEEDCF7398C35ADFB721A8D0388916CE`.
Its predecessor identities remain preserved in the successor handoff. The
predecessor ZIP physical status remains exactly:
`PREDECESSOR ZIP PHYSICAL RE-VERIFICATION — NOT AVAILABLE`.

These are distinct artifacts and identities. The pre-control-hardening
published documentation reference at task start was:

`0ec0c7356851f792e53a8198573890cb1274b4e0`

Later authorized documentation publication may supersede that reference. It
does not represent publication of the complete mixed SOURCE implementation;
documentation synchronization and implementation publication remain separate
gates.

The active-source package is current local-only control evidence. It is not
implementation authority and is not a donor. `SOURCE/REVIEW` must remain
absent; `SOURCE/runtime_data` and `SOURCE/.audit_tmp` remain
`UNRESOLVED – DO NOT USE`.

## 2. Established recovery lineage

The plan preserves the existing sequence and accepted handoffs:

1. The mixed/provenance-drift condition was identified and bounded.
2. Current-state restoration reconciliation established the recovered/current
   SOURCE continuation baseline.
3. The bounded Domains 1–6 restoration implementation was completed at the
   source/test/documentation level.
4. The formal Windows restoration lane reached
   `CURRENT OPC RESTORATION — WINDOWS BUILD PASS — OWNER RUNTIME EVIDENCE REQUIRED`.
   That package was not upgraded to general runtime PASS.
5. The recovered baseline was protected and its residual findings were
   preserved.
6. Active-source, stale-donor and authority-hygiene controls were established.
7. Current authoritative documentation was synchronized through the accepted
   documentation chain.
8. Deferred current-supporting documentation paths were reconciled without
   promoting historical or local-only material to authority.
9. Residual corrective development proceeded under the protected baseline.
10. The bounded REVIEW BAR corrective implementation and later OWNER runtime
    acceptance were completed.

The detailed evidence remains in the accepted external handoffs, including:

- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-CURRENT-STATE-RESTORATION-RECONCILIATION\14_FINAL_RECONCILIATION_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-CURRENT-STATE-RESTORATION-IMPLEMENTATION\20_FINAL_IMPLEMENTATION_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-CURRENT-STATE-RESTORATION-WINDOWS-RUNTIME-ACCEPTANCE\17_FINAL_WINDOWS_RUNTIME_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-CURRENT-RECOVERED-BASELINE-PROTECTION_FINAL9\13_FINAL_BASELINE_PROTECTION_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-RECOVERED-BASELINE-AUTHORITY-HYGIENE-DOCUMENTATION-SYNC\13_FINAL_DOCUMENTATION_SYNC_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-DEFERRED-SUPPORTING-DOCUMENTATION-EXACT-PATH-RECONCILIATION\12_FINAL_DOCUMENTATION_ALIGNMENT_HANDOFF.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-HIGH-RISK-ACTIVE-BASELINE-CONTROLLED-REBASELINE-20260910-REVIEW-BAR-OWNER-ACCEPTED\17_FINAL_AUTHORITY_HYGIENE_HANDOFF.md`

## 3. Current phase marker

`PHASE 3 — FORMALLY CLOSED`

The immediately preceding accepted recovery phase was:

`PHASE 2 FORMAL NO-OMISSION CLOSURE — COMPLETE`

The REVIEW BAR corrective phase, its post-acceptance documentation closure,
Foundation A, POD-11 and CIT-01 remain complete predecessor milestones. The
preceding completed Phase 1 wave was:

`CIT-02 — SHARED CONCRETE-FORMAT PROJECTION — OWNER WINDOWS RUNTIME ACCEPTED`

The CIT-02 status is `WINDOWS OWNER RUNTIME ACCEPTED — ANDROID PARITY
DEFERRED BY OWNER`. Its accepted architecture is the current PREDMET IRiU
occurrence → canonical IRiU display-name resolution → shared ČITULJE
concrete-format projection → ČITULJE preparation UI/PDF. `interniNaziv`
remains stable category/business identity; current `nazivPrikaz` remains the
user-visible IRiU truth; category-only fallback and the shared POLITIKA/NOVOSTI
mechanism remain protected. `IZNOS (RSD)`, price and other derivatives are not
discriminators, and no schema or JSON contract changed.

The earlier completed Phase 1 wave was:

`POD-03 — WINDOWS OWNER RUNTIME ACCEPTED`

The accepted selector/navigation contract is:

`eligible OTVOREN/ZATVOREN candidate` → `human-readable PREDMET identity` →
`stable local PREDMET ID` → `single direct navigation` → `ČITULJE preparation`.

`ZAVRŠEN` remains excluded. Direct dropdown selection opens the corresponding
preparation without `OTVORI ČITULJE`; return, refresh and invalidation behavior
remain protected. In that earlier acceptance record, Android parity was
deferred; consolidated Android parity is now complete and item-level Android
runtime acceptance is not claimed for this record.

The accepted current multi-item package is:

`CIT-06 — WINDOWS OWNER RUNTIME ACCEPTED`

`CIT-07 WIDE — WINDOWS OWNER RUNTIME ACCEPTED`

`CIT-07 NARROW RUNTIME — WINDOWS NOT REACHABLE; TARGETED TEST PASS; ANDROID RUNTIME PARITY OWNER-DEFERRED`

`PDF-03 — WINDOWS OWNER RUNTIME ACCEPTED`

CIT-07 narrow behavior is not represented as Windows runtime acceptance.
PDF-03 runtime evidence covered SAHRANA and KREMACIJA. Targeted and relevant
QA passed; the serialized suite recorded `545 passed, 10 conditional skips,
0 failures`; and the Windows executable SHA-256 is
`960FF97FD5D5E6AF778EDCB0FC12C380073665D307E4963A6A594ECB552DD26D`.
No schema, database, JSON or business-truth change occurred.

The subsequently completed bounded Phase 1 subphase is:

`POD-03 — WINDOWS OWNER RUNTIME ACCEPTED`

Its accepted boundary is one concrete `ČINJENICE CEREMONIJE` presentation with
the concrete ceremony type and date/time preserved, informational-only behavior
preserved, and obligations remaining separately presented. POD-03 targeted tests
passed with 3 tests; relevant PODSETNIK regressions passed with 46 tests;
`flutter analyze --no-pub` passed; the full serialized suite recorded
`545 passed, 10 conditional skips, 0 failures`; and the Windows release build
passed with executable SHA-256
`960FF97FD5D5E6AF778EDCB0FC12C380073665D307E4963A6A594ECB552DD26D`.
The unscheduled-case empty date/time separators are not a new residual.

The subsequently completed bounded Phase 1 package is:

`POD-02 — WINDOWS OWNER RUNTIME ACCEPTED`

`POD-04 — WINDOWS OWNER RUNTIME ACCEPTED`

POD-02 preserves responsive PARENT-to-CHILD master/detail presentation,
presentation-only selection, independent completion controls, accepted order,
grouping and action placement. POD-04 preserves the PARTE parent and
`Spremiti parte` child without changing business identity or completion
semantics. Windows OWNER runtime acceptance passed. Targeted same-parent
toggle/collapse passed; bounded PODSETNIK regression passed (4), R5 ČITULJA
regression passed (12), and relevant PODSETNIK regression passed (30).
`flutter analyze --no-pub` passed; the full serialized suite recorded
`547 passed, 10 skipped, 0 failures`. Windows release build passed with
executable SHA-256
`960FF97FD5D5E6AF778EDCB0FC12C380073665D307E4963A6A594ECB552DD26D`.
Android release APK build passed with SHA-256
`998634EDD95939E879AC20FEC59CCA14FB5AFFDF8302866A24C32FD35229EAB3`;
this is technical build-parity evidence only and does not establish Android
runtime acceptance. The successor 27-row baseline records 26 unchanged rows
and the accepted PODSETNIK source row, with zero current mismatches.

The current completed Phase 1 closure is:

`PHASE 1 POD-05 + NARROW RESPONSIVE POST-ACCEPTANCE CONTROL CLOSURE — COMPLETE`

POD-05 is recorded as `POD-05 — WINDOWS OWNER RUNTIME ACCEPTED — CLOSED` with
the accepted concise URNA/PEPEO parent/child labels and protected full dynamic
notification wording. The bounded technical finding is recorded as
`NARROW RESPONSIVE CHILD PLACEMENT — ANDROID OWNER RUNTIME ACCEPTED — CLOSED`.
The selected narrow child is immediately below its parent; the WIDE
master/detail presentation remains `ACCEPTED / PROTECTED / NO CHANGE`. This is
presentation correction only and does not create a business requirement.
The final closure QA records include 548 passed, 10 skipped and 0 failures for
each overlapping full serialized suite execution, Windows release SHA-256
`960FF97FD5D5E6AF778EDCB0FC12C380073665D307E4963A6A594ECB552DD26D`, and
Android release APK SHA-256
`275B9C5E7AA556DE5C25F77B8CDFF54A2C98D9413CFFF90066038DFF66946AC9`.

The current plan-governance hardening is a control correction over the
recovery process. It is not a newly inserted substantive recovery phase and
does not reorder or reinterpret the existing residual work.

The resolved OWNER recovery sequence is:

1. `PHASE 1 — PROVEN DEVIATIONS AND DEFECTS`;
2. `PHASE 2 — OMITTED PRE-CEREMONY OBLIGATIONS`;
3. `PHASE 3 — OMITTED POST-CEREMONY OBLIGATIONS`.

Phase 2 begins only after Phase 1 is completed, accepted and documented. Phase
3 begins only after Phases 1 and 2 are completed, accepted and documented.
Evidence, runtime and release gates remain separate where required. The latest
completed Phase 1 wave is POD-05 plus the bounded narrow responsive correction,
with the required Windows and Android OWNER runtime evidence recorded. The QA
incident
involving the responsive MODULI test is recorded only as task evidence:
`RESOLVED — TEST-LIFECYCLE ONLY — NO PRODUCT REQUIREMENT CREATED`.

The prior `OTVOREN-only` assumption is withdrawn; `OTVOREN + ZATVOREN` is
accepted. `NO TASK REQUIREMENT MAY BE PROMOTED TO OWNER AUTHORITY WITHOUT A
VERIFIED AUTHORITY SOURCE.`

The completed PDF-05 closure records:

`PDF-05 — WINDOWS OWNER RUNTIME ACCEPTED — CLOSED`

The accepted filename contract preserves unsuffixed singleton POLITIKA and
NOVOSTI filenames, assigns `_A`, `_B`, `_C` alphabetic suffixes to multiple
current same-type occurrences after deterministic `portableOccurrenceId` sort,
keeps that technical identity hidden, and keeps suffix state output-only. PDF
content, concrete format projection, PARTE, persistence, schema, JSON,
transfer, preparation and finalization semantics remain unchanged. PDF-05
targeted tests `7 PASS`, relevant ČITULJE regressions `27 PASS`, analyzer,
serialized full suite (`549 passed, 10 skipped, 0 failures`), Windows release
build, Android release build and Windows OWNER runtime acceptance are recorded.
Android runtime acceptance is not claimed. The residual ledger and matrix are
reconciled only for PDF-05; no next implementation residual is selected.

The completed preceding recovery process marker was:

`NEXT: PHASE 1 BATCH-ADMISSIBILITY REVIEW`

This marker is complete and is superseded by the formal Phase 1 exit record
below. It selected no batch contents and authorized no PODSETNIK fine-tuning,
Android parity or implementation of any residual. POD-01 is now
`WINDOWS OWNER RUNTIME ACCEPTED — CLOSED` without new implementation: OWNER
narrowed its scope to PARENT completion-state visual distinction already
satisfied by accepted POD-02. No CHILD, row/background or text color
requirement was created. All remaining non-closed entries retain their
existing parity/evidence, deferred and future-direction classifications.

## 3B. Phase 1 formal exit

Current Phase 1 state: `PHASE 1 — FORMALLY CLOSED`.

OWNER has confirmed:

- `PHASE 1 EXIT-READY — NO BLOCKING IMPLEMENTATION OR EVIDENCE GATES REMAIN`;
- deferred Android parity is not a Phase 1 exit blocker;
- EVID-01 through EVID-04 are not Phase 1 exit blockers;
- PODSETNIK polish remains deferred;
- CIT-04 and PDF-04 remain future direction outside current Phase 1;
- no Phase 1 implementation residual remains open.

Accordingly, `PHASE 1 FORMAL POST-COMPLETION CONTROL/DOCUMENTATION CLOSURE —
COMPLETE` remains the completed predecessor control state. At that earlier
Phase 1 closure point, Phase 2 had not started, and no Phase 2 implementation,
omission audit, residual or batch was selected. No next implementation member
was authorized. The earlier batch-admissibility marker remains preserved as
completed process history.

## 3C. Post-Phase-1 Android parity

`POST-PHASE-1 CONSOLIDATED ANDROID PARITY — COMPLETE`

OWNER has confirmed that the successful Android release build from the
completed Phase 1 work satisfies the consolidated Android parity gate. No
additional Android parity scope review, runtime package, build or source work
is pending for this recovery sequence.

The established sequence is now:

`PHASE 1 — FORMALLY CLOSED`
→ `POST-PHASE-1 CONSOLIDATED ANDROID PARITY — COMPLETE`
→ `SYNCHRONIZED WINDOWS + ANDROID DEVELOPMENT — RESUMED`

At the time of this earlier post-Phase-1 parity record, Phase 2 had not started.
Earlier item-level acceptance records that describe the narrower runtime
evidence available at their historical acceptance point remain historical
evidence scope and do not represent a pending consolidated parity gate.

The OWNER decision `PODSETNIK — DEFERRED FINE-TUNING / POLISH FINDINGS` keeps
literal/wording, minor presentation, small UX and small bounded usability
findings deferred without creating CIT-02 regressions or separate micro-tasks.
Current PODSETNIK ČITULJA child presentation is not a CIT-02 defect.

## 3D. Phase 2 formal no-omission closure

Current Phase 2 state: `PHASE 2 — FORMALLY CLOSED`.

The completed read-only Phase 2 audit established:

`PHASE 2 — NO PROVEN OMITTED PRE-CEREMONY OBLIGATIONS`

All authoritative PRE-CEREMONY obligations reviewed are present in current
source. `VOJNE POČASTI` is governed by the established OWNER trigger
`vojniPenzioner == DA AND vojnePocasti == DA` and the grouped structure
`VOJNE POČASTI` → `OBAVESTITI NADLEŽNU SLUŽBU`. No implementation package,
residual or batch was required. No source, test, schema, JSON, QA, build or
baseline change was made by this closure.

`PHASE 3 — FORMALLY CLOSED` is the current completed no-omission state. The
completed Phase 3 audit established:

`PHASE 3 — NO PROVEN OMITTED POST-CEREMONY OBLIGATIONS`

All current OWNER-authorized post-ceremony obligations reviewed are present in
current source. No implementation package, residual or batch was required. No
source, test, schema, JSON, QA, build or baseline change was made by this
closure.

This Phase 3 closure does not claim that the entire post-drift recovery
sequence is complete.

## 3E. Phase 3 formal no-omission closure

The reviewed post-ceremony set was:

- `REFUNDACIJA PIO → Predati zahtev`;
- `PORODIČNA PENZIJA → Predati zahtev`;
- `POSMRTNA POMOĆ → Predati zahtev`;
- `URNA / PEPEO → arrange placement`.

The accepted URNA/PEPEO lifecycle, including +3-day notification eligibility,
repeating notifications until completion, the `ZAVRŠEN` blocker and the
`GROBLJE POLAGANJA URNE` authority, remains protected and unchanged.

## 3F. Recovery closure readiness normalization

OWNER has resolved that the canonical phrase `final integrated
acceptance/release sequence` means the recovery-specific integrated
acceptance/release boundary. It does not require completion of the complete
stable OPC v.1 product-line release program.

Stable-product and release work returns to the normal OWNER roadmap unless
separately proven to be a recovery-specific blocker. This includes MODUL DVE
VALUTE, release identity/version/update-channel policy, signing and handover,
stable-product backup/restore rehearsal, final product runtime matrices,
performance targets, broader UI/UX work and related release gates.

EVID-01, EVID-02 and EVID-03 remain non-blocking evidence gaps. EVID-04
preserves accepted Windows evidence without claiming item-level Android runtime
acceptance. Deferred polish, future direction and technical debt return to the
normal roadmap.

`NALOG CVEĆARI — PDF ONLY`.
`DOCX — NOT AN OPEN OPTION`.

No recovery implementation residual remains open. The current readiness state
is:

`POST-DRIFT RECOVERY — READY FOR FORMAL OWNER CLOSURE`

This is not a recovery-closure claim. A separate explicit OWNER closure task is
required.

## 3A. Docs-as-Code progression control

After every OWNER-accepted recovery subphase, the canonical recovery
phase/status and each affected current-authority document must be reconciled.
Local authoritative documentation and the intended public GitHub current
documentation must then be synchronized through the established OWNER-gated
Docs-as-Code workflow. A recovery phase must not silently advance while the
public/current documentation still reports the previous phase. Implementation
publication remains a separate gate from documentation synchronization.

## 4. Residual and deferred authority

The plan references, and does not duplicate or replace, the sole current
detailed residual/deferred/evidence authority:

- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-REVIEW-BAR-POST-ACCEPTANCE-DOCUMENTATION-CLOSURE\10_CURRENT_RESIDUAL_FINDINGS_AND_OWNER_DECISIONS.md`
- `C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-REVIEW-BAR-POST-ACCEPTANCE-DOCUMENTATION-CLOSURE\11_CURRENT_GOOD_STATE_VS_RESIDUAL_MATRIX.md`

The FINAL9 ledger/matrix remain immutable predecessor provenance only; they are
not a competing current authority. The current successor records the accepted
closure of CIT-06, CIT-07 and PDF-03 in addition to the three
additional Phase 1 phase-classification defects `POD-08`, `POD-09` and `POD-10`,
the later Windows-owner-runtime acceptance of Foundation A, and `POD-11` as the
existing grouped-obligation-standard correction accepted on Windows. The
earlier item-level Android deferral is historical; consolidated Android parity
is now complete and item-level Android runtime acceptance is not claimed. POD-03 is now closed as
`WINDOWS OWNER RUNTIME ACCEPTED` under its existing ceremony/header boundary.
Its accepted one-presentation result does not redesign the header or create a
new residual. The later POD-02/POD-04 package is recorded as
`WINDOWS OWNER RUNTIME ACCEPTED` for both members; it closes only those two
implementation residuals and does not advance or reorder the Phase 1 sequence.
The completed Phase 2 audit found `PHASE 2 PROVEN OMITTED OBLIGATIONS — NONE
FOUND`; Phase 2 is formally closed and creates no implementation work. Phase 3
is also formally closed with `PHASE 3 — NO PROVEN OMITTED POST-CEREMONY
OBLIGATIONS`; no Phase 3 implementation member, omission or batch is selected.
Historical readiness/dependency sequences must not be promoted to current
sequencing authority.

Those records retain the established distinctions, including accepted/protect,
partial residual correction, OWNER refinement, future direction, evidence gap,
deferred broader work, locked/no-change and final integrated
acceptance/release work. ČITULJE, PODSETNIK and PDF items remain governed by
their individual ledger and matrix classifications.

Current Git-visible navigation remains governed by the current OPC information
homes and the operative dependency records, especially:

- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- `docs/OPC_PHASE2_ROADMAP_CURRENT_REALITY_RECONCILIATION.md`

## 5. Mandatory recovery-plan continuity gate

During this recovery phase, every substantive OPC task must physically read
this canonical plan before task planning or substantive source-learning and
must report:

1. the resolved physical plan path;
2. `READ = YES`;
3. the current recovery phase;
4. the immediately preceding accepted phase or handoff;
5. the single next plan-authorized action relevant to that task; and
6. the current residual ID/group, its current classification, the predecessor
   authority and the plan authorization for the task; and
7. confirmation that the task does not skip, reorder, reinterpret or silently
   extend the recovery plan or use a historical sequence as current sequencing
   authority.

If any item cannot be established, the task must stop with:

`STOP — RECOVERY PLAN CONTINUITY NOT ESTABLISHED`

This gate complements, and does not replace, the existing engineering-profile,
HUMAN GATE, Docs-as-Code, active-source authority, stale-donor, review,
protected-boundary and anti-drift controls.

## 6. Completion boundary

This plan remains governing authority until the recovery residual, recovery-
specific deferred/evidence obligations and recovery-specific integrated
acceptance/release boundary are reconciled and the OWNER explicitly closes the
post-drift recovery phase. Stable OPC v.1 product-line and general release work
is not part of this recovery boundary unless separately proven to be a
recovery-specific blocker. A task may not claim recovery closure from
source/test evidence, a runtime observation, documentation synchronization or
a public Git commit alone.
