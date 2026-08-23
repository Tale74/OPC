---
name: opc-source-learning
description: Learn current OPC implementation causality against established authority and preserve the distinction between business meaning, source behavior, runtime evidence and inference.
---

# OPC Source Learning

## Goal
Determine HOW current OPC source realizes or violates established business/technical authority.

## Method
Follow this chain:

authority
→ internal pseudocode/logical map
→ source entry point
→ repository/service/data-flow path
→ persistence/schema/import/export boundary
→ derivatives
→ protecting tests
→ proven behavior / conflict / unknown

Use symbol/reference search and direct source reading. Do not infer architecture from file names alone.

## Required output for each material finding
- Authority statement and source document/location.
- Source path(s) and symbol(s) proving current implementation behavior.
- Tests/evidence that protect or contradict it.
- Implementation/authority classification:
  - `ALIGNED`
  - `IMPLEMENTATION DEFECT`
  - `AUTHORITY GAP`
  - `EVIDENCE INCOMPLETE`
- Any pseudocode/logical-map continuity impact.

## Incidental finding control
When a material finding is discovered during source-learning, implementation,
validation or runtime review, update the existing task-local
`INCIDENTAL_FINDINGS.json` immediately. Do not wait for the owner to notice or
for final handoff assembly.

Record:
- a stable task-local id and concise summary;
- concrete evidence path and detail;
- task disposition classification: `IN_SCOPE`, `OUT_OF_SCOPE`,
  `AUTHORITY_GAP`, `EVIDENCE_INCOMPLETE` or `OBSERVATION`;
- impact on the current task;
- scope effect: `WITHIN_APPROVED_SCOPE`, `NO_SCOPE_CHANGE` or
  `NEW_AUTHORIZATION_REQUIRED`;
- durable disposition: resolved in the current task, preserved in an existing
  control with destination and successor, no future action with reason, owner
  gate required, or blocked;
- `authorityEffect: DOES_NOT_CREATE_AUTHORITY`;
- the completion orphan check.

Do not create a parallel ledger. Use an existing authoritative/current-control
destination when future action is needed. Continue unattended within the
already approved scope. Stop for owner attention only when the record shows a
genuine authority/business decision, blocking condition, new authorization
boundary or another explicit HUMAN GATE event.

## Authority boundary
If source reaches a question that is not decided by current authority, stop technical policy-making. Present:
- proven facts;
- exact unresolved owner question;
- technically valid options;
- consequences.

Do not choose on Tale's behalf.
