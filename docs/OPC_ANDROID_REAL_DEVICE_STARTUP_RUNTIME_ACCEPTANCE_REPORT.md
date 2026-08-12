# OPC Android — real-device startup/runtime acceptance report

Datum izvođenja: 12.08.2026. (Europe/Belgrade)

## A. Baseline i artefakt

- Grana: `task/OPC-ANDROID-RELEASE-BUILD-RESOLUTION`
- Baseline HEAD pre ovog izveštaja: `4fd7ea27bd42704b05d52a53c7389af497ee1bc6`
- Remote: `https://github.com/Tale74/OPC.git`
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Veličina: `78,042,999` bajtova
- SHA-256: `33D6D5616F4318A2EE438B28DA381D39CE2E72B98FC5FADDB2BA430AEBD15DB1`
- Vreme artefakta: `2026-08-12 15:14:04`
- Radno stablo je bilo čisto pre dodavanja ovog reporta.

## B. Fizički Android uređaj

- ADB endpoint: `192.168.100.74:37977`
- Model: `LGN-LX1` (`LGN-LX1EEA` / `HNLGN-QL`)
- Android: `15`
- Ekran: `720x1610`, fizička gustina 320 dpi (override 272)
- `adb devices -l`: uređaj u stanju `device`

## C. Postojeća instalacija i upgrade

- Paket: `com.tale.opc_v4`
- `versionName=4.0.0`, `versionCode=1`, `targetSdk=36`
- `firstInstallTime=2026-06-24 21:00:04`
- Pre upgrade-a potvrđena je postojeća instalacija i njen package/signature identitet. Wireless `adb pull` baznog APK-a nije završen u prihvatljivom vremenu, pa hash instaliranog fajla nije korišćen kao dokaz identičnosti.
- Izvršen je dozvoljeni in-place upgrade bez brisanja podataka: `adb install -r ...\app-release.apk` → `Success`.
- Posle upgrade-a: `lastUpdateTime=2026-08-12 16:33:53`.
- Nije korišćen `pm clear`, uninstall ili reset aplikacionih podataka.

## D. Cold startup

- Logcat je očišćen, aplikacija je force-stopovana i pokrenuta sa `am start -n com.tale.opc_v4/.MainActivity`.
- Komanda starta završila je za približno 370 ms; nakon 12 s ekran je bio stabilan na izboru savetnika.
- Nije uočen blank/freeze ekran, ANR, FATAL EXCEPTION ili `Skipped frames` zapis.
- UI je bio renderovan i interaktivan na stvarnom uređaju.

## E. Warm startup / session restore

- Aplikacija je poslata u pozadinu (`HOME`) bez force-stop-a, zatim vraćena sa `am start`.
- Komanda je završila za 657 ms; sistem je potvrdio `topResumedActivity=com.tale.opc_v4/.MainActivity`.
- Sesija je ostala aktivna i vraćen je `OPC — LISTA PREDMETA`, bez ponovnog PIN ekrana.

## F. Login i session

- Korišćen je autorizovani PIN iz task instrukcije (PIN nije upisan u ovaj javni report).
- Uspešno je otvorena sesija savetnika `SAŠA ANDONOV (ADMINISTRATOR)`.
- Početni ekran je prikazao `OPC — LISTA PREDMETA`, kontrolne akcije `Statistika`, `Moduli`, `Podešavanja`, `Odjava` i listu PREDMETA.

## G. Osnovna navigacija i back flow

- Lista PREDMETA je otvorena; postojeći otvoreni PREDMET `TOMIĆ STOJANKA / 230426_0933` je otvoren.
- Prikazane su sekcije `Preminulo lice`, `Činjenice o smrti`, `Statusi`, `Platilac`, `Ceremonija`, `Parte`, `Roba i usluge`, `Finansije`, `Dokumenti`, `Pregled i potvrda`.
- Back tok je prikazao očekivani dijalog `Izlazak iz otvorenog predmeta` sa `OSTANI`, `IZAĐI` i `ZATVORI PREDMET`; izabrano je `IZAĐI`, bez zatvaranja PREDMETA.
- `Moduli` ekran je otvoren i SCENARIO kartica je bila dostupna.

## H. SCENARIO selector i postojeći PREDMET

