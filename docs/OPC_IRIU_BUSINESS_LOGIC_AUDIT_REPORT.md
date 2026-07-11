# OPC IRIU Business Logic Audit Before Owner Pass

## 1. Namena, autoritet i granica

Ovaj dokument rekonstruiše stvarno postojeću poslovnu logiku segmenta **ROBA I USLUGE (IRIU)**, sa posebnim osvrtom na postojeći dokument **NALOG ZA OPREMANJE**. Audit ne odobrava implementaciju, ne projektuje budući tok i ne popunjava nedostajuće owner odluke pretpostavkama.

Stalna granica:

```text
PREDMET = jedina autoritativna poslovna istina
IRIU = child/business-state sloj PREDMETA koji reaguje na PREDMET činjenice
PDF / JSON / FINANSIJE / STATISTIKA = derivati
PODSETNIK = nema današnji IRIU business-state autoritet
```

Svaki nalaz koristi pet traženih klasifikacija:

- **CURRENT SOURCE BEHAVIOR** — šta source danas radi;
- **EXISTING BUSINESS MEANING** — značenje koje se može dokazati bez nagađanja;
- **OWNER DECISION REQUIRED** — pitanje koje source ne rešava;
- **IMPLEMENTATION IMPACT** — oblasti koje bi buduća odluka zahvatila, bez autorizacije promene;
- **FALLBACK REQUIREMENT** — nedostajući/kontradiktorni podatak, promena uslova, istorija, paket ili nedostupna radnja.

## 2. Izvršni zaključak

IRIU red nema jedno jedinstveno poslovno značenje. Ista tabela trenutno može predstavljati:

1. početni kategorijski placeholder na novom PREDMETU;
2. snapshot izabranog kataloškog artikla;
3. ručno dodat artikal ili uslugu;
4. automatski ubačenu uslovnu stavku;
5. preporučenu stavku;
6. operativno aktivan ili potisnut red;
7. finansijsku stavku kada je aktivna i ima pozitivan iznos;
8. izvor za određene operativne/PDF derivate.

Ne postoji opšti poslovni model `PREUZETO / IZVRŠENO / OTKAZANO / ZAMENJENO`. Polje `cekiran` postoji u tabeli i sirovom PDF snapshot-u, ali nije povezano sa trenutnim UI-em, truth servisom, NALOGOM, završetkom ili dokazom izvršenja. Zato se ne sme tumačiti kao završena radnja.

Najvažniji konflikti/gap-ovi:

- owner je tokom audita potvrdio da je `NALOG ZA OPREMANJE` tačan termin; `NALOG ZA PRIPREMU` u početnom tekstu taska bila je omaška;
- owner-approved buduće grupisanje vezuje `BALSAMOVANJE` za `DOČEK POSMRTNIH OSTATAKA`, dok ga current source vezuje za `SAHRANA VAN SRBIJE`;
- `KOMPLET ZA OPELO` se automatski dodaje kada OPELO postane `DA`, ali se pri `DA → NE` ne potiskuje niti uklanja;
- međunarodni/doček redovi se pri gašenju izvornog uslova čuvaju kao potisnuti, bez business-history događaja i bez potvrde korisnika;
- single-PREDMET JSON prenosi IRIU redove, ali ne prenosi `iriu_lifecycle_decisions`, pa se memorija odbijenih auto-predloga ne prenosi tim kanalom;
- IRIU redovi nisu deo postojećeg `snapshotZaSaveCommit(PredmetiData)`, pa samo IRIU promena nije deo save/confirmed-close poređenja PREDMET polja;
- NALOG ZA OPREMANJE je stateless PDF, ne digitalna pripremna lista i ne readiness model.

Zbog ovih konflikata završna klasifikacija audita je:

`AUDIT PASS — EXISTING SOURCE CONFLICTS REQUIRE OWNER REVIEW`

## 3. IRIU domen i persistence model

### 3.1 Entiteti i odnosi

