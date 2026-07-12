# OPC vodič odluka vlasnika — STATUSI, CEREMONIJA i međusegmentni tok

## 1. Namena i autoritet

Ovaj dokument prenosi odluke vlasnika proizvoda za budući razvoj segmenata **STATUSI** i **CEREMONIJA** i njihovih međusegmentnih zavisnosti. Ne menja trenutno ponašanje aplikacije i nije dozvola za implementaciju.

Oznake koje se koriste u vodiču:

- `CURRENTLY IMPLEMENTED` — potvrđeno u trenutnom source-u.
- `OWNER-APPROVED — NOT YET IMPLEMENTED` — odluka vlasnika, ali još nije deo source-a.
- `PARTIALLY IMPLEMENTED` — deo pravila postoji, ali ne i ceo odobreni model.
- `KNOWN CORRECTION DEBT` — poznato odstupanje koje ovaj task ne ispravlja.
- `OWNER DECISION STILL REQUIRED` — odluka nije doneta; implementacija ne sme da nagađa.
- `FUTURE MODULE POSSIBILITY` — ideja ili granica mogućeg budućeg modula, ne obaveza.
- `SUPERSEDED` — ranija beleška više nije buduće merodavno pravilo.

Kada se trenutno ponašanje i odobreno buduće pravilo razlikuju, oba se navode. Buduće pravilo ne sme biti predstavljeno kao da je već implementirano.

## 2. Obavezno pravilo fallback-a

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-GLOBAL-001`**

Svaka vlasnička ili tehnička odluka mora izričito definisati ponašanje za:

1. nedostajući podatak;
2. kontradiktoran uslov;
3. nevalidan unos;
4. delimično izvršenje;
5. promenu izvornog uslova;
6. vreme ili rok;
7. promenu paketa/entitlement-a;
8. nedostupnu primarnu radnju;
9. istorijski dokaz.

Ako vlasnik još nije odlučio fallback, dokumentacija i implementacioni task moraju upisati `OWNER DECISION STILL REQUIRED`. Nije dozvoljena tiha pretpostavka, automatsko pravno tumačenje, gubitak istorije niti proglašavanje poslovnog završetka na osnovu tehničkog događaja.

## 3. Stalna arhitektonska granica

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED` za budući strukturirani tok; postojeća granica je `PARTIALLY IMPLEMENTED`**
**Decision ID: `OPC-OD-ARCH-001`**

- PREDMET je jedini autoritet za poslovne činjenice, prava, obaveze, njihov status i istoriju.
- PODSETNIK sme da čita, grupiše, prioritizuje, prikazuje i zakazuje. Sme da čuva samo tehničko stanje isporuke/podešavanja.
- PODSETNIK nije drugi PREDMET i ne sme da čuva jedinu kopiju poslovne obaveze.
- Otvaranje, odbacivanje, odlaganje ili potvrda prijema notifikacije nije izvršenje poslovne obaveze.
- Poslovno izvršenje mora biti eksplicitno potvrđeno nad obavezom čiji je autoritet PREDMET.
- Windows i Android moraju primenjivati istu poslovnu logiku; budući Web takođe.
- Promena ili degradacija paketa ne sme da obriše činjenice, obaveze ili istoriju PREDMETA. Nedostupna radnja mora ostaviti čitljivo stanje i bezbedan put povratka kada pravo pristupa ponovo postoji.

## 4. STATUSI — odluke vlasnika

### 4.1 POL i gramatičko/rodno izvođenje BRAČNOG STATUSA

**Status: `PARTIALLY IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-001`**

POL iz PREMINULO LICE utiče na gramatiku i rod u BRAČNOM STATUSU. Početna vrednost pola bračnog druga izvodi se kao suprotna izabranom polu preminulog lica.

Fallback: ako POL preminulog lica nedostaje ili nije jednoznačno razrešen, sistem ne sme da zaključuje pol bračnog druga. Potrebna je korisnička provera. Trenutni source ima podrazumevano izvođenje koje u ovom slučaju može pretpostaviti vrednost; to je konflikt između trenutnog i odobrenog budućeg pravila.

