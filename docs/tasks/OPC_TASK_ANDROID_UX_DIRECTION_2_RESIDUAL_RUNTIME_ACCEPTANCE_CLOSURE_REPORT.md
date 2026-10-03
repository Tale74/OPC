# Android UX Direction 2 — microcopy/literal cleanup formal closure

**Closure date:** 2026-10-03
**Status:** `ANDROID UX DIRECTION 2 — FORMALLY CLOSED`
**Scope:** previously implemented and accepted Android UX Direction 2 microcopy/literal work only; no new product implementation.

## Closure result

The owner-authorized closure set comprises the 19 surviving, previously
reviewed Direction 2 source/test paths and this report plus the two current
documentation homes. Existing product/test hunks were preserved without
content changes during closure. Three implementation paths from the earlier
22-path candidate are already represented in the intervening SCENARIO and
PIO commits; they were not staged or duplicated.

The remaining source/test hunks cover the approved bounded literal changes:
KATALOG protected-category wording; payment/help copy and platform label;
PODSETNIK explanation; SCENARIO open-PREDMET count and presentation label;
PARTE print/help text; LISTA PDF labels; STATISTIKA descriptions/metrics; the
OWNER-approved relative-day rule; PREDMET ceremony wording; refund display
terminology; PARTE preparation guidance; and the pensioner display label.
Regression tests cover the ceremony widget, LISTA PDF builder/output, relative
day wording, PARTE copy, and SCENARIO count wording. These are presentation
changes only: business logic, persisted identity/data, schema, JSON,
backup/restore, finance calculation, and PARTE workspace/canvas behavior are
unchanged.

## Runtime residual acceptance

| Finding | Status | Bounded evidence and qualification |
|---|---|---|
| R-1 — PIO Settings/help | `PASS` | The original D2 runtime observation established that the raw predicate fragments were absent on the then-tested PIO surface. That surface was later superseded by the separately approved PIO text correction. The current PIO text is supported by its own regression test, Logos PASS, and OWNER runtime PASS; the earlier screenshot is not claimed to depict the later copy. |
| R-2 — PREDMET/CEREMONIJA international-burial label | `PASS` | OWNER runtime acceptance records `Sahrana u inostranstvu`; the persisted `sahranaVanSrbije` identity is unchanged. |
| R-3 — LISTA PDF international-burial label | `PASS` | OWNER runtime acceptance records `Sahrana u inostranstvu: DA`, retaining country `CRNA GORA` and city `BAR`. |
| A-13 — KATALOG protected-category dialog | `PASS` | OWNER runtime acceptance records the protected-category explanation and `ODUSTANI` / `DEAKTIVIRAJ` choices; no unintended destructive operation was shown. |

The recorded R-1/R-2/R-3/A-13 runtime captures are Windows desktop
observations. They do not establish physical Android-device runtime, store
signing, or general release readiness.

## SCENARIO and PIO supersession

The SCENARIO inconsistency noted during the earlier D2 runtime work was
subsequently separated from D2, audited and corrected in the SCENARIO
historical-integrity task. That correction received Logos independent review
PASS and OWNER runtime acceptance PASS and was formally closed by commit
`c6cafa3a3172eb911ef3002a0533632e315d4f7d`. The historical observation is not
an open D2 finding and is not reopened by this report.

The separate continuity item remains exactly
`PREVIOUS PENDING FINDING — NOT IDENTIFIABLE FROM CURRENT AUTHORITY`. Its
identity is not reconstructed, guessed, or merged with the now-closed SCENARIO
item, `UX-PARTE-001`, or another finding.

The PIO tab received a later bounded text-only correction, formally closed by
commit `39f94a1bccbb98aa04bdb8a6fe6904105503601a`. Its current instruction is:

> Unesite iznos naknade pogrebnih troškova preko Republičkog fonda za penzijsko i invalidsko osiguranje (PIO fond) za tekući period.

The PIO amount entry, formatting, persistence, eligibility predicates and
FINANSIJE behavior remain unchanged. The PIO correction's own Logos review and
OWNER runtime acceptance are PASS. Its source/test hunks are not duplicated in
this D2 closure.

## UX-PARTE and remaining directions

- `UX-PARTE-001 — OPEN / NOT TESTED / ROOT CAUSE NOT PROVEN` remains separate.
- `UX-PARTE-002` remains a separate hierarchy/density concern.
- `UX-PARTE-003 — CLOSED` remains closed.
- Directions 1, 3, 4, 5 and 6 remain separate and unselected.

No PARTE canvas/workspace behavior or other UX direction is included. This
closure does not authorize a subsequent UX implementation; the next phase is
OWNER UX prioritization.

## QA and review evidence

The original Direction 2 candidate evidence is preserved as originally
recorded:

- Focused tests: **16 PASS**.
- `flutter analyze --no-pub`: **PASS**.
- Full serial suite: **593 passed / 10 skipped / 0 failed**.
- Windows release build: **PASS**.
- Android production release build: **PASS**; repository debug-signing
  configuration, not store-signed.

The later PIO candidate ran on the evolved worktree with the remaining D2
source/test hunks present:

- Full serial suite: **602 passed / 9 skipped / 0 failed**.
- Analyzer: **PASS**.
- Windows release build: **PASS**.
- Android production release build: **PASS**.

This later evidence supplements, and does not replace or misdate, the original
D2 QA. Product/test hunks were not changed during formal closure, so no new
product QA was run.

Review status is reported with provenance:

- Earlier Direction 2 post-implementation Logos review: **PASS** (OWNER-supplied
  result; the older package's `PENDING` fields remain historical and were not
  rewritten).
- PIO Logos review: **PASS**.
- SCENARIO corrective Logos review: **PASS**.
- A new independent Logos review of this final closure-documentation
  reconciliation is **not claimed as completed**; this report and external
  handoff are prepared for independent inspection.

## Active-source control and repository state

The pointer-only control repair was completed before this closure. Five
required control inputs were reread; active-source authority is PASS, package
integrity is **7/7 PASS**, protected source baseline is **28/28 PASS**, and the
publication pointer was
`39f94a1bccbb98aa04bdb8a6fe6904105503601a`. The protected baseline was not
changed for this D2 closure. No donor was used. The historical informational
count of 23 dirty paths in `11_OPC_ACTIVE_SOURCE_PRECHECK.md` was intentionally
left untouched under the pointer-repair boundary; the actual D2 closure
inventory had 22 paths at intake.

Closure made no product source/test changes. Only the three authorized
documentation paths changed. The staged/commit diff, final commit identity,
post-push remote identity, and review-package manifest are recorded in the
external bounded closure handoff at
`C:\Projekti\OPC_v1.5\REVIEW\CURRENT_TASK\OPC_ANDROID_UX_DIRECTION_2_FORMAL_CLOSURE_20261003\`.

## Engineering-profile applicability

- **Business/requirements traceability:** existing OWNER decisions and tested
  presentation criteria only; no new requirement or business meaning.
- **Architecture/data contracts/compatibility:** no architecture, dependency,
  database, schema, JSON, or transfer-contract change.
- **Implementation boundary:** existing source/test hunks only; no new product
  implementation or behavioral change.
- **Verification/acceptance:** previously accepted QA/build chain and scoped
  OWNER runtime evidence; no new QA because product/test hunks stayed fixed.
- **Quality/release:** bounded D2 closure only; no store-signing or general
  release-readiness claim.
- **Current-state documentation:** synchronized by this report and the two
  authoritative current-state homes; external review material is evidence, not
  a competing authority.
