# OPC Grouped Safe Upgrade Plan

Status: docs-only grouped upgrade-family register.

Base commit: `9bea04a6411c92a045a39f8b8a522dafa9dbcf98`

This document groups symptoms into goal-level upgrade families. It is not a roadmap, priority order, sequence, or recommended next task list. It does not authorize implementation.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-001

Family name: manual number formatting / UI validation
Symptoms: numeric entry and display formatting can differ across finance/IRiU/PDF surfaces.
Affected modules: finance/payment, IRiU, PDF/documents, JSON display fields.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-020`.
Business risk: user-visible totals or amounts may be misunderstood.
Current protection: source-confirmed finance and IRiU paths; no broad finance regression suite found.
Characterization evidence needed: current accepted inputs, formatting, zero/negative/blank behavior, PDF/rendered output.
Unsafe approach to avoid: changing storage semantics to solve display formatting.
Safe upgrade boundary: characterize display and validation only before any behavior change.
Owner decision required: business rounding/format policy if gaps are found.
Technical audit required: finance display and PDF data-builder audit.
Implementation blocked until: characterization evidence and owner-approved rule changes exist.
Classification: `CHARACTERIZATION REQUIRED / TEST GAP`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-002

Family name: display composition consistency across preview/PDF/JSON
Symptoms: identity/ceremony/display composition is spread across PREDMET fields, segment state, PDFs, and JSON.
Affected modules: Preminulo lice, PARTA, CITULJE, PDF/documents, JSON.
Affected pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-011`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`.
Business risk: public-facing output may diverge from PREDMET truth.
Current protection: PREDMET master-truth policy and current source-confirmed display fields.
Characterization evidence needed: preview/final PDF/JSON display matrix.
Unsafe approach to avoid: making a display output an independent identity source.
Safe upgrade boundary: compare outputs against PREDMET-derived expected composition.
Owner decision required: display flag business meaning where ambiguous.
Technical audit required: PDF/JSON/PARTA data contract audit.
Implementation blocked until: composition matrix is owner-reviewed.
Classification: `PARTIALLY IMPLEMENTED / CHARACTERIZATION REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-003

Family name: PARTA/CITULJE display flags
Symptoms: title, rank, profession, nickname, middle-name, script, symbol, and mourning text flags need unified review.
Affected modules: Preminulo lice, PARTA, CITULJE, PDF/documents.
Affected pseudocode sections: `OPC-PSEUDO-010`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`.
Business risk: public obituary/parta output may be wrong while PREDMET data is correct.
Current protection: source-confirmed fields and derivative-output rule.
Characterization evidence needed: current flag combinations and output examples.
Unsafe approach to avoid: rewriting PREDMET identity fields for one display symptom.
Safe upgrade boundary: flag logic stays derivative and traceable to PREDMET.
Owner decision required: expected display combinations.
Technical audit required: PARTA/CITULJE workflow extraction.
Implementation blocked until: owner-approved display rule matrix exists.
Classification: `PARTIALLY IMPLEMENTED / OWNER DECISION REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-004

Family name: evaluator/advisor guidance strengthening
Symptoms: evaluator conditions exist; consolidated guidance/advisor output is incomplete.
Affected modules: business policy evaluator, advisor/guidance future layer, IRiU, finance, review.
Affected pseudocode sections: `OPC-PSEUDO-005`, `OPC-PSEUDO-006`, `OPC-PSEUDO-016`, `OPC-PSEUDO-020`.
Business risk: warnings may be fragmented or missing.
Current protection: evaluator source and critical IRiU policy tests.
Characterization evidence needed: scenario matrix outputs, current warnings, missing user-facing guidance.
Unsafe approach to avoid: Codex inventing advisor policy or next-action strategy.
Safe upgrade boundary: evaluator stays deterministic; advisor stays derivative.
Owner decision required: warning taxonomy and authority.
Technical audit required: evaluator/advisor contract audit.
Implementation blocked until: owner-approved advisor scope.
Classification: `SOURCE-CONFIRMED / OWNER DECISION REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-005

Family name: IRiU truth engine stabilization
Symptoms: IRiU rows combine catalog defaults, user edits, evaluator-managed requirements, finance, documents, JSON, and stock consequences.
Affected modules: IRiU, KATALOG, evaluator, finance, STANJE ROBE, PDF, JSON.
Affected pseudocode sections: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`.
Business risk: hidden drift can affect totals, documents, or inventory.
Current protection: business-policy IRiU critical scenario tests.
Characterization evidence needed: category map, selected/suppressed/recommended states, catalog snapshot behavior.
Unsafe approach to avoid: overwriting PREDMET/IRiU selected snapshots from current KATALOG state.
Safe upgrade boundary: preserve selected-row truth and KATALOG identity separation.
Owner decision required: unresolved category/rule semantics.
Technical audit required: IRiU category/rule map.
Implementation blocked until: characterization covers affected outputs.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-006

