# OPC Logos Knowledge Base

Status: public knowledge-transfer baseline for Logos.

Base commit: `90c203947cd781d6bd837647485b10d72f181fe2`

This document teaches Logos what OPC is, how the current product works, how modules relate to `PREDMET`, and where the safe upgrade path is constrained. It is docs-only. It does not authorize source, database, UI, PDF, JSON, backup/restore, evaluator, Web, sync, payment, licensing, role, entitlement, migration, or test behavior changes.

## 1. Purpose: Teaching Logos OPC

The purpose is to give Logos a persistent intellectual map of OPC as a functional product on an upgrade path. Logos should be able to reason about OPC product shape, module boundaries, evidence strength, and future risk without treating Codex recommendations as strategic direction.

This is not a bug hunt, not a narrow module audit, and not a JSON/backup/restore task.

## 2. Evidence Legend

| Label | Meaning |
| --- | --- |
| OWNER DECISION | Explicit owner decision recorded in public docs/task reports. |
| OWNER CLARIFICATION | Owner explanation of meaning or intended interpretation. |
| DOCUMENTED POLICY | Public docs define the rule. |
| SOURCE-CONFIRMED | Source code evidence supports the statement. |
| SOURCE-INFERRED | Reasonable source-based inference; needs caution. |
| TEST-CONFIRMED | Test evidence covers the behavior. |
| POLICY EXISTS / IMPLEMENTATION NOT FOUND | Policy exists, but matching implementation was not found/proven. |
| PARTIALLY IMPLEMENTED | Some behavior exists; full product capability is incomplete. |
| FUNCTIONAL BUT ROUGH | Product behavior exists but has rough edges or child-illness symptoms. |
| FUNCTIONAL CURRENT PHASE | Good enough as current phase baseline; still not final architecture. |
| TECHNICAL AUDIT REQUIRED | Must be audited before implementation. |
| OWNER DECISION REQUIRED | Owner decision is needed before implementation. |
| TEST GAP | No adequate test coverage confirmed. |
| RUNTIME GAP | No fresh manual/runtime parity confirmation. |
| UNCLEAR / NEEDS OWNER REVIEW | Evidence is ambiguous. |

## 3. OPC One-Sentence Definition

OPC is a local-first Flutter/Dart product for organizing funeral ceremony cases through `PREDMET` as the central business truth for a firm that owns its own OPC database.

Classification: `DOCUMENTED POLICY / SOURCE-CONFIRMED`.

## 4. OPC Product Purpose

OPC helps a funeral-service firm record one case, guide operational choices, prepare documents, manage selected goods/services, calculate case finance, track inventory consequences, transfer case data, and preserve continuity around the same `PREDMET`.

It is not merely a documentation exercise. It is a working modular tool whose next phase is disciplined strengthening, not reinvention.

## 5. Functional Current Product State

| Area | Current state | Classification |
| --- | --- | --- |
| Runtime | Flutter/Dart app with Windows and Android lanes. | `SOURCE-CONFIRMED / RUNTIME GAP` |
| Database | Local Drift/SQLite model. | `SOURCE-CONFIRMED` |
| PREDMET | Central case workflow and master business truth. | `DOCUMENTED POLICY / SOURCE-CONFIRMED` |
| Documents/PDF | PREDMET-derived PDF/document outputs exist. | `SOURCE-CONFIRMED / TEST GAP` |
| JSON transfer | Single-PREDMET JSON and full backup/database JSON exist as separate forms. | `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED` |
| IRiU | Articles/services rows, policy truth, lifecycle services. | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| STANJE ROBE | Inventory consequence logic exists and is operationally gated. | `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED` |
| Evaluator | Partial policy kernel for condition flags and IRiU/finance consequences. | `PARTIALLY IMPLEMENTED` |
| FirmaPodaci | Editable firm data exists; stable identity history is not complete. | `PARTIALLY IMPLEMENTED` |
| Packages/licensing | Entitlement policy and local license parser exist; payment implementation blocked. | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Roles | Local Administrator/Savetnik user logic exists; future firm/license role identity needs audit. | `SOURCE-CONFIRMED / TECHNICAL AUDIT REQUIRED` |
| OPC Web/sync | Future complementary runtime/access direction only. | `DOCUMENTED POLICY / NOT IMPLEMENTED` |

## 6. Owner/Product Framing

OPC is a functional project on an upgrade path.

OPC is not a broken project.

OPC is not merely a documentation exercise.

OPC is a modular tool centered on `PREDMET`.

`PREDMET` is the master business truth.

