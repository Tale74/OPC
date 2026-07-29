# OPC — Gate 0 protection re-evaluation and closure map

**Status:** `NOT PASS FOR REMOVAL — 25 EXACT PATHS REMAIN BLOCKED — NO DELETION`
**Date:** 2026-07-29
**Base SHA:** `c441d04ee324141dc119f208b7a83fbd02acee35`
**Task branch:** `task/OPC-GATE-0-PROTECTION-REEVALUATION-CLOSURE`

## 1. Scope and authority

This map re-evaluates the 61 paths blocked by the first protection pass using:

- `docs/OPC_DOCUMENTATION_BLOCKER_SECTION_CROSS_MAP.md`;
- `docs/OPC_DOCUMENTATION_EXTRACTED_NORMATIVE_SEMANTIC_QUEUE.md`;
- `docs/OPC_DOCUMENTATION_SEMANTIC_CONSOLIDATION_EVIDENCE_REGISTER.md`;
- `docs/OPC_DOCUMENTATION_THEMATIC_SEMANTIC_CONSOLIDATION.md`;
- `docs/OPC_DOCUMENTATION_SEMANTIC_OWNER_DECISION_QUEUE.md`;
- subsequent Gate 0 technical audits and owner-decision records;
- the owner-approved dependency plan and current owner authority.

The owner authorized removal of groups 5, 6, 8 and 9 only after a complete
protection PASS. Any target without a proven authoritative successor stops the
whole removal cycle.

## 2. Control result

| Measure | Result |
| --- | ---: |
| Original logical targets | 115 |
| Original protection PASS | 54 |
| Original BLOCKED | 61 |
| Former blockers raised to protection PASS | 36 |
| Current total protection PASS | 90 |
| Current BLOCKED paths | 25 |
| `INSUFFICIENT_CONTEXT_PROTECTED` rows | 169 |
| Physical removals | 0 |

All 61 former blockers have complete section extraction: 1,234 sections
mapped, zero unresolved sections at the structural mapping level. Semantic
review nevertheless retains 169 claims whose extracted fragment does not
carry enough context to prove that removing its full source is safe.

The 169 rows have 183 path associations because some claims are evidenced by
both synchronized local copies or more than one source.

## 3. Exact remaining blocked paths

| Exact logical path | Insufficient-context claim associations |
| --- | ---: |
| `docs/tasks/OPC_TASK_CANONICAL_DATABASE_RECOVERY_LEGACY_MIGRATION_COMPATIBILITY_REPORT.md` | 5 |
| `docs/tasks/OPC_TASK_CEREMONY_REMINDER_SYSTEM_GDPR_STARTUP_DIALOG_OFF_REPORT.md` | 2 |
| `docs/tasks/OPC_TASK_DOCUMENTATION_ANTI_DRIFT_VALIDATION_GATE_PARTE_AUTHORITY_REPORT.md` | 4 |
| `docs/tasks/OPC_TASK_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md` | 1 |
| `docs/tasks/OPC_TASK_OWNER_DECISION_CONTINUITY_AND_CURRENT_STATE_AUDIT_REPORT.md` | 5 |
| `docs/tasks/OPC_TASK_OWNER_DECISION_PATCH_FIRM_SCOPED_BROJPREDMETA_AND_SINGLE_PREDMET_JSON_FILENAME_SEMANTICS_REPORT.md` | 2 |
| `docs/tasks/OPC_TASK_OWNER_DECISIONS_STATUSI_CEREMONIJA_DOCUMENTATION_REPORT.md` | 3 |
| `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md` | 2 |
| `docs/tasks/OPC_TASK_PDF_LOGO_MAX_LAYOUT_REPORT.md` | 2 |
| `docs/tasks/OPC_TASK_PDF_MEMORANDUM_HEADER_LOGO_LAYOUT_REPORT.md` | 1 |
| `docs/tasks/OPC_TASK_PODSETNIK_CONTROL_FLOW_USER_CONFIRMATION_AUDIT_REPORT.md` | 8 |
| `docs/tasks/OPC_TASK_PREDMET_OWNER_REVIEW_QUEUE_CONSOLIDATION_REPORT.md` | 3 |
| `docs/tasks/OPC_TASK_PROJECT_DOCS_PROMOTION_AND_TERMINOLOGY_LINEAGE_FACT_CHECK_REPORT.md` | 1 |
| `docs/tasks/OPC_TASK_PROJECT_SOUL_INCONSISTENCY_STANDARDS_AND_GROUND_LEVEL_MILESTONE_AUDIT_REPORT.md` | 6 |
| `docs/tasks/OPC_TASK_PUBLIC_CONTINUITY_BASELINE_TERMINOLOGY_AND_SOURCE_OF_TRUTH_MAP_REPORT.md` | 3 |
| `SOURCE_PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md + LOCAL_PROJECT_DOCS/OPC_v1_ARCHITECTURE_DECISIONS.md` | 21 |
| `SOURCE_PROJECT_DOCS/OPC_v1_chat_transkript_TASK_001.md + LOCAL_PROJECT_DOCS/OPC_v1_chat_transkript_TASK_001.md` | 4 |
| `SOURCE_PROJECT_DOCS/OPC_v1_PROJECT_FLOW_AND_DELTA.md + LOCAL_PROJECT_DOCS/OPC_v1_PROJECT_FLOW_AND_DELTA.md` | 19 |
| `SOURCE_PROJECT_DOCS/OPC_v1_PROJECT_SOUL.md + LOCAL_PROJECT_DOCS/OPC_v1_PROJECT_SOUL.md` | 5 |
| `SOURCE_PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md + LOCAL_PROJECT_DOCS/OPC_v1_ZAKLJUCANA_PRAVILA.md` | 49 |
| `SOURCE_ROOT_LOCAL_DOC/OPC_derivati_pdf_specifikacija.md` | 10 |
| `SOURCE_ROOT_LOCAL_DOC/OPC_IMPLEMENTACIONI_LOGICKO_POSLOVNI_PLAN_RESTORE_TACKA.md` | 9 |
| `SOURCE_ROOT_LOCAL_DOC/OPC_IRIU_zakljucani_plan_i_poslovna_logika.md` | 12 |
| `SOURCE_ROOT_LOCAL_DOC/OPC_zakljucana_poslovna_logika_core_sazetak_v2.md` | 5 |
| `SOURCE_ROOT_LOCAL_DOC/RESTORE_POINT_PRE_PDF_LANE.txt` | 1 |

