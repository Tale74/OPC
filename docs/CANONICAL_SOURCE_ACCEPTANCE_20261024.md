# OPC 4.0.3+5 — prihvatanje korekcija i BundleSource (2026-10-24)

## Opseg i identitet

OWNER je odobrio korekciju korisničkog zahteva za licencu, prikaz stanja licence, Android OWNER aplikaciju i verifikaciju kanonskog BundleSource-a. Promene su izvršene samo u `C:\Tale\OPC\v1.5\BundleSource` i `C:\Tale\Lic\AndroidIssuer`. Zaštićeni `C:\Projekti\OPC_v1.5\source` nije menjan: HEAD `fe696408afc7ceae8aa7ecc80c4cda68c34e9130`, zatečeno stanje 59 Git status redova.

BundleSource potiče iz OWNER prihvaćene 4.0.3 osnove, lokalni HEAD `df47a2cf54a9b30734c53b36e12df8d96c29fc88`, grana `codex/opc-v15-canonical-bundlesource-20261024`, bez push-a. Izvor je sada namerno izmenjen, lokalni radni direktorijum nije čist; nisu izvršeni stage, commit ili push. Novi Windows NSIS template i macOS plugin registrant uključeni su u manifest posle ovog zapisa.

## Tehničko stanje BundleSource-a

Projekat sadrži Dart aplikacioni kod, testove, zvanične ikone, bazu/migracije, `pubspec.yaml` i zaključani `pubspec.lock`, Windows/Android/iOS/macOS/Web projekte, CI workflow-e, release skripte i Windows NSIS template. Generisanje release izlaza iz samog kandidata potvrđeno je na ovom Windows hostu za Windows, Android i Web. Potpuni clean-room build nije rađen. Apple build zahteva macOS/Xcode; za korisničku instalaciju dodatno su potrebni Apple signing/notarization identiteti. Android signing P12 i OWNER seed/registar ostaju van izvora.

- `flutter pub get --offline`: PASS; zaključani paketi su razrešeni.
- `flutter analyze --no-pub`: PASS, bez nalaza.
- `flutter test --no-pub --concurrency=1`: PASS, 693 prošla testa, 9 environment-gated preskočeno, 0 neuspešnih.
- Testovi obuhvataju zahtev za aktivacioni ključ sa nazivom FIRME/PIB/MB, licencni dijalog i izostanak trajnog bannera u LISTA PREDMETA. Licencni token format, PIB+MB identitet, ključ/verifikator i FIRMA guard nisu menjani.
- Prethodno OWNER potvrđeno: jedan PIB+MB ključ aktivira Windows i Android. Ova korekcija nije menjala taj format niti kriptografiju.

## Novi artefakti 4.0.3+5

| Platforma | Artefakt | Rezultat i SHA-256 |
|---|---|---|
| Windows | `C:\Tale\OPC\v1.5\Windows\4.0.3-corrected+5\OPC_Setup_4.0.3_PerUser.exe` | NSIS build PASS; 15,635,877 B; `B078204F9872443ECC318F3662BC2FC4AE3482D934CE195BE185313E3216836F`. Windows executable `OPC.exe` SHA-256 `BA440EBADA7815A9B3D64CEE915D1715E22CD8F20C8B4AE283ED1264CF1B0B46`. Zvanični ICO je odgovarao izvoru, SHA-256 `A507931C389001E06A2D61E78EB0706C3C735C52D134C9B0FF178B9310F2AC8C`.
| Android | `C:\Tale\OPC\v1.5\Android\4.0.3-corrected+5\OPC_Android_4.0.3_release.apk` | APK postoji i validiran; 79,824,288 B; SHA-256 `8D86832ABE1496CE0C5000D8F77ECF4993055465D9F0D3B51DC19F0B75698643`. Package `com.tale.opc_v4`, versionName `4.0.3`, versionCode `5`. `apksigner` potvrđuje OWNER release cert SHA-256 `4d1371c7573e5f61f2d6e662bc18176bf6e20f2e7541875147d3dcd34eb3ad65`.
| Web/PWA | `C:\Tale\OPC\v1.5\PWA\4.0.3-corrected+5\OPC_PWA_4.0.3_build5.zip` | Flutter release build PASS, `version.json` 4.0.3 build 5, 55 fajlova u deploy direktorijumu; ZIP 16,074,268 B, 57 ZIP članova, SHA-256 `2EEF943FD63F8AF4D4BAC5C990AF471C65B0B07F4FC8BE6EC215925448EA980E`. `main.dart.js` SHA-256 `8C7FC4C60B5040021DA57DF46054FF48452158E7F35671DE5273E00B48F10906`.

