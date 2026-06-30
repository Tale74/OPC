# OPC Characterization Evidence Foundation

Status: docs-only characterization evidence baseline.

Base commit: `0f82e144a16bd40e1482fd67dd2346233991a623`

This document maps current evidence levels before future grouped upgrades. It does not authorize source, test, database, schema, migration, UI, PDF, JSON, import/export, backup/restore, evaluator, IRiU, STANJE ROBE, finance, entitlement, role, Web, sync, storage, payment, or runtime behavior changes.

## 1. Purpose

Lock current OPC business/logical behavior as evidence categories: test-confirmed, source-confirmed, documented policy, runtime-confirmed, runtime gap, test gap, characterization required, owner decision required, technical audit required, or implementation blocked.

## 2. Evidence Legend

- `TEST-CONFIRMED`: existing tests are documented or present for the behavior.
- `SOURCE-CONFIRMED`: source paths are identified and current docs record behavior, but tests do not fully protect it.
- `DOCUMENTED POLICY`: docs or owner decisions define the rule; implementation proof is separate.
- `RUNTIME-CONFIRMED`: runtime evidence is recorded in prior docs.
- `SOURCE-INFERRED`: behavior is inferred from source context and needs audit before being treated as proof.
- `TEST GAP`: tests are missing or incomplete.
- `RUNTIME GAP`: runtime validation is missing.
- `CHARACTERIZATION REQUIRED`: behavior must be locked before change.
- `IMPLEMENTATION BLOCKED`: no implementation until required evidence and decisions exist.

## 3. Owner Framing

OPC is a functional local-first project on an upgrade path. It is built from the foundation upward. `PREDMET` is the master business truth. Modules may read, render, transfer, analyze, warn, or operationally react to PREDMET truth, but must not become parallel PREDMET truth. Before behavior is changed, existing behavior must be characterized. A characterization gap is not a recommendation for a task; it is evidence that implementation is blocked until behavior is protected or deliberately changed by owner decision. Future OPC Web must remain possible without selecting Web implementation here.

Classification: `OWNER CLARIFICATION`.

## 4. Characterization-Before-Change Principle

If a future task changes business/logical behavior, it must first classify current evidence, identify expected behavior, record owner-approved intended behavior where policy changes, update pseudocode in the same task, and define tests or explicit technical-audit status.

Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## 5. What Counts As Characterized

Current behavior counts as characterized when it has one or more of:

- focused existing tests and named source paths;
- runtime evidence recorded in current docs;
- source-confirmed behavior with explicit test/runtime gaps;
- documented policy clearly separated from implementation proof;
- owner decision clearly separated from source/test/runtime proof.

Classification: `DOCUMENTED POLICY`.

## 6. What Does Not Count As Characterized

Assumptions, inferred behavior, UI observation without recorded runtime evidence, document wording without implementation proof, source paths without read/write boundary, filename patterns, local DB ids, or owner-reported behavior without source/test/runtime confirmation do not count as fully characterized.

Classification: `DOCUMENTED POLICY / CHARACTERIZATION REQUIRED`.

## 7. Existing Test Evidence

Existing test files found:

- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/json_transfer_regression_test.dart`
- `test/lista_predmeta_screen_smoke_test.dart`
- `test/login_screen_smoke_test.dart`
- `test/opc_local_license_parser_test.dart`
- `test/package_downgrade_migration_test.dart`
- `test/podesavanja_screen_smoke_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`

These tests protect selected behavior only. They do not prove full lifecycle, full finance, full PDF, full PARTA/CITULJE, full backup/restore, full parity, or Web readiness.

Classification: `TEST-CONFIRMED / TEST GAP`.

## 8. Source-Confirmed Evidence

Current docs cite source paths for PREDMET repository/UI/table, preminulo lice, Platilac/JKP, ceremony, evaluator, IRiU, STANJE ROBE, finance, PDF, JSON, backup, users/auth, FirmaPodaci, and entitlement. Source-confirmed behavior is not automatically test-confirmed.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 9. Documented Policy Evidence

Manifest, owner decision report, source-of-truth map, stop-list, modular foundation plan, module contracts, Web guardrails, grouped safe-upgrade plan, and legacy public-safe context define policy boundaries. Policy evidence must not be promoted into implementation proof.

Classification: `DOCUMENTED POLICY`.

## 10. Runtime-Confirmed Evidence

Legacy audit summaries record runtime evidence for selected STANJE ROBE flows and Android/narrow/KATALOG alignment. Current public docs still treat broad Windows/Android parity as a runtime gap.

Classification: `RUNTIME-CONFIRMED / RUNTIME GAP`.

## 11. Gaps And Blockers

Major blockers include full PREDMET lifecycle characterization, identity/version/change-log coverage, finance matrix, PDF rendering contracts, PARTA/CITULJE display composition, backup/restore safety proof, firm identity, runtime parity, and future Web/sync identity/conflict readiness.

Classification: `CHARACTERIZATION REQUIRED / IMPLEMENTATION BLOCKED`.

## 12. Pseudocode-To-Evidence Relationship

Pseudocode explains behavior for Logos and owner review. It must link to source/docs/test evidence but must not replace source code or become a second source of truth.

Classification: `DOCUMENTED POLICY`.

## 13. PREDMET Lifecycle Characterization

Create/open/save/close/reopen/finish/anonymize/delete are source-confirmed as repository/workflow behavior with partial smoke coverage. Full lifecycle behavior is not fully test-confirmed.

Classification: `SOURCE-CONFIRMED / TEST GAP / CHARACTERIZATION REQUIRED`.

## 14. PREDMET Identity/Version Characterization

`brojPredmeta` is firm-scoped, not global. `verzija` is a PREDMET business-version signal. `exportDatum` is export metadata. Filename `_vN` is not authoritative unless later proven and owner-approved.

Classification: `OWNER DECISION / SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 15. Business Policy Evaluator Characterization

