# OPC PARTE Print-Preparation, Template and Media-Lifecycle Audit

> HISTORICAL AUDIT EVIDENCE — `SUPERSEDED` AS ACTIVE POLICY where this report
> leaves format, margins, retention, deletion, or output authority open. The
> later locked authority is `OPC-OD-STAGE1-UNRESTRICTED-PARTE-003`: configurable
> page width/height, separate horizontal/vertical margins, retained reopenable
> and editable completed preparation with reproducibility media until explicit
> user deletion, authoritative WYSIWYG PDF, and optional editable DOCX. Observed
> `224 × 170 mm` reference-document measurements remain factual historical
> evidence only and must not drive implementation.

## 1. Audit contract

This is an audit and source-learning document. It does not authorize or implement a printable PARTE feature, photograph import, media deletion, symbol assets, schema fields, JSON changes, PDF generation, printing, entitlement changes or UI controls.

Classification vocabulary:

- `CURRENTLY IMPLEMENTED` — proven in current source.
- `PARTIALLY IMPLEMENTED` — a related field or capability exists, but the required print-preparation behavior does not.
- `ABSENT` — no current PREDMET/source capability was found.
- `DERIVED` — calculated from authoritative PREDMET facts.
- `FREE TEXT` — user-provided text without a structured grammar model.
- `OWNER PROPOSAL — AUDIT ONLY` — direction supplied for analysis, not approved behavior.
- `AUDIT RECOMMENDATION — OWNER DECISION REQUIRED` — evidence-based recommendation, not authorization.
- `OWNER DECISION REQUIRED` — implementation must not choose silently.

The master rule is unchanged:

```text
PREDMET = authoritative business truth
PARTE = derivative print-preparation and public-display output
preview / PDF / image / printed sheet = derivative artifact
```

## 2. Evidence and privacy boundary

Evidence inspected:

- exact repository base `de9b41abbc6c0adce5a82d9b69cfd484134f7589`;
- current PARTE, PREDMET, CEREMONIJA, PDF, JSON, anonymization, entitlement, media picker, storage and platform source;
- both owner-supplied DOCX references, one male and one female;
- existing OPC symbol assets and their package metadata;
- relevant manifest, owner decisions, pseudocode, workflow and prior audit documents.

Both DOCX files were read directly from the owner's local reference folders. They were not copied into Git. No personal name, family relation, photograph, local owner path or other extracted personal content is reproduced in this public report. Matrix examples are deliberately sanitized.

The attempted hidden Word render produced no artifact and was stopped. Template findings below come from direct OOXML structure, media, relationship, page, paragraph, run, drawing and compatibility-layer inspection of both files. No print action was performed.

## 3. Executive findings

1. Current PARTE is not only a transient preview. It persists symbol ID, script, title/profession/rank/name-display flags, nickname settings and mourners through PREDMET fields.
2. Current PARTE still has no standalone print-ready poster, photograph, real rendered symbol, PARTE PDF/image export, print preview or direct printing action.
3. LISTA PDF contains a text-only PARTE panel on its second page; PREDMET PDF snapshot lists raw PARTE fields. Neither is the reference poster.
4. The same composition logic is duplicated in `parte_segment.dart` and `lista_pdf_data_builder.dart`, creating drift risk.
5. Current generated text omits `časova` after ceremony/opelo/send-off times even though source comments claim sentence formatting; both references print `časova`.
6. `parteIme` is stored, serialized, used by section-progress logic and shown in the raw snapshot, but the current PARTE segment neither edits nor consumes it.
7. Both DOCX references use one shared visual skeleton with content and grammatical variants, not two fundamentally different layouts.
8. Their page is a custom landscape format of approximately `224 × 170 mm`, not A4. Margins are approximately `25 mm` on all sides.
9. Their name line uses Times New Roman 58 pt bold inside a no-wrap, fit-to-cell table. This can silently compress a long public name and is not a safe future overflow policy.
10. The reference photograph is a portrait image placed without OOXML crop. One supplied image is adequate for the displayed print size at 300 DPI; the other is materially below 300-DPI resolution.
11. The same symbol image is embedded in both DOCX files and is byte-identical to current `assets/simboli/Svetosavski.png`.
12. Current OPC symbol UI lists seven IDs, but only two individual symbol assets exist. Preview and LISTA show a label, not the asset. Unknown IDs receive no review warning.
13. Current PREDMET has no photo blob, photo path, app-owned media ID, crop metadata, template ID, generated PARTE artifact or generation state.
14. Current anonymization deliberately leaves names visible and also leaves `ozaloseni`, symbol and all current PARTE text untouched. Future photo/artifact handling is therefore an unresolved privacy decision.
15. `OpcModule.advancedParte` and its add-on exist, but the current PARTE section is not gated by that module. Future packaging is an owner decision; downgrade must never delete PREDMET-owned data.

## 4. Owner-reference DOCX analysis

### 4.1 Shared document structure

Both files have:

- one page;
- custom landscape page size `12699 × 9638` twips, approximately `224 × 170 mm`;
- margins of `1417` twips, approximately `25 mm`;
- one borderless single-cell name table;
- one portrait photograph;
- one symbol image;
- floating text boxes/shapes for introductory phrase, years/profession, narrative and mourners;
- Cyrillic Serbian content;
- the same shape names, paragraph IDs and broad positioning scheme;
- the same embedded cross asset.

