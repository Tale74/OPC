## Aktuelni release kontinuitet — 2026-10-28

Za kanonski OPC 4.0.3+12 source/build/distribution identitet i poznate runtime granice pogledati [OPC_40312_FINAL_RELEASE_RECONCILIATION_20261028.md](OPC_40312_FINAL_RELEASE_RECONCILIATION_20261028.md). Istorijski zapisi niže ostaju neizmenjeni.
# OPC — izvor, gradnja i kontinuitet (OWNER)

## Aktuelno stanje kanonskog izvora i distribucije (27.10.2026.)

Lokalni BundleSource: grana codex/opc-v15-canonical-bundlesource-20261024, dokumentacioni HEAD 31b215e33912ae5419ab58e0b24cb29c2c7b2735, čisto radno stablo pre ovog odobrenog dokumentacionog usklađivanja. Build/source identitet OPC 4.0.3+11 je 3c233bfdca512fee8c7b5a608cb16d66a9c898f7; aplikacioni kod je uveden u d242605877e54379744ecc3eeea88759ce12f9a8, a razlika do 3c bila je samo dokumentacija. Novi dokumentacioni commit ne menja build identitet.

GitHub: poslednji prethodno potvrđen remote ref izolovane grane bio je 31b215e33912ae5419ab58e0b24cb29c2c7b2735. Provera u ovom izvršavanju nije uspela: git ls-remote nije mogao da uspostavi vezu sa github.com:443 preko proxy-ja; GitHub web pregled je vratio Cache miss. Trenutni udaljeni ref zato nije potvrđen i push nije obavljen.

Windows/Android +11: OWNER je prihvatio oba izdanja za ovaj ciklus. Windows release folder je potvrđen 39/39 hash-eva, a aplikacija je pokrenuta. Windows instalacija/ažuriranje i PDF/DOCX izvoz/otvaranje ostaju NOT VERIFIED/NOT TESTED. Android APK je release potpisan, ali prethodni Package Manager update nije uspeo; instalacija/ažuriranje, runtime i dokumentni izvoz/otvaranje nisu PASS. Runtime provere nisu ponavljane.

PWA +10: postojeći opc-srb.pages.dev deployment ostaje poslednji prihvaćen javni kanal. Lokalni ZIP PWA/4.0.3+10/OPC_PWA_4.0.3_build10_CLOUDFLARE.zip je 56 fajlova, SHA-256 E7A52B82AA52986705423872E45D1F7FE19A20ADBFA03C3BC4BB93DF5C5F7570, version.json je 4.0.3 build 10. Nije rađena javna zamena.

Apple +11: GitHub Actions run 40456238530 na kodnoj reviziji 3c imao je iOS no-codesign compile i macOS unsigned technical app PASS. Lokalni iOS/4.0.3_technical i MacOS/4.0.3_technical ZIP-ovi potiču iz starijeg commita cc16f94a..., nisu +11. Potpisana IPA, notarizovan macOS paket, instalacija i dokumentni runtime nisu potvrđeni. Lokalni Apple toolchain zahteva macOS/Xcode i odgovarajuće Apple signing preduslove; privatni materijal ostaje van BundleSource-a.

Reproducibilna putanja: pubspec.yaml/pubspec.lock, lib/, assets/, svih pet native targeta, tool/ci/, .github/workflows/opc-platform-builds.yml i scripts/validate_opc_manifest_gate.py čine izvor i build mehanizam. Windows, Android i Web mogu se graditi iz lokalnog Flutter toolchain-a; Android release koristi spoljašnji OWNER sertifikat. PWA zahteva flutter build web pa serijsku JS kompilaciju web/drift_worker.dart u build/web/drift_worker.dart.js. iOS/macOS tehnički CI koristi macOS runner, dok instalaciona distribucija traži Apple signing/notarization i runtime. Run 40456238530 uključuje QA i Windows/iOS/macOS tehničke poslove; Android CI job je preskočen jer signer nije u CI. Detalji i granice su u OPC_PLATFORM_PARITY_40310.md i spoljnjem OWNER REVIEW sloju.

Ispod ovog sažetka nalaze se hronološki zapisi ranijih faza. Oni su istorijski izvori, a ne trenutni release statusi.
## Autoritet i identitet (istorijski početni zapis)

