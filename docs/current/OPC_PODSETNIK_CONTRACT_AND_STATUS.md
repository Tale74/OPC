# PODSETNIK / URNA-PEPEO Contract and Status Separation

## Current Stage C status overlay

The latest OWNER-authorized presentation correction removes the botanical
section-label pattern completely from `NALOG CVEĆARI`; no substitute decoration
is introduced. The sage/ivory-green label palette and all accepted business,
item, image, ribbon and pagination semantics remain unchanged. `P2-VIS-005`
and `P2-VIS-006` are preserved. Final GUI acceptance is closed for NALOG
CVEĆARI; broader Phase 2 review remains pending.

The `P2-VIS-001/002` presentation-only refinement remains technically
complete. The separately authorized `P2-VIS-004/005/006` correction is now
implemented and renderer-verified; `P2-VIS-003` remains viewer-state-only.
No business contract, PODSETNIK semantics or other Phase 2 capability was
changed. `P2-GAP-003` is final-owner accepted for the NALOG CVEĆARI scope.

**Status:** `LOCKED BUSINESS CONTRACT / AS-BUILT STATUS UNDER REVIEW`

## Contract

The locked business contract requires an applicable URNA/PEPEO obligation
immediately, with secondary semantic reminders allowed only after the `+3`
activation threshold. `KREMACIJA` and `KREMACIJA_EKSPRES` are in scope and
`NAKNADNO` is excluded. The same semantic wording is required in the
PODSETNIK surface and notification body; raw stable keys are implementation
identities, not user-facing text.

The placement parent label is `POLAGANJE URNE`, except the `RASIPANJE_PEPELA` semantic branch, whose parent label is `RASIPANJE PEPELA`. Missing cemetery text uses the exact fallback `Groblje za polaganje urne nije uneto`.

## Core PODSETNIK model

PODSETNIK derives operational obligations from the current PREDMET. PREDMET
remains the sole business truth; PODSETNIK is not an independent parallel
business-data model. Obligations derive from current PREDMET and current IRiU
state and concern selected unfinished obligations where applicable. There is
no generic `Završi predmet` obligation. Business completion and notification
delivery are separate concepts.

## Ceremony header

For a concrete PREDMET, the first PODSETNIK information is the concrete
ceremony type with its date and time. It appears above `OBAVEZE I NAPOMENE` and
is informational, not a checkbox. Use the actual ceremony type, never a
generic `Ceremonija`. The UI separator is the en dash `–`; the em dash `—` is
not used as that separator.

## OBAVEZE I NAPOMENE

`OBAVEZE I NAPOMENE` is the shared section title. The same grouped-obligation concept is used by the PODSETNIK UI and LISTA PDF. LISTA PDF always prints empty checkboxes. Obligations may be atomic or hierarchical/grouped; a grouped
parent becomes completed when all applicable children are completed and may
act as `označi sve`. Atomic obligations have only their main checkbox.

## Confirmed obligation contracts

### OPELO

With `OPELO = NE`, the priest-responsibility selector is hidden and no priest
notification obligation exists. With `OPELO = DA`, show
`Obavestiti sveštenika = DA/NE`. `DA` creates the FIRMA obligation
`Obavestiti sveštenika`; `NE` creates no FIRMA priest-notification obligation.
Where applicable, the OPELO group contains `Obavestiti sveštenika` and
`Spremiti komplet za opelo`. `Obavestiti sveštenika` is one operational step
and includes confirmation. Group completion follows the hierarchical checkbox
semantics. Desktop may place compact OPELO and priest-responsibility controls
side-by-side; Android narrow layout reflows them vertically.

### PARTE

PARTE has one atomic obligation, `Spremiti parte`, with no child checklist.

### OPREMA

OPREMA is category-driven by the presence of current PREDMET IRiU items in
category `OPREMA`. It creates one atomic obligation, `OPREMA`, with manual
completion and the assistance shortcut `Nalog za opremanje`. Generating that
document does not complete OPREMA. Concrete article names are not hard-coded as
obligation rules.

### CVEĆE

CVEĆE is category-driven by current IRiU items in category `CVEĆE`. It creates
one atomic obligation, `CVEĆE`; individual flowers are not separate completion
obligations. The assistance shortcut is `Nalog cvećari`, and generation/export
does not complete CVEĆE. Each current CVEĆE IRiU item has its own ribbon-text
field tied to current item membership. Removing the item removes its active
ribbon field; re-adding the same article later creates a new current event and
previously removed text must not reappear automatically. Blank ribbon text is
valid, and current IRiU order controls order where relevant.

### SLIKA and CRNINA