The evidence supports: **one shared layout with grammatical and conditional content variants**. It does not prove that one template will satisfy every future PARTE form. A future engine must support a stable `templateId` and `templateVersion` even if the first implementation has one layout.

### 4.2 Content differences

| Element | Male reference | Female reference | Finding |
|---|---|---|---|
| Introductory phrase | masculine form | feminine form | grammatical branch |
| Death sentence | masculine verb | feminine verb | grammatical branch |
| Profession/title line | populated | absent | conditional line |
| Ceremony secondary sentence | OPELO | ISPRAĆAJ | source-condition branch |
| Name | includes an additional familiar name | includes an additional name | current `srednje`/`nadimak` choices need explicit owner mapping |
| Mourners | populated free text | populated free text | sensitive free text, variable wrapping |
| Photograph | portrait | portrait | same role, different source resolution |
| Symbol | same cross | same cross | reference evidence only, not universal default |

Fixed layout text includes the mourners label, the connective ceremony wording, `godine`, `časova` and the selected OPELO/ISPRAĆAJ phrase family. Variable content includes public name, optional profession/title, life years, death date, ceremony day/date/time, cemetery, secondary-event time, mourners, photograph and symbol. The masculine/feminine introductory and death phrases are fixed variant text selected by grammar, not arbitrary document-local identity truth.

### 4.3 Typography and placement

- Name: Times New Roman, 58 pt, bold.
- Profession/title and life years: approximately 20 pt.
- Introductory phrase and narrative: approximately 18 pt.
- Mourners: normal-style text, centered, materially smaller than the name.
- Name table: `noWrap` plus `fitText`.
- Mourners and narrative use fixed-size floating text boxes; at least one text-box body declares no automatic fit, so long text can overflow or clip rather than reflow the complete page safely.
- Photograph display size: approximately `40 × 52 mm` in the female form and `44 × 56 mm` in the male form.
- Symbol display size: approximately `20 × 27 mm`.
- Photograph and symbol are separate anchored images around the name/introductory area; neither is an inline text glyph.
- Images use aspect locking and no explicit OOXML crop rectangle.
- Text is laid out through absolute/floating Word objects, not a simple sequential document flow.

OOXML contains duplicated textual payloads inside Microsoft `AlternateContent` Choice/Fallback representations. Word renders one compatible branch; the text is not intended to print twice. A naive DOCX parser or template filler can nevertheless extract or replace the same logical content twice.

### 4.4 Media evidence

| Evidence | Female reference | Male reference | Consequence |
|---|---:|---:|---|
| Main PNG | `843 × 1089`, RGBA, about 1.37 MB | `194 × 245`, indexed PNG, about 30 KB | source sizes vary greatly |
| Additional photo encoding | none found | WDP compatibility image present | DOCX compatibility complexity |
| Symbol PNG | `102 × 136`, RGB | `102 × 136`, RGB | same byte-identical asset |
| Explicit crop | none | none | future crop behavior is not defined by these files |

At the observed display sizes, roughly `472 × 612` to `522 × 659` pixels are needed for 300-DPI output. The smaller male PNG is below that target and requires a visible low-resolution warning; it must not be silently upscaled and described as print-quality.

## 5. Current PARTE source map

### 5.1 UI and persistence

`lib/features/predmeti/presentation/segments/parte_segment.dart` currently:

- selects a symbolic ID from seven textual options;
- selects Latin or Cyrillic script;
- edits title and whether it appears before the name;
- edits profession and whether it appears;
- conditionally includes military rank;
- includes or omits middle name;
- edits nickname, visibility and placement;
- edits mourners as four-line free text;
- generates an inline centered text preview;
- saves those decisions to PREDMET after an 800-ms debounce.

Persisted fields are in `lib/core/database/tables/predmeti_table.dart`. Preview text itself is not stored. Controller values before debounce and the generated preview string are temporary UI state.

The symbol is rendered only as `[ textual label ]`. No asset is loaded in PARTE. There is no photo control, template choice, page preview, validation/preflight or export action.

### 5.2 Current field classification

All `Predmeti.*` storage fields in the table below are defined at the exact path `lib/core/database/tables/predmeti_table.dart`. Their current edit paths are `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart` for identity/death/status, `lib/features/predmeti/presentation/segments/ceremonija_segment.dart` for ceremony, and `lib/features/predmeti/presentation/segments/parte_segment.dart` for PARTE choices. Current generated text is also duplicated at `lib/features/predmeti/pdf/lista_pdf_data_builder.dart`.