**Kanonska putanja:** `C:\Tale\OPC\v1.5\BundleSource`. Ovo je kompletan Flutter projekat sa `.git`, početno čist na `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0` (477 tracked datoteka) iz izolovane grane `codex/opc-v15-result-driven-20261020`, remote `https://github.com/Tale74/OPC.git`. Po početnoj dokumentacionoj konsolidaciji u ovom checkout-u izvedene su ciljane 4.0.3+5 izmene aplikacije i build konfiguracije, opisane u `CANONICAL_SOURCE_ACCEPTANCE_20261024.md`. Stariji commit ostaje istorijska osnova, a aktuelni HEAD i radno stablo moraju se proveriti pre svakog novog build-a ili objave. GitHub push nije izvršen ovim dokumentom.

Zaštićeni aktivni SOURCE (`C:\Projekti\OPC_v1.5\source`) je zaseban mixed worktree na `fe696408...` sa 59 pređašnjih stavki. Njegov jedinstveni/nerazrešeni rad nije automatski prenet. Istorijski `BundleSource_History_20261024` je po posebnom OWNER odobrenju uklonjen nakon ciljane provere porekla; nije build input. Zapis o uklanjanju je u `CLEANUP_DISPOSITION_SR_20261024.md`.

## Sadržaj dovoljan za rad

`lib/`, `test/`, `assets/`, `android/`, `windows/`, `web/`, `ios/`, `macos/`, `.github/workflows/`, `scripts/`, `tool/`, `tools/`, `pubspec.yaml`, `pubspec.lock` i native projektni fajlovi nalaze se u Git checkout-u. `assets/app_icon/` sadrži zvanični master; Windows ICO, Android mipmap i Web ikone su prisutni. `lib/core/database/database.dart` i migracije su u izvoru. `lib/core/entitlements/` sadrži javni verifikator, bez privatnog seed-a. Aktuelne poslovne odluke su u pet glavnih dokumenata ispod `docs/` i u `OPC_CURRENT_DEVELOPMENT_STATE.md`.

Izvor ne zavisi od PHASE direktorijuma, lokalnog Flutter cache-a ili agent-state-a za aplikacioni kod. Platformski toolchain, keystore, Apple identitet, instalacioni alati i hosting nalog su spoljašnji preduslovi. Privatni materijal nikada ne dodavati u Git, javni Web paket ili REVIEW. `docs/SOURCE_CONTENT_SHA256.csv` proverava sadržaj Git radnog stabla bez `.git` i bez sopstvenog reda.

## Alati i serijski postupak

Prethodno potvrđeni Flutter 3.41.7 / Dart 3.11.5 i zaključani `pubspec.lock` su referenca. Na ovom skromnom računaru pokretati **samo jedan** Flutter/Gradle proces odjednom. Po promeni aplikacionog ili build koda: `flutter pub get`, zatim `flutter analyze --no-pub`, zatim `flutter test --no-pub --concurrency=1`; tek zatim ciljani build. Dokumentaciona konsolidacija nije razlog za ponavljanje pune suite. Sačuvati potpune exit kodove i izlaz.

- **Windows:** Windows 10/11 sa Flutter desktop, Visual Studio C++ toolchain; `flutter build windows --release --no-pub --build-name=4.0.3 --build-number=5`. Ranije je kratka `O:` putanja do *roditelja* projekta rešila MSBuild dužinu putanje. NSIS per-user installer je zaseban korak, sa proverom iste verzije i očuvanja lokalnih podataka.
- **Android:** Flutter, JDK/Android SDK/Gradle. `flutter build apk --flavor production --release --no-pub`. Gradle odbija release bez `OPC_ANDROID_RELEASE_KEYSTORE`, `OPC_ANDROID_RELEASE_PASSWORD`, `OPC_ANDROID_RELEASE_ALIAS`; koristiti isključivo postojeći OWNER P12 i alias `opc-v15-release`. Ne koristiti debug ključ. Proveriti APK potpis i Flutter assets pre instalacije.
- **Cloudflare Web/PWA:** `flutter build web --release --no-pub --build-name=4.0.3 --build-number=5`; deployment u postojeći `opc-srb` Pages projekat. Svaki browser profil/origin ima zasebnu lokalnu bazu. Sačuvati prihvaćeni javni origin; nova verzija mora proći realan same-origin update.
- **iOS:** macOS/Xcode i Apple signing identitet. GitHub Actions workflow `.github/workflows/opc-platform-builds.yml` daje tehnički no-codesign compile. Bez signing-a, IPA i stvarnog Apple uređaja nema distribucionog ili update PASS.
- **macOS:** macOS/Xcode. CI tehnički app/DMG bez potpisa; za korisnički paket trebaju codesign/notarization i stvaran install/update test.

