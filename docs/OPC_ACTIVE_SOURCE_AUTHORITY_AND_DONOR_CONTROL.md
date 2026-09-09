# OPC Active Source Authority and Donor Control

**Status:** `CURRENT AUTHORITATIVE CONTROL DOCUMENT`
**Scope:** active-source authority, historical/evidence classification and bounded donor use.

## Purpose and relationship to other homes

This document is the durable control for distinguishing the current active
implementation/documentation layer from recovery, review, quarantine,
reconstruction and historical material. It complements
`OPC_SOURCE_OF_TRUTH_MAP.md`, which navigates the information homes, and
`OPC_DEVELOPMENT.md`, which defines the development workflow. It does not
create product or business authority and does not replace OWNER decisions,
the product/domain home or the engineering profile.

## Permanent authority rule

Current active `SOURCE` and current authoritative documentation are the
primary implementation and authority layer. `BACKUPS`, `RECOVERY`, `REVIEW`,
`QUARANTINE`, reconstruction artifacts and historical source snapshots are
evidence/provenance only unless an explicit OWNER-authorized donor
reconciliation permits bounded reuse. Whole-file or whole-tree donor
replacement is forbidden.

The current local recovered implementation may remain a mixed dirty working
state. Documentation synchronization does not imply that this implementation
state has been published as a coherent source baseline.

## Current classification boundary

The accepted active-source hygiene result records:

- active implementation and authoritative documentation roots as
  `ACTIVE AUTHORITATIVE`;
- Flutter/Dart build and tool output as `ACTIVE GENERATED`, never donor
  authority;
- external `REVIEW` and publication-reconstruction material as
  `ACCEPTED EVIDENCE ONLY`;
- recovery, backup and historical material as
  `HISTORICAL DONOR – NEVER USE DIRECTLY`;
- proven obsolete staging/evidence roots as `OBSOLETE – QUARANTINE`;
- `SOURCE/runtime_data` and `SOURCE/.audit_tmp` as
  `UNRESOLVED – DO NOT USE`.

The accepted hygiene package is external evidence, SHA-256
`2A637C0629D863F56D358E8CAFD99EEFA16E0D463F5D93ACBEBA61970085DD9C`.
Quarantine was copy/hash/remove verified without changing active source
content; protected high-risk active hashes remained matched.

## Mandatory active-source authority control gate

This is a permanent, non-optional gate for every substantive OPC development,
corrective-development, implementation, source-learning, architecture or
data-contract, migration, implementation-review, QA-remediation or other task
that may analyze implementation causality or modify `SOURCE` or tests.

Before implementation causality is analyzed and before any `SOURCE` or test
file is modified, the task must resolve the current physical location of the
current active-source control package from this document, the current
source-of-truth map and the current-state/handoff record. The package location
shown in a current-state record is a location fact, not an eternal path
invariant. If the location changes, the current authoritative record controls.
The five logical inputs remain mandatory even when a package uses generated
filename prefixes or another current naming convention:

1. `ACTIVE_SOURCE_AUTHORITY_MANIFEST.json`;
2. `STALE_DONOR_DENYLIST.json`;
3. `HIGH_RISK_ACTIVE_HASH_BASELINE.csv`;
4. `DONOR_USE_GATE.md`; and
5. `OPC_ACTIVE_SOURCE_PRECHECK.md`.

The task must physically open and read each input during the current task,
verify current provenance and package integrity according to the current
manifest/handoff procedure, execute the prescribed precheck against the
protected active `SOURCE`, and report each input individually. Filename
recognition, existence-only checks, summaries, prior memory or a previous
task's PASS do not satisfy this gate. A machine check, if available, supports
but never replaces semantic reading and reporting.

The required HUMAN GATE evidence is equivalent to:

```text
ACTIVE SOURCE CONTROL INPUTS

[PASS] ACTIVE_SOURCE_AUTHORITY_MANIFEST.json
resolved physical path: <current resolved path>
READ = YES
current provenance/integrity: PASS

[PASS] STALE_DONOR_DENYLIST.json
resolved physical path: <current resolved path>
READ = YES
current provenance/integrity: PASS

[PASS] HIGH_RISK_ACTIVE_HASH_BASELINE.csv
resolved physical path: <current resolved path>
READ = YES
current provenance/integrity: PASS

[PASS] DONOR_USE_GATE.md
resolved physical path: <current resolved path>
READ = YES
current provenance/integrity: PASS

[PASS] OPC_ACTIVE_SOURCE_PRECHECK.md
resolved physical path: <current resolved path>
READ = YES
current provenance/integrity: PASS

ACTIVE SOURCE AUTHORITY PRECHECK — PASS
```

The external package is a current local-only verification/control input for
this purpose. It is not implementation authority, is not a donor, and must
not be promoted or copied into `SOURCE` merely to satisfy the gate. Historical,
recovery, review, quarantine, backup and stale material remains non-
authoritative unless a separate bounded reconciliation and explicit OWNER
authorization applies.

The gate must stop with
`ACTIVE SOURCE AUTHORITY PRECHECK — STOP — <reason>` if any input is missing,
ambiguous, unread, provenance/integrity-unverified or hash-inconsistent; if a
denylisted/stale donor would be required; if protected `SOURCE` cannot be
reconciled safely; or if an unresolved forbidden root would need to become
authority. No implementation source-learning or modification may proceed
after such a stop.

## Mandatory precheck for future substantive work

The permanent gate above is applied before a substantive task reads or writes
implementation material. Its precheck must confirm:

1. the active-source authority manifest is loaded;
2. the stale donor denylist is loaded;
3. relevant high-risk active hashes are checked;
4. every write target is within an authorized active root;
5. no donor material is used without explicit OWNER-authorized reconciliation;
6. every `UNRESOLVED – DO NOT USE` root remains untouched.

The precheck is an authority-hygiene control. It does not authorize source
changes, donor promotion, cleanup, schema changes or publication by itself.

## Bounded donor-use gate

If current active source is incomplete, the task must identify the exact
missing unit, compare the candidate donor against current authority and
accepted evidence, prove the smallest bounded change, and obtain the required
OWNER authorization before any reuse. Evidence may be read for comparison;
it is not implementation authority. Accepted functionality, data contracts,
portable identity and unrelated dirty work must remain protected.
