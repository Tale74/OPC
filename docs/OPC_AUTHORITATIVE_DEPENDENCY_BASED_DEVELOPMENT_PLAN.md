# OPC — authoritative dependency-based development plan

**Status:** `POST-ZERO PROSPECTIVE UPGRADE PROGRAM`
**Autoritativnost:** Tale je 26. jula 2026. odobrio sadržaj, Decision Authority Matrix i dependency red. Dokument je obavezni kontrolni naslednik plan-draft ciklusa, ali još ne autorizuje aplikacionu implementaciju dok documentation protection, removal, Git/lokalna sinhronizacija i Gate 0 closure ne dobiju PASS.
**Approved candidate branch:** `task/OPC-GATE-0-FINAL-PLAN-OWNER-APPROVAL`
**Approved candidate SHA:** `8fb5aed98568e8e7becf7f17792e5066e3dfefdd`
**Owner approval record:** `docs/OPC_GATE_0_OWNER_APPROVAL_RECORD.md`
**Protection-map branch:** `task/OPC-GATE-0-DOCUMENTATION-PROTECTION-MAP`
**Datum owner odobrenja:** 26. jul 2026.
**Ugrađeni review nalazi:** F-01–F-12 iz `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_OWNER_REVIEW_FINDINGS.md`
**Ugrađene naknadne owner odluke:** potpuni code/architecture review; PREDMET-core dependency zaštita; tehnička/owner decision matrica; OPC v.1 / OPC_v.1_Int razdvajanje; MODUL DVE VALUTE.
**ARC–T.A.R.S.:** Definiši, ugradi, potvrdi, zapamti.

## Post-zero interpretation rule - 2026-07-30

The zero baseline at
`docs/OPC_ZERO_BASELINE_AND_POST_ZERO_OWNER_AUTHORITY.md` supersedes this
plan's pre-zero authority and Gate 0 status statements.

This document remains the owner-carried-forward prospective dependency
program. It does not revive pre-zero owner decisions as current authority and
does not authorize application implementation by itself.

Historical statements below about active `SOURCE/PROJECT_DOCS`, an external
`PROJECT_DOCS`, unresolved pre-zero document protection, or plan activation
pending the former Gate 0 describe the pre-zero state only. The current
classification is
`docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`.

Current implementation tasks still require an exact post-zero scope,
applicable technical evidence, post-zero owner approval for business-policy
changes, and the validation/runtime/Git gates defined by current workflow.

The effective post-zero status of this document is:

`POST-ZERO PROSPECTIVE UPGRADE PROGRAM`

## 1. Svrha plana

Ovaj plan određuje zavisnosni i kontrolni red daljeg razvoja OPC-a. Redosled nije kalendar niti automatska autorizacija narednog taska. Svaki program počinje dokazima, razdvaja dijagnostiku od implementacije i završava tehničkom, owner-runtime i dokumentacionom kapijom.

Plan ima šest ciljeva:

1. sačuvati PREDMET kao jedinu autoritativnu poslovnu istinu;
2. stabilizovati i dovršiti aktuelne Windows i Android aplikacije za tržište Srbije;
3. doneti ranu, dokazima zasnovanu odluku o targeted korekcijama, progresivnom refactoru, parcijalnom ili potpunom rewrite-u;
4. izgraditi korisnički konfigurabilan SCENARIO bez retroaktivne promene istorijske istine;
5. pripremiti OPC v.1 za kontrolisanu promenu primarne valute RSD/EUR bez novog coding/build ciklusa u trenutku aktivacije;
6. tek posle stabilizacije Srbije odlučiti i graditi buduću multilingual product line OPC_v.1_Int.

### 1.1 Decision Authority Matrix

Owner zadržava konačnu odluku o:

- poslovnoj politici i značenju poslovnih pravila;
- PREDMET lifecycle-u, statusima i istorijskom zaključavanju;
- SCENARIO uslovima i njihovim IRiU posledicama;
- sadržaju poslovnih dokumenata;
- poslovnom značenju valuta i trenutku globalne promene;
- jezicima, tržištima, product identity-ju;
- poreskoj, pravnoj, licensing i distributivnoj politici;
- Windows i Android runtime acceptance-u.

Codex donosi tehničke i arhitektonske odluke o:

- organizaciji source-a, modula, adaptera, branch-eva i release toka;
- refactor/rewrite granicama kada ne menjaju poslovno značenje;
- persistence reprezentaciji, test strategiji, profiling-u i tehničkim acceptance merama;
- platformskim mehanizmima uz isti poslovni rezultat;
- implementacionoj strukturi i redosledu tehnički zavisnih zahvata.

Codex mora vratiti odluku owneru kada tehnički izbor:

- menja poslovno značenje ili istoriju PREDMETA;
- zahteva destruktivnu ili nekompatibilnu migraciju;
- menja Windows/Android business parity;
- uvodi novu poslovnu, pravnu, poresku ili licensing politiku;
- menja sadržaj poslovnog dokumenta ili product-line identitet.

## 2. Verifikovani baseline i review izvori

### 2.1 Source i Git baseline

Finalni kandidat je pripremljen sa:

- source/review lineage HEAD: `eab28232dd1a791ecd0c24ee33b7f93a34f13797`;
- preparation base branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-REVISION`;
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
| `main` kao stabilni baseline naspram stacked task lineage-a | TECHNICAL MODEL SELECTED – ACTIVATION AFTER OWNER APPROVAL | Sačuvati stacked lineage; formirati operativni `develop/opc-v1`; `main` ostaje stabilni/release baseline. |
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
- Poslovni upis iz UI-a ili MODULA prolazi kroz kontrolisani PREDMET application/domain ugovor; derivat ne upisuje konkurentnu truth kopiju direktno u bazu.
- Derivat sme čuvati samo sopstveno tehničko stanje koje ne nadjačava PREDMET, na primer render pripremu, raspored elementa ili notification scheduling metadata.
- Code review mora dokazati smer zavisnosti `UI/MODULI → application/domain ugovor → PREDMET core` i prijaviti svako obrnuto, kružno ili derivat-na-derivat sprezanje koje ugrožava truth boundary.

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

- uklanjanje zavisnosti od hard-coded rezultata za `JAVNO MESTO/NEDEFINISANO`
  kroz odobreni korisnički podesiv SCENARIO ugovor; postojeće ponašanje se
  karakterizuje samo radi bezbedne migracije, a ne kao zaseban owner fixture;
- zasebno informativno PREDMET polje za groblje polaganja urne u postojećem
  `TIP POLAGANJA URNE` toku; ovaj podatak nije `MESTO CEREMONIJE` odnosno
  `groblje` same kremacije;
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
- OPC v.1 dobija jedan MODUL DVE VALUTE sa dva poslovna režima, ne dve naknadne razvojne faze.
- Početni režim je `RSD primarna / EUR informativna`.
- Posle globalne owner aktivacije režim je `EUR primarna / RSD informativna`.
- Globalna EUR aktivacija je jednosmerna u redovnom korišćenju; zaštićeni RSD fallback ostaje dostupan za vanrednu potrebu.
- Promena režima je runtime funkcija MODULA i ne zahteva novo kodiranje ili build.
- FINANSIJE imaju odvojeni toggle za informativni prikaz sekundarne valute i ručni unos kursa.
- Informativna valuta je izvedeni prikaz; ne menja autoritativne iznose, IRiU, KATALOG ili dokumente.
- FIRMA režim određuje primary default za nove PREDMETE; svaki PREDMET čuva sopstvenu primarnu valutu i relevantan kurs.
- Završeni/istorijski zaključani PREDMET i njegovi derivati ostaju stabilni.
- Postojeći dozvoljeni otvoreni PREDMET prelazi u drugi režim samo eksplicitnom kontrolisanom korisničkom radnjom.

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

- owner approval final-candidate sadržaja, Decision Authority Matrix-a i dependency reda — PASS, zapisano u `docs/OPC_GATE_0_OWNER_APPROVAL_RECORD.md`;
- odluka o F-01–F-12 integraciji;
- formalni operational development HEAD;
- Git/main/integration politika;
- dokumentacioni authority i semantic-parity pravilo;
- klasifikovani historical/superseded konflikti;
- finalni owner-odobren plan;
- usklađeni Git i lokalni dokumentacioni zapis tek posle odobrenja.

### 7.2 Git/main governance odluka

Codex tehnička odluka, koja se aktivira tek posle owner odobrenja ovog plana:

- postojeći stacked task lineage ostaje neizmenjen dokazni razvojni sled;
- Git-history rewrite je zabranjen;
- formira se dugotrajnija operativna grana `develop/opc-v1` iz owner-odobrenog Gate 0 vrha;
- svi novi OPC v.1 task branch-evi polaze sa aktuelnog `develop/opc-v1` HEAD-a;
- svaki task navodi exact base branch/SHA i final branch/SHA;
- `main` ostaje stabilni/release baseline i ne proglašava se operativnim HEAD-om samo zato što je default branch;
- owner-runtime prihvaćen integracioni/release rezultat ulazi u `main` kontrolisanim merge/release taskom;
- release dobija dokaziv commit i tag;
- historical task branches se ne brišu u ovom programu;
- budući OPC_v.1_Int ne dobija samostalni domain/migration fork pre Second Product-Line Gate-a;
- odobreni dokument ulazi u autoritativni manifest posebnim Gate 0 closure commitom.

Do aktivacije:

- task ne sme pretpostaviti da je public `main` source truth;
- mora navesti exact base branch/SHA;
- nova implementacija je zaustavljena.

### 7.3 Gate 0 protection re-evaluation — 29. jul 2026.

Section-by-section cross-map obuhvatio je svih 61 prvobitno blokiranih
targeta, a semantic evidence register svih 704 izdvojenih tvrdnji. Ponovna
evaluacija daje:

- originalni PASS targeti: 54;
- raniji blockeri podignuti na protection PASS: 36;
- ukupni protection PASS: 90;
- i dalje blokirane tačne putanje: 25;
- insufficient-context tvrdnje na tim putanjama: 169;
- fizičko uklanjanje: 0.

Owner stop-pravilo važi globalno: dok postoji makar jedna putanja bez potpunog
section-level autoritativnog naslednika, ne izvršava se delimično uklanjanje
grupa 5, 6, 8 ili 9. Zato Gate 0 i dalje nije zatvoren, lokalni aktivni izvori
se još ne konsoliduju fizičkim brisanjem, a `develop/opc-v1` se ne aktivira.

Aktuelna tačna mapa:
`docs/OPC_GATE_0_PROTECTION_REEVALUATION_AND_CLOSURE_MAP.md`.

## 8. Phase 1 — minimum evidence pre Architecture Decision Gate-a

Phase 1 prvenstveno prikuplja dokaze. Ne autorizuje automatski korekcije.

### 8.1 Full code/architecture review — prvi izvršni ciklus

Review obuhvata kompletan zajednički, Windows i Android source, a ne samo prijavljene simptome.

Obavezni scope:

- PREDMET domain i svi write/read putevi;
- repositories i Drift/SQLite;
- migracije, recovery, backup/restore i JSON;
- scenario/business-policy sloj;
- legacy/`core_v2` odnos;
- veliki presentation/util/database fajlovi;
- navigation/state/error handling;
- module boundaries i međumodulske zavisnosti;
- KATALOG i svi derivati;
- reminders;
- PDF/DOCX pipeline;
- Windows/Android platform adapters;
- testabilnost i characterization gaps;
- performance i product-profile readiness.

Review mora razlikovati:

- potvrđen kvar;
- owner runtime simptom ili hipotezu;
- dokazani arhitektonski dug;
- opravdanu platformsku razliku;
- poslovnu odluku koja nije tehnički dug.

### 8.2 PREDMET source-to-truth i dependency mapa

Pre pojedinačnih implementacionih korekcija dokazati:

- ko kreira i menja PREDMET;
- ko direktno pristupa PREDMET/IRiU tabelama;
- gde se business pravila nalaze van očekivanog domain/application sloja;
- gde derivati čuvaju kopije PREDMET podataka;
- da li se kopije mogu razići sa PREDMETOM;
- kako SCENARIO i IRiU pripadaju poslovnom kontekstu PREDMETA;
- kako KATALOG daje znanje bez retroaktivne izmene istorije;
- kako derivati reaguju na promenu, lock, anonimizaciju ili brisanje;
- postoje li direktni database upisi mimo kontrolisanog PREDMET lifecycle-a;
- da li Windows i Android imaju različite business puteve ili rezultate.

Svaka povreda PREDMET truth boundary-ja ima viši prioritet od običnog UI ili performance duga.

### 8.3 PODSETNIK orphan i OS notification lifecycle

**Audit/diagnosis:**

- reprodukovati brisanje, anonimizaciju i restart;
- proveriti DB cascade, sačuvane notification IDs i OS scheduler;
- proveriti već zakazane i već isporučene notifikacije;
- potvrditi ili odbaciti prijavljeni root-cause kandidat;
- proveriti Windows in-app i Android OS mehanizam.

**Emergency integrity gate:**

Ako je potvrđen uzak data/lifecycle kvar koji ne zahteva novu arhitekturu ili migraciju, owner može odobriti minimalnu korekciju pre opšte Architecture Decision Gate odluke. U suprotnom implementacija čeka Gate.

### 8.4 Windows multiple-instance — data-integrity prioritet

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

### 8.5 Windows startup performance — povezano, ali zasebno

Ne pretpostaviti uzrok. Meriti:

- cold i warm start;
- process start;
- window creation;
- config/locale;
- DB open/migration;
- KATALOG/reminder init;
- first usable screen.

Korekcija sledi tek posle baseline-a i owner-odobrenog cilja.

### 8.6 Android MODULI PARTE performance — simptom u okviru full review-a

Owner hipoteza je da prijavljeno „seckanje” može poticati od komplikovanog koda. Hipoteza nije potvrđen root cause. Code review prethodi ciljanoj optimizaciji i ispituje:

- module open;
- text edit;
- block drag;
- canvas pan/zoom;
- repaint;
- media;
- preview;
- narrow i wide layout;
- veličinu i odgovornosti komponenti;
- spregu editora, canvasa, gesture obrade, medija i preview-a;
- nepotrebne ili široke rebuild/repaint cikluse;
- sinhrone UI-thread, DB ili file operacije;
- lifecycle kontrolera/listenera/resursa;
- reprezentativan slabiji i srednji uređaj/hardware class.

Prvo se proverava da li se simptom još reprodukuje na aktuelnom HEAD-u. Ako ne, zatvara se dokumentovanim runtime nalazom. Ako da, source review i profiling zajedno odlučuju između minimalne korekcije i progresivnog PARTE refactor-a. Audit ne menja owner-prihvaćen PDF/DOCX rezultat.

Source audit završen 29. jula 2026. potvrđuje sledeće kandidate:

- `ParteModuleScreen._load()` serijski traži PARTE pripremu za svaki PREDMET;
- `InteractiveViewer.onInteractionUpdate` poziva široki `setState` pri svakom
  pan/zoom update-u i ponovo gradi preview subtree;
- media blok na rebuild-u kreira novi file-read future, a decode/effects/PNG
  obrada se izvršava sinhrono;
- veliki broj editor radnji upisuje draft i zatim pokreće kompletan
  `buildPlan/_reload`, uključujući DB, media i controller obnovu;
- sam block-drag tokom kretanja ostaje lokalni widget state i commit se vrši na
  završetku, pa nije potvrđen kao glavni per-frame DB uzrok.

Nalaz podržava ciljanu progresivnu refaktorizaciju presentation/render granice,
ne full rewrite. Android uređaj nije bio povezan tokom audita; owner je potvrdio
da ga može staviti na raspolaganje po preciznom zahtevu. Zato se izbor i
acceptance korekcije odlažu do jednog ciljanog latest-HEAD profiler prolaza.

### 8.7 Scenario/IRiU audit

- popisati sve hard-coded scenario family/uslove;
- karakterizovati postojeće `JAVNO MESTO/NEDEFINISANO` ponašanje isključivo
  radi migracione sigurnosti ka korisnički podesivom SCENARIO ugovoru;
- mapirati postojeći `TIP POLAGANJA URNE` tok i zasebno informativno polje
  groblja polaganja urne, različito od `MESTO CEREMONIJE`/`groblje` kremacije;
- klasifikovati managed/manual IRiU redove;
- reprodukovati stale-row ponašanje;
- mapirati scenario → PREDMET → IRiU → dokumenti → completion signali;
- utvrditi current scenario ID/version/storage/JSON ponašanje;
- karakterizovati postojeće baze.

Source audit završen 29. jula 2026.:

- postoji samo `default_funeral_ceremony_policy`; stvarna politika je skup
  hard-coded condition family pravila, ne skup korisničkih scenarija;
- `businessScenarioId` je PREDMET polje i deo je single-PREDMET JSON-a, ali
  nema scenario definition/version snapshot-a, FIRMA template tabele ili
  PODEŠAVANJA UI-a;
- `snapshotZaSaveCommit` trenutno izostavlja `businessScenarioId`, a IRIU
  promene nisu deo tog PREDMET-only snapshot-a;
- IRIU red nema persisted provenance koji pouzdano razlikuje basic,
  scenario-created, catalog i manual red iste kategorije;
- incident scenario-first redosleda je potvrđen i ostaje neispravljen;
- current lifecycle suppressuje zastarele redove i traži korisničke
  `ZADRŽI/UKLONI` ili `DODAJ/NE DODAJ` odluke, što je superseded novijom
  owner odlukom `ODQ-SCENARIO-001`;
- `SAHRANA VAN SRBIJE`, `DOČEK` i `OPELO` imaju add-only UI triggere; pri
  gašenju uslova redovi ostaju stored i truth sloj ih samo potiskuje;
- UI uvek čuva `groblje`, a downstream builder ga već koristi kao
  `MESTO CEREMONIJE`; za `SMESTAJ_URNE` ne postoji eksplicitno istoimeni
  UI/business ugovor;
- source i dva pre-regression backup-a koriste `NEDEFINISANA` kao
  `uzrokSmrti` vrednost i normalizuju `ULICA`/`JAVNO MESTO`; ne postoji
  dedicated kombinovani regression test niti dokumentovan expected rezultat
  dovoljan da se `JAVNO MESTO/NEDEFINISANO` proglasi reprodukovanim.

Naknadna owner odluka od 29. jula 2026. zatvara oba poslovna gate-a:

- poseban expected-result fixture za `JAVNO MESTO/NEDEFINISANO` više nije
  implementaciona zavisnost, jer se scenario politika izmešta iz hard-code-a u
  korisnički podesiv UI; current behavior ostaje characterization input samo za
  bezbednu migraciju;
- postojeći padajući meni `TIP POLAGANJA URNE` i njegova uslovna polja ostaju;
  dodaje se zasebno informativno PREDMET polje za groblje polaganja urne, koje
  može biti različito od `MESTO CEREMONIJE` odnosno `groblje` same kremacije.

Arhitektonski zaključak:

`RETAIN PREDMET/IRiU CORE + BOUNDED PARTIAL REWRITE OF THE SCENARIO/CONFIGURATION BOUNDARY`

Pre automatskog reconciliation-a potrebni su versioned PREDMET scenario
snapshot, FIRMA template/default persistence, IRiU row provenance i
reconciliation-pending tehnički recovery. Izolovan delete patch nije bezbedan.

### 8.8 UI/UX, migration i product-profile readiness audit

- historical schema 1–22;
- canonical DB policy;
- JSON schemas i previously distributed versions;
- FIRMA/scenario/currency persistence opcije;
- Serbia/multilingual separation;
- one-core/profiles/branches/flavors/modules opcije;
- signing/release identity posledice;
- Android narrow, Android wide i Windows UI/UX;
- keyboard/mouse/touch/accessibility parity.

### 8.9 Phase 1 execution checkpoint — 28. jul 2026.

Full source/architecture review iz 8.1 je završen:
`docs/OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md`.

Objedinjena evidence matrica:
`docs/OPC_PHASE_1_ARCHITECTURE_DECISION_GATE_EVIDENCE_MATRIX.md`.

Current tehnička preporuka je:

`RETAIN CURRENT CODEBASE + PROGRESSIVE REFACTOR`.

Full rewrite nije podržan dokazima. Partial rewrite ostaje evidence-gated
opcija za scenario/configuration i JSON orchestration granicu; PARTE
presentation samo ako profiling dokaže potrebu.

Architecture Decision Gate još nije otvoren. Preostali dokazni red je:

1. Windows multiple-instance/concurrent SQLite — audit complete 29 July 2026;
2. Windows startup baseline — source audit complete 29 July 2026; quantitative current-HEAD runtime baseline awaits owner-authorized isolated WINDOWS_TEST instrumentation/build;
3. Android PARTE source audit — complete 29 July 2026; targeted latest-HEAD
   reproduction/profiling awaits an owner-provided Android device;
4. kompletan SCENARIO/IRiU audit;
5. UI/UX, migration, parity i product-profile synthesis;
6. pouzdan kompletan Flutter test rezultat — PASS za neizmenjeni application
   tree na `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`: 247 passed, 1 skipped,
   0 failed; kasniji Phase 1 commitovi do ovog checkpoint-a su documentation-only.

Windows concurrency audit result:

- no process-level guard exists before Flutter/SQLite initialization;
- every production Windows process opens the same canonical database lane;
- isolated synthetic probes confirmed blocking during concurrent open/write;
- recommended correction is a named mutex before Dart/SQLite plus installer
  running-app coordination;
- installation/update/uninstall must never modify canonical database identity,
  location or content;
- implementation remains unauthorized until the relevant correction gate.

Windows startup source-audit result:

- the native shell can be visible before the first usable Flutter route;
- `main.dart` awaits window-manager setup and global Serbian date-symbol
  initialization before `runApp`;
- first-login routing waits on the first database query;
- every database open repeats schema recovery/validation, 74 sequential seed
  attempts, an unconditional built-in policy update and a full KATALOG
  stable-ID scan;
- post-login work also starts automatic status, reminder, setup-readiness and
  SAVETNIK operations;
- one synthetic external harness did not reach its first SQLite phase within
  nine minutes and produced no valid OPC performance metric; it must not be
  repeated;
- a quantitative current-HEAD baseline remains gated by explicit owner
  authorization for isolated WINDOWS_TEST instrumentation and a release build;
- the initial source/harness phase did not open the canonical database and did
  not change application source or runtime behavior.

Subsequent owner-authorized installed-runtime evidence:

- the real installed owner version reaches the login screen in approximately
  `8–9 s` on the reference machine;
- startup to login, without authentication, changed the canonical SQLite file
  by `+8,192` bytes and changed its SHA-256;
- post-exit `PRAGMA integrity_check` is `ok`, schema checkpoint remains 22 and
  no sidecar file remains;
- no restore or overwrite was attempted;
- the owner also confirms visibly slow normal exit, consistent with the prior
  recorded `12.8 s` close;
- production source does not explicitly close the application-owned
  `AppDatabase` before awaiting native window destruction;
- installed-version evidence does not replace the still-required current-HEAD
  isolated measurement before correction acceptance.

## 9. Architecture / refactor / rewrite Decision Gate

### Post-zero technical gate result - 2026-07-30

The post-zero synthesis at
`docs/OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md` closes the
whole-codebase technical architecture choice:

`RETAIN + PROGRESSIVE REFACTOR + BOUNDED SUBSYSTEM CHANGE ONLY WHERE PROVEN`.

Full rewrite is rejected by current evidence. Windows startup/shutdown timing
and Android PARTE profiling are safely deferred for this whole-codebase choice
but remain mandatory before code changes in their affected performance areas.
Business-policy and lifecycle meaning changes still require a post-zero owner
gate. This result does not authorize implementation.

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

Codex na osnovu dokaza odlučuje:

- architecture option;
- scenario persistence model;
- migration strategiju;
- module/refactor granice;
- koje minimalne integrity korekcije mogu prethoditi većem refactoru.

Owner potvrđuje samo poslovne posledice tih odluka, uključujući lifecycle, SCENARIO/IRiU značenje, valutu, dokumente, product identity i svaki izuzetak od PREDMET authority-ja ili Windows/Android parity-ja. Ako tehnički izbor dodiruje takvu posledicu, Gate staje do owner odluke.

## 10. Phase 2 — potvrđene integrity i performance korekcije

Svaka stavka koristi lifecycle iz odeljka 6.

### 10.1 PODSETNIK orphan korekcija

#### Post-zero RI-1 through RI-5 design result - 2026-07-30

The controlling post-zero lifecycle/referential design is
`docs/OPC_POST_ZERO_PREDMET_LIFECYCLE_REFERENTIAL_DESIGN.md`.

It confirms the first executable stage as committed RI-1 characterization and
dependency/orphan inventory with no production behavior change. RI-2
coordination, RI-3 recovery, RI-4 FK enforcement and RI-5 restore/parity proof
remain separately gated. Business/privacy/transfer choices identified by the
design require post-zero owner authority before their affected implementation.

#### RI-1 execution result - 2026-07-30

RI-1 committed characterization and inventory is implemented in
`test/predmet_lifecycle_referential_characterization_test.dart`.

The isolated in-memory evidence locks:

- `foreign_keys=0` as current behavior;
- all seven declared PREDMET dependencies through `foreign_key_list`;
- metadata-only orphan counts for every dependent table;
- hard-delete PARTE/reminder FK orphans;
- derivative PII retained after current anonymization;
- stale PARTE/reminder state retained across individual replacement;
- stale reminder re-association by reused local ID during full restore, even
  when `foreign_key_check` is clean.

This is characterization, not approval of current behavior. Production source,
schema, migration, FK enforcement, JSON format and canonical data are unchanged.
Existing committed stock-compensation, PARTE media rollback, reminder and
historical migration fixtures remain the supporting seam evidence; RI-1 does not
duplicate those broad suites.

Next dependency is RI-2 explicit lifecycle coordination, only after exact
implementation authorization. Hard-delete coordination can proceed without a
new business-policy answer. Replacement, anonymization and restore must stop at
their recorded post-zero owner gates.

#### RI-2 hard-delete slice result - 2026-07-30

The first technically independent RI-2 slice is implemented:

- both production UI delete paths use one application-level hard-delete
  coordinator;
- the coordinator inventories PARTE/reminder state before mutation;
- exclusively owned PARTE media is staged through the existing recoverable
  trash mechanism, while shared media is preserved;
- only stored/scoped ceremony notification IDs are cancelled;
- the existing STANJE ROBE compensation and one DB transaction explicitly
  remove reminder, PARTE, log, contact, IRiU decision, IRiU, consequence and
  PREDMET rows;
- DB/cancellation failure restores staged media and re-establishes reminder
  scheduling before surfacing failure;
- successful commit purges staged app-owned media best-effort.

No schema, migration, FK setting, JSON format, anonymization, replacement or
restore behavior changed. This technical PASS does not close owner runtime
acceptance.

Remaining RI-2 slices stay closed at their post-zero owner gates.

Owner runtime acceptance for this hard-delete slice is explicitly
`DEFERRED / OWED` and must be included with the next authorized Windows/Android
runtime cycle. Deferral is not runtime PASS and does not authorize another RI-2
business-policy slice.

#### RI-2 full-restore slice result - 2026-07-30

The owner selected post-zero policies 3A and 4A. Full backup schema 8 now
transfers reminder enablement/delivery times without device notification IDs.
Restore scoped-cancels destination IDs, explicitly clears PREDMET child state,
imports the database transactionally, removes old app-owned PARTE media and
rebuilds reminder schedules with new local IDs where possible.

Users/PIN hashes remain portable. Destination-installation
`security_settings` and existing `auth_audit_log` remain local; restore appends
one local `full_backup_restore` audit event. Legacy schema-7 backups remain
readable and clear stale destination reminder state. Isolated failure proof
rolls back the database, restores staged media and re-establishes old reminders.

Anonymization and individual replacement remain closed at owner gates 1 and 2.
FK enablement, orphan recovery, migration and canonical/live data remain
outside this slice. Focused technical tests pass. The owner-provided cumulative
PowerShell gate at `a1ec31fcd4b2113740a9e118a29c94a556f4243c` also passes:
analyze with no issues, complete tests 258 passed/1 skipped/0 failed, Windows
release build PASS and Android APK release build PASS. Owner Windows/Android
runtime acceptance remains separately `DEFERRED / OWED`.

Owner Windows hard-delete runtime acceptance subsequently passed: the deleted
synthetic PREDMET remained absent after restart, the application stayed stable,
and unrelated PREDMET/PARTE state remained intact. Android hard delete and
Windows/Android full restore remain owed.

Android subsequently passed the hard-delete UI/database persistence and
isolation checks with the same stable/restart/unrelated-data outcome. The owner
did not report the scheduled-reminder non-arrival observation, so scoped Android
notification cancellation remains owed rather than inferred.

The same Windows session identified two separately source-confirmed PARTE UI
defects (mojibake/internal `mourners` warning text and initial-versus-fitted
font-size display mismatch) plus an unmeasured performance impression. These
findings do not reopen hard-delete PASS. UI correction requires a separate
notified task; performance requires targeted measurement before diagnosis.

Android reproduced both UI defects. The owner additionally established and
clarified the global PARTE empty-content rule: defined blocks remain mandatory
in template/draft structure, while each block's content may be empty. Empty
content is omitted and does not block preparation/confirmation/export. Current
`requiredTextBlockIds` composition and export validation incorrectly infer
missing required structure from content-bearing render output. Correct that
structure-versus-content conflation only in a separate notified task with
focused empty-content, structural-integrity, output and Windows/Android parity
evidence.

Android full-restore runtime subsequently failed before destination mutation.
Read-only inspection of the exact owner-supplied schema-8 backup confirmed 2
orphan reminder rows among 9 reminder rows; all other reminder validator
conditions were valid. The schema-8 exporter included every FK-off reminder
row, while the importer rejected rows without a transferred PREDMET. This
confirmed self-produced-backup compatibility defect is `INC-003`.

Before full-restore acceptance can close, a separate notified correction must:

- restrict future exported reminder settings to transferred PREDMET ownership;
- define safe compatibility for existing schema-8 files carrying orphan
  reminder derivatives without reassociating them;
- preserve valid 3A logical settings and 4A installation-local security/audit;
- prove isolated round-trip/rollback and repeat Android owner runtime.

#### INC-003 bounded full-restore compatibility correction - 2026-07-31

The notified correction is technically implemented on a separate task branch.
It does not perform RI-3 recovery, live cleanup, FK enablement, migration,
relinking or canonical database mutation.

- Export uses the exact captured exported-PREDMET set to include only owned
  reminder settings and change-history rows.
- Schema-8 import fully validates each reminder/history row, then skips only a
  structurally valid row whose PREDMET is absent from the backup. Destination
  IDs never validate ownership, preventing reassociation through reused IDs.
- Restore inventories and scoped-cancels all destination notification IDs,
  including IDs in an orphan reminder row. Rollback compensates only configured
  reminders owned by an existing old PREDMET.
- Policy 3A remains exact: logical enabled/delivery-time configuration is
  transferred, device IDs are not, and future platform slots are rebuilt with
  new local IDs. A future prepared platform slot is not an active trigger now;
  the current trigger remains `activeCeremonyReminderSlot`.
- Policy 4A remains exact: users/PIN hashes transfer, destination security and
  existing audit remain local, and one local restore audit event is appended.
- Supplied-backup isolated evidence: 46 PREDMETI; reminder rows 9 total, 7
  owned, 2 skipped; change-history rows 230 total, 224 owned, 6 skipped; active
  triggers 0 at the recorded preflight moment; 3 future platform slots rebuilt;
  referential check clean.
- Focused and related regressions pass; final analyze is clean and complete
  tests pass 264 with 1 skipped. Owner-provided Windows and Android release
  builds pass on the final correction SHA; runtime acceptance remains separate.

Technical correction PASS does not close Android runtime acceptance. The owner
Android full-restore retest remains owed.

Root-cause dijagnoza je potvrđena code-first auditom:
`docs/OPC_PODSETNIK_ORPHAN_REFERENCE_ROOT_CAUSE_AND_RECOVERY_AUDIT.md`.

Potvrđena su dva nezavisna lifecycle nedostatka:

- reminder SQLite red se oslanja na deklarisani cascade bez uključenog/dokazanog
  runtime foreign-key enforcement-a;
- Android OS notification se ne otkazuje pre brisanja PREDMETA.

Historical diagnosis below is superseded by the RI-2 implementation and
INC-003 correction above: full restore now clears/transfers/rebuilds reminder
configuration under policy 3A. It remains preserved only as chronology, not as
current source state.

Full-backup restore je dodatni trigger jer ne čisti, ne prenosi niti ponovo
gradi reminder konfiguraciju.

Buduća odobrena implementacija mora obuhvatiti:

- atomic/compensating deletion lifecycle;
- cancel pre gubitka notification IDs ili drugi dokazivo bezbedan red;
- idempotent retry;
- recovery za ranije orphan payload-e;
- eksplicitno čišćenje orphan SQLite redova;
- scoped pregled pending OPC payload-a, bez `cancelAll`;
- full-backup prenos logičke konfiguracije bez device-local notification IDs;
- restore cancel/clear/import/reschedule red;
- nema gubitka validnog PREDMETA;
- Windows/Android ekvivalentan business rezultat.

Globalno uključivanje `PRAGMA foreign_keys = ON` ostaje zaseban širi integrity
audit posle inventara svih relacija i postojećih orphan redova.

Taj širi audit je završen:
`docs/OPC_DATABASE_REFERENTIAL_INTEGRITY_AND_PREDMET_DEPENDENCY_AUDIT.md`.

Fixture dokaz potvrđuje FK-off runtime, orphan PARTE/reminder redove,
anonymization privacy ostatke i full-restore dependent-data rizik. Zbog toga
PODSETNIK orphan implementacija ne sme biti izolovan UI/repository patch.
Najpre se primenjuje auditovani progressive lifecycle/referential refactor red.

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

Pre user-configurable UI-a završavaju se characterization, owner gates i
scenario/configuration data ugovor. Source korekcije se zatim implementiraju u
jednom kontrolisanom Phase 4 programu, jer automatsko brisanje nije bezbedno bez
row provenance-a i PREDMET-owned scenario snapshot-a:

- migraciona characterization provera sadašnjeg
  `JAVNO MESTO/NEDEFINISANO` ponašanja, bez zasebnog owner fixture-a ili
  izolovane hard-code korekcije;
- zasebno informativno groblje polaganja urne u postojećem
  `TIP POLAGANJA URNE` toku, odvojeno od mesta/groblja kremacije;
- stale/nepotrebni IRiU redovi;
- incident iz 2026-07-17: scenario redovi su neautorizovano pomereni ispred
  `SANDUK` i osnovnog IRiU bloka;
- jedna poslovna potvrda `NASTAVI/ODUSTANI`, bez tehničkog consequence preview-a;
- automatsko uklanjanje neprimenljivih scenario-owned redova, uključujući
  njihove korisničke vrednosti, bez neaktivne kopije i bez kasnijeg vraćanja;
- automatsko kreiranje novih potrebnih redova sa praznim korisničkim
  vrednostima;
- automatsko poništavanje operativnih/STANJE ROBE posledica ili skriveni,
  nefinansijski `RECONCILIATION_PENDING` recovery kada trenutno ne uspe;
- idempotent reconciliation.

Phase 3 završava dokaz, karakterizaciju mutation putanja, schema/migration
design i zaštitu historical/locked PREDMET granice. Source korekcije se ne rade
kao izolovani patch-evi: implementiraju se u Phase 4 zajedno sa
konfigurabilnim SCENARIO ugovorom.

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

Obavezni incident acceptance uslov:

- očuvati KATALOG mogućnost da user/Administrator definiše nove osnovne IRiU
  kategorije;
- ta mogućnost ne sme menjati postojeće SCENARIO odluke ili logiku;
- `SANDUK` i kompletan primenljiv osnovni IRiU blok moraju prethoditi
  scenario-dependent redovima;
- ukloniti obrnuti test uveden 2026-07-17 i zameniti ga owner-approved
  business-contract i mutation-path regresionim testovima;
- ne menjati completed/locked PREDMET istinu; eligible nezavršen PREDMET koristi
  samo kontrolisani SCENARIO/IRiU reconciliation.

### 14.3 Promena scenarija postojećeg PREDMETA

Samo za lifecycle-eligible PREDMET:

- eksplicitna akcija;
- jedna potvrda da će OPC automatski uskladiti IRiU;
- bez prikaza tehničkog old/new consequence diff-a korisniku;
- automatsko uklanjanje svih neprimenljivih scenario-owned IRiU redova i
  njihovih korisničkih vrednosti;
- automatsko kreiranje novih potrebnih redova sa praznim vrednostima;
- uklonjene vrednosti se ne arhiviraju i ne vraćaju pri povratku na raniji
  SCENARIO;
- operativne posledice se automatski poništavaju; neuspeh koristi skriveni
  `RECONCILIATION_PENDING` recovery bez vraćanja korisniku tehničkog zadatka;
- atomic transaction ili dokazivo bezbedan compensation plan;
- provenance/audit;
- nikada automatski za istorijski zaključan PREDMET.

## 15. Phase 5 — dovršavanje postojećih funkcija

### 15.1 Kompletan signalni model

Pre povratka na poslovni PODSETNIK model mora se inventarisati i dokazati ceo
skup signala:

- narandžasto prazno;
- žuto delimično;
- zeleno potpuno;
- ikona/tekst pored boje;
- scenario-dependent relevantna polja;
- N/A i opciona polja;
- lifecycle eligibility;
- nedostajuća obavezna PREDMET/SCENARIO polja;
- IRiU complete/exception stanje;
- rok/due/missed kandidat;
- izračunato iz PREDMETA/SCENARIO/IRiU;
- nema paralelnog skladištenog truth statusa.

Codex tehnički mapira izvore i zavisnosti. Owner potvrđuje koji signali imaju
poslovno značenje za informisani podsetnik.

### 15.2 Povratak na PODSETNIK model i notifications

Tek posle orphan/lifecycle korekcija i owner-potvrđenog kompletnog signalnog
modela:

- informed reminder trigger mapa;
- active/due/missed/completed/cancelled model;
- closed-app delivery;
- restart/reboot recovery;
- permission denied;
- no duplicates;
- tap vodi samo na postojeći PREDMET;
- Windows i Android jednaka poslovna funkcija uz različit OS mehanizam gde je potrebno.

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

### 15.8 MODUL DVE VALUTE za OPC v.1

Jedan modul podržava dva runtime režima:

1. `RSD primarna / EUR informativna`;
2. `EUR primarna / RSD informativna`.

Pre globalne aktivacije:

- RSD ostaje autoritativna obračunska i dokumentarna valuta;
- FINANSIJE mogu uključiti informativni EUR prikaz;
- toggle otkriva ručni kurs `1 EUR = ___ RSD`;
- informativni EUR se računa kao `RSD / kurs`;
- preračun ne menja PREDMET/IRiU/KATALOG/PDF/RAČUN business iznose.

Posle owner globalne aktivacije:

- EUR postaje default primarna valuta za nove PREDMETE;
- RSD prelazi u informativni FINANSIJE prikaz;
- PDF/DOCX derivati novih EUR PREDMETA koriste EUR bez novog coding/build ciklusa;
- redovna aktivacija je jednosmerna;
- zaštićeni RSD fallback postoji u naprednim podešavanjima MODULA, sa jasnim upozorenjem, višestepenom potvrdom i audit zapisom.

Persistence/migration ugovor mora obezbediti:

- FIRMA default primary režim;
- PREDMET primary currency;
- kurs, datum i provenance potrebne za istorijski prikaz;
- stabilnost završenih/istorijski zaključanih PREDMETA;
- eksplicitnu, kontrolisanu konverziju dozvoljenog otvorenog PREDMETA;
- identičan Windows/Android i JSON rezultat;
- unapred pripremljene RSD i EUR document formation grane;
- bez automatskog spoljnog kursa, PDV-a, poreza ili fiskalizacije.

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

Aktuelni projekat `OPC v.1` dovršava se i stabilizuje kao samostalna OPC Srbija product line do lokalizacionog razdvajanja. Posle potrebnih audita i korekcija owner donosi binding odluku o njenom konačnom release statusu.

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
- MODUL DVE VALUTE sa RSD početnim i EUR aktivacionim režimom.

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

Budući projekat nosi radni identitet `OPC_v.1_Int`. Fizički source fork/novi project root ne nastaje pre ovog gate-a. Architecture audit prvo dokazuje šta ostaje shared core, šta je country/language profile i šta zahteva samostalni release sloj.

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

Dugoročno divergentni domain/migration forkovi nisu default preporuka. Početna tehnička preporuka je shared PREDMET/data core sa odvojenim country/language/document/scenario profilima i zasebnim product/release identitetom, osim ako audit dokaže da migraciona ili poslovna izolacija zahteva drugačije.

Odvojiti:

- UI language;
- script;
- country profile;
- business policy;
- documents;
- KATALOG;
- scenarios;
- currencies.

### 19.4 International multicurrency readiness

- ponovo koristiti dokazani currency ugovor iz OPC v.1, bez fork dupliciranja;
- FIRMA/country base currency;
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

### Pre autoritativne aktivacije plana

Nema unapred otvorene owner odluke. Nova owner odluka traži se samo ako protection mapa pronađe cilj bez dokazanog autoritativnog naslednika ili privacy procena zahteva širenje scope-a.

### Posle Phase 1 audita, pre relevantne implementacije

1. `ZATVOREN`/`ZAVRŠEN` i historical-lock lifecycle, uključujući eventualni correction/reopen izuzetak.
2. Tretman istorijski auto-završenih PREDMETA.
3. Owner runtime acceptance za Codex-definisane Windows startup i Android PARTE tehničke targete.

### Pre odgovarajućih funkcionalnih/product taskova

4. PDF RAČUN toggle migration default za postojeće instalacije.
5. Poslovni sadržaj i PDF/DOCX scope NALOGA CVEĆARI.
6. Globalni trenutak aktivacije EUR režima i eventualna owner odluka o konverziji tada otvorenih PREDMETA.
7. OPC Srbija app identity i update kanal.
8. Multilingual product/business identity.
9. Publisher i signing-key custody/transfer model.

Architecture option, persistence model, module topology, refactor/rewrite granice, technical versioning i release mehanizam pripadaju Codex tehničkoj odluci po Decision Authority Matrix-u. Svaki njihov business-impact izuzetak vraća se owneru.

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

1. Tale eksplicitno odobri final-candidate sadržaj, Decision Authority Matrix i dependency red;
2. izabrani Git/main governance model bude aktiviran i zapisan;
3. otvoreni queue ostane jasno odvojen od zaključanih odluka;
4. nema P0 findings bez resolution-a;
5. finalni plan dobije novi naziv bez `DRAFT`;
6. Git i lokalni dokumentacioni izvori budu semantički usklađeni;
7. kontrolisane razlike i hash-evi budu evidentirani;
8. autoritativni manifest/source-of-truth dokumenti budu ažurirani posebnim owner-odobrenim documentation taskom;
9. branch/commit/report budu pushovani;
10. worktree i origin budu usklađeni.

Do potpunog Gate 0 closure-a status ostaje:

`OWNER APPROVED – AUTHORITATIVE ACTIVATION PENDING GATE 0 CLOSURE`

## Current post-zero sequencing update - 2026-08-01

The current authorized dependency is the bounded PARTE correction on
`task/OPC-POSTZERO-STABILIZATION-AND-PERFORMANCE`, not a rewrite or a new
business-policy task. Its Gate 1 implementation is technically PASS with
focused evidence and remains separate from owner Windows/Android runtime
acceptance.

The owner has reported a scoped Android full-restore PASS after the INC-003
correction; the earlier FAIL is preserved as incident history and the result
does not waive current-tip runtime or security/data coverage.

The observed IRIU/KATALOG slowdown is still an unmeasured performance finding.
The next dependency is a reproducible timing trace. No query/index/startup
change is authorized until that evidence proves a cause. OPC Web,
`OPC_v.1_Int`, RI-3 recovery, migrations and reminder-policy reinterpretation
remain deferred.

Phase 3 lifecycle correction is now owner-approved: automatic `ZAVRŠEN`
transition is retired, and the only business transition is the explicit
`OTVOREN → ZATVOREN → ZAVRŠEN` action. The final state is immutable for direct
edits and reopening. Ceremony date, reminder state and derivative output do
not infer completion. Focused evidence is recorded in
`test/predmet_completion_state_characterization_test.dart` and the task
implementation report; Windows/Android runtime acceptance remains separate.

## 25. Jednolinijski dependency red


**Gate 0 documentation/Git governance → full code/architecture review → PREDMET source-to-truth/dependency mapa → integrity, platform, performance, scenario, UI i migration evidence → Architecture/refactor/rewrite Decision Gate po Decision Authority Matrix-u → potvrđene integrity/performance korekcije → historical/completed PREDMET lifecycle odluka i uklanjanje automatskog ZAVRŠEN → korekcija sadašnjih scenario/IRiU grešaka → user-editable SCENARIO i PODEŠAVANJA → kompletan signalni model → informed PODSETNIK → JSON/dokumenti/PDF/RAČUN/tema → MODUL DVE VALUTE → dokazani progressive refactor/partial rewrite → First Product-Line Gate: stabilni OPC v.1 Srbija → non-blocking Stage 2 cleanup kada opravdan → Second Product-Line Gate: OPC_v.1_Int → i18n/country/multicurrency profiles → signing i professional handover closure.**
