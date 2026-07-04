# OPC Task — PDF Logo Max-Layout Memorandum Correction Report

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- implementation / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no; shared PDF source only, with no platform runner change

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes, limited to the PDF memorandum/logo maximum-layout boundary

Required gate before implementation:
- repository identity / PDF derivative-output boundary / product terminology; passed

## Task identity and protection

- Branch: `task/OPC-PDF-LOGO-MAX-LAYOUT`
- Base commit: `ca9771c505f2f892059e4eb6ab66bd11731a1e84`
- Protected backup/restore baseline: `73108a608abb5f945668df94214742775733f3e0`
- Original backup/restore execution commit: `f8cf1a8d8c583ce34012ff9c58e2b48fd2bed2d1`
- Backup archive: `C:\Projekti\OPC\OPC v.1\BACKUPS\OPC_v1_backup_20260704_0730_before_pdf_logo_max_layout.zip`
- Restore marker: `C:\Projekti\OPC\OPC v.1\RESTORE_POINTS\RESTORE_POINT_20260704_0730_BEFORE_PDF_LOGO_MAX_LAYOUT.md`
- Evidence report: `docs/tasks/OPC_TASK_BACKUP_RESTORE_EVIDENCE_CHECK_REPORT.md`
- Final commit: `HEAD` — immutable hash is recorded in the Codex handoff because a commit cannot contain its own hash

Backup/restore protection for this correction phase was already confirmed as Outcome A and does not need to be repeated.

## Source-learning summary

The previous PDF task changed all six document-specific exporters to delegate
logo rendering to `buildMemorandumLogo`. Fresh inspection confirmed that the
six complete header builders still diverge, but all use that one shared logo
widget:

- PREDMET;
- LISTA;
- NALOG ZA OPREMANJE;
- PREDRAČUN;
- RAČUN;
- SPECIFIKACIJA TROŠKOVA.

The shared widget previously constrained both its parent `pw.Container` and
child `pw.Image` to `96 × 60 pt`, with a 10-point left margin. The image already
used `pw.BoxFit.contain` and right alignment. Therefore the defect was not an
aspect-ratio bug; the bounded allocation was too small.

Each exporter places company name/address/contact/identity in an expanded left
column and the logo in a fixed right-side box in the first header row. LISTA
then renders title and case number; NALOG/PREDRAČUN/SPECIFIKACIJA render a left
title/case block and right date; RAČUN renders `RAČUN BR.` opposite its issue
date; PREDMET renders its title and combined case/export-date/status metadata.

Memorandum height is content-driven by these `pw.Row`/`pw.Column` compositions,
not one shared fixed-height constant. Consequently the logo box height controls
the minimum first-row height when a logo is present, while company metadata can
still make the row taller.

## Exact paths inspected

- `lib/features/predmeti/pdf/memorandum_logo.dart`
- `lib/features/predmeti/pdf/lista_pdf_export.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart`
- `lib/features/predmeti/pdf/predmet_pdf_snapshot_export.dart`
- `lib/features/predmeti/pdf/predracun_pdf_export.dart`
- `lib/features/predmeti/pdf/racun_pdf_export.dart`
- `lib/features/predmeti/pdf/specifikacija_troskova_pdf_export.dart`
- `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_data_builder.dart`
- `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_PDF_MEMORANDUM_HEADER_LOGO_LAYOUT_REPORT.md`
- `docs/tasks/OPC_TASK_BACKUP_RESTORE_EVIDENCE_CHECK_REPORT.md`
- previous PDF task diff from `5e833a2` through `73108a6`

## Diagnosis before fix

Previous 96 × 60 pt logo slot was rejected by Tale as too small.

1. The old box occupied only about 17.5% of the approximately 547-point usable
   A4 width and had 5,760 square points of bounded area. Even with correct
   contain fitting, real logo content—especially source files containing their
   own whitespace—could appear visually weak.
2. Current pages use 24-point horizontal margins, leaving approximately 547
   points. The logo is the fixed right-side member of a row whose company block
   is expanded, so the side can safely receive a larger bounded allocation.
3. The logo side can grow horizontally while leaving the company block ample
   width. A 192-point box plus 8-point separation leaves about 347 points for
   company metadata.
4. Header height must grow for a materially larger logo. The content-driven row
   can safely increase its logo-present minimum from 60 to 120 points without
   introducing a rigid full-header height.
5. The corrected shared maximum box is exactly `192 × 120 pt` for all six
   variants. This doubles both dimensions and quadruples bounded area to 23,040
   square points.
