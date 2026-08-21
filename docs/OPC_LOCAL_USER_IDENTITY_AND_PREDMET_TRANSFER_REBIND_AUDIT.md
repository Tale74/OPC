# OPC Local User Identity And PREDMET Transfer Rebind Audit

Status: `CODE-FIRST TECHNICAL AUDIT — NO IMPLEMENTATION AUTHORIZED`

Date: 2026-07-26

Base branch: `task/OPC-GATE-0-FIRM-IDENTITY-ADVISER-LINK-CORRECTION`

Base SHA: `fca00fa1cf4b53d7dccf858bc98e48a6a84f35f5`

Task branch: `task/OPC-GATE-0-LOCAL-USER-IDENTITY-TRANSFER-REBIND-AUDIT`

## 1. Scope

This audit follows the existing source relationship:

```text
PREDMET
  -> local adviser/actor metadata
  -> administrator-managed local user
  -> one local database
  -> FIRMA
```

It answers technical questions from source and tests before asking the owner. It does not change the approved FIRMA/ADMINISTRATOR/SAVETNIK/PREDMET business relationship and does not modify application code, schema, migrations, JSON, tests, UI, or runtime behavior.

## 2. Source Evidence

| Area | Evidence | Current behavior |
| --- | --- | --- |
| Local user schema | `lib/core/database/tables/korisnici_table.dart:3-10` | User identity is an auto-increment local integer `id` plus name, role, PIN hash, active flag, and creation date. There is no portable stable user identifier. |
| Administrator ownership | `lib/features/auth/data/auth_repository.dart:42-105`; `lib/features/auth/presentation/korisnici_screen.dart:7-44` | First local user is ADMINISTRATOR. User management UI is administrator-only. New local users are created inside the local database. |
| Role/session authority | `lib/features/auth/domain/session_service.dart:5-14`; `lib/features/auth/data/auth_repository.dart:64-80` | Login selects an active local user; administrator status derives from the local role. |
| New PREDMET | `lib/features/predmeti/presentation/lista_predmeta_screen.dart:306-318`; `lib/features/predmeti/data/predmeti_repository.dart:128-144` | New PREDMET receives `savetnikId` and `createdByKorisnikId` from the authenticated local session. |
| Later business change | `lib/features/predmeti/data/predmeti_repository.dart:217-282`; `:475-510` | Save/close paths write `lastBusinessModifiedByKorisnikId` and local `logIzmena.korisnikId` from the acting local user. |
| PREDMET user columns | `lib/core/database/tables/predmeti_table.dart:9-18` | `savetnikId`, `createdByKorisnikId`, and `lastBusinessModifiedByKorisnikId` are nullable local integers without database foreign-key declarations. |
| Audit user column | `lib/core/database/tables/log_izmena_table.dart:5-13` | `logIzmena.korisnikId` is a required local integer but has no declared foreign key to `Korisnici`. |
| Deactivation/role change | `lib/features/auth/data/auth_repository.dart:108-145` | A user can be deactivated or have role changed while historical PREDMET/log references remain. The last active administrator is protected. |
| Permanent deletion guard | `lib/features/auth/data/auth_repository.dart:339-405`; `lib/core/database/database.dart:1986-2073` | Permanent deletion is blocked for own active session, last active admin, PREDMET rows where `savetnikId` matches, and `logIzmena` authored by the user. |
| Guard omission | same source | The deletion reference summary does not count `createdByKorisnikId` or `lastBusinessModifiedByKorisnikId`; deletion can therefore leave dangling historical metadata when the user is referenced only by those columns. |
| Single-PREDMET JSON | `lib/core/utils/json_export_import.dart:187-200`; `:403-460` | Individual transfer serializes all three PREDMET local user IDs but does not transfer the `Korisnici` table. |
| Legacy normalization | `lib/core/utils/json_export_import.dart:1550-1578`; `lib/core/json_transfer/predmet_json_transfer_core.dart:80-105` | Missing creator/modifier IDs normalize to `null`; `savetnikId` remains optional. |
| New individual import | `lib/core/utils/json_export_import.dart:740-775`; `lib/features/predmeti/data/predmeti_repository.dart:520-557` | Imported PREDMET receives a new local PREDMET id but its source-local user IDs are inserted unchanged. |
| Replacement import | `lib/core/utils/json_export_import.dart:765-790`; `lib/features/predmeti/data/predmeti_repository.dart:559-610` | Local PREDMET id is preserved, but imported PREDMET metadata replaces local adviser/creator/modifier IDs unchanged. |
| Conflict UI | `lib/core/utils/json_export_import.dart:1815-1905` | Dialog displays imported/local `savetnikId` and modifier id as numbers, even though imported values are not destination-local authority. |
| Full backup | `lib/core/utils/json_export_import.dart:515-575`; `:839-920` | Full backup transfers `Korisnici`, PREDMET, log, and FIRMA together and reinserts their local IDs as one database family. |
| Tests | `test/json_transfer_regression_test.dart:17-175`; `:250-320`; auth smoke/audit tests | JSON tests confirm transfer/default behavior and local-PREDMET-id replacement. Focused foreign-user-ID collision, rebinding, inactive-user, deletion-reference-completeness, and parity tests were not found. |

