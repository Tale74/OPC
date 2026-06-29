# OPC Task Report - Logos Knowledge Transfer

Task: OPC KNOWLEDGE TRANSFER TO LOGOS - COMPLETE PRODUCT, BUSINESS, MODULE, SOURCE, AND UPGRADE MAP

Branch: `task/OPC-LOGOS-KNOWLEDGE-TRANSFER`

Base commit: `90c203947cd781d6bd837647485b10d72f181fe2`

## OPC MANIFEST CHECK — TASK START

Manifest read: yes.

Task class: documentation / audit.

Core purpose preserved: yes.

PREDMET meaning affected: no.

Database ownership affected: no.

JSON transfer affected: no.

Windows/Android parity affected: no.

Future Web Pristup affected: no.

Terminology drift risk: no; protected terminology is preserved and mixed `Platilac`/`narucilac` state is documented as compatibility-sensitive.

Implementation allowed: no.

Required gate before implementation: none for this docs-only task.

## 1. Title And Task Metadata

Created a public knowledge-transfer package for Logos covering OPC product purpose, PREDMET-centered modular architecture, source learning order, child-illness symptoms, safe upgrade grouping, and implementation stop boundaries.

## 2. Baseline Branch / Commit

Baseline branch before task: `task/OPC-BUSINESS-POLICY-EVALUATOR-DEEP-AUDIT`

Baseline commit: `90c203947cd781d6bd837647485b10d72f181fe2`

New branch: `task/OPC-LOGOS-KNOWLEDGE-TRANSFER`

## 3. Manifest Start Confirmation

Manifest and task template were read. The task was treated as docs-only knowledge transfer.

## 4. Scope Confirmation: Knowledge-Transfer / Docs-Only

No source, database, schema, migration, UI, PDF, JSON behavior, import/export, backup/restore, evaluator behavior, Web/backend/API/sync, storage, payment, licensing, entitlement, role, or test behavior changes were made.

## 5. Files Inspected

