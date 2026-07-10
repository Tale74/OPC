# OPC Task Report — Owner Decisions Documentation: STATUSI, CEREMONIJA and Cross-Segment Tracking

## 1. Task identity

- Branch: `task/OPC-OWNER-DECISIONS-STATUSI-CEREMONIJA-DOCUMENTATION`
- Required base: `ac1ae9138a6866c89ae793896818418341c22f2d`
- Scope: documentation and source-learning only
- Production implementation: not authorized and not performed
- Build/runtime/smoke: forbidden and not performed

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no — future owner decisions are documented, not implemented

Database ownership affected:
- no

JSON transfer affected:
- no

Windows/Android parity affected:
- no — equal future business-rule intent is recorded only

Future Web Pristup affected:
- no — the same future business-rule boundary is preserved

Terminology drift risk:
- controlled — exact owner terms, stable decision IDs and current/future labels are used

Implementation allowed:
- no

Required gate before implementation:
- complete remaining segment owner decisions, especially ROBA I USLUGE / IRIU and cross-segment readiness

## 2. Outcome

The owner decisions for STATUSI, CEREMONIJA and the currently decided part of cross-segment readiness are preserved in a living guide, a stable decision index and Logos-visible pseudocode. The documentation explicitly distinguishes current source behavior from owner-approved future behavior and unresolved owner decisions.

Final classification:

`DOCUMENTATION PASS — CURRENT SOURCE / OWNER-APPROVED FUTURE RULE CONFLICT RECORDED — IMPLEMENTATION NOT AUTHORIZED`

The next owner pass is `ROBA I USLUGE / IRIU`. A future implementation task must not be written until the required segment-by-segment decisions and cross-segment readiness conditions are complete.

## 3. Artifacts

Created:

- `docs/OPC_OWNER_DECISION_GUIDE.md`
- `docs/OPC_OWNER_DECISIONS_STATUSI_CEREMONIJA_PSEUDOCODE.md`
- `docs/OPC_OWNER_DECISION_INDEX.md`
- `docs/tasks/OPC_TASK_OWNER_DECISIONS_STATUSI_CEREMONIJA_DOCUMENTATION_REPORT.md`

Updated:

- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`

The decision index contains 30 stable IDs: two global/architecture decisions, eleven STATUSI decisions, eleven CEREMONIJA decisions and six cross-segment decisions.

## 4. Source-learning evidence

### STATUSI

Inspected current terminology and behavior in:

- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/core/database/tables/predmeti_table.dart`

Confirmed current source facts:

- `RADNI STATUS` is multi-select and supports simultaneous `PENZIONER SRBIJE` and `VOJNI PENZIONER`.
- Current right/benefit facts are predominantly `DA/NE` booleans; the approved tri-state/right-obligation/history model does not exist.
- Current source contains `NAPOMENA (radni status)` backed by `penzionerNapomena`.
- Current spouse-sex initialization can fall through to a default/opposite inference when deceased POL is unresolved; the approved future fallback forbids inference and requires review.

### CEREMONIJA

Inspected:

- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/core/database/tables/predmeti_table.dart`

Confirmed current source facts:

- Ceremony facts include ceremony date/time, cemetery/type, opelo/locations/times, international funeral and reception place/time.
- There is no separate reception date, structured acceptance/execution/history, priest notification, military-honors registration, church-slot confirmation, cancellation lifecycle or derived readiness model.
- Ceremony datetime changes are currently field changes, not the approved cancellation/abandonment/rescheduling business-event model.

### IRIU

Inspected:

- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`
- `lib/core/constants/iriu_constants.dart`

Confirmed source/future conflict:

- Current `SAHRANA VAN SRBIJE` activates `MEĐUNARODNI PREVOZ`, `MEĐUNARODNA DOKUMENTACIJA` and `BALSAMOVANJE`.
- Current `DOČEK POSMRTNIH OSTATAKA` activates `CARGO TROŠKOVI` only.
- Owner-approved future grouping moves `BALSAMOVANJE` under `DOČEK POSMRTNIH OSTATAKA`.
- Current rows can remain stored but suppressed/inactive when the source toggle is disabled.

Recorded exactly as: `KNOWN CORRECTION DEBT — NOT FIXED IN THIS TASK`.

### PREDMET lifecycle, PARTE, JSON and PODSETNIK

Inspected relevant source in:

- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/presentation/segments/parte_segment.dart`
- `lib/core/utils/json_export_import.dart`
- `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`
- `lib/features/predmeti/reminders/`
- `lib/core/entitlements/opc_entitlement_policy.dart`

Confirmed:

- Current statuses are `OTVOREN`, `ZATVOREN`, `ZAVRŠEN`, `ANONIMIZOVAN`; no overlapping `POSTCEREMONIJALNI TOK` category exists.
- Current automatic `ZAVRŠEN` logic does not know the approved obligation/correction-window/readiness model.
- PARTE remains a derivative consumer of CEREMONIJA facts.
- JSON contains only current fields, not the future structured obligations/history.
- PODSETNIK is currently a ceremony-reminder surface and is not the authority for business obligations.

## 5. Git-tracked and local documentation audit

Git-tracked material reviewed included the purpose/anti-drift manifest, the PREDMET workflow/completion/dependency documents, full policy snapshot, prior PODSETNIK control-flow audit and existing Logos pseudocode index.

Local historical material was inspected in the project `PROJECT_DOCS`, `RESTORE_POINTS`, `BACKUPS` and available smoke-log area. Classification:

| Classification | Finding |
|---|---|
| Already migrated to Git | Existing status names, separate international-funeral/reception facts, current IRIU evaluator mapping, visible-muted rows and `ZAVRŠEN` not being a version event are represented in source/Git documentation. |
| Authoritative but not previously migrated | The attached owner decisions for rights, obligations, correction windows, cancellation, postceremonial category and readiness are newly preserved by this task. |
| Obsolete historical | Older notes describing PODSETNIK as merely planned no longer describe the current reminder module. |
| Conflicting with current source | Missing-POL inference fallback and future `BALSAMOVANJE` grouping differ from current behavior; structured obligation gates do not yet exist. |
| Owner decision supersedes old note | The newly approved future IRIU grouping supersedes the older future interpretation while current runtime remains unchanged. |
| Further owner review required | Full Doček/final-departure readiness, IRIU execution/cancellation, international items, vehicle/equipment readiness and later-discovered source segments. |

No historical file was copied wholesale. Backup/restore material was treated as historical evidence, not a newer source of owner authority.

## 6. Owner decisions preserved

The guide and pseudocode record:

- mandatory explicit fallback categories and the prohibition on silent inference;
- PREDMET authority and PODSETNIK technical-only reminder ownership;
- STATUSI semantics, tri-state rights, independent FIRMA obligations, two submission time facts, 24-hour correction and revocation;
- military-honors handoff, removal of the generic work-status note only after an owner-approved migration, and overlapping `POSTCEREMONIJALNI TOK`;
- CEREMONIJA possible/accepted/executed obligations, automatic evidence timestamps, Option B cutoff, source-change cancellation and attempted-cancellation fallback;
- explicit ceremony cancellation/abandonment/rescheduling events;
- IRIU correction debt and unresolved lifecycle;
- derived two-stage reception/final-departure readiness with no manual override.

## 7. Preserved unresolved boundaries

The following were deliberately not completed by inference:

- complete readiness matrix for Doček;
- complete readiness matrix for final departure;
- IRIU execution and cancellation semantics;
- handling of international transport, international documentation, balsamovanje and cargo costs;
- vehicle/equipment readiness;
- any additional source segments discovered later;
- migration/preservation treatment for existing `penzionerNapomena` content;
- full future schema/history/UI/JSON/versioning design.

## 8. Anti-drift and scope proof

- No production Dart file changed.
- No database/schema or JSON behavior changed.
- No status transition changed.
- No STATUSI, CEREMONIJA, PODSETNIK, IRIU, PARTE or reminder behavior changed.
- No test was added to assert unimplemented future behavior.
- No build, runtime, Windows incident audit or smoke test was performed.

## 9. Validation

Validation results are recorded after the documentation set is complete:

- `flutter analyze`: PASS — no issues found
- `flutter test`: PASS — all 126 tests passed
- manifest gate: PASS — one changed task report validated against required base
- UTF-8/BOM/mojibake check: PASS — valid UTF-8 without BOM; no mojibake in new documents
- documentation path/link check: PASS
- working tree scope check: PASS — documentation only
- GitHub visibility gate: PENDING

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
- yes — documentation files only

If not compliant, classify:
- NOT PASS

## PASS / NOT PASS Rule

PASS / NOT PASS:
- PASS WITH PENDING REMOTE CI — local validation complete; GitHub visibility gate pending

## 10. Handoff

This documentation is the owner-decision authority for future design work in the covered scope, but it is not proof of runtime behavior and not authorization to implement. Future tasks must cite decision IDs from `docs/OPC_OWNER_DECISION_INDEX.md`, preserve the current/future distinction and close applicable fallback dependencies before source changes begin.
