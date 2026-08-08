# OPC SCENARIO — LEGACY PATH SURGICAL REMOVAL REPORT

Datum: 2026-08-08  
Task grana: `task/OPC-SCENARIO-LEGACY-PATH-SURGICAL-REMOVAL`

## 1. Baseline i dokaz prethodnog recovery taska

- Polazna grana: `task/OPC-SCENARIO-OPERATIONAL-RECOVERY`.
- Polazni HEAD i poslednji javno vidljiv commit: `f5b39f653c714a5ab9afce3b24bc0041470b6b87` (`fix(scenario): recover operational database catalog and IRiU integration`).
- Polazni working tree: čist; nije postojao `.git/index.lock` niti necommitovana recovery izmena.
- Relevantni polazni report: `docs/OPC_SCENARIO_OPERATIONAL_RECOVERY_REPORT.md`.
- Vlasnikov PowerShell zapis `C:\Users\Steva\Desktop\New Text Document.txt` potvrđuje za prethodni recovery commit: analyze exit 0, full test exit 0 (`372 passed`, `3 skipped`), Windows release build exit 0, Android release build exit 0, commit exit 0 i push exit 0.
- Taj zapis je istorijski baseline dokaz. U ovom tasku nijedan build nije pokrenut.

## 2. Izvori i runtime dokaz

Pročitani su vlasnička konačna mapa, njen kontrolni izveštaj, svi reporti navedeni u tasku, IRiU pseudokod, aktivni SCENARIO/PREDMET/IRiU source, persistence/migration sloj i runtime slike u `C:\Projekti\OPC\OPC v.1\RUNTIME`.

Runtime slike dokazuju:

- aktivan legacy blok sa `BOLNICA`, `DOM ZA STARE`, `STAN`, `LEMOVANJE`, `LIMENI ULOŽAK`, `OPELO`, `SAHRANA VAN SRBIJE` i drugim parcijalnim definicijama;
- odvojen finder potpune kombinacije koji je prikazivao interni `SCENARIO_MAP_*` naziv;
- PREDMET IRiU sa `LIMENI ULOŽAK` i `LEMOVANJE`, ali bez `ZAŠTITNA I DODATNA OPREMA`.

Vlasnička mapa za scenario 0224 (`NASILNA + STAN + SAHRANA + GRADSKO + GROBNICA + OPELO NE + VAN SRBIJE NE + DOČEK NE`) eksplicitno daje devet stavki, uključujući `ZAŠTITNA I DODATNA OPREMA` odmah iza `IZNOŠENJE`. Kontrolni izveštaj potvrđuje 1.008 jedinstvenih kombinacija i nula dupliranih ključeva/stavki.

## 3. Call graph pre korekcije

Normalni runtime put na baseline-u:

`PREDMET polja` → `IriuSegment._runScenarioSync` → `ScenarioModuleRepository.ensureModuleAndDefaults` → `getActiveDefinitions` → `IriuRepository.syncScenarioRows` → `OwnerScenarioPolicyKernel.evaluate` (puni ključ i `MAP_*` izbor) → sačuvana MAP `ScenarioDefinition` → `ScenarioRuleEngine.evaluate([samo izabrana MAP definicija])` → KATALOG resolution → snapshot/diff → IRiU rows/provenance → `PredmetIriuTruthService`.

Važni tragovi:

- puni ključ formira `OwnerScenarioInput.fromPredmet` + `OwnerScenarioKey.stableId`;
- `IriuRepository.syncScenarioRows` pronalazi samo definiciju čiji je ID jednak izabranom punom MAP ključu;
- čim u prosleđenom skupu postoji MAP politika, `ScenarioRuleEngine` dobija listu sa samo jednom izabranom MAP definicijom;
- `LIMENI ULOŽAK` i `LEMOVANJE` dolaze iz sačuvane MAP definicije, ne iz legacy parcijalnih definicija;
- `IriuTruthRules` za `scenarioUpravlja == true` ne menja status/order/financial rezultat; `PredmetIriuTruthService` čita materijalizovana scenario polja;
- legacy parcijalne definicije je UI čitao iz iste `ScenarioDefinitions` tabele i prikazivao kao sve zapise bez `MAP_` prefiksa.

## 4. Klasifikacija puteva

