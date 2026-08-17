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
| Replacement on local ID | Stale reminder/PARTE state remains on replacement | 5 lifecycle/referential tests | INCONCLUSIVE semantic acceptance |
| Full restore | Stale reminder state is cleared before local-ID reuse; tested orphans are zero | 8 backup/restore tests + 5 lifecycle/referential tests | CONTRACT CONFIRMED for tested flow |
| Android parity | Shared Dart contracts are covered; physical Android runtime not exercised in this wave | Test source only | INCONCLUSIVE |

PREDMET remains the owner of authoritative lifecycle/business facts. PODSETNIK/reminder and PARTE state are treated as derived/related state; their retention or reset semantics require a bounded acceptance successor where current evidence does not establish business meaning.

