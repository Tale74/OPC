# OPC SCENARIO RUNTIME INTEGRITY UI CORRECTIONS

## Status

Implementacija je izvršena na javnom potomku prethodne SCENARIO restore tačke, na grani `task/OPC-SCENARIO-RUNTIME-INTEGRITY-UI-CORRECTIONS`. Task je nastavljen nakon što je vlasnik odobrio rad na stvarnom javnom HEAD-u `9b6d2e289d3bddae1993d7d29b1d5e191e1a1982`, jer očekivani SHA iz starijeg task teksta više nije bio aktivni javni baseline.

## Forenzički nalaz pre korekcije

Nalaz je povezan sa source-om, bazom i runtime dokazima, a ne samo sa prethodnim reportom.

| Nalaz | Dokaz | Uzrok |
|---|---|---|
| Dva reda `Slika` | `RUNTIME/Katalog.PNG`, `iriu_katalog_config`, reference iz IRIU/KATALOG/SCENARIO JSON-a | nije postojao dokazani merge korak za stabilni poslovni identitet `SLIKA`; novi upis nije imao poslovnu guard proveru |
| `Zaštitna i dodatna oprema` kao mojibake | runtime screenshot i seed u `database.dart` | oštećen tekst je bio u source seed vrednosti, pa UI nije mogao sam da ga popravi |
| Runtime prikazuje 9 stavki | `RUNTIME/Osnovni.PNG`, `scenario_modules.osnovni_paket_json`, repository migraciona logika | poznati legacy paket od devet stavki tretiran je kao korisnička odluka i nije bio proširen na vlasničkih 11 |
| Nediferencirani OSNOVNI PAKET editor | `_PackageDialog` i screenshot | sve vidljive KATALOG stavke bile su prikazane u jednoj listi bez razlike između izabranog paketa i dostupnog kataloga |
| Legacy scenario ekran | `RUNTIME/Scenario1.PNG`–`Scenario4.PNG`, `_ScenarioPolicyTree`, `_OwnerMapFinder` | stari widget je ostao dominantan u glavnom korisničkom toku i prikazivao interne `MAP_*` identitete i paralelne grupe |
| Jednokoračni novi scenario modal | `RUNTIME/Novi.PNG`, `_ScenarioDialog` | postojao je slobodan `NAZIV`/tehnički ID tok umesto identiteta izvedenog iz poslovnih uslova i vođenog pregleda |
| Nema izmišljenog trenutnog scenarija | globalni ulaz u `ModuliScreen` ne nosi konkretan `predmetId` | globalni policy editor ne sme da prikazuje stanje tekućeg PREDMETA bez konteksta |

Vlasnička mapa i owner kernel nisu menjani. `STAN`, `DOM_ZA_STARE`, `PRIVATNA BOLNICA`, `DRUGO`, `ULICA_JAVNO_MESTO`, `BOLNICA`, `BIOHAZARD`, `LIMENI_ULOZAK` i `LEMOVANJE` ostaju zasebne definicije prema postojećoj politici.

## Primena

### KATALOG integrity

- `SLIKA` je tretirana kao poznat stabilni poslovni identitet.
- Pri otvaranju baze, reference se pre uklanjanja duplikata mapiraju u IRIU redovima, provenance zapisima, KATALOG artiklima, osnovnom paketu, posledicama scenarija i snapshot JSON-u.
- Mojibake seed je zamenjen kanonskim `Zaštitna i dodatna oprema`.
- Novi korisnički unos ili preimenovanje u poslovni ključ `SLIKA` dobija jasnu poruku: `KATALOG sadrži dupliranu poslovnu kategoriju. Prvo ispravite KATALOG.`
- Nije uvedeno generičko deduplikovanje korisničkih kategorija.

### OSNOVNI PAKET

- Tačno poznati legacy paket od devet vlasničkih kategorija migrira se na 11.
- Ostali neprazni paketi ostaju korisnička odluka i ne prepisuju se.
- Upis paketa čuva stabilni owner redosled; dodatne korisničke kategorije, ako su svesno izabrane, dolaze posle vlasničkog reda.
- Editor razdvaja `STAVKE U OSNOVNOM PAKETU` i `DOSTUPNE KATALOG STAVKE`.

### SCENARIO UI

- Glavni prikaz koristi `POSTOJEĆI SCENARIJI` i poslovne filtere: uzrok, mesto smrti, vrstu ceremonije, tip groblja, grobno mesto, opelo, sahranu van Srbije i doček.
- Kremacija skriva tip groblja/grobno mesto i onemogućava međunarodnu sahranu; doček uklanja mesto smrti iz ključa.
- `MAP_*`, `SCENARIJI PO MESTU SMRTI`, `DODATNI USLOVI` i `DODATNI PAKETI` više nisu deo aktivnog korisničkog prikaza.
- Novi scenario prikazuje četiri koraka `USLOVI`, `STAVKE`, `PREGLED`, `ČUVANJE`; slobodni `NAZIV` i tehnički ID nisu primarni unos. Identitet se generiše iz potpunih uslova.
- Postojeći editor razlikuje osnovni paket od `DODATNE STAVKE SCENARIJA` i zadržava izbor OBAVEZNO/PREPORUČENO.
- Responsive filteri koriste jednu kolonu na uskom ekranu i više kolona kada širina dozvoljava. Globalni ekran ne prikazuje lažni `TRENUTNI SCENARIO` bez konkretnog PREDMETA.

BIOHAZARD tekst/prikaz i PDF derivati nisu menjani.

## Test evidence

- `flutter test test/scenario_module_repository_test.dart --no-pub` — PASS.
- `flutter test test/iriu_catalog_basic_category_policy_test.dart --no-pub` — PASS.
- `flutter test test/scenario_module_screen_test.dart --no-pub` — PASS, 2 testa.
- `flutter analyze --no-pub` i kompletan `flutter test --no-pub` su pokrenuti, ali ova validaciona sesija nije dobila jasan završni izlaz/exit code nakon početka rada alata. Zbog OPC pravila to nije proglašeno PASS-om.
- Windows/Android build nije pokretan u ovom tasku.

## Konačni kontrolni status

```text
SCENARIO RUNTIME INTEGRITY AND UI CORRECTION
— KATALOG STABLE ID / REFERENCE REPAIR IMPLEMENTED
— MOJIBAKE SOURCE SEED CORRECTED
— LEGACY BASIC PACKAGE 9 → 11 MIGRATION PASS
— CUSTOM BASIC PACKAGE PRESERVED
— BUSINESS FILTER SCENARIO UI IMPLEMENTED
— LEGACY PARALLEL UI REMOVED FROM ACTIVE PATH
— FOUR-STEP NEW SCENARIO FLOW IMPLEMENTED
— TARGETED REPOSITORY AND KATALOG TESTS PASS
— COMPLETE FLUTTER ANALYZE PENDING FINAL SESSION
— COMPLETE FLUTTER TEST PENDING FINAL SESSION
— WINDOWS/ANDROID BUILD NOT RUN
— RUNTIME ACCEPTANCE PENDING OWNER VERIFICATION
```
