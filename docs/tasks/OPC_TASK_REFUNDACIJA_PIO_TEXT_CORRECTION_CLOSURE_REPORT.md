# REFUNDACIJA PIO text correction — formal closure

**Date:** 2026-10-01
**Status:** `REFUNDACIJA PIO TEXT CORRECTION — FORMALLY CLOSED`

## Accepted result

The PODEŠAVANJA → REFUNDACIJA PIO static explanatory block now presents the
OWNER-approved instruction:

> Unesite iznos naknade pogrebnih troškova preko Republičkog fonda za penzijsko i invalidsko osiguranje (PIO fond) za tekući period.

This is a bounded text-only UX correction. The old explanatory checklist was
removed. The refund amount input, formatting, `SAČUVAJ`, persistence/storage,
eligibility predicates, FINANSIJE behavior, database/schema, JSON and
backup/restore behavior remain unchanged.

`REFUNDACIJA PIO TEXT CORRECTION — PASS`
`BUSINESS LOGIC — UNCHANGED`

## Source and tests

The accepted implementation/test scope is limited to:

- `lib/features/podesavanja/presentation/podesavanja_screen.dart` — the
  existing PIO static presentation hunk;
- `test/podesavanja_screen_smoke_test.dart` — the PIO test hunk and its
  required Material import.

The test verifies the exact instruction, absence of the old explanatory text
and predicate literals, and retention of the amount field, currency display
and save action. No additional product source change was made during closure.

## Accepted technical and runtime evidence

- Focused test: `6 passed / 0 failed`.
- `flutter analyze --no-pub`: PASS.
- Full serialized suite: `602 passed / 9 skipped / 0 failed`.
- Windows release build: PASS.
- Android production release APK build: PASS; APK SHA-256
  `AD43E7114BF65A4C22B69D6FB68F2BEF91A355B8370ABF9ADC06BDA7A14BBC6`.
- `LOGOS INDEPENDENT REVIEW — PASS`.
- `OWNER RUNTIME ACCEPTANCE — PASS`.

The Logos result and runtime acceptance above follow the later OWNER
attestation. The older accepted handoff ZIP
`C:\Projekti\OPC_v1.5\REVIEW\CURRENT_TASK\REFUNDACIJA_PIO_TEXT_CORRECTION_20261001.zip`
is preserved byte-for-byte at SHA-256
`93918FFC1EDF35E30F2CB82CD41B2C4299CCEC4A74E4E1854D0946DCFBD1B224`;
its earlier `PENDING` labels remain historical and were not rewritten. The
Android build used the existing debug-signing configuration and does not claim
store signing or general release readiness. Product QA was not rerun for this
documentation-only closure.

## Active-source and mixed-worktree controls

The active-source package integrity is `7/7 PASS`; the protected baseline
remains `28/28 PASS`. None of the accepted PIO source/test paths or closure
documentation paths is a protected baseline row, so no rebaseline was
required. No donor was used.

The worktree contained 23 pre-existing Direction 2 paths. Closure staging
selected only the PIO presentation/test hunks and this task's documentation;
all unrelated Direction 2 hunks and paths were excluded and retained. No
staging, commit or push is claimed by this task report until verified by the
repository state at task completion.

Current-state summary: `docs/OPC_CURRENT_DEVELOPMENT_STATE.md`.
Quality/release evidence: `docs/OPC_QUALITY_RELEASE.md`.
