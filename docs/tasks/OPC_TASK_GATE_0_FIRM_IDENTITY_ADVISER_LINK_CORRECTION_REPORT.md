# OPC Task Report — Gate 0 Firm Identity Adviser-Link Correction

Status: `DOCS-ONLY SOURCE-FIRST CORRECTION`

Date: 2026-07-26

Base branch: `task/OPC-GATE-0-FIRM-SCOPED-PREDMET-IDENTITY-AUDIT`

Base SHA: `13c5ae7291f9fe392a67ef805342992d5fe01bc5`

Task branch: `task/OPC-GATE-0-FIRM-IDENTITY-ADVISER-LINK-CORRECTION`

Final SHA: supplied by the Git completion response after commit and push.

## Trigger

The owner rejected the proposed same-FIRMA attestation question and correctly required the technical answer to be derived from the existing PREDMET/user architecture.

## Source-Confirmed Correction

The current local ownership chain is:

```text
PREDMET
  -> savetnikId / createdByKorisnikId
  -> local ADMINISTRATOR/SAVETNIK user
  -> local database
  -> singleton FIRMA
```

Evidence:

- `lib/core/database/tables/korisnici_table.dart`;
- `lib/features/auth/data/auth_repository.dart`;
- `lib/features/auth/presentation/korisnici_screen.dart`;
- `lib/core/database/tables/predmeti_table.dart`;
- `lib/features/predmeti/data/predmeti_repository.dart`;
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`;
- `lib/core/utils/json_export_import.dart`.

## Withdrawn Findings

- no owner same-FIRMA attestation is required;
- no new source-FIRMA identity block is required for individual PREDMET JSON by this audit;
- `ODQ-PREDMET-IDENTITY-LEGACY-001` is withdrawn;
- `ODQ-FIRMA-IDENTITY-HISTORY-001` is withdrawn;
- the user must not be asked to resolve local ID portability.

## Corrected Technical Finding

Individual PREDMET JSON currently carries source-local `savetnikId`, `createdByKorisnikId`, and modifier IDs. Those numeric IDs are not portable authority in another database. A future implementation must resolve/rebind them to an active destination-local administrator-approved user while preserving existing PREDMET authority and keep/replace/cancel behavior.

Full-backup PIB/MB preflight remains a separate already-approved guard because full backup replaces the complete FIRMA/user/database family.

## Changed Documents

- `docs/OPC_FIRM_SCOPED_PREDMET_IDENTITY_TECHNICAL_AUDIT.md`
- `docs/tasks/OPC_TASK_GATE_0_FIRM_SCOPED_PREDMET_IDENTITY_AUDIT_REPORT.md`
- `docs/OPC_DOCUMENTATION_SEMANTIC_OWNER_DECISION_QUEUE.md`
- `docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md`
- `docs/OPC_PREDMET_IDENTITY_VERSION_CHANGELOG_GAP_REGISTER.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/tasks/OPC_TASK_GATE_0_FIRM_IDENTITY_ADVISER_LINK_CORRECTION_REPORT.md`

## Scope Boundary

No application code, database schema, migration, JSON schema, test, build configuration, or runtime behavior was changed. No implementation is authorized by this correction.

## Result

`INCORRECT OWNER QUESTION WITHDRAWN — EXISTING PREDMET/USER/FIRMA LINK RESTORED — REMAINING WORK IS TECHNICAL`
