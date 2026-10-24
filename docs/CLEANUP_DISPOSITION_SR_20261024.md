# OPC v1.5 — kanonsko čišćenje i root disposition (2026-10-24)

**NAJNOVIJI STATUS:** Posle posebnog OWNER HUMAN GATE-a oba istorijska korena iz odeljka AUTO REVIEW REJECTED uklonjena su standardnim odobrenim postupkom. Taj odeljak ostaje zapis ranijeg odbijanja, a završni rezultat je na dnu dokumenta.

## Izvršeno u korektivnoj sesiji

Posle kopiranja/provere isporučivih Windows, Android i Web 4.0.3+5 paketa uklonjeni su samo regenerabilni `C:\Tale\OPC\v1.5\BundleSource\build` (2.761 fajl / 1.378.292.158 B), `BundleSource\.dart_tool` (225 / 461.007.107 B), privremeni NSIS staging direktorijum ove sesije (43 / 79.466.951 B) i emulator logovi ove sesije (360.123.088 B). Cache stabla nisu imala reparse veze. C: slobodno: 40.048.234.496 B neposredno pre, 42.307.338.240 B neposredno posle — merena promena **+2.259.103.744 B**. Kasniji uzorak 42.073.792.512 B pokazuje da je ukupni disk podložan međuvremenim upisima; ne menja neposrednu izmerenu cleanup razliku.

Prethodno odvojeno čišćenje `Docs` (40 dokumenata/89.220.839 B), tri ranija `.dart_tool` cache-a i duplikata APK-a (ukupno 606 fajlova/1.763.810.313 B logički) ostaje istorijski rezultat i nije uračunat u ovu sesiju.

## Root-level disposition

### KEEP / PROTECTED

| Putanja | Razlog |
|---|---|
| `C:\Projekti\OPC_v1.5\source` | Zaštićeni mixed worktree, HEAD `fe696408afc7ceae8aa7ecc80c4cda68c34e9130`, 59 prethodnih status redova. Ne menjati. |
| `C:\Tale\OPC\v1.5\source` | Isti HEAD i 59 status redova kao zaštićeni source; unutra su dodatni local-control materijali. Potvrđen kao zaštićena kopija, ne brisati. |
| `C:\Projekti\OPC_v1.5\PHASE1_PROTECTION` | Zaštitni/provenance materijal. |
| `C:\Projekti\OPC_v1.5\.codex-remote-attachments` | Task-control prilozi. |
| `C:\Tale\OPC\v1.5\BundleSource` | Jedini aktuelni source kandidat; manifest 497 fajlova, iz njega su izgrađeni Windows/Android/Web kandidati. |
| `C:\Tale\OPC\v1.5\Windows`, `Android`, `PWA`, `iOS`, `MacOS` | Zadržati postojeće pakete i nove `corrected+5` artefakte. Apple paketi su raniji technical-only artefakti, ne proglašavati ih tekućim release buildom. |
| `E:\LicGen` / OWNER issuer/signing files | Privatni seed, registry, P12 i signing kredencijali. Van source/review paketa. |
| Kanonske/poslovne baze i instalacioni korisnički podaci | Zaštita zahteva očuvanje; ne cilj ove cleanup radnje. |

### AUTO REVIEW REJECTED — potrebna konkretna OWNER odluka

| Putanja | Dokazana preprovera | Rezultat |
|---|---|---|
| `C:\Tale\OPC\Phase5Builds` | 876 fajlova / 125.465.220 B; root i potomci bez reparse; nema baze/privatnih ključeva. Jedan istorijski RR-011 izveštaj je supersedovan aktuelnim source/test ugovorom. | Remove-Item predat standardnom approval gate-u, odbijen pre kreiranja procesa. Automatska kontrola je navela da brisanje celog source/provenance materijala nije dovoljno konkretno odobreno. Ništa nije uklonjeno. |
| `C:\Tale\OPC\v1.5\BundleSource_History_20261024` | 1.478 fajlova / 59.323.283 B; bez reparse, baze ili privatnih ključeva; sadrži istorijske source/provenance snapshot-e. | Isti auto-review rejection za celovito brisanje source/provenance materijala. Ništa nije uklonjeno. |