| Entitet/sloj | CURRENT SOURCE BEHAVIOR | EXISTING BUSINESS MEANING | OWNER DECISION REQUIRED | IMPLEMENTATION IMPACT | FALLBACK REQUIREMENT |
|---|---|---|---|---|---|
| `Iriu` red | Child je PREDMETA preko `predmetId`; cascade delete. Polja: lokalni `id`, nullable `katalogStableArticleId`, `interniNaziv`, editabilni `nazivPrikaz`, tekstualni `kom`, `iznos`, `cekiran`, `redosled`. | Sačuvani PREDMET/IRIU snapshot reda; nije samostalni globalni artikal. | Definisati formalne vrste reda i da li neke vrste postaju obaveze/pripremne akcije. | Model, migracija, UI, JSON, PDF, finansije, istorija. | Nepoznato/legacy poreklo mora ostati čitljivo bez izmišljene klasifikacije. |
| `interniNaziv` | Stabilan kategorijski string pokreće pravila, redosled, katalog, NALOG i stock coverage. | Poslovni discriminator kategorije. | Da li je kategorija dovoljna za budući identity/lifecycle. | Sva pravila i derivati. | Nepoznata kategorija koristi default policy: aktivna, ručno obrisiva, bez auto-upravljanja. |
| `nazivPrikaz` | Snapshot je editabilan i ostaje autoritativni prikaz izbora. | Vidljiva PREDMET vrednost; kasnija promena kataloga je ne prepisuje. | Da li edit posle izvršenja mora biti verzionisan/istorijski. | History/version/PDF/JSON. | Prazno ime pada na kategorijski label u nekim derivatima; ne sme se guessed-relinkovati sa katalogom. |
| `katalogStableArticleId` | Nullable metadata veza ka stabilnom ID-u kataloga; nije FK ni identitet IRIU reda. | Dokaz kataloškog porekla kada postoji; legacy/manual red može biti `null`. | Budući zahtev validacije kada artikal više nije dostupan. | Katalog, stock, import, UI. | Nepoznat imported ID ostaje metadata-only; nema kreiranja ili guessed lokalnog spajanja. |
| `kom` | Slobodan tekst, prikazuje se u dokumentima; ne ulazi u finansijsku formulu niti STANJE ROBE effect. | Informativna/dokumentarna količina. | Da li neke buduće usluge traže funkcionalnu količinu. | Poseban owner/stock dizajn, ne reinterpretacija postojećeg polja. | Nevalidan/prazan tekst ne menja iznos ili zalihu. |
| `iznos` | REAL; pozitivan aktivan red ulazi jednom u `ROBA I USLUGE`; `kom` se ne množi. | Finansijski snapshot reda. | Da li buduća količina menja formulu. | Finance UI/PDF/statistics/tests. | Nula/negativno se isključuje iz finansijske istine, ali red ostaje sačuvan. |
| `cekiran` | Default `false`; source pretraga nije našla UI write/read niti truth upotrebu; sirovi PREDMET PDF ga prikazuje. | Legacy snapshot polje bez dokazanog današnjeg business lifecycle značenja. | Ukloniti, zadržati kao legacy ili formalno definisati — owner/technical decision required. | Schema/JSON/PDF/migration ako ikada bude autorizovano. | Ne koristiti kao completion dokaz. |
| IRIU ekran `NAPOMENA` | UI je prikazuje ispod IRIU redova, ali je čuva u `Predmeti.napomena`, ne u IRIU tabeli. Dokumenti je tretiraju kao `Opšta napomena`. | Opšta PREDMET napomena prikazana na IRIU tački. | Da li budući strukturirani IRIU tok i dalje treba ovu prezentacionu lokaciju; ne menjati bez owner odluke. | PREDMET/UI/PDF/JSON granica. | Ne praviti drugu IRIU kopiju niti je tumačiti kao structured execution history. |
| `iriu_lifecycle_decisions` | Pamti `MANUAL_DELETE` po PREDMETU/kategoriji/scope-u (`MESTO_SMRTI_BLOCK`, `BLOK2`) sa timestamp-om. | Memorija da se upravljana kategorija ne doda ponovo automatski. | Da li je to trajna poslovna odluka, privremeno odbijanje ili samo UX memorija. | Lifecycle/history/transfer. | Full backup je prenosi; single-PREDMET JSON ne — ne tvrditi cross-device kontinuitet. |
| STANJE ROBE effects/consequences | Odvojene tabele prate selection effect i unresolved nedostatak za pokrivene kategorije. | Inventory-owned posledica IRIU izbora, ne drugi PREDMET. | Dalji history/readiness uticaj van postojećeg close blockera. | Stock/PREDMET completion/JSON. | Degradacija/isključenje čuva podatke i samo suzbija operativne radnje. |

### 3.2 Šta IRIU red znači

**CURRENT SOURCE BEHAVIOR:** source ne čuva discriminator tipa reda. Početni, kataloški, ručni, preporučeni i uslovni redovi završavaju u istoj tabeli.

**EXISTING BUSINESS MEANING:** najmanji dokazivi zajednički imenitelj je „sačuvan red robe/usluge povezan sa PREDMETOM, sa vidljivim snapshot sadržajem i mogućim izvedenim posledicama“.

**OWNER DECISION REQUIRED:** ne može se iz source-a zaključiti da svaki red znači planiranu uslugu, obavezu ili izvršenu radnju. Potrebna je formalna klasifikacija po kategorijama/vrstama.

**IMPLEMENTATION IMPACT:** budući model bi morao obuhvatiti persistence, istoriju, JSON, PDF, finance i migraciju bez promene značenja legacy redova.

**FALLBACK REQUIREMENT:** nepoznat red ostaje vidljiv stored snapshot; nema automatskog accepted/completed statusa.

## 4. Kreiranje, ručni unos, izmena, brisanje i redosled

### 4.1 Novi PREDMET

Pri kreiranju novog PREDMETA `inicijalizujIriu` ubacuje sledeći Blok 0 ako odgovarajuća konfiguracija postoji:

```text
SANDUK
OBELEZJE
POKROV_GARNITURA
PESKIR_ZA_KRST
POSMRTNE_PARTE
CRNINA
AGENCIJSKE_USLUGE
CVECE
CITULJA_POLITIKA
+ sve korisničke katalog kategorije
```

- **CURRENT SOURCE BEHAVIOR:** redovi dobijaju `kom = 1`, generički prikazni naziv i uglavnom iznos 0; to nisu nužno izabrani artikli.
- **EXISTING BUSINESS MEANING:** početni kategorijski slotovi/predlozi.
- **OWNER DECISION REQUIRED:** koji su obavezni, koji su samo početna ponuda, i da li user kategorije treba automatski da ulaze u svaki novi PREDMET.
- **IMPLEMENTATION IMPACT:** initialization, ordering, documents, finance, tests.
- **FALLBACK REQUIREMENT:** ako config reda nema, kategorija se preskače; nema fallback kreiranja iz konstante.

