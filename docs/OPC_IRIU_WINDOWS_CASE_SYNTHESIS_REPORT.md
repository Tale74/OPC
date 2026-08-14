# Sintezni izveštaj slučaja: IRiU redosled i Windows startup mutacija

Datum: 14.08.2026.

Ovaj izveštaj spaja nalaze iz:

- `OPC_SOL_MEDIUM_IRIU_PRODUCTION_TEST_ORDERING_DISCREPANCY_AUDIT_TASK.md`;
- `OPC_SOL_MEDIUM_WINDOWS_RUNTIME_STARTUP_MUTATION_FORENSIC_AUDIT_TASK.md`;
- prethodnog implementation izveštaja `OPC_IRIU_SHARED_DERIVED_ORDERING_IMPLEMENTATION_REPORT.md`;
- aktuelnog Windows audit izveštaja i evidence manifesta.

## 1. Sažetak

Slučaj ima dve odvojene teme koje su se u prethodnim zaključcima pomešale:

1. **IRiU redosled**: izvorni/shared ordering kod i aktuelni runtime snimci daju jedan redosled, ali vlasnička tvrdnja da to još nije “traženi” redosled znači da runtime acceptance ne sme biti proglašen završenim dok se ne potvrdi autoritativna ciljna sekvenca.
2. **Startup mutacija**: otvaranje `Roba i usluge` reprodukuje tehničku promenu `updated_at` na tačno 36 `scenario_definitions` redova, bez promene poslovnog sadržaja. Uzrok i caller su dokazani.

Najvažnija korekcija prethodnog izveštavanja je evidencijska, ne kodna: moji Computer Use snimci nisu bili isti fajlovi kao noviji korenski `RUNTIME\IRIU1.PNG` i `IRIU2.PNG`. Nakon direktnog poređenja, njihovi vidljivi redosledi se poklapaju. Stara mapa `RUNTIME_10_ (OLD)` sadrži raniji, drugačiji redosled i ne sme se mešati sa novijom root evidencijom.

## 2. Tri grupe vizuelne evidencije

| Grupa | Vreme | Sekvenca | Status |
|---|---:|---|---|
| `RUNTIME\RUNTIME_10_ (OLD)\IRIU1.PNG` + `IRIU2.PNG` | 06:37 | `Crnina` i `Ešarpa` na kraju, posle `Komplet 80` | stari istorijski dokaz; drugačiji redosled |
| `RUNTIME\OPC_WINDOWS_STARTUP_MUTATION_20260814\iriu_*` | 16:49–17:09 | `Crnina`, `Ešarpa` na pozicijama 3–4 | Computer Use lifecycle snimci |
| korenski `RUNTIME\IRIU1.PNG` + `IRIU2.PNG` | 17:43–17:44 | `Crnina`, `Ešarpa` na pozicijama 3–4 | novija vlasnička dopunska evidencija |

Stari fajlovi imaju SHA-256:

- `RUNTIME_10_ (OLD)\IRIU1.PNG`: `317DCECE679FDAAD5FE344C55B7F986C19D2508AC27D4E6637C928C5DB684B80`;
- `RUNTIME_10_ (OLD)\IRIU2.PNG`: `7D7D041D36367AA3A0CFBF96CAE49A799234D3CDC69D1B939A9731195249013D`.

Noviji korenski fajlovi imaju SHA-256:

- `RUNTIME\IRIU1.PNG`: `B5A68989F49F7CEEAEC26A30D1018F260D01E6467A424E0FE8F7CABD87AE1ED6`;
- `RUNTIME\IRIU2.PNG`: `3EC3694DE8C31A3A5D9B0FD02F579098FB8EF1946BDEB54F6BBD434704C53E02`.

`IRIU2.PNG` iz novije root grupe ima vidljiv “Full-screen Snip” overlay i ne pripisuje se mojoj Computer Use sesiji.

## 3. Redosledi koji su stvarno viđeni

### 3.1 Stara `RUNTIME_10_ (OLD)` grupa

Kombinovani redosled iz starih slika je:

`Agencijske usluge → ČITULJA POLITIKA I/90 mm → Cveće → SVETOSAVSKI KRST → Peškir → Pokrov → Posmrtne parte → Sanduk V-4 → Slika → Transportna vreća → Iznošenje → Prevoz do hladnjače → Hladnjača → Spremanje pokojnika → Prevoz do groblja → Komplet 80 → Crnina → Ešarpa`.

To je redosled koji je prethodni discrepancy audit s pravom tretirao kao istorijski pogrešan prikaz.

### 3.2 Aktuelni Computer Use i noviji root redosled

Obe novije grupe prikazuju:

`Agencijske usluge → ČITULJA POLITIKA I/90 mm → Crnina → Ešarpa → Cveće SUZA SU 1/1 → SVETOSAVSKI KRST Topola/Hrast → Peškir za krst → Pokrov garnitura BORDO → Posmrtne parte → Sanduk V-4 → Slika → Transportna vreća → Iznošenje → Prevoz do hladnjače → Hladnjača → Spremanje pokojnika → Prevoz do groblja → Komplet 80`.

Dakle, između mojih i novijih vlasničkih snimaka nema utvrđene razlike u redosledu stavki. Razlika je između stare `RUNTIME_10_ (OLD)` grupe i novijih snimaka.

## 4. Šta su prethodni ordering taskovi dokazali

Implementation task je uveo `IriuOrderingService` kao zajednički izvedeni ordering authority. Repository projection koristi raw redove samo kao ulaz, a zatim izvodi redosled iz snapshot/provenance/business-section/order podataka. Persistovani `redosled` ostaje tie-break/fallback, ne glavni poslovni redosled.

Prethodni discrepancy audit je dokazao sledeće:

- instalirani `OPC.exe` i finalni release artifact su byte-identični;
- realni PREDMET 113 ima stale raw `redosled`, ali ima parseable applied snapshot;
- provenance postoji za 17/18 stavki, uz `KOMPLET_ZA_OPELO` kao jedini nedostajući provenance red;
- exact production repository call `IriuRepository(db).getIriu(113)` vraća redosled sa `Crnina` i `Ešarpa` na pozicijama 3–4;
- golden fixture nije potpuno istog metadata oblika kao realni PREDMET, ali production-shaped repository test prolazi;
- raniji audit nije mogao nezavisno da očita pixel values u finalnom runtime-u, pa je zaključak tada morao ostati `ROOT CAUSE NOT PROVEN`.

Ovaj poslednji zaključak je važan: prolaz repository testa nije sam po sebi dokaz da je ciljna vlasnička sekvenca definitivno potvrđena.

## 5. Aktuelni Windows lifecycle nalazi

Na instaliranom `C:\Program Files\OPC\OPC.exe` ručno je završena autentikacija vlasnika i proverena su tri lifecycle-a:

- first open;
- close/reopen PREDMET-a;
- full process close, cold start, druga ručna autentikacija i reopen.

U sva tri Computer Use lifecycle snimka vidljivo je 18 redova u novijoj sekvenci iz odeljka 3.2. Standardni Windows screenshot API je svaki put vraćao `SetIsBorderRequired failed: No such interface supported (0x80004002)`, pa su pixel dokazi uzeti lokalnim full-screen PNG capture-om. Navigacija, lifecycle i izbor PREDMET-a obavljeni su Computer Use-om.

Formalno, postoje dva nivoa zaključka:

- **u odnosu na redosled koji je bio naveden u task/test artefaktima**: sva tri lifecycle-a prolaze;
- **u odnosu na vlasnički iskaz da taj redosled nije onaj koji se traži**: runtime acceptance je otvoren, jer autoritativna ciljna sekvenca nije navedena u ovom poslednjem iskazu.

## 6. Repository → provider → widget → pixel lanac

Source chain ostaje:

```text
PredmetScreen
  → IriuSegment
  → IriuRepository.watchIriu(113)
  → _orderedProjection
  → IriuOrderingService.orderedRows
  → stavke = snap.data
  → IriuRowTile mapiranje
  → vidljivi redovi
```

Nije pronađen post-service `.sort()`, index-key reuse ili drugi source-level bypass. `watchIriu` i `getIriu` koriste istu derived projection. `IriuSegment` mapira `stavke` direktno u row tile-ove sa stabilnim ključem.

