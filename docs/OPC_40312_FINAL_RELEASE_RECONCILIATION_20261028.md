# OPC 4.0.3+12 — završna reconciliacija distribucije

Datum: 2026-10-28  
Status: **PARTIAL — distribucioni artefakti usaglašeni; Windows i Android instalacioni runtime za +12 nisu provereni.**

## Izvor i GitHub

- Kanonski izvor: C:\Tale\OPC\v1.5\BundleSource.
- Izolovana grana: codex/opc-v15-canonical-bundlesource-20261024.
- Bazni HEAD pre korekcije: 065db929daf63f5d62ddefa2caeae1af0a6b73ca.
- Aplikacioni izvorni commit: 1b22c848dc879f12b407f4a60f54a84c9eecf89c — Fix PARTE media persistence for Web.
- Commit sadrži tačno 7 odobrenih PARTE Web fajlova; prethodne nezavisne izmene u C:\Projekti\OPC_v1.5\source nisu uključene.
- Commit je objavljen isključivo na izolovanu granu. Lokalni i udaljeni ref su potvrđeni identični na 1b22c848dc879f12b407f4a60f54a84c9eecf89c.
- Prethodni Web build bio je napravljen pre commita iz radnog stabla. Pregled staged diff-a potvrdio je da je svih 7 promenjenih/dodatih fajlova jednako sadržaju commita; build manifesti zato beleže build pre commita i dirty-at-build flag, a ne predstavljaju ga kao clean-checkout build.
- Specijalni CRLF-aware diff check prošao je za staged korekciju. Standardni diff check prijavio je postojeće CRLF završetke kao whitespace; sadržaj nije normalizovan.

## QA i build dokaz

- Prethodno izvršen serijski flutter analyze: **PASS**.
- Prethodna puna Flutter suite: **706 PASS / 11 SKIP / 0 FAIL**. Ovo je zadržan dokaz iz prethodnog +12 ciklusa, nije ponavljan u ovoj reconciliaciji jer se izvorni sadržaj posle toga nije promenio.
- Ciljani native PARTE/PDF/DOCX testovi: **PASS** u prethodnom ciklusu.
- Web-specific Chrome test loader: **NOT VERIFIED** — prethodna dva pokušaja su ostala bez završetka; nisu proglašena prolaznim testom.
- Windows i Web +12 release outputi: prethodno izgrađeni iz istog sedmofajlnog izvornog stabla koje je potom commit-ovano. Windows payload 39/39 fajlova odgovara runtime manifestu. PWA paket 58/58 fajlova odgovara paketnom manifestu.
- Android release APK +12: izgrađen u ovoj reconciliaciji serijski iz kanonskog commita 1b22c848dc879f12b407f4a60f54a84c9eecf89c, uz postojeći release sertifikat. applicationId=com.tale.opc_v4, versionName=4.0.3, versionCode=12. apksigner verifikacija je uspešna; sertifikat SHA-256 4D1371C7573E5F61F2D6E662BC18176BF6E20F2E7541875147D3DCD34EB3AD65.
- Release lozinka i privatni ključevi nisu uključeni u source, distribuciju, evidenciju ili ovaj dokument.

## OWNER-PROVIDED PWA PARTE runtime acceptance

OWNER je dostavio dokaze za sintetički PREDMET 281026_1610, „Nepoznato Lice“, i izjavio da je na OPC PWA 4.0.3+12 fotografija ostala sačuvana nakon zatvaranja/ponovnog otvaranja, te da su PARTE DOCX i PDF otvoreni i sadržali fotografiju, tekst i osnovnu kompoziciju. Ovu stavku beležimo kao **OWNER-PROVIDED RUNTIME ACCEPTANCE — PASS** za navedeni PWA/PARTE opseg; Codex nije ponavljao korisničke radnje.

Originali su sačuvani u eksternom REVIEW paketu pod OWNER_RUNTIME_EVIDENCE/. SHA-256:

