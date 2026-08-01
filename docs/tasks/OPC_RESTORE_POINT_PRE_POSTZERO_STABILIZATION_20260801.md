# OPC restore point — pre post-zero stabilization program

Date: 2026-08-01

## Protected source backup

- Archive: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_PRE_POSTZERO_STABILIZATION_20260801_1300.zip`
- Contents: `SOURCE` working tree excluding `.git`, `build`, `.dart_tool` and `.idea`.
- Purpose: recoverable source snapshot before the broad stabilization task.

## Git boundary

- Previous branch: `task/OPC-INC-003-BACKUP-REMINDER-COMPATIBILITY`
- Previous HEAD/upstream: `644b8b8c68ef9f9591fcc919fe217c1caa68d8c0`
- New task branch: `task/OPC-POSTZERO-STABILIZATION-AND-PERFORMANCE`
- Application source remains unchanged at this restore point.

## Protected restore-point copy

This manifest is copied to:

`C:\Projekti\OPC\OPC v.1\RESTORE_POINTS\RESTORE_POINT_20260801_PRE_POSTZERO_STABILIZATION.md`

## Recovery rule

Do not restore over the canonical/live database or the current working tree
without an explicit owner decision. Recover into an isolated location first,
verify the archive and compare Git SHA before any application or data action.

