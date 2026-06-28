# OPC Task Report - Owner Decision, Continuity and Current Development State Audit

## Executive conclusion

This report records the owner decision pass after the project-soul audit and establishes a public, GitHub-verifiable continuity baseline.

The current safe conclusion is:

- OPC remains a local-first Flutter/Dart product for Windows and Android.
- `OPC Web` is now the canonical future term.
- `SaaS` is not a primary OPC product description and must be cleaned up later where it appears as old wording or internal placeholder terminology.
- OPC Web must not be treated as a server-master `PREDMET` database.
- The next milestone must be documentation/continuity/source-of-truth baseline work before any implementation.

No source code was changed. No private/export/runtime data was opened for content or committed.

PASS classification: PASS WITH OWNER REVIEW QUEUE.

## OPC MANIFEST CHECK — TASK START

Manifest read: YES

Task class:
- documentation / audit / continuity baseline

Core purpose preserved:
- yes

PREDMET meaning affected:
- no, audit only

Database ownership affected:
- no, audit only

JSON transfer affected:
- no, audit only

Windows/Android parity affected:
- no, audit only

Future Web affected:
- yes, terminology and baseline clarification only

Terminology drift risk:
- yes, this task records owner terminology decisions and fact-check queues

Implementation allowed:
- no

Required gate before implementation:
- owner decision / continuity baseline / terminology / source-of-truth gate

## Documents inspected

Public repo documents:

- `README.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/PRODUCT_DIRECTION.md`
- `docs/ARCHITECTURE_OVERVIEW.md`
- `docs/LOGOS_ACCESS_TEST.md`
- `docs/templates/OPC_TASK_TEMPLATE.md`
- current reports under `docs/tasks/`

Previous branch reports inspected or represented in current branch:

- Project soul / inconsistency / standards audit report.
- Local documentation inventory and continuity audit report.
- Manifest automated enforcement report.
- Purpose and anti-drift manifest integration report.
- Web access feasibility audit from `origin/task/OPC-WEB-ACCESS-RELEASE-READY-AUDIT`.
- Database / firm identity and JSON transfer safety audit from `origin/task/OPC-DATABASE-FIRM-IDENTITY-AND-JSON-SAFETY-AUDIT`.

Local docs inspected:

- `SOURCE\PROJECT_DOCS`
- `C:\Projekti\OPC\OPC v.1\PROJECT_DOCS`

Code/project state inspected:

- `lib/`
- `test/`
- `pubspec.yaml`
- platform folders as metadata/evidence only.

## OWNER DECISION REPORT

### Closed owner decisions

1. OPC Web terminology

Decision: canonical future term is `OPC Web`.

`SaaS` must not be used as the primary OPC product description. Existing `SaaS` wording is outdated or placeholder terminology until separately cleaned up.

2. OPC Web product role

Decision: OPC Web is not a replacement for Windows/Android. It is a complementary OS-proof access/runtime solution intended for commercial use according to service packages.

3. Windows/Android relation to OPC Web

Decision: Windows and Android functional solutions define what OPC Web must support. Current and future Windows/Android development must be assessed for applicability to OPC Web without blocking future OPC Web and without product drift.

4. Windows/Android parity

Decision: Windows and Android remain equal versions of the same OPC product.

Forbidden drift:

- Windows = master/admin/desktop-only truth.
- Android = field/mobile/slave version.

5. Remove `saas`

Decision: internal code/document label `saas` is inappropriate for the intended future OPC architecture and must be removed/replaced later with terminology aligned to `OPC Web`.

Status now: documented only. No source cleanup in this task.

6. OPC Web is not server-master PREDMET database

Decision: public documentation must explicitly say:

```text
OPC Web is not a server-master PREDMET database.
```

OPC Web must preserve local-replica model, firm ownership/control, `PREDMET` as master business truth, and no automatic centralization of the `PREDMET` database.

7. Server role in OPC Web

Decision: in future OPC Web, server may host only application, access, license, and auxiliary functions. Server must not be presumed as central/master `PREDMET` repository.

8. Server sync/signaling/mediation

Decision: OPC Web may use server for synchronization, signaling, or mediation between replicas only under issued license conditions for the concrete firm. No server copy becomes automatic master.

9. Firm as primary business user

Decision: the firm is the primary OPC business user, not an individual natural person. A firm may have administrators, advisers, or only an administrator for smaller firms.

10. Administrator / Adviser roles

Decision: Administrators and Advisers are future OPC roles tied to firm/license. No role implementation task until the ground-level baseline is completed.

11. Package model

