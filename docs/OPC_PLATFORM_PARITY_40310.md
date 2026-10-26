# OPC 4.0.3+10 — pravilo jednakosti platformi i stanje 26.10.2026.

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