### 4.2 Dodavanje i platforma

- `IZ KATALOGA` je dostupno i može dodati više redova iste kategorije.
- Ručni unos je blokiran/skriven u Windows buildu (`kIsWindowsBuild`), dok ga Android/non-Windows tok podržava.
- Ručni `FIKSNA` red dobija jedinstven `RUCNO_<timestamp>` interni naziv.
- Ručni `KATALOSKA` unos prvo kreira korisničku globalnu kategoriju, zatim red PREDMETA.

Klasifikacija:

- **CURRENT SOURCE BEHAVIOR:** platforme nemaju isti create-manual capability; kasnije editovanje i brisanje reda postoji.
- **EXISTING BUSINESS MEANING:** katalog izbor čuva snapshot; ručni unos omogućava lokalnu stavku/kategoriju.
- **OWNER DECISION REQUIRED:** da li je Windows ograničenje namerno i usklađeno sa pravilom platformskog pariteta.
- **IMPLEMENTATION IMPACT:** UI/parity samo posle odluke; core model već prihvata red.
- **FALLBACK REQUIREMENT:** kada primarna kataloška radnja nije moguća, source nema jednak fallback na Windows-u.

### 4.3 Izmena i brisanje

- `nazivPrikaz`, `kom` i `iznos` autosave-uju se direktno u IRIU tabelu.
- Kataloška zamena može promeniti kategoriju, stable ID, naziv i iznos i pokreće stock replacement lifecycle za pokrivene kategorije.
- Brisanje traži potvrdu i fizički briše red; za stock izbor prvo vraća/čisti effect.
- Ručno brisanje managed MESTO SMRTI/BLOK2 reda pamti dismissal; brisanje iz condition-conflict dijaloga namerno ne pamti dismissal.
- Svi policy redovi su `manualDeletionAllowed = true`, uključujući `SANDUK`; „protected anchor“ znači prvi redosled, ne zabranu brisanja.

Klasifikacija:

- **CURRENT SOURCE BEHAVIOR:** nema soft-delete ili opšte istorije reda.
- **EXISTING BUSINESS MEANING:** fizičko brisanje uklanja aktuelni snapshot; samo narrow lifecycle/stock slojevi čuvaju posebnu memoriju.
- **OWNER DECISION REQUIRED:** kada se izvršena/poslovno relevantna stavka sme fizički ukloniti i šta mora ostati kao istorija.
- **IMPLEMENTATION IMPACT:** schema/history/JSON/PDF/ZAVRŠEN.
- **FALLBACK REQUIREMENT:** već izvršena radnja ne sme nestati bez owner-approved istorijskog pravila; current source to ne može dokazati.

### 4.4 Redosled i duplikati

`IriuOrderingService` grupiše poznate sistemske kategorije fiksnim redom, a nepoznate/ručne dodaje posle njih. `SANDUK` je u truth sloju dodatno prvi anchor. Baza nema unique constraint `(predmetId, interniNaziv)`.

- **CURRENT SOURCE BEHAVIOR:** duplikati kategorije su dozvoljeni; auto helper samo proverava da li već postoji makar jedan red.
- **EXISTING BUSINESS MEANING:** više od jednog izbora iste kategorije može postojati i finansije sabiraju svaki aktivan pozitivan red.
- **OWNER DECISION REQUIRED:** one-per-PREDMET pravilo za kategorije i izbor autoritativnog reda za NALOG/PDF.
- **IMPLEMENTATION IMPACT:** repository, migration, builder logic, stock effects.
- **FALLBACK REQUIREMENT:** današnji NALOG mapira po kategoriji i poslednji red u truth redosledu prepisuje raniji; ne sme se pretpostaviti da je to owner-approved izbor.

## 5. Potpuna matrica postojećih uslovnih pravila

