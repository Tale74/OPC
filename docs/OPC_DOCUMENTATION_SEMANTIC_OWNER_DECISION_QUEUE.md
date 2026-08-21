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

Current replacement source now preserves the destination-local log and records one local `IMPORT_REPLACE` event transactionally with the replacement. New-import event logging remains a separate bounded implementation gap; no PODSETNIK or broader audit policy is implied.

### `ODQ-PREDMET-HISTORY-VISIBILITY-003` — korisnički change-log — `CLOSED`

Owner je zaključio:

- korisnički change-log pripada `Pregled i potvrda`;
- prikazuje značajne lifecycle/import događaje i, gde je korisno, promenjene poslovne segmente;
- ne prikazuje stare/nove sirove vrednosti;
- ne beleži svaki pojedinačni unos;
- tehnički save/version checkpoint ostaje skriven i odvojen.

### `ODQ-PREDMET-VERSION-002` — close-confirmed business version — `CLOSED`

Owner je zaključio:

- novi PREDMET počinje kao `v1`;
- ordinary save je radni checkpoint bez povećanja poslovne verzije;
- reopen sam ne povećava verziju;
- potvrđeno zatvaranje povećava verziju samo posle promene canonical PREDMET aggregate-a;
- zatvaranje bez aggregate promene ne povećava verziju;
- lifecycle/import događaji ostaju odvojeni lokalni log događaji;
- replacement preuzima eksplicitno izabranu uvoznu verziju;
- `exportVerzija` ostaje transfer metadata.

## 3. Preostale odluke koje se donose u odgovarajućoj planiranoj etapi

### `ODQ-PREDMET-IDENTITY-001` — `brojPredmeta` i FIRMA scope — `OWNER POLICY CLOSED / REBINDING IMPLEMENTATION OPEN`

Već zaključano owner odlukom i potvrđeno code-first auditom:

- `brojPredmeta` je jedinstven samo unutar iste FIRMA;
- budući bezbedni scope je `PIB + Matični broj + brojPredmeta`;
- lokalna baza i njeni administratorom odobreni korisnici već predstavljaju FIRMA granicu;
- PREDMET pripada toj FIRMA kroz `savetnikId`/creator vezu sa lokalnim korisnikom;
- single-PREDMET import mora tehnički razrešiti/rebindovati source-local korisničke ID-jeve na aktivnog lokalnog korisnika i ne sme ih tretirati kao prenosivi autoritet;
- koliziju lokalnog generisanja rešava aplikacija atomski, bez prebacivanja tehničke posledice na korisnika;
- mismatch PIB/MB blokira import/restore bez override-a;
- `verzija`, lokalni `id`, filename i export metadata nisu identity ključevi.

Tehnički audit: `docs/OPC_FIRM_SCOPED_PREDMET_IDENTITY_TECHNICAL_AUDIT.md`.

Korekcija: povučeni su predlog novog source-FIRMA identity bloka, same-firm korisnička potvrda i dve pogrešno otvorene owner odluke. Dalji rad je tehnički audit/implementation proof, ne owner business pitanje.

Local-user transfer audit: `docs/OPC_LOCAL_USER_IDENTITY_AND_PREDMET_TRANSFER_REBIND_AUDIT.md`.

Code-first policy boundary and partial audit-history closure:

- source-local `savetnikId`/creator/modifier brojevi nisu prenosivi autoritet;
- novi individualni import trenutno ne radi destination-local rebinding; to ostaje zaseban tehnički successor;
- replacement čuva lokalni tehnički PREDMET id i beleži lokalnog replacement actor-a za `logIzmena`, ali imported adviser/creator/modifier IDs ostaju zasebno otvorena identity/rebinding obaveza;
- full backup ostaje zaseban transfer cele FIRMA/user/PREDMET porodice;
- ovo nije owner-semantic pitanje za `logIzmena`, ali identity/rebinding tehnička provera nije zatvorena ovim taskom.

### `ODQ-PREDMET-HISTORY-004` — retention i završni lifecycle detalji

Status: `CLOSED — TECHNICAL DESIGN COMPLETE — IMPLEMENTATION BLOCKED`.

Code-first closure:
`docs/OPC_PREDMET_LIFECYCLE_LOG_RETENTION_AND_EVENT_TAXONOMY_AUDIT.md`.

Potvrđeno je:

- skriveni checkpoint i korisnički audit event moraju biti odvojeni;
- event/checkpoint retencija traje dok postoji PREDMET, uključujući
  anonimizovani PREDMET;
- anonimizacija ne sme ostaviti legacy raw snapshot PII;
- hard delete uklanja PREDMET i sve njegove event/checkpoint redove;
- minimum taxonomy je `CREATED`, `CLOSED_CONFIRMED`, `REOPENED`,
  `MANUALLY_FINISHED`, `ANONYMIZED`, `IMPORT_NEW`, `IMPORT_REPLACE`;
- individualni JSON ne prenosi lokalni log/checkpoint, dok full backup čuva
  kompletnu lokalnu DB porodicu;
- legacy snapshot prelazi samo u dokazivu row-only coverage oznaku bez
  izmišljene istorije i lažnog business-version inkrementa.

Ne postoji preostala owner odluka za ovaj tehnički mapping.

### `ODQ-PODSETNIK-001` — poslovni tracking model

Orphan-reference integrity is not part of this owner queue and no longer waits
for owner diagnosis. Technical closure:
`docs/OPC_PODSETNIK_ORPHAN_REFERENCE_ROOT_CAUSE_AND_RECOVERY_AUDIT.md`.

Source confirms missing SQLite/OS deletion coordination and full-restore
reconciliation. A future technical implementation may correct those defects
without deciding the expanded business-tracking model below.

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
- korisnički change-log prikazuje značajne događaje i promenjene segmente bez sirovih starih/novih vrednosti;
- business `verzija` nastaje potvrđenim zatvaranjem promenjenog canonical PREDMET aggregate-a, ne ordinary save-om;
- Git history rewrite nije odobren.

## 5. Trenutno tražena owner akcija

`ODQ-PREDMET-VERSION-002` je zatvoren. Preostale owner odluke ostaju vremenski vezane za odgovarajuće etape; Codex prvo razrešava tehnička pitanja iz source-a, testova i migracija.
