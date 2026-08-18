# RR-005 Disposable Current-Tip Migration / Recovery Rehearsal Report

## Scope and authority

This report records the bounded RR-005 rehearsal on disposable copies only. No production source, tests, schema, migration, dependency, platform, CI, SCENARIO or canonical database content was changed. The canonical database remained outside the mutation lane.

Baseline commit: `070ea5e476441cb44ad9cac424c6b90a73da5a72`
Branch: `task/OPC-DISPOSABLE-MIGRATION-RECOVERY-REHEARSAL`
Execution date: 2026-08-18

## Canonical and disposable-copy integrity

| Check | Result |
|---|---|
| Canonical path | `C:\Users\Steva\Documents\opc_v4_release.sqlite` |
| Disposable path | `%LOCALAPPDATA%\Temp\opc_rr005_rehearsal\opc_current_tip_MIGRATION_TEST.sqlite` |
| Canonical pre SHA-256 | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` |
| Disposable pre SHA-256 | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` |
| Disposable post SHA-256 | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` |
| Canonical post SHA-256 | `8A69AE0EA873EA8B994A882F83D0A49171AA58723E8CA1279BCDFD66EB99BCBB` |
| Canonical pre/post invariant | PASS |
| user_version | 27 before and after |
| `PRAGMA integrity_check` | `ok` on canonical and disposable copy |
| Mutation lane | Disposable copy only |

`PRAGMA foreign_key_check` returned the same 36 pre-existing rows on the canonical database and disposable copy before and after the no-op/reopen case (34 `iriu_provenance → iriu`, 2 `predmet_scenario_snapshots → predmeti`). This is evidence of a baseline referential-integrity anomaly, not evidence that RR-005 created or repaired it. Because the closure oracle requires the relevant integrity state to be explicitly reconciled, RR-005 remains acceptance-inconclusive rather than being silently closed.

## Case results

### Case A — current-tip no-op / reopen

The canonical database was copied byte-for-byte to the disposable `MIGRATION_TEST` path. `owner_database_copy_migration_test.dart` was run with `OPC_OWNER_MIGRATION_COPY` pointing only to that copy: **1/1 passed** in approximately 29.7 seconds. The v27 copy reopened successfully, retained `user_version=27`, `integrity_check=ok`, all recorded table counts and the same SHA-256, and was not replaced.

Representative preserved data counts on both pre- and post-reopen snapshots were: `firma_podaci=1`, `korisnici=1`, `predmeti=47`, `kontakt_lica=1`, `iriu=638`, `iriu_provenance=65`, `predmet_scenario_snapshots=4`, `scenario_definitions=1021`, `scenario_modules=1`, `katalog_artikli=139`, `iriu_katalog_config=29`, `ceremony_reminder_settings=8`, `stanje_robe_stavke=33`, `stanje_robe_applied_effects=53`, `stanje_robe_posledice=46`, `parte_predlosci=2` and `parte_pripreme=1`. The protected PREDMET, IRiU/provenance, SCENARIO snapshot and KATALOG identities therefore remained present and count-stable; no SCENARIO behavior or data was changed.

### Case B — historical migration chain

`canonical_database_migration_recovery_test.dart` ran on the current branch: **40/40 passed**, from 2026-08-18 09:23:26 to 09:30:07 (approximately 401.1 seconds). The evidence covers v19–v26 recovery states, populated schema versions 1–24, malformed-column rejection, missing-table rejection, malformed PARTE rejection, conflicting-index rejection, newer-version rejection, non-empty version-zero rejection and safe retry after DDL-before-failure.

### Case C — recovery / repair behavior

The 40-case suite's recovery states and retry case passed. The package-downgrade lane additionally passed **6/6** tests in approximately 74.1 seconds, including additive recovery of the STANJE ROBE toggle, v19 DATUM DOCEKA migration and retention of package/native functionality. No recovery operation touched the canonical lane.

### Case D — controlled failure behavior

The historical suite passed all controlled rejection cases: unsupported newer schema, non-empty user_version zero, missing required tables, malformed column definitions, malformed PARTE shape and conflicting same-name index definitions. The migration selector suite passed **9/9** tests in approximately 14.0 seconds, including rejection of canonical aliases, relative paths, missing/invalid copies and acceptance only of an explicit existing `MIGRATION_TEST` copy.

## Decision

**RR-005 — ACCEPTANCE INCONCLUSIVE.** Current-tip disposable copy/reopen, historical migration/recovery, package-downgrade compatibility and controlled-failure boundaries are evidenced as passing. Full RR-005 closure is not claimed because the canonical and disposable lanes retain the same 36 pre-existing `foreign_key_check` findings and a current-tip relational-integrity closure oracle is not established.

Bounded successor: **Current-tip migration/recovery relational-integrity closure rehearsal**. It must define the accepted treatment of the pre-existing dependent rows, prove post-recovery referential state on disposable data, and preserve canonical pre/post identity. No implementation or repair is authorized by this report.

## Protected-surface result

No production source, tests, database/schema/migrations, dependencies, platform, CI, runtime/private data or SCENARIO content changed. Analyzer/full-suite PASS evidence from the immediately preceding accepted singleton publication remains reusable because this rehearsal added no source or test artifacts.