- Lice_Nepoznato_281026_1610_PARTA_v1.docx — DCFB704350093EF1337F1F490D003428DC7553ABCE626B1F73070D07892F9E8C.
- Lice_Nepoznato_281026_1610_PARTA_v1 (1).pdf — 7A9555F1EACCDF131D77161BEA6F17DCB3D30926918D2366974E60D458A5DFDE.
- Capture2.PNG — B118C5A605422862B8BEB0C5C5A764684E8C29C69AD3E1C8441421C1A7272780.
- Capture3.PNG — 7FB44BB6F80828AA7233E02417F6D8BA7C74581434766F5AED55265C5D6F11F7.
- Zadatak OPC_CODEX_V40312_FINAL_RELEASE_RECONCILIATION_20261028.md — 0ED60F3B089B0F585ECE0044122AA2948DBD2FCA152A85D350113360345A9346.

Ovo ne potvrđuje druge platforme, ostale dokumente ili sve moguće scenarije.

## Platformski artefakti

| Kanal | Lokalni artefakt | SHA-256 / identitet | Status |
|---|---|---|---|
| Windows runtime folder | OPC_Bundle/Windows/4.0.3+12 | OPC.exe F8F870987B601A4B711118D0EE403747E120A362A6B29EBBF6318F2E202B4AE6; 39 payload fajlova | Paketni payload potvrđen |
| Windows instalater | OPC_Setup_4.0.3_build12_PerUser_unsigned.exe | 3CFAA41872842D15E024157676CC532A18D28BBBA3807977A010EBE020FBAD0B; 15,662,730 B | NSIS compile PASS; **unsigned**; install/update runtime NOT VERIFIED |
| Windows portable | OPC_Windows_4.0.3_build12_portable.zip | 6B53C721348DF98EC30739F26691B3EBAB60556DDD9E3ED67CC0B64F82F01B34; 21,596,364 B | 41 ZIP stavki; OPC.exe hash odgovara runtime payload-u; portable runtime NOT VERIFIED |
| Android | OPC_Android_4.0.3_build12_release.apk | F6160A24FF0B94580B9553499BCDF838A39F06D884FDC05FBF0AD29EEB8A57C0; 79,900,952 B | Signed release PASS; install/update runtime NOT VERIFIED — adb devices -l nije našao uređaj |
| Web/PWA | OPC_Bundle/PWA/4.0.3+12/site | version.json 70D36EB90128C1CF956AC478AEEF2F9CDED3F3BEBB817AEB22DB329578583F4F; main.dart.js D8D27835175BA909647E53029A2F2D27E7AC2BDED343D7302E26753AC1D9C1FC; Drift worker 21DB0E6CE9325EF14888F04801EA7811D4B3D0314BDE117A9D7B520237EB131B; manifest 80DBA9344641545FDAC7E34B9B52C4100AA81EB6B03A44BC238F7E7627CFF8D9 | Publicnih 58/58 payload fajlova hash-identično; OWNER PWA runtime PASS za opisani PARTE opseg |
| iOS/macOS | Samo postojeći 4.0.3_technical CI paketi | lokalni folderski status; bez +12 user-installable paketa, bez potvrđenog Apple signing/notarization/runtime prihvata | NOT CURRENT / NOT DISTRIBUTABLE |

Stanje Windows-a: postoji postojeća HKCU\Software\OPC\Install putanja C:\Users\Steva\AppData\Local\Programs\OPC; aplikacija nije bila pokrenuta. Instalater nije pokretan preko te instalacije. adb devices -l je vratio praznu listu, zato APK nije instaliran. Nije menjan postojeći korisnički profil.

## Google Drive — opcrepo@gmail.com

Novi +12 paketi su dodati u postojeće javne platformске foldere; +11 paketi nisu uklonjeni ili preimenovani. Metadata za sva tri fajla potvrđuje anyone: reader i vlasnika opcrepo@gmail.com.

