# RR-008 Same-Identity Replacement Acceptance Matrix

| ID | Contract | Evidence | Result |
|---|---|---|---|
| R1 | New same-identity PREDMET becomes current while local technical ID is preserved | Focused replacement integration test | PASS |
| R2 | Existing IRiU/contact/provenance/snapshot/lifecycle replacement seam remains intact | Focused test plus existing JSON/SCENARIO suite | PASS |
| R3 | Old PARTE preparation cannot remain current after replacement | Focused test: stale `parte_pripreme` row absent | PASS |
| R4 | App-owned PARTE media is recoverably staged and purged only after commit | `ParteMediaStore` staging seam and production wiring; no external media mutation | PASS |
| R5 | Old reminder IDs are cancelled and no stale IDs remain stored | Focused test with recording notification gateway | PASS |
| R6 | Existing reminder configuration is preserved where appropriate; stale scheduled state based on superseded PREDMET truth is invalidated and no implicit configuration is created | Focused replacement test with recording notification gateway and direct persistence assertions | PASS |
| R7 | Transfer format and protected surfaces remain unchanged | Full JSON/backup/SCENARIO suite, analyzer and Windows release build | PASS |
| R8 | A post-commit reminder initialization failure cannot make committed replacement appear rolled back or leave stale persisted IDs/media | Focused failure-injection test; warning returned, replacement truth present, scheduled IDs empty, media/trash clean | PASS |
| R9 | A later post-commit scheduling failure cancels attempted notifications and leaves the persisted scheduled-ID inventory empty | Focused partial-scheduling failure-injection test with tracking gateway; attempted IDs cancelled and no misleading import failure | PASS |

Owner semantics remain limited to the accepted invariant. RR-008 does not define
PODSETNIK triggers, automatic scheduling, recreation policy or future reminder
semantics. No owner was asked to choose a technical mechanism, and no automatic
anonymization behavior was changed.
