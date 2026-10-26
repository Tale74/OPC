# OPC Web/PWA 4.0.3+10 — kontrolisani Cloudflare kandidat

**OWNER odluka:** 26.10.2026, objava na postojećem testnom `https://opc-srb.pages.dev/` projektu je odobrena. Netlify i platformski instalacioni paketi nisu deo ovog izdanja.

## Izvor i obuhvat

Kanonska osnova je `C:\Tale\OPC\v1.5\BundleSource`. Izdanje konsoliduje ranije lokalno pregledane +6 licencne UI ispravke, +7 Drift Web postojanost sa kompajliranim worker-om, +8/+9 autosave glavnih segmenata i naknadnu korekciju ugnežđenih kontaktnih i IRiU redova. Njihovi detaljni rezultati su u spoljnim REVIEW paketima `LICENSE_UI_RESIDUAL_20261025` i `NESTED_AUTOSAVE_20261026`. Build broj 10 razlikuje ovaj izvršni kandidat od dva različita lokalna JS-a označena sa +9. Poslovna verzija 4.0.3, FIRMA identitet, licencni format i IRiU poslovna pravila nisu menjani.

Tačan Git commit, Web paket i javni asset manifest evidentirati u spoljnjem deployment REVIEW-u. QA i build moraju se odnositi na ovaj commit. Pre deployment-a javni origin je davao `version.json` build 5.

## Release prihvat

Na postojećem Cloudflare projektu potvrditi deployment success, javni `version.json` build 10 i hash-identitet `main.dart.js`, Drift worker-a, service worker-a, manifest-a i ikona. U browser-u dokazati stvarno učitani izvršni JS nakon običnog reload-a, ne samo HTTP odgovor. Na sintetičkom javnom profilu proveriti brzu promenu glavnog segmenta, kontakta i IRiU reda, reload/ponovno otvaranje, offline reload i povratak online. Standalone instalacija zahteva instaliranje i pokretanje iz ikone u zasebnom prozoru; sama prisutnost `manifest.json` nije prihvatni dokaz. Chrome i IAB profili imaju odvojene baze.

Ako bilo koja runtime površina ostane nedostupna, klasifikovati je kao BLOCKED/PARTIAL sa konkretnim razlogom. Ne pripisivati prethodne lokalne ili +5 rezultate novom javnom buildu.

## Izvršena objava i prihvat — 26.10.2026.

Izvorni commit je `48ded2a8516b8a1e934a74492bf07bddb5624f49`; GitHub push nije izvršen. Web build `4.0.3+10` i kompajlirani Drift worker upakovani su u `C:\Tale\OPC\v1.5\PWA\4.0.3+10\OPC_PWA_4.0.3_build10_CLOUDFLARE.zip`, SHA-256 `E7A52B82AA52986705423872E45D1F7FE19A20ADBFA03C3BC4BB93DF5C5F7570`. Postojeći Cloudflare projekat `opc-srb` objavio je Production deployment `24cd0b48-01f8-4901-97a8-efcc165fcb09` na nepromenjenom originu. `version.json` javno vraća build 10; deset javnih resursa odgovara manifestu. Stvarno učitani `main.dart.js` u Chrome i IAB profilu ima SHA-256 `477C1D5F70E099AB0506E23EB9F23A71E93BB0C5A3E0D76D435E393765645F51`.

Chrome javna sintetička baza: postojeći nalog i PREDMET `211026_1946` opstali su posle objave i reload-a. Izmene Platioca, JKP tipa, kontaktnog i ručnog IRiU reda opstale su posle brze promene segmenta i reload-a. Offline reload je pokrenuo aplikaciju i otvorio isti PREDMET; nova offline izmena adrese `OFFLINE 40310` opstala je nakon promene segmenta i drugog offline reload-a. Mreža je zatim vraćena.

Odvojeni IAB javni profil: postojeći sintetički nalog opstao je posle reload-a; novi PREDMET `261026_1801` i polje Platioca `IAB SAVE 40310` opstali su posle promene segmenta i reload-a. Ovo nije sinhronizacija Chrome i IAB baza.

Samostalna Chrome instalacija **nije potvrđena**: CUA kontrola taba ne prikazuje browser toolbar, a podržana kontrola Chrome prozora dva puta je istekla pre snimka instalacionog menija. Manifest i ikone su objavljeni i hash-provereni, ali to ne dokazuje instalaciju. Prvi unos u Platiočev naziv neposredno nakon promene tipa u Chrome-u dao je privremeno prazan prikaz; ponovljeni unos sa potvrđenom vrednošću, kao i nezavisni JKP tip slučaj, opstali su posle prelaza i reload-a. Ovo iskustvo ostaje evidentirano kao ograničenje jednostrukog pokušaja, bez potvrđenog gubitka konačno unete vrednosti.

Detaljna matrica, logovi, screenshot-ovi i javni hash poređenje su u spoljnjem `C:\Tale\OPC_REVIEW\PWA_40310_DEPLOY_20261026`. Nijedan Windows/Android/Apple paket, privatni ključ, kanonska poslovna baza ili zaštićeni SOURCE nisu menjani ovim izdanjem.
