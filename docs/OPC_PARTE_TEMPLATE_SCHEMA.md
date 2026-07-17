# OPC PARTE template and draft schema

Current template and retained-draft schema version: `4`.

## Geometry

- `widthMm`, `heightMm`: physical outer PDF/page dimensions.
- `printableZoneXmm`, `printableZoneYmm`: zone origin from the outer page top-left.
- `printableZoneWidthMm`, `printableZoneHeightMm`: actual printable form area.
- `horizontalMarginMm`, `verticalMarginMm`: safe inset inside the printable zone.
- block `rect`: absolute outer-page millimetres. A valid block is wholly inside the zone after safe inset.

There is no implicit centering. A centered owner profile may be entered explicitly, but it is not printer truth. Changing geometry reflows blocks from the old safe rectangle into the new safe rectangle once and clamps them there.

## Compatibility

Schema 1–3 lacks printable-zone fields. It migrates as `X=0`, `Y=0`, zone width/height equal to the legacy page. Existing coordinates, fonts, media references and margins are preserved. This avoids a double offset. Template transfer schema `3` accepts older transfer versions and emits schema-4 template content.

Malformed zones, unsupported future versions, duplicate block IDs and blocks outside the safe rectangle are rejected with a clear format error.

## Typography

Supported embedded render families are `NotoSans` and `NotoSerif`; unknown legacy values safely fall back to Noto Sans. Noto Serif is distributed under its committed OFL licence. Microsoft proprietary fonts are not bundled.

## Output authority

Preview and PDF consume the same render plan. Calibration visualizes the outer page, printable zone and safe inset. DOCX is secondary and uses Word-compatible editable positioned objects; it does not replace the PDF authority or physical-print acceptance.