To dokazuje source-level parity. Ne rešava samo po sebi pitanje da li je izvedeni redosled poslovno traženi redosled.

## 7. Startup mutation: nezavisna i dokazana tema

Aktuelni Windows audit je reproducirao sledeći lanac:

```text
PredmetScreen bira Roba i usluge
  → IriuSegment.initState
  → _runScenarioSync
  → ScenarioModuleRepository.ensureModuleAndDefaults
  → _ensureOwnerMapDefinitions
  → _repairKnownOwnerMapProtectiveEquipmentGap
  → UPDATE scenario_definitions
```

Tačno 36 `MAP_NASILNA_BOLNICA_*` redova dobija novi `updated_at`. Menjano je samo polje `updated_at`; `consequences_json`, condition, naziv, status, default flag i ostali poslovni podaci ostaju identični.

Root cause je dokazan: bolnički kernel legitimno izostavlja zaštitnu opremu, ali repair fingerprint izbacuje zaštitnu opremu iz očekivanja i poredi samo kategoriju/action. Svih 36 bolničkih definicija tako izgleda kao legacy-gap kandidat. UPDATE je bez punog equality check-a i uvek postavlja novi timestamp.

Zaključci:

- `CANONICAL BUSINESS DATA MUTATED — NO`;
- `CANONICAL TECHNICAL TIMESTAMP MUTATED — YES`;
- `STARTUP NO-OP WRITE CALLER — IDENTIFIED`;
- `STARTUP MUTATION ROOT CAUSE — PROVEN`.

Preciznija granica je: nije dokazano da goli process start do PIN ekrana piše bazu; write se dešava kada se posle login-a otvori IRiU/scenario sync putanja.

## 8. Gde su prethodni zaključci bili prejaki

Prethodni synthesis zaključak `AUDIT PASS` bio je preširok za vlasničku odluku o redosledu. Tačnije formulacije su:

- **startup mutation**: root cause proven;
- **source/repository ordering**: proven for the task/test expected sequence;
- **three current pixel captures**: mutually consistent;
- **owner-required order**: not finally established in the present exchange;
- **IRiU repair handoff**: not ready until the target sequence and first business/runtime divergence are explicitly fixed.

Ne treba menjati ordering kod, istorijski snapshot, provenance ili canonical PREDMET samo zato što se novi screenshot razlikuje od starog. Prvo treba zaključati target order.

## 9. Preporučeni sledeći korak

Vlasnik treba da dostavi jednu autoritativnu sekvencu, po mogućnosti iz jednog od sledećih izvora:

1. odobreni poslovni acceptance dokument;
2. tačan production fixture/test koji predstavlja željeni redosled;
3. eksplicitna numerisana lista 1–18.

Zatim treba ponoviti samo poređenje:

`owner-required order → current root RUNTIME screenshots → Computer Use screenshots → repository output → golden test`.

Ako se potvrdi da novija sekvenca nije željena, tada se radi novi narrow forensic task za prvi divergence point. Startup mutation nalaz ostaje validan i odvojen od tog pitanja.

## 10. Konačni status

| Oblast | Status |
|---|---|
| Stari istorijski pogrešan prikaz | potvrđen u `RUNTIME_10_ (OLD)` |
| Novi root RUNTIME snimci | potvrđeni i međusobno konzistentni |
| Moji Computer Use snimci vs novi root snimci | isti vidljivi redosled |
| Da li je taj redosled poslovno traženi redosled | nije konačno potvrđeno |
| Repository derived output | uhvaćen i konzistentan sa novijom sekvencom |
| Startup `updated_at` churn | reprodukovan, 36 redova |
| Startup root cause | dokazan |
| Canonical business payload | nije promenjen |
| IRiU production repair handoff | nije spreman bez autoritativnog target order-a |

**Konačni objedinjeni zaključak:** istorijski i noviji screenshot dokazi se razlikuju zato što pripadaju različitim lifecycle/build/evidence grupama, ali noviji root RUNTIME snimci i moji Computer Use snimci ne pokazuju međusobnu razliku. Ono što još nije zatvoreno jeste da li je novija sekvenca zaista ona koju vlasnik zahteva. Startup mutation je zaseban, potpuno dokazan problem.