| # | Izvorni uslov / owner segment | CURRENT SOURCE BEHAVIOR / posledica | Reversal danas | EXISTING BUSINESS MEANING | OWNER DECISION REQUIRED / FALLBACK REQUIREMENT |
|---|---|---|---|---|---|
| 1 | Novi PREDMET / PREDMET | Umeće Blok 0 i sve user katalog kategorije. | Korisnik može obrisati. | Početni slot/predlog, ne dokaz izbora ili izvršenja. | Obaveznost i missing-config fallback. |
| 2 | `MESTO SMRTI ∈ {STAN, DOM ZA STARE, ULICA / JAVNO MESTO, DRUGO}` / ČINJENICE O SMRTI | Auto-managed: `HLADNJAČA`, `SPREMANJE PREMINULOG LICA`, `IZNOŠENJE`, `PREVOZ DO HLADNJAČE`, `TRANSPORTNA VREĆA`, `PREVOZ DO GROBLJA`. | Aktivni red postaje suppressed; dijalog nudi ZADRŽI/UKLONI. Novi kvalifikovani redovi se mogu automatski ubaciti. | Operativne kategorije izvedene iz mesta smrti. | Da li su obavezne ili predložene; šta znači ZADRŽI suppressed; izvršena radnja/history fallback. |
| 3 | `MESTO SMRTI = BOLNICA` / ČINJENICE O SMRTI | Auto-managed samo `PREVOZ DO GROBLJA`. | Isti conflict flow. | Uži bolnički transportni predlog. | Nepoznata/kontradiktorna lokacija ne sme proizvesti lažnu radnju. |
| 4 | Prazno/drugo neprepoznato mesto smrti | Ne auto-generiše MESTO SMRTI kategorije. | Postojeći managed redovi mogu postati suppressed. | Nema dokazivog pravila. | Owner fallback za nedostajući/novi tip mesta smrti. |
| 5 | `UZROK SMRTI = ZARAZNA` i mesto nije prazno/BOLNICA / ČINJENICE O SMRTI | Aktivnom redu `SPREMANJE PREMINULOG LICA` dodaje `ZARAZNA BOLEST` signal; NALOG ga prikazuje. | Signal nestaje kada uslov prestane; red prati svoje mesto-smrti active stanje. | Biohazard/upozorenje, ne completion. | Postupak, odgovornost i history nisu modelovani. |
| 6 | Nije kremacija i `TIP GROBNOG MESTA = GROBNICA` / CEREMONIJA | `LIMENI ULOŽAK` i `LEMOVANJE` su recommended/auto-managed. Na prvom otvaranju mogu se ubaciti; live promena traži DODAJ/NE DODAJ. | Promena na nekvalifikovano stanje traži ZADRŽI/UKLONI; ZADRŽI = suppressed. | Blok 2 preporuka/operativna potreba potvrđena testovima. | Termin „requires“ u dijalogu naspram mogućnosti `NE DODAJ`; owner mora potvrditi mandatory semantiku. |
| 7 | Nije kremacija i `UZROK SMRTI ∈ {NASILNA, ZARAZNA, NEDEFINISANA}` / ČINJENICE O SMRTI | `LIMENI ULOŽAK` i `LEMOVANJE` bez obzira na GROB/GROBNICA. | Conflict flow kada override prestane. | Override pravilo, test-confirmed. | Nedostajući/kontradiktorni uzrok i izvršena radnja/history. |
| 8 | `VRSTA CEREMONIJE ∈ {KREMACIJA, KREMACIJA_EKSPRES}` / CEREMONIJA | Isključuje preporuku/aktivnost limenog uloška i lemovanja čak i uz override uzrok. | Prelazak iz kremacije ponovo procenjuje i može tražiti dodavanje. | Kremacija ima prioritet nad Blok 2 pravilom. | Owner potvrda posledica ako su stavke već korišćene/izvršene. |
| 9 | `TIP GROBLJA = LOKALNO` / CEREMONIJA | `PREVOZ SPROVODA` je recommended/auto-managed. | Isti Blok 2 add/conflict/dismissal flow. | Lokalno groblje aktivira transportnu preporuku. | Razlika između preporuke i obaveze/readiness uslova. |
| 10 | `OPELO = DA` / CEREMONIJA | Auto-predlaže `KOMPLET ZA OPELO`. | `DA → NE` ne potiskuje, ne briše i ne otvara konflikt; red ostaje aktivan. | Jednosmeran auto-predlog. | **Owner review:** source-change fallback i istorija; postojeći red ne sme biti protumačen kao izvršen. |
| 11 | `SAHRANA VAN SRBIJE = true` / CEREMONIJA | Umeće i aktivira `MEĐUNARODNI PREVOZ`, `MEĐUNARODNA DOKUMENTACIJA`, `BALSAMOVANJE`. | `true → false`: redovi ostaju stored, postaju suppressed, bez dijaloga ili history događaja. | Current international-case grouping. | Konflikt sa owner-approved budućim grupisanjem; accepted/executed/cancellation fallback nije modelovan. |
| 12 | `DOČEK POSMRTNIH OSTATAKA = true` / CEREMONIJA | Umeće i aktivira samo `CARGO TROŠKOVI`. | `true → false`: stored + suppressed, bez dijaloga/history. | Current reception grouping. | Owner future kaže `BALSAMOVANJE + CARGO`; **KNOWN CORRECTION DEBT**. |
| 13 | Bilo `SAHRANA VAN SRBIJE` ili `DOČEK` true / IRIU picker | Picker prikazuje sve četiri međunarodne kategorije. | Picker ih skriva kada su oba false; već sačuvani redovi ostaju. | Availability filter je širi od active pravila. | Korisnik može izabrati red koji će odmah biti suppressed; fallback/UX odluka required. |
| 14 | Kataloški izbor `SANDUK`, `OBELEŽJE`, `POKROV GARNITURA` sa stable ID + aktivno STANJE ROBE | Effect jedinica 1; dovoljna zaliha decrement; nedovoljna zaliha unresolved posledica i close blocker. | Replace vraća/čisti staro i primenjuje novo; delete vraća/čisti. | Inventory posledica izbora; `kom` nije količina zalihe. | Nedostupan artikal: zamena/dopuna/brisanje; package degradation čuva state. |
| 15 | Aktivni red sa `iznos > 0` | Ulazi u `ROBA I USLUGE` finansijsku istinu i statistički total. | Suppression ili non-positive amount ga isključuje. | Finansijska stavka; količina se ne množi. | Formula po količini nije odobrena. |
| 16 | `CITULJA_POLITIKA` / `CITULJA_NOVOSTI` | `documentScopedOut` za LISTA/NALOG item prikaz, ali pozitivan aktivan iznos i dalje može ući u finansijski total. | Red ostaje stored. | Poseban dokument-scope izuzetak, ne finansijski izuzetak. | Owner mora potvrditi očekivanu transparentnost agregata. |

