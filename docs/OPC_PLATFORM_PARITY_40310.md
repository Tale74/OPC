# OPC 4.0.3+11 — isporuka dokumenata, aktuelni pregled 27.10.2026.

**Aktuelna OWNER metoda prihvatanja:** svih pet platformi ostaju jedna OPC aplikacija sa jednakim poslovnim pravilima i zajedničkim generatorima. Ovaj ciklus proverava da korisnik na svakoj dostupnoj platformi može da dobije upotrebljiv PDF/DOCX. Detaljno međusobno poređenje teksta i izgleda svih pet izlaza nije novi release uslov. Ranija matrica ispod ostaje istorijski dokaz tadašnjeg stanja, uključujući tadašnje zabrane push-a i nepotvrđene Apple buildove; ne koristiti je kao sadašnji status. OWNER je doneo završni OWNER RELEASE ACCEPTANCE PASS za Windows i Android 4.0.3+11. To je release odluka, ne runtime PASS: Windows launch je viđen, ali install/update i dokumenti nisu provereni; Android install/update nije uspeo zbog Package Manager greške, a app/document runtime nije testiran. Ne ponavljati te runtime pokušaje bez konkretne nove potrebe.

**Jedinstvena revizija za tehničke kandidate:** `3c233bfdca512fee8c7b5a608cb16d66a9c898f7` na izolovanoj grani `codex/opc-v15-canonical-bundlesource-20261024`, potvrđena lokalno i udaljeno. Razlika od +11 kodnog commita `d242605` je isključivo prethodna dokumentacija. GitHub Actions run `40456238530` i manifest gate `40456238578` su PASS. Lokalni Android APK i Web bundle ponovo su izrađeni iz `3c233bf`; APK, `main.dart.js`, worker i `version.json` bajtno su jednaki ranijim +11 kandidatima, što povezuje prethodni Web runtime dokaz sa istim izvršnim kodom. Build PASS ne znači runtime PASS.

| Platforma | Tehnički kandidat iz `3c233bf` | Stvarni dokumentni runtime | Odluka |
|---|---|---|---|
| Web/PWA | Lokalni release Web + worker PASS, isti JS/worker hash kao browser testirani +11 | IAB RAČUN PDF/DOCX (raniji REVIEW), dodatno SPECIFIKACIJA TROŠKOVA PDF i sadržajna ČITULJA PDF; Chrome RAČUN DOCX, OOXML validan. Samostalna PWA instalacija i offline +11 nisu provereni | PARTIAL |
| Windows | GitHub CI release build PASS; raniji lokalni +11 kompletan release folder iz bajtno istog aplikacionog koda | +11 zasebna instalacija i otvaranje PDF/DOCX nisu provereni bez izolovanog Windows profila | NOT VERIFIED runtime |
| Android | Lokalni production release APK PASS; potpis postojećim release certifikatom potvrđen | Izolovani AVD nije dovršio boot; nema instalacije, PDF/DOCX izvoza ni update dokaza | NOT VERIFIED runtime |
| iOS | GitHub CI no-codesign compile PASS, artefakt 12713610315 | Nema potpisane instalacije ni uređajskog dokumentnog runtime-a | NOT VERIFIED runtime |
| macOS | GitHub CI nepotpisani tehnički app PASS, artefakt 12712603732 | Nema instalacije, otvaranja PDF/DOCX ni notarizacije | NOT VERIFIED runtime |

Generatori RAČUN PDF/DOCX koriste `RacunDocumentData`; ostali PDF/DOCX generatori su zajednički Dart kod. Web, Android i desktop adapteri u `export_utils.dart` razlikuju se u transportu bajtova. Source mapa i stvarni fajlovi su u spoljnjem `C:\Tale\OPC_REVIEW\FIVE_PLATFORM_40311_DELIVERY_20261027`. PARTE runtime nije potvrđen jer akcija nije bila omogućena u korišćenim sintetičkim PREDMETIMA; fixture generator dokaz je u prethodnom REVIEW-u. Za release odluku i dalje nedostaju stvarni Windows, Android i Apple korisnički izlazi. Javni Cloudflare ostaje +10; nema zamene distribucionih paketa.

---

# Istorijski +11 kandidat pre ovog izvršavanja

Ovaj odeljak je aktuelni status. Donji +10 odeljak ostaje istorijska referenca za ranije prihvaćeni javni PWA. +11 je isključivo lokalni kandidat iz commita `d242605877e54379744ecc3eeea88759ce12f9a8`, na izolovanoj grani `codex/opc-v15-canonical-bundlesource-20261024`. Nema GitHub push-a, Cloudflare deployment-a ni zamene instaliranih paketa. Istih pet platformi mora imati jednaka poslovna pravila, dokumentne vrednosti, polja, redosled i vizuelnu strukturu; build uspeh to sam ne dokazuje.

## Potvrđena izmena i QA

