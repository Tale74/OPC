# OPC Phase 4 Forensic Architecture Migration Report

**Status:** FORENSIC ANALYSIS ONLY — NO IMPLEMENTATION
**Baseline HEAD:** `336552ff40eaa72321670cb554ebd1d6d784d30c`
**Branch:** `task/OPC-SCENARIO-MODULE-LOCK`
**SCENARIO locked production SHA:** `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`
**Final status:** `PHASE 4 PASS — CURRENT→TARGET MIGRATION PATH AND FORENSIC IMPLEMENTATION CLASSIFICATION DEFINED — READY FOR LOGOS REVIEW`

## 1. Outcome and forensic rule

Phase 4 maps the current implementation to the accepted Phase 3 target and identifies safe future intervention classes. It is not cleanup: implementation age, folder placement, low call counts, or the existence of a newer path do not prove removability. The audit classified compatibility, migration, restore, platform, packaging and forensic obligations before assigning any dead-code status.

The protected boundary remains PREDMET as sole business authority, owner-approved meaning, SCENARIO lock/contracts, IRiU order `OSNOVNI → applied SCENARIO → manual/unpredicted`, applied SCENARIO snapshot/non-retroactivity, KATALOG snapshot semantics, schema/migration/recovery behavior, single-PREDMET and full-backup JSON contracts, historical formats, Windows/Android parity, runtime behavior and regression guarantees.

## 2. Evidence and method

The audit read the Phase 3 target documents, current authority homes, SCENARIO lock/report, synchronized pseudocode, all relevant production/test/platform/configuration/script areas, and Git history for concentrated or compatibility-sensitive files. Static import analysis covered 234 source/test/platform/configuration artifacts. The current test inventory contains 68 Dart tests, including 23 SCENARIO, 13 IRiU, 6 migration/recovery, 3 JSON, 4 database, 8 PARTE/PDF, 2 reminder, 7 platform/runtime and 3 auth/identity-oriented tests (categories overlap by filename).

Static import aggregation proves direct dependency cycles at the current file level:

- `features/predmeti` ↔ `features/podesavanja` through `scenario_module_screen.dart`, `iriu_repository.dart`, PREDMET screens and `podesavanja_screen.dart`;
- `features/predmeti` ↔ `features/podsetnik` through list/module screens and `podsetnik_module_screen.dart`;
- `core/utils` ↔ `core/database` through `json_export_import.dart`, `export_utils.dart` and `database.dart`;
- `core/utils` ↔ `features/predmeti` through the JSON monolith and document/UI callers.

These are proven import relationships, not inferred runtime cycles. No broader cycle is claimed without source proof.

## 3. Current responsibility findings

### App and PREDMET

`lib/main.dart` and `lib/app.dart` compose the database, auth, settings, PREDMET screens and reminder service. PREDMET repository code owns lifecycle transactions, hard-delete coordination, save/close/finalize semantics, related-row mutation, scenario initialization and direct Drift access. PREDMET presentation imports database tables, settings, stock, reminders, PDF, PARTE, JSON and auth directly. The aggregate is authoritative but its application/presentation boundary is not narrow.

### SCENARIO, IRiU and KATALOG

SCENARIO contracts, repositories, reconciliation, persistence and UI are implemented under `features/predmeti/core_v2/scenario`; legacy/default adapters are actively exercised by scenario repository, persistence, transfer and runtime tests. IRiU ordering/truth services and repositories preserve the protected package order, but UI and repositories reach into KATALOG/settings and stock. KATALOG identity/seed/configuration is split between `core/catalog`, database tables and `podesavanja` repositories. These are active paths, not removal candidates.

### Policy/finance, stock, PARTE and documents

Business policy models/evaluator, financial truth and statistics are PREDMET-adjacent and database-aware. PARTE has a comparatively coherent domain/application/data/rendering split. PDF/DOCX exporters are PREDMET-derived but presentation screens call them directly and shared rendering helpers live in `core/utils`.

### PODSETNIK and reminders

`ReminderMvpService` is actively used by `app.dart` and `lista_predmeta_screen.dart`; it is not superseded merely because the ceremony notification stack also exists. PODSETNIK screens and reminder repositories read PREDMET facts and persist derived schedule/notification IDs. Business signal semantics remain owner-gated; ambiguous code is not dead.

### Persistence and interoperability

`database.dart` is a 27-version Drift schema/migration/seed/repair/recovery/auth-access concentration point. `schema_recovery.dart` validates additive schema, columns, indexes and rejects malformed objects. `json_export_import.dart` is a 90 KB integration monolith combining single-PREDMET transfer, full backup serialization, validation, restore mutation, filesystem/file-picker/share UI, auth/security preservation, PARTE media, reminders, stock consequences and SCENARIO carriers. `FullBackupRestoreCoordinator` adds restore compensation for media and reminders but is physically nested under PREDMET application.