| Required concept | Current classification | Exact source field/path | Notes |
|---|---|---|---|
| First name | `CURRENTLY IMPLEMENTED` | `Predmeti.ime`, `predmeti_table.dart` | authoritative identity input |
| Surname | `CURRENTLY IMPLEMENTED` | `Predmeti.prezime` | authoritative identity input |
| Middle/additional name | `CURRENTLY IMPLEMENTED` | `Predmeti.srednje`, `srednjeNaParti` | explicit display flag |
| Nickname | `CURRENTLY IMPLEMENTED / FREE TEXT` | `nadimak`, `nadimakNaParti`, `nadimakCrtica` | quoted or dash placement |
| Sex/gender | `CURRENTLY IMPLEMENTED / PARTIAL GRAMMAR MODEL` | `pol` (`M`/`Z`) | defaults to `M`; unknown/conflicting grammar fallback absent |
| Date of birth | `CURRENTLY IMPLEMENTED` | `datumRodjenja` | full date stored |
| Date of death | `CURRENTLY IMPLEMENTED` | `datumSmrti` | full date stored |
| Life years | `DERIVED` | `_izvuciGodinu` / `_extractYear` | partial values currently permitted |
| Profession | `CURRENTLY IMPLEMENTED / FREE TEXT` | `zanimanje`, `zanimanjeNaParti` | edited from PARTE segment |
| Title | `CURRENTLY IMPLEMENTED / FREE TEXT` | `titula`, `titulaIspred` | no structured inflection |
| Military rank | `CURRENTLY IMPLEMENTED / CONDITIONAL` | `cin`, `cinNaParti`, `vojniPenzioner` | shown only for current condition |
| Cemetery | `CURRENTLY IMPLEMENTED` | `groblje` | title-cased in preview |
| Ceremony type | `CURRENTLY IMPLEMENTED` | `vrstaCeremonije` | mapped to a public label |
| Ceremony date | `CURRENTLY IMPLEMENTED` | `datumCeremonije` | weekday derived |
| Ceremony time | `CURRENTLY IMPLEMENTED` | `vremeCeremonije` | current sentence omits `časova` |
| OPELO yes/no | `CURRENTLY IMPLEMENTED` | `opelo` | source-condition branch |
| OPELO place | `CURRENTLY IMPLEMENTED / PARTIAL GRAMMAR` | `opeloMesto` | predefined locatives only |
| OPELO time | `CURRENTLY IMPLEMENTED` | `vremeOpela` | current sentence omits `časova` |
| Send-off time | `CURRENTLY IMPLEMENTED` | `vremeIspracaja` | used only when OPELO is not DA |
| Mourners/family | `CURRENTLY IMPLEMENTED / FREE TEXT` | `ozaloseni` | highly identifying; no print length preflight |
| General note | `CURRENTLY IMPLEMENTED / NOT PARTE INPUT` | `napomena` | must not be silently promoted into public text |
| PARTE display-name override | `PARTIALLY IMPLEMENTED / ORPHANED` | `parteIme` | stored/JSON/progress/snapshot only; not edited or read by current PARTE composition |
| Symbol ID | `PARTIALLY IMPLEMENTED` | `simbol` | stored selection; no image mapping in PARTE output |
| Script | `CURRENTLY IMPLEMENTED` | `pismo` | Latin-to-Cyrillic transliteration |
| Deceased photograph | `ABSENT` | no PREDMET field | catalog/logo media models are unrelated precedents |
| Crop parameters | `ABSENT` | none | no crop UI/model |
| Template/variant ID | `ABSENT` | none | no layout identity/version |
| Generated PARTE artifact | `ABSENT` | none | no reference, timestamp or regeneration state |

### 5.3 Derived text and free text

Derived today:

- masculine/feminine introductory phrase;
- display-name composition;
- life years;
- masculine/feminine death sentence;
- Serbian month and weekday;
- ceremony-type sentence;
- OPELO versus ISPRAĆAJ sentence;
- selected predefined OPELO locatives;
- Latin-to-Cyrillic transliteration.

Free text today:

- title;
- profession;
- rank;
- middle name;
- nickname;
- cemetery and non-predefined OPELO place values;
- mourners.

The future print artifact must derive from stored PREDMET facts plus explicit PARTE display choices. It must not store a second authoritative copy of ceremony facts.

### 5.4 Current platform behavior

Windows and Android use the same PARTE widget, fields, save path and composition logic. `_ParteFieldWithDecision` stacks field and decision vertically below 620 px. The containing PREDMET workspace is scrollable and has a separate narrow Android navigation path.

Remaining narrow risks:

- the PISMO segmented control has no dedicated wrap/vertical path;
- nickname-position segmented labels are long;
- a future image crop, symbol gallery and page preview would materially increase height and action density.

These are audit findings, not current runtime failures proven by this task.

## 6. Current output capability

| Capability | Current state | Evidence |
|---|---|---|
| Inline PARTE text preview | `CURRENTLY IMPLEMENTED` | `parte_segment.dart` |
| Real symbol preview | `ABSENT` | label only |
| Photograph preview | `ABSENT` | no PREDMET media |
| Standalone PARTE PDF | `ABSENT` | no exporter/action |
| Standalone PARTE image | `ABSENT` | no renderer/exporter |
| Print preview | `ABSENT` | no `PdfPreview`/equivalent use |
| Direct physical print | `ABSENT` | `printing` package registered but no `Printing.*` source call found |
| Page-format selection | `ABSENT` | no PARTE layout model |
| Existing PDF generation | `CURRENTLY IMPLEMENTED` | six operational PDF exporters use `package:pdf` |
| Font embedding | `CURRENTLY IMPLEMENTED FOR EXISTING PDFs` | bundled Noto Sans regular/bold/italic variants |
| Image embedding | `CURRENTLY IMPLEMENTED FOR FIRM LOGO` | `pw.MemoryImage`, `memorandum_logo.dart` |
| PARTE text in LISTA PDF | `CURRENTLY IMPLEMENTED` | page-two text panel, textual symbol label |
| PARTE raw fields in PREDMET snapshot | `CURRENTLY IMPLEMENTED` | raw symbol/script/parteIme/mourners rows |
| Windows KORICE save/open | `CURRENTLY IMPLEMENTED` | Downloads/app-documents helper and Explorer open |
| Android Downloads/KORICE save/open | `CURRENTLY IMPLEMENTED` | MediaStore/native channel |
| Reusable PARTE layout component | `ABSENT` | composition duplicated between UI and LISTA builder |

