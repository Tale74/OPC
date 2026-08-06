# OPC SCENARIO OPERATIONAL RECOVERY

## Status

Rad je na grani `task/OPC-SCENARIO-OPERATIONAL-RECOVERY`, izvedenoj iz javno potvrđenog baseline-a `76c2fd7eec49391a3264a1e45094f3032b5edb51`. Kanonska baza nije otvarana niti menjana.

Početni HEAD je `76c2fd7eec49391a3264a1e45094f3032b5edb51`. Finalni commit SHA još ne postoji: sandbox je odbio upis `.git/index.lock`, pa promene ostaju lokalno necommitovane i nisu push-ovane.

Ovaj report dokumentuje dokazani uzrok i lokalnu korekciju migracije. Windows runtime acceptance i release build nisu proglašeni PASS-om dok kompletan test gate ne završi jasnim exit code-om.

## Dokaz pre korekcije

Korišćena je izolovana kopija stvarne runtime baze `C:\Projekti\OPC\OPC v.1\SOURCE\.scenario_recovery_runtime_copy.sqlite`, izvedena iz `C:\Users\Steva\Documents\opc_v4_release.sqlite`. Kanonska baza je ostala netaknuta.

Ta razvojna kopija je privremeni artefakt ovog taska; nije deo source commita i treba je ukloniti kada Git/filesystem write dozvola bude dostupna.

Na kopiji su neposredno potvrđeni:

- postojeći `OSNOVNI PAKET`: 9 stavki;
- postojeće definicije: 1.021, od toga 1.008 `MAP_` definicija;
- KATALOG: 29 vidljivih kategorija;
- `STAN`, `DOM_ZA_STARE`, `PRIVATNA_BOLNICA`, `DRUGO` i `ULICA_JAVNO_MESTO`: legacy posledice kao `PREPORUČENO`, `order: 0`, bez poslovnog metapodatka;
- `BIOHAZARD`: legacy uslov samo `uzrokSmrti = ZARAZNA` i 11 spojenih posledica, uključujući `CITULJA_NOVOSTI` i `SLIKA`;
- `ensureModuleAndDefaults()` je prekidao na `saveOsnovniPaket()` porukom da `CITULJA_NOVOSTI` istovremeno pripada osnovnom paketu i dodatku scenarija.

Root cause nije generička nespremnost baze. `ensureModuleAndDefaults()` je najpre pokušavao da upiše novi paket od 11 stavki, dok su stari scenariji još sadržali preklapajuće posledice. Migracija scenarija nije mogla da stigne do normalnog split/reconcile koraka, a UI je zato dobijao generičku grešku umesto poslovnog sadržaja.

## Korekcija

`ScenarioModuleRepository.ensureModuleAndDefaults()` sada:

1. ne upisuje novi osnovni paket pre migracije postojećih definicija;
2. legacy paket od 9 stavki vodi kroz isti migracioni transaction kao legacy definicije;
3. pre upisa paketa prepoznaje samo tačno dokumentovani legacy oblik podrazumevanih place/BIOHAZARD definicija;
4. taj oblik vraća na aktuelni `assets/scenario_defaults.json` seed, uz očuvanje statusa i oznake podrazumevanosti;
5. korisnički naziv, druga verzija, drugačiji uslov ili drugačije posledice ne ulaze u taj repair i ostaju korisnički podaci;
6. tek posle reconcile/split koraka upisuje 11-stavkovni paket i materializuje nedostajuće `MAP_` definicije.

Nije menjana vlasnička mapa, poslovni BIOHAZARD tekst, KATALOG seed, PDF kod, kanonska baza ili PREDMET/IRiU lifecycle logika.

## Reprodukcija posle korekcije

Na istoj realistic runtime kopiji, sa asset loaderom koji odgovara runtime putu:

- `ensureModuleAndDefaults()` završava;
- definicija count ostaje 1.021;
- `MAP_` count ostaje 1.008;
- KATALOG count ostaje 29;
- paket postaje 11 stavki;
- `STAN` dobija kanonske required posledice;
- `BIOHAZARD` dobija kanonski `ALL` uslov i samo `SPREMANJE_POKOJNIKA` posledicu;
- mereni scenario ensure na kopiji: približno 0,4 s, a ukupno otvaranje sa SQLite kopijom približno 12–13 s.

## Test evidence

Zeleni ciljano:

- `flutter test test/scenario_module_repository_test.dart --no-pub` — exit 0, 6 testa;
- novi regresioni test pokriva legacy runtime oblik, 9 → 11 paket, 1.008 MAP definicija i BIOHAZARD repair;
- `flutter analyze --no-pub` — exit 0, `No issues found!`.
- scenario/PREDMET/KATALOG integracioni blok (`9` test fajlova) — exit 0, `38` testova prošlo, `1` legacy test skipovan po postojećem policy ugovoru.

Kompletan `flutter test --no-pub --concurrency=1` je pokrenut, ali pokretanje nije dobilo završni zbir ni exit code u 600 s. Ponovljena puna suita bez prisilne serijalizacije i sa `--concurrency=8` takođe nije dobila exit 0 u 900/600 s. Izolovani expanded izlaz pokazuje da je izvršavanje napredovalo u `canonical_database_migration_recovery_test.dart`; pojedinačni `State B` test ipak završava zeleno za približno 51 s. Zato je status `NOT PASS`, a ne PASS. Build nije pokrenut jer quality gate nije kompletno zelen.

## Build/runtime status

Windows i Android release build nisu pokrenuti u ovoj validacionoj sesiji. Nema novog artefakta, timestamp-a ili hash-a koji bi se mogao pošteno prijaviti.

Konačna owner runtime provera ostaje obavezna: pokrenuti aplikaciju nad verifikovanom kopijom kanonske baze i potvrditi `PREDMET → SCENARIO KERNEL → KATALOG → IRiU`, reopen/restart, diff potvrdu i očuvanje ručnih IRiU stavki.

## Verdicts

- `SCENARIO ROOT CAUSE — PROVEN`
- `REALISTIC DATABASE REPRODUCTION — PASS`
- `DATABASE ACCESS — PASS`
- `KATALOG CONNECTION — PASS`
- `1008 MAP DEFINITIONS — PASS`
- `11-ITEM OSNOVNI PAKET — PASS`
- `SCENARIO MODULE OPEN — SOURCE/TEST PASS`
- `PREDMET → SCENARIO → IRiU — NOT REVALIDATED IN THIS TASK`
- `DIFF CONFIRMATION — NOT REVALIDATED IN THIS TASK`
- `MANUAL IRiU PRESERVATION — NOT REVALIDATED IN THIS TASK`
- `REOPEN/RESTART — NOT REVALIDATED IN THIS TASK`
- `EXISTING SCENARIO EDITOR — NOT REVALIDATED IN THIS TASK`
- `NEW SCENARIO WIZARD — NOT REVALIDATED IN THIS TASK`
- `FULL FLUTTER ANALYZE — PASS`
- `FULL FLUTTER TEST — NOT PASS`
- `WINDOWS BUILD — NOT RUN`
- `ANDROID BUILD — NOT RUN`
- `WINDOWS RUNTIME ACCEPTANCE — PENDING OWNER`