| Paket | Drive ID | SHA-256 lokalno i nakon Drive preuzimanja | Drive link |
|---|---|---|---|
| Windows PerUser installer (unsigned) | 1t7FBVWA3mOh39LGBeqaS0mcEMdaavoIS | 3CFAA41872842D15E024157676CC532A18D28BBBA3807977A010EBE020FBAD0B | https://drive.google.com/file/d/1t7FBVWA3mOh39LGBeqaS0mcEMdaavoIS/view |
| Windows portable ZIP | 1Zzdh5pLrUsSMNPB9iYePs6UGT0HQLkF2 | 6B53C721348DF98EC30739F26691B3EBAB60556DDD9E3ED67CC0B64F82F01B34 | https://drive.google.com/uc?export=download&id=1Zzdh5pLrUsSMNPB9iYePs6UGT0HQLkF2 |
| Android release APK | 15taR7X_Tf4607730ndVTOBMNO-z0d9yL | F6160A24FF0B94580B9553499BCDF838A39F06D884FDC05FBF0AD29EEB8A57C0 | https://drive.google.com/file/d/15taR7X_Tf4607730ndVTOBMNO-z0d9yL/view |

Anonimni GET na sva tri file/d/.../view linka vratio je HTTP 200 sa odgovarajućim nazivom paketa. Drive transfer endpoint prikazuje Google bezbednosno upozorenje za ove binarne fajlove; nije potvrđen bezuslovni direktni download bez tog koraka. Linkovi na opc-repo su ažurirani na ove ID-jeve, a portable dugme je jasno označeno kao ZIP/spoljašnji link. Sajt ne tvrdi da se datoteka preuzima bez Drive interstitial-a.

## Cloudflare

### Zvanični OPC PWA

- Postojeći opc-srb Pages project i https://opc-srb.pages.dev/ origin ostali su isti.
- Pre reconciliacije: deployment 70d0c344-a7a8-4e3d-90e3-24d944ad7fcf, commit_dirty=true; to je istorijski +12 deployment.
- Novi production deployment: 3d494ad0-522e-47ac-988f-5784666b27d0, https://3d494ad0.opc-srb.pages.dev, production branch main, status success, commit hash 1b22c848dc879f12b407f4a60f54a84c9eecf89c, commit_dirty=false.
- https://opc-srb.pages.dev/ vraća 4.0.3+12; svih 58/58 asseta hash-identično je lokalnom PWA paketu. Nije promenjen origin niti su resetovani browser podaci.

### Distribucioni sajt opc-repo

- Postojeći odvojeni project opc-repo i https://opc-repo.pages.dev/ ostali su isti.
- Production deployment za link correction: e63d0642-aaf6-4abc-ba7d-653089d1209f, https://e63d0642.opc-repo.pages.dev, status success, branch main, ad-hoc/dirty deployment bez Git commit hash-a.
- Ažurirana su samo 3 Drive ID-ja u postojećim Windows installer/portable/Android linkovima; portable oznaka je pojašnjena kao ZIP/spoljašnji Drive link. Zvanični PWA URL ostao je nepromenjen.
- Javna strana vraća HTTP 200, ne sadrži stare +11 Drive ID-jeve i sadrži sva tri nova ID-ja po jednom. Ostali statički resursi su bajt-po-bajt isti kao pre deployment-a. Nije rađen novi desktop/mobilni vizuelni pregled; CSS nije menjan.

## Preostale kontrole i konačna klasifikacija

- **PASS:** source commit/push; signed Android +12 artifact and signer; Windows installer and portable package static validation; local/Drive hashes and public access; Cloudflare PWA 58/58 asset parity; OWNER-PROVIDED PWA PARTE photo persistence/PDF/DOCX acceptance; public distribution links.
- **PARTIAL / NOT VERIFIED:** Windows +12 installer and portable install/runtime; Android +12 install/update runtime; Web-specific Chrome Flutter test loader; iOS/macOS user-installable distribution; new desktop/mobile visual review of the link-only opc-repo update.
- Global label: **PARTIAL — FINAL RECONCILIATION PASS kriterijum nije ispunjen.** Instalacioni runtime na Windows/Android i Apple user-distributable packages ostaju neprovereni/nedostupni; uspešan build ili upload ne menja taj status.

Očuvano: zaštićeni source checkout, kanonska poslovna baza, vlasnički ključevi, prethodni +11 paketi i Cloudflare origin. Private issuer/Android keystore fajlovi nisu kopirani u source, Google Drive, REVIEW paket ili site.