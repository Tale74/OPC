# Portable PREDMET Business Responsibility — Current Acceptance Matrix

| Area | Current result | Evidence boundary |
|---|---|---|
| PREDMET portable responsibility | PASS | Nullable name+role snapshot is PREDMET truth |
| Local `Korisnici.id` portability | FORBIDDEN / PASS | Numeric source IDs are ignored on destination |
| New import actor separation | PASS | Importer is local creator/modifier, not automatic SAVETNIK |
| Local binding | PASS | Requires both name and role plus exactly one destination match |
| Missing/ambiguous match | PASS | Portable snapshot retained; `savetnikId` remains null |
| Schema-27→28 migration | PASS | Adds nullable columns without historical inference/backfill |
| Legacy JSON 6/7 | PASS | Missing responsibility remains unknown |
| Replacement | PASS | Incoming snapshot wins when present; creator retained; local modifier logged |
| PREDMET/detail UI, LISTA PDF, PREDMET PDF and relevant STATISTIKA | PASS | Business-facing surfaces remained consistent with PREDMET responsibility truth; there is no separate business derivative named `LISTA` |
| Full backup schema 9 | UNCHANGED / PASS | User/PREDMET/log family remains a distinct contract |
| Focused/analyzer/full QA | PASS | 48 focused; analyzer clean; 455 passed/10 skipped full suite |
| Windows/Android release builds | PASS | Artifacts built after green analyzer/full-suite gates |
| Android → Windows physical acceptance | PASS | Missing destination local binding preserved the portable `SYNTHETIC_ADMIN / SAVETNIK` snapshot; importer remained distinct |
| Windows → Android physical acceptance | PASS | Unique exact name+role match bound `SAŠA ANDONOV / ADMINISTRATOR`; importer remained distinct |
| Physical transfer/runtime acceptance | PASS | `PHYSICAL SAME-FIRMA WINDOWS ↔ ANDROID PEER RESPONSIBILITY TRANSFER ACCEPTANCE — PASS` |

## Authority boundaries

- `DATABASE OWNERSHIP — NOT EXPLICITLY MODELED`
- `FIRMA BUSINESS-NAMESPACE HYPOTHESIS — PARTIALLY SUPPORTED`

These classifications are not changed by the bounded transfer acceptance. The
PASS proves responsibility preservation for the accepted same-FIRMA peer
scenarios; it does not establish general database ownership, global identity,
all import/export behavior, full-backup acceptance or overall release readiness.
