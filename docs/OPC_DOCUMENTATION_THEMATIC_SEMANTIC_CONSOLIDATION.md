# OPC — thematic semantic consolidation of blocked documentation

**Status:** CONSOLIDATION COMPLETE — OWNER DECISION QUEUE REMAINS — NO DELETION
**Datum:** 26. jul 2026.
**Base SHA:** `bebefd9e3f84a488f97a0ac00e133acc518f0420`
**Task branch:** `task/OPC-GATE-0-DOCUMENTATION-SEMANTIC-CONSOLIDATION`

## 1. Svrha

Ovaj dokument konsoliduje svih 704 reda koji su posle extraction/cross-map faze konzervativno ostali označeni kao `OWNER_SEMANTIC_REVIEW_REQUIRED`.

Konsolidacija ne menja poslovnu politiku i ne autorizuje uklanjanje. Ona:

- uklanja lažni owner teret nastao iz naslova, task oznaka i proceduralnih rečenica;
- odvaja current owner authority od istorijskih pravila;
- grupiše stvarne otvorene poslovne odluke;
- štiti fragmente koji nemaju dovoljan samostalni kontekst;
- obezbeđuje red-po-red dokaz u `docs/OPC_DOCUMENTATION_SEMANTIC_CONSOLIDATION_EVIDENCE_REGISTER.md`.

## 2. Kontrolni rezultat

Svih **704** reda ima sledljivu dispoziciju:

| Dispozicija | Broj | Značenje |
| --- | ---: | --- |
| `HISTORICAL_EVIDENCE_ONLY` | 101 | Naslovi i oznake nemaju samostalno normativno značenje. |
| `CODEX_TECHNICAL_DISPOSITION` | 82 | Tehničko, arhitektonsko ili proceduralno pravilo u Codex authority domenu. |
| `TECHNICAL_AUDIT_GOVERNED` | 3 | Rešava se dokaznim tehničkim auditom; owner zadržava izdavačku/distribucionu odluku. |
| `CURRENT_AUTHORITY_PRESERVED` | 10 | Sadržaj je zaštićen u aktuelnom authority skupu. |
| `CONFLICT_RESOLVED_BY_CURRENT_OWNER` | 27 | Legacy PAKETI/licensing politika je supersedovana aktuelnom owner odlukom. |
| `DEFERRED_OUT_OF_SCOPE` | 19 | OPC Web/server/sync navodi ne pripadaju aktuelnom implementacionom scope-u. |
| `OWNER_DECISION_REQUIRED` | 280 | Grupisano u sedam poslovnih klastera. |
| `PROPOSED_BUSINESS_CHANGE` | 13 | Preporuke/pitanja nisu owner odluke. |
| `INSUFFICIENT_CONTEXT_PROTECTED` | 169 | Fragment nema dovoljan kontekst za bezbedno uklanjanje izvora. |
| **Ukupno** | **704** | Potpun kontrolni zbir. |

## 3. Stvarni konflikti poslovne politike

### 3.1. SCENARIO condition-change i stale IRiU redovi

Legacy pravilo kaže da sistem pri promeni uslova ne sme tiho uklanjati redove. Novija owner odluka zahteva rešavanje zastarelih/nepotrebnih IRiU redova kada se promeni SCENARIO uslov.

Ovo nije konflikt PREDMET authority principa, već konflikt lifecycle procedure:

- završeni PREDMET mora ostati istorijski stabilan;
- FIRMA default/template promena deluje samo prospektivno;
- nezavršen PREDMET može promeniti SCENARIO samo eksplicitnom kontrolisanom korisničkom radnjom;
- još nije zaključano da li reconciliation automatski predlaže, obavezno potvrđuje ili samo označava redove za uklanjanje;
- validni korisnički podaci ne smeju biti izgubljeni.

Status: `OWNER DECISION REQUIRED`.

### 3.2. Legacy PAKETI/licensing nasuprot aktuelnom proizvodu

Legacy dokumenti sadrže package entitlement, issuer, keypair i licensing runtime pravila. Aktuelna owner odluka je jasna:

- PAKETI su trajno napušteni u tekućem proizvodu;
- Stage 1 uklanjanja runtime ograničenja je završen;
- Stage 2 uklanja mrtav package/licensing kod;
- čuvaju se samo neutralne module/capability granice i Git dokazni trag;
- budući kupac može uvesti novi licensing sloj bez zadržavanja mrtvog runtime koda.

Status: `CONFLICT RESOLVED BY CURRENT OWNER`; owner akcija sada nije potrebna.

### 3.3. Automatski `ZAVRŠEN` nasuprot planiranoj ručnoj promeni

Current source/raniji dokumenti opisuju automatsko ponašanje, dok odobreni razvojni pravac zahteva eksplicitnu korisničku promenu statusa, sa lifecycle posledicama različitim od anonimizacije.

Status: poslovni smer je owner potvrđen; detalji implementacionog lifecycle ugovora ostaju u klasteru `PREDMET-LIFECYCLE-PODSETNIK`.

### 3.4. SCENARIO kao hard-coded politika nasuprot korisničkim FIRMA template-ima

Legacy izvori tretiraju više scenarijskih pravila kao zaključana u kodu. Aktuelna owner odluka zahteva:

- ispravku postojećih scenario grešaka;
- potpuno korisnički prilagodljive postojeće scenarije u PODEŠAVANJA;
- kreiranje, čuvanje, import/export scenario template-a;
- pojedinačni i kompletan FIRMA default set;
- SCENARIO snapshot u svakom PREDMETU;
- bez retroaktivne promene završenih PREDMETA.