Paketne kopije su napravljene u novim `corrected+5` direktorijumima; prethodni artefakti nisu prepisani. Web paket nije objavljen na Cloudflare, a javni `https://opc-srb.pages.dev/` nije menjan.

## Acceptance matrix

| Provera | Status | Dokaz / granica |
|---|---|---|
| Aktivacioni zahtev: postojeći kontakt, naziv FIRME, PIB i MB; kopiranje/deljenje fallback | PASS za kod i regresiju | Dijalog koristi postojeći DEVELOPER e-mail, nema tihog slanja; widget testovi i puna suite prošli. Nije ponovljena fizička Windows/Android UI interakcija u ovoj korektivnoj sesiji. |
| Trajna aktivacija: stvarni naziv FIRME + PIB/MB; nema stalnog bannera na listi | PASS za kod i regresiju | Izmenjen prikaz i uklonjen duplirani banner; regresioni widget testovi prolaze. Istekli trial feedback ostaje pri pokušaju novog PREDMETA. |
| Android OWNER issuer UX | PASS testovi / PARTIAL praktični | Android app vodič, fajl tipovi, greške i readiness indikatori pokriveni testovima; 3 testa prošla, 1 cross-sign test preskočen jer test ključ nije prisutan. Nema fizičke OWNER Android izdavačke provere niti novog issuer APK-a. Kriptografija/seed/registar nisu menjani. |
| Windows setup/shortcut/uninstall granice | PASS prethodnog testnog paketa / PARTIAL za novu verziju | NSIS 4.0.3+5 je sastavljen. Prethodna izolovana install/update/uninstall proba iste NSIS logike prošla je i sačuvala marker izvan instalacionog direktorijuma. Novi +5 setup nije pokrenut u korisničkom Windows profilu jer bi promenio njegovu postojeću Desktop prečicu. |
| Android 4.0.2 → 4.0.3+5 update i podaci | BLOCKED runtime | APK/potpis/versionCode su provereni. Postojeći disposable AVD nije podigao ADB uređaj; emulator ponavlja `Unexpected error while creating: C:\Users\Steva\.android\emu-last-feature-flags.protobuf.lock (error: 5)`. Nema install/update/runtime PASS-a u ovom pokušaju; nijedan AVD nije wipe-ovan, nijedan nalog nije menjan. |
| Web runtime/update na prihvaćenom Cloudflare originu | NOT RUN | Kandidat je lokalno izgrađen i zapakovan; nema objave na produkcioni Cloudflare origin niti stvarnog same-origin update testa u ovoj sesiji. |
| iOS/macOS current-source packages | PARTIAL / OPEN | Stariji no-codesign CI artefakti ostaju technical-only i prednjače ovom izmenjenom kandidatu. Nema svežeg Apple build-a ili install acceptance-a; ne tvrdimo distributivni PASS. |
| Zaštićeni SOURCE | PASS | HEAD i 59 pređašnjih status redova nepromenjeni. |

Web build je završio exit 0 uz poruku da CupertinoIcons font nije pronađen; `lib/` nema direktne `CupertinoIcons` reference, build sadrži MaterialIcons i izlaz je validan. Zabeležena je kao upozoravajuća poruka bez utvrđenog OPC korisničkog uticaja, a ne kao dokaz zasebnog defekta.

## Čišćenje i kontinuitet

Ranije provereno čišćenje (606 fajlova / 1,763,810,313 logičkih bajtova, plus prazna Docs putanja) zadržava se kao istorijski rezultat i ne pripisuje se ovom izvršavanju. U ovoj sesiji build izlazi su sačuvani pre planiranog uklanjanja regenerabilnih `build/` i `.dart_tool/` direktorijuma iz BundleSource-a. Zaštita i konačan disk delta biće evidentirani u spoljnjem REVIEW izveštaju nakon tog koraka.

