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

## Mandatory precheck for future substantive work

Before a substantive task reads or writes implementation material, it must
confirm:

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
