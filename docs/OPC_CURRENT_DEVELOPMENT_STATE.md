# OPC v1.5 — trenutno stanje razvoja

Kanonski Flutter izvor je `C:\Tale\OPC\v1.5\BundleSource`, nastao kontrolisanim premeštanjem čistog 4.0.3 checkout-a sa prihvaćenog commit-a `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0`. Zaštićeni aktivni SOURCE `C:\Projekti\OPC_v1.5\source` ostaje na `fe696408afc7ceae8aa7ecc80c4cda68c34e9130` sa 59 ranijih status stavki; nije promovisan niti menjan.

Windows 4.0.3, Android 4.0.3 i Cloudflare PWA imaju ranije izolovane install/update dokaze opisane u [acceptance matrici](FINAL_ACCEPTANCE_MATRIX.md). iOS i macOS su tehnički CI izlazi bez produkcionog potpisa i praktičnog update prihvata. Cloudflare `https://opc-srb.pages.dev/` je jedini odobren PWA origin; Netlify je povučen.

Licenca: jedan trajni ključ za tačan PIB+MB jedne FIRME, bez ograničenja broja uređaja; može se aktivirati prvog dana. Trial traje tri kalendarska meseca; po isteku se bez aktivacije zabranjuje samo otvaranje novog PREDMETA. Private issuer/signing identitet i OWNER registar nalaze se izvan izvornog koda.

Detalji ponovljive gradnje, izvornog porekla i nedostajućih Apple uslova su u [SOURCE_BUILD_AND_CONTINUITY_SR.md](SOURCE_BUILD_AND_CONTINUITY_SR.md). Posle početne dokumentacione konsolidacije u kanonskom izvoru izvedene su ciljane 4.0.3+5 korekcije. Njihova regresija i platformski build dokazi pripadaju tom zasebnom kandidatu; stariji 4.0.3 dokazi ne dokazuju novo stanje.

## 2026-10-24 korektivni kandidat

Korekcija zahteva za licencu, prikaza trajne aktivacije, Android OWNER issuer UX i nova verzija 4.0.3+5 nalaze se u [CANONICAL_SOURCE_ACCEPTANCE_20261024.md](CANONICAL_SOURCE_ACCEPTANCE_20261024.md). Windows/Android/PWA artefakti su verzionisani u OWNER korenu. OWNER je 24.10.2026. praktično prihvatio Windows i Android 4.0.3+5 u posmatranom opsegu: in-place update, pokretanje, očuvanje baze i licence, uklanjanje suvišnog bannera i prikaz stvarne FIRME u licenci. Cloudflare objava/update i Apple distribucija nad +5 ostaju zasebne provere. Windows Desktop prečica i Android OWNER generator imaju zasebne prihvatne korake.
