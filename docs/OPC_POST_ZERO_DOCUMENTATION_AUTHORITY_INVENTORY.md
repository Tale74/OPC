# OPC post-zero documentation authority inventory

**Status:** `ACTIVE POST-ZERO CLASSIFICATION REGISTER`
**Inventory baseline:** `0dde50fb073dbcad0af7d7ce1d9a53c8e5c61570`
**Inventory date:** 2026-07-30

## 1. Purpose

This register classifies every Markdown document currently tracked below
`docs/` without deleting Git history or treating pre-zero owner decisions as
current authority.

Historical verified inventory at the 2026-07-30 task start:

- 102 top-level Markdown documents in `docs/`;
- 92 task reports in `docs/tasks/`;
- one task template in `docs/templates/`;
- 195 tracked Markdown documents in total.

Those numbers are a dated audit snapshot, not a current file-count assertion.
Later reports and this reconciliation were added without changing the
classification rules below.

The classifications below are path-rule based and mutually exclusive. They
cover the complete inventory, including documents added later.

## 2. Classification order

Apply the first matching rule:

1. `CURRENT_POST_ZERO_OWNER_AUTHORITY`;
2. `PERMANENT_INCIDENT_EVIDENCE`;
3. `ACTIVE_GOVERNANCE_AND_CONTINUITY`;
4. `HISTORICAL_TASK_EVIDENCE`;
5. `PRE_ZERO_GOVERNANCE_OR_OWNER_EVIDENCE`;
6. `TECHNICAL_SOURCE_LEARNING_EVIDENCE`;
7. `FUTURE_SCOPE_EVIDENCE_ONLY`.

A lower class never overrides a higher class. Source and test evidence may
prove implemented behavior, but cannot approve a business-policy change.

## 3. Current post-zero owner authority

`CURRENT_POST_ZERO_OWNER_AUTHORITY`:

- `docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md`.

Only post-zero owner decisions recorded in this document or a later explicitly
owner-confirmed Git record are current owner authority.

## 4. Permanent incident evidence

`PERMANENT_INCIDENT_EVIDENCE`:

- `docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md`.

The register is retained permanently. Historical incident reports linked from
it remain Git evidence. Neither a technical diff nor a test PASS is owner
approval of a business change.

## 5. Active governance and continuity

`ACTIVE_GOVERNANCE_AND_CONTINUITY`:

- `docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`;
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`;
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`, prospective
  sequencing and current operative dependency-map role;
- `docs/OPC_AUTHORITATIVE_PLAN_REALITY_RECONCILIATION_REPORT.md`, current
  evidence matrix and reconciliation provenance;
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`;
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`;
- `docs/GIT_WORKFLOW_ARC.md`;
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`;
- `docs/templates/OPC_TASK_TEMPLATE.md`;
- the latest completed post-zero task report, within its exact scope only.

The reconciled plan is authoritative for current dependency ordering, not for
inventing business policy. The reconciliation report proves why status and
ordering changed. Earlier plan chronology remains Git historical evidence at
its recorded baseline SHA.

These documents control workflow, continuity and sequencing. They do not
revive a pre-zero owner decision quoted or linked inside them.

## 6. Historical task evidence

`HISTORICAL_TASK_EVIDENCE`:

- every `docs/tasks/*.md` report completed before the zero baseline;
- every later task report except the latest report within the exact scope being
  inspected.

Task reports remain available through the current tree and Git history until a
separate exact-path cleanup task proves that removal is safe. A report proves
what a task did and what evidence it obtained. It does not establish current
business authority.

## 7. Pre-zero governance or owner evidence

`PRE_ZERO_GOVERNANCE_OR_OWNER_EVIDENCE` includes:

- `docs/OPC_GATE_0_*.md`;
- `docs/OPC_DOCUMENTATION_*.md`;
- plan drafts, final candidates, review findings, review preparation and
  revision reports;
- `docs/OPC_OWNER_DECISION_*.md`;
- `docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md`;
- pre-zero locked-rule, removal, promotion and semantic-decision records.

These files are cleanup candidates, except where a later task proves they are
needed as technical, migration, compatibility, incident or Git evidence. Their
pre-zero owner statements are not current owner authority.

The approved dependency plan and its originating draft are specifically
retained as the prospective upgrade program. Retention does not change their
authority class.

## 8. Technical source-learning evidence

All remaining non-Web top-level Markdown documents are
`TECHNICAL_SOURCE_LEARNING_EVIDENCE`, including:

- architecture, module and dependency maps;
- database, migration, recovery, backup and JSON audits or pseudocode;
- PREDMET, lifecycle, IRiU, SCENARIO and evaluator characterization;
- Windows and Android runtime/performance audits;
- PDF, DOCX, PARTE, PODSETNIK and other derivative audits;
- characterization matrices, gap registers and test evidence;
- Logos learning maps and pseudocode.

They may be consulted for source behavior, compatibility, migration design and
anti-regression evidence. Business assertions in them are treated as source
characterization or prospective-plan input unless confirmed post-zero.

## 9. Future-scope evidence only

Documents whose primary subject is OPC Web, sync, hosting, backend, SaaS,
payment, subscription or international product-line implementation are
`FUTURE_SCOPE_EVIDENCE_ONLY`.

They may remain as risk or readiness evidence, but cannot open implementation
scope. OPC Web is not current implementation scope. `OPC_v.1_Int` cannot start
before OPC v.1 Serbia is completed and stabilized.

## 10. Removed local sources

Read-only verification on 2026-07-30 confirmed:

- repository `PROJECT_DOCS`: absent;
- former external parallel `PROJECT_DOCS`: absent;
- `_IMPORT_TEST_INPUTS`: absent;
- protected `BACKUPS`: present.

References to removed folders in historical documents describe historical
evidence only. They are not live dependencies or parallel authority.

`SOURCE/docs` is the single active local Git working copy of GitHub
documentation.

## 11. Cleanup gate

This inventory does not authorize bulk deletion.

Before removing a tracked document, a later cleanup task must:

1. identify the exact path and classification;
2. prove that current authority does not depend on it;
3. preserve required technical, migration, compatibility and incident evidence;
4. check incoming Markdown links;
5. record the base/final SHA and removal reason;
6. preserve Git history without rewrite.

`docs/OPC_INCIDENT_AND_ANTI_DRIFT_REGISTER.md`, backup evidence needed for safe
recovery, and canonical migration/compatibility evidence are protected.
