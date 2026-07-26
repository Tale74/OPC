# OPC Canonical Database and Migration Policy

## Authority

Owner decision, 2026-07-16. This document is active guidance for native OPC
database upgrades and supersedes any active instruction that treats a newer
test database as more authoritative than an explicitly designated user
business database.

## Canonical business database

For the current owner Windows installation, the single canonical business
database is:

`<OWNER_USER_HOME>\Documents\opc_v4_release.sqlite`

Its business data remains authoritative when its physical schema and
`PRAGMA user_version` disagree. Schema version is a compatibility checkpoint,
not evidence that a different database contains newer or more authoritative
business data.

`opc_v4_windows_test.sqlite`, migration-test copies, temporary databases and
synthetic fixtures are isolated validation lanes. They must not be merged into,
substituted for, or copied over the canonical database.

## User-database rule

Every existing OPC user keeps that user's own database as business truth. A
new OPC build upgrades the existing database in place. Users must never be
instructed to delete it, install an empty or prepared replacement, copy another
user's database, or manually merge release and test files.

Before the first launch of a migration-capable build:

1. identify the build variant, database filename and absolute path;
2. close OPC and resolve WAL/SHM state;
3. create a SQLite-consistent, readable backup;
4. record hash, size, modification time, `user_version`, integrity result and
   schema signature without exposing row contents;
5. run the migration through the tested application path;
6. verify target schema, integrity, row counts and representative business
   values;
7. retain the backup until user acceptance.

## Supported checkpoints

The current migration implementation accepts existing `user_version` values
1 through 22 and targets schema 22. Versions 1–13 have insufficient surviving
distribution evidence, but remain supported as the safer compatibility
classification. Versions 14–16 are documented historical stock-schema
transitions. Version 17 is the public repository baseline. Versions 18–21 are
represented by later source commits and runtime/build reports; v19 is the
confirmed owner incident checkpoint.

Version 0 with existing user tables is rejected as unknown. A version newer
than the application is rejected without downgrade.

## Migration and startup ordering

Drift remains the only version-sequencing owner:

1. Drift reads `user_version` and selects `onCreate` or `onUpgrade`.
2. `onUpgrade` uses idempotent OPC schema primitives for supported additive
   columns and tables.
3. `beforeOpen` reruns only the bounded additive recovery set, validates
   required generated/manual tables and validated indexes, and performs the
   already-established deterministic backfills.
4. A malformed or contradictory same-named object throws a precise
   `OpcSchemaMismatch`.
5. Drift advances `user_version` only after `onUpgrade` and `beforeOpen`
   complete successfully.

This ordering makes retry safe when DDL committed but a later startup step
failed before the checkpoint advanced.

## Validation rules

Existing columns are validated by name, SQLite type, `NOT NULL`, default and
primary-key position. Existing indexes are validated by table, uniqueness,
ordered columns and partial-index predicate. Existence by name alone is not
sufficient.

The historical `stanje_robe_operativno_omoguceno` definitions with defaults
`0` and `1` are both explicitly accepted because both were previously produced
by supported OPC code and the singleton's stored value remains authoritative.
This is a documented compatibility exception, not unrestricted schema repair.

Recovery may create only missing objects explicitly owned by a supported
historical migration. It does not drop/recreate tables, alter business rows to
force validation, ignore SQLite exceptions, infer arbitrary repairs or hide
corruption.

## Canonical upgrade authorization

Migration implementation, fixture tests, backup creation, isolated-copy
migration and copy-only runtime validation may precede the live upgrade. The
real canonical owner database must not be opened by the corrected build until
the owner reviews the evidence package and explicitly authorizes that step.

The current owner's canonical upgrade was explicitly authorized and completed
on 2026-07-16 through a PRODUCTION build from migration-code commit
`0368bd83a57efd03df8ef6e398555e35aec8bf85`. The verified offline backup is
`<LOCAL_OPC_PROJECT_ROOT>\OPC v.1\BACKUPS\opc_v4_release_PRE_CANONICAL_UPGRADE_20260716_212208.sqlite`.
The canonical database reached schema checkpoint 21 with integrity `ok`, all 19
table counts/content fingerprints unchanged, and a successful double-start
smoke. This execution record does not waive the same backup-and-explicit-
authorization requirement for another database or user.

## Fail-closed Windows copy smoke selector

The compile-time `MIGRATION_TEST_DATABASE_PATH` hook is accepted only by the
`WINDOWS_TEST` build variant. That variant fails before database open when the
path is absent, relative, missing, not a regular `.sqlite` file, lacks
`MIGRATION_TEST` in the filename, lacks a SQLite 3 header, names the canonical
release file, or resolves to the same filesystem entity as the canonical file.

All other variants ignore this hook and retain their established database lane.
The path is never persisted and is not exposed as a user database picker.

## External-user rollout

For another user: identify that user's actual canonical path and build variant,
close OPC, create and verify a consistent backup, record metadata-only schema
evidence, launch the corrected build, verify schema 21/integrity/core row counts,
and retain the backup. Unsupported or malformed schemas stop with diagnostics
and remain untouched; they are not replaced.