### 4.2 Značenje radnih statusa

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED` (postojeći izbor statusa je `PARTIALLY IMPLEMENTED`)**
**Decision ID: `OPC-OD-STA-002`**

- `PENZIONER SRBIJE`: PIO refundacija i uslovno pravo na porodičnu penziju.
- `VOJNI PENZIONER`: porodična penzija, vojna posmrtna pomoć i izbor vojnih počasti.
- Oba statusa mogu istovremeno biti uključena. Kombinacija daje refundaciju, jedno neduplirano pravo na porodičnu penziju, vojnu posmrtnu pomoć za bračnog druga, izbor vojnih počasti i praćenje prihvaćenih obaveza.
- `U RADNOM ODNOSU`: samo pravo na porodičnu penziju u stanju `NIJE UTVRĐENO` / `DA` / `NE`, uz nezavisno prihvatanje i izvršenje obaveze FIRME.
- `INOSTRANI PENZIONER` i `DRUGO`: savetodavna napomena samo kada je poznata; FIRMA nema prihvaćenu praćenu predaju. Nepoznato pravilo ne sme proizvesti lažni pravni zaključak.

Fallback za nepoznatu/kontradiktornu kombinaciju: ne izvoditi pravo ni obavezu; označiti potrebu za pregledom i sačuvati izvorne statuse.

### 4.3 Jedno organizaciono pravo na porodičnu penziju

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-003`**

Porodična penzija je jedno organizaciono pravo sa više mogućih korisnika: bračni drug, maloletna deca i deca na školovanju. OPC ne otvara upravne predmete, ne vodi dokumentaciju postupka, ne garantuje ostvarenje prava i ne upravlja odlukom nadležnog organa.

`FUTURE MODULE POSSIBILITY`: poseban modul postceremonijalnih usluga može kasnije voditi prošireni postupak, ali to sada nije odobrena funkcionalnost.

Fallback: ako korisnici ili uslovi nisu poznati, pravo ostaje `NIJE UTVRĐENO`; nema automatskog zaključka.

### 4.4 Trostanje prava

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-004`**

Svako pravo ima vrednost `NIJE UTVRĐENO`, `DA` ili `NE`. `NIJE UTVRĐENO` predstavlja otvoreno informisanje/proveru, ali samo po sebi ne blokira status `ZAVRŠEN`.

Fallback: nedostajući, kontradiktoran ili nevalidan unos tretira se kao nerešen za prikaz i pregled, ne kao `DA` ili `NE`.

### 4.5 Nezavisnost prava i obaveze FIRME

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-005`**

Status prava (`NIJE UTVRĐENO` / `DA` / `NE`) i status obaveze FIRME (`NIJE PREUZETA` / `PREUZETA` / `IZVRŠENA — ZAHTEV PREDAT`) nezavisni su. `DA` ne znači da je FIRMA preuzela obavezu, a obaveza može biti preuzeta i dok je pravo `NIJE UTVRĐENO`.

Fallback: delimično popunjena kombinacija ostaje vidljiva u stvarnim stanjima; sistem je ne dopunjava pretpostavkom.

### 4.6 Potvrda predaje zahteva i dva vremenska podatka

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-006`**

Izvršenje znači `ZAHTEV PREDAT` i zahteva:

- obavezan poslovni datum predaje koji korisnik unosi;
- automatski OPC timestamp trenutka potvrde.

Fallback: bez validnog poslovnog datuma potvrda izvršenja nije kompletna. OPC timestamp se ne unosi ručno i ne sme se zameniti poslovnim datumom. Neuspešna ili delimična potvrda ne sme ostaviti lažno izvršeno stanje.

### 4.7 Blokiranje završetka i korekcioni rok

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-007`**

Samo preuzeta, a neizvršena obaveza blokira `ZAVRŠEN`. `NIJE UTVRĐENO`, `NE` i `DA` bez preuzete obaveze ne blokiraju. Posle potvrđene predaje, obaveza ostaje blokirajuća 24 sata radi korekcije, računato od OPC timestamp-a, ne od poslovnog datuma. Po isteku 24 sata više ne blokira ako je zapis validan.

