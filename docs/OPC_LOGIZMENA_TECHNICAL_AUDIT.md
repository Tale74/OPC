# OPC `logIzmena` technical audit

**Status:** SOURCE-CONFIRMED TECHNICAL AUDIT — OWNER POLICY BOUNDARY IDENTIFIED — NO IMPLEMENTATION
**Datum:** 26. jul 2026.
**Base SHA:** `1168ccd41b1133daec77ce71ef0966ce937ccc0a`
**Task branch:** `task/OPC-GATE-0-LOGIZMENA-TECHNICAL-AUDIT`

## 1. Scope

Read-only review obuhvatio je:

- `logIzmena` schema i write/read putanje;
- PREDMET save/close/open/version lifecycle;
- individualni PREDMET JSON i full backup;
- replacement i deletion;
- user-reference lifecycle;
- UI i test evidence;
- privacy i migration rizik.

## 2. Source-confirmed current model

`lib/core/database/tables/log_izmena_table.dart` definiše:

- lokalni auto-increment `id`;
- `predmetId`;
- `korisnikId`;
- `datumVreme`;
- `polje`;
- `staraVrednost`;
- `novaVrednost`.

`logIzmena` pripada lokalnoj bazi i svaki red pokazuje na lokalni PREDMET i lokalnog korisnika.

## 3. Current write events

`PredmetiRepository` trenutno upisuje:

- `__save_commit_snapshot__` pri eksplicitnom save-u;
- `__confirmed_close_snapshot__` pri potvrđenom zatvaranju;
- `verzija` kada close poveća business verziju;
- `radni_ciklus` pri close/open toku.

Nije pronađen field-by-field audit svake korisničke izmene.

Automatski `ZAVRŠEN`, anonimizacija i običan `azurirajPredmet` ne proizvode potpuni audit događaj kroz ovu putanju.

## 4. Snapshot sadržaj

`snapshotZaSaveCommit` poziva `PredmetiData.toJson()` i uklanja samo:

- `status`;
- `verzija`;
- `exportVerzija`;
- `businessScenarioId`;
- `sourceIdentity`;
- create/last-modified user metadata.

Zato snapshot zadržava gotovo sav ostali sadržaj PREDMETA, uključujući:

- identitet i JMBG;
- adrese, telefone i e-mail;
- podatke PLATIOCA i JKP platioca;
- podatke ceremonije;
- PARTE tekstualni sadržaj;
- finansijske iznose i napomene.

`staraVrednost` i `novaVrednost` zato mogu sadržati duplirane sirove poslovne i lične podatke u JSON stringu.

## 5. Stvarna tehnička funkcija snapshot-a

Snapshot trenutno nije korisnički change-log prikaz. Koristi se kao tehnički checkpoint:

- za određivanje `Sačuvano / Nesačuvano`;
- za detekciju novog save commit-a;
- za poređenje sa poslednjim potvrđenim close stanjem;
- za odluku da li close povećava `verzija`.

Uklanjanje snapshot redova bez zamenskog checkpoint mehanizma promenilo bi save/version ponašanje.

## 6. Read/UI evidence

Source čita samo poslednji save/confirmed-close snapshot. Nije pronađen UI koji prikazuje listu `logIzmena` događaja.

`Pregled i potvrda` trenutno prikazuje:

- status;
- broj verzije;
- `Sačuvano / Nesačuvano`;
- lifecycle akcije.

To nije potpuni audit/change-log pregled.

## 7. Import, replacement, deletion i backup

### Individualni PREDMET JSON

- ne izvozi `logIzmena`;
- ne uvozi tuđi log ili tuđe `korisnikId` vrednosti.

### Replacement

- čuva lokalni tehnički PREDMET `id`;
- briše postojeći lokalni `logIzmena`;
- ne dodaje lokalni replacement događaj.

To je source-confirmed konflikt sa owner pravilom iz commita `1168ccd41b1133daec77ce71ef0966ce937ccc0a`.

### New import

Novi import ne dodaje lokalni import događaj.

### Full backup

Full backup izvozi i uvozi celu `logIzmena` tabelu zajedno sa korisnicima i PREDMETIMA. To je restore cele baze, ne individualni transfer.

### Delete

Brisanje PREDMETA briše njegov log.

## 8. User lifecycle dependency

