---
name: opc-review-handoff
description: Produce a compact machine-verifiable OPC review handoff so Logos can independently review task truth without reconstructing the entire session.
---

# OPC Review Handoff

## Goal
Create an evidence index, not a new competing authority document.

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