## 6. Truth, lifecycle i promena uslova

### 6.1 Današnja stanja

Truth sloj eksplicitno razlikuje:

```text
stored = red postoji u IRIU tabeli
active = trenutne PREDMET činjenice dozvoljavaju operativnu upotrebu
suppressed = red postoji, ali izvorni uslov više/ne važi
recommended = uslov ga preporučuje
financial counts = active AND iznos > 0
```

Ovo nisu stanja `accepted`, `completed`, `cancelled` ili `replaced`.

### 6.2 Lifecycle po grupama

| Grupa | Created | Accepted | Modified | Completed | Cancelled | Removed | Replaced |
|---|---|---|---|---|---|---|---|
| Blok 0 / katalog / ručni red | insert | NO BUSINESS STATE MODEL IDENTIFIED | direktan update | NO BUSINESS STATE MODEL IDENTIFIED | NO BUSINESS STATE MODEL IDENTIFIED | fizički delete | kataloška reselekcija menja snapshot; stock ima zaseban effect lifecycle |
| MESTO SMRTI managed | auto insert | NO BUSINESS STATE MODEL IDENTIFIED | edit dozvoljen | NO BUSINESS STATE MODEL IDENTIFIED | suppressed nije formalno cancelled | conflict ili ručni fizički delete | nema poslovnog replacement event-a |
| BLOK2 managed | initial auto insert ili live add potvrda | add potvrda nije odvojeno accepted stanje | edit | NO BUSINESS STATE MODEL IDENTIFIED | suppressed nije formalno cancelled | fizički delete/dismissal memory | nema formalnog replacement event-a |
| Međunarodni/doček | auto insert/picker | NO BUSINESS STATE MODEL IDENTIFIED | edit | NO BUSINESS STATE MODEL IDENTIFIED | source-off samo suppressed | fizički delete | nema |
| Komplet za opelo | auto insert/picker | NO BUSINESS STATE MODEL IDENTIFIED | edit | NO BUSINESS STATE MODEL IDENTIFIED | source-off nema lifecycle | fizički delete | nema |
| STANJE ROBE effect | selection effect | operational confirmation pri insufficient selection postoji u UI | replacement lifecycle | applied/resolved je inventory state, ne IRIU business completion | clear/restore/supersede narrow stock statuses | cascade/reconcile | explicit stock replacement effect |

### 6.3 Važna asimetrija prvog otvaranja i live promene

- **CURRENT SOURCE BEHAVIOR:** `initState` sinhronizuje MESTO SMRTI i BLOK2 redove. Već kvalifikovan PREDMET može dobiti redove bez live add dijaloga. Kada se Blok 2 uslov promeni dok je widget montiran, novo dodavanje traži `DODAJ / NE DODAJ`.
- **EXISTING BUSINESS MEANING:** lifecycle zavisi i od načina ulaska u stanje, ne samo od konačnih PREDMET činjenica.
- **OWNER DECISION REQUIRED:** ista činjenica mora imati jednu semantiku bez zavisnosti od UI timing-a/otvaranja.
- **IMPLEMENTATION IMPACT:** orchestration/repository/UI/testovi.
- **FALLBACK REQUIREMENT:** unavailable/dismissed dialog ne sme postati tiha poslovna potvrda; current source može ostaviti red absent ili kasnije auto-sinhronizovan zavisno od putanje.

## 7. NALOG ZA OPREMANJE — dubinski audit

### 7.1 Terminologija

Repozitorijum i owner korekcija saglasno potvrđuju:

```text
NALOG ZA OPREMANJE PDF
nalog_za_opremanje_pdf_data_builder.dart
nalog_za_opremanje_pdf_export.dart
```

- **CURRENT SOURCE BEHAVIOR:** korisnik izvozi stateless PDF `NALOG ZA OPREMANJE`.
- **EXISTING BUSINESS MEANING:** operativni dokument za opremanje, izveden iz PREDMETA i odabranog podskupa IRIU.
- **OWNER DECISION REQUIRED:** nema otvorene odluke o nazivu; owner je potvrdio `NALOG ZA OPREMANJE`. Otvorene ostaju samo njegove buduće lifecycle/readiness veze.
- **IMPLEMENTATION IMPACT:** nema terminološke promene; eventualna buduća proširenja moraju sačuvati potvrđen naziv.
- **FALLBACK REQUIREMENT:** ne uvoditi niti koristiti `NALOG ZA PRIPREMU`; ne predstavljati postojeći PDF kao readiness engine.

### 7.2 Izvori podataka

| Izvor | Polja koja NALOG koristi |
|---|---|
| PREDMET — identitet/smrt | ime, prezime, godina iz datuma rođenja, godina iz datuma smrti, mesto smrti |
| PREDMET — CEREMONIJA | vrsta ceremonije, groblje; fallback opelo mesto; datum/vreme ceremonije |
| PREDMET — lifecycle | broj predmeta, status, verzija, savetnik |
| IRIU — oprema | `SANDUK`, `POKROV_GARNITURA`, `OBELEŽJE`, `PESKIR_ZA_KRST` — prikazni naziv aktivnog/vidljivog reda |
| IRIU — usluge | `SPREMANJE PREMINULOG LICA`, `LIMENI ULOŽAK`, `LEMOVANJE` — `DA` samo ako red postoji i aktivan je |
| IRIU/PREDMET truth | `ZARAZNA BOLEST` badge za spremanje kada biohazard uslov važi |
| FIRMA / app settings | memorandum identitet, kontakt, logo, PIB/MB/Račun |
| Runtime | datum generisanja PDF-a |

