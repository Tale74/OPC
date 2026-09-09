# OPC PODSETNIK — IMPLEMENTATION READINESS CONTRACT

**Status:** `RECOVERED OWNER CONTRACT / R5 IMPLEMENTATION + INDEPENDENT LOGOS REVIEW PASS — RUNTIME ACCEPTANCE PENDING`

**Effective baseline:** 2026-08-28

This is a subordinate technical readiness contract. The recovered owner
baseline and traceability ledger in the restoration review are the business
authority. Current source/tests/runtime evidence describe CURRENT reality and
must not be rewritten as target behavior.

## 1. Recovered business contract

- `PREDMET` is the sole business truth; current `IRiU` is the goods/services
  truth. PODSETNIK derives consequences and owns only technical delivery state.
- There is no generic Accept/Dismiss business-suggestion workflow.
- Eligibility is exactly `OTVOREN || ZATVOREN`; every other status fails closed.
  Historical reminder rows for an ineligible PREDMET are inert.
- The surface is `OBAVEZE I NAPOMENE`: one general free note and atomic
  executable children. Grouped parents aggregate children; parent completion
  and mark-all are derived from children. Only unfinished atomic children count.
- `LISTA PDF` is the same conceptual checklist with fresh empty paper
  checkboxes; it is not a completion snapshot.
- Every obligation has explicit `PRE-CEREMONY` or `POST-CEREMONY` phase. Phase,
  unfinished status, parent state or reminder ownership does not create a
  generalized `ZAVRŠEN` blocker.

## 2. Recovered obligation rules

- PIO and family-pension combinations coexist. FIRMA parents are
  `REFUNDACIJA PIO → Predati zahtev`, `PORODIČNA PENZIJA → Predati zahtev`,
  and `POSMRTNA POMOĆ → Predati zahtev`; payer/family paths are informational
  unless explicitly represented by those parents. `Inostrani penzioner`,
  `U radnom odnosu`, `Drugo`, `PORODIČNI PENZIONER` and `BIOHAZARD` are
  informational-only where specified.
- `VOJNE POČASTI = DA` yields `Obavestiti nadležnu službu`.
- Relevant OPELO contains `Obavestiti sveštenika` and, when current PREDMET/
  IRiU makes the kit relevant, `Spremiti komplet za opelo`. Priest contact and
  agreement are one operational completion. There is no separate `Dogovor
  potvrđen`, `Church slot` or church-confirmation derivative.
- `PARTE` is one atomic obligation. `OPREMA`, `SLIKA`, `CRNINA`, `CVEĆE`,
  `Sahrana van Srbije`, `Doček` and unresolved `STANJE ROBE` are ordinary
  checklist/informational consequences as defined by the owner baseline; no
  blocker is inferred from their existence.
- Supported ceremony types are `SAHRANA`, `SAHRANA_EKSPRES`, `KREMACIJA` and
  `KREMACIJA_EKSPRES`. Main location is `GROBLJE`, with fallback
  `Groblje nije uneto`; header is `<VRSTA> – <DATUM> – <VREME> – <MESTO>`.

## 3. Notification and overview contract

- Current notification text remains a CURRENT source fact. The future primary
  sentence includes identity, concrete ceremony type, date, time and
  `NA GROBLJU <GROBLJE>`, ending `DOVRŠITE NEOPHODNE PRIPREME.`
- Primary delivery includes the ceremony date and stops the next day.
- The overview bar rotates relevant unfinished parent labels generally, shows
  no atomic labels/count, opens PODSETNIK and remains visible as grey inactive
  `OBAVEZE ISPUNJENE` until `ZAVRŠEN`. The three-dot entry stays available
  while eligible. This is the bounded R5 correction to the earlier
  post-ceremony-only source behavior; placement, styling and zero-state remain
  unchanged.
- Canonical `OPC Int` values remain language-neutral; localization supplies
  grammar/display. Exact catalogue/API and count grammar remain OPEN.

## 4. Urn/ashes target contract

For both `KREMACIJA` and `KREMACIJA_EKSPRES`, canonical
`tipPolaganja != NAKNADNO` creates a FIRMA-owned POST-CEREMONY urn/ashes parent.
It is manually completable at any time. It is the only explicit PODSETNIK
`ZAVRŠEN` blocker; completion removes the blocker and terminates its cycle.
The secondary cycle threshold is ceremony date +3 days and exists only while
unfinished. No target event date is required; later placement/scattering is
payer/family responsibility. Use `GROBLJE POLAGANJA URNE`, not main GROBLJE.

Semantic wording is:

- `ZA <Ime Prezime> ZAKAZATI POLAGANJE URNE U <TIP> NA <GROBLJE POLAGANJA URNE>.`
- `ZA <Ime Prezime> ZAKAZATI RASIPANJE PEPELA NA <GROBLJE POLAGANJA URNE> GROBLJU.`

