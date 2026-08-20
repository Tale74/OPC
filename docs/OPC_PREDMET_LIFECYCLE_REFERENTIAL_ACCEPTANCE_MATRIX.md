# PREDMET Lifecycle / Referential Acceptance Matrix

| Area | Characterized behavior | Evidence | Decision |
|---|---|---|---|
| Initial/open state | New records are `OTVOREN`; open records remain editable | 5 completion tests | CONTRACT CONFIRMED |
| Close transition | Explicit action moves `OTVOREN` to `ZATVOREN` | 5 completion tests | CONTRACT CONFIRMED |
| Complete transition | Only explicit action moves `ZATVOREN` to immutable `ZAVRŠEN`; invalid direct/automatic paths rejected | 5 completion tests | CONTRACT CONFIRMED |
| Final immutability | `ZAVRŠEN` cannot be edited or reopened through characterized repository paths | 5 completion tests | CONTRACT CONFIRMED |
| Hard delete | Child rows are coordinated and no residual references remain in the tested synthetic graph | 5 lifecycle/referential + 4 coordinator tests | CONTRACT CONFIRMED for tested flow |
| Anonymization | Business row is anonymized while derivative PII retention behavior is observable | 5 lifecycle/referential tests | CONTRACT CONFIRMED as current behavior; acceptance semantics remain owner-gated where required |
| SQLite FK enforcement | `PRAGMA foreign_keys` is `0`; explicit repository/coordinator cleanup is relied upon | 5 lifecycle/referential tests | RISK BOUNDARY — preserve explicit coordination and add release acceptance |
| Replacement on local ID | Current PREDMET truth replaces the local business row; app-owned PARTE media is staged/purged, stale PARTE state is removed, old reminder IDs are cancelled, existing reminder configuration is preserved where appropriate, and no stale scheduled state remains current. Post-commit auxiliary failure leaves committed truth explicit, attempted notifications cancelled, persisted IDs empty and media cleanup warning-visible | Focused replacement plus failure-injection tests; analyzer PASS; full suite PASS; Windows release build PASS | CONTRACT CONFIRMED for implemented seam; PODSETNIK trigger/scheduling semantics remain separately defined |
| Full restore | Stale reminder state is cleared before local-ID reuse; tested orphans are zero | 8 backup/restore tests + 5 lifecycle/referential tests | CONTRACT CONFIRMED for tested flow |
| Android parity | Shared Dart contracts are covered; physical Android runtime not exercised in this wave | Test source only | INCONCLUSIVE |

PREDMET remains the owner of authoritative lifecycle/business facts. PODSETNIK/reminder and PARTE state are treated as derived/related state and are reconciled so no state based on superseded PREDMET truth remains current. Reminder signal taxonomy and broader product semantics remain separately owner-gated.