Evaluator and scenario behavior are partially protected by business-policy/IRiU tests. Complete ceremony guidance/advisor behavior is not implemented or fully characterized.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED`.

## 16. IRiU Truth Characterization

IRiU active/suppressed/recommended/confirmed/dismissed and selected-row behavior are source-confirmed and partially test-confirmed through critical scenario tests. Full category map and downstream finance/document/stock coverage remain gaps.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / CHARACTERIZATION REQUIRED`.

## 17. STANJE ROBE Characterization

Operational toggle and selected consequence flows are test-confirmed in focused tests and runtime-confirmed in legacy summaries. Transfer/restore/sync and full visibility remain characterization gaps.

Classification: `TEST-CONFIRMED / RUNTIME-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 18. Finance/Payment Characterization

Finance is source-confirmed from PREDMET, IRiU, refund, JKP, advance, discount, and payment fields. Dedicated full finance calculation tests were not found.

Classification: `SOURCE-CONFIRMED / TEST GAP / CHARACTERIZATION REQUIRED`.

## 19. PARTA/CITULJE/Display Composition Characterization

PARTA and CITULJE are derivative/display areas with source-confirmed fields and documented gaps. Dedicated display composition tests were not found.

Classification: `PARTIALLY IMPLEMENTED / TEST GAP / OWNER DECISION REQUIRED`.

## 20. PDF/Document Characterization

PDFs are PREDMET-derived outputs. Source paths are documented, but PDF render/data contract regression tests are not found.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 21. JSON Import/Export/Conflict/Version Characterization

JSON transfer has regression tests and source-confirmed keep/replace/cancel behavior. Version/freshness warnings, firm identity guard, and future conflict policy remain characterization and owner-decision gaps.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / OWNER DECISION REQUIRED`.

## 22. Backup/Restore Characterization

Backup/restore is documented as broad local recovery with destructive risk. PIB/MB mismatch guard is documented policy, but implementation proof is not established in current docs.

Classification: `DOCUMENTED POLICY / POLICY EXISTS / IMPLEMENTATION NOT FOUND / TECHNICAL AUDIT REQUIRED`.

## 23. Entitlement/Package/Role Characterization

Entitlement parser/policy has tests and package downgrade coverage. Payment/access, broad enforcement, and cross-device role identity remain blocked.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / IMPLEMENTATION BLOCKED`.

## 24. Users/Auth/Recovery Characterization

Local login/auth/recovery is source-confirmed and smoke-tested. Stable Web/cross-device user/adviser/admin identity is not characterized.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED`.

## 25. Windows/Android Parity Characterization

Shared source and historical runtime notes exist, but current full parity for business workflows is not runtime-confirmed by this task.

Classification: `RUNTIME GAP / TECHNICAL AUDIT REQUIRED`.

## 26. OPC Web Readiness Characterization

Future Web/sync is policy-only and implementation-blocked. Identity, conflict, local DB id, firm scope, version, module output, role, storage, and access must be characterized before Web/sync implementation.

Classification: `DOCUMENTED POLICY / IMPLEMENTATION BLOCKED`.

## 27. Implementation Blocked Until Characterized

Any change to business/logical behavior is blocked until current behavior is characterized, intended behavior is owner-approved where policy changes, pseudocode is updated, and tests or technical-audit status are recorded.

Classification: `IMPLEMENTATION BLOCKED`.

## 28. Final Control Summary

Current OPC behavior is functional but unevenly characterized. Existing tests protect important slices, source confirms more behavior than tests protect, policy defines guardrails beyond implementation proof, and runtime parity/Web readiness remain audit-bound. This document is evidence mapping only and contains no implementation authorization.

Classification: `PASS WITH OWNER REVIEW QUEUE`.
