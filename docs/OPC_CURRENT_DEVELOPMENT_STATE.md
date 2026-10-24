# OPC v1.5 — trenutno stanje razvoja

Kanonski Flutter izvor je `C:\Tale\OPC\v1.5\BundleSource`, nastao kontrolisanim premeštanjem čistog 4.0.3 checkout-a sa prihvaćenog commit-a `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0`. Zaštićeni aktivni SOURCE `C:\Projekti\OPC_v1.5\source` ostaje na `fe696408afc7ceae8aa7ecc80c4cda68c34e9130` sa 59 ranijih status stavki; nije promovisan niti menjan.

Windows 4.0.3, Android 4.0.3 i Cloudflare PWA imaju ranije izolovane install/update dokaze opisane u [acceptance matrici](FINAL_ACCEPTANCE_MATRIX.md). iOS i macOS su tehnički CI izlazi bez produkcionog potpisa i praktičnog update prihvata. Cloudflare `https://opc-srb.pages.dev/` je jedini odobren PWA origin; Netlify je povučen.

Licenca: jedan trajni ključ za tačan PIB+MB jedne FIRME, bez ograničenja broja uređaja; može se aktivirati prvog dana. Trial traje tri kalendarska meseca; po isteku se bez aktivacije zabranjuje samo otvaranje novog PREDMETA. Private issuer/signing identitet i OWNER registar nalaze se izvan izvornog koda.

Detalji ponovljive gradnje, izvornog porekla i nedostajućih Apple uslova su u [SOURCE_BUILD_AND_CONTINUITY_SR.md](SOURCE_BUILD_AND_CONTINUITY_SR.md). Ovaj doc-only korak ne menja Dart/native build ulaze; istorijski QA/CI dokazi pripadaju prethodnom 4.0.3 commit-u, a ne novom dokumentacionom stanju.