Modules around PREDMET are derivative, operational, document, transfer, finance, stock, advisor, or future-access modules.

Each module reads from PREDMET, applies module-specific rules, may produce outputs, may write controlled consequences, must not become independent master truth unless explicitly designed, and must remain faithful to PREDMET.

Classification: `OWNER CLARIFICATION`.

## 7. PREDMET As Master Business Truth

`PREDMET` is the only master business truth. It owns the case meaning. Other modules render, transfer, calculate, guide, or apply controlled consequences around it.

Do not confuse:

| Not master truth | Why |
| --- | --- |
| PDF | Rendered/document derivative. |
| JSON filename | User recognition aid only. |
| JSON transfer file | Transfer package, not identity authority. |
| STANJE ROBE | Operational stock consequence, not case truth. |
| Finance totals | Case calculation derivative. |
| PARTA/CITULJE | Display/document derivatives. |
| Future Web server | Access/runtime/support layer unless owner later approves server-master architecture. |

## 8. PREDMET Lifecycle In Product Language

Current lifecycle:

1. User creates a new PREDMET.
2. App generates metadata, status, version, adviser/user references, and initial IRiU rows.
3. User fills sections.
4. User saves working state.
5. User reviews and closes the case.
6. Closed cases can be reopened for edit.
7. Past ceremonies can become finished.
8. Finished cases can be anonymized.
9. Cases can be deleted with related data cleanup.
10. Single-PREDMET JSON can import as new or enter same-case keep/replace/cancel conflict flow.

Evidence: `lib/features/predmeti/data/predmeti_repository.dart`, `lib/features/predmeti/presentation/predmet_screen.dart`, `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 9. PREDMET Workflow In User Language

User-facing flow:

```text
Lista predmeta / NOVI PREDMET
-> Preminulo lice
-> Cinjenice o smrti
-> Statusi
-> Platilac
-> Ceremonija
-> Parte
-> Roba i usluge
-> Finansije
-> Dokumenti
-> Pregled i potvrda
-> Sacuvaj / Zatvori / Izmeni / Anonimizacija / Delete
```

The point of this flow is not just form entry. Each section feeds later modules and outputs.

## 10. PREDMET Data Families

| Family | Examples | Main downstream modules |
| --- | --- | --- |
| Case identity | `id`, `brojPredmeta`, `verzija`, status, timestamps | Review, JSON, logs, future sync |
| Deceased person | name, JMBG, birth/death facts, title/rank/profession/nickname | PDF, PARTA, CITULJE, JSON, review |
| Death facts | `mestoSmrti`, `uzrokSmrti`, `datumSmrti` | Evaluator, IRiU, documents |
| Status/PIO | work status, pension/refund fields, spouse fields | Finance, PIO/refund, payer shortcuts, PDF |
| Platilac/JKP | payer and JKP responsibility fields | Finance, documents, JSON |
| Ceremony/cemetery | ceremony date/time/type, cemetery, grob, opelo, reception | Evaluator, IRiU, PDF, review |
| Parte/display | `simbol`, `pismo`, `parteIme`, `ozaloseni`, display flags | PARTA, CITULJE, PDF |
| IRiU rows | selected articles/services | Finance, STANJE ROBE, documents, JSON |
| Contacts | related contact persons | JSON, documents, replacement flows |
| Finance | advance, discount, payment notes, JKP, refund | PDF, review |
| Lifecycle/log | snapshots, status, version | Review, auditability, future change-log |

## 11. PREDMET Identity And Firm Scope

Current implementation uses local technical `id` and current same-PREDMET import conflict lookup based on trimmed non-empty `brojPredmeta`.

Owner policy says future safe identity scope is:

```text
PIB + Maticni broj + brojPredmeta
```

`brojPredmeta` is unique only within the same firm. Deceased name and JSON filename are not conflict keys. `exportDatum` is export metadata only. `verzija` is a business-version signal, but current import behavior does not use it as an automatic comparator.

Classification: `OWNER DECISION / SOURCE-CONFIRMED / POLICY EXISTS / IMPLEMENTATION NOT FOUND`.

## 12. Modular Product Architecture

Conceptual model:

```text
OPC
`-- PREDMET = master business truth
    |-- PREDMET workflow points
    |-- business policy evaluator / advisor
    |-- derived modules
    |   |-- PARTA
    |   |-- CITULJE
    |   |-- PDF documents
    |   |-- JSON transfer
    |   |-- IRIU / articles / services
    |   |-- STANJE ROBE
    |   |-- finance/payment
    |   |-- PIO/refund
    |   |-- JKP / payer responsibility
    |   |-- contacts
    |   |-- lifecycle/log/version
    |   `-- Pregled i potvrda
    |-- system modules
    |   |-- users/advisers/admin future roles
    |   |-- FirmaPodaci
    |   |-- packages/licensing
    |   |-- backup/restore
    |   `-- future OPC Web/sync
    `-- upgrade path
        |-- safe characterization
        |-- grouped child-illness fixes
        |-- evaluator/advisor strengthening
        |-- module-rule stabilization
        `-- future architecture preservation
```

