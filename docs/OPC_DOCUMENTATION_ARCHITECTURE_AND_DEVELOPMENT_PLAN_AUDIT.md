# OPC — dokumentacioni, arhitektonski i razvojno-planski audit

**Status:** DRAFT – OWNER REVIEW REQUIRED
**Autoritativnost:** Dokument još nije odobren niti je deo autoritativnog OPC dokumentacionog skupa.
**Source baseline grana:** `task/OPC-PARTE-MODULE-SHORTCUT-PREDMET-PARTE-SEGMENT`
**Source baseline SHA:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
**Datum audita:** 23. jul 2026.
**Poreklo review kopije:** Javno sanitizovana review kopija originalnog Codex deliverable dokumenta. Sanitizacija obuhvata standardno zaglavlje, owner-odobrenu zamenu privatnih apsolutnih lokalnih putanja repo-relativnim putanjama ili neutralnim logičkim oznakama i nesadržinsku normalizaciju završnih razmaka potrebnu za `git diff --check`. Audit nalazi, zaključci, redosled i preporuke nisu sadržinski menjani.
**Konvencija putanja:** Putanje unutar Git repozitorijuma navedene su repo-relativno. `[GIT REPOSITORY ROOT]` označava koren repozitorijuma; `[LOCAL PROJECT_DOCS SOURCE]` označava eksterni lokalni projektno-dokumentacioni izvor; `[LOCAL OPC RESTORE-POINT SOURCE]` označava eksterni lokalni restore/audit izvor.
**Scope:** dokumentacija, source, migracije, arhitektura, razvojni redosled i product-line odluke.
**Van scope-a:** izmene aplikacionog koda, migracija ili baze; buildovi; objavljivanje; potpisivanje.

## 1. Izvršni zaključak

Aktuelnu OPC osnovu treba **zadržati i progresivno refaktorisati**, uz **ograničene parcijalne rewrite-ove** tamo gde postojeći model ne može da ispuni novu owner politiku bez ugrožavanja istorijske istine PREDMETA. Potpuni rewrite sada nije opravdan dokazima.

Glavni razlozi:

1. postoji funkcionalan i owner-proveren Windows/Android baseline sa uspešnim analyze, kompletnim testom, release buildovima i runtime acceptance-om poslednjeg PARTE taska;
2. trenutna baza ima eksplicitni schema version 22 i testirani migracioni lanac 1–22;
3. postoje odvojeni repositories/services, PREDMET-centrični model i značajan testni fond;
4. potpuni rewrite bi uneo najveći rizik za kanonske korisničke baze, JSON razmenu i već potvrđene poslovne rezultate;
5. ipak, scenario politika nije stvarni konfigurabilni engine: postoji jedan ID scenarija, dok su pravila tvrdo kodirana; zato scenario/configuration sloj zahteva novu granicu i verovatno parcijalni rewrite iza kompatibilnih interfejsa;
6. veliki presentation/util/database fajlovi i delimično paralelno postojanje starog i `core_v2` sloja opravdavaju progresivno razdvajanje, ne “big-bang” zamenu.

Pre prvog novog implementacionog taska mora biti odobren i upisan autoritativni plan, a dokumentacioni konflikti navedeni u ovom izveštaju moraju dobiti eksplicitne supersession odluke.

## 2. Verifikovani source i dokumentacioni baseline

### 2.1 Source baseline

- Lokalni source: `[GIT REPOSITORY ROOT]`
- Aktivna grana: `task/OPC-PARTE-MODULE-SHORTCUT-PREDMET-PARTE-SEGMENT`
- HEAD: `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
- Commit: `Record PARTE shortcut owner runtime acceptance`
- Lokalna grana i `origin` imaju odnos `0 ahead / 0 behind`.
- Radno stablo je čisto.
- Javno proverljiv commit:
  `https://github.com/Tale74/OPC/commit/e9ea4a9679f0a9f80521fc3aa362e78b7993d073`

