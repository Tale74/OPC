# OPC Characterization Before Change Rules

Status: docs-only rule document.

Base commit: `0f82e144a16bd40e1482fd67dd2346233991a623`

## 1. Purpose

Define what must be characterized before any future OPC business/logical behavior change.

## 2. General Rule

Current behavior must be classified before it is changed. Classification must distinguish tests, source, docs, runtime evidence, owner decisions, gaps, and blockers.

## 3. Behavior-Change Definition

A behavior change includes any change to PREDMET truth, lifecycle, identity, version, evaluator, IRiU, STANJE ROBE, finance, PDF, JSON, import/export, backup/restore, entitlement, role, Web/sync readiness, or user-visible business decision.

## 4. Docs-Only Exception

Docs-only tasks may classify evidence and clarify boundaries without implementation. If logic is clarified, pseudocode must be updated.

## 5. Pseudocode-Update Requirement

When business/logical behavior is touched or clarified, update `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`, `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`, and `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` as needed.

## 6. Characterization Evidence Requirement

Required rule:

```text
IF a future task changes business/logical behavior:
    require existing behavior characterization first
    require owner-approved intended behavior
    require pseudocode update in same task
    require tests or explicit technical audit status
ELSE IF task is docs-only:
    require evidence classification
    require pseudocode update when logic is clarified
ELSE:
    mark implementation blocked
```

## 7. Owner Decision Requirement

If intended behavior changes business policy, terminology compatibility, conflict handling, display meaning, payment/access, package behavior, role identity, or Web ownership, owner decision is required before implementation.

## 8. Technical Audit Requirement

If source/test/runtime evidence is incomplete, the task must classify `TECHNICAL AUDIT REQUIRED` or `CHARACTERIZATION REQUIRED` instead of implementing.

## 9. Runtime Evidence Requirement

Runtime-sensitive behavior, especially Windows/Android parity and STANJE ROBE user-visible flows, requires recorded runtime evidence before being treated as runtime-confirmed.

## 10. Windows/Android Parity Requirement

Platform differences may exist only for platform form and APIs. Business truth must remain shared. Parity-sensitive changes require explicit characterization.

## 11. Web-Readiness Check

Required rule:

```text
IF future Web/sync might be affected:
    check identity, conflict, local DB id, version, module output, firm scope
    if uncertain:
        mark TECHNICAL AUDIT REQUIRED or OWNER DECISION REQUIRED
```

## 12. Implementation Blocked Wording

Use `IMPLEMENTATION BLOCKED` when evidence, owner decision, technical audit, runtime proof, or tests are missing for a behavior change.

## 13. Report Wording Rules

Reports may state evidence, gaps, risks, owner decisions required, technical audits required, and blocked areas. Reports must keep policy, source, tests, and runtime evidence separate.

## 14. Forbidden Recommended Next Task Wording

Required rule:

```text
IF a gap is found:
    classify the gap
    link it to module contract and pseudocode
    do not recommend next task
    do not create priority order
```

Forbidden wording includes recommended next task, recommended next step, suggested sequence, roadmap, priority order, or implementation sequence.

## 15. PASS / NOT PASS Implications

PASS requires evidence classification, pseudocode alignment when logic is clarified, no implementation, no roadmap/priority order, no behavior changes, and passing manifest gate. NOT PASS applies if behavior is implemented, tests/source are edited, source-confirmed behavior is promoted to test-confirmed, Web architecture is selected prematurely, gaps become nano-tasks, or the manifest gate fails.
