# OPC task report – PARTE final runtime print, guides, DOCX and media corrections

## OPC MANIFEST CHECK — TASK START

- Manifest read: YES – `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`.
- PREDMET remains the sole business authority: YES.
- PARTE remains retained derived technical state: YES.
- PDF remains authoritative and DOCX secondary/editable: YES.
- Unrelated modules, licensing and canonical database policy unchanged: YES.

## Scope and Git base

- Branch: `task/OPC-PARTE-FINAL-RUNTIME-PRINT-GUIDES-DOCX-MEDIA-CORRECTIONS`
- Base: `d3f120553a6ef95ab3497c929f7dc43dede58f88`
- Scope is limited to PARTE source, focused tests and authoritative PARTE documentation. PREDMET, KATALOG/IRiU, PODSETNIK, licensing and unrelated modules are unchanged.

## Mandatory pre-implementation audit

The supplied calibration, PDF, DOCX, template JSON, screenshots and physical-print photographs were inspected locally and were not copied into the repository. All three supplied PDFs have an exact `224 × 170 mm` MediaBox/CropBox. The A5 and Letter results therefore prove printer-driver/page-profile origin, hard-margin and centring differences; they do not prove a wrong OPC page box. The accepted evidence is the latest A5/Letter set and the custom-page PDFs. The withdrawn earlier print is rejected.

The schema-4 JSON stored page size, absolute zone origin `24.5/27.5`, zone `175 × 115`, safe margins `5 × 5` and media rectangles that could be non-proportional despite `lockAspectRatio=true`. Preview/PDF shared absolute page coordinates. DOCX used VML text and page anchors, but media were `behindDoc=0`, stretched to block extents, and the supplied document contained an em dash. The template dialog exposed duplicate apply/update meanings.

## Implemented corrections

- Normal format entry contains only page, zone size and safe margins. X/Y are derived by centring and omitted from the collapsed summary.
- A resettable machine-local printer profile stores horizontal (`- left / + right`) and vertical (`- up / + down`) correction. It translates all PDF blocks as one layer and does not enter PREDMET, draft/template JSON or DOCX.
- Calibration retains the exact custom page and adds both axes, horizontal/vertical measurement marks, known measure and Actual Size / 100% instructions.
- Editor-only safe-left, centre and safe-right guides are shown. Exact neighbouring alignments show contextual guides; drag and 1 mm controls use a mild 1.5 mm snap.
- Noto Serif is the default only when no explicit font exists. Explicit Noto Sans persists. PARTE semantic em dashes were replaced by en dashes.
- Typography is compacted into one font/size row and separated from block geometry controls.
- Template management has one `PRIMENI ŠABLON` action, state-aware default status, save-as-new, confirmed update for user templates, protected built-in actions and separate import.
- Schema 5 records optional media source ratio. Import normalizes around block centre; zone reflow uses one scale; legacy malformed locked media is repaired without continuing distortion.
- PDF and preview keep aspect-contained media. DOCX computes the same contained media rectangle, uses page-relative movable anchors with Behind Text, and applies an equivalent one-line name-fit transform without truncation or wrapping.

## Electronic evidence

- Focused domain/PDF/DOCX tests: PASS before final gate; includes centred zone, profile persistence/reset, locked-ratio reflow, explicit font preservation, custom PDF and valid OOXML.
- Synthetic Word 16 smoke: PASS. One page opened without repair, full synthetic name was visible, two media shapes reported WrapFormat `5` (Behind Text), save/reopen retained two media shapes and their ratios.
- Supplied real/private runtime artifacts remain local and untracked.

## Final validation and builds

Executed successively after the documentation/code freeze:

1. Formatter: PASS for the task files. Current SDK proposed unrelated legacy formatting; those accidental out-of-scope edits were reverted before validation.
2. `flutter analyze --no-pub`: PASS, `No issues found!`, exit 0.
3. Complete `flutter test --no-pub`: PASS, `All tests passed!`, 238 tests plus one skip, exit 0, about 19 minutes.
4. `flutter build windows --release --no-pub`: PASS, exit 0, `build/windows/x64/runner/Release/OPC.exe`.
5. `flutter build apk --release --no-pub`: PASS, exit 0, `build/app/outputs/flutter-apk/app-release.apk`, 73.1 MB.

An initial full suite exposed one new widget fixture timeout. It was not accepted as PASS. The cause was a real temporary-directory future inside Flutter fake async; the fixture now uses an in-memory printer-profile store. The isolated widget test, repeated analyze and repeated complete suite all passed before either build began. Earlier command timeouts/tool crashes were diagnostic only and are not acceptance evidence.

## Acceptance boundary

Electronic custom-page and Word status can pass independently of the owner printer. A5/Letter are driver evidence only. Final physical print on the actual `224 × 170 mm` form and Android runtime remain owner validation and are PENDING until explicitly confirmed.

Final qualified status:

`PARTE FINAL CORRECTIONS IMPLEMENTED – ELECTRONIC OUTPUT PASS – OWNER PHYSICAL PRINT ACCEPTANCE PENDING`

## OPC MANIFEST COMPLIANCE — TASK END

- Manifest compliance checked: YES – implementation, tests, documentation and generated outputs preserve the declared authority and scope boundaries.
- PASS / NOT PASS: PASS – clean analyze, complete tests, both release builds and Word 16 electronic smoke passed; physical print and Android runtime remain explicitly pending owner confirmation.