Operativni baseline je navedeni task-branch commit, **ne trenutni `main`**. Javni `main` i dalje prikazuje inicijalni javni baseline sa četiri commita. Dok se ne donese i sprovede odluka o integraciji, “stable main” pravilo iz Git workflow dokumenta nije jednako stvarnom stanju razvoja.

### 2.2 Poslednji task dokaz

Najnoviji report:

`docs/tasks/OPC_TASK_PARTE_MODULE_SHORTCUT_PREDMET_PARTE_SEGMENT_CORRECTION_REPORT.md`

Report beleži:

- finalni `flutter analyze --no-pub`: PASS;
- fokusirane testove: 3 PASS;
- kompletan Flutter test: 247 PASS, 1 SKIP, 0 FAIL;
- Windows release build: PASS;
- Android release build: PASS;
- owner runtime acceptance: PASS;
- merge u `main`: nije izvršen.

Zaključak: PARTE closure je dokumentovan i owner-potvrđen na task grani, ali upravljački status grane prema `main` ostaje nerešen.

### 2.3 Aktuelna baza i migracije

Source dokaz:

- `lib/core/database/database.dart` — `schemaVersion => 22`;
- isti fajl sadrži sukcesivne upgrade grane do 22;
- `test/canonical_database_migration_recovery_test.dart` pokriva istorijske verzije 1–22;
- `docs/tasks/OPC_TASK_KATALOG_OSNOVNE_KATEGORIJE_IRIU_AUDIT_IMPLEMENTATION_REPORT.md` dokumentuje aditivnu migraciju 21→22 i migracione testove.

Nije pronađena nedostajuća migracija u sadašnjem lancu 1–22. Pronađena je dokumentaciona nedoslednost:
`docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md` na jednom mestu pravilno navodi target 22, a kasnije istorijski opis schema 21 koristi bez jasne oznake da je to ranija closure tačka.

To nije dokaz da migracija nedostaje; jeste razlog da migration policy bude ažuriran pre nove schema promene. Posebno, scenario snapshot/template model, FIRMA defaults, RAČUN toggle i budući country/currency profili zahtevaju unapred definisane aditivne migracije i recovery testove.

## 3. Dokumentacioni inventar i reconciliation

### 3.1 Fizički skupovi

1. Javni/repo dokumentacioni skup:
   `docs` — 133 fajla.
2. Repo legacy/working kopija:
   `PROJECT_DOCS` — 14 fajlova.
3. Eksterni lokalni projektni skup:
   `[LOCAL PROJECT_DOCS SOURCE]` — 11 fajlova.
4. Istorijski restore/audit trag:
   `[LOCAL OPC RESTORE-POINT SOURCE]` — 49 pregledanih tekstualnih/strukturisanih artefakata.

Jedanaest fajlova koji postoje i u `SOURCE/PROJECT_DOCS` i u eksternom `PROJECT_DOCS` skupu byte-identični su po SHA-256. Tri fajla postoje samo u repo kopiji:

- `OPC_RE_ENTRY_AUDIT_PROJECT_STATE_AND_NEXT_MACRO_STEPS_REPORT.md`
- `OPC_TASK_044_PROJECT_STATE_STABILIZATION_AND_CROSS_PLATFORM_BASELINE_REPORT.md`
- `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`

### 3.2 Autoritet po aktuelnijoj dokumentaciji

`docs/OPC_SOURCE_OF_TRUTH_MAP.md` i
`docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`

već razlikuju aktuelni javni `docs/` sloj od istorijskog/pomoćnog `PROJECT_DOCS` sloja. Promotion map eksplicitno beleži odnos 14/11 i objašnjava da raw lokalni dokumenti nisu automatski promovisani.

To je razumnija osnova od pravila iz:

`PROJECT_DOCS/00_README_KAKO_KORISTITI.md`

koje eksterni `PROJECT_DOCS` naziva “Master”, repo kopiju “Codex working copy”, a dokumentaciona ažuriranja izdvaja tek nakon validacije. To pravilo je sada u konfliktu sa owner odlukom da reconciliation prethodi radu i da se oba izvora usklađuju kroz svaki task.

### 3.3 Utvrđeni konflikti i zastarelost

