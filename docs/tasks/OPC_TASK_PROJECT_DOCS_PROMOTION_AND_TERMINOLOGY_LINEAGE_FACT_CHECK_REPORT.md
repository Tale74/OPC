# OPC TASK PROJECT_DOCS PROMOTION AND TERMINOLOGY LINEAGE FACT-CHECK REPORT

Task: OPC PROJECT_DOCS PROMOTION AND TERMINOLOGY LINEAGE FACT-CHECK

OPC MANIFEST CHECK — TASK START

Manifest read: YES
Task class: documentation / fact-check / terminology audit
Core purpose preserved: YES
PREDMET meaning affected: NO
Database ownership affected: NO
JSON transfer affected: NO
Windows/Android parity affected: NO
Future OPC Web affected: NO
Terminology drift risk: YES - audited, no implementation
Implementation allowed: NO
Required gate before implementation: product terminology / source-of-truth

## Executive Conclusion

PASS WITH OWNER REVIEW QUEUE.

Both local `PROJECT_DOCS` sources were inspected. The 11 shared files in `SOURCE/PROJECT_DOCS` and `../PROJECT_DOCS` are byte-identical; `SOURCE/PROJECT_DOCS` has three additional SOURCE-only reports. No raw local document was promoted because the local set contains stale SaaS/customer/licensing wording, local process detail, and large chronological history. The safe promotion result is a public classification map and curated terminology lineage report.

The terminology lineage is mixed: `Platilac` is current visible UI/PDF/business display terminology, while `narucilac` remains current internal code/database/JSON/template terminology and appears in a PDF snapshot path. `klijent` is not established as a current PREDMET business-party term.

## Documents Inspected