SLIKA is category-driven and creates one atomic checkbox-only obligation:
`SLIKA`, with no invented child actions. CRNINA is category-driven and creates
one atomic checkbox-only obligation: `CRNINA`.

### Financial / PIO / pension

Only the following confirmed combinations are current:

- If `Penzioner Republike Srbije` is inactive, there is no corresponding PIO
  consequence. If active, Segment 8 exposes
  `REFUNDACIJA PIO U KORIST FIRME = DA/NE`; when it is `DA` and FIRMA is
  responsible, the obligation is exactly `Predati zahtev`.
- If `Vojni penzioner = DA` and `Posmrtna pomoć = DA`, the obligation is
  `Predati zahtev`.
- If `Vojni penzioner = DA` and `Vojne počasti = DA`, the obligation is
  `Obavestiti nadležnu službu`.
- If `Penzioner Republike Srbije = DA` or `Vojni penzioner = DA`, and marital
  status is `OŽENJEN` or `UDATA`, family-pension right may be relevant. With
  `REFUNDACIJA PIO U KORIST FIRME = DA/NE`, if payer/family handles the path
  there is no FIRMA checklist obligation, only a general note; if FIRMA is
  responsible, the FIRMA obligation is `Predati zahtev`.

No unconfirmed financial combination is added.

### International / reception

`Sahrana van Srbije = DA` creates `Spremiti međunarodna dokumenta`.
`Doček posmrtnih ostataka = DA` creates `Preuzeti posmrtne ostatke`.

### STANJE ROBE

When a shortage relevant to the concrete PREDMET exists, the obligation is
`Razreši stanje robe`. It is available to global PODSETNIK and is printed in
LISTA where applicable.

### BIOHAZARD and NAPOMENA

BIOHAZARD is informational/general-note content, not a checklist obligation.
Segment 7 `NAPOMENA` and PODSETNIK `Napomena` use the same
`PREDMET.napomena`; there is no parallel note truth.

## Overview bar

The latest OWNER rule supersedes older post-ceremony-only and numeric-count
variants: show relevant PARENT obligations generally, without a numeric count.
The exact zero state is `OBAVEZE ISPUNJENE`. On Windows it is on the left side
of the PREDMET row, below the case number. Older variants are historical and
not current contract.

## Complete URNA/PEPEO contract

### Applicability and existence

The contract applies to `KREMACIJA` and `KREMACIJA_EKSPRES` when
`TIP POLAGANJA URNE != NAKNADNO`. The concrete obligation exists immediately
when that trigger is true; `DATUM CEREMONIJE + 3 dana` is never its creation
time. FIRMA operationally organizes the chosen urn placement or ashes
scattering as derived from the PREDMET.

### Completion and the three controlled effects

Completion is manual and may be marked at any time while the obligation exists.
Before +3, completion means the secondary cycle never starts. After the
secondary cycle starts, the same business completion signal must immediately:

1. stop notifications;
2. remove the active unfinished signal; and
3. remove the specific unfinished URNA/PEPEO `ZAVRŠEN` blocker.

The cycle belongs to the concrete unfinished URNA/PEPEO obligation of the
concrete PREDMET. It is not a separate future placement/scattering event and
does not introduce an execution-date field. While this relevant obligation is
unfinished, the concrete PREDMET cannot become `ZAVRŠEN`; this is not a
universal blocker for every unfinished obligation. The blocker is removed only
by completion of this obligation.

### Threshold, location and wording

`DATUM CEREMONIJE + 3 dana` means only the point after which secondary notifications may start if the obligation remains unfinished. It is not an execution date, placement date, scattering date or planned future ceremony date. Use exclusively `GROBLJE POLAGANJA URNE`, never the main `GROBLJE`
field. The missing value is exactly `Groblje za polaganje urne nije uneto`.

`POLAGANJE URNE` and `RASIPANJE PEPELA` are parent/display labels, not extra
`TIP POLAGANJA URNE` enum values. For `GROB`, `GROBNICA`, `KOLUMBARIJUM` and
`ROZARIJUM`, the exact placement body is:

`ZA <Ime Prezime> ZAKAZATI POLAGANJE URNE U <TIP POLAGANJA URNE> NA <GROBLJE POLAGANJA URNE>.`

The exact scattering body is:

`ZA <Ime Prezime> ZAKAZATI RASIPANJE PEPELA NA <GROBLJE POLAGANJA URNE> GROBLJU.`

Titles are exactly `PODSETNIK — POLAGANJE URNE` and
`PODSETNIK — RASIPANJE PEPELA`. The same semantic message is used by the
immediate active PODSETNIK obligation text and the secondary notification body.
It is not stored in `PREDMET.napomena`.