Decision: future commercial packages remain:

- Osnovni
- Srednji
- Potpuni

No payment, entitlement, or licensing implementation before the ground-level baseline.

12. OPC built as Potpuni

Decision: OPC is built as full product (`Potpuni`), with available functions/services disabled according to paid package. Package differences must not change `PREDMET` meaning or create different business truths.

13. PREDMET as master truth

Decision: `PREDMET` remains the only master business truth regardless of package, platform, Windows, Android, OPC Web, sync, license, or auxiliary functions.

14. FirmaPodaci hybrid model

Decision: `FirmaPodaci` is hybrid. It describes the firm as a business entity, but firm data may change over time. Stable technical continuity must not rely only on currently editable `FirmaPodaci`.

15. FirmaPodaci history

Decision: OPC database must track changes in `FirmaPodaci` and preserve credible data before a change, after a change, and continuity between previous/current firm state.

16. Import/restore firm identity guard

Decision: OPC must block restore/import of a database or JSON if PIB/Matični broj do not match the current database. No exception inside import/restore guard. Any future transformation process must be separate and explicitly approved.

17. Local JSON transfer/backup

Decision: for local OPC applications, single `PREDMET` JSON and full backup/database JSON remain the basic transfer/backup models. Stronger identity/guard checks are required before broader OPC Web/sync use.

18. OPC Web technical research

Decision: OPC Web browser/storage implementation must go through a dedicated technical spike/audit before implementation. Future audit must consult current internet technical sources for persistence, quota/eviction, backup UX, offline behavior, database durability, and local-replica feasibility.

19. OPC Web offline/local-replica behavior

Decision: OPC Web must support offline/local-replica behavior as much as technically possible. Future audit must distinguish offline, online-required, interrupted-connection, preservation, reconciliation, and backup/safety warning behavior.

20. Promote local PROJECT_DOCS continuity material

Decision: local `PROJECT_DOCS` continuity material should be sanitized and promoted into public GitHub before the next major architecture task.

21. Next milestone order

Decision: next ground-level milestone must first be continuity/documentation baseline. Only after that may identity/import/sync/OPC Web technical tasks proceed.

22. No implementation in next milestone

Decision: the next ground-level milestone must explicitly forbid source-code changes, database migrations, Web runner, backend/API, sync, and payment/licensing implementation until continuity/documentation baseline is complete.

### Open questions not closed as owner decisions

Terminology `naručilac` / `klijent`

Status: FACT CHECK REQUIRED.

Fact-check result in this audit:

- `naručilac` / `narucilac` evidence exists in source and docs:
  - `lib/core/database/tables/predmeti_table.dart` has `Naručilac` sections and `narucilacRefundira`.
  - `lib/features/predmeti/presentation/segments/narucilac_segment.dart` exists.
  - PDF snapshot export contains `NARUČILAC` labels.
  - `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md` currently lists `narucilac` as protected.
- `klijent` was found in public docs as audit/manifest wording, not as established app UI/source business field in the inspected non-generated source.

Classification: `naručilac/narucilac` is present in OPC evidence, but owner says it is not his term. This requires terminology review, not automatic canonicalization. `klijent` must remain non-canonical unless owner approves.

Administrator/Savetnik identity

Status: TECHNICAL AUDIT REQUIRED.

Open issue: distinguish license slot, stable internal licensed-user/license ID, current display name, historical `PREDMET` signature, role type, and whether `PREDMET` stores snapshot name, internal ID, role type, or a combination.

Single PREDMET JSON vs full backup JSON

Status: TECHNICAL AUDIT REQUIRED.

Open issue: determine whether stronger public distinction is needed between single `PREDMET` export/import and full database/backup restore.

OPC Web local database architecture

Status: TECHNICAL ARCHITECTURE AUDIT REQUIRED.

Open issue: compare browser storage, OPFS, IndexedDB, SQLite/WASM, local file, local agent/service, database outside browser accessed through browser, hybrid models, and other feasible designs.

Conflict rules / same PREDMET changes

Status: EXISTING BUSINESS LOGIC EXTRACTION REQUIRED.

Open issue: extract from current OPC business policy/logic, not redesign from scratch.

## CURRENT OPC DEVELOPMENT STATE AUDIT

### Current application state

