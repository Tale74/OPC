# OPC SCENARIO — nova implementacija i validacija

Datum: 2026-08-05  
Branch: `task/OPC-SCENARIO-NOVA-IMPLEMENTACIJA`  
Baseline: `19dcc68d580c086d9cc74921afa5af8381b9872d` (`task/OPC-SCENARIO-FORENSIC-AUDIT`)

Restore commit: `8e8ae6bf8eac459ba35879c25a42a27d6031796a`  
Public branch: `origin/task/OPC-SCENARIO-NOVA-IMPLEMENTACIJA`

## Outcome

SCENARIO je implementiran kao jedinstveni owner-policy kernel koji iz potpunih uslova PREDMETA određuje jednu dozvoljenu kombinaciju, osnovni paket, posledice, statuse, poreklo i redosled. Kernel pokriva 1.008 jedinstvenih kombinacija: 864 standardne i 144 DOČEK kombinacije.

`STAN`, `DOM_ZA_STARE`, `ULICA_JAVNO_MESTO`, `PRIVATNA BOLNICA`, `DRUGO` i `BOLNICA` imaju nezavisne ključne definicije. `PROMENA_SANDUKA` je DOČEK uslov, a ne novi scenario. `LIMENI_ULOZAK` i `LEMOVANJE` imaju odvojene definicije, perzistenciju, provenance i poslovne posledice. BIOHAZARD zadržava postojeći prikaz i upozorenje.

OSNOVNI PAKET sada ima 11 kategorija:

`SANDUK`, `OBELEZJE`, `POKROV_GARNITURA`, `PESKIR_ZA_KRST`, `POSMRTNE_PARTE`, `CRNINA`, `CVECE`, `CITULJA_POLITIKA`, `CITULJA_NOVOSTI`, `SLIKA`, `AGENCIJSKE_USLUGE`.

## Runtime and persistence

- PREDMET automatski poziva SCENARIO kada su uslovi potpuni; nema ručnog dugmeta za primenu.
- Tačna `MAP_*` definicija se čita iz perzistiranih editabilnih podataka.
- Već dodeljeni PREDMET čuva `ScenarioAssignmentSnapshot`; kasnija izmena definicije nije retroaktivna.
- Promena potpune kombinacije prvo prikazuje diff. IRiU i snapshot ostaju nepromenjeni do potvrde korisnika.
- Nakon potvrde dodaju se nove stavke, a stavke koje izlaze iz rezultata čekaju odluku `ZADRŽI RED` / `UKLONI RED`.
- Ručno dodate, legacy i dismissed stavke nisu predmet tihih brisanja ili ponovnog dodavanja.
- Nerazrešiv `KORISNIK_*` je integrity error; nema `DODATNA_STAVKA` fallback-a.

## UI and platform parity

SCENARIO ekran koristi poslovne filtere i otvara jednu potpunu kombinaciju umesto liste od 1.008 redova. Editor i wizard koriste poslovne uslove, sa responsive rasporedom za Windows i vertikalnim/narrow tokom za Android. Tehnički NADUSLOV/PODUSLOV editor nije izložen u novom toku.

## Database and migration

- Dodat je `predmeti.promena_sanduka` sa additive/idempotent migracijom.
- Schema version je podignuta sa 25 na 26.
- `database.g.dart` je regenerisan.
- KATALOG dobija `SLIKA` i `ZASTITNA_I_DODATNA_OPREMA` identitete.
- Migracije čuvaju postojeće redove, validne korisničke izmene, manual IRiU i postojeće PREDMET snapshot-e; kanonska baza nije otvarana niti menjana.

## Validation evidence

- `C:\flutter\bin\flutter.bat analyze` → `No issues found!` (exit code 0; završno ponavljanje 108.6 s).
- `C:\flutter\bin\flutter.bat test --concurrency=1` → `+368 All tests passed!` (exit code 0; završni prolaz).
- Ciljani scenario/KATALOG/lifecycle regresioni blok → `+13 All tests passed!`.
- Migracioni fixture test proverava praznu bazu, checkpoint-e 1–24, malformed stanja, schema 26 i retry posle DDL greške.

Tokom validacije pronađena su i ispravljena zastarela očekivanja schema 25 i starog devetostavkovnog paketa, kao i fallback ponašanje legacy lifecycle testova za nepotpun PREDMET. Nije menjana poslovna odluka iz owner mape.

## Scope boundaries and remaining acceptance

- PDF derivati nisu menjani.
- Windows/Android build nije pokrenut u ovom tasku.
- Windows runtime acceptance nad proverljivom kopijom kanonske baze ostaje odvojena faza.
- Radno stablo je čisto nakon commit/push koraka; restore commit je javno vidljiv na navedenoj grani.

## Authoritative pseudocode

`docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md` je ažuriran da opiše 11-stavkovni osnovni paket, 1.008 owner-map ključeva, automatski PREDMET→IRiU tok, snapshot, diff potvrdu i KATALOG integrity pravila.
