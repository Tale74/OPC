# OPC SCENARIO Characterization Reconciliation → Zero-Fail → Build Report

Date: 2026-08-09

## Initial state and authority

- Baseline branch: `task/OPC-CUMULATIVE-VALIDATION-BUILD-RUNTIME-PREPARATION`
- Baseline SHA: `176599177371de63d88d0bdaf1ae402c2462b61d`
- New branch: `task/OPC-SCENARIO-CHARACTERIZATION-ZERO-FAIL-BUILD`
- Initial SCENARIO targeted result: 80 passed, 5 failed.
- Initial full suite result: 386 passed, 5 failed, 3 skipped.
- Owner map: `C:\Projekti\OPC\OPC v.1\SCENARIO_MAP\Vlasnicka_definicija_logicke_SCENARIO_mape_KONACNA.md`
- Owner map SHA-256: `663F104F01C8ABFABAF5DEDF8C82185AF03FDEF31B403DFB7D4E2EFBF0E061E4`
- Independent golden fixture carries the same source hash and 1008 scenarios.

The owner map and independent golden fixture remained unchanged. No golden
expected values were weakened or regenerated to conceal failures.

## Forensic reconciliation of the five initial failures

| Test | Scenario / old expected | Owner + golden expected | Production actual | Classification / correction |
|---|---|---|---|---|
| `owner_scenario_policy_kernel_test.dart` — hospital exception and stable ordering | `ZARAZNA / BOLNICA / SAHRANA / GRADSKO / GROB / OPELO DA / NE / NE`; old expected `[PREVOZ_DO_GROBLJA, KOMPLET_ZA_OPELO]` | Golden `SCENARIO 0506`: `[LIMENI_ULOZAK, PREVOZ_DO_GROBLJA, KOMPLET_ZA_OPELO]` | Same as golden | `STALE CHARACTERIZATION EXPECTATION`; expectation corrected to owner map. |
| `owner_scenario_policy_kernel_test.dart` — reception + inner sanduk change | `DOCEK=DA`, `PROMENA_SANDUKA=DA`, local `GROBNICA`; old assertion required a subset including LEMOVANJE | Golden `SCENARIO 0880` includes `CARGO_TROSKOVI`, `IZNOSENJE`, `PREVOZ_DO_HLADNJACE`, `HLADNJACA`, `LIMENI_ULOZAK`, `LEMOVANJE`, `PREVOZ_SPROVODA`, `PREVOZ_DO_GROBLJA` | Same rows except LEMOVANJE was omitted because raw `mestoSmrti=BOLNICA` incorrectly triggered the hospital exception while DOCEK makes place informational | `PRODUCTION BUG`; minimal shared fix uses `input.docek || input.mestoSmrti != 'BOLNICA'` for LEMOVANJE. |
| `scenario_default_policy_characterization_test.dart` — BLOK 2 output | `ZARAZNA / STAN / GRADSKO / GROB`; old expected `[]` | Golden `SCENARIO 0436`: `LIMENI_ULOZAK` and `LEMOVANJE`, both `RECOMMENDED` | Same as golden | `STALE CHARACTERIZATION EXPECTATION`; expectation corrected. |
| `scenario_default_policy_characterization_test.dart` — BLOK 2 cause override | `NEDEFINISANA / STAN / GRADSKO / GROB`; old expected `[]` | Golden `SCENARIO 0652`: `LIMENI_ULOZAK` and `LEMOVANJE`, both `RECOMMENDED` | Same as golden | `STALE CHARACTERIZATION EXPECTATION`; expectation corrected per cause (`NASILNA` remains empty, `NEDEFINISANA` receives the metal pair). |
| `scenario_state_reset_runtime_contract_test.dart` — hospital exception | `ZARAZNA / BOLNICA / SAHRANA / GRADSKO / GROB`; old assertion rejected both LIMENI and LEMOVANJE | Golden `SCENARIO 0506`: LIMENI present, LEMOVANJE absent | Same as golden | `STALE CHARACTERIZATION EXPECTATION`; assertion now requires LIMENI and still rejects LEMOVANJE. |

## Iterative correction loop

1. Corrected the shared DOCEK/BOLNICA production condition and four stale
   characterization expectations.
2. First retest found one over-broad corrected expectation: `NASILNA` does not
   receive the metal pair for `GROB`, while `NEDEFINISANA` does. The test was
   refined by cause, without changing production or golden data.
3. Characterization retest: **12 passed, 0 failed** —
   `20260808_235632_characterization_reconciliation_rerun.log`.
4. Corrected SCENARIO targeted family: **85 passed, 0 failed** —
   `20260808_235723_targeted_scenario_zero_fail.log`.