| Area | Current status | Evidence | Notes |
| --- | --- | --- | --- |
| Supported platforms | REALIZED | `android/`, `windows/`, README, architecture overview | Windows and Android are equal product runtimes. |
| Web runner/backend/API/sync | NOT REALIZED | no `web/`, no backend/API/sync architecture in repo evidence | OPC Web is future complementary runtime/access solution. |
| App architecture | PARTIALLY REALIZED | `lib/core`, `features/auth`, `features/predmeti`, `features/podesavanja`, `features/stanje_robe` | Functional but many boundaries remain in one Flutter package. |
| Local database | REALIZED | Drift/SQLite under `lib/core/database`, schema version 17 in architecture docs/code evidence | Runtime DB files excluded from Git. |
| JSON single PREDMET transfer | REALIZED | `lib/core/utils/json_export_import.dart`, `lib/core/json_transfer/predmet_json_transfer_core.dart`, JSON tests | Needs identity guard before broader replica/Web use. |
| Full backup/database JSON | REALIZED / PARTIALLY GUARDED | backup export/import code and tests | Destructive restore confirmation exists; firm identity mismatch guard not yet implemented. |
| PDF/report/export | REALIZED / PARTIAL | PDF files under `lib/features/predmeti/pdf` | Existing PDFs exist; legal/release readiness remains separate. |
| Reminder/date functionality | PARTIALLY REALIZED | `features/predmeti/reminders`, local docs map `podsetnik` partial | In-app reminder foundation exists; package/add-on gating incomplete. |
| Firm data | REALIZED / NEEDS AUDIT | `FirmaPodaci` singleton table, settings repository/UI | Hybrid/changeable; history and identity guard not implemented. |
| Package/licensing/entitlement | PARTIALLY REALIZED | `lib/core/entitlements`, `OpcEntitlementPolicy`, local license parser | Foundation exists; payment/licensing implementation not authorized. |
| Tests | REALIZED / NEEDS CURRENT RUNTIME VERIFICATION | 9 Dart test files | Previous reports record green checkpoints; this task did not run Flutter tests. |
| Public docs | PARTIALLY REALIZED | `docs/` and task reports | Public baseline exists but local PROJECT_DOCS not yet promoted. |
| Local docs | REALIZED LOCALLY / NEEDS PROMOTION | `SOURCE\PROJECT_DOCS`, control `PROJECT_DOCS` | Must be sanitized before public source-of-truth use. |

### Functional baseline

Windows:

- Evidence-backed status: REALIZED runtime lane in repo, with checked-in Windows runner and Windows installer tooling.
- Not classified as admin/master runtime.
- Needs runtime verification for any current release claim.

Android:

- Evidence-backed status: REALIZED runtime lane in repo, with checked-in Android runner.
- Not classified as field/slave runtime.
- Local docs record prior Android smoke checkpoints, but current runtime verification was not rerun in this task.

Shared baseline:

- One Flutter/Dart codebase.
- Shared `PREDMET` logic and local Drift database.
- Shared JSON transfer and PDF/business document foundations.

### Web baseline

- No Web runner/backend/API/sync is implemented in repo evidence.
- OPC Web is future complementary OS-proof solution.
- OPC Web must support product logic defined by Windows/Android.
- Implementation path is not chosen.
- Browser-local database is only a candidate, not a final owner decision.
- Database outside browser but accessed through browser must be evaluated in future architecture audit.
- OPC Web is not a server-master `PREDMET` database.

### Identity baseline

- Firm identity core for guard policy: PIB + Matični broj per owner decision.
- `FirmaPodaci` is hybrid/changeable and must preserve history.
- Import/restore must block PIB/Matični broj mismatch, with no exception inside the import/restore guard.
- Administrator/Savetnik stable ID requires technical audit.
- `PREDMET` opener/signature model requires technical audit.
- Technical database/repository identity remains open.
- Current code has `sourceIdentity` and static `databaseIdentity: OPC`, but neither is sufficient as stable repository identity.

## Project map realization matrix