## 7. Field-to-template matrix

Personal examples are sanitized by design.

| Printed element | Male form example | Female form example | Current PREDMET source | Transformation/grammar | Missing data | Safe fallback | Proposed ownership | Sensitivity | JSON/anonymization impact |
|---|---|---|---|---|---|---|---|---|---|
| Introductory phrase | masculine phrase | feminine phrase | `pol` | gender-sensitive branch | unknown/conflicting gender | block final generation or require explicit reviewed phrase; never default silently | derived PARTE rule from PREDMET | personal/public | current JSON has `pol`; anonymization leaves it |
| Full name | sanitized male full name | sanitized female full name | `ime`, `srednje`, `nadimak`, `prezime`, title flags | ordered composition | no reliable public name | visible blocker; no blank/synthetic name | PREDMET inputs, PARTE display choices | direct identifier | already in JSON; names survive current anonymization |
| Title/profession | profession present | absent | `titula`, `zanimanje`, flags | optional line/order | empty or too long | omit only when explicitly not selected/empty; warn overflow | PREDMET-scoped PARTE choices | identifying | already in JSON; currently retained |
| Life years | sanitized year range | sanitized year range | birth/death dates | derive year | one or both missing | owner must choose partial range, omission or block; do not invent | derived | identifying | dates in JSON; birth date currently redacted on anonymization |
| Death sentence | masculine verb | feminine verb | `pol`, `datumSmrti` | gender + Serbian date | missing/invalid date or gender | require review/block public generation | derived | identifying | source fields in JSON |
| Ceremony sentence | funeral/day/date/time | funeral/day/date/time | type/date/time | ceremony label + weekday/date/time | any key fact missing | show specific missing-data blocker; do not generate malformed sentence | derived | sensitive schedule | fields in JSON; retained on anonymization |
| Cemetery | cemetery name in sentence | cemetery name in sentence | `groblje` | case/wording unresolved | missing or unsuitable grammatical form | explicit review; no guessed inflection | PREDMET fact + PARTE grammar | sensitive location | in JSON; retained |
| OPELO sentence | OPELO/time | absent | `opelo`, place/time | conditional branch | OPELO DA but missing time/place | warn/block based on owner-required fields | derived | sensitive schedule/religion | in JSON; retained |
| Send-off sentence | absent | ISPRAĆAJ/time | `opelo`, `vremeIspracaja` | inverse condition | OPELO changed to NE or time missing | regenerate from current facts; stale sentence never retained | derived | sensitive schedule | in JSON; retained |
| Mourners | sanitized family text | sanitized family text | `ozaloseni` | free text and wrapping | empty/too long | owner decides omission vs blocker; never truncate silently | PREDMET-scoped PARTE free text | highly identifying third-party data | already JSON; not currently anonymized |
| Photograph | portrait | portrait | absent | user-controlled crop/normalization needed | absent/corrupt/low resolution | explicit no-photo layout or blocker per owner decision | future PREDMET-owned media reference | biometric/highly identifying | new transfer/anonymization policy required |
| Symbol | same cross | same cross | `simbol` | stable ID to audited asset | missing/unknown/deleted ID | visible warning; no silent substitution | PREDMET symbol ID; app asset catalog | religion-sensitive inference risk | ID already JSON; asset/provenance separate |

## 8. Grammar and text-generation audit

### 8.1 Current rules

- `pol == Z` produces `Naša voljena` and `preminula je`; every other value produces `Naš voljeni` and `preminuo je`. Both pairs are directly confirmed by the female/male references.
- `SAHRANA`, `KREMACIJA`, `SMESTAJ_URNE` and `RASIPANJE_PEPELA` map to public labels.
- OPELO DA uses OPELO; otherwise a non-empty send-off time produces ISPRAĆAJ.
- Serbian month genitive and weekday are calculated from stored date text.
- predefined OPELO locations have explicit locatives; arbitrary text is only title-cased.
- Cyrillic output transliterates the complete generated text, including user free text.

### 8.2 Gaps and conflicts

- Binary `M/Z` is not sufficient as an automatic safety fallback for missing, invalid, disputed or non-standard public wording.
- Defaulting all non-`Z` values to masculine can publish grammatically wrong text.
- Current UI and LISTA builders duplicate the grammar code.
- Current sentence output omits `časova`; both references include it.
- Current cemetery form is `na groblju <name>`; references use `<adjectival cemetery name> groblju`. Arbitrary Serbian case conversion cannot be guessed safely.
- Current generated ceremony text inserts a comma after weekday; references use a different punctuation pattern.
- Transliteration can alter foreign names, abbreviations and deliberately Latin-script content. Public output needs explicit user review.
- Current preview's local weekday calculation should use strict date validation; malformed imported dates must not roll into another date.
- Missing birth/death year can create a partial dash line; owner policy is absent.
- Missing ceremony time can produce a syntactically incomplete sentence.
- Long content has no line-count or one-page preflight.

`AUDIT RECOMMENDATION — OWNER DECISION REQUIRED`: one shared, testable PARTE composition service should own text generation for UI preview and every derivative artifact. It must return structured lines plus validation warnings, not only a final string.

## 9. Symbol audit

Current facts:

- PREDMET already stores a per-PREDMET symbol ID.
- Options include Orthodox, Roman Catholic, Islamic, Jewish, no-symbol and free-choice concepts.
- Default is currently `PRAVOSLAVNI_KRST_SVETOSAVSKI`.
- Assets folder contains `Svetosavski.png`, `DavidStar.png` and a five-symbol strip.
- Only the first two are individual image assets.
- `Svetosavski.png` is `102 × 136`, RGB, with no declared DPI/transparency.
- `DavidStar.png` is `374 × 410`, RGBA.
- the strip is `668 × 140`, RGB, about 300 DPI, but is not a stable individual-symbol catalog.
- the reference cross equals the current Svetosavski asset byte-for-byte.
- current PARTE does not map IDs to images.

Future catalog requirements:

- stable non-personal symbol ID;
- display label and category;
- asset path/format/version;
- print dimensions and minimum effective resolution;
- transparency/background behavior;
- monochrome/color policy;
- provenance, copyright and license note;
- active/deprecated state without reusing IDs;
- explicit `BEZ_SIMBOLA` behavior;
- future Web-portable asset packaging.

No symbol may be inferred from sex. The cross in the references is evidence for those forms only, not a universal default.

Fallbacks:

- no selected symbol: owner must decide whether generation is blocked or an explicit no-symbol layout is allowed;
- unknown/deleted ID: show a persistent review warning and do not substitute another symbol;
- unavailable asset on one platform: business state remains, generation fails safely and points to the missing asset;
- free-choice: cannot remain an unstructured label if it is expected to render an asset.

## 10. Photograph storage-model comparison

Existing OPC media precedents are not PARTE implementations:

- catalog article import uses Android `ImagePicker` gallery with quality 85 and 1600-pixel bounds, while desktop uses `FilePicker` limited to JPG/JPEG/PNG;
- catalog photographs are stored as SQLite BLOBs and full-backup base64;
- firm logo import uses `FilePicker` and stores raw bytes as a BLOB;
- `KatalogPhotoPolicy` defines decode-size guidance and aspect-ratio-safe preview behavior.

These prove that shared byte-backed media and platform-specific selection are possible. They do not provide crop ownership, atomic failure handling, PREDMET media transfer, deletion, anonymization or print-quality guarantees.

| Model | Advantages | Risks/cost | Regeneration | Transfer/backup | Audit assessment |
|---|---|---|---|---|---|
| A — original inside PREDMET/app storage | maximum source preservation | large DB/backups, original metadata/privacy, no normalization guarantee | strong | binary must transfer | viable only with explicit size/privacy policy |
| B — normalized app-owned copy | bounded size, orientation/crop fixed, external original untouched | needs managed ownership, atomic import and cleanup | strong while copy exists | relative media identity + bytes/sidecar required | strongest technical foundation |
| C — temporary only, delete after artifact | minimum retained storage | artifact becomes only photo representation; editing/new template/regeneration lost | weak/none | artifact-only mismatch | unsafe as default |
| D — retain until explicit user deletion | clear control and regeneration | storage persists; deletion needs warnings | strong until deletion | policy required | safe user-controlled option |
| E — hybrid retention | normalized copy while editable, optional explicit finalization/deletion | more states and recovery rules | configurable | policy required | best candidate, not approved |

`AUDIT RECOMMENDATION — OWNER DECISION REQUIRED`: use Model E built on Model B. Keep an OPC-owned normalized copy while PARTE remains editable; expose explicit deletion; optionally allow deletion after an explicit finalized export only if the user accepts loss of regeneration and the artifact is verified.

Do not interpret this recommendation as approval.

## 11. Critical file-deletion boundary

```text
OPC MUST NEVER silently delete or modify the user's original external photograph.
```

Any future automatic deletion may target only an OPC-created, app-owned copy or temporary file. Before any deletion implementation, the owner must decide:

- exact owned file/media object;
- event that permits deletion;
- whether successful generation is enough or explicit finalization is required;
- whether regeneration/editing must remain possible;
- confirmation wording;
- undo/recycle/backup policy;
- failure and interrupted-operation behavior;
- behavior when the generated artifact is later missing.

If an app-owned photo is deleted after generation, OPC loses the prepared source image, crop, ability to reflow another template/size, ability to regenerate after ceremony changes and ability to create a fresh artifact after the exported file disappears. An embedded PDF can remain printable, but it must not become the master PREDMET truth.

Safe operation order for any future approved deletion:

```text
select external original
-> read only
-> validate/decode
-> create app-owned normalized copy atomically
-> persist PREDMET media identity and crop atomically
-> generate artifact to temporary destination
-> verify artifact bytes/page/media embedding
-> atomically publish artifact
-> only then offer explicit deletion of app-owned copy
-> never touch external original
```

## 12. Image-transformation requirements

Owner decisions are required for accepted formats and limits. The safe minimum audit model includes:

- decode-based validation, not extension-only validation;
- JPEG and PNG as baseline candidates; HEIC/WebP support only when proven on both platforms;
- maximum input bytes and decoded-pixel count to prevent memory exhaustion;
- EXIF orientation normalization;
- user-controlled crop with fixed, owner-approved portrait aspect ratio;
- no face recognition or biometric identification;
- optional manual grayscale/brightness/contrast only if owner approves;
- embedded color profile/background policy;
- minimum effective DPI warning based on final print dimensions;
- high-resolution downscale using a defined quality algorithm;
- corruption/unsupported/too-small errors before persistence;
- temporary-file cleanup after interrupted import;
- no logging of personal filename or external path.

