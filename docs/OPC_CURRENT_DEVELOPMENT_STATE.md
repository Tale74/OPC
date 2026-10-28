# OPC v1.5 — trenutno kanonsko stanje (ažurirano 2026-10-28)

## Release 4.0.3+12

Aplikacioni kod je na 1b22c848dc879f12b407f4a60f54a84c9eecf89c u izolovanoj grani codex/opc-v15-canonical-bundlesource-20261024; završna reconciliacija, platformski manifesti, GitHub, Drive i Cloudflare dokazi su u [OPC_40312_FINAL_RELEASE_RECONCILIATION_20261028.md](OPC_40312_FINAL_RELEASE_RECONCILIATION_20261028.md).

Klasifikacija je PARTIAL: PWA +12 runtime PARTE prihvat dostavio je OWNER; Android +12 je release-potpisan, ali nije instaliran na emulator/uređaj; Windows +12 instalater/portable runtime nije ponavljan nad postojećom Windows instalacijom; iOS/macOS korisnički paketi nisu dostupni. Stari +11 statusi niže su istorijski i ne predstavljaju aktuelni +12.

---
# OPC v1.5 — trenutno stanje razvoja
## Kanonski status 4.0.3+11 — 27.10.2026.

Kanonski izvor je C:\Tale\OPC\v1.5\BundleSource, izolovana grana codex/opc-v15-canonical-bundlesource-20261024, poslednji lokalni dokumentacioni HEAD pre ovog usklađivanja 31b215e33912ae5419ab58e0b24cb29c2c7b2735; source/build identitet aplikacionog +11 koda je 3c233bfdca512fee8c7b5a608cb16d66a9c898f7. Windows i Android imaju OWNER RELEASE ACCEPTANCE PASS. Njihov runtime status ostaje razdvojen. +10 ostaje javni Cloudflare PWA; +11 nije objavljen. Apple CI +11 je tehnički no-codesign/unsigned, bez instalabilnog runtime prihvata.

GitHub remote provera nije bila dostupna (HTTPS proxy veza odbijena; web pregled Cache miss); poslednji prethodno potvrđen remote SHA bio je 31b215e33912ae5419ab58e0b24cb29c2c7b2735. Aktuelni status i platformska matrica su u OPC_PLATFORM_PARITY_40310.md; istorijski nastavci ispod nisu aktuelan HEAD.


**Istorijski dodatak 26.10.2026:** provereni +10 commit-i su sinhronizovani na
izolovanu GitHub granu `codex/opc-v15-canonical-bundlesource-20261024`;
remote ref je potvrđen na `49bead17fe3a2c76d15678bbfe9c5de8fffbcf23`.
Za obavezno vlasničko pravilo petoplatformske funkcionalne i dokumentne
jednakosti i stvarni status različitih platformskih paketa pogledati
[OPC_PLATFORM_PARITY_40310.md](OPC_PLATFORM_PARITY_40310.md). Stariji statusi
u nastavku su istorijski trag, ne tvrde da je +10 već isporučen nativno.

Kanonski Flutter izvor je `C:\Tale\OPC\v1.5\BundleSource`, nastao kontrolisanim premeštanjem čistog 4.0.3 checkout-a sa prihvaćenog commit-a `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0`. Zaštićeni aktivni SOURCE `C:\Projekti\OPC_v1.5\source` ostaje na `fe696408afc7ceae8aa7ecc80c4cda68c34e9130` sa 59 ranijih status stavki; nije promovisan niti menjan.

Windows 4.0.3, Android 4.0.3 i Cloudflare PWA imaju ranije izolovane install/update dokaze opisane u [acceptance matrici](FINAL_ACCEPTANCE_MATRIX.md). iOS i macOS su tehnički CI izlazi bez produkcionog potpisa i praktičnog update prihvata. Cloudflare `https://opc-srb.pages.dev/` je jedini odobren PWA origin; Netlify je povučen.

Licenca: jedan trajni ključ za tačan PIB+MB jedne FIRME, bez ograničenja broja uređaja; može se aktivirati prvog dana. Trial traje tri kalendarska meseca; po isteku se bez aktivacije zabranjuje samo otvaranje novog PREDMETA. Private issuer/signing identitet i OWNER registar nalaze se izvan izvornog koda.

