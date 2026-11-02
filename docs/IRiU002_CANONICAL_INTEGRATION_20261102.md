# IRiU-002 — kanonska SRB integraciona evidencija

**Status:** pripremljeno u izolovanom integracionom worktree-u; čeka LOGOS pregled i zasebnu OWNER publikacionu autorizaciju.  
**Osnova:** kanonski SRB `544fbb75a3f0dd41120f9677713f2359fc06e096`; prihvaćeni IRiU-002 implementacioni i završni regresioni paketi od 2026-11-02.

## Poslovni autoritet

PREDMET je jedini izvor poslovne istine. SCENARIO kernel formira početnu ponudu. Naknadno kataloško i ručno dodavanje predstavljaju ravnopravne korisničke dopune konkretnog PREDMETA. Kataloška stavka čuva `katalogStableArticleId`; poreklo `RUCNA_STAVKA` beleži korisnički nastanak reda, ne novu poslovnu kategoriju. SCENARIO ne poništava ovu dopunu. Postojeća semantika korisničkog brisanja ostaje nepromenjena.

## Integrisana korekcija

Živa putanja kataloškog dodavanja sada upisuje korisničko poreklo atomarno sa IRiU redom, čuva kataloški identitet i nezavisne vrednosti PREDMETA, a reselection postojećeg korisničkog reda zadržava poreklo. Truth/finance i njegove UI, dokumentacione, statističke i podsetničke projekcije koriste trajno poreklo; automatski i nepoznati redovi ostaju na svojim postojećim SCENARIO uslovima. Korisnički redovi ostaju posle početnih paketa u poslovnom redosledu.

PREDMET JSON i OPC Backup JSON čuvaju poreklo sa snapshot-om i bez njega. Provenance-only carrier koristi postojeći `singlePredmetScenario` root ključ sa jasno označenim `kind`, indeksiranim referencama, hash-om i proverama pokrivenosti i opsega. Ne stvara se fiktivni SCENARIO assignment. Nisu menjani SQL šema, root `schemaVersion` ni vrednosti porekla.

## Izvorna sledljivost

- `lib/features/predmeti/data/iriu_repository.dart`: `dodajKatalogSelection`, `_applyLiveCatalogSelection`, `_updateLiveCatalogSelection`, poreklo, ordering i projekcija porekla.
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`: aktivnost i finansijska podobnost iz stanja PREDMETA i porekla.
- `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`: kasniji korisnički redovi posle početnih paketa.
- `lib/features/predmeti/core_v2/scenario/single_predmet_scenario_carrier_contract.dart` i `lib/core/utils/json_export_import.dart`: validiran single-PREDMET carrier bez snapshot-a i full Backup prenos.
- `test/iriu002_user_catalog_regression_test.dart`: sintetički aktivni/finansijski slučajevi, SCENARIO zaštita, reopen, PREDMET JSON i Backup JSON sa/bez snapshot-a.

## QA dokaz i ograničenja

Integracioni worktree je zasnovan na `544fbb75a3f0dd41120f9677713f2359fc06e096`. Prenetih 18 produkcionih fajlova je sadržinski identično prethodnom LOGOS pregledanom paketu; završni regresioni fajl je bajt-identičan LOGOS pregledanom closure ZIP-u. QA u ovom worktree-u beleži se u pratećem integracionom izveštaju. Automatizovani testovi ne predstavljaju fizičko Windows, Android ili PWA prihvatanje. FIX-001 ostaje izvan obuhvata.

U kanonskom `docs` direktorijumu nisu pronađeni zasebni F1/F2 mehanizamski registri ili pseudokod. Njihov sadržaj nije rekonstruisan niti izmišljen; za ovaj zapis korišćeni su kanonski dokumenti o izvoru istine, domenu, arhitekturi, razvoju, kvalitetu, bazi i backup/restore, kao i pregledni paketi.

## OPC Int parity handoff

OPC Int primarni checkout nije menjan. Zaseban parity zadatak treba mapirati iste odgovornosti u `iriu_repository.dart`, `predmet_iriu_truth_service.dart` i njihovim finansijskim/UI/dokumentacionim potrošačima, ordering servisu, single-PREDMET carrier-u i `json_export_import.dart`. Preneti sintetičke tvrdnje za korisničko poreklo, finansijski zbir, reselection, reopen, JSON i Backup JSON. Pre izmene Int-a proveriti njegove stvarne funkcije i testove; SRB QA ne dokazuje Int prihvatanje.

**Kontrola publikacije:** nema commit-a, merge-a, push-a, build-a ili deployment-a u ovom koraku.
