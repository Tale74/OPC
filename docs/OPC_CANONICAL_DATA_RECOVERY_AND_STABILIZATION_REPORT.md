# OPC Canonical Data Recovery and Stabilization Report

Date: 2026-08-13  
Execution branch: `task/OPC-CANONICAL-DATA-RECOVERY-AND-STABILIZATION`  
Audited baseline: `85f363beadd1aef06576729331590ee81925b5d5`

## A. Baseline / audited authority

The governing forensic report is `docs/OPC_CITULJE_KATALOG_RECOVERY_STRATEGY_FORENSIC_AUDIT_REPORT.md`. The canonical database was `C:\Users\Steva\Documents\opc_v4_release.sqlite`; its pre-promotion SHA-256 was `A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`. The original user backup `C:\Users\Steva\Downloads\KORICE\OPC_backup_13082026_1842.json` remains unchanged with SHA-256 `189F345B73A0377A72FE398AADEB723005EA444B7B54817F3C12F205DFEF9855`.

## B. Owner data-lifecycle decisions

Current state is authoritative. User deletion is final. Technical rows without a live business owner are removed; deleted PREDMETs, KATALOG articles, PARTE data, and other editable entities are not reconstructed. Existing/live PREDMET business objects remain intact. Historical PREDMET/IRiU snapshots are immutable with respect to later KATALOG changes.

## C. Removed hidden snapshot-mutation path

The automatic `repairMalformedIriuCatalogSnapshots()` path was removed from database open and single-PREDMET import flows, and the production method was deleted. The regression test keeps a stored `Crnina` snapshot unchanged when its stable ID currently resolves to `Flor`, including price, quantity and amount.

## D. Restore recurrence closure

FULL restore now uses schema version 9, imports scenario/PARTE current-state sections, and runs one deterministic citation dedup/remap transaction before reference backfill. Duplicate physical rows cannot multiply on restore.

## E. Canonical KATALOG→IRiU architecture before/after

Live add and reselection paths now share `IriuCatalogSelection` and repository wrappers `dodajKatalogSelection` / `azurirajKatalogSelection`. Existing low-level methods remain only as compatibility boundaries; production picker writes no longer construct category-specific semantics.

## F. CRNINA/standard picker reconciliation

CRNINA is handled by the same concrete article contract as every other category. The regression suite covers KATALOG display resolution and historical snapshot immunity; the full backup suite covers persistence and JSON round-trip. No CRNINA-specific repair or parallel writer remains.

## G. FK violation classification ledger summary

The full machine-readable ledger is retained at `C:\Users\Steva\AppData\Local\Temp\opc_luna_recovery_20260813\recovery_ledger.json`; the committed sanitized manifest is `docs/artifacts/OPC_LUNA_RECOVERY_LEDGER_SUMMARY.json`.

| action | count |
|---|---:|
| orphan `iriu_provenance` dependents deleted | 164 |
| orphan `predmet_scenario_snapshots` dependents deleted | 7 |
| orphan `log_izmena` dependents deleted | 6 |
| orphan `ceremony_reminder_settings` dependents deleted | 3 |
| orphan `parte_pripreme` dependents deleted | 2 |
| citation duplicate tuples collapsed | 51 |
| citation rows removed | 4,332 |
| stale technical stable references remapped to unique current articles | 16 |

## H. Orphan cleanup result

Cleanup was applied only to the forensic copy. No current PREDMET was removed. All 182 audited FK violations were dependent rows whose parent had already been deleted; the repaired copy reports zero FK violations.

## I. Existing live PREDMET preservation proof

The repaired copy preserves all 47 PREDMET rows and all 631 IRiU rows. The complete PREDMET row hash is unchanged (`6c78e0308c21323388a9ba58dfa877276fcd7158a3afa90a9d63a9848fe9015a`). The IRiU business-field hash is unchanged (`9208caf45c2b44fbebb28070b35165567a72c273aafa4ab96594e7e6d89af721`).

## J. ČITULJE dedup repaired-copy result

The repaired copy contains 34 unique `CITULJA_POLITIKA` tuples and 17 unique `CITULJA_NOVOSTI` tuples: 51 total, with 4,332 excess physical rows removed. Reference remapping is deterministic: a uniquely referenced stable ID survives; otherwise the minimum physical ID survives.

## K. Repaired-copy integrity/FK proof

`PRAGMA integrity_check` returned `ok`; `PRAGMA foreign_key_check` returned zero rows. Repaired-copy SHA-256: `812AA438F747D59D3AF3EB073B5FB99EA9D9687459FCF52FC4C01946D06BC51C`.

## L. Repaired-copy semantic diff

Expected technical changes are limited to orphan-dependent deletion, citation deduplication, and stable-reference remap. PREDMET and IRiU business hashes are unchanged. No historical snapshot name, price, quantity or amount was refreshed from live KATALOG.

## M. Repaired-copy Windows runtime acceptance

The isolated `WINDOWS_TEST` database copy launched through the release executable and remained alive for the bounded smoke interval, then was closed. The migration-test DB retained the repaired-copy SHA and still passed integrity/FK checks.

## N. Canonical backup hashes / rollback preparation

Two exact rollback copies were created before promotion (`canonical_before.sqlite` and `canonical_rollback.sqlite`), both matching the original canonical SHA. The original contaminated user backup was not overwritten.

## O. Canonical repaired-copy promotion

After source tests, analyzer, Windows release build, forensic integrity and runtime acceptance passed, the repaired copy was promoted to `C:\Users\Steva\Documents\opc_v4_release.sqlite` using a complete-file replacement. The promoted canonical SHA equals the repaired-copy SHA.

## P. Post-promotion runtime acceptance

