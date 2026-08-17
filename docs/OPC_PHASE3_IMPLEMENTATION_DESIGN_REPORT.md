# OPC Phase 3 Implementation / Design Report

**Task type:** architecture design / target SOURCE model / no implementation
**Baseline:** `e57ac1531a1cc3c38993aecc978e9e2a81bd3a24`
**Parent Phase 1 baseline:** `621c70f8d4820042e40a15f3d44187703092db3e`
**SCENARIO locked production SHA:** `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
**Final status:** `PHASE 3 PASS — TARGET OPC SOURCE ARCHITECTURE AND BUILDING-BLOCK MODEL DEFINED — READY FOR LOGOS REVIEW`

## Sources and method

The accepted Phase 1/2 current-state homes, operative dependency plan, Phase 2 roadmap reconciliation and source/pseudocode coverage matrix were read with the SCENARIO lock/report, synchronized internal pseudocode index/views, current architecture, and relevant source/test/platform evidence. The reconstruction covered the app shell, PREDMET, SCENARIO, IRiU, KATALOG, policy/finance, PARTE, documents, PODSETNIK, stock, persistence, JSON/backup, identity/settings, platform adapters and tests.

The design order was: current responsibility → target logical responsibility → dependency direction → ownership/contracts → physical proposal → current-to-target intervention class → risk/prerequisite. No historical placement was treated as authority merely because it exists.

## Findings

The product has strong protected contracts and useful feature seams. PREDMET, SCENARIO and IRiU semantics are sufficiently evidenced for a target model. PARTE is a coherent comparative slice. Database and JSON/backup concentration are the highest maintainability and transfer risks. Reminder scheduling is technically isolatable but its business signal taxonomy is not owner-final. Tests contain valuable contract evidence but need a later discoverability-oriented taxonomy. Generated Drift code is output, not hand-written debt.

## Target and trade-offs

The target is hybrid feature-first with explicit internal layers, a single composition root, PREDMET-centered authority, published cross-feature ports, feature-owned interoperability workflows, infrastructure-owned technical adapters, explicit persistence/platform boundaries, and contract-oriented tests. Policy/finance has the explicit `features/policy_finance` home; test-only support remains under top-level `test/`, outside production `lib`. This improves maintainability, reliability, handover and platform parity at the cost of additional interfaces, adapters and temporary migration duplication. It deliberately retains compatibility code and recovery lanes even when they appear old.

The migration matrix identifies retain, move, split, merge, refactor, recode, partial rewrite, full reconstruction and conditional removal as evidence-based options. The JSON and database hotspots may justify bounded reconstruction, but only after characterization, compatibility inventory, restore rehearsal and reversible adapters. No rewrite is authorized by this report.

## Owner and protected gates

- PREDMET meaning and ownership are preserved; no owner conflict was found.
- SCENARIO remains locked. Any physical or implementation change is `REQUIRES EXPLICIT SCENARIO UNLOCK TASK`.
- PREDMET remains the owner of lifecycle/business facts used by reminders; PODSETNIK may own derived scheduling/delivery/confirmation state, while signal taxonomy and business meaning remain owner-gated.
- Interoperability transfer/full-backup/restore coordination is application-owned; codecs, filesystem and persistence adapters are infrastructure-owned.
- NALOG/RAČUN, dual currency, app identity/distribution and remaining release gates stay in their accepted roadmap/owner homes.

## Later dead-code audit requirements

Before any removal or migration, separately audit migrations, old JSON versions, recovery/repair paths, database-lane selectors, platform branches, historical restore formats, generated outputs and compatibility fixtures. “Unused now” is not “proven dead”. The audit must include repository search, runtime/fixture evidence, upgrade rehearsal and owner/legal/platform obligations.

## Explicit no-implementation confirmation

Phase 3 changed documentation design only. No production SOURCE, tests, dependencies, database, CI, platform configuration, SCENARIO implementation, current-state authority home, or internal pseudocode body was changed. No commit or push was performed. The accompanying review ZIP is local, ignored and non-authoritative.
