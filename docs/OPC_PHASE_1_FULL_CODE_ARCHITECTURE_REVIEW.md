# OPC — Phase 1 full code/architecture review

Status: `CODE-FIRST REVIEW COMPLETE — RUNTIME/PROFILING EVIDENCE REMAINS — IMPLEMENTATION NOT AUTHORIZED`

Audit date: 28 July 2026  
Base branch: `task/OPC-GATE-0-DATABASE-REFERENTIAL-INTEGRITY-AUDIT`  
Base SHA: `f546aac3dd848ccfa780f1c7edbbca85afd20c27`  
Task branch: `task/OPC-PHASE-1-FULL-CODE-ARCHITECTURE-REVIEW`

## 1. Scope and control boundary

This review executes section 8.1 of
`docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`.

It inspected the complete current source structure under:

- `lib/`;
- `windows/`;
- `android/`;
- `test/`;
- current Git documentation and prior Phase 1 evidence.

No application code, test, schema, migration, build configuration, database or
runtime behavior was changed.

The review incorporates, without repeating, the completed identity, version,
`logIzmena`, PODSETNIK orphan and database referential-integrity audits.

## 2. Source inventory

The current tree contains:

- 133 handwritten Dart files under `lib/`, excluding generated
  `database.g.dart`;
- approximately 66,814 handwritten Dart lines;
- 34 Dart test files with approximately 8,241 lines;
- one generated Drift file of approximately 22,586 lines;
- 21 presentation files importing Drift-generated database model types;
- 60 feature files importing the shared database model.

Large handwritten units include:

| File | Approximate lines | Responsibilities observed |
| --- | ---: | --- |
| `lib/features/podesavanja/presentation/podesavanja_screen.dart` | 2,193 | settings navigation, firm data, application settings, diagnostics and module entry points |
| `lib/core/utils/json_export_import.dart` | 2,099 | serialization, validation, file/UI shell, conflict UI, import, replacement and full restore |
| `lib/features/predmeti/parte/presentation/parte_composer_screen.dart` | 2,024 | editor state, persistence actions, media, viewport, gestures and preview |
| `lib/core/database/database.dart` | 2,010 | schema, migrations, additive recovery, seeds, validation and shared DB helpers |
| `lib/features/predmeti/presentation/lista_predmeta_screen.dart` | 1,897 | list, navigation, reminders, stock signals and lifecycle actions |
| `lib/features/predmeti/presentation/predmet_screen.dart` | 1,840 | PREDMET orchestration, segments, documents, PARTE and lifecycle actions |
| `lib/features/predmeti/presentation/segments/iriu_segment.dart` | 1,356 | IRiU UI, catalog, lifecycle and stock-consequence coordination |
| `lib/features/predmeti/presentation/segments/iriu_row_tile.dart` | 1,354 | IRiU row interaction, catalog and platform-specific UI |

File length alone is not a defect. The finding is the combination of size,
multiple responsibility families and direct orchestration across module
boundaries.

## 3. Architecture map

The implemented direction is broadly:

```text
Flutter presentation
  -> repositories and selected application services
  -> Drift AppDatabase / generated row models
  -> local SQLite

PREDMET
  -> IRiU, finance, reminders, PARTE and documents
  -> JSON transfer and full backup/restore

KATALOG
  -> selectable knowledge and stock identity
  -> PREDMET/IRiU snapshots remain historical business data
```

Positive seams already exist:

- feature repositories for PREDMET, IRiU, settings, auth, PARTE and stock;
- `core_v2` evaluator/truth services;
- separate PARTE domain, data, application, PDF and DOCX folders;
- data builders for selected PDFs;
- platform adapters for Android file export and notifications;
- migration fixtures and focused regression tests;
- explicit `PREDMET` version, scenario and actor metadata.

The architecture is therefore evolvable. It is not a source structure that
requires a full rewrite merely to introduce clearer boundaries.

## 4. Findings

### F-01 — PREDMET lifecycle ownership is not yet one atomic application boundary

