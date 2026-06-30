# OPC Characterization Gap Register

Status: docs-only gap register.

Base commit: `0f82e144a16bd40e1482fd67dd2346233991a623`

Gaps are evidence blockers. They are not recommendations, tasks, sequence, roadmap, or priority order.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-001

Gap name: numeric formatting and validation characterization
Affected module: finance/payment, IRiU, PDF
Affected upgrade family: manual number formatting / UI validation
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-024`, `OPC-PSEUDO-025`
Related contract ID: `OPC-MODULE-CONTRACT-011`
Evidence currently available: source-confirmed finance and IRiU paths.
Missing evidence: accepted inputs, formatting, blank/zero/negative cases, PDF consistency tests.
Why this matters: totals can be misunderstood.
Unsafe change to avoid: changing storage semantics for display symptoms.
Behavior blocked until: formatting behavior is characterized.
Owner decision required: only for changed rounding/display policy.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `TEST GAP / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-002

Gap name: preview/PDF/JSON display composition matrix
Affected module: Preminulo lice, PARTA, CITULJE, PDF, JSON
Affected upgrade family: display composition consistency across preview/PDF/JSON
Related pseudocode ID: `OPC-PSEUDO-010`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-002`, `OPC-MODULE-CONTRACT-012`, `OPC-MODULE-CONTRACT-014`, `OPC-MODULE-CONTRACT-015`
Evidence currently available: source-confirmed display fields and derivative-output policy.
Missing evidence: full output matrix across preview, PDFs, and JSON.
Why this matters: public output may diverge.
Unsafe change to avoid: making output an identity source.
Behavior blocked until: display matrix exists.
Owner decision required: yes for display meaning.
Technical audit required: yes.
Web readiness relevance: medium/high.
Classification: `CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-003

Gap name: PARTA/CITULJE flag behavior
Affected module: PARTA, CITULJE
Affected upgrade family: PARTA/CITULJE display flags
Related pseudocode ID: `OPC-PSEUDO-010`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-012`, `OPC-MODULE-CONTRACT-013`
Evidence currently available: partial source evidence and package/add-on policy.
Missing evidence: flag combinations, CITULJE workflow, output examples.
Why this matters: public-facing text can be wrong.
Unsafe change to avoid: changing PREDMET identity fields for display.
Behavior blocked until: owner-reviewed display rules.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `PARTIALLY IMPLEMENTED / TEST GAP`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-004

Gap name: advisor guidance authority
Affected module: evaluator/advisor/review
Affected upgrade family: evaluator/advisor guidance strengthening
Related pseudocode ID: `OPC-PSEUDO-016`, `OPC-PSEUDO-023`
Related contract ID: `OPC-MODULE-CONTRACT-007`, `OPC-MODULE-CONTRACT-008`, `OPC-MODULE-CONTRACT-017`
Evidence currently available: evaluator source/tests and policy docs.
Missing evidence: advisor scope, warning taxonomy, review placement.
Why this matters: guidance can become hidden policy.
Unsafe change to avoid: scattered UI warnings without owner authority.
Behavior blocked until: owner-approved guidance scope.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `OWNER DECISION REQUIRED / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-005

Gap name: IRiU full category and downstream matrix
Affected module: IRiU, finance, PDF, STANJE ROBE
Affected upgrade family: IRiU truth engine stabilization
Related pseudocode ID: `OPC-PSEUDO-006`, `OPC-PSEUDO-007`, `OPC-PSEUDO-023`
Related contract ID: `OPC-MODULE-CONTRACT-009`
Evidence currently available: critical scenario tests and source-confirmed rules.
Missing evidence: all categories, finance/PDF/stock downstream effects.
Why this matters: IRiU drives multiple modules.
Unsafe change to avoid: category rule changes without downstream characterization.
Behavior blocked until: category/effect matrix exists.
Owner decision required: yes for rule changes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `TEST-CONFIRMED / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-006

Gap name: STANJE ROBE transfer and visibility characterization
Affected module: STANJE ROBE
Affected upgrade family: STANJE ROBE consequence visibility
Related pseudocode ID: `OPC-PSEUDO-008`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-010`
Evidence currently available: focused tests and selected runtime evidence.
Missing evidence: transfer/restore/sync and all replacement-path visibility.
Why this matters: inventory consequences can affect close and operations.
Unsafe change to avoid: treating inventory state as PREDMET truth.
Behavior blocked until: stock lifecycle characterization exists.
Owner decision required: yes for UX warnings.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-007

Gap name: finance matrix gap
Affected module: finance/payment
Affected upgrade family: finance/payment consistency
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-011`
Evidence currently available: source-confirmed finance service and UI/PDF paths.
Missing evidence: full calculation tests and edge cases.
Why this matters: payable amount can be wrong.
Unsafe change to avoid: one-output total fixes.
Behavior blocked until: finance matrix exists.
Owner decision required: yes for edge rules.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `SOURCE-CONFIRMED / TEST GAP`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-008

Gap name: PIO/refund guidance gap
Affected module: PIO/refund, finance, advisor, PDF
Affected upgrade family: PIO/refund guidance
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-016`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-006`
Evidence currently available: source-confirmed fields and document paths.
Missing evidence: scenario and guidance matrix.
Why this matters: refund responsibility can be misunderstood.
Unsafe change to avoid: automatic guidance without policy.
Behavior blocked until: refund guidance authority is defined.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `OWNER DECISION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-009