NALOG ne koristi iznose, `kom`, `cekiran`, većinu IRIU kategorija, doček mesto/vreme, međunarodne redove, cargo, komplet za opelo, stock consequence, obaveze, izvršenje ili istoriju.

### 7.3 Hidden logic i fallback

| Finding | CURRENT SOURCE BEHAVIOR | EXISTING BUSINESS MEANING | OWNER DECISION REQUIRED | IMPLEMENTATION IMPACT | FALLBACK REQUIREMENT |
|---|---|---|---|---|---|
| Equipment slot | Nedostajući red daje `—`; naziv reda ima prednost nad fallback labelom. | Odabrani/prikazni snapshot za četiri slot kategorije. | Šta ako postoji više redova iste kategorije. | Builder/PDF/testovi. | Danas poslednji mapirani truth red pobeđuje bez objašnjenja. |
| Service DA/NE | Red postoji i active → `DA`; missing ili suppressed → `NE`. | Izvedena prisutnost/aktivnost, ne dokaz izvršenja. | Da li `NE` sme spajati „nije odabrano“, „nije primenljivo“ i „potisnuto“. | Operativna terminologija/builder. | Ne tumačiti `DA` kao completed niti `NE` kao cancelled. |
| Mesto ceremonije | `groblje`; ako prazno `opeloMesto`; ako oba prazna `—`. | Display fallback. | Da li je opelo mesto validna zamena za mesto ceremonije u svim vrstama. | PDF only posle odluke. | Nevalidni/prazni podaci ostaju `—`, nema readiness blokera. |
| Godina | Pokušava izdvajanje godine; ako format nije prepoznat vraća sirovu vrednost. | Display tolerance. | Potrebna stroža dokument validacija? | Builder/format tests. | Nevalidan datum ne blokira izvoz. |
| Potpisi | Štampa prazne linije `Nalog izdao` i `Opremanje izvršio`. | Papirni operativni handoff/signature prostor. | Da li potpis postaje digitalni event i ko je autoritet. | Budući model/history, ne PDF sam. | Trenutni PDF ne vraća potpis/izvršenje u OPC. |
| Export failure | Catch + UI greška. | Tehnički fallback generisanja. | Nema poslovne alternative definisane. | Future UX only. | Nedostupna PDF radnja ne menja PREDMET/IRIU. |

### 7.4 Da li već postoji preparation/readiness logika?

| Pitanje | Nalaz |
|---|---|
| Preparation checklist | NE — fiksne PDF sekcije nisu persisted checklist. |
| Sequencing | NE — redosled štampanja sekcija nije business execution sequence. |
| Required actions | DELIMIČNO/IMPLICITNO — tri usluge se prikazuju DA/NE, ali nema required/accepted/completed stanja. |
| Dependencies | DA, DERIVATIVNO — active/suppressed zavisi od PREDMET činjenica. |
| Deadlines | NE. |
| Operational readiness | NE. |
| Vehicle departure | NE. |
| Ceremony execution confirmation | NE. |
| Historical evidence | Sam generisani fajl može postojati van baze; OPC ne čuva događaj/potpis/rezultat. |

### 7.5 Odnos prema budućem PODSETNIKU

Postojeće PREDMET činjenice, IRIU active/suppressed signal, source-segment ownership i NALOG-ov uski skup operativnih polja mogu biti **ulazni dokaz za budući owner pass**. Sam NALOG PDF ne sme postati autoritet ni jedina kopija zadatka.

PODSETNIK danas nema vezu sa NALOGOM ili IRIU lifecycle-om. Nema stabilne business-obligation ID-jeve, rokove, assignee, confirmation timestamp ili completion history koje bi reminder mogao bezbedno da prati.

## 8. Cross-segment dependency mapa

```text
PREDMET (autoritet)
  ├─ ČINJENICE O SMRTI: mestoSmrti, uzrokSmrti
  ├─ CEREMONIJA: vrstaCeremonije, tipGroblja, tipGrobnogMesta,
  │              opelo, sahranaVanSrbije, docekPosmrtnihOstataka
  └─ STATUSI: nema direktne current-source IRIU generativne zavisnosti
                ↓
       BusinessPolicyEvaluator snapshot
                ↓
       IriuTruthRules + lifecycle services
                ↓
       stored IRIU rows / active / suppressed / recommended
          ├─ FINANSIJE i finansijski PDF
          ├─ STATISTIKA
          ├─ STANJE ROBE consequences
          ├─ NALOG ZA OPREMANJE
          ├─ ostali PDF dokumenti
          └─ JSON transfer/backup
```

### 8.1 Duplirana/skrivena sprega

- CEREMONIJA UI direktno predlaže OPELO/međunarodne/doček redove, a IRIU `didUpdateWidget` ponavlja deo istih triggera.
- IRIU ekran prikazuje opštu `Predmeti.napomena`, pa vizuelna lokacija i data ownership nisu isti.
- Truth aktivacija je centralizovana za međunarodne/doček redove, ali insert triggeri ostaju u presentation slojevima.
- MESTO SMRTI/BLOK2 imaju lifecycle servise; OPELO i međunarodni/doček nemaju isti lifecycle model.
- Lista/finance/statistics koriste truth/financial service, dok PREDMET snapshot PDF prikazuje sirove IRIU redove.
- NALOG koristi fiksno hardkodiran podskup kategorija.

