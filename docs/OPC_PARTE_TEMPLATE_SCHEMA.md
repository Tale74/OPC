# OPC PARTE template and draft schema

Current technical schema: `5`.

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

In the normal composer UI the user enters only page width/height, printable-zone width/height and horizontal/vertical safe margins. The origin remains serialized for compatibility but is derived as `(page - zone) / 2`; it is not a regular user control.

Schema 5 adds optional `sourceAspectRatio` to media block specifications. When `lockAspectRatio` is true, reflow uses one uniform scale and malformed legacy rectangles are normalized around their centre before safe-area clamping. Missing explicit text font now resolves to Noto Serif; an explicitly stored Noto Sans value remains unchanged.

The machine-local printer profile is not part of either template or draft schema. Its horizontal/vertical correction translates only PDF blocks, defaults to `0 × 0 mm`, and never changes PREDMET, saved block coordinates or DOCX.

## Canonical render and template-state addendum (2026-07-19)

Legacy/custom template and retained-draft decoding migrates the deceased-name
maximum to `74 pt`; no database schema bump is required. The saved minimum,
maximum and requested size are inputs to one canonical fit pass. The resulting
font size, horizontal scale, resolved single line and fit status belong to the
render plan consumed by preview, PDF and DOCX. Export adapters must not make a
second fit or punctuation decision.

Template identity has three independent meanings: the dialog `selected` ID,
the preparation `active` snapshot ID and the persisted `default` ID for future
preparations. Applying a selected template atomically replaces only the open
preparation's technical snapshot/geometry and invalidates stale preview/export
evidence. It does not implicitly change the persisted default.

Required text IDs are `intro`, `name`, `years`, `death`, `ceremony`,
`mournersHeading` and `mourners`. A missing, empty, failed or duplicate required
block makes PDF and DOCX generation fail explicitly.
