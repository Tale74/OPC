# OPC Logical System Map — Current As-Built Candidate

**Status:** `SUBORDINATE TECHNICAL LOGICAL MAP — NOT BUSINESS AUTHORITY`

This map connects owner-authorized rules to current PREDMET data, derivation,
technical path, persistence, UI and side effects. The arrows describe
implementation causality; they do not create business policy.

| Rule / contract | PREDMET/current data | Derivation | Repository/service | Persistence | UI | Side effect/output |
|---|---|---|---|---|---|---|
| Startup routes by local state | users, session, DB emptiness | first-launch/login/list decision | `lib/app.dart` | local DB/session | FirstLaunch, Login, ListaPredmeta | route/window state |
| PREDMET is case truth | case fields, lifecycle, responsibility | read/write case aggregate and dependencies | `lib/features/predmeti/data/predmeti_repository.dart` | Drift PREDMET/dependent tables | list/detail/segments | lifecycle/log updates |
| SCENARIO snapshot | definitions + applied PREDMET snapshot | protected package application/non-retroactivity | `lib/features/predmeti/core_v2/scenario/**` | scenario definitions/snapshots | scenario module/cards | derived IRiU rows |
| IRiU ordering | selected rows and package provenance | OSNOVNI → scenario → manual order | `iriu_ordering_service.dart`, `predmet_iriu_truth_service.dart` | IRiU rows/snapshots | IRiU segments/PDF data | totals/derived documents |
| URNA/PEPEO applicability | ceremony type + placement type | KREMACIJA/KREMACIJA_EKSPRES and not NAKNADNO | `podsetnik_obligation.dart` | obligation state/fingerprint | PODSETNIK surface | active obligation |
| URNA +3 activation | ceremony date + `deliveryTimes` | threshold and daily occurrences | `ceremony_reminder_model.dart` | reminder settings/IDs | Windows in-app slot | Android gateway occurrences |
| Notification enable/disable | enabled + stored IDs | cancel/reconcile/reschedule | `ceremony_reminder_coordinator.dart` | primary/secondary ID columns | PODSETNIK settings | platform delivery/cancellation |
| ZAVRŠEN blocker | current relevant unfinished obligation | future blocker check before finish | `PredmetiRepository.zavrsiPredmet()` | lifecycle status + obligation completion | finish flow/error | allow/block ZAVRŠEN |
| Exact wording | cemetery, placement mode, semantic branch | fallback/labels/body builder | `ceremony_reminder_text.dart` | no business mutation | PODSETNIK/dialog | notification body/title |
| OPREMA document action | PREDMET + OPREMA/IRiU | PDF data derivation | `nalog_za_opremanje_pdf_*` | none beyond case state | action/export UI | PDF; does not complete |
| CVEĆE owner contract | PREDMET + CVEĆE/IRiU | contract-defined PDF derivation | implementation not established in bounded inventory | not established | not established | owner contract only |
| STANJE ROBE | selected rows/consequences | inventory effect lifecycle | `lib/features/stanje_robe/**` | stock/consequence tables | stock screens | operational inventory effect |
| Backup/transfer | case or full local scope | serialize/restore compatibility | `json_export_import.dart`, `core/json_transfer/**`, `full_backup_restore_coordinator.dart` | imported/restored local DB | import/restore UI | portable representation |

## Logical controls

- Current obligations are reconciled against PREDMET state and stable source
  fingerprints; stale persisted obligations are not business authority.
- Cancellation before rescheduling and deterministic IDs protect against
  duplicate cycles; this is a technical safety control.
- The semantic text builder is shared by the in-app and notification paths so
  the visible wording is not reconstructed from raw stable keys.
- Document generation, reminder delivery and inventory effects remain
  derivatives; none completes a PREDMET obligation by observation alone.

## Evidence boundary

Source paths are listed in `OPC_SOURCE_TRACEABILITY.md`. Business authority is
listed in `OPC_OWNER_AUTHORITY_TRACEABILITY.md`. Automated QA/runtime evidence
is listed in `OPC_CURRENT_IMPLEMENTATION_STATE.md` and the external review
package.
