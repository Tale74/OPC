---
name: opc-review-handoff
description: Produce a compact machine-verifiable OPC review handoff so Logos can independently review task truth without reconstructing the entire session.
---

# OPC Review Handoff

## Goal
Create an evidence index, not a new competing authority document.

## Independent Logos review contract

Before Logos writes, approves or assesses a substantive Codex task/report/
review, Logos must record:

1. `TASK UNDERSTANDING CONFIRMATION` — intended outcome, scope, locked OWNER
   decisions and prohibited actions;
2. `CONTINUITY ESTABLISHMENT CONFIRMATION` — current repository/branch/HEAD
   where applicable, predecessor result, dependency position, open/closed
   findings, current authority state and the actual review/evidence package;
3. `DOCUMENTATION READING CONFIRMATION` — direct reading/classification of
   current authoritative homes and task-relevant control documents.

The independent comparison must use OWNER authority, current documentation,
source/test/runtime evidence when relevant, continuity, intended outcome and
anti-drift controls. The latest Codex report is evidence, not sufficient truth;
conversation memory alone is not a substitute for current files and hashes.
When authority, continuity, drift, unsupported inference, source/target
separation or evidence completeness conflicts, Logos must recommend STOP and
correction rather than approve by assumption. This procedure strengthens the
existing HUMAN GATE and creates no parallel governance mechanism.

## Handoff content
Include:
- task identity;
- baseline branch and HEAD;
- baseline/pre-existing worktree delta;
- final branch/HEAD/worktree state;
- files changed by this task;
- authoritative documents actually used;
- pseudocode/logical-map material actually used;
- source-learning findings and classifications;
- tests/QA commands, results and exit evidence;
- build/runtime evidence when applicable;
- documentation updates and local/Git publication status;
- engineering-profile applicability at intake and closure, including explicit
  reasons for omitted chain links and any requirements/traceability,
  architecture/data-contract, verification/acceptance or quality/release impact;
- unresolved owner decisions;
- incidental-finding evidence and completion disposition: every material
  finding is resolved, preserved with an existing-control destination and
  successor, or closed with a justified no-action decision; orphan count is
  zero;
- exact paths/hashes for review artifacts.

## Boundaries
- Store review material outside SOURCE under the project-root `REVIEW` layer.
- Do not create `SOURCE/REVIEW`.
- A review bundle is non-authoritative evidence/navigation.
- REVIEW evidence and harness controls support the adopted engineering profile;
  they do not replace current product/engineering authority.
- Do not require an irrelevant artifact merely to make every profile link look
  populated; proportional `NOT_APPLICABLE` evidence is valid.
- Do not convert unresolved findings into current product truth.
- Do not require continuous owner review inside an approved task merely to
  retain findings. Completion validation enforces the task-local finding
  record; owner attention is reserved for explicit HUMAN GATE events.
- Use `tools/opc_context/package_review.ps1` for the final evidence package.
  Do not improvise another packager when the canonical path applies.
