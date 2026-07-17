# OPC task report — PARTE printable-zone, PDF, DOCX and composer correction

Date: 2026-07-17

Branch: `task/OPC-PARTE-PRINTABLE-ZONE-PDF-DOCX-UX-CORRECTION`

Base SHA: `e0c48a78d2362c8db5018050480ff3f4f93e1aae`

## Manifest start

Purpose, anti-drift manifest and repository rules were read before implementation. Scope remained PARTE-only; PREDMET authority, completed-preparation retention, eligibility, KORICE policy and unrelated modules were protected.

## Audit and diagnosis

- Existing preview and PDF already consumed the same absolute-page render plan; PDF added no centering, scale or hidden origin transform.
- The old model stored only page width/height and two margins. A `224 × 170` page with large margins globally reflowed and miniaturized the design; it could not express the physical `175 × 115` inner zone or its X/Y feed position.
- Runtime PDFs had exact declared page sizes. The supplied physical prints showed that page-level content could start before the decorative inner frame; printer feed/driver behavior cannot be inferred as an OPC transform.
- Legacy template blocks are absolute page coordinates and dimension changes scale from one usable rectangle into another.
- Only Noto Sans was declared. Noto Serif was obtained from the official Google Fonts repository with OFL licence; Times New Roman was not embedded.
- Life years used em dash.
- Word rejected the old DOCX although its ZIP/XML was parseable: VML referenced undefined `_x0000_t202`, and DrawingML anchor children had an invalid order and omitted `cNvGraphicFramePr`.

## Implementation

- Schema 4 separates outer page, printable-zone X/Y/width/height and safe H/V inset. Legacy schema 1–3 migrates to a full-page zone without moving blocks.
- Reflow maps old safe rectangle to new safe rectangle once. Composer rejects every block outside that rectangle.
- Preview, fingerprint, PDF and calibration share absolute outer-page millimetres. Orange marks the zone and red its safe inset; calibration prints offsets, known measure and Actual-size/Fit warnings.
- UI now says `PREGLED PRIPREME`, uses en dash, offers Noto Sans/Noto Serif, hides persistent min/max/block diagnostics, and makes text/format sections collapsible while leaving designer controls outside.
- PDF selects the block font from bundled assets.
- DOCX uses editable VML rectangles for text and schema-ordered page-relative DrawingML anchors for media, zero page margins for absolute positioning, and actual font-family mapping.

## Tests and editor evidence

- Added schema-4 migration/non-centered-zone bounds tests, en-dash/font persistence tests, narrow collapsible UI coverage and stronger DOCX structure/media assertions.
- Targeted PARTE domain/PDF/DOCX suite passed.
- Narrow composer widget test passed without overflow exception.
- Microsoft Word 16 synthetic post-build smoke passed open, save-as and reopen without repair or Text Recovery. The one-page document contained 8 independent shapes (photo, symbol and text), including 6 editable text shapes and 173 editable text characters.
- Private names, images, screenshots, PREDMET numbers and supplied documents are not committed.

## Acceptance boundaries

- Preview status: implementation/test PASS.
- PDF metadata/geometry status: exact page and shared-plan implementation/build PASS.
- DOCX Word status: synthetic Word open/save/reopen PASS.
- Physical print status: PENDING owner print at Actual size / 100%.
- Android runtime status: PENDING owner/device validation.

## Validation and builds

- focused formatter: PASS, 12 task files unchanged after formatting;
- `flutter analyze`: PASS, exit `0`, `No issues found`;
- complete `flutter test`: PASS, exit `0`, 236 tests plus one skip, `All tests passed`, 25:11;
- Windows release build: PASS, exit `0`, `build/windows/x64/runner/Release/OPC.exe`;
- Android release build: PASS, exit `0`, `build/app/outputs/flutter-apk/app-release.apk`, 73.1 MB;
- Windows implementation smoke: PASS — isolated release EXE launch, narrow widget coverage and Word open/save/reopen;
- Android runtime: PENDING owner/device acceptance.

The first complete-test attempt timed out and left `flutter_tester`; a second attempt exposed a stale `sqlite3.dll` native-assets collision. Neither was counted as PASS. The retained process and generated build state were removed with standard Flutter cleanup, then analyze and the complete test were rerun successively to final exit `0`. The first Android attempt similarly timed out without an APK and was not counted; the repeated build completed with exit `0` and a final APK.

## Changed files and privacy

Changes are limited to PARTE model/composer/repositories, preview/UI, PDF/DOCX adapters, embedded Noto Serif/OFL assets, focused tests and authoritative PARTE documentation. There is no PREDMET/database schema change and no KATALOG, IRiU, PODSETNIK or licensing Stage-2 behavior change. Runtime evidence and smoke outputs remain ignored/local and are removed before commit; no private name, photograph, PREDMET number, supplied document or screenshot is tracked.

## Manifest end, GitHub and worktree

End check confirms the manifest boundary: PREDMET remains authority; PARTE is retained technical state; PDF remains authoritative; DOCX remains secondary; physical print remains owner acceptance. The focused branch is committed and pushed for GitHub visibility, with generated smoke files excluded and a clean worktree required before closure. No merge to `main` is authorized.

Final task status: `PARTE CORRECTION IMPLEMENTED — VALIDATION AND BUILDS PASS — OWNER PHYSICAL PRINT ACCEPTANCE PENDING`.
