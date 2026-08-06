# OPC — SCENARIO runtime loading correction

## Nalaz

Dokaz `C:\Projekti\OPC\OPC v.1\RUNTIME\SCENARIO.PNG` prikazuje SCENARIO ekran koji ostaje na kružnom indikatoru bez sadržaja, poruke ili izlaza. Live `OPC.exe` proces nije zaustavljan niti je njegova baza menjana.

## Utvrđeni async lanac

Ekran je pokretao `ScenarioModuleRepository.ensureModuleAndDefaults()` kroz `_moduleFuture`. Taj poziv prvo otvara bazu i zavisi od `AppDatabase.beforeOpen`, a zatim radi migraciju/oporavak šeme, konsolidaciju KATALOG-a, osnovnu politiku, stabilne identifikatore kataloških artikala i učitavanje scenario definicija. Tek nakon toga se čitaju KATALOG i definicije.

Na kopiji `C:\Projekti\OPC\OPC v.1\RUNTIME\runtime_data\opc_v4.sqlite` dijagnostika je pokazala:

- `beforeOpen` i prvi DB upit završavaju približno za 42 sekunde;
- ceo `ensureModuleAndDefaults()` završava približno za 45 sekundi;
- rezultat je 1.021 definicija, od kojih je 1.008 `MAP_` owner-map definicija, 29 vidljivih KATALOG kategorija i paket od 11 stavki;
- nema dokaza o beskonačnoj petlji u učitavanju 1.008 definicija.

Pravi problem u UI lifecycle-u bio je da `FutureBuilder` nije obrađivao `hasError` i nije imao timeout. Svaki DB/native-assets zastoj ili izuzetak zato je korisniku izgledao kao beskonačni loading.

## Korekcija

U `scenario_module_screen.dart`:

1. `ensureModuleAndDefaults`, KATALOG učitavanje i definicije imaju kontrolisani timeout od 60 sekundi.
2. Loading stanje sada ima tekst `Učitavanje SCENARIO modula...`.
3. Svaka faza obrađuje grešku i prikazuje kontrolisani ekran `SCENARIO nije moguće učitati.` sa dugmetom `PONOVI UČITAVANJE`.
4. Posle učitavanja proverava se da postoji najmanje 1.008 `MAP_` definicija; nepotpun skup je greška, a ne prazan ekran.
5. Posle izmene paketa ili scenarija sva tri izvora se ponovo učitavaju kroz jedinstveni retry lifecycle.
6. Uklonjene su neaktivne legacy UI klase iz user-facing fajla.

U `katalog_tab.dart` dodat je mounted-gate posle asinhronog ažuriranja, čime je uklonjen analyzer nalaz za korišćenje `BuildContext` posle async gap-a. Poslovna logika baze nije menjana.

## Validacija

- `flutter analyze --no-pub`: PASS, `No issues found`, exit code 0.
- `scenario_module_screen_test.dart`: PASS, 2/2.
- `scenario_module_repository_test.dart`: PASS, 5/5.
- `iriu_catalog_basic_category_policy_test.dart`: PASS, 5 passed, 2 skipped po postojećoj politici.
- `full_backup_restore_lifecycle_coordination_test.dart`: PASS, 8/8.
- kompletan `flutter test --no-pub`: nije sertifikovan kao PASS; izvršavanje je dostiglo spoljašnji timeout od 904 sekunde i nije vratilo završni exit code. Isti rezultat je ponovljen sa `--concurrency=1`. Zaostali `flutter_tester` procesi su zatvoreni posle timeout-a.

Tokom prvog ciljanog pokušaja test je naišao na zaostali sqlite3 native-assets hook output (`download-*` direktorijum). Očišćeni su samo generisani `.dart_tool/hooks_runner/sqlite3`, `.dart_tool/hooks_runner/shared/sqlite3`, `.dart_tool/flutter_build` i `build/native_assets` delovi; nakon regeneracije ciljani testovi prolaze. Live `OPC.exe` nije diran.

Naknadni vlasnički pokušaj `flutter test --no-pub` ponovio je isti Flutter tool crash, sada sa drugim zaostalim direktorijumom (`download-161ee2f0`) i postojećim ciljnim `build/native_assets/windows/sqlite3.dll`. To potvrđuje nestabilnost generisanog native-assets state-a, a ne regresiju SCENARIO koda. Pre novog full-suite pokušaja moraju se zatvoriti samo zaostali `flutter_tester` procesi i očistiti navedena četiri generisana direktorijuma; instalirani live `OPC.exe` proces se ne zaustavlja.

## Status

```text
SCENARIO RUNTIME LOADING CORRECTION
— ROOT ASYNC CHAIN IDENTIFIED
— CONTROLLED TIMEOUT AND ERROR/RETRY IMPLEMENTED
— 1.008 OWNER-MAP INVARIANT ENFORCED
— FULL ANALYZE PASS
— FOCUSED SCENARIO/REPOSITORY/KATALOG TESTS PASS
— FULL FLUTTER TEST NOT CERTIFIED (904s TIMEOUT)
— WINDOWS/ANDROID RELEASE BUILD NOT RUN IN THIS CORRECTION
— RUNTIME RECHECK REQUIRED WITH NEW BUILD
```