Fallback: nevalidan/nedostajući timestamp ili datum ne pokreće rok; kontradiktoran zapis ostaje blokirajući i usmerava na izvor.

### 4.8 Opoziv

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-008`**

- Preuzeta obaveza može biti opozvana.
- Potvrda `ZAHTEV PREDAT` može biti opozvana u roku od 24 sata.
- Ako se opozove potvrda, a ne obaveza, stanje se vraća na preuzeto/neizvršeno; tajmer se poništava.
- Nova potvrda dobija novi OPC timestamp i novi rok od 24 sata.
- Posle 24 sata PREDMET može završiti ako nema drugih prepreka; korekcija te potvrde je zatvorena.

Istorija opoziva i ponovnih potvrda mora ostati vidljiva. Nedostupna radnja posle roka ne sme menjati istorijski zapis.

### 4.9 Vojne počasti

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED` (trenutno postoji izbor `DA/NE`)**
**Decision ID: `OPC-OD-STA-009`**

Vojne počasti imaju `DA/NE`, pripadaju predceremonijalnom toku i imaju eksplicitno prihvatanje i izvršenje. STATUSI prosleđuje izabranu činjenicu CEREMONIJI na isti način na koji CEREMONIJA dobija uslov za OPELO.

Fallback: bez jednoznačnog `DA` CEREMONIJA ne otvara moguću obavezu; već prihvaćene/izvršene obaveze pri promeni izvora obrađuju se po pravilima iz odeljka 5.7, uz istoriju.

### 4.10 Uklanjanje slobodne napomene radnog statusa

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-010`**

Posle uvođenja strukturiranih prava i obaveza uklanja se slobodno polje `NAPOMENA (radni status)`. Ne uvodi se generička zamena.

Fallback/migracija postojećeg sadržaja nije odlučena: `OWNER DECISION STILL REQUIRED`. Dok se migracija ne odobri, postojeći sadržaj ne sme biti izgubljen.

### 4.11 Preklapajuća kategorija POSTCEREMONIJALNI TOK

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-STA-011`**

Lista dobija preklapajuću kategoriju `POSTCEREMONIJALNI TOK`: aktivne nedovršene stavke prve, završene druge, sa vidljivom istorijom. Isti PREDMET ostaje i u `SVE`, u svom trenutnom statusu i u ovoj kategoriji. Kategorija nije novi status niti novi PREDMET.

Fallback: ako se članstvo ne može pouzdano izvesti, PREDMET ostaje u autoritativnoj statusnoj listi, a kategorija prikazuje razlog nerešenosti bez menjanja statusa.

## 5. CEREMONIJA — odluke vlasnika

### 5.1 Autoritativne činjenice i ulaz iz STATUSA

**Status: `PARTIALLY IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-001`**

CEREMONIJA već čuva činjenice o groblju/tipu, vrsti, datumu i vremenu, opelu, ispraćaju, grobnom/urnskom toku, sahrani van Srbije i dočeku posmrtnih ostataka. Budući model prima i činjenicu `VOJNE POČASTI DA/NE` iz STATUSA.

Fallback: kontradiktorne ili nevalidne činjenice ne smeju stvarati implicitno izvršenu obavezu; korisnik se vraća na izvorni segment.

### 5.2 Moguće predceremonijalne obaveze

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-002`**

- `OPELO = DA` omogućava obaveštavanje parohijskog sveštenika i potvrdu `SVEŠTENIK JE OBAVEŠTEN`.
- `VOJNE POČASTI = DA` omogućava prijavu i potvrdu `VOJNE POČASTI SU PRIJAVLJENE`.
- `OPELO U CRKVI = DA` i `TIP GROBLJA = GRADSKO` omogućavaju potvrdu `CRKVA JE POTVRDILA DA JE TERMIN ZA OPELO SLOBODAN`.

Fallback: bez oba izvorna uslova obaveza nije moguća. Ako se uslov promeni nakon prihvatanja ili izvršenja, primenjuje se odeljak 5.7 i čuva istorija.

### 5.3 Mogućnost nije prihvatanje

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-003`**

