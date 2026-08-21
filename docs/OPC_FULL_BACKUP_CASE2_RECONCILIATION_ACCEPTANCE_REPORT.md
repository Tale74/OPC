# Full-backup Case-2 Safe Fallback / Reconciliation Acceptance Report

## Status

`FULL-BACKUP CASE-2 SAFE FALLBACK / MERGE-RECONCILIATION ACCEPTANCE COMPLETE — READY FOR LOGOS REVIEW`

The explicit Case-2 successor is complete as a bounded selective fallback. The
normal destructive restore remains fail-closed when an established local state
receives a backup with incomplete FIRMA identity. No generic merge engine,
portable user identity or business-policy inference was added.

## Accepted behavior

The user can review a read-only plan and explicitly import only new,
unambiguous PREDMET families. Same-identity conflicts remain local and are
handled by the existing individual PREDMET conflict dialog. Duplicate or blank
identities are ambiguous and blocked. Imported PREDMET, IRiU, contacts and the
supported unresolved STANJE ROBE consequence subset are rebound to the active
destination-local actor inside one transaction.

FIRMA, KORISNICI, catalog/configuration/templates, PARTE persistent/media
state, reminders, `logIzmena`, SCENARIO global/snapshot/provenance state and
foreign numeric IDs are not imported. Cancel and pre-mutation parse failures
leave the destination unchanged.

## Evidence and QA

- Source-learning: `_serijalizujBackup` and `_uvoziBackupUBazu` establish the
  schema-9 full-backup family and destructive restore boundary.
- Focused Case-2 acceptance: 13/13 PASS in the local-identity/recovery suite.
- `flutter analyze --no-pub`: PASS, no issues found, natural completion in
  35.2 s.
- Full `flutter test --no-pub --concurrency=1`: PASS, 445 tests passed and 10
  expected skips; natural completion in 17:38. No test failure or tooling hang.
- `flutter build windows --release`: PASS, 201.9 s; `OPC.exe` SHA-256
  `CFC5578443C3F38041A169D9A046B393A284967AAC943895A58EF2EAD7E7D255`.
- `flutter build apk --release`: PASS, 867.0 s; `app-release.apk` size
  78,436,271 bytes; SHA-256
  `2F3100F051006138E42DC29156E8C84C69CE6C5F4514C3F5163F12164162D899`.
- The protected SOURCE coverage inventory was read-only and remains `337 × 38`;
  the completeness ledger remains 37 rows.
- No canonical database, runtime/private data, SCENARIO or platform source was
  used as a mutation target.

## Authority and boundaries

PREDMET remains the sole business truth. The owner oracle that a newer/current
PREDMET carries current data is honored without inventing a technical
replacement rule. RR-008 and replacement `logIzmena` remain closed. Case 1 and
Case 3 restore behavior remains unchanged. Automatic anonymization remains
deferred/non-blocking; RI-3/global FK, PODSETNIK trigger semantics, policy /
finance, Web/sync and performance work remain separate.

The persistent current-state registers are reconciled to remove the completed
Case-2 successor and point to the bounded acceptance evidence. No Phase 5,
SCENARIO unlock or unrelated successor began.

## Changed-file and handoff boundary

The exact Git-visible delta is the following 17 paths:

```text
docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md
docs/OPC_CURRENT_DEVELOPMENT_STATE.md
docs/OPC_FIRM_SCOPED_PREDMET_IDENTITY_TECHNICAL_AUDIT.md
docs/OPC_LOCAL_USER_IDENTITY_AND_PREDMET_TRANSFER_REBIND_AUDIT.md
docs/OPC_POST_SCENARIO_FORWARD_ACTION_MAP.md
docs/OPC_POST_SCENARIO_OPEN_CLOSED_ITEM_REGISTER.md
docs/OPC_POST_SCENARIO_ORPHAN_GAP_REGISTER.md
docs/OPC_PREDMET_IDENTITY_VERSION_CHANGELOG_GAP_REGISTER.md
docs/OPC_PREDMET_LOCAL_IDENTITY_RECOVERY_ACCEPTANCE_MATRIX.md
docs/OPC_PREDMET_LOCAL_IDENTITY_RECOVERY_ACCEPTANCE_REPORT.md
docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md
docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_ACCEPTANCE_MATRIX.md
docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_ACCEPTANCE_REPORT.md
docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_DESIGN.md
lib/core/utils/json_export_import.dart
lib/features/predmeti/data/predmeti_repository.dart
test/predmet_local_identity_recovery_acceptance_test.dart
```

The external Layer-3 reusable know-how file was updated at
`C:\Projekti\OPC\OPC v.1\INTERNAL_DEVELOPMENT_CONTROL\KNOW_HOW\REUSABLE_ENGINEERING_KNOW_HOW.md`
(SHA-256 `4F9E4BA7E3873EE99F7407C01AB541FAAF855A89D9688C5BBBAFA063DABBAB76`).
The non-authoritative review package is
`C:\Projekti\OPC\OPC v.1\REVIEW\OPC_FULL_BACKUP_CASE2_RECONCILIATION_LOGOS_REVIEW.zip`.
