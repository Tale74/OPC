# OPC Recovered As-Built Architecture

**Status:** `TECHNICAL AS-BUILT — NOT BUSINESS AUTHORITY`

The recovered build is a Flutter/Dart local-first application with Drift/SQLite persistence and Windows/Android native runners. The following is source-learning, not a target architecture or implementation authorization.

## Bounded reminder flow

`PREDMET` data and current status are read by the reminder coordinator. Reminder configuration stores `enabled` and normalized `deliveryTimes`; scheduled primary IDs and secondary IDs are persisted separately in `ceremony_reminder_settings`. The coordinator cancels stored IDs before rescheduling and fail-closes for statuses outside `OTVOREN`/`ZATVOREN`.

The URNA/PEPEO model derives relevance from `KREMACIJA`/`KREMACIJA_EKSPRES` plus a non-empty placement other than `NAKNADNO`. It computes a calendar `+3` activation date, one occurrence per configured time, deterministic local IDs and daily-repeat metadata. Completion suppresses new secondary occurrences.

The recovered Windows UI path evaluates the active secondary slot during startup/resume and can add the semantic reminder text to the existing in-app dialog. Android scheduling uses the notification gateway. This is an as-built source claim; it is not independent Windows runtime acceptance.

## Completion flow

`PredmetiRepository.zavrsiPredmet()` reads the current PREDMET, requires `ZATVOREN`, rejects immutable `ANONIMIZOVAN`, checks active PARTE preparation, then queries `PodsetnikObligationRepository.hasUnfinishedUrnaPepeoBlocker()`. An unfinished current future-blocker throws `UrnaPepeoCompletionBlockException`; otherwise the status is written as `ZAVRŠEN`, and stored PODSETNIK delivery is deactivated after the transaction.

## Persistence boundary

The current source reads/writes `secondary_scheduled_notification_ids` and uses schema 31. The canonical database is external private runtime data and is not changed by this documentation task.

## Evidence pointers

- `lib/features/predmeti/reminders/ceremony_reminder_model.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_coordinator.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`
- `lib/features/predmeti/reminders/ceremony_reminder_text.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/podsetnik/domain/podsetnik_obligation.dart`
- `lib/features/podsetnik/data/podsetnik_obligation_repository.dart`

All paths above are technical evidence only and must be read against the authority manifest.

## Whole-system component map

| Flow | Read/derive | Technical boundary | Persist/output |
|---|---|---|---|
| Startup/auth | local DB/user/session state | `lib/app.dart`, auth/setup features | route to first launch, login or list |
| PREDMET | case fields/lifecycle/responsibility | `predmeti_repository.dart`, PREDMET presentation | Drift PREDMET and dependent rows |
| SCENARIO/OSNOVNI | definitions, package selection, applied snapshot | `core_v2/scenario/**`, scenario kernel | scenario definitions and PREDMET snapshot/provenance |
| IRiU/KATALOG | selected rows, catalogue snapshots, ordering | IRiU truth/ordering services and repositories | PREDMET-scoped rows and derived totals |
| PODSETNIK | obligation rules, settings, completion state | obligation repository and reminder coordinator | settings, scheduled IDs, in-app/notification delivery |
| ZAVRŠEN | lifecycle prerequisites and future blocker | `PredmetiRepository.zavrsiPredmet()` | lifecycle state and PODSETNIK deactivation |
| Documents/PDF | PREDMET, IRiU, firm and catalogue data | `lib/features/predmeti/pdf/**`, parte paths | rendered PDF/document output |
| STANJE ROBE | selected goods and consequences | `lib/features/stanje_robe/**` and database paths | inventory/consequence rows |
| Transfer | case JSON, local actor rebinding, lifecycle decisions | `core/json_transfer/**`, `json_export_import.dart` | imported PREDMET; no server sync |
| Backup/restore | full local payload and compatibility schema | `full_backup_restore_coordinator.dart` | restored local data under explicit boundary |

## Dependency and platform boundary

The Flutter/Dart application shell depends on Drift/SQLite and package/native
adapters. Windows and Android share business/domain paths while their runners,
window lifecycle and delivery gateways differ technically. Generated build
directories, private runtime DBs and platform caches are not current
documentation authority. A `NALOG CVEĆARI` source implementation was not
established in the bounded inventory; its owner contract must not be reported
as as-built behavior.

This map is a technical as-built description. `OPC_LOGICAL_SYSTEM_MAP.md`
provides the subordinate rule-to-side-effect logical map; neither replaces
direct OWNER authority.

## Current-state synchronization addendum — 2026-09-04

The recovered implementation and the OWNER-supplied GUI-exported artifact
establish the bounded prior as-built NALOG CVEĆARI path. That earlier artifact
is historical/superseded for the latest candidate. The current corrected path
uses the neutral sage/ivory-green section-label palette, has no three-dot
markers and no botanical ornament, preserves the ceremony heading and shared
memorandum/header/footer treatment, and emits row ribbon values without the
storage-field label. The accepted final GUI artifact is the later two-page
export `C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`
with SHA-256
`6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`.

The preceding statement that a bounded NALOG CVEĆARI source implementation
was not established is historical inventory wording and is superseded for
this bounded current-state record by the recovered implementation plus GUI
evidence. `P2-VIS-003` remains viewer-state-only; `P2-VIS-004/005` are
implemented with renderer evidence and `P2-VIS-006` is corrected with
renderer evidence. Final OWNER GUI visual acceptance is closed for the NALOG
CVEĆARI scope; broader Phase 2 remains pending separate OWNER review.

Latest as-built refinement: the current Cvećari section-label path returns the
pastel label container with no decoration; the image frame owns a continuous
border outside a 2pt inset and centered `BoxFit.contain` image; and ribbon
presentation emits the row value without
the storage-field label. `P2-VIS-006` tuple structure is unchanged. See
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md` for exact source,
render and verification evidence.

## Final NALOG CVEĆARI evidence closure — 2026-09-05

The accepted final GUI artifact is the later two-page export
`C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`
with SHA-256
`6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`.
The page-count change is explained by added CVEĆE items in the same PREDMET;
the earlier one-page export remains historical. This is as-built/evidence
state only and does not accept the broader Phase 2.