| Oblast | Dokaz | Nalaz | Potrebna odluka |
|---|---|---|---|
| Git praksa | `docs/GIT_WORKFLOW_ARC.md` naspram stvarnih grana | Dokument kaže da je `main` stabilni baseline; stvarni razvojni vrh je stacked task branch, dok `main` ima početni javni baseline | Definisati integracionu/merge strategiju i operativni baseline |
| Lokalni master | `PROJECT_DOCS/00_README_KAKO_KORISTITI.md` naspram `docs/OPC_SOURCE_OF_TRUTH_MAP.md` | Dva različita autoriteta i različit trenutak dokumentovanja | Uvesti dvostruki kontrolisani mirror sa hash proverom; ugasiti treću aktivnu kopiju |
| Git odluka | `OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md` | Tvrdi da OPC nema i neće imati Git; danas postoji javni Git repo | Obeležiti kao istorijski superseded dokument |
| Git preporuka | `OPC_TASK_044...` naspram `OPC_TASK_045...` i sadašnjeg stanja | Sadrži raniju suprotnu odluku | Zadržati audit trag, ali ne aktivni autoritet |
| Schema verzija | `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md` | Meša istorijsku schema 21 closure tačku i sadašnji target 22 | Ažurirati current/historical sekcije |
| PAKETI/licensing | legacy matrice naspram aktuelnih owner dokumenata | Legacy sadržaj postoji, ali noviji dokumenti ga označavaju superseded | Ostaviti kao istoriju; Stage 2 ostaje budući cleanup |
| ZAVRŠEN | aktuelni source/docs naspram nove owner odluke | Source i stari dokumenti još opisuju automatski status | Nova owner odluka mora biti formalno upisana pre implementacije |
| Scenario | docs/source naspram nove owner odluke | Postoji samo default scenario ID i tvrda pravila; novi zahtev traži potpuno korisnički uređive FIRMA templates/defaults i PREDMET-stabilnu istinu | Novi domain/data ugovor i migracija pre UI implementacije |

### 3.4 Predloženi dokumentacioni model

Ne treba održavati tri aktivna “master” skupa.

- `SOURCE/docs` ostaje Git-verzionisani projektni autoritet.
- `[LOCAL PROJECT_DOCS SOURCE]` postaje kontrolisani lokalni mirror **odabranih governance/owner/plan dokumenata**, byte-identičan sa odgovarajućim repo dokumentima.
- `SOURCE/PROJECT_DOCS` se zamrzava kao legacy/historical skup ili postaje automatski generisana read-only kopija; ne sme ostati treći nezavisni autoritet.
- `RESTORE_POINTS` ostaje dokazni/arhivski trag, ne current truth.
- Reconciliation registar beleži putanju, status, autoritet, supersession, hash i datum poslednje provere.

Do owner review-a ovog izveštaja nijedan source/local dokument nije izmenjen.

## 4. Arhitektonska procena

### 4.1 Snage postojeće osnove

- Flutter zajednička osnova za ravnopravne Windows i Android aplikacije.
- Drift/SQLite lokalni model i JSON interchange.
- PREDMET-centričan domain i repositories/services.
- Verzionisan schema/migracioni lanac do 22.
- Značajan automatski testni fond i poslednji dokumentovani kompletan PASS.
- Postoje build varijante kroz `lib/core/config/app_config.dart`, što je moguća osnova za buduće profile, ali još nije country/product architecture.
- `lib/app.dart` već koristi `theme`, `darkTheme` i `ThemeMode.system`; Windows tema je zato pre svega audit stvarnog runtime/kontrasta, ne dokazano nepostojeća funkcija.

### 4.2 Slabosti i koncentracije rizika

Veliki handwritten fajlovi ukazuju na spregu:

- `podesavanja_screen.dart` — oko 2.193 linije;
- `json_export_import.dart` — oko 2.099;
- `parte_composer_screen.dart` — oko 2.024;
- `database.dart` — oko 2.010;
- `lista_predmeta_screen.dart` — oko 1.897;
- `predmet_screen.dart` — oko 1.840;
- pojedinačni segmenti/IRiU tile-ovi — 1.200–1.450 linija.

