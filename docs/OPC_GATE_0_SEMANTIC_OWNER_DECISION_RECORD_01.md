# OPC — Gate 0 semantic owner decision record 01

**Status:** OWNER DECISIONS CLOSED — DOCUMENTATION AUTHORITY — NO IMPLEMENTATION
**Datum:** 26. jul 2026.
**Base SHA:** `457189396537e0ad0e382030877863620686ccae`
**Task branch:** `task/OPC-GATE-0-SEMANTIC-OWNER-DECISIONS-01`

## 1. Authority

Ovaj dokument beleži direktne owner odgovore u interaktivnom semantic review-u. Ne menja aplikacioni kod i ne tvrdi da je odluka implementirana.

## 2. `ODQ-SCENARIO-001` — CLOSED

### 2.1. Poslovna namera

Korisnik bira poslovne uslove promenom sa jednog postojećeg SCENARIO-a na drugi postojeći SCENARIO. Korisnik ne treba da razmišlja o tehničkim posledicama promene uslova. OPC je odgovoran da samostalno prilagodi IRiU i otkloni posledice prethodnog SCENARIO-a.

Uređivanje ili izrada SCENARIO template-a pripada posebnom toku u PODEŠAVANJA i nije deo promene SCENARIO-a na PREDMETU.

### 2.2. Eligibility

- SCENARIO se može promeniti samo na PREDMETU sa statusom `OTVOREN`.
- PREDMET drugog statusa mora prvo proći eksplicitno ponovno otvaranje sa lifecycle tragom.
- Završeni PREDMET ne menja istorijsku poslovnu istinu bez odgovarajućeg prethodnog lifecycle prelaza.
- FIRMA default/template izmene ostaju prospektivne.

### 2.3. Potvrda

Pre promene OPC prikazuje jednu poslovnu potvrdu:

> OPC će automatski uskladiti IRiU sa novim scenarijem.

Akcije su `NASTAVI` i `ODUSTANI`. Korisniku se ne prikazuje tehnička lista reconciliation posledica.

### 2.4. Automatsko IRiU usklađivanje

Posle `NASTAVI` OPC:

- automatski uklanja sve IRiU redove koji više nisu primenljivi;
- uklanja i njihove ručno unete iznose, napomene i druge korisničke vrednosti;
- ne čuva neaktivnu kopiju uklonjenih vrednosti;
- automatski kreira sve nove redove koje novi SCENARIO zahteva;
- nove redove kreira sa praznim korisničkim vrednostima;
- povratak na raniji SCENARIO ne vraća ranije uklonjene vrednosti.

### 2.5. Operativne posledice

OPC automatski poništava operativne posledice uklonjenog reda, uključujući relevantnu STANJE ROBE posledicu.

Ako poništavanje trenutno ne uspe:

- novi SCENARIO ipak ostaje primenjen;
- problematični red privremeno ostaje kao interni `RECONCILIATION_PENDING`;
- red je skriven iz aktivnog IRiU prikaza;
- red ne učestvuje u finansijskom ili drugom aktivnom obračunu;
- OPC nastavlja automatsko tehničko razrešavanje;
- korisnik ne dobija zadatak da ručno rešava tehničku posledicu.

Retry, atomic persistence, error logging i recovery mehanizam su Codex tehničke odluke, uz obavezno očuvanje ovog poslovnog rezultata.

### 2.6. Derivati

- OPC ne briše niti menja ranije izvezene PDF/DOCX fajlove.
- Svaki novi derivat koristi aktuelni SCENARIO i trenutno stanje PREDMETA.
- Ranije izvezeni fajl nije paralelna poslovna istina.

## 3. `ODQ-TERMINOLOGY-001` — CLOSED

### 3.1. Poslovno značenje

`NARUČILAC` i `PLATILAC` nisu dve poslovne uloge. To je isti poslovni pojam.

`NARUČILAC` je korišćen u ranoj fazi razvoja OPC-a i kasnije je zamenjen terminom `PLATILAC`.

### 3.2. Canonical korisnički termin

Canonical korisnički termin je:

> `PLATILAC`

UI, novi PDF/DOCX derivati i korisnička dokumentacija koriste isključivo `PLATILAC`. Zastareli termin `NARUČILAC` ne prikazuje se korisniku, uključujući prikaz starih ili importovanih PREDMETA.

### 3.3. Tehnička kompatibilnost

Legacy `naru*` DB, model, JSON ili template nazivi mogu privremeno ostati samo kao interni compatibility detalj.

Codex tehničkim auditom odlučuje:

- da li je bezbednija kompatibilna migracija na `platilac*` nazive ili zadržavanje internih legacy ključeva;
- kako se čitaju svi raniji JSON fajlovi i postojeće baze;
- kako se sprečava schema/interchange prekid između Windows i Android aplikacija.

Tehnička odluka ne sme:

- izgubiti ili reinterpretirati podatke postojećeg PREDMETA;
- prikazati korisniku zastareli termin;
- prekinuti backward-compatible JSON/database migraciju;
- stvoriti novu poslovnu ulogu.

## 4. Implementacioni status

Odluke su dokumentaciono zaključane, ali nisu implementirane ovim taskom.

Pre implementacije važe source-learning, migration safety, Windows/Android parity i sukcesivni validation/build gate iz odobrenog plana.