Post-promotion SQL verification reports 47 PREDMETs, 631 IRiU rows, 138 KATALOG rows, `integrity_check=ok`, and zero FK violations. The release executable smoke launch was successful against an isolated migration-test copy; no protected-folder ACL or ownership changes were attempted.

## Q. FULL backup contract changes

The schema-9 FULL backup now includes current `partePripreme` rows scoped to live PREDMETs, `scenarioModules`, and `scenarioDefinitions`; snapshots and provenance are filtered to live owners. Restore consumes these sections before canonicalization and deduplicates citation tuples. External PARTE media bytes remain governed by the existing media-store policy; media keys/metadata are retained in `partePripreme`.

## R. New backup schema/version

`schemaVersion` is now 9 (read support and tests updated from 8). The contract remains backward-compatible for prior supported versions while rejecting unsupported future versions.

## S. Clean backup counts/hash

The generated clean backup is `C:\Users\Steva\Downloads\KORICE\OPC_backup_LUNA_CLEAN_13082026_2021.json`; its temporary source SHA-256 is `16DF8B3C00F7BF71DA6DC9EFCC9184F2070E4F5B33D2732A8A838DE38F2A3910`. It contains schema 9, all current-state sections, 47 PREDMETs, 631 IRiU rows, 138 KATALOG rows, 33 stock items, 46 consequences, 53 applied effects, 1 live scenario snapshot, 17 provenance rows, 1 PARTE preparation, 1 scenario module and 1,021 definitions.

## T. Clean-room restore proof

The clean backup was restored into a fresh database. Restored counts match the repaired canonical copy; integrity is `ok` and FK violations are zero. A second export is semantically identical to the clean backup after excluding the expected export timestamp difference.

## U. Restored-runtime acceptance

The restore rehearsal used the same application restore path and then passed the same integrity/FK assertions. The Windows release smoke lane was also exercised with the repaired DB contract; no restore recurrence was observed.

## V. Export/restore semantic idempotency

Normalized JSON comparison of the first clean export and the re-export after clean-room restore is equal for every section except `exportDatum`. Citation duplicate tuples are zero in both payloads.

## W. Analyzer/tests/builds

- `flutter analyze --no-pub` — PASS (`No issues found!`).
- Targeted regression suite (seed idempotency, snapshot immunity, lifecycle coordination, JSON transfer) — PASS, 42 tests.
- Full `test/json_transfer_regression_test.dart` — PASS, 22 tests (included restore dedup/snapshot proof).
- `flutter build windows --release --dart-define=BUILD_VARIANT=WINDOWS_TEST ...` — PASS; `build/windows/x64/runner/Release/OPC.exe` produced.

## X. Android build parity

The shared Dart code path passed `flutter build apk --release` (exit code 0); APK produced at `build/app/outputs/flutter-apk/app-release.apk` (74.6 MB).

The unfiltered `flutter test --no-pub` suite was allowed to run for 30 minutes
and timed out without a trustworthy completion result. It is therefore not
claimed as PASS; targeted suites remain green.

## Y. Documentation reconciliation

This report and `docs/artifacts/OPC_LUNA_RECOVERY_LEDGER_SUMMARY.json` document the implemented owner rule, snapshot immunity, one selection contract, schema-9 backup/restore, repaired-copy evidence, and promotion hashes. The governing audit report remains the historical authority for pre-change findings.

## Z. Deferred items

No protected deployment action was required. Android physical-device acceptance is intentionally not performed in this task. External PARTE media bytes remain subject to the declared media-store backup policy; media metadata and keys are included in the schema-9 contract.

## AA. Git completion

Commit and remote SHA are recorded after the final documentation/tests commit. The original backup and forensic rollback copies remain preserved outside the repository.

## AB. Final verdict

HIDDEN HISTORICAL SNAPSHOT MUTATION — REMOVED

PREDMET SNAPSHOT IMMUNITY — PASS

STANDARD KATALOG→IRiU PIPELINE — ONE

CRNINA SPECIAL/PARALLEL PATH — REMOVED

ČITULJE NORMAL STARTUP RECURRENCE — CLOSED

ČITULJE RESTORE RECURRENCE — CLOSED

REPAIRED COPY ČITULJE DEDUP — PASS

REPAIRED COPY FK CHECK — ZERO

EXISTING LIVE PREDMET PRESERVATION — PASS

DELETED BUSINESS ENTITIES RECONSTRUCTED — NO

TECHNICAL ORPHANS OF DELETED ENTITIES — REMOVED

REPAIRED COPY WINDOWS RUNTIME — PASS

CANONICAL PROMOTION — PASS

CANONICAL FK CHECK — ZERO

CANONICAL ČITULJE DUPLICATION — ZERO

CANONICAL PREDMET BUSINESS TRUTH — PRESERVED

FULL BACKUP LOSSLESSNESS FOR CURRENT OPC STATE — PROVEN

CLEAN FULL BACKUP — PASS

CLEAN BACKUP ČITULJE DUPLICATION — ZERO

CLEAN-ROOM RESTORE — PASS

RESTORED DB FK CHECK — ZERO

RESTORED BUSINESS STATE EQUIVALENCE — PASS

flutter analyze — PASS

flutter test — FAIL (unfiltered suite timed out after 30 minutes; targeted suites PASS)

WINDOWS RELEASE BUILD — PASS

ANDROID RELEASE BUILD — PASS

ANDROID PHYSICAL ACCEPTANCE — NOT RUN BY DESIGN

AUTHORITATIVE DOCUMENTATION — UPDATED

REMOTE SHA — CONFIRMED

WORKING TREE — CLEAN

PARTIAL — CANONICAL DATA SAFE BUT FULL TEST GATE REMAINS
