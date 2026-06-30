# OPC Modular Foundation Control Plan

Status: docs-only modular control plan.

Base commit: `9bea04a6411c92a045a39f8b8a522dafa9dbcf98`

This document defines control boundaries for future OPC grouped work. It is not an implementation specification and does not authorize source, database, schema, migration, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement, role, Web, sync, storage, payment, or test behavior changes.

## 1. Purpose

Create a foundation-up control plan for OPC so future tasks can identify evidence, gaps, risks, owner decisions, technical audits, and blocked implementation areas without turning symptoms into nano-tasks or Codex-authored strategy.

## 2. Evidence Legend

- `DOCUMENTED POLICY`: current public docs define the rule.
- `OWNER DECISION` / `OWNER CLARIFICATION`: owner decision report or task framing defines the rule.
- `SOURCE-CONFIRMED`: source files were previously inspected by the public docs and cited there.
- `TEST-CONFIRMED`: current docs cite tests for the behavior.
- `PARTIALLY IMPLEMENTED`: implementation evidence exists but the behavior is incomplete or has known gaps.
- `POLICY EXISTS / IMPLEMENTATION NOT FOUND`: policy is documented, but current implementation proof is missing.
- `TECHNICAL AUDIT REQUIRED`: source/runtime/test characterization is required before implementation.
- `OWNER DECISION REQUIRED`: owner must decide policy before implementation.
- `IMPLEMENTATION BLOCKED`: implementation is not authorized by this control plan.

## 3. Owner Framing

OPC is a functional local-first project on an upgrade path.

OPC is not a broken project.

OPC is not merely a documentation exercise.

OPC must be built from the foundation upward.

`PREDMET` is the master business truth.

Modules around `PREDMET` are derivative, operational, document, transfer, finance, stock, advisor, support, package/access, or future Web/sync layers.

A module may read, render, transfer, analyze, warn, or operationally react to PREDMET truth, but must not become parallel PREDMET truth.

Future OPC Web must remain possible, but no final Web technical solution is chosen in this task.

Classification: `OWNER CLARIFICATION`.

## 4. OPC As Functional Product On Upgrade Path

The public manifest defines OPC as a stable tool for funeral ceremony cases using `PREDMET` as central business truth for a firm/user that owns its local OPC database. Current source/docs describe working PREDMET, IRiU, JSON, entitlement, auth, KATALOG, STANJE ROBE slices, documents, and local-first runtime behavior with known test and audit gaps.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 5. Build-From-Foundation Principle

Future work must start from foundation evidence:

1. Confirm `PREDMET` truth and identity boundary.
2. Confirm core policy/evaluator/advisor consequences.
3. Confirm module contracts.
4. Confirm derivative output contracts.
5. Confirm operational side effects.
6. Confirm support/access boundaries.
7. Check future Web-readiness guardrails.

This is a classification order, not a task sequence.

Classification: `DOCUMENTED POLICY`.

## 6. PREDMET Core Truth

`PREDMET` owns the case business truth: identity, status, lifecycle, version, workflow fields, and source data used by JSON, PDFs, lists, reminders, statistics, IRiU, finance, STANJE ROBE consequences, and review.

Forbidden interpretation: PDF, JSON, Web, package, finance, stock, advisor, or UI output must not replace `PREDMET` as master truth.

Evidence: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_SOURCE_OF_TRUTH_MAP.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`; `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 7. Core Policy/Evaluator/Advisor Layer

The business policy evaluator reads PREDMET facts and produces derivative policy/consequence snapshots that affect IRiU and future advisor guidance. It must remain deterministic for the same PREDMET/business scenario inputs.

The future advisor/guidance layer is policy/future/blocked until owner scope, warning taxonomy, and technical design are audited. It may explain, warn, or guide; it must not invent business truth or silently write PREDMET changes.

Evidence: `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`; `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`; `docs/OPC_BUSINESS_POLICY_CONSEQUENCE_GRAPH.md`; `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.

Classification: `SOURCE-CONFIRMED / PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.

## 8. Module Contract Principle

Every module must have a declared class, read sources, write targets, allowed outputs, allowed side effects, forbidden side effects, truth boundary, characterization evidence needed, Web relevance, risk, and blocked implementation conditions.

If a module contract is unclear, the area is not implementation-ready.

Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## 9. Derivative Module Principle

Derivative modules render or transfer PREDMET-derived data. PARTA, CITULJE, PDF outputs, JSON files, reminders, statistics, and document add-ons may expose business-visible information, but they do not own the case truth.

Classification: `DOCUMENTED POLICY`.

## 10. Operational Module Principle

Operational modules can create operational side effects while remaining bounded. STANJE ROBE may apply/restore inventory effects and keep consequence records; PODSETNIK may provide reminder UX; IRiU can hold selected case rows. None of these may redefine PREDMET or KATALOG truth.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 11. Support/Access Module Principle

