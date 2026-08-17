# OPC Phase 4 Characterization Gap Register

Characterization status is assessed before any later recode, partial rewrite or reconstruction. No implementation is authorized by this register.

| Candidate | Intervention | Characterization state | Existing protection | Missing evidence before implementation |
|---|---|---|---|---|
| `json_export_import.dart` transfer/backup monolith | PARTIAL REWRITE / SPLIT | **CHARACTERIZATION PARTIAL** | JSON regression, full-backup lifecycle, scenario carrier, PARTE JSON, stock boundary and auth/recovery tests | Complete format/version fixture inventory; section-by-section round-trip golden set; failure/rollback matrix; platform file/share behavior; caller migration proof |
| `database.dart` schema/seed/repair/recovery concentration | PARTIAL REWRITE / SPLIT | **CHARACTERIZATION PARTIAL** | v19–v26 recovery states, package downgrade, owner-copy migration, schema recovery and seed tests | Full v1–v27 transition table; malformed-schema matrix; every repair/backfill idempotency proof; restore interruption/reopen evidence; generated schema parity |
| PREDMET repository/application orchestration | REFACTOR / SPLIT | **CHARACTERIZATION PARTIAL** | lifecycle, referential, completion, hard-delete, save/close and scenario application tests | Cross-feature transaction inventory; event/order characterization; UI-to-workflow contract tests; rollback boundaries |
| IRiU/KATALOG selection and ordering | SPLIT / REFACTOR / possible RECODE of selectors | **CHARACTERIZATION SUFFICIENT for ordering; PARTIAL for ownership** | shared derived ordering, manual-row, catalog picker, fixed-price and scenario tests | Complete KATALOG snapshot provenance and catalog mutation matrix; UI selection contract |
| Policy/finance evaluator and statistics | REFACTOR / bounded RECODE | **CHARACTERIZATION PARTIAL** | business-policy/IRiU critical tests and current statistics service | Golden policy input/output matrix, owner-approved finance semantics, presentation calculation inventory |
| PODSETNIK reminder scheduling/delivery | REFACTOR / SPLIT | **CHARACTERIZATION PARTIAL** | reminder system/runtime evidence and active UI use | Owner signal taxonomy; clock/time-zone matrix; cancellation/restore/platform parity cases |
| Documents/PDF/DOCX rendering seam | SPLIT / REFACTOR | **CHARACTERIZATION PARTIAL** | PDF identity/fidelity, PARTE print and Android storage contract tests | Per-document artifact golden set; renderer/platform capability matrix; error/reporting contract |
| STANJE ROBE effects and consequences | REFACTOR | **CHARACTERIZATION PARTIAL** | operational toggle, delete/restore and JSON boundary tests | Full effect lifecycle matrix across IRiU/KATALOG/PREDMET changes and restore conflicts |
| Auth/recovery and entitlement payloads | RETAIN / REFACTOR | **CHARACTERIZATION SUFFICIENT for current lanes; PARTIAL for future policy** | auth, recovery, license parser and identity tests | Owner distribution decision and old payload retention policy |

## Gate rule

No HIGH/CRITICAL rewrite candidate may proceed while its status is `PARTIAL` or `INSUFFICIENT` for the missing evidence listed above. A later implementation phase may choose bounded adapters first to improve characterization without a big-bang rewrite.