### Cadence and language boundary

Use the existing `deliveryTimes`; there is no new frequency/cadence selector,
no URNA-specific cadence setting and no restored `frequency_hours`. Canonical
business values remain language-neutral. Serbian inflection/grammar belongs to
presentation/localization. Raw keys such as `post.urn_ashes` and
`post.urn_ashes.arrange_placement` are never user-facing.

## As-built trace

The recovered source has:

- a language-neutral stable rule identity `post.urn_ashes.arrange_placement`;
- a future-blocker flag on the atomic placement obligation;
- current-rule/source-fingerprint reconciliation;
- explicit `PredmetiRepository.zavrsiPredmet()` consumption of unfinished URNA/PEPEO blockers;
- separate primary and secondary scheduled ID persistence;
- cancellation before rescheduling and completion-driven deactivation;
- configured `deliveryTimes`, deterministic notification IDs and duplicate-cycle protection through cancellation plus per-session dialog keys;
- Windows in-app startup/resume evaluation and Android gateway scheduling.

These are implementation facts. The bounded Windows runtime evidence also
records the existing in-app startup/login modal for `PREDOJEVIĆ LJUBOMIR`;
Android scheduling is not used as Windows evidence. `WINDOWS SECONDARY DELIVERY`
is a non-correction re-acceptance item and is recorded separately from the
eight-capability correction denominator.

## Status language

`URNA/PEPEO business contract je zaključan; implementation, runtime acceptance, release i publication status moraju se voditi zasebno prema stvarno završenom stanju.`

## Stage B status — contract unchanged

The OWNER-authorized Stage B correction is limited to the `NALOG CVEĆARI`
presentation artifact. It does not change the locked PODSETNIK/URNA/PEPEO
business contract, completion semantics, reminder cadence, obligation
projection or `WINDOWS SECONDARY DELIVERY` classification. The four PDF
artifact findings are resolved at source/test/render level and remain
separate from runtime, release and publication status.

## Phase 2 artifact-review status (contract unchanged; historical pre-correction wording)

The preceding paragraph records the pre-correction artifact-review state.
The current bounded correction status is recorded in the current-state
addendum below and does not alter the locked business contract wording. The
other seven capabilities are not reopened.

Cancellation evidence alone does not prove the `ZAVRŠEN` blocker. The blocker is separately source-traceable through the repository hook described above; a future implementation correction would still require targeted tests, analyzer, full suite, build and runtime evidence under a separately authorized task.

## Complete PODSETNIK surface

The current candidate covers the common model/header and the sections
`OBAVEZE I NAPOMENE`, OPELO, PARTE, OPREMA, CVEĆE, SLIKA, CRNINA,
financial/pension, international/reception, STANJE ROBE, BIOHAZARD note and
NAPOMENA. The latest OWNER overview-bar rule is current-authoritative; old
overview/task prose is not. The confirmed financial/pension wording is
`Predati zahtev`.

The core model separates PREDMET-derived obligations, completion state,
delivery configuration and presentation text. `enabled` controls delivery;
`deliveryTimes` controls configured slots. There is no frequency selector and
no `frequency_hours`. Completion is independent from generating a PDF or
opening a document action.

## Phase 2 runtime status (separate from contract)

The URNA/PEPEO business contract above is `CONFIRMED` and unchanged. Phase 2
runtime evidence is recorded separately:

- semantic wording for existing PREDMET `PREDOJEVIĆ LJUBOMIR` and disposable
  test PREDMET `PHASE2 TEST URNA` was consistent with the contract;
- manual completion persistence was observed as `completed = 1`;
- the corrected UI completion hook persists the same completion signal and
  invokes the existing reminder cancellation/deactivation path;
- `TEST URNA PHASE2` remained completed after reopening and LISTA displayed
  `OBAVEZE ISPUNJENE`;
- the protecting UI test passed, while the separate `ZAVRŠEN` blocker remains
  repository-derived through `PredmetiRepository.zavrsiPredmet()`;
- `P2-DEF-001` is therefore an implemented correction candidate, not a new
  business rule.

The automated coordinator and UI protecting tests are technical evidence. The
runtime screenshots establish completion persistence and the LISTA projection;
they do not convert the business contract into implementation authority.

## Exact URNA/PEPEO presentation contract

The only placement location is `GROBLJE POLAGANJA URNE`. If it is absent the
exact fallback is `Groblje za polaganje urne nije uneto`. Parent labels are
`POLAGANJE URNE` and `RASIPANJE PEPELA`; titles are `PODSETNIK — POLAGANJE
URNE` and `PODSETNIK — RASIPANJE PEPELA`. The same semantic wording is used
in the PODSETNIK and notification body. Canonical values/rule IDs remain
language-neutral, with grammar/localization handled at presentation; raw keys
are never user-facing.