## 4. Classification outcome

The decision-grade matrix is in `OPC_PHASE4_INTERVENTION_DECISION_MATRIX.md`.

| Classification (decision-matrix rows) | Count | Interpretation |
|---|---:|---|
| ACTIVE — TARGET FIT | 4 | SCENARIO contracts/runtime (locked), PARTE core, identity/security core, platform adapters |
| ACTIVE — MOVE/RENAME | 5 | KATALOG, policy/finance, transfer contracts, backup coordinator, test taxonomy/support |
| ACTIVE — SPLIT/MERGE REQUIRED | 6 | app composition, PREDMET orchestration, IRiU boundary, reminders, documents, JSON/backup workflow |
| ACTIVE — REFACTOR CANDIDATE | 2 | stock effects and shared rendering helpers |
| ACTIVE — RECODE CANDIDATE | 0 as a row; 1 bounded candidate | Policy/finance projection may be recoded only after contract extraction |
| ACTIVE — PARTIAL REWRITE CANDIDATE | 2 | JSON monolith seams; database concentration seams |
| ACTIVE — FULL RECONSTRUCTION CANDIDATE | 0 | evidence does not justify a whole-system replacement |
| COMPATIBILITY / MIGRATION INFRASTRUCTURE | 3 as rows; 11 protected entries | schema history, recovery, legacy JSON, scenario adapters, stable IDs, auth/recovery and platform lanes |
| HISTORICAL / FORENSIC ONLY | 0 | no source path was proven production-independent solely by age |
| PROVEN DEAD | 1 | `lib/core/utils/export_utils_replacement.dart`, a tracked placeholder with no references or runtime role |

The counts are classification rows, not files-to-change. No intervention is authorized by this report.

## 5. Dead-code result

One source artifact meets the forensic standard: `lib/core/utils/export_utils_replacement.dart` contains only the statement that the active implementation is `export_utils.dart`; repository-wide search found no Dart, test, script, packaging, migration, JSON, restore, platform or documentation reference; Git history shows only its public-baseline introduction; all consumers import `export_utils.dart`. It is classified `PROVEN DEAD`, but it was not deleted.

No other candidate reached that threshold. `ReminderMvpService` is called by app and list screens; `statistika_v1` is called by the reports screen; legacy SCENARIO adapters are exercised by tests and persisted-data repair; license/entitlement payloads are active in settings and stock gates; old database and JSON paths carry explicit compatibility obligations. Unused-element annotations and old names are insufficient evidence.

## 6. High-risk migration conclusions

1. Extract interoperability application workflows and stable ports before changing codecs or database adapters. The JSON monolith should be decomposed, with partial reconstruction preferred only for seams whose contract and compatibility fixtures are sufficient.
2. Decompose database schema, migrations, seed, repair, recovery and repositories behind persistence ports. Keep schema history, generated Drift output, owner-copy selectors and recovery diagnostics intact.
3. Separate PREDMET lifecycle/application orchestration from presentation and derivative workflows. Do not move SCENARIO physically without an explicit unlock task.
4. Establish KATALOG and IRiU ports before extracting selection/order logic; preserve snapshot provenance and package ordering.
5. Isolate reminder scheduling/delivery state from PREDMET facts. Resolve signal semantics with the owner before recoding ambiguous reminder behavior.

The ordered prerequisite graph is in `OPC_PHASE4_MIGRATION_PREREQUISITE_SEQUENCE.md`; no big-bang migration is recommended.

## 7. Owner gates and unresolved evidence

- SCENARIO physical restructuring remains `REQUIRES EXPLICIT SCENARIO UNLOCK TASK`.
- PODSETNIK signal taxonomy/business meaning remains owner-gated; source facts remain PREDMET-owned.
- Full backup/restore release rehearsal, dual-currency, NALOG/RAČUN, app identity/distribution and remaining roadmap gates remain product/owner decisions, not silently reprioritized by this audit.
- Rewrite candidates have partial or insufficient characterization and therefore cannot proceed to implementation without the gap register’s evidence work.

No Phase 4 stop condition was triggered: protected contracts remain preservable, critical compatibility paths are identifiable, and no business authority was reassigned.

## 8. No-implementation proof

Phase 4 changed documentation only. No Dart file, import, test, schema/migration, dependency, configuration, CI, platform code, runtime/private data, database, SCENARIO implementation or pseudocode body was changed. No commit or push was performed. The review ZIP is local, ignored and non-authoritative.
