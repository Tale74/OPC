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

## Shared memorandum logo

```text
FirmaPodaci.logo stores optional image bytes selected in PODEŠAVANJA

IF logo bytes exist:
    reserve one shared 96 x 60 point logo slot
    keep 10 points of separation from company text
    scale image proportionally with contain fit
    align image to the right inside the slot
ELSE:
    render no logo slot
```

Before this correction, callers supplied separate 72–76 point widths and
52–56 point heights, while the helper also added a 12-point left margin. The
small fixed slots constrained the image even when the memorandum row had more
available space. The shared helper now owns one moderately larger size and a
slightly smaller separation margin, so all six headers receive the same narrow
visual correction.

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
no matching date column. A uniform move would not be source-consistent and was
not safe without deferred PDF visual review.

## Protected boundary

This correction changes only the shared logo display slot. It does not change
the PDF export set, filenames, document text, title/date/case-number semantics,
PREDMET/IRiU/finance data, IPS QR content/layout, calculations, JSON, saving, or
runtime flow. PDFs remain derived outputs; PREDMET remains master business
truth.
