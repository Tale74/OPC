# OPC — izvor, gradnja i kontinuitet (OWNER)

## Autoritet i identitet

**Kanonska putanja:** `C:\Tale\OPC\v1.5\BundleSource`. Ovo je kompletan Flutter projekat sa `.git`, početno čist na `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0` (477 tracked datoteka) iz izolovane grane `codex/opc-v15-result-driven-20261020`, remote `https://github.com/Tale74/OPC.git`. U 24.10. dokumentacionoj konsolidaciji dodati su samo dokumenti i README navigacija; aplikacioni fajlovi ostaju bajt-identični prihvaćenom commit-u. Tačan dokumentacioni commit naveden je u OWNER kontrolnom manifestu van Git stabla. Nema push-a.

Zaštićeni aktivni SOURCE (`C:\Projekti\OPC_v1.5\source`) je zaseban mixed worktree na `fe696408...` sa 59 pređašnjih stavki. Njegov jedinstveni/nerazrešeni rad nije automatski prenet. `C:\Tale\OPC\v1.5\BundleSource_History_20261024` je stariji manifestirani skup 469/4.0.2/4.0.3 snapshot-a i dokaza, **nije** trenutni build input.

## Sadržaj dovoljan za rad

`lib/`, `test/`, `assets/`, `android/`, `windows/`, `web/`, `ios/`, `macos/`, `.github/workflows/`, `scripts/`, `tool/`, `tools/`, `pubspec.yaml`, `pubspec.lock` i native projektni fajlovi nalaze se u Git checkout-u. `assets/app_icon/` sadrži zvanični master; Windows ICO, Android mipmap i Web ikone su prisutni. `lib/core/database/database.dart` i migracije su u izvoru. `lib/core/entitlements/` sadrži javni verifikator, bez privatnog seed-a. Aktuelne poslovne odluke su u pet glavnih dokumenata ispod `docs/` i u `OPC_CURRENT_DEVELOPMENT_STATE.md`.

Izvor ne zavisi od PHASE direktorijuma, lokalnog Flutter cache-a ili agent-state-a za aplikacioni kod. Platformski toolchain, keystore, Apple identitet, instalacioni alati i hosting nalog su spoljašnji preduslovi. Privatni materijal nikada ne dodavati u Git, javni Web paket ili REVIEW. `docs/SOURCE_CONTENT_SHA256.csv` proverava sadržaj Git radnog stabla bez `.git` i bez sopstvenog reda.

## Alati i serijski postupak

Prethodno potvrđeni Flutter 3.41.7 / Dart 3.11.5 i zaključani `pubspec.lock` su referenca. Na ovom skromnom računaru pokretati **samo jedan** Flutter/Gradle proces odjednom. Po promeni aplikacionog ili build koda: `flutter pub get`, zatim `flutter analyze --no-pub`, zatim `flutter test --no-pub --concurrency=1`; tek zatim ciljani build. Dokumentaciona konsolidacija nije razlog za ponavljanje pune suite. Sačuvati potpune exit kodove i izlaz.

- **Windows:** Windows 10/11 sa Flutter desktop, Visual Studio C++ toolchain; `flutter build windows --release --no-pub --build-name=4.0.3 --build-number=4`. Ranije je kratka `O:` putanja do *roditelja* projekta rešila MSBuild dužinu putanje. NSIS per-user installer je zaseban korak, sa proverom iste verzije i očuvanja lokalnih podataka.
- **Android:** Flutter, JDK/Android SDK/Gradle. `flutter build apk --flavor production --release --no-pub`. Gradle odbija release bez `OPC_ANDROID_RELEASE_KEYSTORE`, `OPC_ANDROID_RELEASE_PASSWORD`, `OPC_ANDROID_RELEASE_ALIAS`; koristiti isključivo postojeći OWNER P12 i alias `opc-v15-release`. Ne koristiti debug ključ. Proveriti APK potpis i Flutter assets pre instalacije.
- **Cloudflare Web/PWA:** `flutter build web --release --no-pub --build-name=4.0.3 --build-number=4`; deployment u postojeći `opc-srb` Pages projekat. Svaki browser profil/origin ima zasebnu lokalnu bazu. Sačuvati prihvaćeni javni origin; nova verzija mora proći realan same-origin update.
- **iOS:** macOS/Xcode i Apple signing identitet. GitHub Actions workflow `.github/workflows/opc-platform-builds.yml` daje tehnički no-codesign compile. Bez signing-a, IPA i stvarnog Apple uređaja nema distribucionog ili update PASS.
- **macOS:** macOS/Xcode. CI tehnički app/DMG bez potpisa; za korisnički paket trebaju codesign/notarization i stvaran install/update test.

## Prihvaćeni lokalni artefakti

U OWNER bundle-u pored izvora: `Windows/4.0.3/OPC_Setup_4.0.3_PerUser.exe` SHA-256 `3A4FB149A50B18AF3C57E50921AD6433F419A1C6A891F89F228591120E6D06E0`; `Android/4.0.3/OPC_Android_4.0.3_release.apk` `CB52B880735E7E85E1608380D563C185942EB4E05E96F083187635D240EDBDA2`; `PWA/4.0.3_Cloudflare/OPC_PWA_PUBLIC_403_CLOUDFLARE.zip` `173E15E7659A4D6F072E18CC61E625A9640E664999CC887DC3A73BE8F21B52CC`. Apple `iOS/4.0.3_technical` i `MacOS/4.0.3_technical` su nepotpisani tehnički izlazi. Primena/ažuriranje i poznate granice opisani su u `docs/FINAL_ACCEPTANCE_MATRIX.md`.

## Nastavak i objavljivanje

Raditi iz ovog kanonskog checkout-a, sa lokalnom granom za promene. Pre bilo kog GitHub push-a, javnog release-a ili zamene zaštićenog SOURCE-a potreban je konkretan OWNER pregled i odluka. CI i runtime PASS starog commita ne pripisivati sledećem izmenjenom kodu. Licence, signing, kanonsku bazu i korisničke podatke čuvati van izvora.