Users/auth, roles, FirmaPodaci, entitlement, packages, licensing, backup/restore, and future access layers support product operation. They may control access, actor context, identity metadata, recovery, transfer, or availability. They must not mutate PREDMET truth as a side effect of access or package state.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 12. Add-On/Package Module Principle

Package/add-on availability can hide, lock, or expose features. It must fail closed where documented and must not delete, rewrite, or reinterpret PREDMET data. `Osnovni`, `Srednji`, and `Potpuni` are canonical package terms.

Classification: `OWNER DECISION / SOURCE-CONFIRMED`.

## 13. Future OPC Web Readiness Principle

OPC Web remains a future complementary browser-access runtime for the same OPC product logic. This plan does not choose server, database, browser storage, sync, backend, API, licensing, payment, or role implementation.

Future Web work must preserve local/firma ownership, firm-scoped PREDMET identity, explicit transfer/restore semantics, module contracts, evaluator determinism, and PREDMET master truth.

Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

## 14. Characterization-Before-Change Principle

Any task that changes existing business/logical behavior must first produce characterization evidence for current behavior, identify owner-approved rule changes, update the pseudocode learning layer in the same task, and document the no-parallel-truth boundary.

No behavior-change implementation is authorized by this document.

Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## 15. Pseudocode-Learning-Layer Principle

The pseudocode layer helps Logos and the owner learn source-confirmed behavior. It is not source code, not executable truth, and not a second source of truth over the real source.

When a task clarifies business/logical behavior, the pseudocode map, index, and safe-upgrade notes must stay aligned.

Classification: `DOCUMENTED POLICY`.

## 16. Drift Risks

- Derivative outputs being treated as master truth.
- Web/server planning being treated as server-master PREDMET ownership.
- Filename, export date, or local DB id being treated as canonical identity.
- STANJE ROBE becoming parallel PREDMET or KATALOG truth.
- Package gates mutating case truth.
- Finance/PDF/display cleanup changing business meaning.
- Advisor/guidance wording becoming hidden business policy.
- Nano-tasking symptoms instead of grouping characterization evidence.

Classification: `TECHNICAL AUDIT REQUIRED / OWNER DECISION REQUIRED`.

## 17. What Must Never Be Treated As Strategy

This control plan must not be read as a roadmap, implementation sequence, priority order, or recommended next task. Upgrade families, owner decisions, audits, and blockers are evidence buckets only.

Classification: `DOCUMENTED POLICY`.

## 18. What Codex May Output

Codex may output:

- source-confirmed findings;
- documented-policy findings;
- gaps;
- risks;
- owner decision required;
- technical audit required;
- implementation blocked;
- characterization evidence needed;
- pseudocode sections created/updated;
- no-implementation confirmation.

Classification: `DOCUMENTED POLICY`.

## 19. What Logos/Owner Decide

Logos and the owner decide strategy, task selection, sequencing, prioritization, commercial direction, Web architecture, policy changes, package/access rules, and implementation authorization.

Classification: `OWNER DECISION`.

## 20. Open Owner Decisions

- Future advisor/guidance scope and warning taxonomy.
- JSON version conflict warning/hard-block policy.
- PREDMET version/change-log overview content and retention.
- Firm-scoped identity history and malformed/missing identity handling.
- Payment/access commercial model.
- Role model beyond current local admin/adviser behavior.
- Document add-on packaging boundaries.
- Future OPC Web architecture choice.

Classification: `OWNER DECISION REQUIRED`.

## 21. Technical Audits Required

- PREDMET lifecycle/version/log coverage.
- Single-PREDMET JSON import freshness and firm identity guards.
- Full backup/restore wrong-firm and destructive restore guards.
- Finance edge-case matrix.
- PDF/document render/data contract coverage.
- PARTA/CITULJE display composition and flags.
- IRiU category/rule map and consequence coverage.
- STANJE ROBE consequence transfer/restore/sync risk.
- Windows/Android parity characterization.
- Web/sync identity, storage, conflict, access, and security audit.

Classification: `TECHNICAL AUDIT REQUIRED`.

## 22. Implementation Blocked Areas

Implementation is blocked for Web/backend/API/sync/storage, payment/subscription, new role architecture, licensing/payment enforcement beyond current foundation, database/schema migrations, JSON behavior changes, import/backup/restore behavior changes, evaluator behavior changes, IRiU behavior changes, STANJE ROBE behavior changes, finance behavior changes, PDF behavior changes, UI behavior changes, and test behavior changes in this task.

Classification: `IMPLEMENTATION BLOCKED`.

## 23. Final Control Summary

OPC continues from `PREDMET` foundation upward. Modules may read, render, transfer, analyze, warn, or operationally react to PREDMET truth, but must not become parallel truth. Future Web remains possible through guardrails, not through a premature architecture choice. Grouped safe-upgrade families are evidence buckets, not roadmap or priority.

Classification: `PASS WITH OWNER REVIEW QUEUE`.