6. `pw.BoxFit.contain` computes the largest proportional image that fits both
   bounds; width and height are never stretched independently.
7. Wide, tall, square, small, large, and transparent images selected through
   PODEŠAVANJA all use the same contain rule. Existing image whitespace is not
   cropped because image processing is outside this task.
8. Both parent and image are bounded to `192 × 120 pt`; right alignment keeps
   them inside their side, while the expanded sibling absorbs remaining width.
9. `Broj predmeta` is intentionally unchanged. It is already below the
   company/logo row, and its variants—including `RAČUN BR.`—do not need movement
   to satisfy the logo allocation.
10. Build, runtime PDF export, representative-logo rendering, and owner visual
    acceptance remain pending.

## Implementation

Changed source path:

- `lib/features/predmeti/pdf/memorandum_logo.dart`

Exact shared values:

- previous maximum box: `96 × 60 pt`;
- new maximum box: `192 × 120 pt`;
- previous company/logo separation: `10 pt`;
- new company/logo separation: `8 pt`;
- fitting: `pw.BoxFit.contain`;
- alignment: `pw.Alignment.centerRight`.

No exporter-specific source file required modification because all six call the
same helper. Both the parent container and image retain explicit maximum width
and height. The effective memorandum/header height increases by 60 points when
the previous company block was shorter than the logo; no body position is
manually offset because the PDF widget layout naturally places body content
after the taller header.

## Business meaning and risk control

The memorandum is the formal company-identity area. The larger allocation makes
the selected company logo materially more credible while leaving all generated
business facts derived from PREDMET and existing finance/data builders.

The principal risks were distortion, clipping, width collision, title/date/case
collision, body overlap, divergent headers, and unintended RAČUN/IPS behavior.
They are controlled by one bounded shared helper, proportional contain fitting,
the existing expanded company column, the separate metadata row, natural header
layout, and no changes to exporter bodies or business data.

## Safe upgrade boundary

The implementation changes only the shared PDF memorandum logo maximum box and
its separation margin. It does not change PDF export selection, filenames,
document set, text, PREDMET, RAČUN/PREDRAČUN/LISTA/SPECIFIKACIJA/NALOG business
logic, finance, IRiU, IPS QR, payer/recipient data, JSON, catalog, packages,
reminders, GDPR, STATISTIKA, STANJE ROBE, Android behavior, Windows runner, or
any unrelated PDF polish.

## Pseudocode / Logos learning layer

Changed documentation paths:

- `docs/OPC_PDF_MEMORANDUM_HEADER_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/tasks/OPC_TASK_PDF_LOGO_MAX_LAYOUT_REPORT.md`

The pseudocode now records shared versus variant-specific header ownership, the
`192 × 120 pt` maximum box, contain fitting, source-image variability, the
content-driven 120-point row minimum, unchanged case-number placement, protected
business content, and pending runtime/visual review. The index now links the PDF
source entry directly to this learning-layer document.

## Validation

- `dart format lib/features/predmeti/pdf/memorandum_logo.dart`: completed; no
  formatting change required. A non-project Dart telemetry write later reported
  an AppData access error; it did not alter source or invalidate Flutter checks.
- First `flutter analyze`: timed out after 120 seconds with no result; not counted
  as a pass.
- Repeated `flutter analyze`: PASS — `No issues found!` in 263.3 seconds; zero
  errors, warnings, lints, or info findings.
- `flutter test`: PASS — all 110 tests passed in approximately 1 minute 14
  seconds of test-reported time (139.3 seconds wall time).
- Manifest gate: PASS — one changed task report validated against base commit
  `ca9771c505f2f892059e4eb6ab66bd11731a1e84`.

No test failure or analyzer finding required a correction.

## Build/runtime and visual status

- Windows build: not run; deferred by owner decision.
- Android build: not run; prohibited unless explicitly approved.
- Runtime validation: not run; deferred by owner decision.
- PDF export/generation: not run.
- PDF visual review: not performed.
- Visual acceptance: not claimed.

Exact status:

`SOURCE/TEST PASS — BUILD DEFERRED BY OWNER DECISION — PDF VISUAL REVIEW REQUIRED LATER`

The owner must later review generated PDFs using representative wide, tall,
square, transparent, and whitespace-bearing logos. Source-level dimensions and
automated tests do not prove the final visual result.

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

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes; shared PDF memorandum logo sizing only

If not compliant, classify:
- not applicable

PASS / NOT PASS:
- PASS