Mandatory public docs were inspected:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_FULL_BUSINESS_POLICY_AND_LOGIC_SNAPSHOT.md`
- `docs/OPC_BUSINESS_DOMAIN_AND_FLOW_MAP.md`
- `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`
- `docs/OPC_PREDMET_DEPENDENCY_MAP.md`
- `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`
- `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md`
- `docs/OPC_BUSINESS_POLICY_CONSEQUENCE_GRAPH.md`
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_COMPLETION_MATRIX.md`
- `docs/OPC_LOCKED_RULES_PUBLIC_SUMMARY.md`
- `docs/OPC_BACKUP_RESTORE_POLICY_PUBLIC_SUMMARY.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- task reports under `docs/tasks/`

Source/test evidence families were inspected/indexed:

- PREDMET table/repository/UI segments
- evaluator/IRiU truth/lifecycle/finance services
- STANJE ROBE services/repositories
- JSON/backup transfer utilities
- PDF builders/exporters
- FirmaPodaci/settings
- auth/users/session
- entitlements/licensing
- current tests under `test/`

## 6. Files Changed

- `docs/OPC_LOGOS_KNOWLEDGE_BASE.md`
- `docs/OPC_MODULE_RELATIONSHIP_MAP.md`
- `docs/OPC_SOURCE_LEARNING_INDEX_FOR_LOGOS.md`
- `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`
- `docs/tasks/OPC_TASK_LOGOS_KNOWLEDGE_TRANSFER_COMPLETE_PRODUCT_BUSINESS_MODULE_SOURCE_AND_UPGRADE_MAP_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`

## 7. Main Knowledge Base Created

Created `docs/OPC_LOGOS_KNOWLEDGE_BASE.md`.

It explains OPC as a functional, modular, PREDMET-centered product and records what Logos must preserve, understand, and still learn.

## 8. Module Relationship Map Created

Created `docs/OPC_MODULE_RELATIONSHIP_MAP.md`.

It maps PREDMET core and required modules by purpose, inputs, rules, outputs, source files, tests, state, symptoms, upgrade risks, and Web/sync relevance.

## 9. Source Learning Index Created

Created `docs/OPC_SOURCE_LEARNING_INDEX_FOR_LOGOS.md`.

It gives Logos an ordered practical reading path across manifest docs, PREDMET source, UI workflow, evaluator, IRiU, STANJE ROBE, finance, PARTA/CITULJE, PDF, JSON, backup/restore, FirmaPodaci, users/roles, packages/licensing, and tests.

## 10. Child-Illness / Register Created

Created `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`.

It groups unresolved symptoms into safe upgrade candidates and avoids nano-tasking.

## 11. Current OPC Product Summary

OPC is a functional local-first Flutter/Dart product with Windows and Android lanes, local Drift/SQLite data, PREDMET workflow, PDF/documents, single-PREDMET JSON, backup JSON, IRiU/services, STANJE ROBE consequences, finance/payment logic, local users/roles, FirmaPodaci, and entitlement/package gating.

## 12. Modular Architecture Findings

The correct architecture understanding is PREDMET-centered:

- PREDMET is master truth.
- Documents, JSON, finance, IRiU, STANJE ROBE, PARTA, CITULJE, contacts, review, and lifecycle modules derive from or attach to PREDMET.
- System modules such as FirmaPodaci, users, packages/licensing, backup/restore, and future Web/sync support the product but must not redefine PREDMET truth.

## 13. Business Policy / Evaluator Findings

The evaluator is implemented as a partial policy kernel. It derives condition flags and supports IRiU/finance consequences. It is not yet a complete ceremony advisor, warning checklist, PIO/refund guide, JKP/payer guide, document requirement graph, or full review guidance layer.

## 14. Current / Future Upgrade Findings

Findings only:

- business understanding gap: final advisor ownership and module boundaries need owner decisions;
- source understanding gap: Logos should follow the source learning index before orchestrating implementation;
- test coverage gap: full workflow, PDF, finance, PARTA/CITULJE, version/log, and parity tests remain incomplete;
- runtime confirmation gap: fresh Windows/Android parity smoke has not been run here;
- owner decision needed: advisor scope, terminology cleanup, refund/JKP guidance, document display policy, change-log content;
- safe upgrade candidate: grouped display, finance, evaluator, identity/transfer, and parity stabilization;
- implementation blocked: identity guards, Web/sync, payment, role architecture, migrations, import/restore behavior changes;
- child-illness symptom: rough edges should be grouped, not split into isolated nano-tasks;
- future architecture risk: server-master Web/sync drift must be avoided.

## 15. Major Knowledge Gaps Still Remaining

- exact runtime parity across Windows and Android;
- exact PDF render consistency;
- PARTA/CITULJE full workflow;
- PIO/refund and JKP/payer advisor rules;
- finance edge-case regression matrix;
- duplicate `brojPredmeta` creation behavior;
- `verzija` increment/change-log coverage;
- firm identity/history implementation model;
- Web/sync storage and ownership architecture.

## 16. Drift Risks

Documented drift risks:

- treating module output as master truth;
- treating filename as identity;
- treating `exportDatum` as freshness authority;
- treating Codex recommendation as strategy;
- making JSON/backup/restore the product center;
- fixing display symptoms by changing PREDMET truth;
- duplicating evaluator logic per platform;
- implementing Web as a server-master database.

## 17. Implementation Stop-List Confirmation

Stop-list preserved. This task does not authorize Web runner, backend/API, sync, storage adapter, migrations, payment/subscription, role implementation, package restructuring, source-code changes, database changes, import/export behavior changes, backup/restore behavior changes, evaluator behavior changes, UI/PDF changes, or test behavior changes.

## 18. Validation Results

Manifest gate result: PASS.

Command:

```text
python scripts\validate_opc_manifest_gate.py --base 90c203947cd781d6bd837647485b10d72f181fe2
```

## 19. Final Status

PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: yes.

Core purpose preserved: yes.

PREDMET meaning preserved: yes.

Database ownership preserved: yes.

Windows/Android parity preserved: yes.

Existing JSON transfer preserved: yes.

Terminology preserved: yes.

Future Web Pristup not blocked: yes.

Source changes within scope: yes, documentation only.

If not compliant, classify: not applicable.
