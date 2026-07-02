# OPC Task Report - Catalog Article Detail Full-Size Navigation UX

## Task identity

- Required base commit: `0857b70fd002a15dbc51ccbb3377d588bdde4f08`
- Branch: `task/OPC-CATALOG-ARTICLE-DETAIL-FULLSIZE-NAVIGATION-UX`
- Task class: implementation
- Implementation commit: `0573a34b79c59b6885c4eb6bdf30f7c201261a9f`
- Final report metadata is included in the final amended commit.

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes

Task class:
- implementation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- yes, safely: one shared responsive viewer now adapts to available viewport shape and input model without changing product meaning

Future OPC Web affected:
- no

Terminology drift risk:
- no

Implementation allowed:
- yes

Required gate before implementation:
- platform parity

Manifest read: YES

Required source-policy files read before change:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`
- `docs/GIT_WORKFLOW_ARC.md`
- `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`
- `docs/tasks/OPC_TASK_IRIU_CITULJE_CATALOG_PICKER_NOVOSTI_FIX_REPORT.md`

## Source-learning summary and diagnosis before fix

- Grid entry: `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`, `IriuRowTile._otvoriKatalogZaStavku`, resolves picker category keys, loads lightweight article summaries, and opens a Windows dialog or Android modal bottom sheet.
- Category loading/filtering: the same method calls `PodesavanjaRepository.getArtikliZaKategorijuLightweight` once per resolved category. CITULJE resolution remains `CITULJA_POLITIKA` plus `CITULJA_NOVOSTI`; other rows remain scoped to their own category.
- Grid representation: `_ArtikliPickerContent` builds `GridView.builder`; `_ArtiklKartica` shows cached/decoded photograph, title, price, direct `IZABERI`, and photograph tap for detail.
- Old detail preview: `_ArtikliPickerContentState` rendered a `Positioned.fill` overlay inside the grid picker subtree.
- Constraint cause: Windows `_ArtikliPickerDialog` capped the parent subtree at `maxWidth: 680` and `maxHeight: screenH * 0.86`. The nested detail could not exceed that grid-dialog box, regardless of its own responsive calculations.
- Nesting: preview was not a second route/dialog; it was nested inside the grid dialog/bottom-sheet content stack.
- Reusable navigation state: `_ArtikliPickerContent` already owns the complete currently loaded summary list and the tapped article, so it can pass the list and selected index without repository/filter changes.
- Selection return: `_izaberiArtikl` closes the picker and calls the existing callback with `naziv`, `cena`, `stableArticleId`, and `interniNazivKategorije`; `_primeniArtikl` then uses the existing stock confirmation and `azurirajKatalogIzborStavke` path.
- Platforms: Windows and Android share `_ArtikliPickerContent`; only the outer grid container differs. The detail viewer can therefore be shared and branch responsively by available viewport shape.
- Images: summaries carry `hasPhoto`; bytes load lazily through `getKatalogArticlePhotoById`, are future-cached per article id, decoded through `KatalogPhotoPolicy`, and the old preview already used `BoxFit.contain`.
- Keyboard/focus: no catalog-preview keyboard navigation existed. Other app screens use Flutter `Focus`/logical-key handling, establishing the local input pattern.

## Implemented changes

- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
  - Replaced the nested constrained preview with a root-navigator detail dialog.
  - Passed the existing loaded article list and tapped index into local detail state.
  - Sized the dialog from the Flutter application viewport with small insets, so desktop uses nearly all available app-window space and does not use OS taskbar metrics.
  - Kept full image visibility and aspect ratio with `BoxFit.contain`.
  - Added wide/landscape image-plus-info and portrait image-above-info layouts.
  - Preserved title, price, position, close, and `IZABERI` controls.
  - Added visible previous/next mouse/touch buttons and scoped Left/Right keyboard navigation.
  - Kept Escape, barrier close, and Android back on the normal dialog-pop path, returning to the grid.
  - Returns the currently displayed summary on `IZABERI`, then invokes the unchanged selection callback.
- `test/iriu_citulje_catalog_picker_test.dart`
  - Added deterministic previous/next and boundary tests while retaining CITULJE Politika/Novosti coverage.
- Pseudocode documents
  - Added `OPC-PSEUDO-030` and its Logos/safe-upgrade cross-references.

## Business meaning, risk, and safe boundary

The catalog photograph represents real funeral goods/services. A dominant, aspect-preserving image and same-category browsing reduce repeated close/open work while the selected catalog article remains the sole returned business identity.

Blind changes could desynchronize the displayed article from the returned `stableArticleId`, erase a selected source category, distort photographs, hide actions, or regress Android back behavior.

The safe boundary is responsive picker-detail UI and local index navigation only. Catalog data/filtering, IDs, category identity, price semantics, repository behavior, IRiU persistence, PREDMET, finance, PDF, JSON, stock, package/add-on, Web, sync, backend, payment, and licensing are outside the change.

## Pseudocode update

- Exact entry: `OPC-PSEUDO-030 - Catalog article detail viewer full-size display and same-category navigation`
- Updated: `docs/OPC_BUSINESS_CRITICAL_PSEUDOCODE_MAP.md`
- Updated: `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- Updated: `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`

The entry records `source paths -> source behavior -> pseudocode -> business meaning -> risk if changed blindly -> safe upgrade boundary` and explicitly protects current-list navigation and displayed-article selection identity.

## Validation

- `flutter test test/iriu_citulje_catalog_picker_test.dart --reporter expanded`
  - PASS: `+4: All tests passed!`
- `git diff --check`
  - PASS; line-ending conversion warnings only, no whitespace errors.
- `flutter analyze`
  - NOT COMPLETED: produced no output and timed out after 184 seconds in this environment. No PASS is claimed.
- `python scripts\validate_opc_manifest_gate.py --base 0857b70fd002a15dbc51ccbb3377d588bdde4f08`
  - PASS after the required manifest headings were corrected to the gate's canonical form.

## Runtime/manual evidence

No interactive Windows or Android app session was available in this Codex run. Source and focused-test evidence confirm routing, responsive constraints, local navigation boundaries, and identity callback wiring, but do not constitute visual acceptance. Owner visual review is required for desktop and Android sizing/orientation behavior.

## Scope confirmations

- Grid behavior is preserved.
- Catalog data is not changed.
- Selected article identity and return semantics are preserved; detail selection returns the currently displayed summary into the existing callback.
- CITULJE Politika/Novosti visible picker behavior is preserved and remains covered by the focused test.
- Android back/select behavior is not intentionally changed; the viewer uses normal dialog navigation and no global orientation policy.
- No unrelated PREDMET, IRiU business logic, finance, PDF, JSON, Web, sync, stock, package/add-on, backend, payment, or licensing behavior was changed.
- No unresolved placeholders remain.

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
- yes

If not compliant, classify:
- not applicable

Manifest compliance checked: YES

PASS / NOT PASS: PASS, subject to explicit owner visual review; static analysis timed out and is not represented as passing.
