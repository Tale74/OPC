# OPC zero baseline and post-zero owner authority

**Status:** `ACTIVE OWNER AUTHORITY`
**Established:** 2026-07-29

## 1. New zero baseline

The current OPC Windows/Android project is functional and usable. It is the
new development zero baseline, not a failed product awaiting rescue.

- Application/source baseline:
  `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`.
- Documentation/continuity baseline immediately before this decision:
  `3946202fd4e947a9182f10e9e8d5463093691dd9`.
- Later corrections in the approved plan and draft are prospective upgrades
  of this functional baseline.
- An upgrade may not silently regress an existing usable capability, canonical
  database, PREDMET authority or Windows/Android business-result parity.

## 2. Owner-decision authority reset

Only owner decisions made after establishment of this zero baseline are
current owner authority.

Earlier owner decisions and documents are obsolete as active authority. They
may remain temporarily only as:

- technical/source evidence needed for safe migration or compatibility;
- Git historical evidence;
- recorded incident evidence needed to prevent drift;
- backup and restore evidence.

A rule found only in pre-zero documentation is not current owner policy unless
the owner confirms it after the zero baseline.

## 3. Prospective plan continuity

The owner explicitly carries forward the approved dependency-based plan and
its originating draft as the prospective upgrade program for:

- completion and stabilization of OPC v.1 Serbia;
- controlled integrity, performance, lifecycle, SCENARIO, document, currency
  and UX upgrades;
- later transition to the multilingual product line.

The plan governs future sequencing. It does not turn pre-zero owner-decision
documents into current authority.

## 4. Preserved evidence

The cleanup must preserve:

- backup files and backup/restore ability;
- Git history without history rewrite;
- current source and test evidence necessary to understand the zero baseline;
- canonical database migration and compatibility facts;
- incident and anti-drift records.

## 5. Documentation authority

The local repository path `SOURCE/docs` is the working local copy of the same
documentation published through GitHub. It is the single active
documentation source.

Legacy parallel `SOURCE/PROJECT_DOCS`, external `PROJECT_DOCS`, ignored root
notes and superseded Git documents are cleanup inputs, not parallel authority.

Future handover documentation must be:

- repository-relative and privacy-safe;
- source- and version-traceable;
- organized by current product, architecture, data, build/release, tests,
  known issues, incidents and operational handover;
- free of obsolete or conflicting active instructions.

## 6. Post-zero owner decisions

1. Current OPC is the functional and usable zero baseline.
2. Planned corrections are upgrades of that baseline.
3. Only post-zero owner decisions are current owner authority.
4. Pre-zero owner decisions/documents are obsolete as active authority.
5. Backups and Git history are preserved.
6. Recorded incidents are preserved in the current Incident/Anti-Drift
   Register to prevent recurrence.
7. Documentation cleanup and Git/local authority alignment are authorized.

## 7. Post-zero continuity confirmation - 2026-07-30

The owner confirmed the following continuing boundaries after establishment of
the zero baseline:

- `PREDMET` remains the single business truth; derivatives cannot become
  parallel authority.
- Windows and Android remain equal, standalone local applications.
- The designated canonical database is not deleted, replaced or used for
  experiments.
- Data work requires backup-first handling, isolated migration copies,
  readable-backup proof and rollback/restore evidence.
- Historical package/licensing code must not restrict the current native
  product.
- OPC Web is not current implementation scope.
- OPC v.1 Serbia must be completed and stabilized before `OPC_v.1_Int`.
- A future localized version includes Serbian in both Latin and Cyrillic
  scripts.
- The approved dependency plan and its originating draft remain prospective
  upgrade-program evidence.
- Git history is preserved without history rewrite.

The owner also reconfirmed the incident discipline:

- the unauthorized IRiU ordering change is not owner-approved merely because a
  diff, changed test or technical PASS exists;
- a hypothesis is not a confirmed root cause;
- accepted behavior is not changed under the label of refactoring;
- technical PASS and owner runtime acceptance are recorded separately.

The active Git documentation classification is maintained in
`docs/OPC_POST_ZERO_DOCUMENTATION_AUTHORITY_INVENTORY.md`.

## 8. RI-2 full-restore owner decisions - 2026-07-30

The owner selected the following post-zero policies:

- **3A - logical reminder portability:** a full backup carries reminder
  enablement and delivery times. Device-local notification IDs never travel
  with the backup. Restore cancels and clears destination reminder state, then
  creates new local notification IDs where scheduling is possible.
- **4A - installation-local security/audit:** users and their PIN hashes remain
  part of the full backup. `security_settings`, including recovery material,
  and existing `auth_audit_log` remain owned by the destination installation.
  A successful restore appends a new destination-local auth audit event.

These decisions authorize only the RI-2 full-restore lifecycle slice. They do
not answer the separate anonymization or individual-replacement owner gates,
enable foreign keys, authorize migration/orphan repair, or open canonical
production data.

## 9. PARTE user-facing terminology confirmation - 2026-07-30

The owner confirmed during Windows runtime acceptance that user-facing PARTE
validation and warning text:

- must never expose internal block IDs such as `mourners`;
- must use the Serbian business label, including `Ožalošćeni`;
- must remain valid Serbian Unicode text without mojibake.

This is an active post-zero UI/terminology boundary. Recording the observed
defect does not itself authorize an application-code correction outside a
separate notified task branch.
