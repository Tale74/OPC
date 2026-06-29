# OPC Task Report - Business-Critical Source To Pseudocode Map

Task: OPC BUSINESS-CRITICAL SOURCE TO PSEUDOCODE MAP - LOGOS LEARNING LAYER

Branch: `task/OPC-BUSINESS-CRITICAL-PSEUDOCODE-MAP`

Base commit: `78f88228bb55526ae7c168c2aac0140ec3cb620c`

## OPC MANIFEST CHECK — TASK START

Manifest read: yes.

Task class: audit / documentation.

Core purpose preserved: yes.

PREDMET meaning affected: no.

Database ownership affected: no.

JSON transfer affected: no.

Windows/Android parity affected: no.

Future Web Pristup affected: no.

Terminology drift risk: no.

Implementation allowed: no.

Required gate before implementation: none for this docs-only task.

## 1. Title And Task Metadata

Created a public Logos learning layer that translates business-critical OPC source behavior into short pseudocode, source indexes, and safe grouped upgrade notes.

## 2. Baseline Branch / Commit

Baseline branch: `task/OPC-LOGOS-KNOWLEDGE-TRANSFER`

Baseline commit: `78f88228bb55526ae7c168c2aac0140ec3cb620c`

## 3. Manifest Start Confirmation

Manifest, task template, current public docs, Logos knowledge-transfer docs, and required local `PROJECT_DOCS` context were inspected. Local `PROJECT_DOCS` is present in this repo and treated as supporting/historical context only; public `docs/` remains current source of truth.

## 4. Scope Confirmation

Audit-only / docs-only / source-to-pseudocode-only. No implementation or behavior changes were made.

## 5. Files Inspected

Public docs inspected include manifest, Git workflow, task template, owner decisions, source-of-truth map, stop-list, current development state, business rule docs, PREDMET workflow docs, evaluator docs, Logos knowledge base, module relationship map, source learning index, child-illness register, and the prior Logos task report.

Local context inspected:

- `PROJECT_DOCS/00_README_KAKO_KORISTITI.md`
- `PROJECT_DOCS/OPC_v1_PROJECT_SOUL.md`
- `PROJECT_DOCS/OPC_v1_PROJECT_FLOW_AND_DELTA.md`
- `PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md`
- `PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md`
- `PROJECT_DOCS/OPC_v1_CODEX_RULES.md`
- `PROJECT_DOCS/OPC_v1_BACKUP_AND_RESTORE_POLICY.md`
- `PROJECT_DOCS/OPC_v1_AUDIT_SUMMARY.md`
- `PROJECT_DOCS/PROJECT_MAP_OPC_v1.json`
- `PROJECT_DOCS/PROJECT_MAP_OPC_v1_SUMMARY.md`

Business-critical source/test areas inspected:

- PREDMET table/repository/list/detail workflow source
- evaluator and IRiU truth/lifecycle source
- STANJE ROBE lifecycle/availability/repository source
- finance truth and PDF data builders
- PARTA/display composition source
- JSON single-PREDMET and backup/restore source
- entitlement/license/package source
- auth/users/session source
- current tests under `test/`

## 6. Files Changed

- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/tasks/OPC_TASK_BUSINESS_CRITICAL_SOURCE_TO_PSEUDOCODE_MAP_LOGOS_LEARNING_LAYER_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_BUSINESS_LOGIC_EXTRACTION_QUEUE.md`
- `docs/OPC_SOURCE_LEARNING_INDEX_FOR_LOGOS.md`
- `docs/OPC_CHILD_ILLNESS_AND_SAFE_UPGRADE_CANDIDATE_REGISTER.md`

## 7. Pseudocode Map Created

Created `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md` with 17 pseudocode sections covering required business-critical areas.

## 8. Pseudocode Index Created

Created `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md` with source-file-to-pseudocode learning entries.

## 9. Safe Upgrade Notes Created

Created `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md` with grouped safe upgrade findings, not nano-tasks.

## 10. Main Source Areas Converted To Pseudocode

Covered:

- PREDMET lifecycle;
- PREDMET identity/metadata;
- business policy evaluator;
- IRiU truth logic;
- business scenarios and consequences;
- STANJE ROBE;
- finance/financial truth;
- PARTA/CITULJE display composition;
- PDF/document derivation;
- JSON single-PREDMET transfer;
- backup/restore;
- entitlement/packages/roles overlay;
- users/auth/recovery;
- Pregled i potvrda / advisor future.

## 11. Business-Critical Areas Not Covered And Why

No runtime UI smoke was performed because the task is docs-only. No private/export/runtime data was inspected. No implementation behavior was changed. CITULJE is covered only where source-confirmed; exact full workflow remains technical audit material.

## 12. Major Bug/Nedoslednost Candidates Found

Candidates only:

- duplicate/global vs firm-scoped `brojPredmeta` identity gap;
- version/change-log visibility gap;
- JSON version/freshness warning gap;
- PARTA/PDF/JSON display composition consistency gap;
- finance/refund/JKP characterization gap;
- evaluator/advisor guidance gap;
- STANJE ROBE unresolved consequence visibility gap;
- Windows/Android runtime parity gap;
- entitlement/payment/role architecture gap.

## 13. Safe Upgrade Groups Identified

Identified 15 grouped upgrade findings in `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`, including formatting/validation, display composition, PARTA/CITULJE flags, evaluator/advisor, IRiU truth, stock visibility, finance/payment, PIO/refund, JKP/Platilac, JSON/version warnings, firm identity, change-log visibility, parity, entitlement, and document engine boundaries.

## 14. What Logos Must Learn From This Task

Logos should learn actual behavior shape from source-faithful pseudocode: what triggers each rule, what it outputs, which side effects exist, where evidence is strong, and where implementation is still blocked.

## 15. What Must Not Be Inferred From This Task

Do not infer implementation permission. Do not infer that pseudocode replaces source code. Do not infer that all candidates are confirmed bugs. Do not infer that JSON/backup/restore, PARTA, evaluator, finance, or any single module is the strategic center of OPC.

## 16. Implementation Stop-List Confirmation

Stop-list preserved. This task does not authorize source-code changes, database/schema changes, migrations, UI changes, PDF changes, JSON behavior changes, import/export behavior changes, backup/restore behavior changes, evaluator behavior changes, test behavior changes, Web/backend/API/sync/storage implementation, payment/licensing/entitlement implementation, role implementation, bug fixes, formatting fixes, refactors, cleanup, or speculative architecture.

## 17. Validation Results

Manifest gate result: PASS.

Command:

```text
python scripts\validate_opc_manifest_gate.py --base 78f88228bb55526ae7c168c2aac0140ec3cb620c
```

## 18. Final Status

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
