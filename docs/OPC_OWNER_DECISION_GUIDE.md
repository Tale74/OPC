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

**Status: `KNOWN CORRECTION DEBT`**
**Decision ID: `OPC-OD-CER-010`**

Odobreno buduće grupisanje:

- `SAHRANA VAN SRBIJE` dodaje `MEĐUNARODNI PREVOZ` i `MEĐUNARODNA DOKUMENTACIJA`.
- `DOČEK POSMRTNIH OSTATAKA` dodaje `BALSAMOVANJE` i `CARGO TROŠKOVI`.

Trenutni source vezuje `BALSAMOVANJE` za `SAHRANA VAN SRBIJE`, dok `DOČEK` dodaje samo `CARGO TROŠKOVI`. Redovi se pri gašenju uslova zadržavaju kao potisnuti/neaktivni. Ovo je: **KNOWN CORRECTION DEBT — NOT FIXED IN THIS TASK**.

Fallback i životni ciklus već prihvaćenih/izvršenih IRIU stavki pri promeni izvora zahtevaju sledeću odluku vlasnika; nema tihe primene CEREMONIJA pravila.

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