| Deo | Pre korekcije | Posle korekcije | Dokaz/granica |
|---|---|---|---|
| `OwnerScenarioPolicyKernel` | RUNTIME BUSINESS AUTHORITY za ključ i seed | RUNTIME BUSINESS AUTHORITY | formira pun ključ; ne zaobilazi sačuvanu definiciju pri normalnom runtime-u |
| MAP `ScenarioDefinition` records | RUNTIME BUSINESS AUTHORITY | RUNTIME BUSINESS AUTHORITY | jedina aktivna definicija prosleđena evaluatoru |
| `ScenarioRuleEngine` | RUNTIME BUSINESS AUTHORITY (data evaluator) | RUNTIME BUSINESS AUTHORITY (data evaluator) | evaluira samo izabranu MAP definiciju |
| legacy `STAN/BOLNICA/...` records | DISPLAY + MIGRATION/COMPATIBILITY; normalni MAP runtime ih ignoriše | MIGRATION/COMPATIBILITY ONLY | `getActiveDefinitions` sada vraća isključivo `MAP_*` |
| legacy split/repair kod u repository-ju | MIGRATION ONLY | MIGRATION ONLY | potreban za postojeće baze; istorijske migracije nisu brisane |
| `IriuTruthRules` za scenario-managed red | READ ONLY / DISPLAY DERIVATION | READ ONLY / DISPLAY DERIVATION | stored scenario fields imaju prednost; ne dodaje/uklanja MAP stavke |
| `IriuTruthRules` za ručne/legacy redove | COMPATIBILITY TRUTH | COMPATIBILITY TRUTH | van scenario-managed seta; ne menja MAP rezultat |
| `BusinessPolicyEvaluator` | READ ONLY legacy parity/snapshot lane | READ ONLY legacy parity/snapshot lane | ne piše scenario rows niti bira definiciju |
| mesto/blok2 lifecycle servisi | LEGACY/COMPATIBILITY, bez poziva u normalnom MAP sync-u | isto | nisu u aktivnom `PREDMET → MAP → IRiU` call chain-u |
| legacy SCENARIO UI blok | DISPLAY ONLY, ACTIVE | REMOVED | non-MAP zapisi se više ne renderuju |

Nema `UNKNOWN` dela koji može menjati scenario-managed IRiU.

## 5. Verdict početne hipoteze

`LEGACY PARTIAL SCENARIO RUNTIME PATH` je **PROVEN INACTIVE** za normalni runtime sa MAP definicijama. Source i regression test dokazuju da čak i eksplicitno ubačena legacy `STAN` definicija sa dodatnom stavkom ne može promeniti izabrani MAP ID niti finalni item set.

`LEGACY PARTIAL SCENARIO UI` je bio **PROVEN ACTIVE**: `_ScenarioPolicyTree` je renderovao svaki non-MAP zapis u bloku `DODATNI SCENARIJI`. Taj blok je uklonjen.

Početna pretpostavka o paralelnom poslovnom autoritetu zato je odbačena. Korekcija nije nagađala niti brisala istorijske definicije; runtime granica je dodatno učvršćena tako što `getActiveDefinitions` vraća samo potpune MAP definicije.

## 6. Root cause konkretnog mismatch-a

Greška je bila unutar generatora potpune MAP definicije. `OwnerScenarioPolicyKernel._consequences` je koristio isti uslov za BIOHAZARD upozorenje i za `ZAŠTITNA I DODATNA OPREMA`: samo `ZARAZNA` ili `NEDEFINISANA`. Vlasnička mapa zahteva zaštitnu opremu i za `NASILNA`, dok BIOHAZARD tekst i dalje ostaje ograničen na postojeće zaključano pravilo.

Korekcija razdvaja:

- `requiresProtectiveEquipment`: svaki uzrok osim `PRIRODNA`;
- `biohazard`: samo `ZARAZNA` ili `NEDEFINISANA` (postojeći tekst nije promenjen).

Za postojeće baze repository popravlja samo precizan fingerprint netaknute sistemske version-1 `MAP_NASILNA_*` definicije kojoj nedostaje ta jedna stavka. Zapis sa bilo kojom dodatnom korisničkom izmenom ne odgovara fingerprint-u i ostaje netaknut. Nema resetovanja, reseed-a korisničkih definicija niti izmene istorijske DB migracije.

## 7. Finalni jedini izvršni put

`PREDMET` → potpuni `OwnerScenarioKey` → aktivna sačuvana `MAP_* ScenarioDefinition` → `ScenarioRuleEngine` data evaluation → KATALOG stable-ID resolution → PREDMET-scoped snapshot/diff → scenario-managed IRiU.

Legacy parcijalne definicije nisu deo aktivnog definition seta, nisu renderovane i ne mogu dopuniti rezultat posle MAP selekcije. Ručni IRiU redovi ostaju van scenario-managed seta i nisu obrisani niti preuzeti.

## 8. Regression expected/actual

Ključ:

