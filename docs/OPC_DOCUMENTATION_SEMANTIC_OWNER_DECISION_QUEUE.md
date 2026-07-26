# OPC — semantic consolidation owner decision queue

**Status:** OWNER REVIEW REQUIRED — NO IMPLEMENTATION — NO DELETION
**Datum:** 26. jul 2026.
**Base SHA:** `bebefd9e3f84a488f97a0ac00e133acc518f0420`

## 1. Kako owner koristi ovaj queue

Nije potrebno pregledati 704 pojedinačna reda. Codex ih je sve mapirao u evidence register. Owner treba da odlučuje samo o sledećim poslovnim klasterima, i to respektivno kada njihov razvojni gate dođe na red.

## 2. Odluke zatvorene 26. jula 2026.

### `ODQ-SCENARIO-001` — promena SCENARIO-a i IRiU reconciliation — `CLOSED`

Owner je zaključio:

- promena SCENARIO-a je dozvoljena samo na `OTVORENOM` PREDMETU;
- korisnik bira drugi postojeći SCENARIO, ne uređuje template u tom toku;
- prikazuje se jedna poslovna potvrda `NASTAVI / ODUSTANI`, bez tehničkog pregleda;
- OPC automatski uklanja neprimenljive IRiU redove i njihove korisničke vrednosti;
- OPC automatski dodaje nove potrebne redove sa praznim korisničkim vrednostima;
- OPC automatski poništava prethodne operativne posledice;
- ako poništavanje trenutno ne uspe, novi SCENARIO ostaje primenjen, a problematični red postaje skriveni interni `RECONCILIATION_PENDING`, isključen iz prikaza i obračuna do automatskog razrešenja;
- raniji eksterni PDF/DOCX fajlovi ostaju netaknuti, a svaki novi derivat koristi aktuelni PREDMET;
- povratak na raniji SCENARIO ne vraća obrisane vrednosti;
- korisnik ne rešava tehničke posledice promene — OPC je odgovoran za usklađivanje.

Završeni PREDMET ostaje istorijski nepromenljiv. FIRMA template/default izmene ostaju prospektivne.

### `ODQ-TERMINOLOGY-001` — `PLATILAC` / `NARUČILAC` — `CLOSED`

Owner je zaključio:

- oba naziva predstavljaju isti poslovni pojam;
- `NARUČILAC` je termin iz rane faze razvoja;
- canonical korisnički termin je `PLATILAC`;
- UI, novi PDF/DOCX i korisnička dokumentacija ne smeju prikazivati `NARUČILAC`;
- legacy DB/JSON kompatibilnost i eventualno interno preimenovanje rešava Codex tehničkim auditom i migracijom bez gubitka starih PREDMETA.

### `ODQ-PREDMET-LOCAL-LOG-002` — individualni JSON i lokalni `logIzmena` — `CLOSED`

Owner je zaključio:

- `logIzmena` ostaje lokalna audit evidencija instalacije;
- individualni PREDMET JSON ne prenosi tuđi `logIzmena`;
- novi import i replacement beleže lokalni događaj sa lokalnim korisnikom i vremenom;
- replacement čuva postojeći lokalni log i dodaje događaj zamene;
- full database backup/restore ostaje odvojena operacija;
- log ne sme postati paralelna poslovna istina PREDMETA.

Current replacement source briše lokalni log i ne beleži događaj zamene. Korekcija je budući tehnički/implementacioni dug, bez izmene aplikacije u Gate 0 dokumentacionom tasku.

## 3. Preostale odluke koje se donose u odgovarajućoj planiranoj etapi

### `ODQ-PREDMET-IDENTITY-001` — `brojPredmeta` i FIRMA scope

- Da li je `brojPredmeta` jedinstven unutar jedne FIRMA/database family?
- Kako UI postupa pri koliziji: blokira, regeneriše ili traži kontrolisanu owner/user odluku?
- Da li single-PREDMET JSON mora nositi FIRMA identity metadata?

### `ODQ-PREDMET-VERSION-002` — version/freshness konflikt

- Koje polje je autoritet za freshness poređenje?
- Kako se tretiraju ista, viša i niža verzija?
- Da li zaštita ostaje warning + explicit keep/replace/cancel ili postoje slučajevi hard block-a?

Do odluke ostaje važeće sadašnje eksplicitno `keep / replace / cancel`; automatsko zamenjivanje ili hard block nije odobren.

