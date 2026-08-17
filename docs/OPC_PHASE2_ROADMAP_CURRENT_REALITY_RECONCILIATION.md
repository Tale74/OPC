# OPC Phase 2 Roadmap / Current-Reality Reconciliation

**Status:** current Phase 2 synchronization evidence; the dependency-based plan remains the operative roadmap.

**Baseline:** `621c70f8d4820042e40a15f3d44187703092db3e` on `task/OPC-SCENARIO-MODULE-LOCK`.

**Governing rule:** factual state is synchronized; business priority, product scope and implementation sequence are not redesigned by this report.

## Effective classification map

| Roadmap area | Current classification | Evidence and reconciliation |
|---|---|---|
| Phase 1 authority/documentation standardization | `COMPLETE` | Published Phase 1 commit and current compact authority homes establish the navigation baseline. |
| PREDMET authority and explicit lifecycle | `COMPLETE` technical baseline / runtime acceptance still scoped | Source, tests and current-state evidence confirm explicit lifecycle; final product parity remains a separate gate. |
| SCENARIO implementation, 1,008 map and module placement | `COMPLETE` / `LOCKED` | Locked source SHA, lock report, 33-file regression contract and Windows/Android owner runtime PASS. |
| SCENARIO JSON carriers | `PARTIALLY COMPLETE` | Carrier contracts and production structures exist; final release-candidate round-trip/rehearsal remains open. |
| IRiU/KATALOG price, ordering and snapshot rules | `COMPLETE` technical / release evidence scoped | Generic package invariant and source/test coverage align; concrete visual/runtime gates remain where documented. |
| Referential integrity and scoped restore | `PARTIALLY COMPLETE` | Hard-delete and scoped restore slices have evidence; remaining RI owner gates and final rehearsal are not silently closed. |
| Windows single-instance protection | `OPEN` / implementation discrepancy candidate | Audit evidence shows no native guard; this Phase 2 task records the gap and does not change source. |
| Windows startup/canonical runtime closure | `PARTIALLY COMPLETE` | Proven cold/reopen and repaired-copy slices remain bounded; protected-install visual/SCENARIO/LISTA proof remains open. |
| Evidence-first performance closure | `OPEN` | Windows exit/startup and Android PARTE/IRiU profiling targets remain unmeasured or owner-target dependent. |
| Completion/signal model | `OPEN` / `BLOCKED BY OWNER DECISION` | Complete derived signal meanings are not settled. |
| PODSETNIK full upgrade | `OPEN` / `BLOCKED BY OWNER DECISION` | Existing notification behavior is represented; complete lifecycle-aware semantics remain owner-open. |
| Single-PREDMET JSON UI relocation | `OPEN` | Action ownership relocation remains a product-completeness item; no code change authorized here. |
| Full backup/restore final rehearsal | `OPEN` / release-gate blocker | Prior scoped PASS is evidence, not current release-candidate closure. |
| NALOG CVEĆARI content and scope | `BLOCKED BY OWNER DECISION` | No standalone generator/business scope is proven. |
| RAČUN availability/default and standard PDF typography | `BLOCKED BY OWNER DECISION` / `TECHNICAL DEBT` | Existing exporter is not treated as absent; scope and visual refinement remain separate. |
| Windows light/dark theme | `COMPLETE` / `SUPERSEDED` pending wording | Explicit owner authority: `WINDOWS LIGHT/DARK THEME — RUNTIME CONFIRMED / CLOSED`. It is removed from active roadmap dependency and reopens only for regression/new owner decision. |
| Broader Windows/Android UI/UX audit | `OPEN` | Separate from the closed light/dark runtime item. |
| MODUL DVE VALUTE | `OPEN` / blocking for stable OPC v.1 | Not implemented; remains a locked product-line predecessor. |
| Final platform business-semantic parity | `OPEN` / blocking for gate | Theme is closed, but lifecycle, JSON, reminders, documents, currency and release evidence still require final matrix acceptance. |
| App identity/version/update channel | `BLOCKED BY OWNER DECISION` | Current technical values are facts, not final owner policy. |
| `OPC_v.1_Int`, Web/sync and international product-line scope | `PRODUCT-LINE FUTURE SCOPE` | Not mixed into current v.1 completion. |
| Signing/professional handover | `POST-GATE` | Remains sequenced after product-line and owner decisions. |

## Superseded chronology and drift

Older draft plans and the historical plan-reality report may still contain theme `PARTIAL`, `OPEN` or “runtime audit” wording. Those records remain historical evidence. The effective current status is carried by:

- `docs/OPC_AUTHORITATIVE_DEPENDENCY_BASED_DEVELOPMENT_PLAN.md`;
- `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`;
- the Phase 2 synchronized internal pseudocode index.

This is classified as `ROADMAP DRIFT` and `DOCUMENTATION DRIFT`, not an implementation discrepancy and not an owner conflict.

## Owner decisions preserved

The following remain open and were not guessed: complete PODSETNIK signal meanings, NALOG CVEĆARI content/scope, RAČUN FIRMA availability/default, measurable performance targets, EUR activation/treatment, app identity/version/update channel, release baseline/signing custody, and future IP/repository-use/distribution decisions.

## Reconciliation result

The roadmap now distinguishes completed/locked behavior, accepted runtime closure, partial technical work, open implementation evidence, owner decision gates, technical debt and future product-line scope. No new priority sequence was invented and no production implementation was performed.