Izvorni uslov samo čini obavezu mogućom. FIRMA je mora eksplicitno prihvatiti, a izvršenje eksplicitno potvrditi. Delimična radnja ostaje u stvarnom stanju i ne postaje automatski izvršena.

### 5.4 Timestamp izvršenja

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-004`**

Potvrde izvršenja predceremonijalnih obaveza dobijaju samo automatski OPC timestamp. Ne postoji ručni datum stvarne radnje. Nevalidan/nedostajući timestamp znači da potvrda nije validno kompletna.

### 5.5 Uticaj na ZAVRŠEN i kategoriju

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-005`**

Prihvaćena, a neizvršena predceremonijalna obaveza blokira `ZAVRŠEN`. Sama po sebi ne stvara članstvo u `POSTCEREMONIJALNI TOK`.

### 5.6 Opcija B — prestanak blokiranja

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-006`**

Izvršena predceremonijalna obaveza prestaje da blokira tek kada je potvrđena i kada prođe datum/vreme ceremonije plus 24 sata. Do tog preseka potvrda može biti opozvana; istorija ostaje.

Fallback: bez validnog datuma/vremena ceremonije nema pouzdanog preseka i obaveza ostaje blokirajuća uz upućivanje na CEREMONIJU.

### 5.7 Promena izvornog uslova

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-007`**

- Moguća, neprihvaćena obaveza nestaje kada izvorni uslov prestane.
- Prihvaćena, neizvršena obaveza zatvara se kao otkazana zbog promene izvora, uz istoriju.
- Ako je izvršena, nastaje nova obaveza otkazivanja, a original ostaje u istoriji.

Kontradiktorna ili delimična promena ne sme brisati ni original ni istoriju; zahteva pregled izvora.

### 5.8 Ishod otkazivanja

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-008`**

- Uspeh: `OTKAZIVANJE IZVRŠENO = DA` i automatski timestamp.
- Neuspeh: `POKUŠANO OTKAZIVANJE`, automatski timestamp pokušaja i obavezan razlog; tok se zatvara, istorija ostaje.

Fallback: bez obaveznog razloga neuspešan tok nije kompletan; tehnički neuspeh čuvanja ne sme prikazati završeno otkazivanje.

### 5.9 Promena datuma/vremena ceremonije

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-009`**

Promena zahteva izbor poslovnog događaja: otkazivanje ceremonije, odustajanje porodice ili novi datum. Sistem ne zaključuje događaj sam.

- Otkazivanje/odustajanje: stari događaj postaje neaktivan; neizvršene obaveze se otkazuju, a za izvršene nastaju obaveze otkazivanja.
- Novi datum: stari događaj se zamenjuje novim autoritativnim događajem; uslovi se ponovo procenjuju; stare i nove obaveze/otkazivanja ostaju pravilno povezane i istorijski vidljive.

Fallback: bez korisničkog izbora promena se ne finalizuje. Nevalidan novi termin ne postaje autoritativan.

### 5.10 IRIU zavisnosti

**Status: `CURRENTLY IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-010`**

Owner-potvrđeno i trenutno implementirano grupisanje:

- `SAHRANA VAN SRBIJE` obavezno dodaje `MEĐUNARODNI PREVOZ` i `MEĐUNARODNA DOKUMENTACIJA`.
- `BALSAMOVANJE` pripada `SAHRANA VAN SRBIJE`, uslovno se nudi, nije obavezno i može se ukloniti.
- `DOČEK POSMRTNIH OSTATAKA` dodaje samo `CARGO TROŠKOVI` i ima parametre `MESTO`, `DATUM` i `VREME DOČEKA`.
- `BALSAMOVANJE` nema zavisnost od `DOČEK POSMRTNIH OSTATAKA`.