- `README.md`
- `docs/`
- `docs/tasks/`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/PRODUCT_DIRECTION.md`
- `SOURCE/PROJECT_DOCS`
- `../PROJECT_DOCS`
- read-only source evidence under `lib/`, `test/`, PDF/export, UI, database/source model, and JSON utility paths

## Changed Files

- `docs/OPC_CANONICAL_TERMINOLOGY_GLOSSARY.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`
- `docs/tasks/OPC_TASK_PROJECT_DOCS_PROMOTION_AND_TERMINOLOGY_LINEAGE_FACT_CHECK_REPORT.md`

## PROJECT_DOCS Inventory And Classification

The detailed inventory table is in `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`.

Summary:

| Source | Finding |
| --- | --- |
| `SOURCE/PROJECT_DOCS` | 14 files inspected. |
| `../PROJECT_DOCS` | 11 files inspected. |
| Shared files | All 11 shared files are byte-identical. |
| SOURCE-only files | Three reports exist only in `SOURCE/PROJECT_DOCS`: re-entry audit, task 044, task 045. |
| Raw promotion | Not done. |
| Public-safe promotion | Classification map plus curated summaries/reporting. |

## PROJECT_DOCS Promotion Results

| Result | Documents |
| --- | --- |
| Already covered by public docs | Project soul, Codex rules, project map summary core facts. |
| Promote sanitized summary later | architecture decisions, audit summary, backup/restore policy, flow/delta, locked rules, project map JSON, re-entry audit, task 044, task 045. |
| Do not promote | chat transcript and raw private/control/local process copies. |
| Control copy status | backup/control copy only; no unique current truth found beyond byte-identical shared files. |

## Terminology Lineage Fact-Check

Detailed evidence is in `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`.

| Term | Exact spelling | Found where | Context | Layer | Current meaning | Current status | Evidence | Required action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Platilac | `Platilac` | `predmet_screen.dart` | PREDMET section label. | UI | payer section | CURRENT UI TERM | visible label is `Platilac` | preserve |
| PLATILAC | `PLATILAC ROBE I USLUGA`, `PLATILAC JKP TROŠKOVA` | `narucilac_segment.dart` | payer segment headings | UI | payer roles | CURRENT UI TERM | visible headings are payer terms | preserve |
| narucilac | `NarucilacSegment`, `narucilacRefundira` | UI class, database/export/finance/PDF logic | internal implementation naming | source model / database field / JSON / business logic | payer-related internal fields | INTERNAL CODE TERM | source uses `narucilac` while UI says `Platilac` | no rename now |
| NARUCILAC | `NARUCILAC` | database seeds/template segment ids | document template segment id | database seed / source model | segment identity | INTERNAL CODE TERM | seeded arrays contain `NARUCILAC` | migration audit required before change |
| NARUČILAC | `NARUČILAC IME`, etc. | `predmet_pdf_snapshot_export.dart` | audit-style PREDMET snapshot labels | PDF/export | payer/orderer fields | PDF LEGACY / MIXED | snapshot title is `PLATILAC`, fields remain `NARUČILAC` | owner cleanup decision required |
| PLATILAC | `PLATILAC: ...` | main PDF/list/racun/predracun/specifikacija paths | payer document section | PDF/export | payer display | CURRENT PDF TERM | commercial/list PDFs use payer terms | preserve |
| klijent | `klijent` | no current PREDMET source-party evidence found | N/A | unknown/docs-only | not established | NON-CANONICAL FOR PREDMET PARTY | reports already forbid replacing `narucilac` with it | keep forbidden as replacement |
| customer | `customerId`, `customerLabel` | license parser/model/tests/local docs | license customer metadata | test/licensing/docs | commercial/license customer | LICENSING TERM ONLY | not PREDMET party terminology | keep separate |

## Question 5/36 Status

PARTIALLY RESOLVED - OWNER REVIEW REQUIRED.

Evidence supports option 7: mixed state requiring future cleanup. More specifically:

- option 2 applies: `narucilac` is a current internal code/database/JSON term;
- option 3 likely applies: older/internal `narucilac` terminology has partly evolved into visible `Platilac`;
- option 4 applies in one PDF snapshot/export path;
- option 5 applies in settings/source-visible wording, while main PREDMET UI uses `Platilac`;
- option 6 applies to some old reports/docs, but not to source evidence;
- option 1 is not fully supported for current visible terminology.

## Public Docs Updated

- glossary updated with mixed lineage status;
- owner decision report addendum added for question 5/36;
- source-of-truth map updated with promoted public summary/report locations;
- public promotion map created;
- terminology lineage report created.

## Public Docs Intentionally Not Updated

`docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` was not changed. Its protected `narucilac` guard remains useful because implementation cleanup is not approved and compatibility-sensitive names still exist.

`README.md`, product direction, current state, and stop-list were not changed because this task did not change product identity or implementation boundaries.

## Private/Sensitive Data Exclusion Confirmation

No private databases, customer records, runtime exports, backup JSON, credentials, signing keys, license files, local machine config, build artifacts, or raw chat transcripts were added.

## Implementation Stop-List Confirmation

No source code, tests, UI labels, PDF labels, JSON keys, database fields, migrations, Web runner, backend/API, sync, payment/licensing/entitlement implementation, role implementation, storage adapter, or package restructuring was changed.

## Open Owner-Review Queue

- Decide whether `Platilac` should become the long-term canonical display and implementation term.
- Decide whether internal `narucilac` names remain compatibility names or get a future migration/cleanup.
- Decide whether PDF snapshot labels should align with main payer PDFs.
- Approve which local docs get future curated public summaries.
- Decide whether a public locked-rules summary should be created from `OPC_v1_ZAKLJUCANA_PRAVILA.md`.

## Safe Next Task Recommendation

Safe next task: create sanitized public summaries for selected local docs, starting with locked rules and backup/restore policy, without implementation changes.

Future implementation cleanup, if owner approves it, must be a separate guarded source/database/PDF/JSON compatibility task.

## Validation Results

| Check | Result |
| --- | --- |
| Docs-only diff | PASS - changed files are under `docs/` only. |
| Manifest gate | PASS - `python scripts\validate_opc_manifest_gate.py --base 6edc91e1a8d2d6e3f8a2ae47b237f03e446a1e29`. |
| Source code untouched | PASS - no `lib/`, `test/`, platform, database, migration, backend, Web runner, sync, payment/licensing/entitlement implementation, or package files changed. |
| Private/runtime/export/customer data excluded | PASS |
| Flutter analyze/test/build | Not run; docs-only task. |

## Final Git Status

Expected clean after commit/push; final handoff records actual `git status`.

OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES
Core purpose preserved: YES
PREDMET meaning preserved: YES
Database ownership preserved: YES
Windows/Android parity preserved: YES
Existing local JSON transfer preserved: YES
OPC Web not implemented: YES
OPC Web not described as SaaS: YES
No source implementation: YES
Changed files within scope: YES - documentation only
PASS / NOT PASS: PASS WITH OWNER REVIEW QUEUE