Ovo samo po sebi ne dokazuje potrebu za rewrite-om, ali povećava rizik regresija, otežava platformsku i scenario politiku i opravdava karakterizacione testove pa ekstrakciju po granicama.

U source-u koegzistiraju legacy i `core_v2` koncepti. Potrebna je jasna mapa koji sloj je authoritative i progresivno uklanjanje duplih puteva tek nakon characterization testova.

### 4.3 SCENARIO: najvažniji arhitektonski jaz

Dokazi:

- `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart` definiše samo `default_funeral_ceremony_policy`;
- `business_policy_evaluator.dart` nepoznat/prazan ID vraća na default;
- stvarni uslovi su tvrdo kodirani u `IriuTruthRules`;
- PREDMET čuva `businessScenarioId`, ali ne čuva verziju/snapshot kompletnog scenarija;
- `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md` i `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md` potvrđuju da trenutni sistem nije multi-scenario engine.

Owner konstanta “SCENARIO je deo PREDMETA” ne može se dugoročno garantovati samo ID-em čija bi pravila kasnije bila promenjena. Potreban je najmanje:

- `ScenarioTemplate` za FIRMA podešavanja i import/export;
- verzija, stabilni identitet i provenance;
- immutable `PredmetScenarioSnapshot` ili sadržinski ekvivalent pri kreiranju/eksplicitnoj promeni PREDMETA;
- prospektivni FIRMA default pojedinačno i kao skup;
- kontrolisana promena samo kod dozvoljenih nezavršenih PREDMETA;
- deterministički IRiU reconciliation plan sa preview-em, konfliktima, potvrdom i audit zapisom;
- potpuna istorijska stabilnost završenih PREDMETA.

Ovo je preporučeni parcijalni rewrite novog domain/configuration sloja, ne rewrite cele aplikacije.

### 4.4 PODSETNIK orphan: dokazani visoki rizik

`ceremony_reminder_settings` ima FK `ON DELETE CASCADE` i čuva OS notification IDs.
`PredmetiRepository.obrisiPredmet` briše PREDMET/bazne redove, ali ne otkazuje prethodno zakazane OS notifikacije. Otkazivanje se nalazi u reminder coordinator reschedule toku.

Mogući rezultat:

1. PREDMET se obriše;
2. cascade ukloni reminder red i izgubi notification ID;
3. Android OS notifikacija ostane zakazana;
4. payload `predmet:<id>` kasnije pokazuje na nepostojeći PREDMET.

Ovo je source-potkrepljen kandidat za prijavljeni orphan i prvi implementacioni integritetni task posle dokumentacionog gate-a. Potrebni su i recovery test za već orphan zakazane notifikacije i definicija šta se radi sa već isporučenim notification history zapisima.

### 4.5 ZAVRŠEN lifecycle

`PredmetiRepository` sadrži `_trebaAutomatskiZavrsiti`, `osveziAutomatskiStatusPredmeta` i masovno osvežavanje statusa na osnovu vremena ceremonije.

Nova owner odluka to superseduje: `ZAVRŠEN` treba da bude eksplicitna korisnička promena, različita od anonimizacije. Pre implementacije treba uskladiti:

- razliku `ZATVOREN` / `ZAVRŠEN`;
- reverzibilnost;
- PODSETNIKE i zakazane notifikacije;
- mogućnost uređivanja;
- scenario promene;
- postojeće automatski završene PREDMETE;
- import starijih JSON zapisa;
- evidenciju datuma/uzroka promene.

### 4.6 IRiU scenario reconciliation

Trenutni sync putevi pretežno dodaju nedostajuće managed redove. Lifecycle sloj za konflikte nudi zadržavanje/uklanjanje kroz korisničku odluku. To objašnjava kako redovi mogu ostati kada uslovi više ne važe.

Pre UI izlaganja scenarija obavezni su:

- inventar svih managed/manual redova i ownership pravila;
- reprodukcija `JAVNO MESTO/NEDEFINISANO`;
- audit `MESTO CEREMONIJE` za polaganje urne;
- deterministička matrica keep/remove/archive/merge;
- očuvanje validnih user-entered cena, količina i napomena;
- preview i potvrda pre destruktivne reconciliation promene;
- testovi ponavljanja, rollback-a i Windows/Android identičnog rezultata.

### 4.7 Windows startup i multiple instance

Windows runner nema dokazanu single-instance zaštitu. `main.dart` pre `runApp` čeka Windows manager inicijalizaciju i Serbian date locale inicijalizaciju; baza se kreira lazy. To nije dovoljno da se uzrok sporog starta pripiše bilo kojoj komponenti.

Zato:

- prvo instrumentisati cold/warm startup milestone-e u release/profiling buildu;
- posebno meriti prozor, konfiguraciju, bazu/migracije, KATALOG, reminders i prvi screen;
- uvesti single-instance zaštitu sa bezbednim prosleđivanjem fokusa/launch intent-a;
- testirati concurrent DB/import/export/migration rizike;
- ne koristiti “sakrij drugi prozor” kao jedini data-integrity mehanizam.

### 4.8 Dokumenti, JSON i RAČUN

- Single-PREDMET JSON export trenutno je prikazan u documents sekciji `predmet_screen.dart`; relokacija u trotačka meni je mala i poslovno pravilna, uz očuvanje schema/interchange testova.
- Nije pronađen samostalan NALOG CVEĆARI generator/export, iako entitlement/module trag postoji. Zato je potreban source/business inventory, ne pretpostavka da je dokument “skoro gotov”.
- Standardni PDF-ovi imaju dokument-specifične layout-e; tipografija mora biti menjana dokument po dokument uz boundary fixtures i vizuelni/štampani owner acceptance.
- PDF RAČUN je trenutno standardno dostupan. Novi FIRMA toggle je jednostavna availability politika. Ne uvoditi PDV, fiskalizaciju, legal-form inference niti promene IRiU računanja.

### 4.9 Lokalizacija, valute i potpisivanje

- Nema pronađenog Flutter l10n/ARB sistema ili `supportedLocales`.
- UI, dokumenti i datumi sadrže tvrdo kodirane srpske stringove.
- Brojni formateri, PDF-ovi i QR sadrže RSD pretpostavke.
- Android release konfiguracija trenutno koristi debug signing config.
- Nije pronađena završena Windows code/installer signing politika.

Zaključak: multilingual/multicurrency nije prevodilački task nego foundation program. Signing je readiness i ownership odluka posle stabilizacije publisher/product identiteta.

## 5. Poređenje razvojnih opcija

| Opcija | Dobit | Rizik/nedostatak | Odluka |
|---|---|---|---|
| Samo ciljane korekcije | Najbrže rešava orphan, startup, PARTE stutter, JSON i PDF | Ne rešava scenario engine, i18n/currency ni velike spregnute fajlove | Potrebno za hitne kvarove, nedovoljno kao ukupan pravac |
| Progresivni refactor | Čuva bazu, testove i prihvaćene rezultate; smanjuje rizik po modulima | Zahteva disciplinu, characterization testove i privremene adaptere | **Preporučeni osnovni pravac** |
| Parcijalni rewrite | Omogućava čist scenario/configuration sloj i zamenu najtežih podsistema | Zahteva compatibility ugovore i migracije | **Preporučen selektivno**, prvo scenario engine/configuration |
| Potpuni rewrite | Potencijalno čist novi dizajn | Najveći migration, parity, runtime i acceptance rizik; ponavlja potvrđene funkcije | **Nije opravdan sada** |

### Rewrite decision gate

Potpuni rewrite može ponovo doći na razmatranje samo ako posle characterization i architecture audita bude dokazano najmanje jedno:

- postojeći data/domain model ne može čuvati PREDMET/scenario istoriju bez nesrazmernog rizika;
- progresivna ekstrakcija ne može obezbediti Windows/Android isti poslovni rezultat;
- merljivi performance/stability ciljevi ne mogu biti dostignuti parcijalnim izmenama;
- trošak kompatibilnog refactora dokazivo premašuje migraciono i acceptance opterećenje novog sistema;
- postoji proverena migracija svih kanonskih baza i JSON formata, sa rollback/recovery planom.