Status: smer je `CONFLICT RESOLVED BY CURRENT OWNER`; exact reconciliation pravila ostaju otvorena.

### 3.5. Raniji PARTE media audit nasuprot novijem closure authority-ju

Raniji media audit je sadržao otvorena pitanja. Noviji `OPC_OWNER_DECISION_GUIDE.md` i PARTE closure reporti zaključavaju app-owned media, external-original zaštitu, retention i explicit deletion ponašanje.

Status: `CURRENT AUTHORITY PRESERVED`; raniji otvoreni audit nije current owner queue.

### 3.6. OPC Web/SaaS/server pretpostavke

Legacy dokumenti sadrže Web/SaaS/server/database-family predloge. Aktuelna odluka zadržava Windows i Android kao ravnopravne lokalne aplikacije, dok je OPC Web van scope-a.

Status: `DEFERRED_OUT_OF_SCOPE`; nijedan server ne postaje PREDMET authority.

### 3.7. PDF RAČUN legacy legal block nasuprot FIRMA toggle odluci

Aktuelna owner odluka ne uvodi PDV, fiskalizaciju niti automatsku pravnu klasifikaciju. Postojeći PDF RAČUN ostaje dostupan samo kroz jednostavan FIRMA toggle.

Status: poslovni smer je `CURRENT OWNER AUTHORITY`; document-by-document naslednik mora biti zapisan u budućem PDF audit tasku.

## 4. Genuine owner decision klasteri

| Klaster | Redova | Zašto owner odluka ostaje potrebna |
| --- | ---: | --- |
| `PREDMET-IDENTITY-JSON` | 113 | `brojPredmeta` scope/uniqueness, version/freshness, konflikt politika, FIRMA metadata, change-log i import history. |
| `IRiU-KATALOG-STOCK-BACKUP` | 85 | Full-backup stock politika, import/replace consequence reconciliation i legacy IRiU pravila bez jednog current naslednika. |
| `AUTH-ROLE-LIFECYCLE` | 27 | PIN/recovery/admin-selection/role lifecycle tvrdnje nisu objedinjene u current authority dokumentu. |
| `PREDMET-LIFECYCLE-PODSETNIK` | 23 | Tracking item, potvrda, odlaganje, reopen/override/history, notification action i status coupling. |
| `STANDARD-DOCUMENT-DERIVATIVES` | 17 | Legacy PDF/DOCX specifična pravila treba pojedinačno potvrditi ili supersedovati tokom standard document audita. |
| `SCENARIO-IRiU-RECONCILIATION` | 10 | Tačan UX i data ugovor promene SCENARIO-a na nezavršenom PREDMETU. |
| `TERMINOLOGY-PLATILAC-NARUCILAC` | 5 | Canonical korisnički termin i bezbedna DB/JSON/template cleanup/migration putanja. |
| **Ukupno** | **280** | Owner odlučuje po klasterima, ne po 280 pojedinačnih redova. |

## 5. Tehničke i arhitektonske dispozicije

Codex može bez nove poslovne odluke da primeni sledeće principe u budućim auditima:

- PREDMET je jedina poslovna istina; derivati i operativni moduli ne smeju ga reinterpretirati;
- Windows i Android imaju isti poslovni rezultat uz dozvoljene OS-specifične mehanizme;
- Local DB row `id` nije cross-device business identity;
- servisne operacije moraju biti idempotentne i sprečiti dvostruke posledice;
- document engine čita pripremljene važeće podatke i ostaje modularan;
- privacy, UTF-8, Git, validation i backup discipline su proceduralne kapije;
- signing tehnologija, modularne granice, state-management i refactor strategija pripadaju tehničkom auditu;
- tehnički audit ne sme sam odlučiti poslovni status, scenario posledicu, role pravo ili istorijsku istinu PREDMETA.

## 6. Predložene, ali neodobrene poslovne promene

Trinaest redova je klasifikovano kao preporuka/pitanje, a ne authority. Tematski pripadaju:

- strožoj automatskoj JSON version/freshness zaštiti;
- repository/database-family identitetu;
- budućem Web/server/sync modelu;
- budućim promenama terminologije;
- owner-review milestone/promotion predlozima;
- pojedinačnim UI ili lifecycle preporukama.

Nijedna nije implementaciono odobrenje. Ako ulazi u aktuelni OPC v.1 plan, mora najpre proći odgovarajući owner decision gate. Predlozi vezani za OPC Web ostaju odloženi.

## 7. Fragmenti bez dovoljnog konteksta

Preostalih 169 redova nisu proglašeni zastarelim. To su:

- uvodne rečenice čiji se spisak nalazi u nastavku izvornog odeljka;
- delovi tabela bez kompletne kolone/reda;
- kratke locked oznake;
- normativne rečenice čije značenje zavisi od susednih stavki.

Za njih važi zaštitno pravilo: izvorna putanja ostaje `BLOCKED` dok current dokument ne preuzme značenje kompletnog odeljka ili owner ne odobri njegovu dispoziciju.

## 8. Posledica za removal manifest

- nijedna putanja nije obrisana;
- nijedna od 61 putanje još nije automatski `PASS FOR REMOVAL`;
- 704-redni evidence register omogućava sledeću owner odluku po sedam klastera;
- tek posle odluka i section-level zaštite može se pripremiti precizni removal candidate manifest;
- Git history rewrite ostaje zabranjen.

## 9. Gate rezultat

`SEMANTIC CONSOLIDATION PASS — OWNER BUSINESS DECISION CLUSTERS REMAIN — REMOVAL NOT AUTHORIZED`
