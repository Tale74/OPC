# OPC task report — Gate 0 PREDMET version import fact-check

**Status:** SOURCE FACT CONFIRMED — OWNER QUEUE CORRECTED — NO IMPLEMENTATION
**Datum:** 26. jul 2026.

## 1. Git baseline

- Base branch: `task/OPC-GATE-0-SEMANTIC-OWNER-DECISIONS-01`
- Base SHA: `7933e8dd3ae90d268e7c15d55342d1cfd153c28f`
- Task branch: `task/OPC-GATE-0-PREDMET-VERSION-IMPORT-FACT-CHECK`
- Final SHA: Git object ID commita koji sadrži ovaj report; navodi se u completion odgovoru.

## 2. Review scope

- single-PREDMET JSON official export;
- import normalization i typed deserialization;
- DB/model `verzija` contract;
- transaction boundary;
- full-backup integer validation;
- JSON regression test coverage;
- relevant current authority dokumenti.

## 3. Nalaz

- official OPC export uvek zapisuje typed integer `verzija`;
- missing/null/wrong-type vrednost pada pre DB transakcije;
- takav PREDMET nije uspešno importovan;
- owner business pitanje za missing/malformed import uklonjeno je iz queue-a;
- eksplicitni `verzija >= 1` guard nije pronađen;
- `0`/negative integer predstavlja tehnički validation/test gap;
- same/higher/lower valid-version conflict semantika ostaje odvojena tema;
- `keep / replace / cancel` ostaje važeća owner odluka.

## 4. Dokumentaciona korekcija

Kreirano:

- `docs/OPC_PREDMET_VERSION_IMPORT_FACT_CHECK.md`
- `docs/tasks/OPC_TASK_GATE_0_PREDMET_VERSION_IMPORT_FACT_CHECK_REPORT.md`

Ažurirano:

- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md`
- `docs/OPC_DOCUMENTATION_SEMANTIC_OWNER_DECISION_QUEUE.md`
- `docs/OPC_DOCUMENTATION_THEMATIC_SEMANTIC_CONSOLIDATION.md`
- `docs/OPC_DOCUMENTATION_SEMANTIC_CONSOLIDATION_EVIDENCE_REGISTER.md`

## 5. Semantic kontrolni zbir

- `OWNER_DECISION_REQUIRED`: 261;
- `TECHNICAL_AUDIT_GOVERNED`: 7;
- ostale dispozicije: nepromenjene;
- ukupan zbir: 704.

## 6. Scope potvrde

- application/test/database/migration/build/runtime izmene: 0;
- brisanje: 0;
- Git history rewrite: nije izvršen;
- source review je read-only;
- implementacija range guarda/testova nije autorizovana ovim taskom.

## 7. Gate

`PREDMET VERSION IMPORT FACT-CHECK PASS — OWNER PREMISE CONFIRMED — TECHNICAL RANGE VALIDATION GAP RECORDED`