Ne treba pokušavati alternativni API, shell, rename/move ili drugo indirektno brisanje ovih korena. Pre narednog pokušaja potreban je OWNER-ov konkretan pristanak na trajno uklanjanje **oba navedena istorijska korena**.

### OWNER GATE / nije uklonjeno

Sledeće stavke zadržane su prema postojećoj root disposition matrici; ova sesija nije ponavljala njihov sadržajni inventar niti ih je menjala:

- `C:\Projekti\OPC_v1.5_OWNER_CLOSURE_BACKUP_20261013` — closure backup/provenance.
- `C:\Projekti\OPC_v1.5\BACKUPS` — backup sadržaj.
- `C:\Projekti\OPC_v1.5\PHASE1_ARTIFACTS` i `PHASE2_ARTIFACTS_20261014` do `PHASE7_ARTIFACTS_20261015` — prethodni dokazni paketi i razvojni materijal.
- `C:\Projekti\OPC_v1.5\RESTORE_REHEARSAL` — restore/test data.
- `C:\Projekti\OPC_v1.5\REVIEW` — runtime/review dokazi i paketi.
- `C:\OPC_ANDROID_UPGRADE_TEST_20261020`, `C:\OPCW20261019`, `C:\OPCW20261020` — emulator/SQLite/istorijski testni koreni.

Prethodna matrica navodi jedinstveni/nepoznati sadržaj ili baze u ovim korenima. Ne brišu se na osnovu same činjenice da je BundleSource sada kanonski. Samo pojedinačno potvrđeni cache/duplikati mogu se obraditi odvojeno kada su opet prisutni i prethodna odobrenja važe.

`C:\Tale\OPC\v1.5\Docs` nije vraćen; ranije odobrenih 40 fajlova je uklonjeno i dokazi su van owner root-a.

## Završno izvršenje posle posebnog OWNER HUMAN GATE-a

OWNER je posebno odobrio trajno brisanje samo `C:\Tale\OPC\Phase5Builds` i `C:\Tale\OPC\v1.5\BundleSource_History_20261024`, uz završnu proveru. Pre izvršenja potvrđeno je: 477/477 fajlova istorijskog 4.0.3 commita `cc16f94` i 469/469 fajlova CommonSource-a prisutno je u tekućem BundleSource-u; 4.0.3 commit je predak tekućeg HEAD-a; svih 179 Git bundle objekata nalazi se u zaštićenom repozitorijumu, 178 imenovanih ref-ova se poklapa, a dodatni `HEAD` je simbolički unos. Pet ZIP arhiva ne sadrži člana nazvanog kao baza, private seed, registry ili signing ključ. U dva korena nema reparse tačaka, baza ili privatnih ključnih fajlova. Aktuelni BundleSource sadrži platformne projekte, CI workflow, installer template, zvaničnu ikonu, testove i build konfiguraciju; Windows/Android/Web paketi 4.0.3+5 bili su sačuvani i hash-provereni pre brisanja. `E:\LicGen\Private` je dostupan.

Standardna approval-gated komanda završila je exit 0. Uklonjeno je **876 + 1.478 = 2.354 fajla** i **125.465.220 + 59.323.283 = 184.788.503 B** logičkog sadržaja. Odmah pre komande C: slobodno **42.067.021.824 B**, odmah posle **42.257.027.072 B**: izmerena promena **+190.005.248 B**. Ne predstavljati taj disk delta kao zbir logičkih veličina. Naknadna nezavisna provera potvrdila je odsustvo obe putanje. Zaštićeni SOURCE i OWNER-root source ostali su na HEAD `fe696408afc7ceae8aa7ecc80c4cda68c34e9130` sa 59 ranijih status redova svaki; E: privatni root, kanonski BundleSource i platformni paketi ostali su prisutni. Nijedan drugi istorijski koren nije brisan.
