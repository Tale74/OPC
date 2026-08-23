# Portable PREDMET Responsibility — V1 Pilot QA / Runtime Evidence

Focused responsibility + migration command: PASS — 48 tests, 0 failures.

`flutter analyze --no-pub`: PASS — no issues found.

`flutter test --no-pub --concurrency=1`: PASS — 455 passed, 10 skipped,
0 failures. Execution was strictly serialized and completed naturally.

Windows release build: PASS.

Android release build: PASS.

The implementation/QA phase above launched no application and performed no
runtime/device transfer. Subsequent bounded physical acceptance used disposable
test data and normal product transfer paths; it did not mutate a canonical or
private database and did not change source, tests, schema or runtime behavior.

## Physical runtime acceptance

Final status:

`PHYSICAL SAME-FIRMA WINDOWS ↔ ANDROID PEER RESPONSIBILITY TRANSFER ACCEPTANCE — PASS`

- Android → Windows: PASS. A missing local name+role binding retained the
  portable `SYNTHETIC_ADMIN / SAVETNIK` responsibility snapshot. Destination
  importer `SAŠA ANDONOV / ADMINISTRATOR` remained the local creator/modifier
  and did not become responsible SAVETNIK.
- Windows → Android: PASS. The exact unique
  `SAŠA ANDONOV / ADMINISTRATOR` destination match bound the local adviser.
  Importer `SYNTHETIC_ADMIN / ADMINISTRATOR` remained the distinct local
  creator/modifier. The owner's clarification that SAVETNIK cannot import was
  accepted as role policy, not classified as a defect.
- PREDMET/detail UI, LISTA PDF, PREDMET PDF and relevant STATISTIKA remained
  consistent with portable PREDMET responsibility in both directions. `LISTA`
  is not a separate business derivative.

Forward acceptance package SHA-256:
`90737297884BA9E8AF2F19F7CA8254F4FC390A12335074666562C71D2C6A2214`.

Reverse acceptance package SHA-256:
`554F38ADE79E20730BA91C74D307B65B69F67968FB80978086A3A8039314F290`.

## Preserved boundaries

Schema 28 remains an additive portable-responsibility migration without
historical responsibility backfill. Local numeric `Korisnici.id` values remain
non-portable. Full-backup schema remains 9 and legacy individual JSON remains
readable with unknown responsibility when the new fields are absent. No
SCENARIO source/test contract changed.

- `DATABASE OWNERSHIP — NOT EXPLICITLY MODELED`
- `FIRMA BUSINESS-NAMESPACE HYPOTHESIS — PARTIALLY SUPPORTED`

The physical PASS is bounded to same-FIRMA peer responsibility transfer and
does not claim general platform, backup/restore or release readiness.