Pre izmene je Web DOCX transport u `sacuvajKoriceDokumentFajlDetalji` pozivao `Platform.isAndroid` iz `dart:io`; minimalna JS proba dala je `Unsupported operation: Platform._operatingSystem`. +11 dodaje samo Web transport već generisanih DOCX bajtova kroz postojeći browser download adapter i odgovarajući MIME tip. Generatori, poslovna pravila i licencni format nisu menjani. Serijski `flutter analyze --no-pub`: PASS, `No issues found!`; cela `flutter test --no-pub --concurrency=1 --timeout 2m`: PASS, 706 prošlih, 10 preskočenih, 0 neuspešnih. Ciljani sintetički RAČUN/PARTE fixture testovi: 21 PASS. Web Chrome test runner se i pre i posle korekcije zadržao na `Running test suite` bez događaja, pa njegov ishod nije PASS. Stvarni IAB test ispod nezavisno potvrđuje transport.

Toolchain: Flutter 3.41.7, Dart 3.11.5; `pubspec.lock` SHA-256 `8B7D64C5E6F668016AC1C8897C5CE37C6DE12069C9B9D105E79FED79113E9B26`.

## Platformska matrica kandidata +11

| Platforma | Build iz istog commita | Runtime i dokumenti | Status |
|---|---|---|---|
| Web/PWA | PASS, release 4.0.3+11, `drift_worker` dodat; aktivni IAB JS hash jednak serviranom buildu | PASS za stvarno preuzimanje i validnost RAČUN PDF i DOCX iz postojećeg sintetičkog PREDMETA; ostali dokumenti, offline +11 i samostalna PWA instalacija nisu provereni | PARTIAL |
| Windows | PASS, kompletan release folder; `OPC.exe` 4.0.3+11 | +11 nije instaliran/pokrenut u zasebnom profilu; dokumentni izlazi nisu provereni | PARTIAL |
| Android | PASS, production release APK, versionCode 11, v2 potpis; certifikat isti kao postojeći +5 | +11 nije instaliran: nema povezanog izolovanog ADB emulatora; izlazi nisu provereni | PARTIAL |
| iOS | +11 nije izgrađen: lokalni host je Windows; lokalni commit nije objavljen, a push je zabranjen u ovom zadatku | Nema +11 runtime ni dokumenata | BLOCKED |
| macOS | Isto kao iOS | Nema +11 runtime ni dokumenata | BLOCKED |

Stariji Apple CI artefakti iz `cc16f94a` nisu +11 kandidati. Ranije instalirani Windows/Android +5 i javni PWA +10 ostaju važeći samo u svom ranije prihvaćenom obuhvatu.

## Dokazna matrica dokumenata

`predmet_screen.dart` nudi SPECIFIKACIJU TROŠKOVA, PREDRAČUN, LISTU, NALOG ZA OPREMANJE, NALOG CVEĆARI, RAČUN PDF/DOCX, te uslovno PARTE PDF/DOCX i ČITULJE PDF. Generatori su zajednički Dart kod; to još nije potvrda jednakosti svih platformskih izvoza.

| Dokument | Zajednički generator | Stvarni IAB +11 eksport | Windows/Android +11 | iOS/macOS +11 |
|---|---|---|---|---|
| RAČUN PDF/DOCX | PASS, sintetički fixture | PASS, oba preuzeta i strukturno proverena | NOT VERIFIED | NOT VERIFIED |
| PARTE PDF/DOCX | PASS, sintetički fixture | NOT VERIFIED, uslovna radnja nije aktivirana | NOT VERIFIED | NOT VERIFIED |
| Ostalih pet standardnih PDF-ova | Postojeći zajednički kod prolazi celu suite; zaseban međupatformski fixture nije sproveden | NOT VERIFIED | NOT VERIFIED | NOT VERIFIED |
| ČITULJE PDF | Postojeći zajednički kod prolazi suite; uslovni runtime nije sproveden | NOT VERIFIED | NOT VERIFIED | NOT VERIFIED |

Fixture testovi iz istog sintetičkog ulaza su proizveli RAČUN PDF/DOCX i PARTE PDF/DOCX. Dvanaest odabranih sintetičkih oznaka i poslovnih vrednosti postoji u odgovarajućim fixture PDF/DOCX parovima. Zasebno, iz istog stvarnog IAB PREDMETA, 13/13 odabranih oznaka i vrednosti postoji u oba preuzeta RAČUN fajla. To su uska sadržajna poređenja, ne puna provera redosleda ili vizuelne jednakosti. Prve fixture PDF strane su renderovane i pregledane. DOCX vizuelni prikaz nije proverljiv u ovom hostu jer `soffice.exe` nije dostupan. Stvarni IAB RAČUN DOCX je valjan OOXML ZIP, a stvarni RAČUN PDF je ispravan A4 dokument. Fixture i IAB izlazi koriste različite sintetičke PREDMETE i ne treba porediti njihove hash-eve kao dokaz jednakosti.

## Release granica