The references use portrait ratios near 3:4 but are not identical. They do not by themselves approve a crop ratio.

## 13. Print-layout requirements

Unresolved owner decisions:

- exact paper size: preserve custom approximately `224 × 170 mm`, map to a commercial sheet, or adopt another format;
- portrait/landscape (references are landscape);
- printer-safe margins and bleed;
- one-page invariant;
- target DPI;
- exact photograph and symbol boxes;
- Times New Roman fidelity versus bundled Noto Sans or another licensed font;
- Cyrillic/Latin font coverage;
- long-name size/line strategy;
- profession/title and mourners maximum line strategy;
- missing-photo and missing-symbol reflow;
- permitted whitespace changes between variants.

No printed personal value may be silently truncated, ellipsized or horizontally compressed. The reference `fitText` name cell must be replaced by an explicit preflight strategy: approved line break/size profile or a blocking review warning.

## 14. Output-format comparison

| Format | Fidelity | Windows/Android | Fonts/images | Printing | Regeneration/testability | Future Web | Assessment |
|---|---|---|---|---|---|---|---|
| Generated PDF | high and deterministic | strong shared Dart path | embeddable | reliable through viewer; direct print optional later | strong golden/data tests | strong download artifact | recommended candidate |
| Generated image | fixed visual pixels | strong | flattened | scaling/DPI risks | testable but large/no selectable text | strong display | useful preview/secondary export, not sole master |
| HTML/print surface | browser-friendly | renderer variance | CSS/font differences | print-dialog variance | moderate | strongest native Web fit | not safest first fidelity target |
| DOCX template filling | close to references in Word | weak Android/Word dependency | floating-object complexity | Word-dependent | difficult; duplicate compatibility content | weak | unsuitable as primary cross-platform engine |
| Direct printer canvas | potentially precise | platform-specific APIs/drivers | manual | direct | difficult and hardware-dependent | weak | defer beyond first implementation |

`AUDIT RECOMMENDATION — OWNER DECISION REQUIRED`: generate a deterministic, one-page PDF from a shared data/layout model, save it through existing KORICE infrastructure and initially rely on the OS PDF viewer for printing. An image preview may be derived from the same model. Direct printing should be a separate delivery capability, not shared business state.

## 15. Persistence, JSON and backup candidates

| Candidate | Current state | SQLite need | Single-PREDMET JSON | Full backup | Anonymization | Decision |
|---|---|---|---|---|---|---|
| Symbol ID | exists | keep | already included | already included | currently retained | validate catalog/fallback |
| Title/profession/rank/name flags | exist | keep | included | included | currently retained | public-display policy |
| Mourners | exists | keep | included | included | currently retained | privacy/anonymization decision |
| Photo media identity | absent | likely needed | must transfer if regeneration promised | must transfer | delete/redact policy required | owner decision |
| Normalized photo bytes/file | absent | BLOB or managed relative media | base64/sidecar/package design | binary inclusion | strong deletion requirement | owner/technical decision |
| Crop parameters | absent | needed if non-destructive crop/regeneration | include | include | delete with photo or retain neutral geometry | owner decision |
| MIME/dimensions/hash/version | absent | recommended metadata | include | include | hash sensitivity review | technical design after owner choice |
| Template ID/version | absent | recommended | include | include | non-personal | owner decision |
| Free sentence overrides | absent | not assumed | only if approved | only if approved | may contain personal data | owner decision |
| Artifact reference | absent | optional/cache/audit only | portability risk | policy required | delete/retain decision | must not be authority |
| Generation timestamp | absent | optional audit metadata | decision required | decision required | likely retainable | owner decision |
| Print status/count | absent | no current business meaning | do not add without approval | n/a | n/a | owner decision |

No design may rely only on an absolute Windows path, Android content URI or external gallery path. A cross-device restore must either carry the media or produce an explicit `PHOTO_MISSING_REVIEW_REQUIRED` state without substituting another file.

Current full backup already demonstrates base64 transfer of BLOBs for firm logo and catalog photographs. Single-PREDMET JSON currently contains only PREDMET/IRIU/contact data and no PREDMET media block. Reusing the full-backup precedent does not decide the future PARTE transfer format or acceptable backup growth.

## 16. Anonymization and privacy

Current anonymization in `predmeti_repository.dart`:

- marks status `ANONIMIZOVAN`;
- redacts selected identifiers, addresses and contact data;
- deliberately keeps deceased names visible;
- does not redact `ozaloseni`, title, profession, nickname, cemetery, ceremony facts or symbol;
- has no photo/artifact handling because those concepts do not exist;
- does not manage already exported KORICE artifacts.

Therefore future PARTE media cannot inherit a safe policy automatically.

Owner decisions required:

- delete app-owned photo on anonymization, retain it, or require explicit choice;
- delete/manage app-owned generated artifacts or treat exported KORICE files as user-controlled external derivatives;
- whether mourners must be redacted;
- whether photograph bytes may appear in single-PREDMET JSON/full backup;
- whether media hashes, filenames or paths may enter logs;
- cache/thumbnail/temporary-file cleanup on both platforms;
- behavior when anonymization is partial or disk deletion fails.

A photograph is highly identifying and may contain biometric information. Symbol choice may reveal sensitive religious information. Test fixtures must be synthetic.

## 17. Package and entitlement findings