## 13. Module-By-Module Explanation

| Module | Product role | Current state |
| --- | --- | --- |
| PREDMET core | Master case container and lifecycle. | `FUNCTIONAL CURRENT PHASE / TEST GAP` |
| Preminulo lice | Identity and personal/death facts. | `SOURCE-CONFIRMED / TEST GAP` |
| Platilac / legacy narucilac | Payer data and compatibility naming layer. | `FUNCTIONAL BUT ROUGH / OWNER REVIEW REQUIRED` |
| JKP responsibility | Separate or same payer responsibility for JKP costs. | `SOURCE-CONFIRMED / TEST GAP` |
| Ceremony/groblje/opelo | Ceremony operational and document context. | `SOURCE-CONFIRMED / TEST GAP` |
| PIO/refund | Pension/refund/payment effect. | `SOURCE-CONFIRMED / TEST GAP` |
| IRiU | Selected articles/services and managed categories. | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| STANJE ROBE | Inventory consequence module. | `PARTIALLY IMPLEMENTED / TEST-CONFIRMED` |
| Finance/payment | Totals, payer, refund, JKP, payment notes. | `SOURCE-CONFIRMED / TEST GAP` |
| PARTA | PREDMET-derived public/display document area. | `PARTIALLY IMPLEMENTED / TEST GAP` |
| CITULJE | Document/IRiU derivative area. | `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED` |
| PDF/documents | Rendered outputs from PREDMET and related rows. | `SOURCE-CONFIRMED / TEST GAP` |
| JSON transfer | Single-case and backup transfer. | `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED` |
| Backup/restore | Broad recovery/import-export behavior. | `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED` |
| Pregled i potvrda | Review/lifecycle confirmation point. | `SOURCE-CONFIRMED / IMPLEMENTATION REQUIRED` for future change-log |
| Lifecycle/log/version | Status, snapshots, version signal. | `PARTIALLY IMPLEMENTED / TEST GAP` |
| Business policy evaluator | Condition flags and IRiU/finance consequences. | `PARTIALLY IMPLEMENTED` |
| Advisor/guidance future layer | Full ceremony guidance/checklist. | `POLICY EXISTS / IMPLEMENTATION NOT FOUND` |
| FirmaPodaci | Firm display/settings data. | `PARTIALLY IMPLEMENTED` |
| Users/advisers/admin | Local auth/session/user management. | `SOURCE-CONFIRMED / TEST-CONFIRMED / TECHNICAL AUDIT REQUIRED` |
| Packages/licensing | Entitlement/package gating. | `SOURCE-CONFIRMED / TEST-CONFIRMED` |
| Future OPC Web/sync | Complementary access/runtime direction. | `DOCUMENTED POLICY / NOT IMPLEMENTED` |

## 14. Business Policy Evaluator / Advisor Explanation

The current evaluator is a policy kernel. It reads selected PREDMET facts, derives condition flags, and allows IRiU/finance services to classify rows as active, suppressed, recommended, biohazard, derivative-excluded, or financially counted/excluded.

It is not yet a complete advisor.

## 15. What Evaluator Does Today

Source-confirmed evaluator behavior:

- resolves default funeral ceremony policy;
- normalizes death place;
- detects cremation;
- detects hospital death;
- detects local/gradsko cemetery;
- detects international case;
- detects reception of remains;
- detects override cause of death;
- detects biohazard precondition;
- feeds IRiU truth rules;
- supports managed row insertion/suppression/confirmation;
- supports financial truth inclusion/exclusion through IRiU truth.

## 16. What Evaluator / Advisor Does Not Yet Do

Not found as complete evaluator output:

- full ceremony guidance checklist;
- user-facing warning taxonomy;
- PIO/refund guidance;
- JKP/payer guidance;
- complete document requirement graph;
- complete STANJE ROBE consequence contract;
- full `Pregled i potvrda` business review model.

Classification: `POLICY EXISTS / IMPLEMENTATION NOT FOUND / TECHNICAL AUDIT REQUIRED`.