## 4. Disposition of the other 36 former blockers

The other 36 former blockers are raised to `PASS_AFTER_EXTRACTION` because:

- every source section is represented in the section cross-map;
- normative/owner-signal lines are retained in the evidence register;
- closed owner decisions are present in current decision records;
- unresolved business clusters remain explicitly preserved in the current
  owner decision queue for their dependency stage;
- Git-tracked reports retain full history;
- technical and procedural statements are governed by the current plan,
  manifest, source, tests and current technical audit documents.

This classification does not authorize partial removal while section 3
contains any blocked path.

### 4.1 `SOURCE/PROJECT_DOCS` is a mixed evidence source

`SOURCE/PROJECT_DOCS` is neither wholly authoritative nor wholly obsolete.
Its 14 files must not receive one folder-level disposition.

Five logical source/control-copy pairs remain blocked:

- `OPC_v1_ARCHITECTURE_DECISIONS.md`;
- `OPC_v1_chat_transkript_TASK_001.md`;
- `OPC_v1_PROJECT_FLOW_AND_DELTA.md`;
- `OPC_v1_PROJECT_SOUL.md`;
- `OPC_v1_ZAKLJUCANA_PRAVILA.md`.

Together they carry 98 insufficient-context path associations. They contain
relevant owner/business continuity mixed with superseded or historical text.
The remaining `SOURCE/PROJECT_DOCS` files have provisional successors or
historical disposition, but the global stop rule keeps the whole physical
cleanup closed until the five mixed documents have complete section-level
current successors.

No `SOURCE/PROJECT_DOCS` file is treated as current authority merely because it
is local, and no file is treated as obsolete merely because it is old.

## 5. Stop result

The owner stop condition is met by 25 paths. Therefore:

- no group 5, 6, 8 or 9 target is removed in this cycle;
- no local documentation file is removed or renamed;
- no ignored root evidence file is removed;
- no Git history rewrite is performed;
- physical Git/local authority synchronization remains blocked;
- `develop/opc-v1` is not created;
- Gate 0 is not declared closed.

Separately, the owner explicitly authorized deletion of the obsolete,
Git-ignored `_IMPORT_TEST_INPUTS` directory. That private test-input cleanup is
outside groups 5, 6, 8 and 9 and does not change the zero documentation-removal
result in this map.

## 6. Required successor work

The next documentation work must create section-level current successors for
the 169 claims, not ask the owner to review 169 isolated fragments. Claims are
grouped by their already planned dependency domains:

- canonical database/backup/restore;
- PREDMET identity, lifecycle, version and local audit log;
- SCENARIO/IRiU/KATALOG and PODSETNIK;
- standard PDF/document formation;
- role/recovery policy;
- documentation governance and historical milestones.

Codex first resolves technical, architectural and procedural claims from
source, tests and current authority. Only genuine unresolved business-policy
conflicts return to the owner.

## 7. Gate result

`PROTECTION RE-EVALUATION COMPLETE — 90 PASS / 25 BLOCKED — GLOBAL OWNER STOP ENFORCED — GATE 0 NOT CLOSED`