To znači da promena jednog pravila može različito uticati na UI prisutnost, finansije, NALOG, raw snapshot PDF, statistiku i JSON.

## 9. Dokumenti, finance i statistika

| Derivat | Current IRIU ponašanje | Važna granica/fallback |
|---|---|---|
| FINANSIJE | Sabira svaki active red sa `iznos > 0`; ne množi `kom`. | Suppressed i non-positive su isključeni; document-scope citulje nisu finansijski isključene. |
| LISTA / PREDRAČUN / RAČUN / SPECIFIKACIJA | Koriste shared prepared data; item lista izostavlja suppressed i document-scoped citulje, finansijski agregat koristi financial truth. | Prikazana item lista i agregat mogu imati različit scope. |
| PREDMET PDF snapshot | Prikazuje raw IRIU redove, uključujući `cekiran`; finansije iz truth sloja. | Može prikazati stored/suppressed red koji drugi derivat izostavlja. |
| NALOG ZA OPREMANJE | Samo četiri equipment slot-a i tri DA/NE usluge + biohazard. | Nije puna IRIU lista niti readiness dokaz. |
| STATISTIKA | Truth snapshot i financial total; `TOP ARTIKLI` koristi active redove. | Broji pojavljivanje, ne `kom`; scope je statistički derivat. |

## 10. JSON transfer i historical preservation

### 10.1 Single-PREDMET JSON

Prenosi:

- ceo PREDMET row;
- IRIU redove sa svim row poljima, uključujući nullable stable ID, `cekiran` i redosled;
- kontakte;
- bezbedno ograničen unresolved STANJE ROBE consequence blok kada ispunjava transfer pravila.

Ne prenosi:

- `iriu_lifecycle_decisions` dismissal memoriju;
- pun STANJE ROBE ledger/applied-effect istoriju;
- izvedeni active/suppressed/recommended status (ponovo se računa iz PREDMETA);
- poslovni accepted/completed/cancelled history jer takav model ne postoji.

### 10.2 Full backup

Full backup prenosi IRIU redove, `iriuLifecycleDecisions`, katalog/config, logove i STANJE ROBE tabele u okviru svoje backup politike.

### 10.3 Fallback rizik

- **CURRENT SOURCE BEHAVIOR:** single import/replacement rebuild-uje IRIU redove i briše lokalne lifecycle decisions; incoming single payload ih nema.
- **EXISTING BUSINESS MEANING:** snapshot redovi se prenose, UX memorija odbijanja ne.
- **OWNER DECISION REQUIRED:** da li dismissal predstavlja PREDMET poslovnu činjenicu koja mora ići kroz single transfer.
- **IMPLEMENTATION IMPACT:** JSON schema/core/import validation/repository/tests samo posle odluke.
- **FALLBACK REQUIREMENT:** posle single transfera managed row može ponovo biti predložen/ubačen; audit ne sme tvrditi da je odbijanje sačuvano.

## 11. PREDMET lifecycle i ZAVRŠEN

### 11.1 OTVOREN/ZATVOREN

- IRIU se menja samo kada je PREDMET UI enabled (`OTVOREN`).
- Opšti IRIU missing/suppressed/recommended red ne blokira `ZATVOREN`.
- Jedini current close blocker povezan sa IRIU je aktivna unresolved STANJE ROBE posledica, i to samo kada je STANJE ROBE operativno aktivno.

### 11.2 ZAVRŠEN

Automatski `ZAVRŠEN` zavisi od datuma ceremonije koji je pre današnjeg datuma. IRIU active/suppressed, nedostajući red, positive amount, `cekiran`, NALOG ili execution ne učestvuju.

### 11.3 Save/version/change evidence gap

`snapshotZaSaveCommit` prima samo `PredmetiData` i ne uključuje child IRIU redove. IRIU izmene se direktno čuvaju, ali samo IRIU promena nije deo postojećeg PREDMET field snapshot poređenja za saved/unsaved i confirmed-close verzionu odluku.

Klasifikacija:

- **CURRENT SOURCE BEHAVIOR:** child rows su persistent, ali nisu u save/close snapshot-u.
- **EXISTING BUSINESS MEANING:** IRIU je poslovni deo PREDMETA prema arhitektonskoj dokumentaciji, ali lifecycle evidence nije kompletno integrisan.
- **OWNER DECISION REQUIRED:** tačna version/change-log semantika IRIU promena i budućih execution događaja.
- **IMPLEMENTATION IMPACT:** snapshot/version/log/JSON/review — zaseban autorizovan task.
- **FALLBACK REQUIREMENT:** ne prikazivati današnji status/verziju kao dokaz da se IRIU sadržaj nije promenio.

## 12. Readiness i finalni polazak

Current IRIU već poseduje potencijalne ulazne činjenice:

- prisustvo i aktivnost opreme/usluga;
- međunarodni/doček source condition;
- mesto/uzrok smrti kategorije;
- Blok 2 preporuke;
- biohazard signal;
- unresolved STANJE ROBE posledicu;
- ceremony date/time kroz PREDMET, van samog IRIU reda.

