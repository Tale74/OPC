# OPC Firm-Scoped PREDMET Identity Technical Audit

Status: `CODE-FIRST TECHNICAL AUDIT — NO IMPLEMENTATION AUTHORIZED`

Audit date: 2026-07-26

Base branch: `task/OPC-GATE-0-CLOSE-CONFIRMED-BUSINESS-VERSION-OWNER-DECISION`

Base SHA: `d7b906339b45309164e49fd26023f87881e63552`

Task branch: `task/OPC-GATE-0-FIRM-SCOPED-PREDMET-IDENTITY-AUDIT`

Correction branch: `task/OPC-GATE-0-FIRM-IDENTITY-ADVISER-LINK-CORRECTION`

Correction note: the first published audit incorrectly elevated a technical adviser/user mapping question into two owner decisions and proposed a new single-PREDMET FIRMA identity block. Source review and owner correction establish the existing `PREDMET -> SAVETNIK/creator -> local database -> singleton FIRMA` ownership boundary. Those recommendations are withdrawn below.

## 1. Purpose And Locked Boundary

This audit resolves the source-first technical questions behind `ODQ-PREDMET-IDENTITY-001` and `TAR-003`. It does not change application code, database schema, JSON schema, tests, migrations, UI, runtime behavior, or existing business policy.

Locked owner policy remains:

```text
PIB + Matični broj + brojPredmeta
```

`brojPredmeta` is unique only within the same FIRMA. Local database `id`, filename, `exportDatum`, `exportVerzija`, and business `verzija` are not PREDMET identity keys.

## 2. Verified Source Baseline

| Evidence | Source location | Verified behavior |
| --- | --- | --- |
| FIRMA storage | `lib/core/database/tables/firma_podaci_table.dart:3-16` | `FirmaPodaci` is a singleton table; PIB and MB are editable text columns with empty-string defaults. |
| FIRMA seed and access | `lib/core/database/database.dart:780-790`; `lib/features/podesavanja/data/podesavanja_repository.dart:78-87` | Runtime creates and reads row `id = 1`; saving settings updates that same mutable row. |
| FIRMA input | `lib/features/podesavanja/presentation/podesavanja_screen.dart:833-850`; `:929-975` | PIB and MB are trimmed on save, but no format, non-empty, or immutable-identity validation is attached to these fields. |
| Local users and roles | `lib/core/database/tables/korisnici_table.dart:3-10`; `lib/features/auth/data/auth_repository.dart:28-105`; `lib/features/auth/presentation/korisnici_screen.dart:7-44` | The local database owns ADMINISTRATOR/SAVETNIK users; first ADMINISTRATOR is created locally and only an authenticated administrator can use the user-management UI. |
| PREDMET ownership link | `lib/core/database/tables/predmeti_table.dart:3-18`; `lib/features/predmeti/data/predmeti_repository.dart:128-144`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart:306-318` | New PREDMET receives `savetnikId` and `createdByKorisnikId` from the authenticated local session. In the one-local-database/one-FIRMA model this is the existing FIRMA ownership chain. |
| Number generation | `lib/core/format/app_format.dart:17-24`; `lib/features/predmeti/data/predmeti_repository.dart:128-144` | `brojPredmeta` is generated from day, month, two-digit year, hour, and minute. Two creations in the same minute can produce the same value. |
| Uniqueness enforcement | `lib/core/database/tables/predmeti_table.dart`; `lib/core/database/database.dart` | No unique key or unique index protects `predmeti.broj_predmeta`. |
| Single-PREDMET JSON | `lib/core/utils/json_export_import.dart:187-200`; `:403-460` | Transfer contains PREDMET, including `savetnikId`/creator/modifier local IDs, IRiU, contacts, optional stock consequences, and transfer metadata. It does not carry transferable user rows. |
| Current conflict lookup | `lib/core/utils/json_export_import.dart:2176-2205` | Import trims non-empty `brojPredmeta` and queries local PREDMET rows by that field only. One match opens keep/replace/cancel; multiple matches stop replacement. |
| Import/replacement user handling | `lib/core/utils/json_export_import.dart:740-790`; `lib/features/predmeti/data/predmeti_repository.dart:559-610` | Imported PREDMET local user IDs are inserted/replaced without mapping them to an active user in the destination database. A foreign local ID can be absent or point to a different local user. |
| Full backup export | `lib/core/utils/json_export_import.dart:515-575` | Full backup includes the singleton `firmaPodaci` map and the complete local database transfer set. |
| Full backup import | `lib/core/utils/json_export_import.dart:839-900`; `:2231-2260` | UI requests destructive confirmation, then import deletes current FIRMA/PREDMET data and inserts imported FIRMA data. No PIB/MB preflight comparison occurs before deletion. |
| Transfer tests | `test/json_transfer_regression_test.dart:17-175`; `:380-470` | Tests protect PREDMET serialization, import, local-id-preserving replacement, legacy backup compatibility, and selected backup validation. No focused FIRMA mismatch, missing identity, duplicate-generation, or firm-scoped conflict tests exist. |

## 3. Corrected Current Identity Model

The local runtime already has an ownership chain:

```text
PREDMET
  -> savetnikId / createdByKorisnikId
  -> local ADMINISTRATOR/SAVETNIK user
  -> one local database
  -> singleton FIRMA
