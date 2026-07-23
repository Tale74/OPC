# OPC — authoritative development plan revision report

**Status:** DOCUMENTATION-ONLY REVISION COMPLETE – FINAL OWNER REVIEW REQUIRED
**Plan status:** DRAFT – FINAL OWNER REVIEW REQUIRED
**Autoritativnost:** Revidirani plan još nije autoritativan.
**Datum:** 23. jul 2026.

## 1. Git baseline i task

- Branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-REVISION`
- Base branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-OWNER-REVIEW-FINDINGS`
- Base SHA: `5734eee9c952bf67458727ca26203bacc0a1cf6a`
- Final SHA: stvarni branch-tip SHA navodi se u završnom CODEX → GIT delivery odgovoru i javnom GitHub commit linku. Commit ne može sadržati sopstveni SHA bez promene tog SHA; report zato ne unosi samoreferentnu netačnu vrednost.

Pre izmene je potvrđeno:

- očekivana branch i HEAD;
- lokalni HEAD i origin bili su identični;
- divergencija `0/0`;
- worktree čist;
- audit, originalni draft, preparation report i OWNER_REVIEW_FINDINGS prisutni i čitljivi iz Git commita.

## 2. Promenjeni fajlovi

Dodati su samo:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_REVISED_DRAFT.md`
- `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_REVISION_REPORT.md`

Nisu menjani niti uklonjeni:

- originalni audit;
- originalni draft plan;
- owner-review preparation report;
- OWNER_REVIEW_FINDINGS;
- postojeća autoritativna OPC dokumentacija;
- aplikacioni kod;
- testovi;
- SQLite fajlovi;
- migracije;
- JSON schemas;
- build/signing/IDE konfiguracija;
- runtime ponašanje;
- canonical baza ili business data;
- lokalni autoritativni dokumentacioni izvor.

SHA-256 revised plan review kopije:

`EDAE89DB7201ABB8362CE77C832EB5DAA74C161C0E40F27BF914DFA14392CA29`

## 3. Reconciliation osnova

Ponovo su pročitani current Git manifest, source-of-truth, owner-decision, stop-list, development-state, migration, workflow i local-doc promotion dokumenti, kao i relevantni lokalni `PROJECT_DOCS` izvori konflikta.

Klasifikacija:

- Git `docs/` upravlja current public continuity baseline-om;
- lokalni `PROJECT_DOCS` ostaju supporting/historical evidence;
- lokalni “Master” iskaz nije automatski promovisan;
- istorijski Git-absence iskazi su superseded stvarnim Git tokom;
- package-era pravila su superseded za current product novijom owner odlukom;
- `main` naspram stacked task lineage-a ostaje genuine governance owner decision;
- schema 21/22 tekst zahteva kasnije dokumentaciono razjašnjenje, ali nije pronađen dokaz nedostajuće current migracije.

Nijedan konflikt nije tiho pretvoren u novu owner odluku.

## 4. OWNER_REVIEW_FINDINGS resolution matrix

| Finding | Naslov | Revised plan section | Status | Resolution | Preostala owner odluka |
| --- | --- | --- | --- | --- | --- |
| F-01 | Architecture/rewrite gate prekasno | 8–9, 25 | FULLY RESOLVED | Minimum evidence Phase 1 i rani Architecture Decision Gate sada prethode velikom scenario/refactor radu. | Owner bira konačnu architecture option posle audita. |
| F-02 | Windows multiple-instance prioritet | 8.2, 10.2, 25 | FULLY RESOLVED | Multiple-instance je data-integrity prioritet, odvojen od startup UX-a i podignut pre status/feature rada. | Owner potvrđuje architecture ponašanje posle dijagnostike. |
| F-03 | Dijagnoza odvojena od implementacije | 6, 8, 10 | FULLY RESOLVED | Uveden je obavezni sedmostepeni lifecycle od source-learning-a do Git closure-a; root-cause kandidat nije autorizacija. | Samo scope-specifične odluke posle nalaza. |
| F-04 | Ne zaključavati fizički snapshot | 4.2, 9.3–9.4, 14 | PARTIALLY RESOLVED – OWNER DECISION REQUIRED | Plan zaključava istorijski stabilan scenario ishod, ali poredi copied/versioned/reference/normalized/hybrid reprezentacije. | Owner bira persistence model posle audita. |
| F-05 | Postojeći scenariji potpuno izmenjivi | 4.3, 14.2 | FULLY RESOLVED | Eksplicitno je uklonjena pretpostavka zaštićenog system originala; svi korigovani scenariji postaju user-editable. | Nema odluke o osnovnom zahtevu; UI detalji dolaze u tasku. |
| F-06 | Historical/completed lifecycle | 12.1–12.2, 21 | PARTIALLY RESOLVED – OWNER DECISION REQUIRED | Dodata je zasebna owner kapija za open/completed/closed/anonymized/deleted/legacy-auto-completed i druge locked states. | Owner odlučuje lock, reverzibilnost, reopen/correction i legacy tretman. |
| F-07 | Semantic parity umesto bezuslovnog byte parity-ja | 3.3, 6.7, 23–24 | FULLY RESOLVED | Uvedeni semantic parity, controlled metadata/sanitization i dual-hash reconciliation; byte identity samo kada je bezbedna i moguća. | Nema nove poslovne odluke. |
| F-08 | Stage 2 ne blokira OPC Srbija | 4.5, 17–18, 25 | FULLY RESOLVED | Stage 2 je kasniji architecture/cleanup scope i nije predecessor Serbia gate-a bez dokazive zavisnosti. | Owner kasnije autorizuje Stage 2 scope. |
| F-09 | Merljiva performance acceptance | 8.3–8.4, 11 | PARTIALLY RESOLVED – OWNER DECISION REQUIRED | Definisani su procedure, hardware classes, release/cold/warm/fixture/frame baseline i pre/posle dokazi. | Owner odobrava numeričke targete posle baseline merenja. |
| F-10 | Backup/restore rehearsal | 13 | FULLY RESOLVED | Obavezni su isolated copies, realistic/partial fixtures, idempotency, backup readability, restore rehearsal i no-merge-to-canonical pravilo. | Live canonical upgrade uvek zahteva eksplicitnu owner autorizaciju. |
| F-11 | Dva product-line gate-a | 17, 19 | PARTIALLY RESOLVED – OWNER DECISION REQUIRED | Odvojeni su binding OPC Srbija gate i kasniji multilingual gate; oba srpska pisma su obavezna, albanski isključen. | Owner bira app identities, update kanale i multilingual architecture. |
| F-12 | Git/main integration politika | 3.2, 7, 21, 24 | PARTIALLY RESOLVED – OWNER DECISION REQUIRED | Uveden je Gate 0 za stacked branches, operational HEAD, main, release baseline, merge/consolidation i historical branches. | Owner bira formalni Git integration model. |

Nijedan nalaz nije `NOT RESOLVED – STOP`.

## 5. Zaključane odluke koje nisu vraćene u queue

Revised plan kao konstante, a ne pitanja, tretira:

- PREDMET authority;
- SCENARIO pripada PREDMETU;
- FIRMA defaults/templates deluju prospektivno;
- završeni PREDMET ne prima retroaktivne scenario/KATALOG promene;
- postojeći scenariji posle korekcije potpuno su user-editable;
- scenario save/import/export i individualni/kompletni FIRMA defaults;
- Windows/Android ravnopravnost;
- SQLite i JSON interchange;
- napuštanje PAKETA i završen Stage 1;
- Stage 2 kao poseban future cleanup;
- OPC Web van current scope-a;
- JSON relokacija;
- napuštanje automatskog `ZAVRŠEN`, uz otvorena lifecycle pravila;
- completion signali kao derivat;
- PDF per-document typography;
- RAČUN availability toggle bez VAT/fiscal/legal inference-a;
- Windows system theme princip;
- exclusion albanskog;
- oba srpska pisma u multilingual verziji;
- technical PASS odvojen od owner runtime acceptance-a.

## 6. Genuine owner decision queue

### Pre autoritativnog usvajanja

1. Git/main/integration model i formalni operational/release baseline.
2. Odobrenje revised dependency reda.

### Posle minimum evidence audita

3. Architecture option.
4. Scenario persistence model.
5. Historical/completed lifecycle, `ZATVOREN`/`ZAVRŠEN`, reopen/correction i legacy auto-completed tretman.
6. IRiU keep/remove/archive/merge pravila.
7. Merljivi Windows startup i Android PARTE targeti.

### Pre relevantnih functional/product taskova

8. RAČUN toggle migration default.
9. NALOG CVEĆARI business content i PDF/DOCX scope.
10. OPC Srbija app identity/versioning/update kanal.
11. Multilingual architecture/release identity.
12. Currency-rate model.
13. Publisher i signing-key custody/transfer model.

## 7. Validation

Dokumentacioni closure zahteva:

- `git diff --cached --check`: PASS;
- `git diff --check`: PASS;
- strict UTF-8 bez BOM-a: PASS;
- replacement characters: 0;
- privacy/sensitive-data scan: PASS;
- apsolutne privatne lokalne putanje: 0;
- korisnička imena, tajne, tokeni i ključevi: 0;
- Markdown struktura: PASS;
- repo-relativne reference: PASS;
- scope: samo dva nova dokumenta;
- originalni/authoritative dokumenti: neizmenjeni.

## 8. Closure

Revised plan ostaje:

`DRAFT – FINAL OWNER REVIEW REQUIRED`

CODEX → GIT completion zahteva commit, push, identičan local/origin HEAD, divergenciju `0/0`, čist worktree i javno dostupan plan/report.

Finalni ciklus status:

`OPC AUTHORITATIVE DEPENDENCY-BASED DEVELOPMENT PLAN REVISED FOR FINAL OWNER REVIEW – NOT YET AUTHORITATIVE`