Detalji ponovljive gradnje, izvornog porekla i nedostajućih Apple uslova su u [SOURCE_BUILD_AND_CONTINUITY_SR.md](SOURCE_BUILD_AND_CONTINUITY_SR.md). Posle početne dokumentacione konsolidacije u kanonskom izvoru izvedene su ciljane 4.0.3+5 korekcije. Njihova regresija i platformski build dokazi pripadaju tom zasebnom kandidatu; stariji 4.0.3 dokazi ne dokazuju novo stanje.

## 2026-10-24 korektivni kandidat

Korekcija zahteva za licencu, prikaza trajne aktivacije, Android OWNER issuer UX i nova verzija 4.0.3+5 nalaze se u [CANONICAL_SOURCE_ACCEPTANCE_20261024.md](CANONICAL_SOURCE_ACCEPTANCE_20261024.md). Windows/Android/PWA artefakti su verzionisani u OWNER korenu. OWNER je 24.10.2026. praktično prihvatio Windows i Android 4.0.3+5 u posmatranom opsegu: in-place update, pokretanje, očuvanje baze i licence, uklanjanje suvišnog bannera i prikaz stvarne FIRME u licenci. Cloudflare objava/update i Apple distribucija nad +5 ostaju zasebne provere. Windows Desktop prečica i Android OWNER generator imaju zasebne prihvatne korake.

## Post-runtime zatvaranje — 24.10.2026.

Kanonska +5 korekcija je lokalno zabeležena na grani `codex/opc-v15-canonical-bundlesource-20261024`; OWNER je posebno odobrio objavu te izolovane grane; GitHub push je uspeo, a udaljeni ref je posle prvog post-runtime commita potvrđen na `90e89455ecd8f30942cccec3fff82519a85de4df`. Svaki naredni dokumentacioni commit na istoj grani treba zasebno potvrditi remote proverom. Windows +5 NSIS instalacija na OWNER testnoj mašini završila se exit 0; Desktop i Start prečice ciljaju instalirani `OPC.exe` 4.0.3+5, instalirani EXE SHA-256 je `BA440EBADA7815A9B3D64CEE915D1715E22CD8F20C8B4AE283ED1264CF1B0B46`, uninstaller postoji, a 5/5 ranije prisutnih lokalnih fajlova ima nepromenjen hash. Uninstall nije izvršen nad tom instalacijom.

Zasebni Android OWNER generator u `C:\Tale\Lic\AndroidIssuer` ima pojednostavljen prvi uvoz na Android-u i objašnjava lokalno zaštićeno pamćenje seed-a/registra. Posle ciljane analize i testova izgrađen je postojeće potpisan APK 1.0.1+2, SHA-256 `AEA2A369CA4CC16E51AA504BA3A2767A0791333538A19D1992E4977C41BDDCDD`, na `E:\LicGen\Android`. Nije ugrađen privatni seed ili registar; Android GUI runtime nove verzije nije praktično proveren jer ADB ne prikazuje uređaj. E: spoljašnji manifest je proverio 24/24 stavke.

Cloudflare `https://opc-srb.pages.dev/version.json` od 25.10.2026. javno vraća 4.0.3+5. Postojeći +5 PWA ZIP SHA-256 `2EEF943FD63F8AF4D4BAC5C990AF471C65B0B07F4FC8BE6EC215925448EA980E` objavljen je na istom projektu kao Production deployment `0cf8b32d-83ba-4998-ae8c-d419c3f8db22` (55 fajlova, success). Šest javnih fajlova, uključujući `main.dart.js` i service worker, hash-identični su ZIP unosima. U postojećem sintetičkom Chrome profilu PREDMET `211026_1946` ostao je prisutan posle reload-a, novog taba i provere bez mreže; mreža je potom vraćena. Samostalna standalone PWA instalacija, stvarni izlaz Copy/Share/Email zahteva, važeća sintetička aktivacija i istek trial-a nisu potvrđeni. Detaljna klasifikacija je u spoljnjem `C:\Tale\OPC_REVIEW\CLOUDFLARE_4035_FINAL_ACCEPTANCE_20261025\ACCEPTANCE_REPORT_SR.md`. Prihvaćena javna +5 objava ostaje netaknuta tokom naredne lokalne licencne UI korekcije.

## Lokalni korektivni kandidat 4.0.3+7 — 25.10.2026.