Redovi se pri gašenju izvornog uslova zadržavaju kao potisnuti/neaktivni, čime se čuvaju postojeće vrednosti i ručne izmene. `KOMPLET ZA OPELO` se na isti način potiskuje kada `OPELO` postane `NE`.

Fallback i životni ciklus budućih prihvaćenih/izvršenih IRIU stavki pri promeni izvora i dalje zahtevaju posebnu odluku vlasnika; ova korekcija ne uvodi takav model.

### 5.11 PARTE kao izvedeni prikaz

**Status: `CURRENTLY IMPLEMENTED`**
**Decision ID: `OPC-OD-CER-011`**

PARTE izvodi podatke iz CEREMONIJE (datum, vreme, groblje, vrsta ceremonije, opelo i ispraćaj). Ovaj skup odluka ne menja ponašanje PARTE. Ako izvorni podaci nedostaju ili su nevalidni, PARTE ne sme postati novi autoritet niti izmišljati vrednosti.

## 6. Međusegmentne odluke i readiness

### 6.1 Konačni polazak vozila je izvedena spremnost

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-XSG-001`**

Konačni polazak vozila je izvedena spremnost, ne ručna check-lista, ne pripada samo jednom segmentu i ne pripada PODSETNIKU.

### 6.2 Nema ručnog override-a

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-XSG-002`**

Nema ručnog override-a. Nedostajući, nerešen, kontradiktoran, nevalidan, neizvršen ili naknadno poništen uslov daje `NIJE SPREMNO`, prikazuje konkretan blocker i vodi korisnika do autoritativnog izvora.

### 6.3 Doček — faza 1

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-XSG-003`**

Spremnost za doček zahteva datum/vreme dočeka i sve povezane uslove/obaveze. Doček mora biti pre ceremonije. Nedostajući ili nevalidan termin znači da ni spremnost za doček ni konačni polazak nisu spremni.

### 6.4 Zatvaranje faze dočeka

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-XSG-004`**

Završetak dočeka je jednostavna eksplicitna ručna potvrda sa automatskim OPC timestamp-om. Tehničko obaveštenje nije potvrda završetka. Neuspešno čuvanje ne sme ostaviti zatvorenu fazu.

### 6.5 Doček — faza 2 / konačni polazak

**Status: `OWNER-APPROVED — NOT YET IMPLEMENTED`**
**Decision ID: `OPC-OD-XSG-005`**

Konačni polazak može biti spreman tek kada je faza 1 zatvorena, doček potvrđen, ostali CEREMONIJA/IRIU/međusegmentni uslovi zatvoreni i nema blockera.

### 6.6 Nerešena puna matrica

**Status: `OWNER DECISION STILL REQUIRED`**
**Decision ID: `OPC-OD-XSG-006`**

Sledeći owner pass za `ROBA I USLUGE / IRIU` mora odlučiti najmanje:

- puni spisak uslova za spremnost dočeka i konačni polazak;
- životni ciklus prihvaćenih/izvršenih IRIU stavki pri promeni CEREMONIJA uslova;
- da li i kako se IRIU izvršenje potvrđuje, opoziva i istorijski čuva;
- koji IRIU nedostaci blokiraju `ZAVRŠEN`, doček ili konačni polazak;
- vremenske preseke i fallback za kašnjenje, delimičan doček i promenu termina;
- ponašanje kada paket više ne omogućava primarnu radnju;
- istorijski prikaz zamenjenih, potisnutih i otkazanih IRIU stavki.

Eksplicitno ostaju nerešeni: kompletna readiness matrica za Doček; kompletna readiness matrica za konačni polazak; IRIU izvršenje i otkazivanje; međunarodni prevoz; međunarodna dokumentacija; balsamovanje; cargo troškovi; spremnost vozila/opreme; i svi dodatni izvorni segmenti koji se naknadno otkriju.

Do te odluke nije dozvoljeno izmišljati punu readiness matricu.

## 7. Trenutni source naspram budućeg modela

Trenutni source:

- podržava višestruki izbor radnih statusa, uključujući istovremeni `PENZIONER SRBIJE` i `VOJNI PENZIONER`;
- čuva prava/pomoći uglavnom kao `DA/NE` booleane i nema odvojenu istoriju prihvatanja/izvršenja;
- ima slobodnu `NAPOMENA (radni status)`;
- određuje `ZAVRŠEN` prema postojećim pravilima, bez novog 24-časovnog modela obaveza;
- nema preklapajuću kategoriju `POSTCEREMONIJALNI TOK`;
- CEREMONIJA nema strukturirane potvrde obaveštavanja/prijave/termina, otkazivanja niti readiness model;
- doček čuva mesto i vreme, ali ne i zaseban datum dočeka;
- PODSETNIK je postojeći reminder tok i nije poslovni autoritet;
- JSON izvozi samo postojeća polja; buduće obaveze i istorija još ne postoje.

Zato je merodavan zaključak ovog dokumentacionog taska:

`DOCUMENTATION PASS — CURRENT SOURCE / OWNER-APPROVED FUTURE RULE CONFLICT RECORDED — IMPLEMENTATION NOT AUTHORIZED`

## 8. PARTE print-preparation and media

**Status: `CURRENTLY IMPLEMENTED — REAL-DEVICE RUNTIME SMOKE PENDING`**

The historical audit findings and queue remain below for traceability. The owner-authorized task `OPC-PARTE-PRINT-PREPARATION-IMPLEMENTATION` resolved their implementation scope without modifying `OPC-OD-CER-011`: PREDMET remains authoritative and PARTE remains derivative.

### 8.1 Current source findings

- Current PARTE stores public-display choices and produces an inline text preview.
- LISTA PDF repeats the text preview as a derivative panel; there is no standalone print-ready PARTE.
- PREDMET already stores identity, dates, gender, title/profession/rank/name choices, ceremony, cemetery, OPELO/send-off, script, symbol ID and mourners.
- Photograph, crop/media identity, template identity, real symbol rendering, standalone artifact and print workflow are absent.
- `parteIme` is stored/transferred but is not currently edited or used by the PARTE composer.
- Current symbol options and individual packaged assets are not a complete one-to-one catalog.
- Current anonymization has no photograph/artifact rule and retains current mourners text.
- `advancedParte` entitlement exists, but current PARTE UI does not consume it.

### 8.2 Historical owner proposals resolved by the implementation task

- prepare a concrete printable death notice/poster from PREDMET;
- support a deceased-person photograph;
- package appropriate symbol assets in OPC and let the user select one;
- minimize retained photo storage;
- consider deletion of an OPC-owned prepared copy after safe generation, or explicit deletion from PARTE;
- preserve equal Windows/Android product meaning.

These proposals became implemented behavior only through the later explicit implementation task; the audit itself was not authorization.

### 8.3 Non-negotiable safety boundary

OPC must never silently modify or delete the user's original external photograph. Any future deletion may target only an OPC-created app-owned copy or temporary file under an owner-approved retention/finalization policy.

Unknown or deleted symbol IDs must not be silently replaced. Long public values must not be silently truncated, ellipsized or fit-compressed.

### 8.4 Historical PARTE audit queue

The following queue IDs are retained as audit navigation IDs, not owner-decision IDs. Their authorized implementation resolution is summarized in 8.5:

- `OPC-PARTE-ODQ-001`: required/optional printed fields and blockers;
- `OPC-PARTE-ODQ-002`: template, paper, margins, font and version strategy;
- `OPC-PARTE-ODQ-003`: grammar fallback for missing/conflicting gender;
- `OPC-PARTE-ODQ-004`: exact public wording, punctuation, cemetery case and `časova`;
- `OPC-PARTE-ODQ-005`: meaning/migration of `parteIme`;
- `OPC-PARTE-ODQ-006`: symbol catalog, default/no-symbol, missing-ID and provenance/license policy;
- `OPC-PARTE-ODQ-007`: photo formats, crop, DPI and quality thresholds;
- `OPC-PARTE-ODQ-008`: app-owned photo storage and portable identity;
- `OPC-PARTE-ODQ-009`: retention, deletion, finalization and regeneration;
- `OPC-PARTE-ODQ-010`: SQLite, single-PREDMET JSON and full-backup media transfer;
- `OPC-PARTE-ODQ-011`: anonymization of photo, mourners and artifacts;
- `OPC-PARTE-ODQ-012`: PDF/image/direct-print delivery boundary;
- `OPC-PARTE-ODQ-013`: long-name/mourners overflow policy;
- `OPC-PARTE-ODQ-014`: package/add-on ownership and downgrade behavior;
- `OPC-PARTE-ODQ-015`: generated artifact metadata and any print-status meaning.

