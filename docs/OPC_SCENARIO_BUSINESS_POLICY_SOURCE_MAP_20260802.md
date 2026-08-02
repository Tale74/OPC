# OPC — source mapa poslovne politike pre korekcije (2026-08-02)

Početna grana: `task/OPC-SCENARIO-UI-RUNTIME-MIGRATION`  
Početni SHA: `508f914330b6934b9b340b2bb1a3526434a5001e`

## Aktivni tok pre korekcije

`PREDMET` → `IriuSegment._runScenarioSync` → `ScenarioModuleRepository` →
`ScenarioRuleEngine.evaluate` → `IriuRepository.syncScenarioRows` → fizički
IRiU redovi → `PredmetIriuTruthService` → `IriuTruthRules` → UI, PDF,
STATISTIKA i `FinancialTruthService`.

Ovaj tok ima dve aktivne poslovne istine. `ScenarioRuleEngine` odlučuje koje
stavke postoje, dok `IriuTruthRules` ponovo, hardcoded, odlučuje da li su iste
stavke aktivne, preporučene, upozorene i finansijski uključene. UI pokreće
sinhronizaciju u `initState` i `didUpdateWidget`, a repository bez pitanja
briše SCENARIO redove koji više nisu željeni.

## Source mapa

| Poslovna odluka | Aktivna putanja / klasa i funkcija | Činjenice PREDMETA | Rezultat, status, upozorenje i provider | Redosled i finansije | Promena uslova / korisnička odluka | Dokaz |
|---|---|---|---|---|---|---|
| OSNOVNI PAKET | `ScenarioModules.osnovniPaketJson`; `ScenarioModuleRepository.read/saveOsnovniPaket`; `ScenarioRuleEngine.evaluate` | nema | kategorije postaju fizički redovi; nema data-driven statusa/provider-a | `IriuOrderingService` hardcoded; finansije ponovo tumači `IriuTruthRules` | SCENARIO-owned red se briše bez odluke | `scenario_module_repository.dart`, `iriu_repository.dart` |
| STAN | `assets/scenario_defaults.json` → repository → engine → sync | `mestoSmrti` | šest dodataka; svi se učitavaju kao `recommended` bez individualnih metapodataka | hardcoded ordering i truth | tiho uklanjanje | `MESTO_SMRTI_BLOK` |
| DOM ZA STARE | isto | `mestoSmrti` | isti paket kao STAN | isto | isto | default asset |
| PRIVATNA BOLNICA | isti objedinjeni default; dodatno normalizacija u `IriuTruthRules` | `mestoSmrti` | isti rezultat kao DOM, ali nije eksplicitno predstavljeno mapiranje scenarija | isto | isto | default asset, truth rules |
| DRUGO | isti objedinjeni default | `mestoSmrti` | isti rezultat kao DOM | isto | isto | default asset |
| ULICA / JAVNO MESTO | default + `normalizeMestoSmrti` | `mestoSmrti` | šest dodataka | isto | isto | default asset, truth rules |
| BOLNICA | `MESTO_SMRTI_BOLNICA` | `mestoSmrti` | samo `PREVOZ_DO_GROBLJA` | isto | isto | default asset |
| LIMENI ULOŽAK | `OPREMA_PREMA_USLOVU`; paralelno `_shouldAutoAddLimeniUlozak` | ceremonija, uzrok smrti, tip grobnog mesta | preporučeno; bez editabilnog provider/warning modela | hardcoded uz SANDUK bloku | legacy lifecycle čuva ručno brisanje, scenario sync ne koristi tu odluku | asset, `iriu_truth_rules.dart`, lifecycle service |
| LEMOVANJE | ista definicija, ali posebna hardcoded funkcija `_shouldAutoAddLemovanje` | isti ulazi | preporučeno; nema editabilnog provider-a | hardcoded | isto | asset, truth rules |
| Kremacija | negativan criterion u `OPREMA_PREMA_USLOVU`; ponovljeno u truth rules | `vrstaCeremonije` | ne preporučuje LIMENI/LEMOVANJE | finansijski ih suppressuje truth rules | postojeći red ostaje vidljiv, ali scenario sync može da ga obriše ako ga poseduje | asset, truth service |
| PREVOZ SPROVODA | `LOKALNO_GROBLJE`; paralelno `_shouldRecommendPrevozSprovoda` | `tipGroblja` | preporučeno | hardcoded redosled; uključeno samo kad truth kaže active | scenario sync briše bez odluke; legacy dismissal postoji odvojeno | asset, truth rules |
| OPELO | `OPELO`; paralelno `isOperationallyActive` | `opelo` | red se dodaje; truth nema recommended status iako specifikacija zahteva | hardcoded | tiho uklanjanje | asset, truth rules |
| BIOHAZARD | samo `BusinessPolicyEvaluator` snapshot + `IriuTruthRules.isBiohazard` | zarazna smrt i mesto nije bolnica | upozorenje na SPREMANJE; nije editabilni scenario podatak | ne menja order; finansije indirektno | nema posebne sačuvane odluke | evaluator, truth service/rules |
| Međunarodne stavke | `SAHRANA_VAN_SRBIJE`; paralelno truth rules | `sahranaVanSrbije` | prevoz, dokumentacija, balsamovanje | hardcoded order i financial active | tiho uklanjanje | asset, truth rules |
| Cargo | `DOCEK_POSMRTNIH_OSTATAKA`; paralelno truth rules | `docekPosmrtnihOstataka` | cargo troškovi | hardcoded order i financial active | tiho uklanjanje | asset, truth rules |
| Status | consequence action u Scenario modelu, ali sync ga ne materijalizuje; `IriuTruthRules.isRecommended` odlučuje ponovo | više činjenica | samo tri hardcoded preporuke | status ne upravlja redosledom | nije sačuvan kao autoritativni rezultat | scenario contract, truth rules |
| Provider | nije modelovan | — | FIRMA/druga služba/napomena nisu runtime podaci | — | — | nedostaje u contract-u i persistence-u |
| Ordering | `IriuOrderingService._systemCategoryOrder` | kategorija reda | fizički redosled | potpuno hardcoded, ne čita scenario `order` | ponovna aktivacija rebuild-uje sve sistemske kategorije; ručni redovi ostaju iza njih | ordering service |
| Finansijsko uključivanje | `FinansijeSegment` → `PredmetIriuTruthService` → `IriuTruthRules.countsForFinancialTruth` → `FinancialTruthService` | hardcoded active + iznos | uključuje aktivan red sa pozitivnim iznosom | paralelna interpretacija izvan scenario evaluacije | zavisi od hardcoded suppress stanja | financial/truth services |
| Promena uslova | `IriuSegment.didUpdateWidget` → `_runScenarioSync` | mesto, groblje, uzrok, ceremonija, međunarodno, cargo, opelo | odmah usklađuje redove | rebuild order | `syncScenarioRows` briše scenario-owned red bez pitanja | UI handler + repository |
| Korisnička odluka | `iriu_lifecycle_decisions` samo za stari mesto/blok2 lane; Scenario sync ga ne čita | ručno brisanje | odluka opstaje za legacy lane, ne za novi scenario lane | — | paralelni, nepotpuni persistence | repository lifecycle helpers |