Missing or invalid urn location uses the exact fallback
`Groblje za polaganje urne nije uneto`. Migration/version number,
fingerprint encoding/version, role-specific reopen semantics and exact
animation remain OPEN. No target date or church workflow is invented.

## 5. Technical design boundary (subordinate)

The implementation may use a generic PREDMET-owned obligation state, stable
rule/instance identity and source fingerprint, atomic persistence, derived
parents, dynamic reconciliation, minimal completed-child retention for a
temporarily non-current concrete ČITULJA occurrence, full-backup business
state, non-portable device notification IDs and a versioned transfer contract.
It must not retain incomplete, invalid, orphaned or redundant ČITULJA state
merely as history or treat a parent row as independent business truth.
PODSETNIK may retain only delivery configuration/IDs. Exact schema/API choices
remain implementation detail and cannot create business semantics.

## 6. Current source reality

Current source implements the bounded obligation foundation and the
F-LOGOS-001…007 correction: responsibility-gated PIO/family/military/OPELO
projection, owner-defined atomic/grouped shape, PREDMET-owned completion,
source-fingerprint reconciliation and portable transfer/backup state. The
OPELO responsibility fact is persisted as `obavestitiSvestenika`, with empty
legacy/unknown state failing closed. The URNA/PEPEO business contract is
locked; implementation, runtime acceptance, release and publication status
must be tracked separately according to the actually completed state. This
contract does not claim Windows acceptance or release readiness.

R5 adds the bounded ČITULJE PODSETNIK projection. Current applicable ČITULJA
IRiU occurrences produce one human-facing `ČITULJA` parent and one atomic
child per portable occurrence. The parent is derived from relevant children;
checking the parent marks all relevant children, and a child change recomputes
the parent. Completion for a concrete child is retained by its portable
occurrence identity when that occurrence temporarily leaves current IRiU, but
the non-current child is not projected; a new portable identity starts
independently. Incomplete, invalid, orphaned and parent-only ČITULJA state is
not retained merely as history. Single-PREDMET JSON and full Backup JSON
preserve this minimal completed child state during temporary non-current
membership. Import accepts only a completed canonical child whose portable
identity matches exactly one ČITULJA IRiU occurrence in the same PREDMET;
generic/unknown states and independent parent state are not resurrected by
this exception. The parent is included in the general relevant-parent overview bar, while the
existing placement, styling, no-count rule and `OBAVEZE ISPUNJENE` zero-state
are preserved. Each child can request the canonical persisted-state ČITULJA
PDF generator. Existing PREDMET JSON and Backup JSON obligation transfer
carries the portable child completion state; schema and unrelated obligation
semantics are unchanged.

## 6A. Current bounded milestone extension — 2026-09-07

URNA/PEPEO applies to both cremation types when `tipPolaganja != NAKNADNO`,
exists immediately, uses the existing delivery-time selector for its +3-day
repeating cycle, reads only `grobljePolaganjaUrne`, terminates on completion
and remains the sole PODSETNIK `ZAVRŠEN` blocker. F-06 adds atomic text-only
manual rows under the derived `POSEBNE OBAVEZE` parent for SAVETNIK and
ADMINISTRATOR; no edit or delete operation exists. Both state families use
the existing PREDMET/Backup JSON transfer boundary. The additive database
extension is schema 35.

Targeted/relevant source tests and analyzer are green. The serial full-suite
attempt is recorded as incomplete because four unrelated existing STANJE ROBE
UI tests fail both in the full run and when isolated; this is not claimed as
runtime or release acceptance.

## 7. Dependency order (historical task names retained only as provenance)

1. **Domain/persistence foundation:** generic rule/instance state,
   PREDMET-owned completion/history, parent aggregation, reconciliation,
   migration and versioned transfer contract. Bounded F-LOGOS-001…007
  correction is implemented; independent Logos review is PASS, with runtime
  acceptance remaining separate.
2. **UI/primary notification:** consume the projection for
   `OBAVEZE I NAPOMENE`, checklist/header, primary wording/cutoff and overview
   bar.
3. **URNA/PEPEO specialization:** both cremation types, `NAKNADNO`
   exclusion, semantic wording, sole blocker, +3 cycle and termination.

Order is strict: verify the domain/persistence foundation before the UI/
The bounded R5 ČITULJE parent/child integration and general-parent overview-bar
correction are implemented and have independent Logos review PASS; integrated
runtime/release acceptance remains pending.
Each future code task uses targeted tests → natural `flutter analyze` → natural full
`flutter test` → authorized build, sequentially.

## 8. Explicitly unresolved

The following remain OPEN: exact localization catalogue/API, migration/version
number, fingerprint format,
role-specific reopen semantics, exact Serbian singular/plural count sentence,
attention animation and any additional blocker. No source, test, schema,
migration, UI, scheduler, runtime or database change is authorized here.
