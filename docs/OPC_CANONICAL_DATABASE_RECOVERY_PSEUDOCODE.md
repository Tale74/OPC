# OPC Canonical Database Recovery Pseudocode

## OPC-PSEUDO-051

```text
RESOLVE compile-time BUILD_VARIANT
RESOLVE database filename and platform documents directory
OPEN only the database selected by that established runtime lane

IF database is an explicitly designated canonical user database:
    business rows remain authoritative regardless of schema checkpoint

IF user_version == 0 AND user tables already exist:
    STOP with unsupported-checkpoint diagnostic

IF user_version > application schema version:
    STOP; never downgrade automatically

DRIFT onUpgrade owns version sequencing

FOR each additive object belonging to a supported historical migration:
    IF prerequisite foundational table is missing:
        STOP with precise diagnostic
    IF object is missing:
        create only that expected object
    ELSE:
        validate type, nullability, default, PK/index properties
        IF definition conflicts:
            STOP; do not drop, recreate, or ignore

DRIFT beforeOpen:
    rerun the same bounded additive recovery set
    validate generated tables
    validate manual auth/reminder/lifecycle tables
    validate required indexes and partial predicates
    perform established deterministic backfills
    validate complete required target schema

ONLY AFTER onUpgrade and beforeOpen succeed:
    Drift advances user_version to 21

ON interrupted open:
    keep committed valid DDL
    keep stale checkpoint
    next open detects and validates existing objects
    create only remaining missing objects
    finish without duplicate DDL or business-row loss

BEFORE any real-user rollout:
    close OPC
    resolve WAL/SHM
    create consistent verified backup
    test application migration on an isolated copy
    compare integrity, schema and row counts

NEVER:
    replace canonical database with a test database
    copy a migrated test database over canonical data
    manually force user_version
    catch and ignore duplicate-column errors
    expose private row values in reports
```

Source implementation:

- `lib/core/database/database.dart`
- `lib/core/database/schema_recovery.dart`
- `test/canonical_database_migration_recovery_test.dart`
- `test/owner_database_copy_migration_test.dart`