## Nalazi koji blokiraju jedinstveni autoritet

- OSNOVNI PAKET je prazan zato što `ScenarioModules.osnovniPaketJson` ima
  podrazumevano `[]`, a `ensureModuleAndDefaults` seeduje samo definicije.
- `ScenarioRuleEngine` i `IriuTruthRules` odlučuju o istim kategorijama.
- Status, upozorenje, provider i finansijsko uključivanje nisu deo sačuvanog
  scenario consequence modela.
- Poslovni redosled se ignoriše pri sync-u i ponovo hardcoduje.
- `IriuSegment` je UI-driven trigger poslovne mutacije.
- `syncScenarioRows` automatski briše SCENARIO-owned redove; snack bar stiže
  tek posle brisanja i nije korisnička odluka.
- Stari `MestoSmrtiIriuLifecycleService` i `Blok2IriuLifecycleService` ostaju
  prisutni i testirani; produkcijski pozivi su zamenjeni scenario sync-om, ali
  njihove hardcoded odluke i dalje napajaju truth lane preko `IriuTruthRules`.
- `BusinessPolicyEvaluator` je međusloj koji i dalje računa hardcoded booleane,
  dok `PredmetIriuTruthService` assertion-ima proverava paritet sa drugom
  hardcoded implementacijom.
- `PredmetScenarioSnapshots` i application/reconciliation contract postoje,
  ali nisu povezani sa aktivnim sync transakcijama.

Stop-uslovi nisu aktivirani: stabilni identifikatori kategorija postoje,
aktivni poslednji writer je dokaziv, postojeći redovi i korisničke odluke mogu
se sačuvati bez migracionog gubitka, a korekcija ostaje u SCENARIO/IRiU domenu.
