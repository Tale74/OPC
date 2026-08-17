# OPC Phase 4 JSON / Interoperability Forensic Report

## Current responsibility concentration

`lib/core/utils/json_export_import.dart` is a 90 KB file with direct imports of `dart:io`, Flutter UI, file picker, path provider, share APIs, Drift database, auth security, PREDMET repositories, SCENARIO transfer contracts, PARTE media/models, reminders, stock consequences and rendering utilities. It contains both testable serialization functions and user-facing workflows.

The file currently performs:

- single-PREDMET serialization/import, conflict selection and version increments;
- legacy `OPC_BELEZNICA` and current transfer normalization;
- full backup section assembly for PREDMET, IRiU, KATALOG, FIRMA/settings, PARTE, reminders, stock, logs and SCENARIO carriers;
- field/type/identity/reference validation;
- direct SQL/Drift mutation and restore ordering;
- restore compensation coordination through `FullBackupRestoreCoordinator`;
- filesystem/file-picker/share operations and SnackBar reporting;
- test-only serialization/import entry points.

`lib/core/json_transfer/predmet_json_transfer_core.dart` is a clearer typed seam with explicit legacy/current format normalization and validation. It is evidence for extraction, not proof that the monolith is fully superseded.

## Current → target seam map

| Current responsibility | Target ownership | Current evidence | Recommendation |
|---|---|---|---|
| Format/version envelope and legacy reader | interoperability domain/codecs | `PredmetJsonTransferDocument`, `OPC_BELEZNICA` adapter | RETAIN / MOVE / REFACTOR |
| Single-PREDMET workflow and conflict policy | `features/interoperability/application` | PREDMET conflict dialogs, repository replacement methods | SPLIT; application workflow |
| Full-backup section orchestration | `features/interoperability/application` | `_serijalizujBackup`, `_uvoziBackupSaLifecycleKoordinacijom` | SPLIT; partial rewrite candidate |
| Schema/field/reference validation | interoperability domain/validation | required field helpers, stock/IRiU reference checks | RETAIN logic behind contract; expand fixtures |
| Database transaction/apply | persistence ports implemented by infrastructure | direct Drift calls and SQL deletes/inserts | Extract port; never let codec own mutation |
| PARTE media staging and restore | PARTE/media port plus workflow coordination | `ParteMediaStore`, backup coordinator | Keep derivative ownership; workflow coordinates |
| Reminder cancellation/rescheduling | PODSETNIK/platform ports plus workflow | reminder settings payload and coordinator | Keep derived state; preserve compensation behavior |
| Filesystem/file picker/share/UI errors | platform and presentation adapters | `dart:io`, file_picker, path_provider, share_plus, SnackBar | Move behind ports; do not change user-visible contract without evidence |
| Auth/security preservation | identity/persistence contract | security fields intentionally excluded/preserved during restore | Preserve installation-local semantics |

## Compatibility obligations

The single-PREDMET format is distinct from full backup. Legacy `OPC_BELEZNICA`, export version fields, SCENARIO schema-1 envelopes, stock consequence restrictions, PARTE JSON, reminder settings and auth/FIRMA fields are all compatibility surfaces. Full restore has rollback/compensation behavior and intentionally preserves installation-local recovery/security material.

## Intervention decision

Do not preserve the 90 KB monolith as a target boundary, but do not mandate a clean-room rewrite. The evidence supports a **partial rewrite/split**: first freeze typed envelopes and validation fixtures, then extract application coordination behind ports, then move codecs/filesystem/persistence adapters. A bounded full reconstruction is permissible only if parity tests show the existing internal roles cannot be separated without reproducing hidden state. Current characterization is `PARTIAL`, so no implementation may begin yet.