The exact canonical semantic forms are:

- placement: `ZA <Ime Prezime> ZAKAZATI POLAGANJE URNE U <TIP POLAGANJA URNE> NA <GROBLJE POLAGANJA URNE>.` for `GROB`, `GROBNICA`, `KOLUMBARIJUM` or `ROZARIJUM` only;
The canonical scattering template above is the only exact OWNER contract. The
fallback substitutes `Groblje za polaganje urne nije uneto` for the location
value. These templates are semantic output; they do not add a future execution
date to the +3 reminder.

## Document-action contracts

`OPREMA → Nalog za opremanje` and `CVEĆE → Nalog cvećari` are derived
document actions. For `NALOG CVEĆARI`, the OWNER contract is PDF-only,
PREDMET-truth based, excludes broj predmeta and quantity, uses generation date,
deceased/dynamic ceremony data, and the exact ceremony labels `Datum:` and
`Vreme:`. It uses current IRiU CVEĆE
order, optional/blank `TEKST TRAKE`, catalogue/article image with preserved
aspect, and the shared PDF identity/helper, font, geometry and motif. It does
not complete CVEĆE. The bounded current path provides the exporter, document
action, route and UI path; blank and non-empty `TEKST TRAKE` outputs were
generated and visually reviewed. The business contract remains unchanged.

## Status separation

| Layer | Status |
|---|---|
| Business contract | Locked where directly authorized; unresolved meaning remains OWNER DECISION REQUIRED |
| Source implementation | Traceable for listed recovered paths only |
| Tests | Evidence of technical characterization, not business authority |
| Windows/Android runtime | Artifact/platform-specific observations only |
| Release/publication | Separate gates; not implied by current candidate |

## Current-state synchronization addendum — 2026-09-04

The locked PODSETNIK/URNA-PEPEO contract is unchanged. The current Cvećari
technical state includes the shared memorandum/header/footer and typography
correction, ceremony grammar correction, sage/ivory-green labels, removed
three-dot treatment, no botanical ornament, rendered flower images and row
ribbon values without the literal `TEKST TRAKE`.

The four bounded PDF technical findings remain closed as GUI evidence. Current
status is `P2-GAP-003 — IMPLEMENTED / AUTOMATED QA PASS / TECHNICAL ARTIFACT
PASS / FINAL OWNER VISUAL ACCEPTANCE PASS — NALOG CVEĆARI SCOPE`. `P2-VIS-003` remains
`VIEWER-STATE CAUSE INDICATED — NO OPC ARTIFACT CORRECTION AUTHORIZED`;
`P2-VIS-004/005` are implemented with renderer evidence and `P2-VIS-006` is
corrected with renderer evidence. Full detail and hashes are in
`REVIEW_EVIDENCE/P2_VIS_004_006_CORRECTION_EVIDENCE.md`. Broader Phase 2
review remains pending. P2-RUN-001 is separately resolved as Codex sandbox desktop
isolation, while current Computer Use `apps=[]` remains a tooling state. No
business contract semantics changed.

Current presentation synchronization: `P2-VIS-004` is implemented and
renderer-verified with no decoration, `P2-VIS-005` retains the inset-safe image
frame and value-only ribbon output, and `P2-VIS-006` remains preserved. This is
not a business-contract change. The bounded evidence is
`REVIEW_EVIDENCE/P2_VIS_007_DECORATION_REMOVAL_EVIDENCE.md`; OWNER GUI export
and NALOG CVEĆARI acceptance are now closed; broader Phase 2 acceptance remains pending.

## Final NALOG CVEĆARI documentation closure — 2026-09-05

The final accepted output is PDF-only. `PREDMET` remains the sole business and
content source of truth; `NALOG ZA OPREMANJE` is only a visual comparator.
The final GUI artifact is the two-page export
`C:\Users\Steva\Downloads\KORICE\PREDMET_PROBNI_040926_2318_NALOG_CVECARI_v1.pdf`
with SHA-256
`6257C3BB1E082EFA7CE043DED059753D5DD0725F8E8D0EF61D00250E3795551A`.
The later page count reflects added CVEĆE items in the same PREDMET. The
accepted presentation has sage/ivory-green labels, no botanical or replacement
decoration, value-only ribbon output and one coherent name/value/image block
per current CVEĆE item.

`NALOG CVEĆARI CLOSED — BROADER PHASE 2 OWNER REVIEW STILL PENDING`.
