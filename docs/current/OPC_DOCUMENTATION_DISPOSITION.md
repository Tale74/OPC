# Documentation Re-baseline Disposition Manifest

**Status:** `CURRENT DISPOSITION / OWNER-LOGOS REVIEW REQUIRED`

`SCENARIO LOCK` is the last trusted previous documentation baseline. The recovered current documentation surface is top-down and bounded. No stale document receives authority by being read or linked.

| Surface | Disposition | Authority after cutover |
|---|---|---|
| `docs/current/*` | retain as new top-down current candidate | current by subject, pending OWNER/Logos review; 13-file set |
| `README.md` and the seven former home/current-state files | preserve for provenance with re-baseline boundary banner; original snapshots are in `docs/archive/documentation-rebaseline/legacy-homes/` | not independent authority; point to `docs/current/` |
| `docs/tasks/*` (128 files at inventory) | retain as historical/provenance evidence; no active authority links | non-authoritative |
| `docs/artifacts/*` (13 files at inventory) | retain as supporting artifact evidence; no business authority | non-authoritative |
| post-SCENARIO-LOCK reports, migration manifests and reconciliation ledgers | preserve as audit history; classify only through this manifest and review package | non-authoritative unless directly revalidated |
| 8 directly relevant PODSETNIK/URNA-PEPEO pointer, audit and task records | moved to `docs/archive/documentation-rebaseline/podsetnik-lineage/` with explicit contents manifest | archived; never current authority |
| internal pseudocode in primary SOURCE | forensic-only logical/technical evidence | never product/business authority |
| generated/private runtime material | exclude from current docs and review package | never current documentation authority |

The active navigation root is `docs/current/OPC_AUTHORITY_MANIFEST.md`. Archive isolation for directly superseded PODSETNIK pointers/reports is physical and recorded in `docs/archive/documentation-rebaseline/podsetnik-lineage/ARCHIVE_CONTENTS.md`; it must not be linked from the current surface.

## Inventory checkpoint

At the final read-only inventory, the recovery worktree contained 401
documentation/evidence files in the selected extensions: 13 current candidate
files, 19 archive files (including 9 legacy-home snapshots and 9
PODSETNIK/archive-boundary files), 128 task records and 13 artifact records.
The remaining 228 files are supporting or historical documentation. Counts are
evidence-time counts, not a claim about GitHub publication state.

## Synchronization boundary

This candidate defines the local target state. GitHub synchronization/publication is a separate gated action and was not performed. Any later publication must carry the same manifest, disposition, hashes and review package.