Licencne UI korekcije iz +6 i ciljano ažuriranje Drift Web runtime-a na 2.35.1 čine neobjavljeni +7 kandidat. Lokalni serijski `flutter analyze --no-pub`, puna suite (696 PASS / 9 SKIP / 0 FAIL) i Web release build su prošli. Kompajlirani `drift_worker.dart.js` je obavezan deo potpunog paketa. Stvarni Chrome test na zasebnom lokalnom originu potvrdio je sintetički nalog i PREDMET `251026_1724` sa imenom i prezimenom posle višestrukih reload-a i prijava. IAB je pre ažuriranja Drift-a gubio nalog uprkos prisutnom worker-u; IAB +7 nije ponovno prihvaćen. Javni Cloudflare ostaje +5. GitHub push, javni deployment i zamena Windows/Android paketa nisu izvršeni niti odobreni ovim korakom. Detalji i integritet artefakata su u spoljnjem REVIEW paketu, a reproduktivni Web postupak i ograničenje `drift_dev` generatora u [SOURCE_BUILD_AND_CONTINUITY_SR.md](SOURCE_BUILD_AND_CONTINUITY_SR.md).

## Lokalni korektivni kandidat 4.0.3+8 — 26.10.2026.

Naknadni IAB +7 test je dokazao da sintetički nalog i PREDMET opstaju posle reload-a kada je upis završen. Otkriven je odvojen korisnički defekt: trenutni pritisak na `SAČUVAJ` ili izlaz neposredno posle unosa imena mogao je preteći 800 ms odloženom upisu identiteta; prikazivao se nevalidan PREDMET, a uneta polja nisu bila sačuvana. +8 za segment `Preminulo lice` skraćuje pauzu autosave-a na 250 ms i dovršava čekajući upis pri gubitku fokusa, promeni segmenta, izričitom čuvanju i izlazu. Ne tvrditi da je ovim proverena automatska trajnost svakog drugog polja u svim segmentima.

Ciljana regresija ima 9 PASS; serijska puna suite 701 PASS / 9 SKIP / 0 FAIL, `flutter analyze --no-pub` bez nalaza i Web release build uspešan. Kompajlirani Drift worker je uključen. Na istom izolovanom lokalnom originu Chrome i IAB su nakon +8 učitali ranije kreirane sintetičke naloge/PREDMETE i sačuvali izmenu identiteta bez klika na `SAČUVAJ`, i posle reload-a. Chrome je dodatno otvorio postojeći PREDMET bez mreže, nakon čega je mreža vraćena. Samostalna PWA instalacija i javni same-origin +5→+8 update nisu potvrđeni. Cloudflare i dalje služi prihvaćeni +5; +8 nije objavljen, niti su zamenjeni Windows/Android paketi. Dokazi i manifest su u spoljnjem `C:\Tale\OPC_REVIEW\LICENSE_UI_RESIDUAL_20261025`.

## Lokalni autosave kandidat 4.0.3+9 — 26.10.2026.

OWNER je naglasio da korisnik neće uvek pritisnuti `SAČUVAJ` i da 800 ms nije prihvatljivo. Zato +8 identitetska korekcija nije tretirana kao opšte rešenje. Ciljana provera je našla isti 800 ms timer koji se otkazuje pri promeni ekrana u glavnim segmentima Platilac, Ceremonija, Parte i Finansije. +9 skraćuje njihovu pauzu na 250 ms, serijski čeka upis pri promeni segmenta, ručnom čuvanju, izlazu, zatvaranju, završavanju i anonimizaciji. Dodata je regresija za Platioca i odluku u segmentu Parte. Posebni kontakt redovi i IRiU redovi imaju zasebne mehanizme odloženog upisa; ovaj rezultat ih ne proglašava potpuno prihvaćenim.

+9 je neobjavljeni lokalni kandidat. QA, novi Web build i lokalni runtime dokazi moraju se vezati za +9 artefakt; raniji +8 Web ZIP i testovi ostaju istorijski dokazi pre proširenja. Javni Cloudflare ostaje +5. Izvorna osnova, privatni ključevi i instalirani paketi nisu promenjeni.

Završni +9 QA: `flutter analyze --no-pub` bez nalaza; puna serijska suite 703 PASS / 9 SKIP / 0 FAIL; `flutter build web --release --no-pub --build-name=4.0.3 --build-number=9` i zasebna kompilacija Drift worker-a uspešni. Lokalni server `http://127.0.0.1:18789/` vraća build 9. IAB je sačuvao postojeći nalog i PREDMET `251026_1750`; nov unos `AUTOSAVE4039` u polju IME Platioca opstao je nakon trenutne promene segmenta i reload-a bez pritiska na `SAČUVAJ`. Zasebni Chrome profil je posle +9 reload-a zadržao nalog, PREDMET `251026_1724` i ranije autosave polje `AUTO`. Potpun Web ZIP sadrži 56 fajlova i SHA-256 `F9AF82E62705D2A3694667BA4C1B3592713A8F565118D18C14867F700F91C8BF`. Javna same-origin nadogradnja i standalone PWA instalacija nisu testirane; Cloudflare ostaje +5.