Ostali istorijski koreni ostaju razdvojeni od kanonskog kandidata. Ovaj dokument ne predstavlja brisanje celih root-ova niti potvrdu da su Apple i PWA runtime acceptance završeni.

## Završeno čišćenje u ovoj sesiji

Posle kopiranja i hash-provere Windows/Android/Web artefakata uklonjeni su samo regenerabilni `BundleSource\build` (2,761 fajl; 1,378,292,158 logičkih B), `BundleSource\.dart_tool` (225 fajlova; 461,007,107 B), moja privremena NSIS build-input fascikla (43 fajla; 79,466,951 B) i dva privremena emulator loga (360,123,088 B). Nije bilo reparse tačaka u dva BundleSource cache direktorijuma. C: slobodan prostor porastao je sa 40,048,234,496 B na 42,307,338,240 B; merena promena **+2,259,103,744 B**. To je izmerena promena tokom tačno ograničenog cleanup prozora, ne pripisana logičkom zbiru bez rezerve.

`C:\Tale\OPC\v1.5\source` je zadržan kao protected: Git HEAD isti je kao zaštićeni `C:\Projekti\OPC_v1.5\source` i oba imaju 59 pređašnjih status redova. Njega nisam brisao.

Pokušaj uklanjanja dva istorijska korena `C:\Tale\OPC\Phase5Builds` (876 fajlova, 125,465,220 B; bez baze/ključeva/reparse) i `C:\Tale\OPC\v1.5\BundleSource_History_20261024` (1,478 fajlova, 59,323,283 B; bez baze/ključeva/reparse) odbijen je pre kreiranja procesa od strane automatske approval kontrole. Navedeni razlog: celovito brisanje source/provenance materijala traži posebno, konkretnije OWNER odobrenje. Nijedan od ova dva korena nije obrisan niti premešten. Zaštićeni active SOURCE, backup/REVIEW/PHASE/restore koreni i svi poslovni podaci ostali su neizmenjeni.

Android evidence note: the long Gradle terminal session disappeared before its natural exit code was retained. The deliverable is therefore labelled **APK artifact/signature/assets verified**, with the build process exit status not captured. No second build was started solely to recover a terminal exit code.

## OWNER HUMAN GATE — naknadno završeno brisanje dva istorijska korena

Prethodni auto-review rejection iz ovog dokumenta opisuje raniji pokušaj. Posle posebnog OWNER odobrenja i završne source/key/ZIP/Git provere, standardni approval-gated postupak je uklonio samo `C:\Tale\OPC\Phase5Builds` i `C:\Tale\OPC\v1.5\BundleSource_History_20261024`. Nezavisni postcheck potvrdio je odsustvo obe putanje. Uklonjeno 2.354 fajla / 184.788.503 B logički; C: slobodan prostor u neposrednom merenju +190.005.248 B. BundleSource, paketi, `E:\LicGen`, oba 59-status zaštićena source stabla i drugi istorijski root-ovi nisu menjani. Tačni preduslovi i matrica su u `CLEANUP_DISPOSITION_SR_20261024.md`.

## Naknadna OWNER runtime odluka — 24.10.2026.

OWNER je potvrdio praktični PASS Windows i Android 4.0.3+5 u posmatranom obuhvatu: ažuriranje prethodne kompatibilne instalacije, pokretanje, očuvanje poslovne baze i trajne licence, odsustvo duplog bannera i prikaz stvarnog naziva FIRME uz PIB i MB u postojećem licencnom dijalogu. Ranije stavke o Android AVD blokadi i Windows +5 runtime neizvesnosti gore predstavljaju stanje prethodnog izvršavanja, ne ovu naknadnu OWNER odluku. Windows Desktop prečica, Cloudflare +5 objava/update i Android OWNER generator su odvojeni, još nepotvrđeni prihvatni koraci. Ovo ne proširuje prihvat na Apple platforme.