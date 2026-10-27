# OPC 4.0.3+11 — dokumentna isporuka i kontinuitet (27.10.2026)

## Provereni identitet

- Kanonski izvor: `C:\Tale\OPC\v1.5\BundleSource`; jedina odobrena GitHub grana za ovaj ciklus: `codex/opc-v15-canonical-bundlesource-20261024`.
- `SOURCE_COMMIT` svih tehničkih kandidata je `3c233bfdca512fee8c7b5a608cb16d66a9c898f7`. Push je potvrđen fast-forward proverom udaljenog SHA. +11 aplikacioni kod potiče iz `d242605877e54379744ecc3eeea88759ce12f9a8`; razlika do `3c233bf` bila je samo dokumentacija. Naknadni dokumentacioni zapisi ne menjaju identitet builda.
- GitHub Actions `40456238530`: Analyze and test, Windows, iOS no-codesign i macOS tehnički build PASS; Android CI job SKIP jer privatni release signer nije konfigurisan u CI. Zasebni manifest gate `40456238578` PASS. Lokalni release Android APK je potpisan postojećim OWNER certifikatom. iOS/macOS CI artefakti nisu potpisani za korisničku distribuciju.
- Javni `https://opc-srb.pages.dev/` ostaje prihvaćeni +10. +11 nije javno objavljen. Instalirani Windows/Android paketi nisu zamenjeni.

## Dokumentni put i runtime

RAČUN PDF/DOCX dele `RacunDocumentData`; ostali predviđeni generatori su zajednički Dart moduli. Web, Android i desktop se razlikuju u adapteru za dobijene bajtove (`lib/core/utils/export_utils.dart`), bez poslovnog forka. Mapa izvora: spoljni REVIEW `SOURCE_ROUTE_SR.md`.

Lokalni +11 Web: stvarno preuzeti RAČUN PDF/DOCX (raniji REVIEW), SPECIFIKACIJA TROŠKOVA PDF i uslovna ČITULJA PDF u IAB-u; RAČUN DOCX i u zasebnom Chrome profilu. PDF-ovi se parsiraju i renderuju; Chrome DOCX se otvara OOXML parserom. Word vizuelno otvaranje nije potvrđeno. `main.dart.js`, Drift worker i `version.json` iz ponovnog `3c233bf` builda imaju iste SHA-256 kao prethodni browser testirani +11 kandidat. PARTE runtime nije potvrđen, jer akcija nije bila dostupna u tim sintetičkim PREDMETIMA; postoje zasebni fixture dokazi generatora. Samostalna PWA instalacija i offline +11 su NOT VERIFIED.

Windows +11: CI build PASS, lokalni dokumentni runtime NOT VERIFIED bez izolovanog korisničkog profila. Android +11: release build i potpis PASS, ali izolovani AVD nije završio boot, pa instalacija/update i izvoz nisu provereni. iOS/macOS: CI tehnički build PASS, stvarni runtime i dokumentni izvoz NOT VERIFIED. Nijedan tehnički build ne predstavlja automatski platformski prihvat.

## Granice i nastavak

Dokazi, kandidati i SHA manifest: `C:\Tale\OPC_REVIEW\FIVE_PLATFORM_40311_DELIVERY_20261027`; raniji REVIEW: `C:\Tale\OPC_REVIEW\OPC_40311_FIVE_PLATFORM_CANDIDATE_REVIEW_20261027.zip`, SHA-256 `E196A67933B7F087642EB5ADC67D3AC8F79FC59D0EC9F81C3C5C1BCA70024A90`. Aktuelna statusna matrica je na vrhu `docs/OPC_PLATFORM_PARITY_40310.md`.

Zaštićeni istorijski `C:\Projekti\OPC_v1.5\source`, poslovna baza, korisnički profili, `E:\LicGen` privatni materijal i postojeće produkcione instalacije nisu menjani. Bez nove OWNER odluke nema Cloudflare deployment-a, zamene distributivnih paketa, promene licence/ključeva ili zaštićenih grana. Sledeći dozvoljeni praktični korak: u zasebnom Windows test profilu proveriti instalaciju +11 i stvarno otvaranje RAČUN PDF/DOCX, pa zasebno nastaviti Android i Apple runtime kada su odgovarajuća okruženja dostupna. Ne ponavljati već uspešnu punu QA ili build bez konkretne promene koda.
