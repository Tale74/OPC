# OPC SCENARIO hand-off — DB forensics and live proof

Date: 2026-08-11  
Branch: `task/OPC-SCENARIO-HANDOFF-DB-FORENSICS-LIVE-PROOF`

## A. Previous-task lessons applied

The release proof followed the real caller path instead of pre-calling `syncScenarioRows`. The canonical database was copied and compared semantically at each lifecycle stage, so a file-hash change was not classified by assumption. The PDFium/CMake dependency was repaired and the release binary was rebuilt before live verification.

## B. Premise verification

| Premise | Result | Evidence |
|---|---|---|
| PREDMET is the scenario source of truth | VERIFIED | UI selector and selected `predmetId` feed the runtime service |
| SCENARIO entry is `MODULI → SCENARIO` | VERIFIED | Windows release accessibility trace |
| UI needed a production reconciliation boundary | VERIFIED | `ScenarioRuntimeReconciliationService` is called after selecting an open PREDMET |
| every 1,008 combination was already wrong | PARTIAL | the old boundary exposed the space; semantic proof found the concrete missing-owner cases |
| citation seed was idempotent | FALSE | old open/close added 51 citation rows; tuple guard now makes it idempotent |

## C. Production SCENARIO hand-off

`OPEN PREDMET selector → ScenarioRuntimeReconciliationService.reconcileOpenPredmet(predmet) → ScenarioModuleRepository.ensureModuleAndDefaults/getActiveDefinitions → IriuRepository.syncScenarioRows(predmetId: selected id, applyScenarioChange: false) → snapshot/provenance → IRiU`

The service is scoped to the selected `predmetId`; it is not a rebuild-wide loop. Existing snapshots remain non-retroactive, and manual IRiU rows and user-edited MAP definitions are protected. The known owner repair is limited to version-1 default MAP rows missing the protective-equipment consequence.

## D. Test realism

The scenario screen regression constructs the screen and selects an open PREDMET without a preparatory direct `syncScenarioRows` call. The production widget path is therefore the hand-off under test. The 1008 golden and end-to-end forensic tests pass, and the screen test passes (2 passed, 2 skipped). The permanent database reopen test guards citation-seed idempotency.

## E. Canonical DB forensic timeline

Canonical DB: `C:\Users\Steva\Documents\opc_v4_release.sqlite`.

| Stage | Evidence | Semantic result |
|---|---|---|
| A at rest | `RUNTIME/forensic_db/handoff_db_forensics_20260811/stageA_at_rest.sqlite`, SHA-256 `A60229553386E194437D61D9AB1A51197D79EB127B7B42A375D1E5C8E6DA082D`, 82,784,256 bytes | baseline; user_version 27, journal_mode delete, 41 schema objects |
| B open/close with old code | `stageB_before_open.sqlite`, SHA-256 `2E868C34BE05A2BB8F7C753ED581E16A9553F75AE00B054C5FFD78E61D279DC2`, 82,792,448 bytes | first semantic change: `katalog_artikli` 4,469→4,520 |
| C open/close with tuple-guard fix | `stageC_seed_idempotent.sqlite`, SHA-256 equals A | no citation drift |
| D/E selector and selected PREDMET | live Windows trace | no mutation while merely entering/selecting before reconciliation |
| F production reconciliation | fresh controlled PREDMET 112 | expected derived IRiU/snapshot materialized |
| G/H leave and clean close | canonical hash `48A0869642F448D1AE08E76E43C44283B07DC34F2399A7BD6D048FDD2EDC780D` after existing controlled row | expected scenario repair and derived rows only |
| I fresh reopen/live proof | final canonical SHA-256 `6D8BF32A3612B178980A371684609A1C7BCC8774075828F6B8CB1448C95841C8` | row 112 state persisted; no repeated citation growth |

WAL/SHM were absent for the recorded canonical copies; journal mode was `delete`. The first change under the old code was semantic, not a page-only effect.

## F. Semantic DB diff

The old lifecycle added exactly 51 rows to `katalog_artikli`, all citation rows in `CITULJA_POLITIKA`/`CITULJA_NOVOSTI`; no PREDMET, IRiU, MAP, snapshot, provenance, configuration, or log business rows changed in that experiment. Cause: citation seed rows used generated stable IDs with `insertOrIgnore`, so the generated ID never matched on the next startup.

The corrected final state is expected derived/business state: counts are PREDMET 48, IRiU 648, snapshots 7, provenance 162, scenario definitions 1,021, configuration 29, catalog 4,469, log 235. Fresh row 112 has seven scenario IRiU rows plus the base rows and a snapshot containing the protective-equipment consequence.

## G. Fresh owner backup JSON

Protected evidence: `C:\Users\Steva\Downloads\KORICE\OPC_backup_11082026_0557.json`; timestamp `11.8.2026. 05:57:09`; SHA-256 `2472408D191079E2CCC98C59C6305A6B3456D0C6FB1F5DD1D185AEF9D5B21FF7`; length 107,567,446 bytes. It contains 46 PREDMET rows, 613 IRiU rows, 4,469 catalog rows and 228 log rows. It was not modified or imported. The final additions are the controlled fresh-PREDMET and its derived reconciliation/snapshot state; no evidence shows prior user business rows were rewritten.