- Current PARTE section is part of the ordinary PREDMET navigation and is not checked against `OpcModule.advancedParte`.
- `OpcModule.advancedParte` is available to POTPUN or SREDNJI with add-on, but no current PARTE screen/export path consumes that check.
- Current operational PDF actions are broadly available through `operationalDocuments`.

Future photo/symbol/print-preparation packaging is `OWNER DECISION REQUIRED`. Regardless of the decision:

- downgrade may hide/disable actions but must retain PREDMET-owned fields and app-owned media;
- no downgrade may automatically delete a photo;
- an unavailable feature must still preserve safe backup/restore and anonymization handling;
- re-upgrade must recover the same data without guessed reconstruction.

## 18. Required fallback matrix

| Condition | Required safe fallback |
|---|---|
| Missing photograph | explicit no-photo layout or blocking review, owner decides; no placeholder person |
| Corrupt photograph | reject before persistence; keep prior valid app copy; report actionable error |
| Unsupported format | do not import; list supported formats; external original untouched |
| Very small image | show effective-DPI warning; block final print or require explicit owner-approved override |
| Extremely large image | bounded decode/normalization; fail safely before DB/storage exhaustion |
| Missing symbol | explicit review state; owner decides no-symbol permission |
| Deleted/unknown symbol asset | preserve stored ID, warn, do not substitute |
| Missing/conflicting gender | do not default public grammar; require explicit reviewed variant/text |
| Missing birth date/year | owner decides omit/partial/block; never invent |
| Missing death date | block death sentence/final generation or require explicit owner-approved override |
| Missing ceremony date/time | specific blocker; no malformed public sentence |
| Missing cemetery | specific blocker or approved omission; no guessed location |
| OPELO DA→NE | regenerate from current PREDMET; remove OPELO sentence; use send-off only when current data supports it |
| Ceremony rescheduled | invalidate cached preview/artifact; regenerate from current authoritative event; never silently print stale schedule |
| Long name | approved line/size profile plus preview warning; no fit-text squeeze, ellipsis or truncation |
| Long mourners text | measured line/page preflight; require editing/alternate approved layout; no truncation |
| Generation failure | keep media/source state; do not publish partial artifact or mark finalized |
| Disk full | atomic temporary output, cleanup owned temporary file, keep source state |
| Permission denied | preserve source/media; offer another approved destination or retry |
| Interrupted import | do not change PREDMET until normalized copy and metadata are complete; clean owned temp |
| Interrupted export | do not replace prior valid artifact with partial bytes; source remains editable |
| Deleted app-owned image | explicit missing-photo state; existing artifact may open but regeneration is unavailable |
| Generated artifact missing | regenerate only if source media exists; otherwise explicit non-regenerable warning |
| JSON import on another device | restore media by portable identity or mark missing; never use stale machine path |
| Anonymization | execute owner-approved photo/mourner/artifact policy atomically; report deletion failure |
| Package downgrade | preserve all authoritative data/media; disable capability only |
| Android narrow overflow | vertical scrolling/stacking/wrapping; no hidden controls/actions |
| Direct print unavailable | save/open PDF and show clear delivery fallback; business state unchanged |

## 19. Answers to required audit questions

1. **What is implemented?** Persisted PARTE display choices, text composition, inline preview, LISTA text panel and raw snapshot fields.
2. **What existing data fills the forms?** Identity, gender, dates, title/profession/rank/name options, ceremony, cemetery, OPELO/send-off and mourners.
3. **What is absent?** Deceased photograph, crop/media lifecycle, real symbol rendering/catalog completeness, template identity, standalone artifact and print workflow.
4. **What is free text?** Title, profession, rank, nickname, mourners, cemetery and arbitrary OPELO place.
5. **What should remain derived?** Grammar, public name composition, years, weekday/date/time sentences and OPELO/send-off branching from PREDMET.
6. **What grammar exists?** Binary masculine/feminine intro/death forms, ceremony labels, locative mapping, Serbian dates and transliteration; fallbacks are incomplete.
7. **Is one template sufficient?** One shared layout with variants fits these two references; future multiple template IDs/versions must remain possible.
8. **Symbol model?** Stable per-PREDMET ID resolved through a versioned, provenance-documented app asset catalog with explicit no-symbol and missing-ID states.
9. **Photo model?** Normalized app-owned copy with portable identity and crop metadata is the strongest base; hybrid retention is recommended for owner decision.
10. **Can app-owned photo be deleted after generation?** Technically yes, but only after explicit policy/verification and only with accepted loss of regeneration/editing.
11. **What is lost?** Prepared source, crop, reflow, new template/size generation and recovery if artifact disappears.
12. **Must external original remain?** Yes; OPC must never silently modify/delete it.
13. **Safest output?** Deterministic generated PDF, owner decision required.
14. **How preserve regeneration?** Retain normalized app-owned media plus crop/template metadata until explicit approved deletion.
15. **What enters SQLite/JSON?** Existing display fields already do; future media identity/bytes, crop and template version require explicit portable-transfer design.
16. **Anonymization?** Current policy is insufficient for photo/mourners/artifacts; owner decision required.
17. **Downgrade?** Hide capability, preserve all data/media.
18. **Platform differences?** Shared truth/layout; pickers, storage URI/path, viewer/direct print delivery may differ technically.
19. **Owner decisions?** Listed in section 21.
20. **Smallest safe sequence?** Data/decision model → media ownership → deterministic layout → cross-platform UI → fidelity/runtime verification.
21. **Outside first implementation?** Direct printer integration, automatic deletion, multiple complex templates, biometric processing, workflow/completion/PODSETNIK semantics and unapproved package changes.