## 3. Technical Conclusions

### 3.1 Local user id is installation/database-local

The current integer user id is valid only inside its originating database family. Equal integer values in two independent databases do not prove the same human user.

Classification: `SOURCE-CONFIRMED`.

### 3.2 Full backup and individual PREDMET transfer have different identity semantics

Full backup transfers users, PREDMET records, logs, and FIRMA together, so preserving their internal local IDs is coherent after complete validation.

Individual PREDMET JSON does not transfer users. Its numeric user IDs are source provenance hints only and must not be inserted as destination-local authority.

Classification: `SOURCE-CONFIRMED / CURRENT IMPLEMENTATION DEFECT`.

### 3.3 Deactivation is not historical deletion

Deactivating a user preserves their row and therefore preserves existing PREDMET/log attribution. This is compatible with historical continuity.

Permanent deletion must remain stricter. The current guard is incomplete because it ignores creator and last-modifier references.

Classification: `SOURCE-CONFIRMED / REFERENCE-GUARD DEFECT`.

### 3.4 No new business decision is needed

Existing owner decisions already establish:

- PREDMET belongs to the local FIRMA through administrator-managed local work;
- individual JSON does not import foreign `logIzmena`;
- local import/replacement actor and timestamp are local audit authority;
- replacement preserves local audit history;
- imported business `verzija` remains the selected business version.

The remaining choices are technical mapping and validation details.

## 4. Recommended Rebind Model

### 4.1 New individual PREDMET import

When importing as a new local PREDMET:

- assign `savetnikId` to the authenticated active local importing user under the same eligibility rules used for local creation;
- assign `createdByKorisnikId` to that same local importer because import creates the local PREDMET record;
- assign `lastBusinessModifiedByKorisnikId` to the local importer when the imported business state is adopted locally;
- record a local `IMPORT_NEW` event with local actor/time authority;
- do not copy source-local numeric user IDs into destination authority columns.

Source adviser information may be shown only as non-authoritative transfer provenance if a future schema already has a safe textual/stable provenance field. It must not be guessed from a numeric id.

### 4.2 Replacement import

When replacing an existing local PREDMET:

- preserve the existing local `savetnikId`;
- preserve the existing local `createdByKorisnikId`;
- set `lastBusinessModifiedByKorisnikId` to the authenticated local replacement actor;
- preserve existing local audit events;
- append a local `IMPORT_REPLACE` event with local actor/time authority;
- adopt the explicitly selected imported business state and business `verzija`;
- do not copy source-local numeric user IDs into local authority columns.

This keeps replacement as a change to the existing local PREDMET rather than silently reassigning it to an unrelated local integer id.

### 4.3 Missing/inactive local actor

Individual import requires an authenticated active local user. If no such user exists, import is technically blocked. The importer must not choose or invent a foreign user identity.