Trajno brisanje lokalnog korisnika je blokirano ako postoje PREDMET ili `logIzmena` reference. Time trenutni model štiti referencu na autora, ali vezuje user lifecycle za log-retention politiku.

## 9. Test evidence

Nisu pronađeni fokusirani regression testovi koji zaključavaju:

- tačan skup log događaja;
- save/confirmed-close snapshot sadržaj;
- version increment matricu;
- očuvanje lokalnog loga pri replacementu;
- lokalni import/replacement događaj;
- full-backup log round-trip;
- odsustvo sirovih podataka iz budućeg audit event-a.

## 10. Tehnički zaključak

Current `logIzmena` meša dve različite odgovornosti:

1. tehnički business-state checkpoint potreban save/version mehanizmu;
2. buduću lokalnu audit evidenciju razumljivu korisniku.

To treba razdvojiti pre izlaganja change-log UI-a.

## 11. Codex tehnička preporuka

Bez owner promene poslovnog značenja:

- sačuvati lokalni audit-log model;
- ne prenositi ga individualnim JSON-om;
- uvesti lokalne `IMPORT_NEW` i `IMPORT_REPLACE` evente;
- replacement ne sme brisati postojeći lokalni audit log;
- tehnički checkpoint izdvojiti iz korisničkog audit događaja;
- zameniti raw snapshot skladištenje dokazivo bezbednim canonical checkpoint/hash modelom tek nakon migration i compatibility audita;
- audit event ne treba da kopira kompletan PREDMET;
- legacy snapshot redove ne brisati ili transformisati bez dokazane migracije koja čuva save/version ponašanje;
- dodati fokusirane repository, JSON/backup i Windows/Android parity testove pre runtime promene.

Ovo je tehnička preporuka, ne autorizacija implementacije.

## 12. Preostala owner granica

Kod ne može odlučiti koji događaji imaju poslovnu vrednost u budućem korisničkom pregledu.

Sledeća stvarna owner odluka je da li `Pregled i potvrda` treba da prikazuje:

- samo značajne lifecycle/import događaje; ili
- detaljniji pregled promenjenih poslovnih oblasti/polja.

Raw prethodne i nove vrednosti ne preporučuju se za UI ili audit event bez posebne owner odluke i privacy procene.

## 13. Status

`LOGIZMENA TECHNICAL AUDIT PASS — CHECKPOINT AND AUDIT RESPONSIBILITIES MUST BE SEPARATED — OWNER EVENT-VISIBILITY DECISION REQUIRED`

## 14. Owner closure

Owner je nakon ovog audita prihvatio Codex preporuku:

- korisnički pregled prikazuje značajne lifecycle/import događaje;
- događaj može navesti promenjene poslovne segmente;
- ne prikazuju se sirove prethodne/nove vrednosti niti svaki pojedinačni unos;
- tehnički checkpoint ostaje skriven i odvojen.

Status pitanja iz odeljka 12:

`CLOSED — OWNER DECISION RECORDED — IMPLEMENTATION NOT AUTHORIZED`

## 15. Code-first lifecycle/retention closure

Follow-up audit:
`docs/OPC_PREDMET_LIFECYCLE_LOG_RETENTION_AND_EVENT_TAXONOMY_AUDIT.md`.

The follow-up source audit closes the remaining technical design questions:

- technical checkpoints and local audit events require separate stores;
- checkpoints retain hashes/coverage metadata, not raw PREDMET values;
- minimum events are `CREATED`, `CLOSED_CONFIRMED`, `REOPENED`,
  `MANUALLY_FINISHED`, `ANONYMIZED`, `IMPORT_NEW` and `IMPORT_REPLACE`;
- `SCENARIO_CHANGED` and `ADVISER_REASSIGNED` apply only to the corresponding
  explicit business actions;
- audit/checkpoint rows remain while the PREDMET exists, including after
  anonymization;
- anonymization must remove/transform legacy raw snapshot PII;
- hard deletion removes PREDMET, audit events and checkpoints together;
- individual JSON excludes both responsibilities, while full backup preserves
  them as part of the complete local database family;
- legacy raw snapshots may be hashed only at proven
  `legacy_predmet_row_only` coverage and must not create invented historical
  segment changes or false business-version increments.

No new owner business decision remains.

Updated status:

`TECHNICAL DESIGN COMPLETE — NO NEW OWNER DECISION — IMPLEMENTATION BLOCKED`
