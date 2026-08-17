# OPC Phase 4 Database Migration / Recovery Forensic Report

## Current implementation

`lib/core/database/database.dart` is the concrete Drift database, with `schemaVersion => 27`. Its `onCreate` path creates all tables, prepares auth security, creates lifecycle/reminder tables, seeds KATALOG and document defaults, repairs canonical identities and backfills policy. Its `onUpgrade` path accepts existing versions 1–27 and applies guarded additive changes from v1 through v27. `beforeOpen` reruns a bounded additive recovery/validation set and rejects newer unsupported user versions.

The file also contains authentication access, seed/repair logic, stable-ID backfills, catalog/category remapping, stock indexes, scenario data repair, migration-test database selection and other concrete queries. `database.g.dart` is generated Drift output and must not be treated as hand-written debt.

## Compatibility inventory

| Lane | Current evidence | Classification | Target treatment |
|---|---|---|---|
| v1–v27 schema checkpoints | Explicit `if (from < N)` gates and schema policy | COMPATIBILITY / MIGRATION INFRASTRUCTURE | Preserve; later split into versioned migrations |
| Additive before-open recovery | `_recoverSupportedAdditiveSchema`, column/table/index checks | COMPATIBILITY / MIGRATION INFRASTRUCTURE | Retain behind recovery port; keep idempotency |
| Schema mismatch fail-closed behavior | `OpcSchemaMismatch`, newer-version and malformed-object rejection | PROTECTED CONTRACT | Preserve exact failure boundary |
| KATALOG seed and canonical repair | Stable IDs, category merge/remap, scenario/snapshot JSON reference updates | COMPATIBILITY / MIGRATION INFRASTRUCTURE | Separate seed, repair and recovery transactions |
| Stock indexes/effects | Applied-effect and consequence indexes/backfills | COMPATIBILITY / MIGRATION INFRASTRUCTURE | Preserve index predicates and lifecycle tests |
| Auth/recovery schema | security settings, audit logs, recovery metadata and PIN compatibility | COMPATIBILITY / MIGRATION INFRASTRUCTURE | Identity/persistence ports; preserve installation-local security state |
| Scenario/IRiU tables | v23 tables, v24 business fields, snapshot/provenance | PROTECTED SCENARIO/PREDMET CONTRACT | No physical/source change without unlock; retain migrations |

## Test protection

`canonical_database_migration_recovery_test.dart` covers confirmed v19–v26 states, repeated opens, stale checkpoints and unsupported transitions. `package_downgrade_migration_test.dart`, owner-copy migration tests and migration selector fixtures protect additional lanes. These tests are strong but do not constitute a complete v1–v27 matrix; characterization is therefore `PARTIAL` for any decomposition/reconstruction.

## Target decomposition recommendation

The best future intervention is a **split with bounded partial reconstruction where seams cannot be extracted safely**:

1. schema definitions/generated output;
2. versioned migrations;
3. seed/default data;
4. canonical repair/backfill;
5. recovery/validation;
6. repository implementations;
7. diagnostics and migration-test selectors.

No migration branch should be deleted merely because a current database is at v27. The full transition matrix, malformed schema cases, transaction interruption, restore/reopen behavior, and generated schema parity must be characterized before implementation.