+11 je tehnički pripremljen lokalni kandidat. **Petoplatformska funkcionalna i dokumentna jednakost ostaje NOT VERIFIED.** Potrebni su istovetni sintetički ulazi na svakom runtime-u, izvoz svih uslovno dostupnih dokumenata, sadržajno i vizuelno poređenje, kao i instalacija/ažuriranje uz očuvanje podataka. Za Apple CI iz tačnog +11 commita potrebna je posebna OWNER odluka o objavi izolovane grane. Kandidati, logovi i SHA-256 manifest su izvan BundleSource-a u `C:\Tale\OPC_REVIEW\FIVE_PLATFORM_40310_20261027`.

---

# Istorijsko stanje +10, 26.10.2026.

Windows, Android, iOS, macOS i PWA moraju poticati iz iste prihvaćene izvorne revizije i predstavljati istu poslovnu aplikaciju. Za isti PREDMET, iste podatke, podešavanja, licencno stanje i resurse svi izlazi moraju imati iste poslovne vrednosti, nazive polja, redosled, uslovna pravila i izgled. Tehnički način čuvanja/preuzimanja fajla može se razlikovati, ali ne sme promeniti sadržaj ili mogućnost dobijanja dokumenta. Build uspeh nije dokaz ovog pravila.

## Trenutna matrica

| Platforma | Sačuvani paket | Dokaz | Status jednakosti sa +10 |
|---|---|---|---|
| PWA | 4.0.3+10, Cloudflare | Javni JS i worker identični paketu; browser autosave i offline provere iz prihvata +10 | PARTIAL — samostalna instalacija i svi dokumenti nisu provereni |
| Windows | 4.0.3-corrected+5 | Raniji praktični install/update i licencni prihvat | NOT VERIFIED — paket ne sadrži +10 korekcije |
| Android | 4.0.3-corrected+5 | Raniji praktični install/update i licencni prihvat | NOT VERIFIED — paket ne sadrži +10 korekcije |
| iOS | 4.0.3 technical CI, izvor `cc16f94a` | CI kompilacija bez potpisa i instalacije | NOT VERIFIED — stariji izvor; nema runtime prihvata |
| macOS | 4.0.3 technical CI, izvor `cc16f94a` | CI kompilacija bez potpisa i instalacije | NOT VERIFIED — stariji izvor; nema runtime prihvata |

Git kanonskog `BundleSource` za +10 je `48ded2a8516b8a1e934a74492bf07bddb5624f49` za kod; kasniji dokumentacioni commit-i ne menjaju taj kod. Vezani javni Cloudflare deployment je `24cd0b48-01f8-4901-97a8-efcc165fcb09`.

## Trag dokumenata i konkretna ograničenja

`predmet_screen.dart` nudi šest standardnih PDF-ova (SPECIFIKACIJA TROŠKOVA, PREDRAČUN, LISTA, NALOG ZA OPREMANJE, NALOG CVEĆARI, RAČUN), RAČUN DOCX i zasebne PARTE/ČITULJE izlaze. Generatori su zajednički Dart kod u `lib/features/predmeti/pdf/`, `parte/pdf/`, `parte/docx/` i `citulje/pdf/`. RAČUN PDF i DOCX koriste zajednički `RacunDocumentData`; eksportovani bajtovi se tek zatim predaju platformskom mehanizmu za čuvanje. Postojeća PDF kontraktna/fixture testiranja pokrivaju delove sadržaja i prikaza, ali nisu petoplatformsko poređenje izlaznih dokumenata iz istog PREDMETA.

PDF transport u `lib/core/utils/export_utils.dart` (86–117) ima poseban Web download, Android storage i desktop fajl. Nasuprot tome, DOCX transport (120–139) nema Web granu i poziva `Platform.isAndroid`/`dart:io`. **Ovo je izvorno potvrđen rizik PWA DOCX eksportovanja, ne runtime potvrđen defekt.** Pre tvrdnje o jednakosti treba izvršiti RAČUN i PARTE DOCX u PWA, uporediti ih sa nativnim izlazima i po potrebi zasebno odobriti korekciju.

## Obavezna naredna kontrola izdanja

1. Iz istog prihvaćenog izvornog commit-a izgraditi svih pet platformi; Apple potpis/instalacija zahtevaju odgovarajuće spoljne identitete i okruženje. Ne menjati sadašnje prihvaćene pakete bez OWNER odluke.
2. Na svih pet izvršnih okruženja učitati isti sintetički PREDMET i ista podešavanja. Izvesti svaki ponuđeni PDF/DOCX. Uporediti poslovne vrednosti, nazive, redosled, uslovna pravila, izgled i dostupnost fajla. PDF metapodaci mogu biti različiti; sama jednakost SHA-256 nije jedini prihvatni kriterijum.
3. Zasebno potvrditi install/update i očuvanje podataka po platformi, zatim sastaviti manifest sa izvorom, verzijom, hash-evima i rezultatima.

Do završetka tih koraka petoplatformska jednakost ostaje **NOT VERIFIED**.