## Prihvaćeni lokalni artefakti

U OWNER bundle-u pored izvora: `Windows/4.0.3/OPC_Setup_4.0.3_PerUser.exe` SHA-256 `3A4FB149A50B18AF3C57E50921AD6433F419A1C6A891F89F228591120E6D06E0`; `Android/4.0.3/OPC_Android_4.0.3_release.apk` `CB52B880735E7E85E1608380D563C185942EB4E05E96F083187635D240EDBDA2`; `PWA/4.0.3_Cloudflare/OPC_PWA_PUBLIC_403_CLOUDFLARE.zip` `173E15E7659A4D6F072E18CC61E625A9640E664999CC887DC3A73BE8F21B52CC`. Apple `iOS/4.0.3_technical` i `MacOS/4.0.3_technical` su nepotpisani tehnički izlazi. Primena/ažuriranje i poznate granice opisani su u `docs/FINAL_ACCEPTANCE_MATRIX.md`.

## Nastavak i objavljivanje

Raditi iz ovog kanonskog checkout-a, sa lokalnom granom za promene. Pre bilo kog GitHub push-a, javnog release-a ili zamene zaštićenog SOURCE-a potreban je konkretan OWNER pregled i odluka. CI i runtime PASS starog commita ne pripisivati sledećem izmenjenom kodu. Licence, signing, kanonsku bazu i korisničke podatke čuvati van izvora.

## Aktuelni kandidat 4.0.3+5 (2026-10-24)

Po korekcijama licencnog korisničkog toka i uklanjanju trajnog LISTA PREDMETA bannera, verzija je `4.0.3+5`. `flutter analyze --no-pub` je prošao bez nalaza; serijska puna suite je završila sa 693 PASS / 9 environment-gated skip / 0 fail. Detalji, hash-ovi Windows/Android/Web artefakata i runtime granice su u [CANONICAL_SOURCE_ACCEPTANCE_20261024.md](CANONICAL_SOURCE_ACCEPTANCE_20261024.md).

Aktuelni lokalni artefakti nalaze se u `C:\Tale\OPC\v1.5\Windows\4.0.3-corrected+5`, `Android\4.0.3-corrected+5` i `PWA\4.0.3-corrected+5`. Android APK je release potpisan postojećim OWNER sertifikatom, package `com.tale.opc_v4`, versionCode 5. OWNER je naknadno prihvatio praktične Windows i Android 4.0.3+5 rezultate u posmatranom opsegu. PWA +5 je 25.10.2026. objavljen na postojećem Cloudflare projektu; javni bundle i očuvanje sintetičkog PREDMETA kroz reload/novi tab/offline su provereni, dok standalone instalacija i deo licencnog UX prihvata ostaju otvoreni (videti `OPC_CURRENT_DEVELOPMENT_STATE.md` i spoljni REVIEW). Stariji Apple no-codesign izlazi nisu artefakti trenutnog korigovanog koda.

## Lokalni licencni UI kandidat 4.0.3+6 (2026-10-25)

`pubspec.yaml` sada označava novi, neobjavljeni izvorni kandidat 4.0.3+6 za ograničenu korekciju poziva sa liste PREDMETA, medaljona, nevažećeg ključa i Web oznake platforme. Ovo ne menja već prihvaćene +5 Windows/Android pakete niti javni Cloudflare +5 deployment. Za +6 je dozvoljen samo odgovarajući lokalni Web build i REVIEW; Cloudflare objava, GitHub push i zamena platformskih paketa zahtevaju novu OWNER odluku. Pre kasnijih Windows/Android/Apple buildova proveriti aktuelni HEAD i završni QA kandidat umesto preuzimanja stare +5 komande iz istorijskog zapisa.

**Web worker i postojanost:** `lib/core/database/database.dart` očekuje `drift_worker.dart.js` na Web originu. Sam `flutter build web` je u lokalnom +6 kandidatu kopirao `web/drift_worker.dart`, ali nije proizveo JavaScript worker; HTTP 404 se poklopio sa gubitkom sintetičkog administratora posle reload-a u izolovanom IAB testu. Pre PWA pakovanja dodatno serijski izvršiti `dart compile js web/drift_worker.dart -O4 -o build/web/drift_worker.dart.js`, potvrditi HTTP 200 i SHA-256 tog fajla, pa uraditi stvarnu proveru postojanosti nakon reload-a. Ovo je zahtev za potpun build paket, ne promena licencne logike. Raniji +5 prihvat se ne revidira automatski ovim lokalnim nalazom; njegov javni origin i postojeći podaci ostaju netaknuti.

