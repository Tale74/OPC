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
- Classification:
  - `ALIGNED`
  - `IMPLEMENTATION DEFECT`
  - `AUTHORITY GAP`
  - `EVIDENCE INCOMPLETE`
- Any pseudocode/logical-map continuity impact.

## Authority boundary
If source reaches a question that is not decided by current authority, stop technical policy-making. Present:
- proven facts;
- exact unresolved owner question;
- technically valid options;
- consequences.

Do not choose on Tale's behalf.