Severity: `P0 DATA/PRIVACY INTEGRITY`

Evidence:

- `lib/features/predmeti/data/predmeti_repository.dart:199`;
- `lib/features/predmeti/data/predmeti_repository.dart:374`;
- `lib/features/predmeti/data/predmeti_repository.dart:559`;
- `lib/features/predmeti/presentation/predmet_screen.dart:870`;
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart:487`;
- `docs/OPC_DATABASE_REFERENTIAL_INTEGRITY_AND_PREDMET_DEPENDENCY_AUDIT.md`.

PREDMET DB transactions, PARTE media, reminder OS state, stock compensation,
logs and restore/replacement do not yet share one explicit lifecycle
orchestrator. The fixture-confirmed orphan/privacy defects are a consequence of
this missing boundary.

Disposition:

`PROGRESSIVE LIFECYCLE/REFERENTIAL REFACTOR REQUIRED BEFORE ISOLATED FIXES`.

### F-02 — Drift declarations do not currently provide runtime referential safety

Severity: `P0 DATA INTEGRITY`

Evidence:

- FK declarations in `lib/core/database/tables/iriu_table.dart`,
  `log_izmena_table.dart`, `kontakt_lica_table.dart`,
  `parte_pripreme_table.dart` and `stanje_robe_posledice_table.dart`;
- connection creation at `lib/core/database/database.dart:2076`;
- fixture-confirmed `PRAGMA foreign_keys=0` in the referential audit.

Enabling FK enforcement without the staged recovery/lifecycle work would be
unsafe. The RI-1 through RI-5 sequence remains controlling.

### F-03 — Current SCENARIO is an identifier seam, not a configurable scenario engine

Severity: `P0 ARCHITECTURE/BUSINESS-LOGIC DEPENDENCY`

Evidence:

- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart:8`
  exposes one scenario;
- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart:24`
  falls back to that scenario for an unknown value;
- `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart:18`;
- rules remain distributed through
  `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`,
  lifecycle services, repository materialization and ceremony UI;
- JSON defaults at `lib/core/utils/json_export_import.dart:659` and
  `lib/core/json_transfer/predmet_json_transfer_core.dart:92`.

The existing `businessScenarioId` is useful migration infrastructure, but it
does not yet persist a complete PREDMET-owned scenario snapshot/template
version. Unknown imported/current IDs are not proven to be rejected at the
transfer boundary; the evaluator silently resolves them to the default. This
requires characterization, not an owner guess.

Disposition:

`DEDICATED SCENARIO/IRIU AUDIT BEFORE PERSISTENCE OR UI DESIGN`.

### F-04 — Business truth has a partial `core_v2` convergence seam

Severity: `P1 ARCHITECTURE`

Evidence:

- `PredmetIriuTruthService` consumes `BusinessPolicyEvaluator`;
- multiple assertions explicitly describe a “no-output-change migration
  phase” in
  `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`;
- presentation and repositories still call legacy/static `IriuTruthRules`
  directly.

This is evidence of an unfinished but technically sound strangler/refactor
direction. It supports progressive convergence rather than replacing the whole
application.

### F-05 — Presentation is coupled to persistence models and constructs sibling repositories

Severity: `P1 MAINTAINABILITY/TESTABILITY`

Evidence:

- 21 presentation files import the shared generated database model;
- `PredmetiRepository.db` is publicly exposed at
  `lib/features/predmeti/data/predmeti_repository.dart:36`;
- sibling repositories are constructed from it at
  `lib/features/predmeti/presentation/predmet_screen.dart:174` and
  `lista_predmeta_screen.dart:690`;
- `izvestaji_screen.dart:67` directly selects a DB table.

Importing immutable row types is not itself a truth violation. The risk is
presentation-driven dependency construction and the direct query exception,
which make module contracts harder to enforce and test.

Disposition:

`INTRODUCE APPLICATION/FACADE CONTRACTS PROGRESSIVELY; DO NOT REPLACE ALL ROW MODELS AT ONCE`.

### F-06 — JSON/full-backup orchestration is a high-coupling subsystem

Severity: `P1 MIGRATION/DATA INTEGRITY`

Evidence:

- `lib/core/utils/json_export_import.dart` is approximately 2,099 lines;
- it contains 44 async/future sites and 22 `AppDatabase` references;
- it combines file selection, public UI dialogs, schema normalization,
  serialization, import, replacement and full restore;
- `lib/core/json_transfer/predmet_json_transfer_core.dart` already provides a
  smaller transfer-core seam.

Disposition:

`PARTIAL SUBSYSTEM REFACTOR CANDIDATE`, not a rewrite authorization. Preserve
all current schemas and previously distributed database compatibility.

### F-07 — Windows has no source-visible single-instance guard

Severity: `P0/P1 DATA-INTEGRITY RISK — RUNTIME NOT YET REPRODUCED IN THIS TASK`

Evidence:

- `windows/runner/main.cpp:8` creates a new Flutter window for every process;
- no mutex, named pipe, window discovery or equivalent guard exists in
  `windows/`, `lib/` or declared dependencies;
- all production variants use the same database name in
  `lib/core/config/app_config.dart:55`;
- SQLite/FK lifecycle defects are already fixture-confirmed.

This confirms absence of a guard, not the exact concurrent-write outcome.
Runtime reproduction and a same-PREDMET/import/migration collision matrix
remain required.

### F-08 — Startup contains credible source candidates but no measured bottleneck

Severity: `P1 PERFORMANCE — MEASUREMENT REQUIRED`

Evidence:

- desktop waits for `windowManager.ensureInitialized()` and locale data before
  `runApp` at `lib/main.dart:13` and `lib/main.dart:20`;
- the first auth query opens the lazy DB;
- every DB open executes additive recovery, catalog seeding/backfill, index
  checks and schema validation in
  `lib/core/database/database.dart:173`;
- entitlement resolution is also a startup `Future` at `lib/app.dart:39`.

No one source candidate may be declared the cause without cold/warm timing.

### F-09 — Android PARTE has source-visible repaint/IO candidates, not a proven root cause

Severity: `P1 PERFORMANCE — PROFILING REQUIRED`

Evidence:

- `parte_composer_screen.dart` is approximately 2,024 lines with 22
  `setState` sites;
- viewport interaction calls `setState` on every interaction update at
  `parte_composer_screen.dart:1808`;
- each media block creates a `FutureBuilder` from
  `mediaStore.read(...)` at `parte_composer_screen.dart:2060`;
- block drag updates local state for every pan event at
  `parte_composer_screen.dart:1998`;
- controller disposal is correctly implemented at lines 106–120 and
  1715–1718.

The source supports the owner hypothesis that complexity/rebuild breadth may
contribute. It does not prove that hypothesis or prove current stutter on the
latest HEAD.

### F-10 — System theme support already exists in shared app code

Severity: `P2 RUNTIME CONFIRMATION GAP`

Evidence:

- `theme`, `darkTheme` and `ThemeMode.system` are configured at
  `lib/app.dart:94`;
- Windows runner includes system dark-window handling.

The Windows theme backlog item must begin with runtime verification. A new
Windows-only selector is not justified by current source evidence.

### F-11 — Localization, country profiles and dual-currency readiness are not implemented

Severity: `P1 FUTURE ARCHITECTURE READINESS`

Evidence:

- the app initializes only `sr_Latn_RS` date formatting at `lib/main.dart:20`;
- `MaterialApp` has no generated localization delegates or supported-locale
  registry;
- UI and document strings are embedded in source;
- money formatting appends `RSD` at
  `lib/core/format/app_money_format.dart:35`;
- firm, catalog and QR settings contain fixed RSD labels/encoding;
- current build variants separate test lanes, not country/language profiles.

This supports one shared core with explicit language/country/document/currency
profiles later. It does not support creating a second divergent domain fork
now.

### F-12 — Release signing is not transfer-ready

Severity: `P1 RELEASE READINESS`

Evidence:

- Android release currently uses the debug signing configuration at
  `android/app/build.gradle.kts:34`;
- application identity is `com.tale.opc_v4`;
- no completed Windows publisher/certificate custody configuration was found
  in the inspected tree.

No certificate purchase or signing change is authorized by this audit.

### F-13 — Static validation passes; complete test gate did not produce a verifiable result

Severity: `P1 TEST INFRASTRUCTURE`

Evidence:

- `flutter analyze --no-pub`: PASS, no issues, 281.9 seconds;
- `flutter test --no-pub`: the command exceeded the 15-minute output-wrapper
  limit without emitting a final result;
- after the parent command ended, one `flutter_tester` child remained active
  and nearly idle;
- the child was initially left running because the owner required that it be
  allowed to finish, then explicitly terminated by owner instruction after it
  remained orphaned.

This is `NOT COMPLETED / NOT PASS / NOT FAIL`. Test-runner isolation is required
before any future implementation validation can be considered reliable.

## 5. Architecture option comparison

| Option | Current evidence | Decision |
| --- | --- | --- |
| Targeted fixes only | Appropriate for bounded UI/output defects, but insufficient for lifecycle, JSON and scenario boundaries | Use only after the relevant boundary is stabilized |
| Progressive refactor | Existing repositories, services, `core_v2`, PARTE layers and tests provide viable seams | **Recommended primary strategy** |
| Partial subsystem rewrite | Potentially justified for scenario/configuration persistence and JSON orchestration; PARTE presentation only if profiling proves it | Keep as Decision Gate option |
| Full rewrite | No evidence that the current domain/data core is unrecoverable; migration and parity risks would be highest | **Not recommended** |

## 6. Recommendation

```text
RETAIN CURRENT CODEBASE
+ PROGRESSIVE PREDMET/LIFECYCLE/REFERENTIAL REFACTOR
+ CONTROLLED CORE_V2 CONVERGENCE
+ POSSIBLE PARTIAL SCENARIO/JSON SUBSYSTEM REWRITE AFTER EVIDENCE
```

The existing codebase contains valuable implemented business behavior,
migrations, JSON compatibility, document output and test knowledge. A full
rewrite would recreate those risks without evidence of a compensating benefit.

## 7. Architecture Decision Gate status

The gate is **not yet ready**.

Source review is complete, but the following evidence remains:

1. Windows multiple-instance and concurrent SQLite runtime audit;
2. Windows cold/warm startup measurements;
3. Android PARTE latest-HEAD reproduction and profiling;
4. complete SCENARIO/IRiU condition, stale-row, urn and storage audit;
5. UI/UX and fixed Windows/Android parity scenarios;
6. schema/JSON/product-profile readiness synthesis;
7. reliable complete Flutter test result.

## 8. Correct remaining Phase 1 sequence

```text
Full source review — COMPLETE
  -> Windows multiple-instance/concurrent DB evidence
  -> Windows startup baseline
  -> Android PARTE reproduction/profiling
  -> SCENARIO/IRiU full audit
  -> UI/UX, migration, parity and product-profile readiness synthesis
  -> Architecture/refactor/rewrite Decision Gate
```

Windows multiple-instance evidence remains ahead of ordinary startup tuning
because it can affect canonical data. None of these audits authorizes source
changes.

## 9. Stop conditions

Stop before implementation when:

- a lifecycle child has no proven PREDMET owner;
- a change could alter historical/completed PREDMET truth;
- migration/recovery cannot preserve canonical user databases;
- scenario reconciliation could remove valid manual IRiU data;
- a platform solution changes business result;
- a test gate does not return a complete final exit result;
- a technical choice changes business policy and lacks owner approval.

## 10. Final status

`PHASE 1 FULL CODE/ARCHITECTURE SOURCE REVIEW PASS — CURRENT CODEBASE RETENTION AND PROGRESSIVE REFACTOR RECOMMENDED — ARCHITECTURE DECISION GATE AWAITS RUNTIME/PROFILING EVIDENCE — IMPLEMENTATION NOT AUTHORIZED`