Sadašnja NSIS komanda koristi `--build-number=5`; posle build-a kopirati ceo `build\\windows\\x64\\runner\\Release` u izolovani `build_input`, službeni ICO i `tools\\windows_installer\\OPC_WINDOWS_NSIS_403.nsi` u radni folder, zatim kompajlirati kopiju skripte sa `OPC_VERSION=4.0.3`. Ne instalirati test setup preko korisničkog Desktop-a ili postojećeg OPC profila; koristiti zaseban Windows test profil/VM za novu runtime proveru.

## Lokalni kandidat 4.0.3+7 i Web postojanost (25.10.2026)

IAB je i posle HTTP 200 za kompajlirani worker gubio nov sintetički nalog pri reload-u. Pregled IndexedDB je pokazao bazu, ali ne i upisano ime naloga. Zato worker 404 nije dokazan kao jedini uzrok. Zaključani Drift 2.32.1 zamenjen je verzijom 2.35.1 sa naknadnim ispravkama postojanosti Web IndexedDB upisa. U odvojenom stvarnom Chrome profilu na lokalnom originu `http://127.0.0.1:18789/`, +7 je sačuvao sintetičkog administratora, PREDMET `251026_1724`, ime `TEST` i prezime `POSTOJANOST` kroz više reload/prijava. Ovo potvrđuje samo taj profil i lokalni build; IAB +7 i javni Cloudflare update nisu prihvaćeni.

Za svaki naredni Web release serijski pokrenuti `flutter build web --release --no-pub --build-name=4.0.3 --build-number=<odobren_broj>` pa `dart compile js web/drift_worker.dart -O4 -o build/web/drift_worker.dart.js`. Pre arhiviranja proveriti `build/web/version.json`, `build/web/main.dart.js` i **kompajlirani** `build/web/drift_worker.dart.js`. `.map` i `.deps` iz kompilatora ne ulaze u distributivni ZIP. HTTP 200 za worker i stvarni reload sa postojećim nalogom/PREDMETOM su oba obavezna runtime uslova.

Trenutni Flutter 3.41.7 zaključava `meta 1.17.0` i `test_api 0.7.10`. `drift_dev` kompatibilan sa Drift 2.35.1 zahteva noviji `analyzer`/`meta`/`test_api`; `flutter pub get` sa njim je dokazano neuspešan. Zato je `drift_dev` privremeno uklonjen iz root `dev_dependencies`, bez menjanja već generisanog `database.g.dart`. Postojeći runtime, analiza, 696 testova i Web build prolaze. **Novo generisanje Drift modela nije potvrđeno u ovom SDK-u**; pre izmene šeme treba uspostaviti kompatibilan generator/toolchain u zasebnoj kontrolisanoj proveri. Ne koristiti `dependency_overrides` za prikrivanje konflikta.

## Lokalni +8 autosave i PWA provera (26.10.2026)

Aktuelni neobjavljeni kandidat je `4.0.3+8`. U stvarnom IAB +7 unos identiteta neposredno pre `SAČUVAJ`/izlaza izgubljen je zato što je 800 ms timer segmenta otkazan pri promeni ekrana; čekanje duže od 800 ms omogućilo je upis. +8 koristi 250 ms pauzu pri kucanju, a `PreminuloLiceSegmentState.flushPendingSave()` serijski završava čekajući upis pre promene segmenta, čuvanja ili izlaza. Gubitak fokusa sa polja IME/PREZIME takođe pokreće upis. Regressija eksplicitno pokriva brzi Save, Back, pauzu, promenu segmenta i polja bez Save. Ne izvoditi zaključak o svim drugim segmentima iz ovih testova.

Serijski `flutter analyze --no-pub` je bez nalaza; puna `flutter test --no-pub --concurrency=1` ima 701 PASS / 9 SKIP / 0 FAIL; zatim `flutter build web --release --no-pub --build-name=4.0.3 --build-number=8` i kompilacija worker-a prolaze. U lokalnom Chrome i IAB profilu na `http://127.0.0.1:18789/` raniji sintetički nalozi/PREDMETI i +8 izmena identiteta bez ručnog čuvanja opstali su posle reload-a i ponovne prijave. Chrome offline otvaranje postojećeg PREDMETA je prošlo. Javni Cloudflare je +5; +8 nije deploy-ovan. Pre naredne javne objave potreban je zaseban OWNER release pregled i stvarni same-origin update prihvat. `drift_dev` ograničenje iz prethodnog odeljka ostaje otvoreno za buduće promene šeme.

