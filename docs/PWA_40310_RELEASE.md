# OPC Web/PWA 4.0.3+10 — kontrolisani Cloudflare kandidat

**OWNER odluka:** 26.10.2026, objava na postojećem testnom `https://opc-srb.pages.dev/` projektu je odobrena. Netlify i platformski instalacioni paketi nisu deo ovog izdanja.

## Izvor i obuhvat

Kanonska osnova je `C:\Tale\OPC\v1.5\BundleSource`. Izdanje konsoliduje ranije lokalno pregledane +6 licencne UI ispravke, +7 Drift Web postojanost sa kompajliranim worker-om, +8/+9 autosave glavnih segmenata i naknadnu korekciju ugnežđenih kontaktnih i IRiU redova. Njihovi detaljni rezultati su u spoljnim REVIEW paketima `LICENSE_UI_RESIDUAL_20261025` i `NESTED_AUTOSAVE_20261026`. Build broj 10 razlikuje ovaj izvršni kandidat od dva različita lokalna JS-a označena sa +9. Poslovna verzija 4.0.3, FIRMA identitet, licencni format i IRiU poslovna pravila nisu menjani.

Tačan Git commit, Web paket i javni asset manifest evidentirati u spoljnjem deployment REVIEW-u. QA i build moraju se odnositi na ovaj commit. Pre deployment-a javni origin je davao `version.json` build 5.

## Release prihvat

Na postojećem Cloudflare projektu potvrditi deployment success, javni `version.json` build 10 i hash-identitet `main.dart.js`, Drift worker-a, service worker-a, manifest-a i ikona. U browser-u dokazati stvarno učitani izvršni JS nakon običnog reload-a, ne samo HTTP odgovor. Na sintetičkom javnom profilu proveriti brzu promenu glavnog segmenta, kontakta i IRiU reda, reload/ponovno otvaranje, offline reload i povratak online. Standalone instalacija zahteva instaliranje i pokretanje iz ikone u zasebnom prozoru; sama prisutnost `manifest.json` nije prihvatni dokaz. Chrome i IAB profili imaju odvojene baze.

Ako bilo koja runtime površina ostane nedostupna, klasifikovati je kao BLOCKED/PARTIAL sa konkretnim razlogom. Ne pripisivati prethodne lokalne ili +5 rezultate novom javnom buildu.