Browser bundle provera: dokumentovani CUA CDP `Page.getResourceContent` je u otvorenom Chrome i IAB tabu pročitao stvarno učitani `main.dart.js`; oba SHA-256 su `01B543B89865A15F68B43B0C9A42CB1C64C24C416BE6C125061DCB4671EF70A5`, identična lokalnom +9 build-u. Time je isključeno pogrešno pripisivanje +8 PWA cache verzije novim +9 UI rezultatima. Detalji su u spoljnjem završnom REVIEW paketu.

## Lokalna korekcija ugnežđenog autosave-a — 26.10.2026.

U nastavku +9 otkriven je poseban gubitak poslednje IRiU izmene pri neposrednom uklanjanju reda sa ekrana: njen 800 ms timer se otkazivao u `dispose`, a roditeljski flush nije čekao ugnežđeni red. Isti životni ciklus postojao je u kontaktnom redu. Kanonski radni kandidat sada serijski dovršava čekajuće upise kontaktnih i IRiU redova pre roditeljske navigacije/Save/Back i pri uklanjanju reda; brisanje čeka prethodni upis da se obrisani red ne vrati. Nema promene šeme, poslovnih IRiU pravila ili licencnog formata. Ovo je i dalje necommitovano mešovito radno stablo +6/+7/+8/+9 i ove ciljane korekcije, na HEAD `0f2104f973dfccbb3523f88875cfd349dc843bc6`.

Ciljani widget testovi: 3 PASS, uključujući brzi unmount i trke sa brisanjem. Serijski `flutter analyze --no-pub`: bez nalaza; puna `flutter test --no-pub --concurrency=1`: 706 PASS / 9 SKIP / 0 FAIL; Web release build broj 9 i Drift worker kompilacija: PASS. Novi lokalni `main.dart.js` SHA-256 je `477C1D5F70E099AB0506E23EB9F23A71E93BB0C5A3E0D76D435E393765645F51`; worker SHA-256 `21DB0E6CE9325EF14888F04801EA7811D4B3D0314BDE117A9D7B520237EB131B`. Na `http://127.0.0.1:18789/` Chrome i IAB koriste odvojene sintetičke baze: kontaktni i ručni IRiU redovi su opstali posle trenutne promene ekrana ili Save/Back, ponovnog učitavanja, prijave i otvaranja istog PREDMETA. Vizuelni i QA dokazi su u spoljnjem `C:\Tale\OPC_REVIEW\NESTED_AUTOSAVE_20261026`.

Lokalni dokaz ne obuhvata sve moguće kontaktne blokove, svaku IRiU poslovnu putanju, javni same-origin update, offline ponašanje ni standalone PWA instalaciju. Cloudflare i dalje služi prihvaćeni +5; javni deployment, GitHub push i zamena instalacionih paketa zahtevaju zasebnu OWNER odluku.

## Javni Cloudflare PWA 4.0.3+10 — 26.10.2026.

Gornji status +5 predstavlja istorijsko stanje pre nove OWNER-odobrene objave. Prihvaćene lokalne +6/+7/+8/+9 korekcije i ugnežđeni autosave sada su na kanonskom commitu `48ded2a8516b8a1e934a74492bf07bddb5624f49`. Web-only build broj 10 objavljen je na postojećem `https://opc-srb.pages.dev/` kao Production deployment `24cd0b48-01f8-4901-97a8-efcc165fcb09`. Deset javnih asseta i stvarno učitani JS u Chrome-u i IAB-u hash-identični su paketu. Javna Chrome provera potvrdila je trajnost glavnog polja, kontaktnog i IRiU reda posle prelaza i reload-a, kao i offline otvaranje i novu offline izmenu sačuvanu posle reload-a. Odvojeni IAB profil potvrdio je nalog, novi PREDMET i polje Platioca posle reload-a. Standalone PWA instalacija nije stvarno izvedena jer native CUA nije mogao da prikaže Chrome instalacioni meni; ne klasifikovati je kao PASS. Detalji su u [PWA_40310_RELEASE.md](PWA_40310_RELEASE.md) i spoljnjem `C:\Tale\OPC_REVIEW\PWA_40310_DEPLOY_20261026`. GitHub push i promena drugih platformskih paketa nisu izvršeni.
