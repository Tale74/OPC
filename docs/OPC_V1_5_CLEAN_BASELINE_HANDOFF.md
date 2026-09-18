# OPC v1.5 Clean Development Baseline Handoff

## Task identity

- Task: `OPC v1.5 CLEAN DEVELOPMENT BASELINE`
- Owner: Tale
- Outcome: local clean development baseline establishment
- Scope: source/test/configuration migration of the already reconciled current delta; no product correction
- Publication: not pushed; implementation publication remains separately gated

## Source continuity

- Predecessor SOURCE: `C:\Projekti\OPC\OPC v.1\SOURCE`
- Predecessor branch: `task/OPC-RR011-ANDROID-TEST-LANE-INITIALIZATION-CORRECTION`
- Predecessor HEAD: `ec19dedda147eb8561fb88f79eb319d2d03e9cc6`
- Predecessor before migration: staged `0`, unstaged tracked `53`, untracked `54`
- Target SOURCE: `C:\Projekti\OPC_v1.5\source`
- Target branch: `codex/opc-v1.5-clean-baseline`
- Target base HEAD: `ec19dedda147eb8561fb88f79eb319d2d03e9cc6`
- Predecessor remained read-only and was not reset, cleaned, restored, stashed or normalized.

## Reconciliation boundary

The existing reconciliation was continued; it was not restarted.

- Included current paths: `83`
- Category A accepted product source: `45`
- Category B accepted current tests/fixtures: `28`
- Category C current repository/control docs: `8`
- Category D required project/build configuration: `2`
- Excluded Category E generated/reproducible outputs: `4`
- Excluded Category F local forensic/control docs: `20`
- Category G obsolete/stale: `0`
- Category H unresolved: `0`
- Predecessor-target equivalence: `83/83 PASS`
- Missing target paths: `0`
- Hash mismatches: `0`
- Manifest: `docs/OPC_V1_5_CLEAN_BASELINE_MANIFEST.csv`
- Manifest SHA-256: `91E47033568646083D9A6B68E85C9C075829EB806F9D7DF5639DCF95504E524A`

The manifest is ignored by the generic repository `*.csv` rule and must be
staged explicitly. No excluded REVIEW, runtime-data, audit, cache or forensic
content is part of the baseline.

## Validation evidence

- Dependency state: `flutter pub get --offline` — PASS; no dependency upgrade
- Flutter lane: Flutter `3.41.7`, Dart `3.11.5`, JDK `21.0.10`
- Analyzer: `flutter analyze --no-pub` — PASS, exit `0`; `No issues found! (ran in 59.6s)`
- Full suite: `flutter test --no-pub --concurrency=1` — PASS, exit `0`; `549 passed, 10 skipped, 0 failures`
- Windows build: `flutter build windows --release` — PASS, exit `0`
  - Artifact: `C:\Projekti\OPC_v1.5\source\build\windows\x64\runner\Release\OPC.exe`
  - Timestamp: `2026-09-18T21:50:32.2233688+02:00`
  - Size: `89600` bytes
  - SHA-256: `19281A7394918312367A920947F08823CE46BE558158F8CE8FCA7A1DF45AF3AB`
- First Android attempt: execution incomplete; no success/failure marker; not accepted as build evidence
- Android retry: `flutter build apk --release` — PASS, exit `0`, duration `141.1s`
  - Artifact: `C:\Projekti\OPC_v1.5\source\build\app\outputs\flutter-apk\app-production-release.apk`
  - Timestamp: `2026-09-18T22:25:18+02:00`
  - Size: `79272487` bytes
  - SHA-256: `3BECAB4499D1D39ADF7FA2DCD425AECF8A1E51C7AF3BB9A12AEBCC4296996897`
  - Current invocation produced the accepted artifact; the identical hash of an earlier artifact does not substitute for this successful invocation.

All Flutter/Dart/Gradle operations were serialized. No arbitrary timeout was
used. No source, test, schema, JSON, dependency or business mutation was made
during execution-lane recovery.

## Generated residue

After the successful Android build, no `.kotlin` session file or equivalent
non-baseline untracked generated path remained. Build outputs are ignored and
were not staged. No unresolved generated file was deleted.

## Current-authority transition

The current development source transitions to:

`C:\Projekti\OPC_v1.5\source`

The predecessor SOURCE remains historical/read-only provenance. Post-drift
recovery remains formally closed; synchronized Windows + Android development
continues from this clean-baseline target. Phase 2 has not started and no new
feature, residual or batch is selected by this baseline handoff.

## Engineering-profile and control disposition

- Requirements/traceability: no product requirement was added or changed; the migration preserves the accepted current delta.
- Architecture/data contracts: no schema, database, JSON, transfer or business contract changed.
- Verification/acceptance: analyzer, serialized tests and both release builds completed; runtime acceptance was not created by build success.
- Quality/release: both platform release artifacts are recorded; push/publication remains separately gated.
- Authority: current docs and the prior accepted reconciliation establish the migration boundary; historical REVIEW material was not used as a donor.
- Incidental finding disposition: the prior Android execution-incomplete incident was resolved by the bounded retry; no orphan finding remains.

## Commit note

This handoff is intended to be included in the single local baseline commit
with subject `baseline: establish clean OPC v1.5 source`. The final commit SHA,
parent, staged path set and clean-worktree result are reported by the final
post-commit verification.
