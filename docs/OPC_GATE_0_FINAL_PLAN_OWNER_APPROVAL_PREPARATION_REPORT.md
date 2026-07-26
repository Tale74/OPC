# OPC — Gate 0 final plan owner-approval preparation report

**Status:** DOCUMENTATION-ONLY FINAL CANDIDATE PREPARED – OWNER APPROVAL REQUIRED
**Datum:** 26. jul 2026.
**ARC–T.A.R.S.:** Definiši, ugradi, potvrdi, zapamti.

## 1. Git baseline i task

- Base branch: `task/OPC-AUTHORITATIVE-DEVELOPMENT-PLAN-REVISION`
- Base SHA: `eab28232dd1a791ecd0c24ee33b7f93a34f13797`
- Task branch: `task/OPC-GATE-0-FINAL-PLAN-OWNER-APPROVAL`
- Final branch SHA: Git object ID commita koji sadrži ovaj report; autoritativno se čita sa task branch HEAD-a i navodi u completion odgovoru. SHA ne može biti samoreferentno ugrađen u sadržaj istog Git objekta.
- Baseline pre izmene: lokalni HEAD i origin identični, divergence `0/0`, worktree čist.

## 2. Dokumentacioni izlazi

Kreiran je:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN_FINAL_CANDIDATE.md`

Ovaj report je:

- `docs/OPC_GATE_0_FINAL_PLAN_OWNER_APPROVAL_PREPARATION_REPORT.md`

Istorijski audit, originalni draft, owner-review findings i revised draft nisu menjani niti uklanjani.

## 3. Ugrađene odluke

Finalni kandidat ugrađuje:

- Decision Authority Matrix: Codex tehničke/arhitektonske odluke i owner poslovne odluke;
- kompletan code/architecture review kao prvi izvršni ciklus posle Gate 0;
- PREDMET source-to-truth i dependency mapu kao obaveznu zaštitu core-a;
- Android PARTE „seckanje” kao owner runtime simptom/hipotezu unutar full review-a, ne unapred potvrđen root cause;
- tehnički Git governance model sa sačuvanim stacked lineage-om, budućim `develop/opc-v1` i `main` kao stabilnim/release baseline-om;
- razdvajanje aktuelne OPC v.1 Srbija product line i budućeg OPC_v.1_Int;
- odlaganje fizičkog međunarodnog source fork-a do Second Product-Line Gate-a;
- jedan MODUL DVE VALUTE sa režimima `RSD primarna / EUR informativna` i `EUR primarna / RSD informativna`;
- runtime EUR aktivaciju bez novog coding/build ciklusa;
- zaštićeni RSD fallback;
- PREDMET-owned valutu/kurs i istorijsku stabilnost derivata;
- ažuriran owner decision queue i dependency red.

## 4. Scope zaštita

- Aplikacioni source nije menjan.
- Testovi nisu menjani.
- Baza, schema i migracije nisu menjani.
- Build/release konfiguracija nije menjana.
- Runtime ponašanje nije menjano.
- Postojeća Git dokumentacija nije menjana.
- Lokalni autoritativni dokumentacioni folder nije menjan niti sinhronizovan pre owner odobrenja.
- Dokument još nije proglašen autoritativnim.
- Nijedan implementation task nije pokrenut.

## 5. Dokumentacione kontrole

Obavezne kontrole za ovaj task:

- `git diff --check`;
- stroga .NET UTF-8 validacija bez BOM-a;
- privacy/sensitive-data diff scan;
- provera da nema privatnih apsolutnih putanja, korisničkih imena, tajni, ključeva, tokena ili ličnih podataka;
- provera postojećih relativnih `docs/` referenci;
- potvrda da diff obuhvata samo dva nova Markdown dokumenta;
- potvrda da su task branch i origin usklađeni nakon push-a;
- potvrda da je worktree čist nakon commita.

Finalni PASS rezultati i final branch SHA potvrđuju se Git stanjem i completion odgovorom nakon push-a.

## 6. Owner gate

Plan ostaje:

`FINAL CANDIDATE – OWNER APPROVAL REQUIRED`

Owner mora eksplicitno odobriti sadržaj, Decision Authority Matrix i dependency red. Tek sledeći dokumentacioni closure task sme:

- proglasiti plan autoritativnim;
- formirati/aktivirati `develop/opc-v1`;
- ažurirati manifest i source-of-truth dokumente;
- semantički uskladiti odobreni plan sa lokalnim dokumentacionim izvorom;
- autorizovati prvi read-only full code/architecture review.

## 7. Completion status

`GATE 0 FINAL PLAN CANDIDATE PREPARED FOR OWNER APPROVAL – NOT YET AUTHORITATIVE – NO APPLICATION IMPLEMENTATION STARTED`