If later UI allows administrator-directed assignment to another active local adviser, that assignment must use an actual destination-local user selected from the local database. It is an optional workflow refinement, not required to make the current importer-based model safe.

### 4.4 User lifecycle

- deactivation preserves historical references;
- role change does not rewrite completed or historical PREDMET attribution;
- permanent deletion guard must count `savetnikId`, `createdByKorisnikId`, `lastBusinessModifiedByKorisnikId`, and `logIzmena.korisnikId`;
- a referenced user is retained or deactivated, not permanently deleted;
- no raw PREDMET history is copied into the user record.

## 5. No Schema Rewrite Required

The safe rebinding behavior can be implemented without introducing a new cross-device user identity or rewriting the user/PREDMET schema.

A future OPC Web/sync or multi-database user federation may require stable UUID-style user identity, but that is outside current OPC v.1 implementation scope. It must not be pre-implemented through this local transfer fix.

## 6. Required Characterization And Test Matrix

A future authorized implementation task must cover:

| Case | Required result |
| --- | --- |
| New import, source id absent | Destination importer becomes local adviser/creator/modifier; local import event recorded. |
| New import, source id equals an unrelated destination id | Source number ignored; destination importer remains authority. |
| New import, source id does not exist locally | Import remains valid through destination-local rebinding. |
| Replacement, imported adviser differs | Existing local adviser and creator preserved; local replacement actor becomes modifier. |
| Replacement, local adviser inactive | Historical adviser remains; authenticated active local actor performs replacement. |
| Current user inactive/no session | Import blocked before database mutation. |
| Permanent deletion referenced only as creator | Deletion blocked. |
| Permanent deletion referenced only as last modifier | Deletion blocked. |
| Deactivation/role change | Historical PREDMET/log attribution unchanged. |
| Full backup | Internal user/PREDMET/log ids preserved only as one validated complete database family. |
| Failure during rebind/import | Transaction rollback leaves local PREDMET, IRiU, contacts, stock consequences, and log unchanged. |
| Windows/Android | Equivalent business attribution and conflict result. |

## 7. Documentation Disposition

`OPC-RULE-USER-001`, `TAR-003`, the identity gap register, and the semantic decision queue should record:

- the code-first technical answer exists;
- no owner answer is pending;
- implementation remains blocked only by authorization, characterization/tests, migration compatibility where applicable, and runtime validation.

## 8. Result

## 9. Current implementation reconciliation — 2026-08-21

The bounded correction described by this audit is now implemented: new and
replacement individual transfers require an active destination-local actor;
replacement preserves destination ownership and local history; deletion guards
cover adviser, creator, last modifier and `logIzmena`; and four-state full-backup
identity plus collision controls are covered by the current acceptance report.
Case 2 (existing local state plus missing/incomplete backup identity) remains
fail-closed and out of scope for merge/reconciliation in the historical
pre-implementation wording below; that wording is superseded by the current
selective fallback addendum. Historical successor reference:
`FULL-BACKUP MISSING/INCOMPLETE FIRMA IDENTITY — USER FALLBACK + SAFE
MERGE/RECONCILIATION DESIGN AND ACCEPTANCE`; Case 3 fresh recovery is supported.
The original pre-implementation findings below remain historical evidence.
Focused proof is 44/44 PASS; analyzer and the full Flutter suite are PASS (443
tests, 10 expected skips), and both release-build gates passed serially.

`LOCAL USER IDS ARE DATABASE-LOCAL — INDIVIDUAL PREDMET TRANSFER MUST REBIND TO LOCAL AUTHORITY — FULL BACKUP PRESERVES THE COMPLETE USER/PREDMET FAMILY — NO NEW OWNER DECISION OR SCHEMA REWRITE IS REQUIRED`

### Current Case-2 status

The earlier Case-2 wording in this historical audit is superseded by the
current bounded selective fallback. Destructive full-backup replacement stays
fail-closed when FIRMA identity is incomplete; explicit user confirmation can
import only new/unambiguous PREDMET families through the existing local-user
transfer seam. See `docs/OPC_FULL_BACKUP_CASE2_RECONCILIATION_DESIGN.md`.