## 6. Product-line preporuka

### 6.1 OPC Srbija

Zadržati i stabilizovati postojeće Windows/Android aplikacije kao Serbia-market product profile:

- srpski latinica i ćirilica;
- postojeća lokalna baza i JSON kompatibilnost;
- srpski business/country profile;
- PREDMET kao jedina istina;
- FIRMA scenario templates/defaults, ali scenario snapshot u svakom PREDMETU;
- isti business result na Windows i Android.

### 6.2 Buduća višejezična verzija

Graditi iz **zajedničkog core/codebase-a**, ne iz dugoročno divergentnih kopija. Odvojiti:

1. UI jezik;
2. pismo;
3. country/business profile;
4. scenario policy/template;
5. dokumente;
6. KATALOG sadržaj;
7. valutu i formatiranje.

Razmatrani jezici: srpski latinica, srpski ćirilica, hrvatski, bosanski, slovenački, crnogorski, makedonski, mađarski, rumunski, bugarski, nemački i engleski. Albanski je izričito van scope-a.

Preporuka je profile/flavor/module pristup u jednom repozitorijumu i jednom shared core-u. Release grane ili tagovi mogu održavati stabilnu Serbia liniju, ali ne treba klonirati domain i migracije. Tačan app ID, naziv, update kanal i marketing verzija zahtevaju owner odluku.

## 7. Owner decision queue

Pre prvog implementation taska:

1. Da li se `e9ea4a9…` formalno usvaja kao operativni baseline i kako se integriše prema `main`?
2. Da li se `SOURCE/docs` usvaja kao Git authority, eksterni `PROJECT_DOCS` kao kontrolisani mirror, a `SOURCE/PROJECT_DOCS` zamrzava kao legacy?
3. Potvrditi supersession `OPC_TASK_045` tvrdnje da Git neće postojati.
4. Zaključati `ZATVOREN`/`ZAVRŠEN` lifecycle, reverzibilnost i posledice po reminders/scenario/edit.
5. Odlučiti tretman postojećih automatski završenih PREDMETA.
6. Odobriti model: FIRMA scenario template/default set + immutable/versioned PREDMET scenario snapshot.
7. Definisati šta eksplicitna promena scenarija sme da ukloni, zadrži ili arhivira iz IRiU.
8. Potvrditi da završeni PREDMET nikada ne prima retroaktivne FIRMA/KATALOG/scenario promene.
9. Odabrati ponašanje RAČUN toggle-a za postojeće instalacije (preporuka: dosadašnja dostupnost ostaje uključena posle migracije, dok je korisnik ne isključi).
10. Definisati poslovni sadržaj NALOGA CVEĆARI i da li je potreban samo PDF ili i DOCX.
11. Potvrditi Serbia product identity i da li multilingual izdanje ima poseban app ID/update kanal.
12. Odrediti da li se country/currency automatika sme ikada osloniti na spoljne kurseve; do tada samo readiness.
13. Odrediti budući publisher/ownership model pre kupovine signing sertifikata.

## 8. Dokumenti koje treba kreirati/ažurirati posle owner review-a

### Novi, byte-identični u oba izvora

Repo:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- `docs/OPC_DOCUMENTATION_GOVERNANCE_AND_RECONCILIATION_REGISTER.md`

Lokalni mirror:

- `[LOCAL PROJECT_DOCS SOURCE]/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`
- `[LOCAL PROJECT_DOCS SOURCE]/OPC_DOCUMENTATION_GOVERNANCE_AND_RECONCILIATION_REGISTER.md`

Za parove evidentirati SHA-256 jednakost.

### Repo dokumenti za ažuriranje

