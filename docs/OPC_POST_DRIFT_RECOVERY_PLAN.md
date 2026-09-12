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

`65AB20CC4730A9A352BF4AE830B9D4F909FE024F12A3E4FC8F3ACE7F9DCAD0FA`

The current external active control package is:

`C:\Projekti\OPC\OPC v.1\REVIEW\CURRENT_TASK\OPC-HIGH-RISK-ACTIVE-BASELINE-CONTROLLED-REBASELINE-20260912-PHASE1-FOUNDATION-B-CIT01-CLOSURE\`

Its enclosing ZIP SHA-256 is:

`3EADA0AADA6E72615241C9B63414D600134A8EE8C5A153D7D066A9B2679C8186`

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

`PHASE 1 FOUNDATION B / CIT-01 POST-ACCEPTANCE CONTROL CLOSURE — COMPLETE`

The preceding accepted recovery phase was:

`PHASE 1 FOUNDATION B — CIT-01 — OWNER WINDOWS RUNTIME ACCEPTANCE PASS`

The REVIEW BAR corrective phase and its post-acceptance documentation closure
remain complete predecessor milestones. The next recommended Phase 1
structural/logical wave is:

`CIT-02 — SHARED CONCRETE-FORMAT PROJECTION`

This is a bounded next-wave recommendation, not implementation authorization.
Its implementation requires a separate OWNER continuation. The current CIT-01
closure records Windows OWNER runtime acceptance with Android parity deferred.

The current plan-governance hardening is a control correction over the
recovery process. It is not a newly inserted substantive recovery phase and
does not reorder or reinterpret the existing residual work.

The resolved OWNER recovery sequence is:

1. `PHASE 1 — PROVEN DEVIATIONS AND DEFECTS`;
2. `PHASE 2 — OMITTED PRE-CEREMONY OBLIGATIONS`;
3. `PHASE 3 — OMITTED POST-CEREMONY OBLIGATIONS`.

Phase 2 begins only after Phase 1 is completed, accepted and documented. Phase
3 begins only after Phases 1 and 2 are completed, accepted and documented.
Evidence, runtime and release gates remain separate where required. OWNER has
accepted CIT-01 and the next recommended structural/logical Phase 1 wave is
`CIT-02 — SHARED CONCRETE-FORMAT PROJECTION`; this plan does not authorize its
implementation or any internal work within that wave.

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
not a competing current authority. The current successor records the three
additional Phase 1 phase-classification defects `POD-08`, `POD-09` and `POD-10`,
the later Windows-owner-runtime acceptance of Foundation A, and `POD-11` as the
existing grouped-obligation-standard correction accepted on Windows with
Android parity deferred by OWNER. The duplicated/repeated `ČINJENICE
CEREMONIJE` presentation remains a separate open Phase 1 presentation defect
under its existing ceremony/header boundary.
The current audit found `PHASE 2 PROVEN OMITTED OBLIGATIONS — NONE FOUND` and
`PHASE 3 PROVEN OMITTED OBLIGATIONS — NONE FOUND`; those phases remain reserved
for future source-proven omissions and create no implementation work here.
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

This plan remains governing authority until the residual, deferred, evidence
and final integrated acceptance/release sequence is completed and the OWNER
explicitly closes the post-drift recovery phase. A task may not claim recovery
closure from source/test evidence, a runtime observation, documentation
synchronization or a public Git commit alone.
