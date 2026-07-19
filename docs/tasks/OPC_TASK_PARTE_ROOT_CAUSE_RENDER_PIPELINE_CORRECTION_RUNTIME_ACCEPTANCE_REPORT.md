# OPC task — PARTE root-cause render pipeline correction and runtime acceptance

Date: 2026-07-19

Branch: `task/OPC-PARTE-ROOT-CAUSE-RENDER-PIPELINE-RUNTIME-ACCEPTANCE`

Base SHA: `dd641e5002dd6c02102919cc968f15e6876944b4`

Final SHA: pushed branch HEAD (assigned by Git after this report is staged)

## Scope and audit order

The two supplied task texts were byte-identical duplicate pastes, not separate
tasks. Source, supplied PDF/DOCX/JSON, screenshots and A5/Letter photographs
were audited before code changes. Private runtime documents and photographs
remain outside Git.

## Root causes

The missing PDF name was reproduced in isolation. The old adapter placed a
natural-width `pw.Text` inside `pw.Column -> pw.Transform`; when that natural
line exceeded the box, layout could silently emit no text. The exporter had no
required-block postcondition.

The DOCX contained mourners XML, but every absolute VML textbox lived in its own
ordinary anchor paragraph. Those paragraphs consumed normal document flow and
pushed later positioned blocks beyond the effective page. The name also used an
exporter-specific smaller-font approximation instead of the canonical scale.

The life-years em-dash survived in retained legacy draft text, while only one
export path attempted a replacement. The template dialog initialized to the
first/built-in item and conflated selected, active and persisted-default state.

## Old and corrected render flow

Old flow:

`draft -> preview-specific fit / PDF transform / DOCX approximation`

Corrected flow:

`PreparationState -> CanonicalRenderPlan -> PreviewAdapter | PdfAdapter | DocxAdapter`

The canonical plan now owns resolved lines, bounds, font size, horizontal scale,
fit status, visibility/export eligibility and media ratio. Adapters do not
change business text, fit or punctuation. Export validation rejects duplicate,
missing, empty or failed required blocks.

Required text blocks are: intro, name, years, death, ceremony,
`mournersHeading` and mourners.

## Typography and output

- Built-in and migrated name limits accept a maximum of `74 pt`.
- Name fit is single-line and lossless: bounded horizontal compression followed
  by bounded font reduction; impossible fit blocks export.
- Life years are normalized to an en-dash before adapters.
- PDF uses a low-level horizontal text-scale operation after canonical fitting,
  preserving both visual scale and extractable spaces.
- DOCX keeps one zero-flow anchor paragraph, page-relative editable textboxes
  and page-relative Behind Text media anchors. Both mourners blocks are required.
- A one-cell-table-inside-textbox pilot was not retained because its independent
  benefit could not be established while another live Word session prevented
  automation SaveAs/export even for a newly created reference document. The
  already Word-validated editable textbox representation remains.

## Template state and UI

`selected` is the dialog choice, `active` is the snapshot applied to the current
preparation and `default` is the persisted choice for future preparations.
Selecting, applying and setting default are separate operations. Applying a
template atomically updates only technical layout/style and invalidates stale
preview/export evidence.

The command panel is denser and responsive: full format labels wrap safely,
font size has a synchronized decimal input plus A−/A+ controls, and exceptional
printer explanations use an on-demand info affordance. A follow-up runtime
correction removed the permanent page/zone/guide/reader legend above the
preparation and added top padding so the first `Uvodna fraza` floating label is
not clipped. Placement guide lines remain editor-only and never enter PDF/DOCX.

## Calibration analysis

Owner geometry remains outer page `224 × 170 mm`, centered print zone
`175 × 115 mm`, derived origin `24.5/27.5 mm` and safe inset `5 × 5 mm`.
The safe inset narrows the print zone; it is not already included in 175 × 115.
A5 and Letter findings demonstrate driver/media mapping differences and cannot
be converted into a global application offset. Recommended procedure is custom
224 × 170 media, Actual size / 100%, OPC correction initially 0/0, followed by
measured center-axis correction stored only in the machine-local printer profile.

Follow-up physical evidence established a usable `Letter + Actual size` result
for the tested HP LaserJet M207-M212 PCLm-S path with `+25 mm` horizontal and
`+4 mm` vertical correction. This value is not a global constant. Local profile
schema 2 associates corrections with active template IDs; the legacy single
profile migrates to the template active on first load. Applying an unassociated
template or using another machine safely resolves to `0/0`, while portable
template JSON remains hardware-independent.

## Evidence and validation

- Focused domain/PDF/DOCX suite: 32 PASS.
- Focused PARTE UI suite: 2 PASS.
- Synthetic real PDF: exact 224 × 170 mm; full extractable one-line name,
  en-dash and all required blocks.
- Synthetic DOCX package: full name, canonical scale and all required blocks;
  stable short-name Word 16 render previously confirmed both mourners blocks.
- Formatter: PASS.
- `flutter analyze --no-pub`: PASS, no issues, 34.0 s.
- `flutter test --no-pub`: PASS, 242 PASS + 1 skipped, 0 failed, 18:51.
- Windows release build: PASS in 186.6 s; `OPC.exe` SHA-256
  `32172CD5C2760D5A222A949A0F03C8BCE431D76E7F42A9155B6C2312A84B8F39`.
- Windows runtime electronic smoke: PASS; release process stayed alive,
  responsive and exposed title `OPC ORGANIZATOR POGREBNE CEREMONIJE`.
- Word 16 smoke: PASS. Long synthetic DOCX opened read-only without repair;
  Word exposed 9 shapes. Object-model line evidence was: full name 1 line,
  years 1 line with en-dash, `Ožalošćeni:` 1 line and mourners 1 line. A prior
  isolated open/save/reopen/render of the same stable textbox structure also
  confirmed both mourners blocks. Additional automated PDF export was not used
  because the owner's already-open Word session blocked all secondary SaveAs
  operations, including an unrelated new reference document.
- Android release build: PASS in 801.5 s; APK 76,762,706 bytes, SHA-256
  `57E550F0866CE2A4AD0AF1514576C042E14760D09A3E67ACA6D985C035C75977`.
- Android narrow smoke: NOT AVAILABLE; `flutter devices` found only Windows and
  Edge, with no connected Android device/emulator.
- Owner physical print: PASS for the tested Letter / Actual size path with the
  machine-local `+25/+4 mm` profile; this is evidence for that printer/media
  path, not a portable or globally hardcoded default.

## Privacy, manifest and repository hygiene

No supplied personal PDF, DOCX, JSON or photograph is staged. Synthetic outputs
are generated under ignored `tmp/`. Source and documentation are UTF-8.
`git diff --check` passes. GitHub visibility and post-push clean-worktree state
are confirmed by the final task handoff.

Manifest: four authoritative documentation updates, this task report, seven
PARTE production files and three focused test files. Build artifacts stay
ignored and are not committed.

Current status: `PARTE ROOT-CAUSE PIPELINE CORRECTION PASS – PREVIEW/PDF/DOCX
ELECTRONIC PARITY PROVEN – TESTED LETTER PHYSICAL PRINT PASS`.
