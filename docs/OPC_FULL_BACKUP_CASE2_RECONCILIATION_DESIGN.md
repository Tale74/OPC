# Full-backup Case-2 Safe Fallback / Reconciliation Design

## Decision

Case 2 is the bounded state in which destination-local business state exists
but the incoming full backup does not provide both FIRMA identity components
(PIB and matični broj). Missing identity is not treated as a match. The normal
destructive full-backup restore therefore remains fail-closed.

The accepted fallback is a user-confirmed, selective import of only new and
unambiguous PREDMET families. It reuses the existing single-PREDMET transfer
contract and destination-local actor rebinding; it is not a generic database
merge and does not replace the destination FIRMA or users.

## Source-learned full-backup model

`OPC_BACKUP`, schema 9, contains `predmeti`, `iriu`, `kontaktLica`, FIRMA and
user data, catalog/configuration/templates, PARTE preparation, `logIzmena`,
STANJE ROBE effects/consequences, reminders and optional SCENARIO snapshot,
provenance and definition/module sections. The ordinary restore deletes and
recreates the local database family in one transaction. That behavior remains
unchanged for Case 1 (identity consistent) and Case 3 (fresh local recovery).

The selective Case-2 path imports only `PREDMET` plus its connected `IRIU`,
contacts and the already-supported unresolved STANJE ROBE consequence transfer
subset. Foreign numeric user IDs are never imported. Scenario-global state,
snapshot/provenance, `logIzmena`, reminders, PARTE persistent/media state,
FIRMA, users, catalog/configuration and templates remain destination-local.

## Classification and user control

The preflight classifies every incoming PREDMET by trimmed `brojPredmeta`:

- one incoming row and no destination match: importable;
- one destination match: same-identity conflict, retained locally;
- duplicate incoming identity, duplicate destination identity or blank identity:
  ambiguous and not imported.

All rows are parsed and classified before mutation. The UI shows the counts and
requires the user to choose **UVEZI SAMO NOVE PREDMETE**. Cancel performs no
write. Conflict handling remains the existing individual PREDMET keep/replace/
cancel flow; no timestamp/version rule silently chooses a replacement.

## Atomicity and recovery

Selected new families are inserted in one outer database transaction. The
transactionless repository seam is used only because the caller owns this
transaction; there is no second merge abstraction. If parsing or an insert
fails, the transaction rolls back and no selected family is partially visible.
The local FIRMA, users and all retained families are never written by this
fallback.

The owner oracle remains the governing business rule: PREDMET is the sole
business truth and all derivatives must follow the currently applied PREDMET.
This fallback intentionally does not decide unresolved reminder triggers,
automatic scheduling, anonymization, global identity, Web/sync or any SCENARIO
policy.

## Rejected alternatives

- destructive full restore without complete identity: unsafe and remains
  blocked;
- timestamp/version-based automatic replacement: violates explicit human
  arbitration and the current PREDMET conflict boundary;
- importing FIRMA/users/catalog/reminders/PARTE/SCENARIO families: would merge
  unrelated local authority and require a broader migration design;
- portable/global user identity or a generic database merge engine: not present
  in the current architecture and not authorized.

## Compatibility boundaries

The fallback preserves the existing full-backup schema and individual transfer
formats. Case 1, Case 3, legacy backups, RR-008 replacement-derived-state
behavior, replacement `logIzmena`, SCENARIO lock and the local-database/FIRMA
boundary remain unchanged. Broader JSON/database migration, recovery and
cross-platform rehearsal remain separate roadmap successors.