- SCENARIO prikazuje dva otvorena PREDMETA kao dve nezavisne `CheckBox` stavke; izbor kontrolisanog PREDMETA je bio jednoznačan (samo njegov `checked=true`).
- Postojeći PREDMET `STOJANKA TOMIĆ / 230426_0933` je ranije provereno prikazao izvedeni snapshot `PRIRODNA · STAN · SAHRANA · LOKALNO · GROB · OPELO DA · VAN SRBIJE NE · DOČEK NE`.
- UI je bez mojibake teksta ili praznih/nekorisnih kontrola; duži sadržaj je scrollable.

## I. Kontrolisani NASILNA acceptance case

Kontrolisani PREDMET je kreiran kroz normalan Android UI, bez direktnog upisa u bazu:

- Naziv u UI: `ANDROID NASILNA`
- Broj PREDMETA: `120826_1640`
- Status: `OTVOREN`
- Uslovi podešeni i sačuvani kroz sekcije PREDMETA:
  - `UZROK SMRTI NASILNA`
  - `MESTO SMRTI STAN`
  - `VRSTA CEREMONIJE SAHRANA`
  - `TIP GROBLJA GRADSKO`
  - `GROBNO MESTO GROB`
  - `OPELO NE`
  - `SAHRANA VAN SRBIJE NE`
  - `DOČEK NE`
- SCENARIO prikaz je potvrdio:
  - `TRENUTNI USLOVI I IZVEDENI SCENARIO`: `NASILNA · STAN · SAHRANA · LOKALNO · GROB · OPELO NE · VAN SRBIJE NE · DOČEK NE`
  - `PRIMENJENI SCENARIO SNAPSHOT`: isti tuple
  - `DODATE STAVKE SCENARIJA`: `Transportna vreća AKTIVNO`, `Iznošenje AKTIVNO`, `Zaštitna i dodatna oprema AKTIVNO`, `Prevoz do hladnjače AKTIVNO`.

Ovim je na fizičkom uređaju potvrđeno da selector, production caller i prikaz primenjenog snapshot-a rade za poznati NASILNA slučaj, uključujući traženu zaštitnu stavku.

## J. Notifikacija / PODSETNIK nalaz

Na uređaju je posle upgrade-a postojala nova aktivna notifikacija:

- Naslov: `Podsetnik za ceremoniju`
- Tekst: `SAHRANA ZA KOSARA JOVANOVIĆ JE 05.08.2026. U 12:00. DOVRŠITE NEOPHODNE PRIPREME.`
- Android `dumpsys notification` vreme kreiranja: `2026-08-12 16:34:46 +02:00`
- Package `lastUpdateTime`: `2026-08-12 16:33:53 +02:00`

Dakle, notifikacija jeste nova i generisana je od runtime-a nove verzije, približno 53 sekunde posle instalacionog upgrade-a. Njena ciljna ceremonija pripada istorijskom PREDMETU `JOVANOVIĆ KOSARA / 010826_1303`, koji je u filteru `ZAVRŠEN` prikazan kao `ZAVRŠEN`, pre 7 dana, SAHRANA–ORLOVAČA. To je poslovno-pravilo nalaz za proveru PODSETNIK eligibility/status filtera; nije Android startup crash niti blokada acceptance toka.

## K. Findings i korekcije

- Android-specific blocking finding: nema.
- `FATAL EXCEPTION`, `ANR in`, `Process ... com.tale.opc_v4` i `Skipped N frames` provera nad poslednjih 500 logcat zapisa: 0 pogodaka.
- Nije uočeno vidljivo seckanje, ne-renderovan ekran ili nečitljiv/mojibake UI u testiranim tokovima.
- Nije menjana izvorna logika niti konfiguracija; izvršen je samo dozvoljeni in-place APK upgrade i normalni UI testni unos kontrolisanog PREDMETA.
- Poslovni nalaz iz odeljka J ostavljen je za zasebnu proveru PODSETNIK pravila; za ovaj startup acceptance ne uvodi se neodobrena promena.

## L. Final verdict

- Real-device cold startup: **PASS**
- Real-device warm startup/session restore: **PASS**
- Login i osnovna navigacija: **PASS**
- SCENARIO selector / applied snapshot / NASILNA IRiU: **PASS**
- Android runtime stability (ANR/FATAL/skipped-frame smoke check): **PASS**
- PODSETNIK: **PASS kao nova runtime notifikacija**, uz **FOLLOW-UP poslovnog pravila** jer je poruka generisana za PREDMET koji je već `ZAVRŠEN`.

Ukupan Android startup/runtime acceptance verdict: **PASS — sa neblokirajućim PODSETNIK follow-up nalazom**.
