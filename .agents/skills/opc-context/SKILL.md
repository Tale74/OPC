---
name: opc-context
description: Establish bounded OPC task context from current authority, local pseudocode boundary, Git state and task-relevant source without doing substantive implementation.
---

# OPC Context

Use at the start of substantive OPC work.

## Goal
Replace manual context reconstruction with an evidence-backed, bounded task context. Do not implement product changes in this skill.

## Required actions
1. Resolve the current repository root, active branch, HEAD and worktree status.
2. Preserve pre-existing worktree delta as baseline evidence; do not assume a clean tree.
3. Read the task-relevant current authority beginning with the five authoritative homes named in root `AGENTS.md`.
4. Determine the task-relevant implications of the adopted engineering profile across business/domain authority, requirements/traceability, architecture/data contracts, implementation boundaries, verification/acceptance, quality/release and current-state documentation. Record an evidence-backed reason for any link that is not applicable; do not require an artifact merely to fill the chain.
5. Locate the project-root internal pseudocode/logical-map boundary and read only task-relevant material.
6. Identify task-relevant source/tests by concrete names, symbols, business terms and data-flow entry points.
7. Separate findings into:
   - OWNER / BUSINESS AUTHORITY
   - SOURCE-PROVEN IMPLEMENTED BEHAVIOR
   - RUNTIME EVIDENCE
   - INFERENCE / UNKNOWN
8. Run `tools/opc_context/build_context.ps1` and `validate_context.ps1` when available. Preserve the harness-initialized task-local `INCIDENTAL_FINDINGS.json`; it is completion evidence, not a new authority or parallel ledger.
9. Produce the mandatory HUMAN GATE blocks and STOP.

The Context Harness and HUMAN GATE support application of the engineering
profile; they do not replace standards applicability, product authority or
current-state documentation.

## Fail closed
Do not claim continuity/documentation reading if the referenced evidence was not actually located/read.
Do not derive business meaning from a convenient local ID, current authenticated actor, derivative output, migration shortcut or historical report.
If authority is unresolved, use `OWNER DECISION REQUIRED`.
