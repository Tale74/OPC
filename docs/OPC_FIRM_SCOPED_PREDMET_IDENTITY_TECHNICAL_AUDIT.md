# OPC Firm-Scoped PREDMET Identity Technical Audit

Status: `CODE-FIRST TECHNICAL AUDIT — NO IMPLEMENTATION AUTHORIZED`

Audit date: 2026-07-26

Base branch: `task/OPC-GATE-0-CLOSE-CONFIRMED-BUSINESS-VERSION-OWNER-DECISION`

Base SHA: `d7b906339b45309164e49fd26023f87881e63552`

Task branch: `task/OPC-GATE-0-FIRM-SCOPED-PREDMET-IDENTITY-AUDIT`

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
| PREDMET schema | `lib/core/database/tables/predmeti_table.dart:3-18` | PREDMET stores local `id` and `brojPredmeta`; it has no FIRMA foreign key, FIRMA identity snapshot, or repository identity key. |
| Number generation | `lib/core/format/app_format.dart:17-24`; `lib/features/predmeti/data/predmeti_repository.dart:128-144` | `brojPredmeta` is generated from day, month, two-digit year, hour, and minute. Two creations in the same minute can produce the same value. |
| Uniqueness enforcement | `lib/core/database/tables/predmeti_table.dart`; `lib/core/database/database.dart` | No unique key or unique index protects `predmeti.broj_predmeta`. |
| Single-PREDMET JSON | `lib/core/utils/json_export_import.dart:403-460` | Transfer contains PREDMET, IRiU, contacts, optional stock consequences, and transfer metadata. It does not contain FIRMA PIB/MB or a stable FIRMA identity block. |
| Current conflict lookup | `lib/core/utils/json_export_import.dart:2176-2205` | Import trims non-empty `brojPredmeta` and queries local PREDMET rows by that field only. One match opens keep/replace/cancel; multiple matches stop replacement. |
| Replacement | `lib/features/predmeti/data/predmeti_repository.dart:559-610` | Replacement keeps the local technical PREDMET id and inserts imported business state. Firm scope is not checked. |
| Full backup export | `lib/core/utils/json_export_import.dart:515-575` | Full backup includes the singleton `firmaPodaci` map and the complete local database transfer set. |
| Full backup import | `lib/core/utils/json_export_import.dart:839-900`; `:2231-2260` | UI requests destructive confirmation, then import deletes current FIRMA/PREDMET data and inserts imported FIRMA data. No PIB/MB preflight comparison occurs before deletion. |
| Transfer tests | `test/json_transfer_regression_test.dart:17-175`; `:380-470` | Tests protect PREDMET serialization, import, local-id-preserving replacement, legacy backup compatibility, and selected backup validation. No focused FIRMA mismatch, missing identity, duplicate-generation, or firm-scoped conflict tests exist. |

## 3. Current Identity Model

The current runtime has three separate concepts:

1. local technical PREDMET identity: `predmeti.id`;
2. user-facing case number and current import conflict key: `predmeti.brojPredmeta`;
3. mutable current FIRMA data: singleton `FirmaPodaci(id = 1)`.

The three concepts are not joined by a persistent identity relation. Therefore the current database cannot prove which PIB/MB identity was applicable to an older PREDMET when FIRMA settings later change.

Classification: `SOURCE-CONFIRMED ARCHITECTURAL GAP`.

## 4. Confirmed Risks

### 4.1 Same-minute duplicate creation

Minute-resolution generation plus absence of a unique constraint permits duplicate `brojPredmeta` values. Current single-PREDMET import already treats multiple local matches as unsafe and stops replacement.

Classification: `SOURCE-CONFIRMED COLLISION RISK`.

### 4.2 Cross-firm false conflict

Because single-PREDMET JSON carries no FIRMA identity and matching uses only `brojPredmeta`, a transfer from another FIRMA can be presented as the same local PREDMET.

Classification: `SOURCE-CONFIRMED POLICY/IMPLEMENTATION CONFLICT`.

### 4.3 Destructive full-backup replacement without identity preflight

The imported full backup contains FIRMA PIB/MB, but current flow reaches destructive replacement without comparing those values to the local FIRMA identity.

Classification: `SOURCE-CONFIRMED POLICY/IMPLEMENTATION CONFLICT / DATA-LOSS RISK`.

### 4.4 Editable identity without history

PIB and MB are mutable display/settings fields. Current source has no identity-history table and no PREDMET-bound FIRMA identity snapshot. Later changes can make historical firm scope unprovable.

Classification: `SOURCE-CONFIRMED HISTORY GAP`.

### 4.5 Legacy compatibility ambiguity

Previously distributed single-PREDMET JSON files do not contain FIRMA identity. Old backups may contain blank or historically editable PIB/MB. A new guard cannot safely treat missing identity as either a match or a mismatch without an explicit compatibility rule.

Classification: `MIGRATION/OWNER DECISION REQUIRED`.

## 5. Technical Architecture Recommendation