Family name: STANJE ROBE consequence visibility
Symptoms: stock consequences can block close and affect JSON/unresolved transfer context; visibility and lifecycle require careful review.
Affected modules: STANJE ROBE, IRiU, KATALOG, PREDMET lifecycle, JSON.
Affected pseudocode sections: `OPC-PSEUDO-008`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021`.
Business risk: inventory consequence may be ignored, duplicated, or treated as case truth.
Current protection: operational toggle and JSON regression tests.
Characterization evidence needed: apply/restore/resolve/unresolved/replace/import flows.
Unsafe approach to avoid: making stock quantity or consequence state parallel PREDMET truth.
Safe upgrade boundary: operational consequence only, bound through IRiU/KATALOG rules.
Owner decision required: user-visible warning and close-block UX rules.
Technical audit required: stock consequence transfer/restore/sync audit.
Implementation blocked until: stock lifecycle contract is owner-reviewed.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-007

Family name: finance/payment consistency
Symptoms: finance combines IRiU, refund, JKP, advance, discount, payment notes, and PDFs.
Affected modules: finance/payment, IRiU, PIO/refund, JKP, Platilac, PDF.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-020`.
Business risk: wrong payable amount or document mismatch.
Current protection: source-confirmed calculation paths; dedicated finance tests not found.
Characterization evidence needed: totals matrix across included/excluded IRiU, refund, JKP, advance, discount.
Unsafe approach to avoid: fixing one rendered total without service-level characterization.
Safe upgrade boundary: finance truth remains PREDMET/IRiU-derived.
Owner decision required: finance edge-case rules.
Technical audit required: finance regression matrix.
Implementation blocked until: expected finance behavior is documented.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-008

Family name: PIO/refund guidance
Symptoms: refund data affects finance/PDF, but user-facing guidance is incomplete.
Affected modules: PIO/refund, finance/payment, advisor/guidance, PDF.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-016`, `OPC-PSEUDO-020`.
Business risk: refund responsibility or amount may be misunderstood.
Current protection: source-confirmed fields and settings refund amount.
Characterization evidence needed: pensioner, spouse-right, payer self-refund, amount, and PDF cases.
Unsafe approach to avoid: automatic guidance without owner policy.
Safe upgrade boundary: guidance stays explanatory until owner approves policy effect.
Owner decision required: refund guidance text and consequence authority.
Technical audit required: refund finance/PDF path audit.
Implementation blocked until: guidance policy is owner-approved.
Classification: `SOURCE-CONFIRMED / OWNER DECISION REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-009

Family name: JKP/Platilac consistency
Symptoms: visible `Platilac` and legacy internal `narucilac` coexist; JKP payer logic affects finance/PDF.
Affected modules: Platilac, JKP, finance/payment, PDF, JSON.
Affected pseudocode sections: `OPC-PSEUDO-009`, `OPC-PSEUDO-011`, `OPC-PSEUDO-012`, `OPC-PSEUDO-020`.
Business risk: wrong payer responsibility or compatibility break.
Current protection: terminology lineage and source-confirmed fields.
Characterization evidence needed: same payer, separate JKP payer, legal/physical payer, self-pay cases.
Unsafe approach to avoid: global rename without DB/JSON/template compatibility plan.
Safe upgrade boundary: preserve compatibility until owner-approved migration/cleanup exists.
Owner decision required: future terminology cleanup policy.
Technical audit required: payer/JKP compatibility audit.
Implementation blocked until: compatibility plan exists.
Classification: `FUNCTIONAL BUT ROUGH / OWNER DECISION REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-010

Family name: JSON import/version/freshness warnings
Symptoms: keep/replace/cancel exists; version warning behavior is policy/open decision.
Affected modules: JSON transfer, PREDMET identity, lifecycle/version, Pregled i potvrda.
Affected pseudocode sections: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-019`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021`.
Business risk: user may choose without enough version/conflict context.
Current protection: explicit user choice and JSON regression tests.
Characterization evidence needed: higher/lower/same/missing/malformed `verzija`; filename/exportDate behavior.
Unsafe approach to avoid: silent overwrite or `exportDatum`/filename authority.
Safe upgrade boundary: warning/comparison must preserve explicit user choice unless owner changes rule.
Owner decision required: warning vs hard-block matrix.
Technical audit required: JSON conflict and platform parity audit.
Implementation blocked until: version/conflict policy is owner-approved.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-011

Family name: firm-scoped identity guard
Symptoms: future-safe identity is `PIB + Maticni broj + brojPredmeta`; current guards need proof.
Affected modules: PREDMET identity, FirmaPodaci, JSON, backup/restore, Web/sync.
Affected pseudocode sections: `OPC-PSEUDO-004`, `OPC-PSEUDO-012`, `OPC-PSEUDO-013`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Business risk: wrong-firm import, restore, or sync conflict.
Current protection: owner decision and manifest gate.
Characterization evidence needed: same/different/missing/malformed firm identity and backup restore behavior.
Unsafe approach to avoid: relying on `brojPredmeta` or mutable display fields alone.
Safe upgrade boundary: identity/history audit before guard implementation.
Owner decision required: missing/malformed identity behavior.
Technical audit required: repository identity and migration audit.
Implementation blocked until: firm identity model is approved.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-012

Family name: version/change-log visibility
Symptoms: `verzija` exists; complete review change-log overview is missing.
Affected modules: lifecycle/log/version, Pregled i potvrda, JSON, future sync.
Affected pseudocode sections: `OPC-PSEUDO-002`, `OPC-PSEUDO-004`, `OPC-PSEUDO-016`, `OPC-PSEUDO-019`, `OPC-PSEUDO-021`.
Business risk: user cannot review enough change history for conflict reasoning.
Current protection: version/log source paths and owner decision for review location.
Characterization evidence needed: save, close, reopen, replace, no-change, changed flows.
Unsafe approach to avoid: treating `_vN` filename or export date as authoritative.
Safe upgrade boundary: audit increments and logs before visible overview.
Owner decision required: overview content and retention.
Technical audit required: lifecycle/version/log coverage audit.
Implementation blocked until: review structure is proven suitable.
Classification: `OWNER DECISION / IMPLEMENTATION REQUIRED / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-013