Gap name: JKP/Platilac compatibility gap
Affected module: Platilac, JKP, finance, PDF, JSON
Affected upgrade family: JKP/Platilac consistency
Related pseudocode ID: `OPC-PSEUDO-009`, `OPC-PSEUDO-012`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-003`, `OPC-MODULE-CONTRACT-004`
Evidence currently available: source-confirmed fields and terminology docs.
Missing evidence: compatibility and scenario matrix.
Why this matters: payer responsibility and JSON/PDF compatibility.
Unsafe change to avoid: global rename.
Behavior blocked until: compatibility is characterized.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `FUNCTIONAL BUT ROUGH / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-010

Gap name: JSON version/freshness warning gap
Affected module: JSON transfer, lifecycle/version
Affected upgrade family: JSON import/version/freshness warnings
Related pseudocode ID: `OPC-PSEUDO-012`, `OPC-PSEUDO-025`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-015`, `OPC-MODULE-CONTRACT-018`
Evidence currently available: JSON regression tests and owner decisions.
Missing evidence: warning comparator behavior for all version states.
Why this matters: conflict choices need context.
Unsafe change to avoid: silent overwrite or export-date authority.
Behavior blocked until: conflict matrix and owner policy exist.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `CHARACTERIZATION REQUIRED / IMPLEMENTATION BLOCKED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-011

Gap name: firm-scoped identity guard gap
Affected module: PREDMET identity, FirmaPodaci, JSON, backup/restore
Affected upgrade family: firm-scoped identity guard
Related pseudocode ID: `OPC-PSEUDO-004`, `OPC-PSEUDO-013`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-020`
Evidence currently available: owner decision and policy docs.
Missing evidence: implementation proof and malformed/missing identity handling.
Why this matters: wrong-firm conflict/restore risk.
Unsafe change to avoid: relying on `brojPredmeta` alone.
Behavior blocked until: firm identity model is audited.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-012

Gap name: version/change-log visibility gap
Affected module: lifecycle/log/version, Pregled i potvrda
Affected upgrade family: version/change-log visibility
Related pseudocode ID: `OPC-PSEUDO-016`, `OPC-PSEUDO-022`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-017`, `OPC-MODULE-CONTRACT-018`
Evidence currently available: owner decision and source-confirmed paths.
Missing evidence: increment/log coverage and review UI suitability.
Why this matters: future conflict reasoning needs reviewable history.
Unsafe change to avoid: filename `_vN` authority.
Behavior blocked until: version/log characterization exists.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: critical.
Classification: `OWNER DECISION / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-013

Gap name: Windows/Android runtime parity gap
Affected module: all workflows
Affected upgrade family: Windows/Android runtime parity
Related pseudocode ID: `OPC-PSEUDO-022`, `OPC-PSEUDO-026`
Related contract ID: all relevant contracts
Evidence currently available: shared source and selected legacy runtime notes.
Missing evidence: current fixed parity scenario results.
Why this matters: business truth must remain shared.
Unsafe change to avoid: assuming parity from source only.
Behavior blocked until: parity-sensitive behavior is characterized.
Owner decision required: only for intentional differences.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-014

Gap name: entitlement/payment/access boundary gap
Affected module: entitlement/packages/licensing, roles
Affected upgrade family: entitlement/package enforcement
Related pseudocode ID: `OPC-PSEUDO-014`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-023`
Evidence currently available: parser/policy tests and owner decisions.
Missing evidence: commercial access model and broad enforcement characterization.
Why this matters: package state must not mutate truth.
Unsafe change to avoid: package gates deleting or rewriting PREDMET data.
Behavior blocked until: access model is owner-approved and characterized.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: high.
Classification: `IMPLEMENTATION BLOCKED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-015

Gap name: document engine/add-on boundary gap
Affected module: PDF/documents, NALOG CVECARI, PARTA, CITULJE
Affected upgrade family: document engine/add-on boundary
Related pseudocode ID: `OPC-PSEUDO-011`, `OPC-PSEUDO-024`
Related contract ID: `OPC-MODULE-CONTRACT-014`, `OPC-MODULE-CONTRACT-025`
Evidence currently available: derivative-output policy and source paths.
Missing evidence: document data contracts and add-on combinations.
Why this matters: documents can become hidden policy if unbounded.
Unsafe change to avoid: independent document data owner.
Behavior blocked until: document contract is characterized.
Owner decision required: yes for packaging.
Technical audit required: yes.
Web readiness relevance: medium.
Classification: `TEST GAP / CHARACTERIZATION REQUIRED`.

## CHARACTERIZATION-GAP-ID: OPC-CHAR-GAP-016

Gap name: future Web/sync characterization gap
Affected module: future OPC Web/sync
Affected upgrade family: future OPC Web/sync readiness
Related pseudocode ID: `OPC-PSEUDO-021`, `OPC-PSEUDO-026`
Related contract ID: `OPC-MODULE-CONTRACT-026`
Evidence currently available: documented policy and guardrails.
Missing evidence: architecture, identity, conflict, storage, access, role, sync characterization.
Why this matters: Web must not create server-master or parallel truth drift.
Unsafe change to avoid: choosing architecture before audits.
Behavior blocked until: owner-approved architecture and characterization exist.
Owner decision required: yes.
Technical audit required: yes.
Web readiness relevance: primary.
Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.