## Lokalni +9: čekajući upisi glavnih segmenata (26.10.2026)

Po dodatnom OWNER zahtevu za autosave pri promeni polja ili ekrana, +8 rešenje identiteta prošireno je na glavne segmente Platilac, Ceremonija, Parte i Finansije. Svaki segment zadržava postojeći `onSave` i poslovni companion, ali koristi 250 ms timer i `flushPendingSave()` koji čeka već započet upis. Roditeljski ekran poziva flush pre navigacije među segmentima i poslovnih akcija Save, izlaz, zatvaranje, završavanje i anonimizacija. Neposredna Parte odluka ide kroz istu serijsku putanju. Regresija obuhvata neposredan prelazak iz Platioca i Parte bez ručnog Save-a. +9 je zaseban build identitet; +8 Web artefakt nije zamena za njega.

Ovaj mehanizam ne obuhvata automatski zasebno ugnežđene kontakt redove, IRiU redove i druga polja sa sopstvenim timerima. Njihovo potpuno runtime prihvatanje ostaje zaseban uslov pre tvrdnje da je autosave univerzalan u celoj aplikaciji. Javni Cloudflare +5 i produkcioni paketi nisu menjani.

Završni lokalni +9 izlazi: analiza bez nalaza; serijska puna suite 703 PASS / 9 SKIP / 0 FAIL; Web release build broj 9 i kompajlirani `drift_worker.dart.js` prošli. `main.dart.js` SHA-256 `01B543B89865A15F68B43B0C9A42CB1C64C24C416BE6C125061DCB4671EF70A5`, worker SHA-256 `21DB0E6CE9325EF14888F04801EA7811D4B3D0314BDE117A9D7B520237EB131B`. Lokalni Web paket ima 56 fajlova, svaki hash je proveravan u ZIP-u, ZIP SHA-256 `F9AF82E62705D2A3694667BA4C1B3592713A8F565118D18C14867F700F91C8BF`. IAB je praktično potvrdio Platilac autosave posle promene segmenta i reload-a; Chrome i IAB stari nalozi/PREDMETI su opstali. Ne koristiti ovaj rezultat kao dokaz Cloudflare same-origin update-a ili standalone PWA instalacije.

## Ugnežđeni kontaktni i IRiU redovi — lokalni nastavak +9

Kod +9 glavnih segmenata nije čekao posebne 800 ms timere kontaktnih i IRiU redova. Pre korekcije ciljani IRiU widget test reprodukovao je gubitak poslednje izmene pri neposrednom unmount-u. Nastavak radnog kandidata dodaje registraciju ugnežđenih flush funkcija u `NarucilacSegmentState` i `IriuSegmentState`, serijski upis poslednjeg snapshot-a pri dispose i zaštitu redosleda upis/brisanje; `PredmetScreen` čeka i IRiU segment. Zadržani su postojeći repozitorijumi, model i poslovna pravila. Ciljana regresija 3/3, serijska analiza bez nalaza, puna suite 706 PASS / 9 SKIP / 0 FAIL, Web release broj 9 i kompajlirani worker su prošli. Detaljni logovi i stvarni Chrome/IAB post-reload dokazi su u `C:\Tale\OPC_REVIEW\NESTED_AUTOSAVE_20261026`.

Novi lokalni `main.dart.js` SHA-256 je `477C1D5F70E099AB0506E23EB9F23A71E93BB0C5A3E0D76D435E393765645F51`; worker ostaje `21DB0E6CE9325EF14888F04801EA7811D4B3D0314BDE117A9D7B520237EB131B`. Pošto je aplikacioni kod promenjen posle prethodnog +9 ZIP-a, prethodni ZIP hash `F9AF82...` i JS hash `01B543...` odnose se samo na istorijski +9 pre ove korekcije. Novi izlaz ima isti build-number 9 i sme biti označen samo kao lokalni korektivni snapshot; pre javnog izdanja potrebno je posebno verzionisanje i OWNER gate. Cloudflare +5 i platformski instalacioni paketi nisu menjani.
