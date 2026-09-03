# OPC Source Traceability — Current As-Built Candidate

**Status:** `READ-ONLY TECHNICAL TRACEABILITY — NOT BUSINESS AUTHORITY`

| Technical claim | Recovery source evidence |
|---|---|
| Startup routing | `lib/main.dart`; `lib/app.dart` (`_StartRouter`) |
| Schema/database boundary | `lib/core/database/database.dart`; `lib/core/database/schema_recovery.dart`; `lib/core/database/migrations/**` |
| Auth and local identity | `lib/features/auth/**`; `lib/features/setup/**`; `lib/app.dart` |
| PREDMET lifecycle and finish hook | `lib/features/predmeti/data/predmeti_repository.dart` (`zavrsiPredmet`) |
| Responsibility transfer/rebinding | `predmeti_repository.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart` |
| IRiU truth/order | `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`; `predmet_iriu_truth_service.dart`; `lib/features/predmeti/data/iriu_repository.dart` |
| SCENARIO definitions/snapshots | `lib/features/predmeti/core_v2/scenario/**`; `owner_scenario_policy_kernel.dart` |
| Obligation applicability/completion | `lib/features/podsetnik/domain/podsetnik_obligation.dart`; `lib/features/podsetnik/data/podsetnik_obligation_repository.dart` |
| Reminder dates/slots/IDs | `lib/features/predmeti/reminders/ceremony_reminder_model.dart`; `ceremony_reminder_coordinator.dart` |
| Reminder settings/ID persistence | `lib/features/predmeti/reminders/ceremony_reminder_repository.dart`; `lib/core/database/database.dart` |
| Exact semantic wording | `lib/features/predmeti/reminders/ceremony_reminder_text.dart` |
| Windows in-app path | `lib/features/predmeti/presentation/lista_predmeta_screen.dart` |
| Android delivery gateway | `lib/features/predmeti/reminders/ceremony_notification_gateway.dart` |
| PREDMET segments/ceremony fields | `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`; `lib/features/predmeti/presentation/**` |
| PDF/document outputs | `lib/features/predmeti/pdf/**`; `lib/features/parte/**` |
| Backup/restore and transfer | `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/**`; `lib/features/predmeti/application/full_backup_restore_coordinator.dart` |
| STANJE ROBE | `lib/features/stanje_robe/**` and related repositories/database paths |

No source path in this index is business authority. Absence of a bounded source
file is recorded as `NOT ESTABLISHED`; it is not converted into an inference
that the feature is absent or accepted.
