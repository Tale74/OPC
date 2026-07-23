# OPC — authoritative development plan owner-review preparation report

**Status:** DOCUMENTATION-ONLY REVIEW PREPARATION
**Plan status:** DRAFT – OWNER REVIEW REQUIRED
**Autoritativnost:** Nijedan od objavljenih review dokumenata još nije owner-odobren niti je deo autoritativnog OPC dokumentacionog skupa.
**Datum:** 23. jul 2026.

## 1. Git baseline i grana

- Base branch: `task/OPC-PARTE-MODULE-SHORTCUT-PREDMET-PARTE-SEGMENT`
- Base SHA: `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`
- Review branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-OWNER-REVIEW`
- Final branch commit SHA: branch-tip SHA se objavljuje u završnom delivery odgovoru i javnom GitHub commit linku. Commit ne može sadržati sopstveni SHA bez promene tog SHA; zato se ovde ne navodi samoreferentna netačna vrednost.

Pre kreiranja review grane potvrđeno je:

- očekivana base grana;
- očekivani base SHA;
- lokalni HEAD i origin bili su identični;
- divergencija je bila `0/0`;
- worktree je bio čist.

## 2. Dodati dokumenti

- `docs/OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT.md`
- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_DRAFT.md`
- `docs/OPC_AUTHORITATIVE_DEVELOPMENT_PLAN_OWNER_REVIEW_PREPARATION_REPORT.md`

Postojeći OPC dokumenti nisu menjani. Novi dokumenti nisu dodati u manifest autoritativnih dokumenata niti u lokalni autoritativni dokumentacioni izvor.

## 3. Audit dokument — kontrolisana sanitizacija

Originalni deliverable:

- logički naziv: `OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT_2026-07-23.md`
- SHA-256: `66E27A8199643B827BFB1EBEC00B4A7B0464F678A4BD1749365751862D22686F`

Sanitizovana Git review kopija:

- putanja: `docs/OPC_DOCUMENTATION_ARCHITECTURE_AND_DEVELOPMENT_PLAN_AUDIT.md`
- SHA-256: `28CD42766FC86A741731B647445448D25C580A1D84C7D073822341D60DCB77D1`

Hash-evi se očekivano razlikuju isključivo zbog owner-odobrene kontrolisane transformacije:

1. dodato je standardno `DRAFT – OWNER REVIEW REQUIRED` zaglavlje;
2. apsolutne putanje unutar Git repozitorijuma zamenjene su repo-relativnim putanjama;
3. koren Git repozitorijuma zamenjen je oznakom `[GIT REPOSITORY ROOT]`;
4. eksterni lokalni projektno-dokumentacioni izvor zamenjen je oznakom `[LOCAL PROJECT_DOCS SOURCE]`;
5. eksterni lokalni restore/audit izvor zamenjen je oznakom `[LOCAL OPC RESTORE-POINT SOURCE]`;
6. separator repo-relativnih putanja normalizovan je na `/`;
7. završni razmaci redova tehnički su normalizovani radi obaveznog `git diff --check` PASS-a, bez promene teksta ili nalaza.

Transformisano je 38 redova originalnog audit dokumenta:

`27, 42, 60, 62, 63, 66, 75, 77, 79, 81, 91, 92, 98, 120, 136, 137, 321, 322, 326, 327, 346, 397–413`.

Audit nalazi, source evidence, zaključci, preporuke, dependency redosled, refactor/rewrite procena, owner decision queue, stop uslovi i acceptance kapije nisu sadržinski promenjeni.

## 4. Plan dokument — kontrolisano zaglavlje

Originalni deliverable:

- logički naziv: `OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_DRAFT_2026-07-23.md`
- SHA-256 originala i Git kopije pre zaglavlja: `44F623A0B426C9D12287F361BCC4EE045CA4710439099CED3AC8B1A884DF8627`

Git review kopija posle standardnog zaglavlja:

- putanja: `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_DRAFT.md`
- SHA-256: `96C3E868AEBB2734CF5CD64392FB34B90B244F0F3D8612733CE5EA8E42961CFC`

Kontrolisana razlika sastoji se od standardnog review zaglavlja i nesadržinske normalizacije završnih razmaka radi `git diff --check` PASS-a. Telo plana od prvog numerisanog odeljka nadalje nije sadržinski menjano.

## 5. Scope potvrda

U ovom koraku nisu menjani:

- aplikacioni source kod;
- testovi;
- baza ili migracije;
- build konfiguracija;
- runtime ponašanje;
- postojeća OPC dokumentacija;
- manifest autoritativnih dokumenata;
- lokalni autoritativni dokumentacioni izvor.

Plan ostaje `DRAFT – OWNER REVIEW REQUIRED`.

## 6. Dokumentacione kontrole

Pre commita i push-a obavezno se potvrđuju:

- `git diff --check`: PASS;
- UTF-8 bez BOM-a i bez replacement znakova: PASS;
- privacy/sensitive-data diff scan: PASS;
- nema preostalih apsolutnih Windows putanja: PASS;
- nema korisničkih imena, tajni, ključeva ili ličnih podataka: PASS;
- Markdown struktura i repo-relativne putanje: PASS;
- scope diff sadrži samo tri nova dokumenta: PASS.

## 7. Closure status

`AUTHORITATIVE DEVELOPMENT PLAN DOCUMENTS PUBLISHED AS SANITIZED DRAFTS FOR OWNER REVIEW – NOT YET APPROVED OR AUTHORITATIVE`
