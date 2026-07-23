# OPC — predlog autoritativnog zavisnosnog plana razvoja

**Status:** DRAFT – OWNER REVIEW REQUIRED
**Autoritativnost:** Dokument još nije odobren niti je deo autoritativnog OPC dokumentacionog skupa. Postaje autoritativan tek po owner odobrenju i kasnijem kontrolisanom upisu u oba dokumentaciona izvora.
**Source baseline grana:** `task/OPC-PARTE-MODULE-SHORTCUT-PREDMET-PARTE-SEGMENT`
**Source baseline SHA:** `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
**Datum audita/nacrta:** 23. jul 2026.
**Poreklo review kopije:** Git review kopija originalnog Codex deliverable dokumenta. Izmena obuhvata standardno zaglavlje i nesadržinsku normalizaciju završnih razmaka potrebnu za `git diff --check`; telo plana nije sadržinski menjano.
**Princip:** ARC–T.A.R.S. — Definiši, ugradi, potvrdi, zapamti.

## 1. Ustav plana

Ove konstante imaju prednost nad rednim brojem svakog programa:

1. PREDMET je jedina autoritativna poslovna istina.
2. SCENARIO je deo konkretnog PREDMETA.
3. FIRMA čuva scenario obrasce/default-e za buduće PREDMETE; promena FIRMA default-a ne menja postojeće PREDMETE.
4. Završen PREDMET je istorijski stabilan prema scenario i KATALOG promenama.
5. Dozvoljeni nezavršeni PREDMET može promeniti scenario samo eksplicitnom kontrolisanom radnjom i bezbednim IRiU reconciliation-om.
6. Windows i Android su ravnopravne, samostalne lokalne aplikacije; OS mehanizam može biti različit, business/data rezultat mora biti isti.
7. SQLite baze i postojeći JSON interchange ostaju kompatibilni kroz aditivne migracije, recovery i populated-canonical testove.
8. PAKETI su napušteni za sadašnji proizvod. Stage 2 uklanja mrtav runtime kod, ali ostavlja čiste capability/module extension points.
9. OPC Web nije current scope.
10. Dokumentacioni reconciliation je prva kapija i horizontalni deo svakog taska.
11. Nema PDV-a, fiskalizacije, poreskog ili pravnog zaključivanja bez posebne owner odluke.
12. Tehnički PASS, build PASS, owner runtime acceptance i dokumentacioni closure su odvojeni događaji.

## 2. Upravljanje planom

Svaka stavka ima status: `PREDLOG`, `ODOBRENO`, `AKTIVNO`, `TEHNIČKI POTVRĐENO`, `OWNER PRIHVAĆENO`, `ZATVORENO`, `ODLOŽENO` ili `SUPERSEDED`.

Promena redosleda je dozvoljena kada novi dokaz promeni zavisnost ili rizik. Izmena plana zahteva:

- razlog i dokaz;
- uticaj na PREDMET/migracije/parity;
- owner odluku;
- identično ažuriranje oba izvora;
- novi hash u reconciliation registru.

## 3. Gate 0 — dokumentacioni i source baseline

### 0.1 Owner adoption

- potvrditi operativni commit `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`;
- odlučiti integraciju task grana prema `main`;
- usvojiti source-of-truth/mirror model;
- formalno supersedovati Git i master dokumentacione konflikte;
- odobriti ovaj plan ili evidentirati korekcije.

### 0.2 Dokumentacioni reconciliation

- inventarisati svaki aktivni governance/owner/architecture/migration dokument;
- klasifikovati `CURRENT`, `SUPPORTING`, `HISTORICAL`, `SUPERSEDED`, `CONFLICT`;
- rešiti current schema 22 formulaciju;
- upisati novu ZAVRŠEN i SCENARIO owner politiku;
- kreirati plan i reconciliation registar u oba izvora;
- potvrditi SHA-256 identičnost;
- ažurirati source-of-truth mapu, stop-list, manifest i current state.

**Gate 0 izlaz:** dokaziv source baseline + jedan current dokumentacioni model + owner-usvojen plan. Bez toga nema implementation taska.

## 4. Program A — integritet podataka i lifecycle

### A1. PODSETNIK orphan i brisanje PREDMETA

**Zašto prvo:** postoji source-potkrepljen put u kome DB cascade briše notification IDs pre nego što OS notifikacija bude otkazana.

Audit/implementacija:

- precizan deletion transaction/lifecycle redosled;
- otkazivanje svih zakazanih OS notifikacija pre gubitka ID-eva;
- idempotentno ponašanje ako OS cancel ili DB korak ne uspe;
- recovery za već orphan payload-e;
- brisanje, anonimizacija, import/restore i restart testovi;
- odvojeni Android OS i Windows in-app mehanizam, isti business result.

Acceptance: nijedna buduća notifikacija ne vodi na nepostojeći PREDMET; nema gubitka validnog PREDMETA pri partial failure-u.

### A2. Ručni `ZAVRŠEN`

Pre koda owner zaključava `ZATVOREN`/`ZAVRŠEN`, reverzibilnost, reminder posledice, uređivanje, scenario i legacy tretman.

Implementacioni smer:

- ukloniti automatsku vremensku tranziciju;
- eksplicitna potvrđena korisnička radnja;
- bez destruktivnih posledica anonimizacije;
- kompatibilan import starih JSON zapisa;
- migracioni/normalization plan samo ako je potreban;
- završen PREDMET ostaje scenario/KATALOG istorijski stabilan.

### A3. Windows single-instance i startup profiling

- release cold/warm milestone merenja;
- baza/migracija/KATALOG/reminder/first-frame profil;
- single-instance guard i fokus/prosleđivanje launch-a;
- concurrent DB/import/export/migration test;
- korekcija samo dokazanih bottleneck-a.

### A4. Android PARTE performance

- profil otvaranja, drag/canvas pan/zoom, repaint, medije i preview;
- Android narrow/wide i slabiji referentni uređaj;
- bez promene owner-prihvaćenog PARTE PDF-a ili poslovnog ponašanja.

**Program A gate:** integritet PREDMETA/reminder-a potvrđen; ručni status dokumentovan i owner-proveren; multiple-instance data risk uklonjen; performanse merene i prihvatljive.

## 5. Program B — scenario istina i IRiU

Program B počinje odmah posle Gate 0 source-learning auditom, ali implementacija schema/model promene čeka closure A1/A2 gde lifecycle zavisnosti dodiruju scenario.

### B1. Potpuni scenario/IRiU audit

- inventar svih hard-coded uslova i default ponašanja;
- reprodukcija `JAVNO MESTO/NEDEFINISANO`;
- audit nepotrebnih IRiU redova posle promene uslova;
- audit `MESTO CEREMONIJE` za smeštaj/polaganje urne;
- managed/manual row ownership;
- matrica zavisnosti PREDMET → SCENARIO → IRiU → dokumenti;
- characterization testovi sadašnjeg ponašanja.

Audit ne menja source.

### B2. Korekcija postojećih scenario bagova

- ispraviti potvrđene greške pre izlaganja scenarija korisniku;
- bezbedni keep/remove/archive/merge IRiU kriterijumi;
- preview i potvrda za potencijalni gubitak user unosa;
- idempotentni reconciliation;
- urn ceremony place kroz owner-potvrđen data/business model;
- Windows/Android identičan rezultat.

### B3. Scenario domain/data contract

Definisati pre UI-a:

- FIRMA `ScenarioTemplate`;
- template verziju, stabilni ID i provenance;
- individualni default i kompletan default set za FIRMA;
- immutable/versioned scenario snapshot u svakom PREDMETU;
- prospective-only primenu;
- explicit-change workflow za dozvoljeni nezavršeni PREDMET;
- završeni PREDMET bez retroaktivne promene;
- import/export schema, validation i konflikt verzija;
- database migration, rollback/recovery i canonical fixtures.

### B4. PODEŠAVANJA scenario UI

- izložiti postojeće korigovane scenarije;
- puna korisnička izmenjivost;
- kreiranje, čuvanje, kopiranje, uvoz/izvoz obrasca;
- pojedinačni default i kompletan FIRMA default set;
- validacija kontradikcija i preview poslovnih posledica;
- pristupačnost i Android narrow/wide/Windows parity.

### B5. PREDMET scenario promena

- dostupna samo kada lifecycle dopušta;
- eksplicitna radnja;
- diff starog/novog scenarija;
- IRiU reconciliation preview;
- potvrda i atomic operation;
- audit/provenance;
- bez promene završenih PREDMETA.

**Program B gate:** scenario više nije samo tvrdi ID; svaki PREDMET nosi stabilnu scenario istinu; FIRMA default-i su prospektivni; scenario templates su prenosivi; IRiU reconciliation ne ostavlja nepotrebne redove niti briše validan user sadržaj bez odluke.

## 6. Program C — dovršavanje PODSETNIKA i signala

### C1. Reminder business model

Posle A1/A2 i B lifecycle pravila:

- aktivan, dospeo, propušten, izvršen, otkazan;
- posledice ZAVRŠEN/anonimizacija/brisanje;
- vreme, zona, restart, reschedule i permission stanje;
- derivat PREDMETA, ne paralelna truth.

### C2. Obaveštenja/notifikacije

- closed-app delivery;
- restart/reboot recovery;
- odbijena dozvola;
- no-duplicate delivery;
- tap vodi na isti postojeći PREDMET;
- Windows i Android jednaka poslovna funkcija uz dozvoljeno različit OS mehanizam.

### C3. Signali popunjenosti segmenata

- orange empty, yellow partial, green complete;
- obavezna ikona/tekst pored boje;
- relevantna, opciona, uslovna i N/A polja;
- scenario-dependent očekivanja;
- IRiU uključivanje;
- računanje iz PREDMETA/IRiU u runtime-u, bez novog skladištenog truth statusa.

## 7. Program D — postojeći dokumenti i PREDMET operacije

### D1. Relokacija single-PREDMET JSON izvoza

- iz `DOKUMENTA` u trotačka meni pregleda PREDMETA;
- bez promene JSON schema;
- Windows/Android interchange i legacy import regression test;
- ostaje odvojeno od izvoza cele baze.

### D2. NALOG CVEĆARI

Prvo poslovno/source mapiranje:

- PREDMET i IRiU izvori;
- obavezni/opcioni sadržaj;
- PDF i eventualni DOCX;
- dugačke vrednosti i boundary data;
- owner acceptance uz reprezentativni primer.

Tek zatim implementacija kao čist derivat.

### D3. Standardni PDF typography audit

PARTE je van scope-a.

Po dokumentu:

- current font/layout inventar;
- minimal/normal/maximal fixtures;
- kontrolisano malo povećanje;
- bez overflow-a, truncation-a, promene formation pravila ili neplaniranog page break-a;
- render diff i owner vizuelna/štampana provera.

### D4. FIRMA toggle za PDF RAČUN

- samo availability;
- preporučeni migration default: uključen za postojeće instalacije radi očuvanja ponašanja;
- kada je isključen, dokument se ne nudi nijednim UI putem;
- ne menja PREDMET/IRiU ni postojeće fajlove;
- nema VAT/legal-form inference-a.

## 8. Program E — cross-platform UI/UX i modularna refaktorizacija

### E1. Sistemska tema audit

Pošto source već koristi `ThemeMode.system`:

- potvrditi Windows runtime promenu teme;
- kontrast, signalne boje, dijalozi, KATALOG, PARTE;
- tema ne menja PDF/DOCX output;
- Windows-only selector samo ako se dokaže platform limitation i owner odobri.

### E2. UI/UX audit

Tri cilja:

- Android narrow;
- Android wide;
- Windows.

Meriti/nalaziti overflow, touch targets, keyboard/mouse, navigaciju, gustinu, modalnost, font, scroll i parity. Audit sam ne odobrava redizajn.

### E3. Progressive refactor

Posle characterization testova:

- razdvojiti velike presentation fajlove;
- razdvojiti JSON serialization, validation, IO i UI orchestration;
- razdvojiti database schema/migrations od domain operacija gde je bezbedno;
- definisati legacy/`core_v2` put i postepeno ukloniti dupliranje;
- održati kompatibilne adapters/repositories tokom prelaza.

### E4. Rewrite re-evaluation gate

Na osnovu merenja i završenog scenario contract-a uporediti targeted/refactor/partial/full opciju. Default ostaje progressive refactor + parcijalni rewrite scenario/config sloja. Full rewrite traži novu owner odluku i kompletan migration/rollback dokaz.

### E5. PAKETI/licensing Stage 2

Tek posle module-boundary audita:

- ukloniti mrtav runtime kod i bypass ostatke;
- očuvati neutralne capability extension points gde imaju dokazanu vrednost;
- sačuvati istorijsku dokumentaciju/Git trag;
- ne ostavljati tajne, ključeve ili aktivna ograničenja.

## 9. Program F — Srbija stabilization i product-line gate

### F1. Serbia release candidate

Posle Programa A–E relevantnih closure-a:

- srpski latinica/ćirilica;
- canonical DB/JSON compatibility;
- Windows/Android parity;
- završeni scenario/PREDMET lifecycle;
- dokumenti i reminders owner-provereni;
- known issues/technical debt evidentirani.

### F2. Owner product-line odluka

Odlučiti:

- stabilni naziv/versioning/app IDs/update kanal;
- održavanje Serbia profile-a;
- zajednički core za buduću multilingual verziju;
- release branch/tag strategiju bez dugoročne duplikacije source-a.

## 10. Program G — multilingual i multicurrency foundation

Počinje tek posle Serbia stabilization i architecture readiness gate-a.

### G1. i18n/l10n readiness

Odvojiti:

- UI jezik i pismo;
- country business profile;
- dokumente;
- scenario templates/policy;
- KATALOG sadržaj;
- datum/broj/adresu;
- font/Unicode/PDF layout.

Jezici: sr-Latn, sr-Cyrl, hrvatski, bosanski, slovenački, crnogorski, makedonski, mađarski, rumunski, bugarski, nemački i engleski. Albanski nije u scope-u.

### G2. Multicurrency readiness

- FIRMA base valuta;
- valuta PREDMETA/stavke;
- originalni i preračunati iznos;
- kurs, izvor, datum i rounding;
- IRiU/dokument/JSON ponašanje;
- RSD/EUR/USD/lokalne valute i dual-currency country profile.

Stop: nema VAT-a, fiskalizacije ili tax logic-a bez owner odluke.

### G3. Multilingual product profile

Preporuka:

- jedan shared domain/data core;
- eksplicitni country/language/document/scenario/currency profili;
- odvojeni release identity samo ako owner/product distribucija to zahteva;
- bez divergentnog kopiranja migracija i PREDMET logike.

## 11. Program H — signing i handover readiness

### H1. Android

- release keystore umesto debug signing-a;
- application ID i update continuity;
- backup/custody/recovery;
- transfer privatnog ključa ili publisher transition plan.

### H2. Windows

- executable i installer signing;
- publisher identity;
- certificate/timestamping/SmartScreen;
- key custody i transfer implikacije.

### H3. Project handover dokumentacija

Završna profesionalna konsolidacija:

- product/domain/architecture;
- source-of-truth i module map;
- DB/migrations/JSON ugovori;
- build/release/signing;
- dependencies/licence/assets;
- security/privacy;
- test strategy;
- known issues/technical debt;
- ADR/pseudocode/runbook;
- owner decisions i development history.

Ovo je završna konsolidacija; kontinuirano dokumentovanje nije odloženo do ove faze.

## 12. Horizontalni task template

Svaki audit/task mora sadržati:

1. exact source commit i branch;
2. pročitane lokalne i GitHub dokumente;
3. konflikt/supersession nalaze;
4. PREDMET authority mapu;
5. Windows/Android parity mapu;
6. DB/JSON/migration impact;
7. out-of-scope i stop uslove;
8. test/validation redosled;
9. owner runtime scenario;
10. dokumente za dual-source ažuriranje.

## 13. Validation gate

Za buduću implementaciju, bez izuzetka:

1. fokusirani testovi tokom razvoja;
2. `flutter analyze --no-pub` do konačnog PASS-a;
3. tek zatim kompletan `flutter test --no-pub` do konačnog PASS-a;
4. tek posle oba PASS-a owner može odobriti buildove;
5. Windows i Android buildovi sukcesivno prema tasku;
6. owner runtime acceptance odvojeno po platformi;
7. dokumentacioni closure i SHA sync tek posle evidentiranog rezultata.

## 14. Stop lista

Odmah stati kada:

- baseline ili authority nije dokaziv;
- owner dokumenti su u konfliktu;
- pojavljuje se gubitak/mutacija istorijske istine PREDMETA;
- migracija nema populated-canonical i recovery dokaz;
- scenario promena može tiho obrisati validan IRiU sadržaj;
- Windows/Android business result divergira;
- task uvodi Web, PAKETE, VAT/fiskalizaciju ili legal inference mimo scope-a;
- audit prelazi u kod bez odobrenja;
- full rewrite nema merljiv dokaz, compatibility i rollback plan.

## 15. Jednolinijski zavisnosni red

**Dokumentacioni/source Gate 0 → PODSETNIK orphan → ručni ZAVRŠEN → Windows single-instance/startup i Android PARTE profiling → scenario/IRiU audit i korekcije → versioned FIRMA templates + PREDMET scenario snapshot → scenario PODEŠAVANJA/import/export/defaulti → završavanje PODSETNIKA i completion signali → JSON relokacija/NALOG CVEĆARI/PDF/RAČUN → tema i responsive audit → progressive refactor + rewrite re-evaluation → Stage 2 licensing cleanup → Serbia stabilization/product-line odluka → i18n/currency foundation → multilingual profile → signing/handover readiness.**

Audit podfaze koje ne menjaju stanje mogu teći ranije, ali nijedna implementacija ne sme preskočiti podatkovnu, lifecycle ili dokumentacionu zavisnost.