`MAP_NASILNA_STAN_SAHRANA_GRADSKO_GROBNICA_NE_NE_NE`

Expected i actual dodatak (stroga list equality):

1. `TRANSPORTNA_VRECA`
2. `IZNOSENJE`
3. `ZASTITNA_I_DODATNA_OPREMA`
4. `PREVOZ_DO_HLADNJACE`
5. `HLADNJACA`
6. `SPREMANJE_POKOJNIKA` (stabilni KATALOG identitet koji se korisniku prikazuje kao „Spremanje preminulog lica/pokojnika“ prema KATALOG resolveru)
7. `LIMENI_ULOZAK`
8. `LEMOVANJE`
9. `PREVOZ_DO_GROBLJA`

Test potvrđuje tačan redosled, odsustvo dodatnih legacy stavki, odsustvo `KOMPLET_ZA_OPELO`, odsustvo duplikata i validnu KATALOG rezoluciju kroz stvarni sync.

## 9. PREDMET-scoped UI i state isolation

- PREDMET meni sada otvara `Scenario predmeta` i prosleđuje konkretni `PredmetiData`.
- Header koristi postojeći `brojPredmeta`: `Scenario za PREDMET <brojPredmeta>`.
- Rezime prikazuje poslovne ose, nikad `MAP_*`/`SCENARIO_MAP_*` identitet.
- Finder, preview i editor za MAP zapis koriste poslovni rezime umesto internog ID-ja.
- Nema globalnog `currentScenario`; UI kontekst je immutable widget input, a snapshot persistence je keyed po `predmetId`.
- Testovi istovremeno drže PREDMET A i B, potvrđuju različite UI rezimee, različite snapshot redove i različite scenario ID-jeve bez kontaminacije.

## 10. Promenjeni fajlovi

- `lib/features/predmeti/core_v2/scenario/owner_scenario_policy_kernel.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_module_repository.dart`
- `lib/features/predmeti/core_v2/scenario/scenario_module_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `test/owner_scenario_policy_kernel_test.dart`
- `test/scenario_module_repository_test.dart`
- `test/scenario_module_screen_test.dart`
- `test/scenario_owner_runtime_lifecycle_test.dart`
- `test/scenario_editable_business_policy_test.dart`
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- ovaj report

## 11. Validation gate

- `flutter analyze --no-pub`: **PASS**, exit 0, `No issues found` (32.5 s). Raniji pokušaj sa rokom 5 min je timeout i nije računat kao PASS; ponovljeni završni pokušaj je dao čist exit 0.
- Ciljani SCENARIO/PREDMET/KATALOG/IRiU skup: **PASS**, exit 0, 33 testa u objedinjenom završnom prolazu.
- Završni izmenjeni skup: **PASS**, exit 0, 19 testova.
- Strogi end-to-end regression fajl: **PASS**, exit 0, 3 testa.
- `git diff --check`: **PASS**, exit 0 (samo očekivana Git LF/CRLF upozorenja).
- Full `flutter test --no-pub`: **INCOMPLETE / nije pokrenut u ovom tasku**. Vlasnikov neposredni baseline dokaz pokazuje da je prethodni full suite trajao 22:47; task dozvoljava full suite samo kada može razumno završiti sa jasnim exit kodom. Nije proglašen PASS na osnovu istorijskog rezultata.

`BUILD NOT RUN — DEFERRED BY OWNER FOR CUMULATIVE RUNTIME BUILD`

## 12. Obavezni verdicti

- `LEGACY PARTIAL SCENARIO RUNTIME PATH — PROVEN INACTIVE`
- `LEGACY PARTIAL SCENARIO UI — REMOVED`
- `MAP KERNEL SOLE RUNTIME SCENARIO AUTHORITY — PASS`
- `TEST SCENARIO MAP SELECTION — PASS`
- `TEST SCENARIO MAP → IRiU — PASS`
- `ZAŠTITNA I DODATNA OPREMA REGRESSION — PASS`
- `INTERNAL MAP ID HIDDEN FROM USER UI — PASS`
- `APPLIED SCENARIO IS PREDMET-SCOPED — PASS`
- `MULTIPLE PREDMET STATE ISOLATION — PASS`
- `1008 MAP DEFINITIONS — PASS`
- `11-ITEM OSNOVNI PAKET — PASS`
- `FLUTTER ANALYZE — PASS`
- `TARGETED TESTS — PASS`
- `FULL FLUTTER TEST — INCOMPLETE`
- `BUILD — NOT RUN BY OWNER DECISION`
- `WINDOWS RUNTIME — DEFERRED TO CUMULATIVE BUILD`
