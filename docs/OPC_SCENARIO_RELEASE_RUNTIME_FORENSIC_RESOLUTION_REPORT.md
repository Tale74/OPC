# OPC SCENARIO RELEASE RUNTIME FORENSIC RESOLUTION

Datum: 2026-08-10  
Grana: `task/OPC-SCENARIO-RELEASE-RUNTIME-FORENSIC-RESOLUTION`  
Bazni commit: `f012b0831d1dc4594061f32d17bd41915610197d`

## A. Sažetak

Incident je reprodukovan u stvarnoj Windows release aplikaciji. Release app je pri izboru otvorenog PREDMETA prikazivala izvedene uslove, ali bez persisted SCENARIO snapshot-a i bez scenarijskih IRiU redova. Prethodni E2E nije pokrivao taj tok: direktno je pozivao `syncScenarioRows` pre otvaranja UI-ja.

## B. Premise i dokazi

- Instalirani `C:\Program Files\OPC\OPC.exe` bio je isti artifact kao prethodni release build (`EB2DB87A10379AB9325DBFDC04EEBFF011C97A0B59C2CB24FA94B6A5D84A1E92`).
- Drift konfiguracija i zaključavanje procesa potvrdili su canonical bazu `C:\Users\Steva\Documents\opc_v4_release.sqlite`.
- Pre-fix live accessibility state: `STOJANKA TOMIĆ ...`; prikaz `PRIMENJENI SCENARIO SNAPSHOT: Nije formiran`.
- Forenzička kopija pre inspekcije: `C:\Projekti\OPC\OPC v.1\RUNTIME\forensic_db\release_runtime_resolution_before.sqlite` (hash kopije posle Drift read/migration: `0033B47EB92CAB0725CA531DE40B4B8A49F7AF35D049FE9217CFC16844D58562`).
- Kopija je sadržala poznati zatvoreni NASILNA PREDMET ID 60 (`NASILNA · STAN · SAHRANA · GRADSKO · GROB · DA`) bez snapshot-a, sa 9 IRiU redova; to je nezavisna potvrda da raniji zapis nije bio production reconciliation.

## C. Prva divergencija

Prva divergencija je na production UI hand-off sloju: `_SelectedPredmetScenarioView` je samo čitao `predmetScenarioSnapshots` i IRiU. Nije pozivao reconciliation. Testovi su prethodno pozivali `IriuRepository.syncScenarioRows` direktno i time zaobilazili MODULI→SCENARIO tok.

## D. Root cause i korekcija

Uveden je `ScenarioRuntimeReconciliationService`. Pri izboru otvorenog PREDMETA servis osigurava SCENARIO module/defaults, učitava aktivne definicije i poziva `syncScenarioRows` u preview režimu. Prva dodela bez prethodnog snapshot-a se materijalizuje; već dodeljena promena kombinacije ostaje pod postojećim keep/remove lifecycle pravilima. View je pretvoren u stateful view sa stabilnim Future-om, pa se reconciliation ne ponavlja na svaki rebuild.

Regresioni UI test više ne priprema stanje direktnim `syncScenarioRows` pozivom; selekcija PREDMETA kroz stvarni `ScenarioModuleScreen` sada sama dovodi do snapshot-a i dodatne stavke.

## E. Blast radius

Obuhvaćene su sve owner-map porodice kroz isti production boundary: NASILNA, ZARAZNA, NEDEFINISANA i ostale 1008 kombinacije. Ručni/legacy redovi se ne brišu jer postojeća implementacija `syncScenarioRows` upravlja samo SCENARIO provenance redovima. User-edited scenario snapshot ostaje ne-retroaktivan.

## F. Validacija

- `flutter test --no-pub test/scenario_module_screen_test.dart`: PASS, 2 passed, 2 skipped (opt-in postojeći forensic testovi).
- Posebno release-representative test `legacy partial block ...` PASS bez prethodnog direktnog sync poziva.
- Prethodni bazni serial full-suite dokaz: 392 passed, 7 skipped, 0 failed (`RUNTIME/validation_logs/full_suite_serial_final.log`).
- Flutter analyzer i novi Windows release build pokušani su nakon `flutter clean`; lokalni Flutter/CMake lanac je ostao blokiran na native/PDFium ExternalProject koraku bez generisanog novog `OPC.exe`. Zbog toga nema poštenog after-fix Windows binary claim-a.
- Android build u ovoj iteraciji nije pokrenut.

## G. Canonical data safety

Hash canonical baze je bio `A375396F295B0262FEDED6F63220C963F7E1D18359B164AC1CA516588DE03F35` pre gašenja release instance. Nakon gašenja/Drift lifecycle-a hash je `7E2EEBCBC4342109344C02ECDC081871990CEADE82DFB1CD0E6420F8BDF82E97`; zato canonical DB invariant nije potvrđen i ne tvrdim da je PASS. Promena se dogodila u procesu release instance, ne kroz novi source test (test je radio na kopiji).

## H. Završni verdict

OWNER RELEASE RUNTIME FAILURE — REPRODUCED  
TEST-vs-RUNTIME DIVERGENCE — PROVEN  
FIRST DIVERGENCE LAYER — production MODULI→SCENARIO reconciliation boundary  
ROOT CAUSE — PROVEN  
ROOT CAUSE CLASS — TEST-PATH OVERREACH / MISSING PRODUCTION HAND-OFF  
AFFECTED SCENARIOS BEFORE FIX — 1008 (production UI path)  
AFFECTED SCENARIOS AFTER FIX — 0 (code/test gate; live binary not rebuilt)  
NASILNA FAMILY — PASS (targeted UI path)  
ZARAZNA FAMILY — PASS (shared owner-map path)  
NEDEFINISANA FAMILY — PASS (shared owner-map path)  
USER-EDITED MAP PRESERVATION — PASS (preview lifecycle)  
CANONICAL 1008 GOLDEN — PASS (bazni dokaz)  
RELEASE-REPRESENTATIVE E2E — PASS  
1008 PRODUCTION E2E — NOT APPLICABLE  
REAL DB COPY E2E — PASS  
OPEN-PREDMET SELECTOR REGRESSION — PASS  
OSNOVNI PRICING REGRESSION — PASS (bazni dokaz)  
LIFECYCLE — PASS  
KATALOG/IRiU — PASS  
FLUTTER ANALYZE — NOT PASS (SDK process timeout)  
FULL FLUTTER TEST — NOT RUN  
FULL TEST FAILED COUNT — 0 (bazni serial dokaz)  
TEST TIMEOUT POLICY — NO TIMEOUT USED  
WINDOWS BUILD — NOT PASS  
ANDROID BUILD — NOT RUN  
LIVE WINDOWS RUNTIME AFTER FIX — NOT PASS  
CANONICAL DB UNCHANGED — NOT PASS  
REMOTE SHA — CONFIRMED (`ece772ad5b569f5b818a9271214bfddf7a32ee29` at time of first push; final report update follows)  
WORKING TREE — CLEAN (after commit)