```

The local database is the current FIRMA boundary. A separate FIRMA foreign key on every PREDMET is not required to express ownership inside this one-FIRMA database model.

The source-confirmed gap appears only when an individual PREDMET crosses databases: `savetnikId`, `createdByKorisnikId`, and `lastBusinessModifiedByKorisnikId` are local database IDs. They cannot be copied into another database as transferable user identity.

Classification: `EXISTING OWNERSHIP MODEL CONFIRMED / CROSS-DATABASE USER-MAPPING GAP`.

## 4. Confirmed Risks

### 4.1 Same-minute duplicate creation

Minute-resolution generation plus absence of a unique constraint permits duplicate `brojPredmeta` values. Current single-PREDMET import already treats multiple local matches as unsafe and stops replacement.

Classification: `SOURCE-CONFIRMED COLLISION RISK`.

### 4.2 Imported local user-ID collision

An imported numeric `savetnikId` may not exist in the destination database or may identify a different administrator-approved user. Blindly preserving that number can attribute the PREDMET to the wrong local user.

Classification: `SOURCE-CONFIRMED TRANSFER-MAPPING DEFECT`.

### 4.3 Destructive full-backup replacement without identity preflight

Full backup is different from single-PREDMET transfer: it carries FIRMA and local users together. The imported backup contains FIRMA PIB/MB, but current flow reaches destructive replacement without comparing those values to the current local FIRMA before deletion.

Classification: `SOURCE-CONFIRMED POLICY/IMPLEMENTATION CONFLICT / DATA-LOSS RISK`.

### 4.4 Incorrect first-audit recommendation

The initial audit proposed source-FIRMA identity metadata and owner same-firm attestation for individual PREDMET JSON. That adds a new concept where the current model already establishes FIRMA ownership through the destination database and its administrator-approved user. The proposal is withdrawn.

Classification: `DOCUMENTATION CORRECTION`.

## 5. Corrected Technical Architecture Recommendation

Retain the current codebase and existing one-database/one-FIRMA ownership model. This evidence does not justify partial or full rewrite and does not justify a new per-PREDMET FIRMA identity subsystem.

### 5.1 Resolve individual transfer through a local approved user

Individual PREDMET import should not trust transferred local numeric user IDs. The import boundary must:

1. validate the transfer and PREDMET data;
2. resolve PREDMET ownership to an active user from the destination local database;
3. use the authenticated importing user where current role rules permit;
4. otherwise require selection of an active local user available under the destination administrator;
5. write destination-local `savetnikId`/creator/modifier metadata according to the existing audit policy;
6. preserve source user information only if a later technical design can do so as non-authoritative transfer provenance without importing foreign local IDs.

This is technical user-ID rebinding inside the existing business model. It is not a new FIRMA identity decision.

### 5.2 Preserve existing conflict behavior

Within the destination local FIRMA/database, `brojPredmeta` remains the current case conflict key. Keep/replace/cancel remains explicit. Business `verzija` remains a later version signal, not an identity key.

No new source-FIRMA identity block or same-firm attestation is required by this audit.

### 5.3 Full-backup preflight remains separate

Full backup carries the complete FIRMA/user/database family. The existing owner decision still applies: compare imported and current PIB/MB before destructive confirmation and before entering the delete transaction; proven mismatch blocks restore without override.

Validation/parsing must finish before destructive writes. A failure must leave the current database unchanged.

### 5.4 Collision-safe local creation

Preserve the existing human-readable case-number policy, but creation must become atomic:

- generate a candidate;
- check it inside the creation transaction;
- deterministically regenerate/suffix on collision;
- enforce a compatible database uniqueness rule inside the local FIRMA/database.

The application resolves the collision. The user must not be asked to reason about this technical consequence.

## 6. Required Test Proof Before Implementation

Future implementation remains blocked until one separately authorized task proves:

- source local user IDs are never silently treated as destination user identity;
- import resolves/rebinds to an active local administrator-approved user;
- missing, inactive, changed-role, and colliding local user IDs are safe;
- one-match and multiple-match `brojPredmeta` conflict behavior remains intact;
- keep/replace/cancel remains explicit;
- full-backup PIB/MB preflight happens before destructive confirmation/write;
- same-minute/concurrent PREDMET creation collision handling;
- no canonical PREDMET/IRiU/contact loss;
- Windows and Android parity of business result;
- rollback on parsing, validation, and transaction failure.

## 7. Owner Decision Queue

No new owner decision is required by this correction.

Withdrawn:

- `ODQ-PREDMET-IDENTITY-LEGACY-001`;
- `ODQ-FIRMA-IDENTITY-HISTORY-001`;
- the proposal for user same-firm attestation;
- the proposal that individual PREDMET JSON must add a new source-FIRMA identity block.

Any future change to the business relationship between FIRMA, ADMINISTRATOR, SAVETNIK, and PREDMET remains owner authority. The current correction preserves that relationship.

## 8. Dependency Conclusion

The next implementation sequence, when separately authorized, is:

1. characterize local-user mapping fixtures for individual PREDMET transfer;
2. implement destination-local adviser/actor rebinding without importing foreign local IDs as authority;
3. add full-backup PIB/MB preflight;
4. add collision-safe `brojPredmeta` creation;
5. run required analyze/test/build/runtime gates.

PODSETNIK completion and stronger import/version rules must preserve the same PREDMET-to-local-user-to-FIRMA boundary.

## 9. Corrected Audit Result

## 10. Current implementation reconciliation — 2026-08-21

The bounded implementation now applies the audit conclusion: individual
transfer/replacement rebinds local authority without adding a FIRMA identity
block, four-state full-backup PIB/MB and structural preflight precedes
destructive confirmation/write, and local number collisions are resolved
transactionally without renumbering legacy duplicates. Missing/incomplete
backup identity with existing local business state is Case 2 and fails closed;
The next successor wording is historical pre-implementation evidence and is
superseded by the current Case-2 closure addendum below.
merge/reconciliation remains out of scope with successor
`FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY — USER FALLBACK + SAFE
MERGE/RECONCILIATION DESIGN AND ACCEPTANCE`. A fresh local database with a
complete identity remains a legitimate Case-3 recovery path. The
pre-implementation matrix remains historical evidence; current status is in
`docs/OPC_PREDMET_LOCAL_IDENTITY_RECOVERY_ACCEPTANCE_REPORT.md`. Broader
Web/sync identity, migration/recovery and runtime parity remain separate.

`PREDMET ALREADY BELONGS TO THE LOCAL FIRMA THROUGH ITS ADMINISTRATOR-APPROVED USER CONTEXT — INDIVIDUAL JSON NEEDS TECHNICAL LOCAL-USER REBINDING, NOT A NEW FIRMA IDENTITY CONCEPT OR OWNER ATTESTATION`
## Current Case-2 closure addendum

The previously open Case-2 successor is closed by a bounded selective fallback:
destructive full-backup replacement remains fail-closed when FIRMA identity is
incomplete, while a user-confirmed plan may import only new/unambiguous
PREDMET families through the existing destination-local transfer seam. The
fallback does not merge FIRMA, users, catalog/configuration, PARTE, reminders,
history or SCENARIO state. See
`docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_ACCEPTANCE_REPORT.md` for current
implementation and acceptance evidence. Earlier sections retain their
historical pre-implementation classification.