Ali current source nema:

- accepted/completed status većine stavki;
- finalnu listu required kategorija;
- validaciju spremnosti vozila/opreme;
- reception completion;
- cross-segment blocker matricu;
- deadline/cutoff;
- manual ili derived `SPREMNO` rezultat;
- istoriju izvršenja/otkazivanja.

Zato se iz sadašnjih redova ne može dokazati readiness ni dozvola polaska. U skladu sa prethodnom owner odlukom, nema osnova za manual override ili silent `SPREMNO`.

## 13. Mandatory fallback matrica

| Situacija | Current fallback | Gap / owner requirement |
|---|---|---|
| Nedostajući source podatak | Pravila uglavnom vraćaju none/suppressed; NALOG prikazuje `—` ili `NE`. | Razlikovati unknown/not-applicable/not-selected; nema lažnog pravnog/operativnog zaključka. |
| Kontradiktorne činjenice | Nema opšte conflict validacije; evaluator primenjuje prioritet koda (npr. kremacija pre override-a). | Owner mora potvrditi prioritete i source navigation. |
| Nevalidan unos | Iznos UI odbija neparsabilan unos; datumi u NALOGU imaju tolerantni raw fallback. | Business validation po poljima/readiness-u nije kompletna. |
| Delimično izvršenje | Nema opšteg execution modela. | Ne izvoditi completion iz stored/active/cekiran/PDF potpisa. |
| Promena source uslova | Managed grupe: suppressed + keep/remove; international/doček: suppressed; opelo komplet ostaje active. | Ujednačen lifecycle, cancellation i historical evidence owner decision required. |
| Već izvršena radnja | Source je ne prepoznaje osim narrow stock effect-a. | Ne brisati/otkazivati bez buduće owner odluke. |
| Timing/deadline | Nema IRIU rokova. | Readiness/cutoff owner decision required. |
| Nedostupna primarna radnja | Windows nema ručni add; PDF failure daje grešku; stock daje dopuna/zamena/brisanje. | Paritet i business alternative required. |
| Package degradation | Core IRIU/PREDMET ostaje; STANJE ROBE disabled/notLicensed čuva state i suzbija efekte/close blocker. | Buduće obaveze/history ne smeju biti obrisane ni skrivene kao jedina kopija. |
| Historical preservation | Raw rows + narrow dismissal/stock logs; fizički delete nema opštu istoriju. | Formalni immutable business history required pre execution modela. |
| Single-PREDMET transfer | Redovi se prenose, lifecycle dismissal memory ne. | Owner mora odlučiti transfer scope pre oslanjanja na tu memoriju. |

## 14. Owner decision queue pre bilo kakve implementacije

1. Klasifikovati svaku IRIU kategoriju: placeholder, izbor, usluga, obaveza, pripremna akcija, informacija ili kombinacija.
2. Odlučiti mandatory/recommended/optional semantiku MESTO SMRTI i BLOK2 kategorija.
3. Potvrditi owner-approved buduće grupisanje međunarodnog/doček seta, posebno `BALSAMOVANJE`.
4. Definisati source-change lifecycle za OPELO komplet, međunarodne, cargo i već izvršene radnje.
5. Definisati accepted/completed/cancelled/replaced status samo tamo gde je poslovno potreban.
6. Odlučiti fizičko brisanje naspram istorijskog zatvaranja.
7. Odlučiti one-per-PREDMET kategorije i duplikat fallback.
8. Definisati IRIU u PREDMET version/change-log/save snapshot-u.
9. Odlučiti da li `iriu_lifecycle_decisions` ide kroz single-PREDMET JSON.
10. Potvrditi Windows/Android parity za ručni unos.
11. Definisati transparentnost PDF/finance scope razlika, naročito citulje.
12. Definisati potpunu Doček/final departure readiness matricu i vehicle/equipment izvore.
13. Tek zatim odrediti šta budući PODSETNIK čita i kako vodi korisnika do PREDMET-owned radnje.

## 15. Implementation stop boundary

Ovaj audit ne autorizuje:

- promenu `Iriu` tabele, schema-e, generated koda ili migracije;
- promenu `IriuTruthRules`, evaluator-a, lifecycle servisa ili UI triggera;
- preimenovanje NALOGA;
- korekciju BALSAMOVANJE/CARGO grupisanja;
- dodavanje accepted/completed/readiness/PODSETNIK toka;
- promenu JSON/PDF/finance/statistics/ZAVRŠEN/version ponašanja;
- nove testove koji bi buduće owner odluke predstavili kao postojeće zahteve.

## 16. Evidence mapa

Glavni inspected source:

- `lib/core/database/tables/iriu_table.dart`
- `lib/core/database/tables/iriu_katalog_config_table.dart`
- `lib/core/database/database.dart`
- `lib/core/constants/iriu_constants.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/core_v2/business_policy/`
- `lib/features/predmeti/core_v2/models/iriu_truth_models.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/pdf/`
- `lib/features/predmeti/statistika_v1/`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/stanje_robe/`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- relevant tests and Git/local continuity documentation.

Evidence status: source-confirmed throughout; Blok 2 critical scenarios, JSON transfer and STANJE ROBE narrow behavior have direct tests. Full international/doček, NALOG semantics, save/version child-row integration and end-to-end runtime behavior remain test/runtime gaps.