## 17. How Modules Derive From PREDMET

| Module | Derivation rule |
| --- | --- |
| PDF/documents | Render PREDMET facts, IRiU rows, payer, finance, firm, adviser, and version/status data. |
| JSON transfer | Serializes PREDMET plus approved child/related rows and metadata. |
| IRiU | Belongs to PREDMET and is influenced by PREDMET death/ceremony/cemetery conditions. |
| STANJE ROBE | Applies operational stock effects from covered IRiU categories. |
| Finance | Uses active positive IRiU rows, refund, advance, discount, JKP and payment fields. |
| PARTA/CITULJE | Use PREDMET display, ceremony, and document/category data. |
| Contacts | Child rows attached to PREDMET. |
| Review | Aggregates status, version, saved state, completeness, and lifecycle actions. |

## 18. How Modules Write Consequences

| Module | Writes consequence? | Boundary |
| --- | --- | --- |
| IRiU lifecycle | Yes, can insert/confirm/suppress related rows. | Must remain PREDMET-attached and policy-driven. |
| STANJE ROBE | Yes, can record applied/unresolved stock effects. | Must not become PREDMET truth. |
| JSON import replace | Yes, replaces PREDMET-related data while keeping local technical id. | Must preserve explicit user choice and identity rules. |
| Backup/restore | Yes, broad destructive import possible after confirmation. | Needs firm identity guard before stronger architecture. |
| Finance/PDF/PARTA/CITULJE | Mostly outputs/rendered derivatives. | Must not rewrite case truth except through explicit PREDMET fields. |
| Evaluator/advisor | Today mostly classifies; future advisor may write decisions only if explicitly designed. | Requires owner decision. |

## 19. How Documents Derive From PREDMET

Documents are outputs. They combine:

- deceased person facts;
- death facts;
- payer and JKP fields;
- ceremony/groblje/opelo facts;
- IRiU rows;
- finance/payment values;
- firm/adviser data;
- version/status/snapshot data.

Known risk: document preview/final PDF consistency and terminology cleanup are test gaps.

## 20. How JSON / Backup / Restore Relate To PREDMET

Single-PREDMET JSON transfers a case boundary. It carries PREDMET, IRiU, contacts, metadata, and allowed unresolved STANJE ROBE consequence transfer blocks. It is not the same as full backup.

Full backup/database JSON is broader recovery behavior and may be destructive after confirmation.

Future guard policy: PIB/MB mismatch must block import/restore. This is not fully implemented/proven.

## 21. How Finance / Payment / IRiU / STANJE ROBE Relate

IRiU rows form the bridge between operational services and finance. Active positive rows count for financial truth. Suppressed or non-positive rows are excluded. Some IRiU categories can also create STANJE ROBE consequences. Finance then applies payer/refund/JKP/advance/discount/payment notes.

Risk: changing evaluator or IRiU rules can alter finance, documents, and stock.

## 22. How PARTA / CITULJE Relate

PARTA is a PREDMET-derived display/document area using name, symbol, script, mourners, ceremony, and display flags.

CITULJE is partially extracted and appears through IRiU/document/entitlement evidence. Exact workflow and source-of-truth boundaries remain `TECHNICAL AUDIT REQUIRED`.

## 23. How PIO / Refund / JKP / Platilac Relate

PIO/refund depends on status/pension/refund fields and finance decisions. JKP depends on payer responsibility fields. Platilac is current visible payer terminology, while `narucilac` remains internal legacy/source/database/JSON terminology.

Risk: terminology cleanup must not break database/JSON/template compatibility.

## 24. How Pregled I Potvrda Should Function

Today it is the review/lifecycle action point: save, close, reopen/edit, status, version, and saved/unsaved state.

Owner decision says future version/change-log overview belongs here. Current implementation does not yet provide the full business change-log overview or complete advisor checklist.

Classification: `SOURCE-CONFIRMED / OWNER DECISION / IMPLEMENTATION REQUIRED`.

## 25. Current Source-Confirmed Implementation

Source-confirmed anchors:

- `lib/core/database/tables/predmeti_table.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/*.dart`
- `lib/features/predmeti/core_v2/business_policy/*.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/*.dart`
- `lib/features/stanje_robe/**/*.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/predmeti/pdf/*.dart`
- `lib/core/entitlements/*.dart`
- `lib/features/auth/**/*.dart`
- `lib/features/podesavanja/**/*.dart`

## 26. Test-Confirmed Behavior

Test-confirmed areas include:

- IRiU critical business policy scenarios;
- JSON transfer and replacement regressions;
- STANJE ROBE operational toggle/consequence behavior;
- local license parser;
- package downgrade migration behavior;
- selected login/settings/list smoke tests.

Test gaps remain for full workflow, PDFs, finance edge cases, PARTA/CITULJE, version/log overview, and runtime parity.

## 27. Policy-Only / Owner-Decision Rules

| Policy | Current implementation status |
| --- | --- |
| PREDMET is master truth | Supported by structure; policy is authoritative. |
| Windows/Android are equal product forms | Shared code supports; fresh runtime parity gap remains. |
| OPC Web is complementary and not server-master | Policy only; not implemented. |
| Firm-scoped identity is PIB + MB + brojPredmeta | Policy exists; guard not implemented/proven. |
| `exportDatum` is not freshness authority | Policy exists; current conflict UI displays metadata but does not use it as authority. |
| `verzija` conflict warning matrix | Owner decision; implementation required. |
| Future change-log overview in Pregled i potvrda | Owner decision; implementation required. |

## 28. Not Implemented / Waiting Items

- firm-scoped identity guard;
- PIB/MB import/restore mismatch block;
- automatic `verzija` conflict warning/comparator;
- PREDMET change-log overview;
- full ceremony advisor;
- PIO/refund advisor;
- JKP/payer advisor;
- complete document requirement graph;
- Web/sync architecture;
- payment/subscription implementation;
- stable cross-device role/license identity;
- complete CITULJE workflow extraction.

## 29. Known Child-Illness Symptoms

Child-illness symptoms are visible rough edges in a functional product, not proof that OPC is broken.

Known groups:

- manual number formatting and validation consistency;
- PARTA/PDF display composition consistency;
- nickname/title/rank/profession/middle-name display flags;
- document preview versus final PDF consistency;
- incomplete evaluator/advisor guidance;
- PIO/refund guidance gaps;
- JKP/Platilac consistency gaps;
- firm identity guard gaps;
- version/change-log visibility gaps;
- Windows/Android runtime parity gaps;
- JSON/backup/restore safety gaps.

## 30. Safe Grouped Upgrade Candidates

Findings-only categories:

| Category | Safe grouping |
| --- | --- |
| business understanding gap | Clarify module ownership and advisor responsibility. |
| source understanding gap | Read source in the order defined by the Logos learning index. |
| test coverage gap | Group tests by product risk: workflow, finance/PDF, IRiU, stock, transfer, parity. |
| runtime confirmation gap | Run Windows/Android parity smoke only under explicit validation task. |
| owner decision needed | Ask owner for policy before implementing advisor, terminology cleanup, role/payment, hard blocks. |
| safe upgrade candidate | Group small display/composition symptoms by module, not one nano-task per label. |
| implementation blocked | Identity, Web/sync, payment, role, migrations, import guards. |
| child-illness symptom | Treat as roughness to group and stabilize, not as strategic direction. |
| future architecture risk | Preserve local ownership and PREDMET truth. |

## 31. Drift Risks

Do not:

- treat module output as master truth;
- treat filename as identity;
- treat `exportDatum` as freshness authority;
- treat Codex recommendation as strategy;
- make JSON/backup/restore the center of product understanding;
- fix display symptoms by changing PREDMET truth;
- duplicate evaluator logic per platform;
- implement Web as server-master database;
- rename `narucilac` internals without compatibility plan;
- use package/licensing gates to alter PREDMET truth.

## 32. Things Logos Must Never Forget

1. `PREDMET` is master business truth.
2. OPC is functional and modular.
3. Current rough edges are upgrade candidates, not proof of failure.
4. Windows and Android are equal runtime forms.
5. Future Web is complementary access/runtime, not an implicit server-master.
6. Firma/user owns its database.
7. Single-PREDMET JSON and full backup JSON are different.
8. Human keep/replace/cancel choice in same-PREDMET import is intentional.
9. `verzija` is business-version signal, not automatic overwrite authority.
10. Codex findings are evidence, not owner strategy.

## 33. What Logos Still Does Not Know And Must Learn Next

Findings only:

- exact runtime parity behavior across Windows/Android;
- exact PDF render output consistency;
- exact PARTA/CITULJE workflow rules;
- complete PIO/refund and JKP/payer guidance rules;
- full finance edge-case matrix;
- duplicate `brojPredmeta` creation behavior;
- `verzija` increment coverage and change-log data source;
- firm identity/history implementation path;
- Web/sync architecture that preserves local database ownership.