| Project-map item | Evidence source | Current status | Notes | Blocking questions |
| --- | --- | --- | --- | --- |
| PREDMET core | `PROJECT_MAP_OPC_v1.json`, `features/predmeti`, DB tables | REALIZED | Core exists and is central truth. | future extraction only. |
| PREDMET metadata/versioning | project map, `predmeti_table.dart`, repository | REALIZED / NEEDS AUDIT | Metadata exists; historical signature model still open. | Administrator/Savetnik identity audit. |
| Single-PREDMET JSON transfer | project map, JSON code/tests | REALIZED | Basic transfer works. | identity guard and business logic extraction. |
| PREDMET conflict replace | project map, JSON import flow | REALIZED / NEEDS EXTRACTION | Same `brojPredmeta` conflict exists. | extract full existing conflict rules. |
| PREDMET UI surfaces | project map, UI files | PARTIALLY REALIZED | Functional but large/dense. | no broad refactor until baseline. |
| Business policy/scenario | project map, `core_v2/business_policy` | PARTIALLY REALIZED | Foundation exists. | extract existing business logic before new sync rules. |
| Auth/users/roles/recovery | project map, `features/auth` | REALIZED / TECH AUDIT REQUIRED | Local roles and PIN model exist. | stable licensed-user identity. |
| KATALOG core | project map, DB/repositories/UI | REALIZED / PARTIAL | Catalog foundation exists. | package/productization decisions. |
| Entitlement policy | project map, `core/entitlements` | PARTIALLY REALIZED | Policy and parser exist. | no licensing implementation yet. |
| Licensing persistence/activation | project map, entitlement code | PARTIALLY REALIZED | Local license file/parser exists. | production/payment/license task forbidden now. |
| Local-first / SaaS-ready identity | project map | SUPERSEDED TERMINOLOGY | Intent becomes OPC Web/local-replica identity baseline. | terminology cleanup. |
| Backup/restore policy | local docs, JSON backup code | REALIZED / NEEDS GUARD | Local policy strong; code lacks PIB/MB block. | firm identity guard audit. |
| Encoding/project safety | local docs | REALIZED AS RULE | Encoding gate exists in local docs. | promote to public docs. |
| IRiU | project map, `features/predmeti` | PARTIALLY REALIZED | Functional but redesign/engine split remains. | business logic extraction. |
| PDF/documents | PDF code | PARTIALLY REALIZED | Existing PDFs real; future document engine/add-ons not complete. | release/legal decisions. |
| STATISTIKA | project map, statistics files | REALIZED / PARTIAL | Current implementation exists. | no current runtime verification. |
| JSON import/export | JSON code/tests | PARTIALLY REALIZED | Strong base, mixed responsibilities. | identity/guard distinction. |
| STANJE ROBE inventory/admin | project map, feature files/tests | REALIZED / PARTIAL | Current reference module exists. | full productization/procurement history open. |
| PODSETNIK | project map, reminders service | PARTIALLY REALIZED | Local foundation. | package/add-on gate. |
| NALOG CVEĆARI / PARTE / ČITULJE extras | project map | PLANNED | Not treated as complete. | owner/package decisions. |
| Release/signing lane | project map | FOUNDATION | Not release approval. | release checklist audit. |
| Full database backup/import | project map, JSON code | PARTIALLY REALIZED | Backup exists; identity guard missing. | PIB/MB block design. |
| LK/OCR future seam | project map | FUTURE | Not current implementation. | later owner decision. |
| Advanced document engine | project map | FUTURE | Not current implementation. | later technical design. |
| SaaS/multi-device sync future | project map | SUPERSEDED TERM / FUTURE AUDIT | Replace with OPC Web/sync terminology. | technical architecture audit. |
| Licensing server future | project map | FUTURE | No implementation. | forbidden until baseline. |

## Business logic extraction queue

Items where existing OPC business policy/logic must be extracted before redesign:

- Conflict rules when two flows affect same `PREDMET`.
- `PREDMET` lifecycle: open, close, reopen/edit, versioning, autosave/exit decisions.
- JSON import replacement behavior and local technical ID preservation.
- STANJE ROBE consequences, warnings, close-blocks, and role boundaries.
- IRiU truth/rules and relationship to `PREDMET`.
- Financial truth rules and refund/JKP logic.
- Package visibility rules that must not alter `PREDMET` truth.
- Local role/session rules that constrain future OPC Web roles.

## Documentation promotion plan