Retain the current codebase and add a focused identity layer. This evidence does not justify partial or full rewrite.

### 5.1 Normalized business identity value

Introduce one shared normalization/comparison component for PIB and MB:

- trim surrounding whitespace;
- remove presentation separators only if their accepted formats are source- and test-proven;
- preserve raw display values separately;
- compare normalized values deterministically;
- never use FIRMA name or address as identity.

Normalization is a technical decision; changing which legal identifiers define FIRMA remains owner authority.

### 5.2 FIRMA identity history

Do not use only the mutable singleton row as historical identity. Introduce an append-only FIRMA identity history record containing at minimum normalized PIB, normalized MB, validity metadata, and local creation/change actor-time metadata. Do not store old full FIRMA/PREDMET business snapshots in that history.

Each new PREDMET should reference or snapshot the effective FIRMA identity record used when it was created. Completed PREDMET records must retain their historical identity reference when current FIRMA settings change.

Legacy PREDMET rows must not be falsely claimed as historically proven. Migration should mark their backfilled association as `legacy-assumed` or equivalent until the owner-approved compatibility rule is applied.

### 5.3 Single-PREDMET transfer identity block

A future JSON schema revision should add a small source-FIRMA identity block containing the normalized PIB/MB identity applicable to that PREDMET. It must not export the whole mutable `FirmaPodaci` record and must not turn JSON into a parallel business truth.

Import order should become:

1. validate supported schema;
2. parse and validate source FIRMA identity;
3. compare source and local FIRMA scope;
4. only inside the same proven FIRMA scope, compare `brojPredmeta`;
5. retain explicit keep/replace/cancel behavior;
6. apply business `verzija` only as a later same-PREDMET version signal.

### 5.4 Full-backup preflight

Full-backup import must compare imported and local normalized PIB/MB before the destructive confirmation and before entering the delete transaction. Proven mismatch must block with no override, as already decided by the owner.

Validation/parsing must finish before destructive writes. A failure must leave the current database unchanged.

### 5.5 Collision-safe local creation

Preserve the existing human-readable case-number policy, but creation must become atomic:

- generate a candidate;
- check it inside the creation transaction;
- deterministically regenerate/suffix on collision;
- enforce a compatible database uniqueness rule for the local FIRMA/database scope.

The exact suffix format is a technical/UI detail as long as the user-facing `brojPredmeta` remains stable after creation.

## 6. Required Migration And Test Proof Before Implementation

Future implementation remains blocked until one implementation task proves:

- migration from database schema version 22 without losing canonical PREDMET data;
- behavior for old rows with no FIRMA identity reference;
- behavior for old single-PREDMET JSON without a FIRMA block;
- behavior for old backup with missing/blank PIB or MB;
- normalized match and mismatch matrices;
- no destructive write before full-backup preflight passes;
- same-minute/concurrent PREDMET creation collision handling;
- one-match and multiple-match single-PREDMET conflict behavior;
- keep/replace/cancel remains explicit;
- completed PREDMET historical stability;
- Windows and Android parity of business result;
- rollback on parsing, validation, and transaction failure.

## 7. Owner Decision Queue

Source and existing owner policy already answer identity scope, mismatch behavior, and keep/replace/cancel. They must not be asked again.

Only these business-policy decisions remain:

### `ODQ-PREDMET-IDENTITY-LEGACY-001`

How should an old single-PREDMET JSON without source FIRMA identity be handled?

- block import;
- allow controlled import as a new PREDMET only;
- or allow explicit same-firm attestation before normal conflict handling.

Codex recommendation: explicit same-firm attestation, followed by normal conflict handling, with a local audit event. This preserves compatibility without silently asserting identity.

### `ODQ-FIRMA-IDENTITY-HISTORY-001`

When PIB or MB changes, is the new value:

- a correction of the same FIRMA identity;
- or a transition to a different FIRMA identity/database family?

Codex can implement the history mechanism, but this distinction changes business ownership semantics and remains owner authority.

## 8. Dependency Conclusion

The next implementation sequence, when separately authorized, is:

1. owner closes the two decisions in section 7;
2. characterize and test current database/JSON legacy fixtures;
3. introduce identity normalization and FIRMA identity history migration;
4. bind new PREDMET records to effective FIRMA identity;
5. add schema-versioned single-PREDMET identity block;
6. add full-backup preflight mismatch guard;
7. add collision-safe `brojPredmeta` creation;
8. run required analyze/test/build/runtime gates.

PODSETNIK completion, Web/sync, and stronger import freshness rules must not precede this foundation where they depend on PREDMET identity.

## 9. Audit Result

`FIRM-SCOPED PREDMET IDENTITY POLICY IS OWNER-CLOSED — CURRENT SOURCE DOES NOT IMPLEMENT IT — TARGETED IDENTITY LAYER AND MIGRATION ARE RECOMMENDED — TWO LEGACY/HISTORY OWNER DECISIONS REMAIN`