Source fact-check je uklonio missing/null/wrong-type `verzija` iz owner queue-a: typed deserialization odbija takav transfer pre DB mutacije. Eksplicitni `verzija >= 1` boundary ostaje tehnički validation/test dug.

### `ODQ-PREDMET-HISTORY-003` — change-log i reopen/import history

- Da li korisnički pregled prikazuje samo značajne lifecycle/import događaje ili i promenjene poslovne oblasti/polja;
- retention i prikaz poslovno vidljivih događaja;
- da li `ZATVOREN → OTVOREN` uvek pravi novi verzijski trag;
- sadržaj budućeg pregleda u `Pregled i potvrda`.

Code-first audit je utvrdio da postojeći snapshot redovi nisu spreman korisnički audit-log: oni sadrže gotovo ceo PREDMET i služe save/version checkpoint mehanizmu. Njihova migracija, privacy zaštita i razdvajanje od audit event-a pripadaju Codex tehničkom domenu.

### `ODQ-PODSETNIK-001` — poslovni tracking model

Potrebno je zaključati:

- šta je automatski izvedeno upozorenje, a šta trajna obaveza PREDMETA;
- complete/reopen/postpone/acknowledge/override prava;
- actor/time/reason/history;
- odnos sa ručnim `ZAVRŠEN`;
- da li otvorene obaveze blokiraju završetak ili samo upozoravaju;
- da li notification action samo otvara PREDMET ili sme potvrditi izvršenje;
- ADMINISTRATOR/SAVETNIK prava i uređivanje sadržaja notifikacija.

### `ODQ-STOCK-BACKUP-001` — STANJE ROBE i backup/import posledice

Potrebno je zaključati:

- da li full backup obavezno nosi sve stock tabele;
- ponašanje starih backup-a bez stock sekcija;
- mismatch/unknown repository identity;
- import/replace reconciliation već izvršenih stock posledica;
- šta se čuva kao unresolved consequence, a šta nikada ne ulazi u single-PREDMET JSON;
- potvrdu da STANJE ROBE nikada ne postaje paralelni PREDMET truth.

### `ODQ-AUTH-001` — PIN/recovery/role lifecycle

Potrebno je current authority dokumentom objediniti ili supersedovati legacy pravila za:

- privremeni reset PIN i obaveznu promenu;
- izbor administratora kada postoji više aktivnih administratora;
- recovery actor/history;
- role prava koja utiču na PREDMET/PODSETNIK radnje.

Tehničko kriptografsko i storage rešenje donosi Codex audit; poslovna prava ostaju owner odluka.

### `ODQ-DOCUMENTS-001` — legacy standard-document pravila

Tokom planiranog document-by-document PDF audita owner potvrđuje:

- koja formation/page-count pravila ostaju obavezna;
- koja stara PDF specifikacija je supersedovana current source rezultatom;
- canonical terminologiju u dokumentima;
- acceptance reprezentativnih maksimalnih sadržaja.

Već zaključano:

- PARTE nisu deo ovog standard PDF audita;
- font se povećava kontrolisano po dokumentu;
- PDF RAČUN dobija FIRMA availability toggle;
- nema PDV, fiskalizacije ni automatske legal-form logike.

## 4. Već razrešeno — owner ne treba ponovo da odlučuje

- PAKETI/licensing legacy runtime politika;
- OPC Web je van trenutnog scope-a;
- PREDMET je jedina poslovna istina;
- Windows/Android parity;
- SCENARIO pripada PREDMETU, a FIRMA daje prospektivne default/template vrednosti;
- završeni PREDMET se ne menja novim SCENARIO/KATALOG pravilima;
- PARTE media retention/deletion prema novijem closure authority-ju;
- ručni pravac statusa `ZAVRŠEN`;
- PDF RAČUN FIRMA toggle bez poreske logike;
- individualni PREDMET JSON ne prenosi `logIzmena`; import/replacement događaji beleže se lokalno;
- Git history rewrite nije odobren.

## 5. Trenutno tražena owner akcija

Neposredno sledeća owner obaveza je `ODQ-PREDMET-HISTORY-003`: odrediti granulat poslovno vidljivog change-log pregleda nakon završenog code-first audita. Ostale odluke mogu ostati vremenski vezane za odgovarajuće etape odobrenog zavisnosnog plana, ali njihovi izvorni dokumenti do tada ne mogu biti uklonjeni.