Family name: Windows/Android runtime parity
Symptoms: shared source exists, but full parity needs runtime characterization for sensitive workflows.
Affected modules: all user workflows.
Affected pseudocode sections: all pseudocode sections.
Business risk: platform behavior drift.
Current protection: shared Dart source and manifest platform parity gate.
Characterization evidence needed: create/open/save/close, PDF, JSON import, stock, auth, settings, narrow UI.
Unsafe approach to avoid: assuming parity from source inspection only.
Safe upgrade boundary: parity characterization before behavior changes.
Owner decision required: only for intentional platform differences.
Technical audit required: fixed parity scenario audit.
Implementation blocked until: parity-sensitive behavior is characterized.
Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-014

Family name: entitlement/package enforcement
Symptoms: package/add-on gating exists; payment/access implementation is blocked.
Affected modules: entitlement/packages/licensing, users/roles, documents, STANJE ROBE, settings.
Affected pseudocode sections: `OPC-PSEUDO-014`, `OPC-PSEUDO-015`, `OPC-PSEUDO-018`, `OPC-PSEUDO-021`.
Business risk: invalid package unlocks features or disabled module changes data.
Current protection: fail-closed parser/policy tests.
Characterization evidence needed: package levels, add-ons, missing/invalid licenses, role overlays.
Unsafe approach to avoid: package gates that mutate PREDMET truth.
Safe upgrade boundary: access affects availability only.
Owner decision required: commercial/payment/access model.
Technical audit required: payment/access gate and role identity audit.
Implementation blocked until: owner approves commercial/access architecture.
Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / IMPLEMENTATION BLOCKED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-015

Family name: document engine/add-on boundary
Symptoms: document outputs are entitlement-gated derivatives; add-on document architecture is not fully defined.
Affected modules: PDF/documents, PARTA, CITULJE, NALOG CVECARI, entitlement/packages.
Affected pseudocode sections: `OPC-PSEUDO-011`, `OPC-PSEUDO-014`, `OPC-PSEUDO-018`, `OPC-PSEUDO-020`.
Business risk: document output becomes hidden policy source.
Current protection: PREDMET truth manifest and package/add-on rules.
Characterization evidence needed: document data contracts, visible actions, package/add-on combinations.
Unsafe approach to avoid: independent document data owner.
Safe upgrade boundary: documents read PREDMET/IRiU/finance/Firma data and remain outputs.
Owner decision required: document product packaging.
Technical audit required: document engine boundary audit.
Implementation blocked until: boundary is approved.
Classification: `DOCUMENTED POLICY / TECHNICAL AUDIT REQUIRED`.

## UPGRADE-FAMILY-ID: OPC-UPGRADE-FAMILY-016

Family name: future OPC Web/sync readiness
Symptoms: future access must preserve PREDMET truth, local/firma ownership, identity, module contracts, and explicit conflict choices.
Affected modules: PREDMET core, JSON, backup/restore, FirmaPodaci, users/roles, entitlement, finance, STANJE ROBE, evaluator, all derivatives.
Affected pseudocode sections: `OPC-PSEUDO-018`, `OPC-PSEUDO-019`, `OPC-PSEUDO-020`, `OPC-PSEUDO-021`.
Business risk: premature Web/sync design can create server-master drift, identity collision, data loss, or parallel truth.
Current protection: manifest, owner decision report, stop-list, Web guardrails.
Characterization evidence needed: identity, version, conflict, module write boundaries, storage, role, access, and sync risk audit.
Unsafe approach to avoid: choosing architecture or implementing sync/API/storage before audits.
Safe upgrade boundary: guardrail/audit only until owner-approved architecture.
Owner decision required: future OPC Web architecture and access model.
Technical audit required: Web/sync architecture audit.
Implementation blocked until: owner-approved architecture and characterization evidence exist.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

## Final Grouping Summary

These families are classification buckets for evidence, risk, characterization, owner decisions, technical audits, and blocked implementation areas. They are not a task sequence, priority order, or roadmap.
