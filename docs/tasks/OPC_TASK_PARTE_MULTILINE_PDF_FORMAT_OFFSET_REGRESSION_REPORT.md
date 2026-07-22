# OPC TASK REPORT — PARTE MULTILINE PDF, FORMAT TITLE AND OFFSET REGRESSION

## OPC MANIFEST CHECK — TASK START

- Manifest read: `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- Manifest compliance checked: PREDMET authority, derived PARTE state,
  canonical render-plan parity, machine-local printer profile and public-repo
  privacy remain unchanged.
- PASS / NOT PASS: `PASS`

## Status

`PARTE FINAL TECHNICAL-TEXT UI CORRECTION CLOSED – WINDOWS PRINUĐENI PASS – ANDROID FUNCTIONAL RUNTIME SATISFACTORY – FOLLOW-UP REFINEMENT FINDINGS PENDING`

## Git

- Branch: `task/OPC-PARTE-MULTILINE-PDF-FORMAT-OFFSET-REGRESSION`
- Base SHA: `de708deb81d85d789b2b088a0f706ef4da77bcbb`
- Final/tested SHA: `805ad18865fddb3181bf27e6cfc82d7cfffd5b53`

## Runtime evidence and root cause

The supplied Windows preview, exported PDF, DOCX, template JSON and physical
print were inspected outside Git. The PDF retained only the first canonical
line of `Ceremonija` and `Ožalošćeni`, although preview and the canonical
render plan contained the remaining lines.

The PDF adapter wrapped separately measured one-line widgets in a fixed-height
`Column`. The PDF layout engine clipped later children. This was an adapter
defect, not missing PREDMET data and not a two-line canonical-model limit.

The DOCX evidence also showed an exact-edge one-line name fit risk. Canonical
name fitting now retains a small cross-adapter safety reserve and the DOCX name
uses non-breaking spaces, without truncating or changing authoritative text.

No supplied personal artifact was copied into the repository.

## Corrections

- PDF text rendering uses a deterministic low-level multiline painter.
- The painter iterates the complete `block.lines` list; it has no two-line cap.
- Alignment, font size, horizontal scale and canonical line order are retained.
- `FORMAT I ZONA ŠTAMPE (mm)` no longer has the redundant expanded subtitle.
- The local per-template print correction range is centralized at
  `−100..+100 mm`, replacing the former `−25..+25 mm` clamp.
- Existing printer-profile and portable-template boundaries are unchanged.

## Validation

- Formatter: completed; Dart telemetry emitted a non-fatal local permission
  warning after formatting.
- Focused Flutter tests: `37 PASS`, `0 FAIL`.
- The regression test gives both `Ceremonija` and `Ožalošćeni` three
  canonical lines and proves all three are painted in order.
- Generated synthetic PDF text extraction contains all three lines of both
  blocks.
- Rendered synthetic PDF was visually inspected; all six lines are visible.
- `flutter analyze --no-pub`: the Codex attempt timed out after 5 minutes and
  was correctly not reported as PASS. The owner subsequently reran analyze
  manually to final green completion: PASS.
- OPC manifest gate against the base SHA: `PASS`.
- `git diff --check`: PASS before documentation finalization.
- Owner manual complete Flutter test: PASS / final green completion. Exact
  totals and duration are not asserted without a retained reliable log.
- Windows release build: PASS, manually run after both green gates.
- Android release build: PASS, manually run after the Windows build.

## Privacy and repository hygiene

Runtime files under the user's Downloads/Desktop paths and generated local
smoke artifacts remain outside Git. Tests use synthetic content only.

## Owner Windows/Android runtime closure

- Windows runtime: `PRINUĐENI PASS`.
- Android runtime: `FUNCTIONALLY SATISFACTORY`.
- Android follow-up: `REFINEMENT FINDINGS MATERIAL IN PREPARATION`.
- The previous correction task is closed at its defined objective.
- The former private evidence folder was intentionally removed because it held
  stale, irrelevant findings. Future physical evidence may be recreated there
  only after prior owner notice.
- Future refinements are acknowledged but deliberately unspecified.

`DO NOT START PARTE FOLLOW-UP IMPLEMENTATION UNTIL OWNER FINDINGS PACKAGE IS DELIVERED AND REVIEWED.`

## OPC MANIFEST COMPLIANCE — TASK END

- PREDMET remains the sole business truth.
- The correction is limited to PARTE adapters, local printer-profile validation,
  focused UI text and their tests/documentation.
- No private runtime evidence is committed.
- PASS / NOT PASS: `PASS`
