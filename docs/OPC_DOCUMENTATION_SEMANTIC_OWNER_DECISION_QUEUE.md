# OPC — semantic consolidation owner decision queue

**Status:** OWNER REVIEW REQUIRED — NO IMPLEMENTATION — NO DELETION
**Datum:** 26. jul 2026.
**Base SHA:** `bebefd9e3f84a488f97a0ac00e133acc518f0420`

## 1. Kako owner koristi ovaj queue

Nije potrebno pregledati 704 pojedinačna reda. Codex ih je sve mapirao u evidence register. Owner treba da odlučuje samo o sledećim poslovnim klasterima, i to respektivno kada njihov razvojni gate dođe na red.

## 2. Odluke koje neposredno blokiraju dokumentaciono uklanjanje

### `ODQ-SCENARIO-001` — promena SCENARIO-a i IRiU reconciliation

Potrebno je zaključati:

- da li se pre primene novog SCENARIO-a prikazuje pregled redova koji ostaju, menjaju se ili postaju neprimenljivi;
- da li uklanjanje neprimenljivih redova zahteva eksplicitnu potvrdu;
- kako se čuvaju ručno uneti iznosi, napomene i druge validne korisničke vrednosti;
- šta se dešava sa redom koji je već proizveo dokument, stock ili drugu posledicu;
- potvrdu da završeni PREDMET nikada ne prolazi reconciliation.

Dok odluka nije zaključana, legacy pravilo „ne uklanjaj tiho“ i nova obaveza uklanjanja stale redova moraju oba ostati vidljiva kao konflikt koji čeka finalni lifecycle ugovor.

### `ODQ-TERMINOLOGY-001` — `Platilac` / `naručilac`

Potrebno je zaključati:

- canonical korisnički termin;
- da li legacy `naru*` DB/JSON polja ostaju kompatibilni tehnički nazivi;
- da li se radi migracija ili samo UI/document terminology cleanup;
- kako se čitaju prethodno izvezeni JSON fajlovi i stari PREDMETI.

## 3. Odluke koje se donose u odgovarajućoj planiranoj etapi

### `ODQ-PREDMET-IDENTITY-001` — `brojPredmeta` i FIRMA scope

- Da li je `brojPredmeta` jedinstven unutar jedne FIRMA/database family?
- Kako UI postupa pri koliziji: blokira, regeneriše ili traži kontrolisanu owner/user odluku?
- Da li single-PREDMET JSON mora nositi FIRMA identity metadata?

### `ODQ-PREDMET-VERSION-002` — version/freshness konflikt

- Koje polje je autoritet za freshness poređenje?
- Kako se tretira missing/malformed verzija?
- Kako se tretiraju ista, viša i niža verzija?
- Da li zaštita ostaje warning + explicit keep/replace/cancel ili postoje slučajevi hard block-a?

Do odluke ostaje važeće sadašnje eksplicitno `keep / replace / cancel`; automatsko zamenjivanje ili hard block nije odobren.

### `ODQ-PREDMET-HISTORY-003` — change-log i reopen/import history

- Koji poslovni događaji ulaze u history;
- retention i prikaz;
- da li `ZATVOREN → OTVOREN` uvek pravi novi verzijski trag;
- kako replacement import čuva prethodno stanje i actor/time/reason;
- da li se history prenosi single-PREDMET JSON-om.

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
- Git history rewrite nije odobren.

## 5. Trenutno tražena owner akcija

Za nastavak dokumentacionog Gate 0 potrebno je najpre odgovoriti na:

1. `ODQ-SCENARIO-001`;
2. `ODQ-TERMINOLOGY-001`.

Ostale odluke mogu ostati vremenski vezane za odgovarajuće etape odobrenog zavisnosnog plana, ali njihovi izvorni dokumenti do tada ne mogu biti uklonjeni.
