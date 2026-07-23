# OPC — revised authoritative dependency-based development plan

**Status:** DRAFT – FINAL OWNER REVIEW REQUIRED
**Autoritativnost:** Ovaj dokument još nije autoritativan. Ne odobrava implementaciju i ne postaje deo autoritativnog OPC dokumentacionog skupa dok Tale eksplicitno ne odobri njegov sadržaj.
**Revision base branch:** `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-OWNER-REVIEW-FINDINGS`
**Revision base SHA:** `5734eee9c952bf67458727ca26203bacc0a1cf6a`
**Revision branch:** `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-REVISION`
**Datum revizije:** 23. jul 2026.
**Ugrađeni review nalazi:** F-01–F-12 iz `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_OWNER_REVIEW_FINDINGS.md`
**ARC–T.A.R.S.:** Definiši, ugradi, potvrdi, zapamti.

## 1. Svrha plana

Ovaj plan određuje zavisnosni i kontrolni red daljeg razvoja OPC-a. Redosled nije kalendar niti automatska autorizacija narednog taska. Svaki program počinje dokazima, razdvaja dijagnostiku od implementacije i završava tehničkom, owner-runtime i dokumentacionom kapijom.

Plan ima pet ciljeva:

1. sačuvati PREDMET kao jedinu autoritativnu poslovnu istinu;
2. stabilizovati i dovršiti aktuelne Windows i Android aplikacije za tržište Srbije;
3. doneti ranu, dokazima zasnovanu odluku o targeted korekcijama, progresivnom refactoru, parcijalnom ili potpunom rewrite-u;
4. izgraditi korisnički konfigurabilan SCENARIO bez retroaktivne promene istorijske istine;
5. tek posle stabilizacije Srbije odlučiti i graditi buduću multilingual product line.

## 2. Verifikovani baseline i review izvori

### 2.1 Source i Git baseline

Plan je revidiran sa:

- source/review lineage HEAD: `5734eee9c952bf67458727ca26203bacc0a1cf6a`;
- review-findings branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-OWNER-REVIEW-FINDINGS`;
- potvrđenim čistim worktree-om;
- identičnim lokalnim i origin HEAD-om;
- divergencijom `0/0`.

Operativni development lineage trenutno je na task granama. Javni `main` nije automatski pretpostavljen kao aktuelni source HEAD.

### 2.2 Obavezni review dokumenti

- `docs/OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_DRAFT.md`
- `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_OWNER_REVIEW_PREPARATION_REPORT.md`
- `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_OWNER_REVIEW_FINDINGS.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`

Relevantni lokalni `PROJECT_DOCS` i restore/audit izvori ostaju supporting/historical evidence. Nisu automatski autoritet i nisu javno kopirani.

## 3. Dokumentacioni authority model

### 3.1 Trenutna hijerarhija

Do nove owner odluke:

1. Git-verzionisani current dokumenti u `docs/` određuju aktivni javni continuity baseline.
2. Source kod, testovi i platform folderi dokazuju trenutno implementaciono ponašanje.
3. Najnoviji task report pobeđuje samo unutar sopstvenog potvrđenog scope-a.
4. Lokalni `PROJECT_DOCS` i restore-point materijal pružaju istoriju i kontekst.
5. Nova owner odluka superseduje stariji konfliktni dokument tek kada je zapisana i Git-dostupna.

### 3.2 Klasifikovani postojeći konflikti

| Konflikt | Trenutni status | Pravilo ovog plana |
| --- | --- | --- |
| `main` kao stabilni baseline naspram stacked task lineage-a | OPEN GOVERNANCE DECISION | Ne pretpostavljati `main` kao operativni HEAD; rešiti u Gate 0. |
| Lokalni “Master PROJECT_DOCS” naspram Git source-of-truth mape | CLASSIFIED, NOT DELETED | Git docs vode current continuity; lokalni dokumenti ostaju supporting dok owner ne odobri promociju. |
| Istorijska odluka da Git ne postoji/ne treba da postoji | SUPERSEDED BY ACTUAL GIT FLOW | Sačuvati kao istoriju, ne primenjivati na novi rad. |
| Package/licensing-era pravila naspram odluke o napuštanju PAKETA | SUPERSEDED FOR CURRENT PRODUCT | Stage 1 politika važi; Stage 2 ostaje kasniji cleanup. |
| Schema 21 closure zapis naspram current schema 22 | DOCUMENTATION CLARIFICATION REQUIRED, NO MISSING CURRENT MIGRATION PROVEN | Pre nove migracije precizirati historical/current formulaciju. |

### 3.3 Semantic parity pravilo

Dokumentaciona usklađenost znači:

- isti business meaning;
- isti owner-decision status;
- isti dependency i acceptance sadržaj;
- kontrolisani source-specific metadata;
- evidentirane sanitizacione i environment razlike.

Byte-identičnost i SHA-256 paritet zahtevaju se samo kada su tehnički mogući i privacy-bezbedni. Kada Git i lokalni dokument opravdano imaju različite putanje, manifest podatke, environment reference ili sanitizaciju:

- oba dokumenta nose isti document ID/verziju;
- reconciliation registar beleži oba hash-a;
- razlog transformacije je eksplicitan;
- sadržinska ekvivalencija se proverava;
- javni dokument nikada ne otkriva privatnu putanju, korisničko ime, tajnu ili runtime podatak radi byte-pariteta.

## 4. Trajne arhitektonske i owner konstante

### 4.1 PREDMET i derivati

- PREDMET je jedina autoritativna poslovna istina.
- PDF, DOCX, JSON, PODSETNIK, PARTE, NALOG CVEĆARI, IRiU prikazi, statistike i drugi izlazi ostaju derivati ili operativni slojevi.
- Derivat ne sme postati paralelni master.
- KATALOG je dopuna znanja; kasnija KATALOG promena ne prepisuje istorijsku PREDMET istinu.

### 4.2 SCENARIO

- SCENARIO je deo svakog konkretnog PREDMETA.
- FIRMA podešavanja daju scenario templates/defaults za nove PREDMETE.
- Kasnija promena FIRMA template-a, default-a ili business policy-ja ne menja istorijski zaključan PREDMET.
- Dozvoljeni nezavršeni PREDMET scenario menja samo eksplicitnom korisničkom radnjom i bezbednim IRiU reconciliation-om.
- Fizička reprezentacija istorijski stabilnog scenario state-a nije unapred zaključana.

### 4.3 Postojeći scenariji

Postojeći hard-coded scenariji nisu trajno zaštićeni ili neizmenljivi sistemski scenariji.

Posle audita i korekcije:

- svaki postojeći scenario postaje potpuno korisnički izmenjiv kroz PODEŠAVANJA;
- korisnik može da kreira novi scenario;
- template može da se sačuva, uveze i izveze;
- pojedinačni scenario može biti FIRMA default;
- kompletan FIRMA scenario set može biti sačuvan i primenjen kao default konfiguracija;
- postojeći scenariji mogu biti početni sadržaj, ali ne ostaju zaključani.

Obavezne prethodne korekcije:

- `JAVNO MESTO/NEDEFINISANO`;
- nedostajući `MESTO CEREMONIJE` za smeštaj/polaganje urne;
- zastareli ili nepotrebni IRiU redovi posle promene uslova.

### 4.4 Platforme i podaci

- Windows i Android su ravnopravne, samostalne lokalne aplikacije.
- Svaka koristi lokalni SQLite/Drift model i postojeći JSON interchange.
- OS mehanizam može biti različit; business i data rezultat mora biti ekvivalentan.
- Ne uvodi se obavezni network sync.
- OPC Web ostaje van current implementation scope-a.

### 4.5 PAKETI i licensing

- PAKETI su trajno napušteni za sadašnji proizvod.
- Stage 1 uklanjanja runtime ograničenja je završen.
- Stage 2 fizičko uklanjanje mrtvog licensing/package koda je poseban kasniji task.
- Stage 2 ne blokira stabilizaciju ili zadržavanje OPC Srbija.
- Budući kupac eventualni licensing vraća kroz čiste module/capability extension boundaries, dokumentovan istorijski model i Git istoriju, ne kroz mrtav runtime kod.

### 4.6 Dokumenti, statusi i teme

- Single-PREDMET JSON export pripada PREDMET trotačka meniju, ne `DOKUMENTA`.
- Automatski `ZAVRŠEN` se napušta posle eksplicitne lifecycle odluke.
- Completion signali su izračunati derivati PREDMETA/IRiU, nikada novo skladišteno business truth stanje.
- Standardni PDF dokumenti osim PARTE menjaju tipografiju dokument po dokument.
- PDF RAČUN dobija prost FIRMA availability toggle.
- Nema PDV obračuna, fiskalizacije ili automatskog legal-form zaključivanja.
- Windows prati system theme kao Android gde je tehnički moguće.
- Windows-only theme selector zahteva dokazanu tehničku prepreku i posebnu owner odluku.

### 4.7 Lokalizacija i valute

- Albanski je isključen.
- Multilingual razmatra srpski latinicu, srpski ćirilicu, hrvatski, bosanski, slovenački, crnogorski, makedonski, mađarski, rumunski, bugarski, nemački i engleski.
- UI jezik, pismo, country profile, business policy, dokumenti, KATALOG, scenario i valuta ostaju odvojeni koncepti.
- Multicurrency readiness ne odobrava PDV, porez ili fiskalizaciju.

## 5. Dependency principi

Redosled određuju:

1. dokumentacioni autoritet;
2. rizik gubitka ili nekonzistentnosti podataka;
3. migracioni i JSON rizik;
4. arhitektonska zavisnost i cena rework-a;
5. poslovni smisao i owner odluka;
6. Windows/Android parity;
7. merljivost tehničkog rezultata;
8. owner runtime acceptance;
9. product-line odluke.

Audit koji ne menja stanje može početi ranije kada ne preskače source-learning ili owner gate. Implementacija ne može početi samo zato što je stavka navedena u planu.

## 6. Obavezni lifecycle svakog audit/implementation područja

Svaka velika oblast mora imati odvojene korake.

### 6.1 Dokumentacioni i source-learning audit

- pročitati current Git dokumente, latest report i relevantne lokalne izvore;
- evidentirati source commit;
- mapirati PREDMET/SCENARIO/IRiU/JSON/parity posledice;
- klasifikovati konflikt, bez tihog rešavanja.

### 6.2 Reprodukcija i dijagnostika

- ponovljiv fixture i okruženje;
- observed/expected rezultat;
- source-supported root-cause hipoteza;
- dokaz ili odbacivanje hipoteze;
- bez promene produkcionih podataka.

### 6.3 Owner/architecture decision gate

Obavezan kada nalaz menja:

- poslovno pravilo;
- lifecycle;
- migraciju;
- PREDMET authority;
- scenario istoriju;
- platform parity;
- product identity;
- dokumentacioni/Git governance.

### 6.4 Implementaciona autorizacija

Mora imati:

- tačan scope;
- out-of-scope;
- migracioni/backup plan;
- acceptance kriterijume;
- stop uslove;
- eksplicitno owner odobrenje kada je zahtevano.

### 6.5 Tehnička potvrda

- fokusirani testovi;
- `flutter analyze --no-pub` do finalnog PASS-a;
- tek zatim kompletan `flutter test --no-pub` do finalnog PASS-a;
- buildovi tek uz owner odobrenje;
- Windows/Android buildovi sukcesivno.

### 6.6 Owner runtime acceptance

- odvojeno od tehničkog PASS-a;
- odvojeno po platformi;
- koristi dogovoreni realni poslovni scenario;
- fizički/štampani rezultat gde je relevantan.

### 6.7 Dokumentacioni closure

- task report;
- owner odluka/status;
- source HEAD i final SHA;
- semantic-parity sync;
- migration/JSON/pseudocode/manifest update gde je relevantan;
- CODEX → GIT completion gate.

## 7. Gate 0 — documentation reconciliation i Git governance

Nijedan novi implementation task ne počinje pre Gate 0 closure-a.

### 7.1 Obavezni izlazi

- owner review ovog revised draft-a;
- odluka o F-01–F-12 integraciji;
- formalni operational development HEAD;
- Git/main/integration politika;
- dokumentacioni authority i semantic-parity pravilo;
- klasifikovani historical/superseded konflikti;
- finalni owner-odobren plan;
- usklađeni Git i lokalni dokumentacioni zapis tek posle odobrenja.

### 7.2 Git/main governance odluka

Owner mora izabrati i dokumentovati:

- kako se tretiraju stacked task branches;
- koja grana/commit je operational development head;
- koja grana je release baseline;
- da li i kada `main` postaje current;
- merge, consolidation ili release-branch strategiju;
- kako se čuvaju historical task branches;
- kako odobreni dokument stiže u authoritative branch;
- kako future audit nalazi tačan source HEAD;
- kako se sprečava grananje sa zastarelog baseline-a.

Dok ova odluka nije doneta:

- task ne sme pretpostaviti da je public `main` source truth;
- mora navesti exact base branch/SHA;
- stacked lineage se ne prepisuje niti briše;
- Git-history rewrite je zabranjen.

## 8. Phase 1 — minimum evidence pre Architecture Decision Gate-a

Phase 1 prvenstveno prikuplja dokaze. Ne autorizuje automatski korekcije.

### 8.1 PODSETNIK orphan i OS notification lifecycle

**Audit/diagnosis:**

- reprodukovati brisanje, anonimizaciju i restart;
- proveriti DB cascade, sačuvane notification IDs i OS scheduler;
- proveriti već zakazane i već isporučene notifikacije;
- potvrditi ili odbaciti prijavljeni root-cause kandidat;
- proveriti Windows in-app i Android OS mehanizam.

**Emergency integrity gate:**

Ako je potvrđen uzak data/lifecycle kvar koji ne zahteva novu arhitekturu ili migraciju, owner može odobriti minimalnu korekciju pre opšte Architecture Decision Gate odluke. U suprotnom implementacija čeka Gate.

### 8.2 Windows multiple-instance — data-integrity prioritet

Odvojiti:

1. reprodukciju više instanci;
2. audit concurrent pristupa SQLite bazi;
3. isti-PREDMET write scenario;
4. migration/startup race;
5. import/export i output overwrite;
6. architecture odluku o single-instance/IPC/focus ponašanju;
7. implementaciju;
8. owner runtime acceptance.

Multiple-instance zaštita je viši prioritet od ordinary startup UX-a.

### 8.3 Windows startup performance — povezano, ali zasebno

Ne pretpostaviti uzrok. Meriti:

- cold i warm start;
- process start;
- window creation;
- config/locale;
- DB open/migration;
- KATALOG/reminder init;
- first usable screen.

Korekcija sledi tek posle baseline-a i owner-odobrenog cilja.

### 8.4 Android MODULI PARTE performance

Profilisati:

- module open;
- text edit;
- block drag;
- canvas pan/zoom;
- repaint;
- media;
- preview;
- narrow i wide layout;
- reprezentativan slabiji i srednji uređaj/hardware class.

PARTE audit ne otvara redizajn i ne menja owner-prihvaćen PDF rezultat.

### 8.5 Scenario/IRiU audit

- popisati sve hard-coded scenario family/uslove;
- reprodukovati `JAVNO MESTO/NEDEFINISANO`;
- mapirati urn placement i `MESTO CEREMONIJE`;
- klasifikovati managed/manual IRiU redove;
- reprodukovati stale-row ponašanje;
- mapirati scenario → PREDMET → IRiU → dokumenti → completion signali;
- utvrditi current scenario ID/version/storage/JSON ponašanje;
- karakterizovati postojeće baze.

### 8.6 Full code architecture i UI/UX audit

Obuhvatiti:

- PREDMET domain;
- repositories i Drift/SQLite;
- migracije i recovery;
- JSON import/export;
- scenario/business-policy sloj;
- legacy/`core_v2` odnos;
- veliki presentation/util/database fajlovi;
- navigation/state/error handling;
- module boundaries;
- KATALOG i derivati;
- reminders;
- PDF/DOCX pipeline;
- Windows/Android platform adapters;
- Android narrow, Android wide i Windows UI/UX;
- testabilnost i characterization gaps;
- product-profile readiness.

### 8.7 Migration i product-profile readiness audit

- historical schema 1–22;
- canonical DB policy;
- JSON schemas i previously distributed versions;
- FIRMA/scenario persistence opcije;
- Serbia/multilingual separation;
- one-core/profiles/branches/flavors/modules opcije;
- signing/release identity posledice.

## 9. Architecture / refactor / rewrite Decision Gate

Ovaj gate dolazi posle minimalnih Phase 1 dokaza i pre velikog scenario/configuration ili modularnog implementacionog rada.

### 9.1 Opcije koje se porede

| Opcija | Kada je opravdana | Glavni rizik | Dokaz potreban |
| --- | --- | --- | --- |
| Targeted corrections | Uzak potvrđen kvar, stabilna granica | Dug tehnički dug ostaje | Reprodukcija, focused test, minimal diff |
| Progressive refactor | Postojeći domain/data core je očuviv | Privremeni adapteri i duži prelaz | Characterization, module map, parity dokaz |
| Partial subsystem rewrite | Izolovan podsistem ne može bezbedno da evoluira | Compatibility/migration granica | Jasni ugovori, rollback, coexistence plan |
| Partial scenario/configuration rewrite | Current hard-coded evaluator ne može dati user-editable policy bez nove granice | PREDMET history i IRiU migration | Scenario audit, persistence comparison, JSON/migration fixtures |
| Full rewrite | Postojeća osnova dokazivo sprečava stabilnost, parity ili evoluciju | Najveći data/migration/runtime rizik | Potpuna cost/risk analiza, canonical migration proof, rollback i owner odluka |

### 9.2 Trenutna provisional preporuka

`RETAIN CURRENT CORE → TARGETED INTEGRITY FIXES → PROGRESSIVE REFACTOR → BOUNDED PARTIAL REWRITE WHERE PROVEN`

Full rewrite nije pretpostavljen. Gate može promeniti preporuku samo dokazima.

### 9.3 Scenario persistence opcije

Gate poredi najmanje:

- kopirane/verzionisane scenario podatke;
- immutable scenario version reference;
- normalizovani PREDMET-owned scenario state;
- hibridni state/provenance model;
- drugi evidence-supported model.

Obavezni ishod, nezavisno od fizičkog modela:

- PREDMET samorazrešivo čuva scenario/business context koji je važio;
- završeni/istorijski zaključan PREDMET ostaje stabilan;
- FIRMA template promena ne menja postojeću istoriju;
- JSON/migracija ostaju kompatibilni;
- Windows i Android identično tumače stanje.

### 9.4 Gate odluke

Owner potvrđuje:

- architecture option;
- scenario persistence model;
- migration strategiju;
- module/refactor granice;
- koje minimalne integrity korekcije mogu prethoditi većem refactoru.

## 10. Phase 2 — potvrđene integrity i performance korekcije

Svaka stavka koristi lifecycle iz odeljka 6.

### 10.1 PODSETNIK orphan korekcija

Samo posle potvrđene dijagnoze:

- atomic/compensating deletion lifecycle;
- cancel pre gubitka notification IDs ili drugi dokazivo bezbedan red;
- idempotent retry;
- recovery za ranije orphan payload-e;
- nema gubitka validnog PREDMETA;
- Windows/Android ekvivalentan business rezultat.

### 10.2 Windows multiple-instance zaštita

Samo posle architecture odluke:

- sprečiti concurrent data mutation;
- bezbedno fokusirati/proslediti launch postojećoj instanci gde je odobreno;
- fail-safe migration/import/export ponašanje;
- isti-PREDMET i output collision testovi;
- owner runtime acceptance.

### 10.3 Startup korekcija

Menjati samo dokazane bottleneck-e. Single-instance i startup mogu deliti platform infrastrukturu, ali imaju odvojene acceptance rezultate.

### 10.4 Android PARTE performance korekcija

Najmanji dokazani rendering/state zahvat, bez promene:

- PREDMET/IRiU boundary-ja;
- editor business ponašanja;
- PDF/DOCX formation pravila;
- owner-prihvaćenog vizuelnog rezultata.

## 11. Merljiva performance acceptance

Za Windows startup i Android PARTE task mora zapisati:

- referentni uređaj ili hardware class;
- OS verziju;
- release build variant;
- canonical-like izolovanu bazu/fixture;
- reprezentativni PREDMET i PARTE sadržaj;
- broj ponavljanja;
- cold/warm razliku;
- pre-change baseline;
- proposed target;
- owner odobren target pre implementation acceptance;
- post-change rezultat;
- owner-perceived runtime nalaz.

### 11.1 Windows minimum metrike

- process start → first window;
- process start → first usable screen;
- DB open/migration trajanje;
- cold median i raspon;
- warm median i raspon;
- single-instance second-launch ponašanje.

### 11.2 Android PARTE minimum metrike

- module-open latency;
- frame/render profiling;
- jank/missed-frame evidence;
- drag/pan/zoom interaction;
- media-heavy fixture;
- narrow/wide;
- najmanje jedna slabija i jedna srednja hardware class.

Plan ne izmišlja numeričke pragove bez baseline-a. Audit predlaže prag; owner ga potvrđuje.

## 12. Phase 3 — PREDMET lifecycle i sadašnji scenario defects

### 12.1 Historical/completed PREDMET owner gate

Pre status ili scenario implementacije owner odlučuje ponašanje za:

- otvoren PREDMET;
- završen PREDMET;
- zatvoren PREDMET ako source razlikuje taj status;
- anonimizovan PREDMET;
- obrisan PREDMET;
- istorijski auto-završen PREDMET;
- drugi source-defined locked state.

Owner mora odlučiti:

- koji status aktivira istorijski lock;
- odnos `ZATVOREN`/`ZAVRŠEN`;
- reverzibilnost;
- dozvoljeni correction/reopen izuzetak, ako postoji;
- ko ga pokreće i kakav audit trag ostavlja;
- reminders, editovanje, dokumenti i scenario posledice;
- legacy auto-completed tretman.

Invariant:

Kasnija FIRMA scenario/KATALOG/default/business-policy promena ne menja istorijsku poslovnu istinu zaključanog PREDMETA.

### 12.2 Uklanjanje automatskog `ZAVRŠEN`

- eksplicitna korisnička radnja;
- confirmation i lifecycle guard;
- bez anonimizacionih/destruktivnih posledica;
- legacy/import kompatibilnost;
- owner runtime provera.

### 12.3 Korekcija sadašnjih scenario defects

Pre user-configurable engine-a:

- `JAVNO MESTO/NEDEFINISANO`;
- `MESTO CEREMONIJE` za urnu;
- stale/nepotrebni IRiU redovi;
- safe keep/remove/archive/merge;
- očuvanje user cena, količina i napomena;
- preview i potvrda kada je sadržaj ugrožen;
- idempotent reconciliation.

## 13. Migration, backup i restore pravila

Svaka schema ili data migracija mora:

1. koristiti izolovanu kopiju, nikada jedini canonical fajl;
2. napraviti SQLite-consistent backup pre otvaranja realne ili verified canonical kopije;
3. dokazati da je backup čitljiv;
4. koristiti realistične historical schema fixtures;
5. uključiti partial-migration state fixtures;
6. dokazati idempotency i bezbedan retry;
7. sačuvati row counts i reprezentativne poslovne vrednosti;
8. dokazati JSON round-trip za Windows i Android gde je relevantan;
9. izvesti restore rehearsal i dokazati da se backup stvarno vraća;
10. definisati rollback ili forward-fix pravilo;
11. zabraniti merge test baze u canonical user bazu;
12. zahtevati owner autorizaciju pre live canonical upgrade-a.

Schema verzija nije business authority. Existing user database ostaje korisnikova istina.

## 14. Phase 4 — korisnički konfigurabilni SCENARIO

Počinje tek posle Architecture Decision Gate-a i Phase 3 korekcija.

### 14.1 Domain/data ugovor

- owner-odobren persistence model;
- stable ID i version/provenance;
- PREDMET-owned historically stable scenario state;
- FIRMA templates/defaults;
- individualni i kompletni default set;
- prospective application;
- migration/JSON contracts;
- Windows/Android identično tumačenje.

### 14.2 PODEŠAVANJA

- prikaz svih korigovanih postojećih scenarija;
- puna user editability;
- create/copy/save;
- import/export;
- individualni default;
- complete FIRMA default set;
- validation kontradikcija;
- Android narrow/wide/Windows parity.

### 14.3 Promena scenarija postojećeg PREDMETA

Samo za lifecycle-eligible PREDMET:

- eksplicitna akcija;
- old/new diff;
- IRiU consequence preview;
- keep/remove/archive/merge odluka;
- atomic transaction ili dokazivo bezbedan compensation plan;
- provenance/audit;
- nikada automatski za istorijski zaključan PREDMET.

## 15. Phase 5 — dovršavanje postojećih funkcija

### 15.1 PODSETNIK model i notifications

Posle orphan i lifecycle korekcija:

- active/due/missed/completed/cancelled model;
- closed-app delivery;
- restart/reboot recovery;
- permission denied;
- no duplicates;
- tap vodi samo na postojeći PREDMET;
- Windows i Android jednaka poslovna funkcija uz različit OS mehanizam gde je potrebno.

### 15.2 Completion signali

- narandžasto prazno;
- žuto delimično;
- zeleno potpuno;
- ikona/tekst pored boje;
- scenario-dependent relevantna polja;
- N/A i opciona polja;
- izračunato iz PREDMETA/IRiU;
- nema paralelnog skladištenog truth statusa.

### 15.3 Single-PREDMET JSON relokacija

- premeštanje u trotačka meni PREDMETA;
- ista schema;
- legacy import;
- Windows/Android interchange;
- odvojeno od full backup/database JSON.

### 15.4 NALOG CVEĆARI

- source/business inventory;
- PREDMET/IRiU input map;
- owner definisan sadržaj;
- PDF i eventualni DOCX scope;
- boundary fixtures;
- owner acceptance.

### 15.5 Standardni PDF typography

PARTE je van scope-a.

Za svaki dokument:

- current layout/font inventar;
- minimal/normal/max fixtures;
- kontrolisano malo povećanje;
- bez overflow-a, truncation-a ili promene formation pravila;
- render diff;
- owner vizuelna i, gde treba, štampana provera.

### 15.6 PDF RAČUN FIRMA toggle

- availability only;
- nema PDV/tax/fiscal/legal inference-a;
- ne menja PREDMET/IRiU;
- ne briše postojeće fajlove;
- migration default za postojeće instalacije zahteva owner odluku.

### 15.7 Windows system theme

- proveriti postojeći `ThemeMode.system`;
- runtime theme change, kontrast i accessibility;
- PDF/DOCX output ostaje nezavisan;
- Windows-only selector samo posle dokazane prepreke i owner odluke.

## 16. Phase 6 — progressive refactor i cross-platform UX

Samo u granicama odobrenim Architecture Decision Gate-om:

- razdvajanje velikih presentation fajlova;
- JSON serialization/validation/IO/orchestration granice;
- database schema/migration/domain separacija gde je bezbedna;
- legacy/`core_v2` convergence;
- adapters tokom prelaza;
- characterization pre zamene;
- Android narrow/wide/Windows UX korekcije;
- keyboard/mouse/touch/accessibility parity.

Partial rewrite je dozvoljen samo za dokazano izolovan subsystem sa compatibility i rollback ugovorom.

## 17. First product-line gate — OPC Srbija

Posle potrebnih audita i korekcija owner odlučuje stabilnu OPC Srbija product line.

Mora sačuvati:

- Windows i Android;
- srpski latinicu;
- srpski ćirilicu;
- standalone lokalni rad;
- SQLite;
- JSON interchange;
- PREDMET authority;
- scenario istoriju;
- Windows/Android business parity;
- canonical database kompatibilnost.

Gate zahteva:

- regression evidence;
- backup/restore rehearsal;
- odvojeni Windows/Android runtime acceptance;
- known issues/technical debt;
- app identity, versioning i update-channel odluku;
- release baseline commit/tag/branch odluku.

Stage 2 licensing cleanup nije predecessor ovog gate-a.

## 18. Stage 2 package/licensing cleanup

Stage 2 može početi posle module-boundary audita i odgovarajuće owner autorizacije. Može biti pre ili posle Serbia gate-a samo ako konkretna zavisnost to opravda; po default-u ga ne blokira.

Ukloniti:

- mrtav runtime licensing/package kod;
- bypass ostatke;
- neaktivne restrikcije;
- stare tajne/ključeve ako bi postojali u runtime scope-u;
- misleading uslove.

Sačuvati:

- clean module boundaries;
- opravdane capability/extension boundaries;
- historical model kao sanitizovanu dokumentaciju;
- Git istoriju;
- mogućnost budućeg spoljnog komercijalnog sloja.

## 19. Second product-line gate — multilingual version

Počinje tek kada OPC Srbija gate bude zatvoren.

### 19.1 Obavezna podrška

- srpski latinica;
- srpski ćirilica.

### 19.2 Jezici za razmatranje

- hrvatski;
- bosanski;
- slovenački;
- crnogorski;
- makedonski;
- mađarski;
- rumunski;
- bugarski;
- nemački;
- engleski.

Albanski je isključen.

### 19.3 Arhitektonske opcije

Audit poredi:

- jedan shared core + profiles;
- flavors;
- modules;
- release branches;
- drugi evidence-supported model.

Dugoročno divergentni domain/migration forkovi nisu default preporuka.

Odvojiti:

- UI language;
- script;
- country profile;
- business policy;
- documents;
- KATALOG;
- scenarios;
- currencies.

### 19.4 Multicurrency readiness

- FIRMA base currency;
- PREDMET/stavka valuta;
- originalni i preračunati iznos;
- kurs, datum, izvor i rounding;
- IRiU/dokument/JSON prikaz;
- dual-currency country profile.

Nema PDV-a, poreza ili fiskalizacije bez nove owner odluke.

## 20. Signing i professional handover closure

### 20.1 Android

- production application ID;
- release keystore;
- update continuity;
- backup/custody/recovery;
- publisher transfer plan.

### 20.2 Windows

- executable/installer signing;
- publisher identity;
- certificate/timestamp;
- key custody;
- transfer implications.

### 20.3 Handover paket

- product/domain/architecture;
- source-of-truth;
- DB/migrations/JSON;
- module map;
- build/release/signing;
- dependencies/licences/assets;
- privacy/security;
- tests;
- known issues/technical debt;
- ADR/pseudocode/runbook;
- owner decisions i development history.

## 21. Owner decision queue

Queue sadrži samo nerešene odluke.

### Pre autoritativnog usvajanja plana

1. Git/main/integration model i formalni operational/release baseline.
2. Odobrenje ovog revised dependency reda.

### Posle Phase 1 audita, pre relevantne implementacije

3. Architecture option: targeted/progressive/partial/full.
4. Scenario persistence model.
5. `ZATVOREN`/`ZAVRŠEN` i historical-lock lifecycle, uključujući eventualni correction/reopen izuzetak.
6. Tretman istorijski auto-završenih PREDMETA.
7. IRiU keep/remove/archive/merge pravila.
8. Windows startup i Android PARTE merljivi targeti.

### Pre odgovarajućih funkcionalnih/product taskova

9. PDF RAČUN toggle migration default za postojeće instalacije.
10. Poslovni sadržaj i PDF/DOCX scope NALOGA CVEĆARI.
11. OPC Srbija app identity, versioning i update kanal.
12. Multilingual product architecture i release identity.
13. Currency-rate model; bez odluke nema automatskog spoljnog kursa.
14. Publisher i signing-key custody/transfer model.

Već zaključane owner odluke iz odeljka 4 ne vraćaju se u queue.

## 22. Stop uslovi

Rad mora stati kada:

- source/Git baseline nije dokaziv;
- current owner odluke su u nerešivom konfliktu;
- task pretpostavlja `main` bez governance odluke;
- audit se pretvara u neautorizovanu implementaciju;
- root-cause hipoteza se tretira kao potvrđen uzrok;
- promena ugrožava PREDMET authority;
- završeni PREDMET bi retroaktivno promenio scenario/KATALOG/business policy;
- IRiU reconciliation može tiho izgubiti validan user sadržaj;
- migracija nema isolated copy, backup, restore rehearsal i recovery dokaz;
- test baza bi bila spojena u canonical bazu;
- JSON compatibility ili Windows/Android parity ne mogu biti sačuvani;
- full rewrite nema cost/migration/rollback dokaz;
- Stage 2 vraća package restrikcije;
- scope uvodi Web, PDV, porez ili fiskalizaciju;
- javni dokument bi otkrio privatnu putanju, identitet, tajnu ili runtime podatak;
- technical PASS se predstavlja kao owner runtime acceptance.

## 23. Pravila izmene plana

Plan se menja samo kroz Git documentation task koji navodi:

- base i final SHA;
- razlog i source evidence;
- affected dependency;
- owner decision status;
- migration/parity/PREDMET uticaj;
- change matrix;
- semantic-parity dokumentacioni update;
- CODEX → GIT completion gate.

Nijedna preporuka ne postaje owner odluka samo zato što je upisana u plan.

## 24. Kriterijumi za autoritativno proglašenje

Plan postaje autoritativan tek kada:

1. Tale eksplicitno odobri revised sadržaj i dependency red;
2. owner odluka o Git/main governance-u bude zapisana ili jasno označena kao pre-implementation gate;
3. otvoreni queue ostane jasno odvojen od zaključanih odluka;
4. nema P0 findings bez resolution-a;
5. finalni plan dobije novi naziv bez `DRAFT`;
6. Git i lokalni dokumentacioni izvori budu semantički usklađeni;
7. kontrolisane razlike i hash-evi budu evidentirani;
8. autoritativni manifest/source-of-truth dokumenti budu ažurirani posebnim owner-odobrenim documentation taskom;
9. branch/commit/report budu pushovani;
10. worktree i origin budu usklađeni.

Do tada status ostaje:

`DRAFT – FINAL OWNER REVIEW REQUIRED`

## 25. Jednolinijski dependency red

**Gate 0 documentation/Git governance → Phase 1 reprodukcija i minimum evidence (PODSETNIK, Windows multiple-instance/startup, Android PARTE, scenario/IRiU, full architecture/UI, migration/product profiles) → early Architecture/refactor/rewrite Decision Gate → potvrđene integrity/performance korekcije → historical/completed PREDMET lifecycle odluka i uklanjanje automatskog ZAVRŠEN → korekcija sadašnjih scenario/IRiU grešaka → user-editable scenario architecture i PODEŠAVANJA → dovršavanje PODSETNIKA/signala/JSON/dokumenata/PDF/RAČUN/tema → owner-odobren progressive refactor i UX korekcije → First Product-Line Gate: OPC Srbija → non-blocking Stage 2 cleanup kada opravdan → Second Product-Line Gate: multilingual → i18n/currency foundation → signing i professional handover closure.**