## 20. Recommended safe implementation sequence

### Phase 1 — Authoritative PARTE data model

- resolve owner queue;
- define existing-versus-new fields;
- define symbol catalog ID and fallback;
- define app-owned photo identity/storage/crop;
- define template ID/version;
- define JSON/full-backup/anonymization/downgrade contracts;
- centralize structured composition and validation results.

### Phase 2 — Media import and preparation

- read external original without modifying it;
- validate, orient, crop and normalize an app-owned copy;
- add storage state, warnings and explicit removal;
- implement symbol catalog with provenance;
- test atomic failures and restart recovery.

### Phase 3 — Print-layout generation

- implement one owner-approved layout with variants;
- embed approved font, photograph and real symbol;
- enforce one-page/no-truncation preflight;
- generate deterministic PDF and optional derived preview image;
- invalidate/regenerate after source changes.

### Phase 4 — Cross-platform UI

- shared edit/validation/preview model;
- Windows picker/storage/viewer delivery;
- Android gallery/storage/viewer delivery;
- narrow vertical scroll/wrap/compact actions;
- explicit photo deletion and regeneration warnings.

### Phase 5 — Runtime and fidelity verification

- synthetic male/female, no-photo, no-symbol, long-name and long-mourners fixtures;
- JSON/full-backup round-trip and cross-device restore;
- anonymization and downgrade;
- restart/regeneration;
- Windows/Android visual parity;
- printer fidelity only in a separately authorized test.

## 21. PARTE owner-decision queue

These are unresolved questions, not owner-approved decisions.

| Queue ID | Decision required |
|---|---|
| `OPC-PARTE-ODQ-001` | Required versus optional printed fields and final-generation blockers |
| `OPC-PARTE-ODQ-002` | One initial shared layout, target paper size and template version policy |
| `OPC-PARTE-ODQ-003` | Public grammar fallback when `pol` is missing/conflicting and whether reviewed phrase override exists |
| `OPC-PARTE-ODQ-004` | Exact punctuation, cemetery wording, `časova`, OPELO/place and send-off text |
| `OPC-PARTE-ODQ-005` | Meaning/removal/migration of orphaned `parteIme` |
| `OPC-PARTE-ODQ-006` | Symbol catalog, default/no-symbol policy, missing-ID behavior and licensing/provenance |
| `OPC-PARTE-ODQ-007` | Accepted photo formats, crop ratio, print DPI, quality thresholds and adjustments |
| `OPC-PARTE-ODQ-008` | Photo storage model: BLOB versus managed file/package and portable identity |
| `OPC-PARTE-ODQ-009` | Retention/deletion/finalization/regeneration policy for app-owned photo |
| `OPC-PARTE-ODQ-010` | SQLite, single-PREDMET JSON and full-backup media transfer limits/format |
| `OPC-PARTE-ODQ-011` | Anonymization of photo, mourners and generated artifacts |
| `OPC-PARTE-ODQ-012` | Standalone output: PDF recommendation, optional image and direct-print boundary |
| `OPC-PARTE-ODQ-013` | Long-content preflight and approved alternate layout/size profiles |
| `OPC-PARTE-ODQ-014` | Package/add-on ownership of future advanced print preparation |
| `OPC-PARTE-ODQ-015` | Generated artifact retention/reference/timestamp and whether print status has business meaning |

## 22. Source paths inspected

- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/core/database/tables/predmeti_table.dart`
- `lib/core/database/tables/katalog_artikli_table.dart`
- `lib/core/database/database.dart` and generated model
- `lib/core/format/app_date_format.dart`, `app_time_format.dart`, `app_text_format.dart`
- `lib/core/utils/json_export_import.dart`, `export_utils.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/predmeti/pdf/` including LISTA, PREDMET snapshot, Noto Sans and logo image embedding
- `lib/features/podesavanja/presentation/katalog_tab.dart`, `katalog_photo_policy.dart`, `podesavanja_screen.dart`
- `lib/features/podesavanja/data/podesavanja_repository.dart`
- `lib/core/entitlements/opc_entitlement_policy.dart`
- `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/com/tale/opc_v4/MainActivity.kt`
- `windows/flutter/generated_plugin_registrant.cc`, `windows/flutter/generated_plugins.cmake`
- `pubspec.yaml`, `assets/simboli/`, relevant current tests and authoritative docs listed by the task
- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`, `docs/OPC_OWNER_DECISION_INDEX.md`, `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md`
- `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`, `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- `docs/OPC_PREDMET_WORKFLOW_ATLAS.md`, `docs/OPC_PREDMET_DEPENDENCY_MAP.md`, `docs/OPC_PREDMET_COMPLETION_STATE_MATRIX.md`
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`, `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`, `docs/OPC_MODULE_CONTRACTS_AND_TRUTH_BOUNDARIES.md`
- relevant existing PDF, JSON, PARTE/CITULJE and PREDMET workflow task reports under `docs/tasks/`

## 23. Final audit classification

The photo storage/deletion policy, symbol fallback, target format, grammar fallback, anonymization and packaging still require owner decisions. Current source and both references are sufficiently reconstructed to make those decisions without implementing prematurely.

`AUDIT PASS — PHOTOGRAPH RETENTION/DELETION POLICY REQUIRES OWNER DECISION — NO IMPLEMENTATION AUTHORIZED`