5. 1008 golden retest: **4 passed, 0 failed** —
   `20260808_235915_scenario_1008_golden_retest.log`.
6. Lifecycle retest: **5 passed, 0 failed** —
   `20260808_235945_lifecycle_retest.log`.
7. Final analyzer: **exit 0, no issues** —
   `20260809_000104_flutter_analyze_zero_fail.log`.
8. Final complete suite: **391 passed, 3 skipped, 0 failed, exit 0**, natural
   duration 21:54 — `20260809_000223_full_flutter_test_zero_fail.log`.

All Flutter commands used no timeout wrapper. Long migration and build phases
were allowed to finish naturally.

## Final test and build evidence

- KATALOG/IRiU targeted baseline gate: 62 passed, 2 skipped.
- Migration recovery baseline gate: 64 passed, 1 skipped.
- SCENARIO targeted: 85 passed, 0 failed.
- SCENARIO 1008 golden: 4 passed, 0 failed.
- Lifecycle: 5 passed, 0 failed.
- `flutter analyze --no-pub`: PASS, exit 0.
- `flutter test --no-pub`: PASS, 391 passed, 3 skipped, 0 failed, exit 0.

### Windows

Command: `flutter build windows --release --no-pub`  
Natural exit: 0; duration: 361.0 s  
Log: `C:\Projekti\OPC\OPC v.1\RUNTIME\validation_logs\20260809_002458_windows_release_build.log`

- Release folder: `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release`
- `OPC.exe`: 89,088 bytes; timestamp `2026-08-06T12:00:17+02:00`; SHA-256
  `EB2DB87A10379AB9325DBFDC04EEBFF011C97A0B59C2CB24FA94B6A5D84A1E92`
- `data\app.so`: 12,633,008 bytes; timestamp `2026-08-09T00:30:24+02:00`; SHA-256
  `94FA53BEF14776B2A91B0F821409872C8BE5699776B3A71721B3951869CF0155`

### Android

Command: `flutter build apk --release --no-pub`  
Natural exit: 0; duration: 1,282.1 s  
Log: `C:\Projekti\OPC\OPC v.1\RUNTIME\validation_logs\20260809_003155_android_release_build.log`

- APK: `C:\Projekti\OPC\OPC v.1\SOURCE\build\app\outputs\flutter-apk\app-release.apk`
- Size: 77,961,079 bytes; timestamp `2026-08-09T00:53:11+02:00`
- SHA-256: `9CA86983CBC414B6526ED9860C7C26B05127B75E7B68F93B25DD3E4D4CA29FB7`
- ADB was not used.

## Canonical database

Canonical database: `C:\Users\Steva\Documents\opc_v4_release.sqlite`

- Before validation/build: SHA-256 `B6AD1F7376564589AD6AF2506932DDC8DCB6AFC50FCA4F30F525C01AE9D1C12F`
- After validation/build: SHA-256 `B6AD1F7376564589AD6AF2506932DDC8DCB6AFC50FCA4F30F525C01AE9D1C12F`
- Result: byte hash identical; canonical user database unchanged.

Runtime checklist remains at
`docs/OPC_CUMULATIVE_VALIDATION_RUNTIME_ACCEPTANCE_CHECKLIST.md` and remains
owner-driven. No Windows or Android runtime PASS is claimed by Codex.

## Mandatory verdicts

- `INITIAL 5 SCENARIO FAILURES RECONCILED — PASS`
- `OWNER/GOLDEN/PRODUCTION CONSISTENCY — PASS`
- `STALE CHARACTERIZATION EXPECTATIONS REMOVED — PASS`
- `SCENARIO TARGETED TESTS — PASS`
- `SCENARIO 1008 GOLDEN GATE — PASS`
- `KATALOG/IRiU TESTS — PASS`
- `LIFECYCLE TESTS — PASS`
- `MIGRATION RECOVERY FAMILY — PASS`
- `FLUTTER ANALYZE — PASS`
- `FULL FLUTTER TEST — PASS`
- `FULL TEST FAILED COUNT — 0`
- `TEST TIMEOUT POLICY — NO TIMEOUT USED`
- `WINDOWS RELEASE BUILD — PASS`
- `ANDROID RELEASE BUILD — PASS`
- `WINDOWS ARTIFACT HASHES — RECORDED`
- `ANDROID APK HASH — RECORDED`
- `CANONICAL DB UNCHANGED — PASS`
- `RUNTIME — PENDING OWNER ACCEPTANCE`
- `REMOTE SHA — NOT CONFIRMED FOR THIS NEW BRANCH`
- `WORKING TREE — NOT CLEAN (pending report/source commit)`

The technical zero-fail/build gate is complete. Owner Windows/Android runtime
acceptance remains pending and is not implied by these technical PASS results.
