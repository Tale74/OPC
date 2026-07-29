# OPC task report — zero-baseline authority, incident register and local-doc cleanup

**Status:** `POST-ZERO AUTHORITY ESTABLISHED — INCIDENTS PRESERVED — LOCAL PARALLEL AUTHORITY REMOVED`
**Date:** 2026-07-29

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- documentation / cleanup

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no

Future OPC Web affected:
- no

Terminology drift risk:
- controlled

Implementation allowed:
- no

Required gate before implementation:
- post-zero documentation authority and Architecture Decision Gate

## 1. Git baseline

- Base branch: `task/OPC-GATE-0-PROTECTION-REEVALUATION-CLOSURE`
- Base SHA: `3946202fd4e947a9182f10e9e8d5463093691dd9`
- Task branch: `task/OPC-ZERO-BASELINE-AUTHORITY-AND-INCIDENT-REGISTER`
- Final SHA: supplied by Git branch tip and completion response

## 2. Owner authority recorded

- Current application is functional and usable.
- It is the new zero baseline.
- Planned work is a prospective upgrade.
- Only post-zero owner decisions are current owner authority.
- Backups and Git history remain preserved.
- Recorded incidents remain permanent anti-drift evidence.
- Git/local documentation cleanup and alignment are authorized.

## 3. Incident preservation

The current register preserves:

- unauthorized IRiU basic/scenario ordering regression;
- reported Windows Administrator persistence/identity anomaly with unproven
  root cause.

Historical reports remain available through Git history after later cleanup.

## 4. Local authority cleanup

The local repository `SOURCE/docs` is designated as the working local copy of
the GitHub documentation.

After exact path and backup-exclusion verification, the following parallel
authority folders were removed:

- `SOURCE/PROJECT_DOCS`: 14 files, 949,966 bytes;
- external sibling `PROJECT_DOCS`: 11 files, 877,593 bytes.

Both paths were confirmed absent after deletion. The project `BACKUPS`
directory was explicitly excluded and confirmed present afterwards.

The removed folders were not Git-tracked authority. Their pre-zero content
remains available only where separately retained in backups or prior evidence.
The local repository `SOURCE/docs` now remains the working copy of GitHub
documentation.

## 5. Scope

- No application source/test/configuration change.
- No canonical database access.
- No backup deletion.
- No Git history rewrite.
- No cleanup of Git-tracked historical documents in this task; that follows
  only after the post-zero active-document inventory is fixed.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked:
- yes

Core purpose preserved:
- yes

PREDMET meaning preserved:
- yes

Database ownership preserved:
- yes

Windows/Android parity preserved:
- yes

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes

OPC Web remains outside current implementation scope:
- yes

Source changes within scope:
- yes — documentation only

PASS / NOT PASS:
- PASS for post-zero authority and incident preservation
