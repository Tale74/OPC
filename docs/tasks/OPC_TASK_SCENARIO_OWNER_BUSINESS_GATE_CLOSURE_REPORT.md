# OPC task report — SCENARIO owner business-gate closure

Status:
`OWNER BUSINESS GATES CLOSED — DOCUMENTATION UPDATED — IMPLEMENTATION NOT STARTED`

Decision date: 2026-07-29

## 1. Git baseline

- Base branch: `task/OPC-PHASE-1-SCENARIO-IRIU-COMPLETE-AUDIT`
- Base SHA: `ace0f4db326ce3799882afe90d72ef4751ec1c28`
- Task branch: `task/OPC-SCENARIO-OWNER-GATE-CLOSURE`
- Final SHA: supplied by the immutable Git branch tip and completion response;
  a commit cannot contain its own SHA

The baseline was clean and synchronized with its upstream before this
documentation-only task began.

## 2. Owner decisions

### 2.1 `JAVNO MESTO/NEDEFINISANO`

The previously requested exact-result owner fixture is no longer an
implementation dependency.

The approved product direction removes scenario policy from hard-coded rules
and exposes corrected scenarios through the user-configurable SCENARIO UI.
Therefore:

- no isolated hard-code business result is to be owner-defined for this pair;
- existing behavior may still be characterized as migration evidence;
- the future validated scenario definition determines the required result;
- this does not authorize an isolated application-code correction.

### 2.2 Urn placement cemetery

The existing `TIP POLAGANJA URNE` dropdown and the conditional fields that it
already exposes remain the governing UI flow.

A distinct informational PREDMET field is required for the cemetery where the
urn will be placed. This fact:

- belongs to PREDMET;
- is part of the existing urn-placement flow;
- may differ from the cremation `MESTO CEREMONIJE`;
- must not reuse or overwrite the existing cremation `groblje` fact;
- requires an additive, migration-safe persistence and JSON design during the
  later authorized implementation.

The exact technical field identifier and migration mechanics are delegated to
Codex under the Decision Authority Matrix. Any technical choice that changes
the business meaning returns to the owner.

## 3. Documentation effect

Updated:

- `docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`

The original Phase 1 audit report remains an immutable record of the open gates
that existed at audit completion. This report records their later owner
closure.

## 4. Scope confirmation

- No application source was changed.
- No tests were changed.
- No database or migration was changed.
- No build configuration or runtime behavior was changed.
- No Flutter analyze, test or build command was run.
- Implementation remains restricted to a new Projects chat after owner
notification and Architecture Gate authorization.

## 5. Completion controls

- `git diff --check`: PASS
- strict .NET UTF-8 validation: PASS for all four changed documents
- BOM result: ABSENT for all four changed documents
- privacy/sensitive-data diff scan: PASS
- private absolute-path and user-name scan: PASS
- documentation-only scope check: PASS
- referenced relative-path existence check: PASS
- commit and push: recorded by the branch history
- local/origin equality and clean worktree: confirmed after push