- `docs/OPC_SOURCE_OF_TRUTH_MAP.md`
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`
- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/OPC_IMPLEMENTATION_STOP_LIST.md`
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`
- novi adoption report u `docs/tasks/`

### Lokalni dokumenti za ažuriranje

- `[LOCAL PROJECT_DOCS SOURCE]/00_README_KAKO_KORISTITI.md` — novi authority/mirror model;
- reconciliation registar — klasifikacija svakog aktivnog, historical i superseded dokumenta.

`SOURCE/PROJECT_DOCS` dokumenti se ne brišu bez posebne owner odluke. `OPC_TASK_044`, `OPC_TASK_045` i slični se označavaju superseded/historical, sa vezom ka novoj odluci.

## 9. Stop uslovi

Audit/task mora stati i vratiti se owneru kada:

- local/GitHub dokumenti sadrže nerešen konflikt owner odluke;
- source HEAD ili bazni commit nije dokaziv;
- radno stablo ima neidentifikovane izmene;
- promena može izgubiti PREDMET, scenario snapshot, validni IRiU ili JSON kompatibilnost;
- lifecycle pravilo nije jednoznačno;
- Windows/Android business result ne može ostati jednak;
- audit prelazi u neodobrenu implementaciju;
- migracija nema upgrade, recovery i populated-canonical test;
- zahtev uvodi PDV, fiskalizaciju, poresko ili pravno zaključivanje bez nove owner odluke;
- scope vraća PAKETE/licensing u sadašnji runtime;
- full rewrite se predlaže bez merljivih dokaza i migracionog plana;
- owner runtime nalaz nije odvojen od tehničkog PASS-a.

## 10. Kontrolne i acceptance kapije

Za svaki budući task:

1. **Definiši:** source-learning oba dokumentaciona izvora, source i latest report; zaključaj business pravila, migraciju, parity i stop-list.
2. **Ugradi:** najmanji odobreni scope, bez paralelnog izvora istine.
3. **Potvrdi:** fokusirani testovi; `flutter analyze --no-pub` do finalnog PASS-a; tek zatim kompletan `flutter test --no-pub` do finalnog PASS-a; buildovi samo uz owner odobrenje; odvojeni Windows/Android runtime acceptance.
4. **Zapamti:** task report, owner decision, pseudocode/manifest, migration policy i byte-identična dual-source dokumentacija.

Tehnički PASS nije owner runtime acceptance. Build PASS nije dokaz ispravnog poslovnog rezultata. Dokumentacioni closure nije dozvoljen pre evidentiranja oba nivoa.

## 11. Konačna preporuka

Usvojiti sledeću strategiju:

- odmah: dokumentacioni reconciliation i usvajanje autoritativnog plana;
- zatim: data-integrity/lifecycle kvarovi i merene performance korekcije;
- rano: scenario audit i novi versioned template/snapshot ugovor;
- dalje: progresivna modularna refaktorizacija uz parcijalni rewrite scenario/configuration sloja;
- zadržati Srbiju kao stabilan product profile;
- multilingual graditi kasnije iz istog shared core-a, sa odvojenim jezikom, country profilom, dokumentima, scenario politikom i valutama;
- ne odobriti potpuni rewrite bez kasnijeg dokaznog decision gate-a.

Ovim se čuvaju PREDMET, kanonske baze, Windows/Android ravnopravnost i već owner-potvrđeni rezultati, dok se otvara čist put ka konfigurabilnim scenarijima, stabilnoj Srbiji i budućoj višejezičnoj verziji.

## 12. Evidencioni indeks glavnih preporuka

| Preporuka/nalaz | Tačan source/dokument dokaz |
|---|---|
| Operativni PARTE baseline i owner acceptance | `docs/tasks/OPC_TASK_PARTE_MODULE_SHORTCUT_PREDMET_PARTE_SEGMENT_CORRECTION_REPORT.md`; Git commit `e9ea4a9679f0a9f80521fc3aa362e78b7993d073` |
| `main` politika nije usklađena sa stvarnim stacked task razvojem | `docs/GIT_WORKFLOW_ARC.md`; lokalni `git branch -vv`, `git rev-list --left-right --count HEAD...@{upstream}` i javni GitHub branch/commit pregled od 23.07.2026. |
| Current authority naspram legacy local master konflikta | `docs/OPC_SOURCE_OF_TRUTH_MAP.md`; `docs/OPC_PROJECT_DOCS_PUBLIC_PROMOTION_MAP.md`; `[LOCAL PROJECT_DOCS SOURCE]/00_README_KAKO_KORISTITI.md` |
| Git “nikad” odluka je zastarela | `PROJECT_DOCS/OPC_TASK_045_CODEX_OPERATING_MODE_AUDIT_REPORT.md`; postojanje `.git`, `origin` i javnog `https://github.com/Tale74/OPC` |
| PREDMET/SQLite/JSON/Win–Android konstante | `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`; `docs/OPC_SOURCE_OF_TRUTH_MAP.md` |
| Schema 22 i migracioni lanac 1–22 | `lib/core/database/database.dart:63`; `test/canonical_database_migration_recovery_test.dart:175`; `docs/tasks/OPC_TASK_KATALOG_OSNOVNE_KATEGORIJE_IRIU_AUDIT_IMPLEMENTATION_REPORT.md` |
| Migration policy tekstualna nedoslednost | `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md` — current target 22 naspram kasnijeg istorijskog schema 21 opisa |
| Scenario je samo ID + hard-coded default/rules | `lib/core/database/tables/predmeti_table.dart:12`; `lib/features/predmeti/core_v2/business_policy/business_scenario_id.dart:1`; `lib/features/predmeti/core_v2/business_policy/business_policy_evaluator.dart:62`; `docs/OPC_BUSINESS_POLICY_EVALUATOR_DEEP_AUDIT.md`; `docs/OPC_BUSINESS_POLICY_SCENARIO_MATRIX.md` |
| IRiU sync/reconciliation mora biti korigovan pre scenario UI-a | `lib/features/predmeti/data/iriu_repository.dart:359`; `lib/features/predmeti/presentation/segments/iriu_segment.dart:355`; business rules pod `lib/features/predmeti/core_v2/business_policy/` |
| Orphan reminder root-cause kandidat | `lib/core/database/database.dart:768`; `lib/features/predmeti/reminders/ceremony_reminder_repository.dart:32`; `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart:46`; `lib/features/predmeti/data/predmeti_repository.dart:199` |
| Automatski `ZAVRŠEN` postoji u source-u | `lib/features/predmeti/data/predmeti_repository.dart:95`; isti fajl `:338` i `:360`; poziv iz `lib/features/predmeti/presentation/predmet_screen.dart:202` |
| JSON je sada u Documents sekciji | `lib/features/predmeti/presentation/predmet_screen.dart:1374`; transfer ugovor `lib/core/json_transfer/predmet_json_transfer_core.dart` |
| Windows system theme već postoji u shared source-u | `lib/app.dart:89` |
| Startup traži merenje, a runner nema dokazanu single-instance zaštitu | `lib/main.dart`; `windows/runner/main.cpp`; `windows/runner/flutter_window.cpp` |
| i18n/currency je foundation, ne prevod | nema `l10n`/ARB/`supportedLocales` u `[GIT REPOSITORY ROOT]`; RSD dokazi: `lib/core/format/app_money_format.dart:35`, `lib/features/podesavanja/domain/nbs_ips_qr_payload_builder.dart:104`, `lib/features/predmeti/presentation/segments/iriu_segment.dart:680` |
| Build variant postoji kao početni hook, ne kao gotov country model | `lib/core/config/app_config.dart:4` i `:26` |
| Android release signing nije production-ready | `android/app/build.gradle.kts:37` |
| Progressive refactor/partial rewrite je bolji od full rewrite-a | prethodni migration/test/runtime dokazi plus koncentracija u `lib/features/podesavanja/presentation/podesavanja_screen.dart`, `lib/core/utils/json_export_import.dart`, `lib/features/predmeti/parte/presentation/parte_composer_screen.dart`, `lib/core/database/database.dart`, `lib/features/predmeti/presentation/lista_predmeta_screen.dart` i `lib/features/predmeti/presentation/predmet_screen.dart` |
