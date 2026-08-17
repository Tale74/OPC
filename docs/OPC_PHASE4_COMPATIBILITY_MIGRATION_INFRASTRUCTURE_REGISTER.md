# OPC Phase 4 Compatibility / Migration Infrastructure Register

These paths may look historical or superseded but remain protected until a separate compatibility audit proves otherwise.

| Protected path / data | Why it remains protected | Evidence | Target treatment |
|---|---|---|---|
| Drift schema versions 1–27 in `database.dart` | Existing databases can arrive at any supported checkpoint; additive recovery handles partially committed DDL | `canonical_database_migration_recovery_test.dart`, `package_downgrade_migration_test.dart`, migration policy | Split schema/migration/recovery responsibilities; preserve all checkpoints |
| `schema_recovery.dart` and `beforeOpen` recovery | Detects malformed/missing tables, columns and indexes and fails closed | Schema recovery implementation and canonical recovery tests | Retain as recovery infrastructure behind persistence port |
| Seed and repair routines | Canonical KATALOG identities, stable IDs, scenario definitions and references are repaired without broad user-data rewrite | `repairKnownCatalogIntegrity`, stable-ID tests, scenario startup characterization | Separate seed/repair lanes; preserve transaction boundaries |
| `database_lane_diagnostics.dart`, migration selector and fixtures | Selects/diagnoses canonical or migration-test DBs and protects owner-copy workflow | migration selector/copy tests and policy docs | Retain diagnostics and test-only lanes |
| `OPC_BELEZNICA` single-PREDMET format | Supported legacy import may be the only representation of older user exports | `legacyBeleznicaTransferFormat`, transfer parser and JSON tests | Versioned codec adapter; no removal without import policy |
| SCENARIO schema-1 carrier/adapters and legacy provenance | Applied snapshots and historical/manual rows require explicit ownership | carrier/envelope/persistence tests and locked contract | Retain behind locked SCENARIO port; unlock required for physical move |
| PREDMET export version and conflict fields | Cross-device transfer and replacement flows use version/conflict semantics | JSON transfer core and regression tests | Preserve versioned transfer contract |
| Full-backup sections for PARTE media, reminders, stock, auth/FIRMA and logs | Restore coordinates data and external derivative state; installation-local security state is intentionally preserved | JSON monolith, full-backup coordinator and lifecycle tests | Split workflow from adapters without dropping sections |
| Legacy stable article IDs / SANDUK aliases | Historical stock and IRiU rows point to stable IDs | stock operational tests and identity mapper | Preserve mapping; canonicalize only through proven migration |
| Legacy PREDMET fields and ceremony values | Old databases may carry fields that current UI no longer offers | table comments, UI fallback and ceremony tests | Keep read compatibility; do not infer deadness |
| Local license/entitlement envelope and installation identity | Older payloads may be imported/diagnosed even when current policy is unrestricted | active parser/bootstrap/repository tests and settings UI | Preserve compatibility; owner decides future distribution model |
| Android storage and Windows notification branches | Platform-specific behavior is real, not unused duplication | Android storage contract, Windows runtime and reminder evidence | Keep adapter-specific lanes and parity tests |

## Safety rule

Every future deletion proposal must cite this register and prove that the relevant migration, restore, legacy, platform and owner-recovery obligations have moved to an equivalent path.

