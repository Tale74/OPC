# OPC PDF Memorandum/Header Pseudocode

Status: Logos learning layer for the source-confirmed PDF export/header structure.

## Export flow

```text
WHEN a user selects a PDF action on PREDMET:
    predmet_screen calls the matching document exporter
    exporter reads PREDMET and the document-specific related data
    exporter prepares document data and creates its own PDF page/body
    exporter builds its own memorandum/header
    IF FirmaPodaci contains logo bytes:
        header delegates logo rendering to buildMemorandumLogo
    exporter saves the PDF through the shared KORICE export utility
```

The six standard exporters in this layout group are PREDMET, LISTA, NALOG ZA
OPREMANJE, PREDRAČUN, RAČUN, and SPECIFIKACIJA TROŠKOVA. Each exporter owns
its page and header composition. They do not share one complete header builder.

## Shared identity rows

```text
PDF remains a derivative of PREDMET and settings data

buildMemorandumIdentityRows receives PIB, MB and account values
    omit an empty value
    return each present value as a separate row, in this order:
        PIB <value>
        MB <value>
        Račun <value>

each of the six duplicated headers renders every returned entry
as its own PDF text widget
never join PIB, MB and Račun with a separator
always spell Račun with the Serbian diacritic
```

Only identity-row text construction is shared. Complete header composition
remains exporter-owned, as do document title, date, case number and body.

## Shared memorandum logo

```text
FirmaPodaci.logo stores optional image bytes selected in PODEŠAVANJA

IF logo bytes exist:
    reserve one shared 192 x 120 point maximum logo box
    keep 8 points of separation from company text
    scale image proportionally with contain fit
    align image to the right inside the slot
ELSE:
    render no logo slot
```

Before this correction, callers supplied separate 72–76 point widths and
52–56 point heights, while the helper also added a 12-point left margin. The
small fixed slots constrained the image even when the memorandum row had more
available space. The maximum-layout correction below supersedes that moderate
allocation.

## Document-specific title metadata

```text
LISTA:
    company memorandum + logo
    title, then Broj predmeta
    no date in header

NALOG ZA OPREMANJE / PREDRAČUN / SPECIFIKACIJA TROŠKOVA:
    company memorandum + logo
    left block = title, then Broj predmeta
    right block = document date

RAČUN:
    company memorandum + logo
    left block = "RAČUN BR: <brojPredmeta>"
    right block = issue date

PREDMET:
    company memorandum + logo
    title
    metadata line = Broj predmeta + export date + status
```

`Broj predmeta` was intentionally not moved. RAČUN uses it as part of its
established title, PREDMET combines it with status/date metadata, and LISTA has
no matching date column. A uniform move is not required for the maximum-layout
correction and remains outside its safe scope.

## Protected boundary

This correction changes only the shared logo display slot. It does not change
the PDF export set, filenames, document text, title/date/case-number semantics,
PREDMET/IRiU/finance data, IPS QR content/layout, calculations, JSON, saving, or
runtime flow. PDFs remain derived outputs; PREDMET remains master business
truth.

## Maximum-layout correction

The previous shared `96 x 60` point slot was rejected as visually too small.
The new `192 x 120` point box doubles both dimensions and provides four times
the bounded area. On A4 pages with the current 24-point side margins, it uses
about 35 percent of the approximately 547-point content width and leaves the
expanded company block about 347 points after the 8-point separation.

The helper constrains both its parent container and image to the maximum box.
`contain` chooses the largest proportional rendering that fits both bounds, so
wide, tall, square, small, large, and transparent source images remain inside
the box without stretching, squashing, or clipping. Whitespace already inside
the selected image remains part of the image; this layout does not crop or
process it.

All six exporters call the same helper. The first memorandum row naturally
grows from a 60-point to a 120-point minimum when a logo exists. Title, date,
and case-number blocks remain in their separate document-specific row, so
`Broj predmeta` is intentionally not moved. No fixed full-header height is
introduced; longer company text can still determine a greater row height.

Source-level layout and automated tests do not establish visual acceptance.
Windows/Android build, runtime PDF export, and owner review of representative
wide, tall, square, transparent, and whitespace-bearing logos remain pending.

The identity-row correction does not change logo bounds, PREDMET/IRiU/catalog
truth, finance or totals, RAČUN legal/business meaning, JSON, or DOKUMENTI
navigation.