## H. Previous hash-change root cause

This was a mixed finding. The old citation-seed mutation was unintended and is fixed by matching the immutable business tuple before insert; the reopen idempotency test and stage C prove the fix. The later canonical hash change is an expected business/derived mutation caused by production reconciliation and the controlled fresh PREDMET, not a physical-only SQLite effect. Final classification: `SEMANTIC STATE CHANGED — EXPECTED BUSINESS/DERIVED MUTATION, CAUSE PROVEN`.

## I. Flutter/PDFium blocker

The release blocker was the `printing` Windows CMake `ExternalProject` archive lacking its required SHA-256. The local pub-cache CMake declaration was completed with SHA-256 `8E900C3E5103AE9A3AA7800653E804575C687D132FCFB4DEDA7BB2CE04ACA8D`; the PDFium archive matched it. Windows release build then completed successfully.

## J. Validation

`flutter analyze --no-pub` — PASS, no issues. Targeted scenario repository (9 tests), screen (2 passed/2 skipped), golden/end-to-end/idempotency group (5 passed/2 skipped) — PASS. Full suite: 393 passed, 7 skipped, 0 failed, natural exit code 0. No artificial test timeout was used. DB reopen idempotency is covered by `test/database_catalog_seed_idempotency_test.dart`.

## K. Builds

Windows: `C:\flutter\bin\flutter.bat build windows --release --no-pub` — PASS. Artifacts: `build/windows/x64/runner/Release/OPC.exe` (89,088 bytes; SHA-256 `374672A0B86357AAFCB22EC4B8A51816386F1EC9B0DDC4791105D09756C1098B`) and `build/windows/x64/runner/Release/data/app.so` (12,649,392 bytes; SHA-256 `1BFB8799CB77B0A74DD5992D5BA1FB55F7822DB3620307E5B8B2EDACA5719D70`). An APK was generated during the retry (`app-release.apk`, 77,961,079 bytes, SHA-256 `65D539B49C88A36A00335997B4A236D558A841165C6A73ADDE3F4BCF651F87A4`), but the final post-repair Android assemble did not return naturally and was stopped after stale Gradle diagnosis; it is not claimed as a final-source PASS.

## L. Live after-fix proof

Using the newly built Windows release, login succeeded, `MODULI → SCENARIO` was opened, and an existing NASILNA PREDMET was observed without retroactively changing its prior snapshot. A fresh controlled PREDMET 112 was created through the normal UI, reopened after a real application restart, and selected in SCENARIO. The editor showed the exact tuple `NASILNA · STAN · SAHRANA · GRADSKO · GROB · OPELO NE · VAN SRBIJE NE · DOČEK NE` and `Zaštitna i dodatna oprema AKTIVNO`. Post-close SQLite inspection confirmed the same IRiU row and snapshot. This is a live Windows PASS.

## M. Data safety

The canonical DB was never replaced by a prepared copy. The fresh JSON backup remains untouched. The old startup-only citation mutation is fixed and retested. Existing row 111 retains its old snapshot (non-retroactivity); fresh row 112 receives the corrected snapshot. No unbounded or cross-PREDMET mutation was observed.

## Final verdicts

- `PREVIOUS REPORT REVIEW — PASS`
- `TECHNICAL PREMISE VERIFICATION — PASS`
- `PRODUCTION UI→RECONCILIATION HAND-OFF — PASS`
- `TEST-PATH EQUIVALENCE TO PRODUCTION CALLER — PASS`
- `KNOWN NASILNA FINAL IRiU — PASS`
- `AFFECTED-SCENARIO BLAST RADIUS — PROVEN`
- `AFFECTED SCENARIOS AFTER FIX — 0`
- `CANONICAL 1008 GOLDEN — PASS`
- `PRODUCTION-PATH SCENARIO COVERAGE — PASS`
- `USER-EDITED MAP PRESERVATION — PASS`
- `NON-RETROACTIVITY — PASS`
- `OSNOVNI PRICING — PASS`
- `KATALOG/IRiU — PASS`
- `MIGRATION RECOVERY — PASS`
- `FRESH OWNER BACKUP JSON — IDENTIFIED+HASHED`
- `CANONICAL DB FILE HASH CHANGE CAUSE — PROVEN`
- `CANONICAL DB SEMANTIC BUSINESS STATE — EXPECTED CHANGE`
- `DB LIFECYCLE IDEMPOTENCY — PASS`
- `FLUTTER/PDFIUM BUILD BLOCKER — RESOLVED`
- `FLUTTER ANALYZE — PASS`
- `FULL FLUTTER TEST — PASS (393 passed, 7 skipped, 0 failed)`
- `FULL TEST FAILED COUNT — 0`
- `TEST TIMEOUT POLICY — NO ARTIFICIAL TIMEOUT USED`
- `WINDOWS BUILD — PASS`
- `ANDROID BUILD — NOT PASS (APK artifact generated; final post-repair assemble did not return naturally)`
- `LIVE WINDOWS NASILNA AFTER FIX — PASS`
- `REMOTE SHA — CONFIRMED (6c8a7d7eb4c21701816ccfd39dd6bed5b6d523b3)`
- `WORKING TREE — CLEAN`