| Local document | Folder source | Classification | Promote? | Sanitization needed? | Reason |
| --- | --- | --- | --- | --- | --- |
| `00_README_KAKO_KORISTITI.md` | both | MASTER / CURRENT | yes | yes | Defines use of PROJECT_DOCS. |
| `OPC_v1_PROJECT_SOUL.md` | both | MASTER / CURRENT | yes | yes | Captures project soul. |
| `OPC_v1_PROJECT_FLOW_AND_DELTA.md` | both | MASTER / CURRENT | yes | yes | Long continuity/history and current flow. |
| `OPC_v1_ZAKLJUCANA_PRAVILA.md` | both | MASTER / CURRENT | yes | yes | Locked rules. |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` | both | MASTER / CURRENT | yes | yes | Architecture decisions. |
| `OPC_v1_CODEX_RULES.md` | both | SUPPORTING / CURRENT | yes | yes | Operating rules; merge with public workflow. |
| `OPC_v1_BACKUP_AND_RESTORE_POLICY.md` | both | SUPPORTING / CURRENT | yes | yes | Backup/restore discipline. |
| `PROJECT_MAP_OPC_v1_SUMMARY.md` | both | SUPPORTING | yes | yes | Human-readable map. |
| `PROJECT_MAP_OPC_v1.json` | both | SUPPORTING / NEEDS OWNER REVIEW | maybe | yes | Machine-readable map; risk of stale terminology. |
| `OPC_v1_AUDIT_SUMMARY.md` | both | SUPPORTING / HISTORICAL MIXED | maybe | yes | Large historical audit summary. |
| `OPC_v1_chat_transkript_TASK_001.md` | both | HISTORICAL | no by default | yes | Transcript/history, not baseline truth. |
| `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md` | SOURCE only | SUPPORTING / CURRENT | maybe | yes | Later continuity report. |
| `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md` | SOURCE only | SUPPORTING / CURRENT | maybe | yes | Baseline report. |
| `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md` | SOURCE only | SUPPORTING / CURRENT | maybe | yes | Operating mode report. |
| old root `OPC_*.md` / `RESTORE_POINT_*.txt` | SOURCE root / old source | HISTORICAL / SUPERSEDED | no | yes | Useful history, not public truth. |
| private/import JSON/export/runtime data | ignored folders | PRIVATE / DO NOT PROMOTE | no | n/a | Must not enter public repo. |

## Terminology drift control

Confirmed for future public terminology:

- `OPC Web`
- `PREDMET`
- `firma`
- `ADMINISTRATOR`
- `SAVETNIK`
- `Osnovni`
- `Srednji`
- `Potpuni`

Fact-check / audit terms:

- `naručilac` / `narucilac`: present in source and PDF labels; owner review required before declaring canonical.
- `klijent`: not established as app source/UI business term in inspected non-generated source; do not introduce.
- `saas`: inappropriate for intended future OPC architecture; future cleanup required.
- `OPC Web Pristup`: existing public term in current docs; owner now chooses canonical `OPC Web`.

## Implementation stop-list

Do not implement until continuity/documentation baseline and relevant audit statuses are closed:

- source-code changes;
- database migrations;
- Web runner;
- backend/API;
- sync;
- payment/licensing implementation;
- entitlement implementation;
- browser/local storage architecture;
- role/license identity implementation;
- identity/import/restore guard implementation without prior technical audit;
- `saas` source cleanup in code;
- terminology rewrites in source/UI;
- PROJECT_DOCS bulk promotion without sanitization.

## Source-of-truth baseline

Current public source-of-truth:

- manifest: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- workflow: `docs/GIT_WORKFLOW_ARC.md`
- product direction: `docs/PRODUCT_DIRECTION.md`
- architecture baseline: `docs/ARCHITECTURE_OVERVIEW.md`
- task template: `docs/templates/OPC_TASK_TEMPLATE.md`
- current task reports under `docs/tasks/`

Current local continuity truth candidates:

- core `SOURCE\PROJECT_DOCS` and matching control folder documents.

Current source-of-truth gap:

- public docs do not yet contain enough sanitized local PROJECT_DOCS continuity material for Logos/Codex to work only from GitHub.

## Safe next task recommendation

Next safe task:

```text
OPC PUBLIC CONTINUITY BASELINE, TERMINOLOGY GLOSSARY AND SOURCE-OF-TRUTH MAP
```

Allowed scope:

- docs only;
- promote sanitized local PROJECT_DOCS material;
- create canonical terminology glossary;
- create source-of-truth map;
- create implementation stop-list;
- mark historical/superseded docs;
- update manifest/product docs to use `OPC Web` and explicitly state that OPC Web is not a server-master `PREDMET` database.

Forbidden scope:

- source changes;
- database migrations;
- Web runner;
- backend/API;
- sync;
- payment/licensing/entitlement implementation.

## Validation

Required validation for this task:

- manifest gate must pass;
- changed files must be docs-only;
- no private/export/runtime/customer data included;
- no source code changed;
- final working tree must be clean.

Flutter analyze/test/build:

- Not run - documentation/report-only task; no app source/test/build files changed.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: YES

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

JSON transfer preserved for local apps:
- yes

OPC Web not implemented and not mischaracterized as SaaS:
- yes

Terminology preserved:
- yes; open terminology items are explicitly queued

Future Web not blocked:
- yes

Source changes within scope:
- yes

If not compliant, classify:
- NOT PASS

## PASS / NOT PASS:

PASS WITH OWNER REVIEW QUEUE
