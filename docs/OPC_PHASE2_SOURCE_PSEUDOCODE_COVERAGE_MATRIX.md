# OPC Phase 2 Source / Pseudocode Coverage and Reconciliation Matrix

**Status:** Phase 2 internal synchronization evidence; not a production specification and not implementation authorization.

**Baseline:** repository `621c70f8d4820042e40a15f3d44187703092db3e`; branch `task/OPC-SCENARIO-MODULE-LOCK`; locked SCENARIO SHA `a8218537c1aa85b61fe5c85c21dbd03672f6e77c`.

**Authority order:** later explicit owner authority → current source/tests for implemented behavior → scoped runtime evidence → authoritative dependency-based roadmap → older reports and historical pseudocode.

## Coverage matrix

| Logical area | Internal pseudocode view | Current SOURCE responsibility | Tests/contracts/runtime evidence | Synchronization result | Current classification |
|---|---|---|---|---|---|
| PREDMET core, lifecycle and identity | Business-critical map; safe-upgrade notes; master index | `lib/features/predmeti/data/predmeti_repository.dart`, PREDMET domain/application, lifecycle tables | `predmet_completion_state_characterization_test.dart`, lifecycle/referential tests, owner decision report | PREDMET remains sole master truth; explicit `OTVOREN → ZATVOREN → ZAVRŠEN` and protected final state represented | COMPLETE technical baseline; change-log/identity gates remain open |
| SCENARIO module and non-retroactivity | IRIU business view; business-critical map; module architecture view; master index | `lib/features/predmeti/core_v2/scenario/**`, scenario tables and presentation | Locked 33-file contract; scenario runtime/application/persistence/reconciliation tests; Windows and Android owner PASS | MODULI → SCENARIO placement, applied PREDMET snapshot/provenance, package ordering and non-retroactivity aligned with locked source | COMPLETE / LOCKED; no production change authorized |
| IRiU ordering, snapshots and KATALOG | `OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`; business-critical map | `iriu_repository.dart`, `iriu_ordering_service.dart`, display-name and truth services, catalog tables | `iriu_shared_derived_ordering_test.dart`, KATALOG/price/catalog-picker tests, scenario ordering tests | Generic order is `OSNOVNI → applied SCENARIO → manual/unpredicted`; selected snapshots remain PREDMET-scoped | COMPLETE technical; runtime/release evidence remains scoped |
| Business policy, finance and statistics | Business-critical map; owner-decision view; safe-upgrade notes | `business_policy/**`, financial truth service, statistics aggregators | business-policy/IRiU critical tests and current runtime reports | Evaluator is represented as partial deterministic policy kernel; finance/statistics remain derivatives | PARTIALLY COMPLETE; owner/business guidance gaps remain |
| PARTE preparation and document derivatives | PARTE preparation view; PDF/memorandum view; business-critical map | `features/predmeti/parte/**`, `features/predmeti/pdf/**` | PARTE domain/schema/print tests, PDF/DOCX reports and platform evidence | PARTE, PDF and DOCX remain PREDMET-derived; physical print is separate owner evidence | TECHNICAL BASELINE; NALOG/typography/release gates remain |
| PODSETNIK/reminders and signals | Podsetnik control-flow view; business-critical map; prebuild historical view | `features/podsetnik/**`, `features/predmeti/reminders/**` | reminder system tests, Android runtime acceptance and owner decision queue | Existing scheduling/notification behavior represented without claiming a complete signal taxonomy | OPEN / OWNER DECISION REQUIRED for complete semantics |
| STANJE ROBE and effects | Business-critical map; IRIU view; prebuild historical view | `features/stanje_robe/**`, stock tables/effects services | stock operational tests, delete/restore and JSON boundary tests | Stock is an operational consequence over PREDMET/IRiU, never a parallel business truth | PARTIAL technical/release evidence |
| Persistence, migrations and recovery | Canonical database recovery view; business-critical map; Windows identity forensic view | `lib/core/database/**`, migration/recovery and backup coordinators | migration/recovery, owner-copy migration and full-backup restore tests | Migration compatibility and selected-database lane are protected; canonical recovery is not disposable legacy | COMPLETE recovery slices; final release rehearsal and RI gates open |
| Single-PREDMET JSON transfer | Business-critical map; IRIU view; safe-upgrade notes | `lib/core/json_transfer/**`, `predmet_json_transfer_core.dart`, export/import utilities | JSON regression, carrier contract, scenario transfer-envelope tests | Single-PREDMET contract remains distinct from full backup; SCENARIO carrier is represented as partially complete pending final release round-trip | PARTIALLY COMPLETE / RELEASE ACCEPTANCE OPEN |
| Full backup / restore | Business-critical map; canonical recovery view; safe-upgrade notes | `full_backup_restore_coordinator.dart`, `json_export_import.dart`, database recovery | `full_backup_restore_lifecycle_coordination_test.dart`, canonical recovery evidence | Full backup owns broad local state and preserves compatibility/rollback boundaries | TECHNICAL PASS slices; final release-candidate rehearsal open |
| Authentication, settings and access context | Business-critical map; owner-decision view | `features/auth/**`, `features/podesavanja/**`, entitlements | auth/settings smoke and policy tests | Auth/settings supply technical context and must not redefine PREDMET meaning | COMPLETE baseline; identity/distribution decisions remain owner-open |
| Windows/Android platform boundaries and theme | Windows identity forensic view; prebuild historical view; master index | `lib/app.dart`, platform runners/adapters, notification/filesystem integration | owner runtime evidence; current platform reports; shared `ThemeMode.system` source | Windows light/dark theme is explicitly closed by owner runtime authority; no pseudocode/open roadmap task remains | THEME COMPLETE; broader UI/UX and Windows release gates remain separate |
| Governance, roadmap and drift control | Master index; safe-upgrade notes; historical audit views | `docs/OPC_*` authority homes, operative dependency plan and manifests | Phase 1 manifest, lock report, current source/test evidence | Historical chronology is subordinate; current plan/state carry the effective status | SYNCHRONIZED; no owner-authority conflict found |

## Invariant verification

| Invariant | Verification result |
|---|---|
| PREDMET is the only master business truth | Present in product/domain home, architecture, source boundary and active pseudocode overlay |
| `ordered OSNOVNI PAKET → ordered applied SCENARIO PAKET → manual/unpredicted items` | Present in IRIU pseudocode, current state, roadmap and source coverage |
| SCENARIO changes are non-retroactive to applied PREDMET snapshots | Present in lock contract, scenario persistence/reconciliation source and tests |
| SCENARIO production lock | SHA and lock contract preserved; no source/test/definition change made |
| KATALOG snapshot behavior | PREDMET/IRiU snapshot responsibility retained; current KATALOG is not retroactive authority |
| Runtime evidence boundary | Owner runtime PASS is recorded as observed behavior, not internal root-cause proof |
| Persistence/migration compatibility | Recovery and migration views retain compatibility and rollback obligations |
| Single-PREDMET versus full-backup JSON | Distinct paths and contracts preserved in pseudocode and source coverage |

## Scope result

No production source, tests, configuration, dependencies, database, CI, platform configuration or SCENARIO implementation was modified. This matrix is evidence for Logos review and does not authorize any future implementation.