Detailed evidence and fallbacks are in `docs/OPC_PARTE_PRINT_PREPARATION_MEDIA_AUDIT_REPORT.md` and `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md`.

### 8.5 Implemented policy lock

**Status: `CURRENTLY IMPLEMENTED`**
**Decision ID: `OPC-OD-PARTE-001`**

- `PREDMET.partePotrebna` is the authoritative decision that PARTE are required. PARTE never becomes a parallel PREDMET and temporary edits never write back.
- A legitimate entitled open creates or resumes one restart-safe technical preparation. It snapshots the active FIRMA technical template; later default-template changes do not mutate the preparation.
- A changed authoritative PREDMET source is detected and warned about. Temporary edits are not silently overwritten; rebuild is explicit.
- The standard format is a custom `224 × 170 mm` landscape page with a `5 mm` margin. Preview and PDF consume one shared measured render plan. Full text wraps, may reduce only to configured minimum, and unresolved overflow blocks confirmation/PDF; there is no silent clipping, truncation or ellipsis.
- Missing or conflicting gender never defaults silently to male wording. Grammar review/verification is required.
- Symbol terminology is exactly `Standardni simbol iz PARTE kataloga`, `BEZ SIMBOLA`, and `SLOBODAN IZBOR`. The embedded catalog has Davidova zvezda, Katolički, Običan krst, Petokraka, Polumesec and Svetosavski. No-symbol removes/reflows the block; free choice requires an owned custom copy or explicit no-symbol acknowledgement.
- External photograph/custom-symbol originals are read-only and are never moved, modified or deleted. OPC stores only normalized app-owned temporary copies under its support storage. Invalid media is rejected without losing the previous durable copy; low-resolution use requires acknowledgement.
- FIRMA user templates contain technical layout/style only and no case content, media or paths. The built-in template is immutable. ADMINISTRATOR manages templates; SAVETNIK can use the composer but cannot administer templates.
- `advancedParte` is available in POTPUN and in SREDNJI only with the add-on. A downgrade locks mutation without deleting data; re-entitlement resumes the same preparation. OSNOVNI does not initialize it.
- Single-PREDMET JSON carries only the authoritative `partePotrebna` fact and excludes preparation/templates/media. Full backup carries content-free FIRMA user templates/default identity but excludes preparation/media. Dedicated template transfer is versioned and supports replace/copy/cancel conflicts.
- Final preview confirmation and successful current export to `Downloads/KORICE` are mandatory before `PRIPREMA ZAVRŠENA`. A started unfinished preparation blocks manual/automatic completion and anonymization.
- Completion cleanup deletes only app-owned temporary media/state, retains the exported PDF, and records retryable cleanup-pending state on failure.
- Windows and Android share the same persistence, policy, composer and PDF logic; Android narrow UI scrolls and keeps controls reachable.
- `parteIme` fact-check is `FACT CHECK INCONCLUSIVE — PRESERVED, NOT REUSED`: compatibility storage/transfer remains, but the implementation assigns it no guessed filename or business meaning.

Implementation evidence and exact fallback branches are in `docs/OPC_PARTE_PRINT_PREPARATION_PSEUDOCODE.md` sections 20-27 and `docs/tasks/OPC_TASK_PARTE_PRINT_PREPARATION_IMPLEMENTATION_REPORT.md`.
