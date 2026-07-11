# OPC Task Report — IRIU Business Logic Audit Before Owner Pass

## 1. Task identity

- Branch: `task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS`
- Base commit: `3fe6b6df2c1f1537a53b57d720cee8ae193bdecf`
- Task class: documentation / logical audit
- Implementation authorization: none
- Production source changes: none
- Build/runtime/smoke: not performed

## OPC MANIFEST CHECK — TASK START

Manifest read:
- yes — `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Task class:
- audit / documentation

Core purpose preserved:
- yes

PREDMET meaning affected:
- no — PREDMET remains the only authoritative business truth

Database ownership affected:
- no

JSON transfer affected:
- no — current transfer behavior was audited only

Windows/Android parity affected:
- no source change; current manual-add difference was recorded for owner review

Future Web Pristup affected:
- no; same future business logic boundary preserved

Terminology drift risk:
- controlled — owner corrected the task typo and confirmed `NALOG ZA OPREMANJE`

Implementation allowed:
- no

Required gate before implementation:
- IRIU owner pass and complete cross-segment readiness decisions

## 2. Objective and result

The audit reconstructed current IRIU storage, truth, lifecycle, UI triggers, condition reversals, financial/document/statistics derivatives, JSON transfer behavior, STANJE ROBE coupling, PREDMET status/version boundary and the existing NALOG ZA OPREMANJE.

The source is reconstructable, but it contains materially different lifecycle patterns and a known conflict with the owner-approved future Doček grouping. Final classification:

`AUDIT PASS — EXISTING SOURCE CONFLICTS REQUIRE OWNER REVIEW`

## 3. Owner clarification received during audit

The original task text used `NALOG ZA PRIPREMU`. The owner corrected this during execution:

```text
NALOG ZA OPREMANJE je ispravno.
NALOG ZA PRIPREMU je bila greška.
```

The audit therefore treats `NALOG ZA OPREMANJE` as the confirmed term and does not leave naming as an unresolved decision.

## 4. Artifacts

Created:

- `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`
- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md`

Updated:

- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`

## 5. Inspected paths

Primary source:

- `lib/core/database/tables/iriu_table.dart`
- `lib/core/database/tables/iriu_katalog_config_table.dart`
- `lib/core/database/database.dart`
- `lib/core/constants/iriu_constants.dart`
- `lib/features/predmeti/data/iriu_repository.dart`
- `lib/features/predmeti/data/predmeti_repository.dart`
- `lib/features/predmeti/core_v2/business_policy/`
- `lib/features/predmeti/core_v2/models/iriu_truth_models.dart`
- `lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart`
- `lib/features/predmeti/core_v2/services/predmet_iriu_truth_service.dart`
- `lib/features/predmeti/core_v2/services/mesto_smrti_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/blok2_iriu_lifecycle_service.dart`
- `lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`
- `lib/features/predmeti/core_v2/services/financial_truth_service.dart`
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`
- `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`
- `lib/features/predmeti/presentation/segments/finansije_segment.dart`
- `lib/features/predmeti/presentation/predmet_screen.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_data_builder.dart`
- `lib/features/predmeti/pdf/nalog_za_opremanje_pdf_export.dart`
- other PREDMET PDF builders/exporters
- `lib/features/predmeti/statistika_v1/`
- `lib/core/utils/json_export_import.dart`
- `lib/core/json_transfer/predmet_json_transfer_core.dart`
- `lib/features/stanje_robe/`
- `lib/core/entitlements/opc_entitlement_policy.dart`

Tests/documentation:

- `test/business_policy_iriu_critical_scenarios_test.dart`
- `test/json_transfer_regression_test.dart`
- `test/stanje_robe_operational_toggle_test.dart`
- `test/package_downgrade_migration_test.dart`
- current Git-tracked workflow, dependency, completion, policy, owner-decision and pseudocode documents
- local `PROJECT_DOCS`, relevant `RESTORE_POINTS` and project flow/delta continuity material.

No standalone IRIU provider/controller layer was identified; orchestration is split between widgets, repositories and core_v2 services.

## 6. Business model reconstructed

### Data model

An IRIU row is a PREDMET child with a category discriminator, editable visible snapshot, informational `kom`, amount, order, nullable catalog stable ID and legacy `cekiran`. The same row shape is used for initial placeholders, catalog choices, manual rows, conditional rows and recommendations.

### Truth model

Current derived row truth distinguishes:

- stored;
- active or suppressed;
- recommended or not;
- biohazard signal;
- financial inclusion/exclusion;
- derivative exclusions.

It does not distinguish accepted, completed, cancelled or business-replaced.

### Persistence/lifecycle

- Rows persist directly and may be physically deleted.
- The `NAPOMENA` shown under the IRIU list is stored as general `Predmeti.napomena`, not as an IRIU row/segment-owned history field.
- Managed MESTO SMRTI/BLOK2 deletion/skip can leave `MANUAL_DELETE` memory.
- International/reception source reversal preserves rows as suppressed.
- OPELO reversal does not deactivate the previously inserted `KOMPLET ZA OPELO`.
- STANJE ROBE has its own narrow effect/consequence lifecycle for three covered catalog categories.

## 7. Conditional business rules discovered

1. New PREDMET initializes nine Blok 0 categories plus all user catalog categories when configs exist.
2. `STAN`, `DOM ZA STARE`, `ULICA / JAVNO MESTO`, `DRUGO` generate six MESTO SMRTI operational categories.
3. `BOLNICA` generates only `PREVOZ DO GROBLJA`.
4. Infectious non-hospital death marks active `SPREMANJE PREMINULOG LICA` as `ZARAZNA BOLEST`.
5. Non-cremation `GROBNICA` recommends `LIMENI ULOŽAK` and `LEMOVANJE`.
6. Non-cremation `NASILNA`, `ZARAZNA` or `NEDEFINISANA` cause forces the same pair regardless of grave type.
7. Cremation suppresses that pair and has priority over the cause override.
8. Local cemetery recommends `PREVOZ SPROVODA`.
9. `OPELO = DA` inserts `KOMPLET ZA OPELO`; reversal has no matching lifecycle.
10. `SAHRANA VAN SRBIJE` inserts/activates international transport, documentation and balsamovanje.
11. `DOČEK POSMRTNIH OSTATAKA` inserts/activates cargo only.
12. Either international/reception toggle makes all four international picker rows selectable, even though activation remains condition-specific.
13. Active positive IRIU rows form financial truth; `kom` is not multiplied.
14. Catalog-bound SANDUK/OBELEŽJE/POKROV GARNITURA selection can create stock effect or unresolved consequence.

The complete matrix, reversal and fallback classification is in the main audit report.

## 8. NALOG ZA OPREMANJE findings

The NALOG consumes:

- deceased identity/year/death place;
- ceremony type/place/date/time;
- four equipment categories;
- three DA/NE services;
- biohazard flag;
- PREDMET number/status/version/adviser;
- firm memorandum data.

It does not contain persisted checklist items, sequencing, deadlines, assignment, digital execution, cancellation, readiness or vehicle departure state. Its two signature lines are blank paper output and do not write business evidence back to OPC.

Important output fallback: missing or suppressed service prints `NE`, so the PDF does not distinguish not-selected, not-applicable and source-suppressed.

## 9. Cross-segment and derivative findings

- Direct current IRIU inputs come from PREDMET death facts and CEREMONIJA facts.
- No direct STATUSI-to-IRIU row-generation rule was identified.
- IRIU feeds finance, statistics, STANJE ROBE, NALOG ZA OPREMANJE, other PDFs and JSON.
- LISTA-family documents use truth-aware active rows; raw PREDMET PDF prints stored rows; NALOG uses a fixed seven-category projection.
- Čitulje can be scoped out of item rendering while still contributing to financial truth when active and positive.
- Presentation code and truth code share responsibility for insert versus active/suppressed behavior, creating hidden coupling.

## 10. Conflicts and known debts

### Owner-approved future grouping conflict

Current source:

```text
SAHRANA VAN SRBIJE -> Međunarodni prevoz + Međunarodna dokumentacija + Balsamovanje
DOČEK -> Cargo troškovi
```

Owner-approved future grouping:

```text
SAHRANA VAN SRBIJE -> Međunarodni prevoz + Međunarodna dokumentacija
DOČEK -> Balsamovanje + Cargo troškovi
```

Classification: `KNOWN CORRECTION DEBT — NOT FIXED IN THIS TASK`.

Additional debts/gaps:

- OPELO auto-insert is one-way.
- Initial-sync and live-condition-change Blok 2 add flows have different confirmation semantics.
- Windows lacks the current manual-add action available on non-Windows.
- Duplicate categories are permitted; finance counts all while NALOG chooses one map value.
- IRIU child rows are outside current PREDMET save/confirmed-close field snapshot.
- Single-PREDMET JSON does not carry IRIU dismissal memory.
- Physical row deletion lacks general business history.

## 11. ZAVRŠEN and readiness

Current IRIU does not affect automatic `ZAVRŠEN`; past ceremony date controls it. General missing/suppressed/recommended rows do not block close. Only an unresolved STANJE ROBE consequence blocks `ZATVOREN`, and only while that module is operationally active.

Current data can provide candidate readiness inputs, but cannot prove accepted/executed/cancelled state, completed reception, equipment readiness or final departure. No readiness solution was designed in this audit.

## 12. Owner decisions required

- category-by-category business meaning;
- mandatory/recommended/optional semantics;
- future international/Doček grouping and source-reversal lifecycle;
- accepted/completed/cancelled/replaced states where actually needed;
- deletion versus immutable historical closure;
- duplicate/one-per-PREDMET rules;
- IRIU version/change-log semantics;
- single-PREDMET transfer scope for lifecycle decisions;
- Windows/Android manual-add parity;
- document item scope versus financial aggregate transparency;
- full Doček/final-departure readiness matrix;
- only then, future PODSETNIK inputs and navigation.

## 13. Implementation boundary

No production Dart, database/schema, JSON, PDF, finance, status, IRIU, NALOG, STANJE ROBE, PODSETNIK, tests or runtime behavior was changed. No future owner decision was encoded as a test.

## 14. Validation

- `flutter analyze`: PASS — no issues found
- `flutter test`: PASS — all 126 tests passed
- manifest gate: PASS — one changed task report validated against base
- UTF-8/BOM/mojibake check: PASS — new documents are valid UTF-8 without BOM or mojibake
- documentation path/link check: PASS
- documentation-only scope check: PASS
- GitHub visibility gate: PASS — remote branch matched content commit `3cc4e7fc0ea55017516df2637da3c9b0e732e331`; branch and all required artifacts returned HTTP 200

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
- yes — no behavior changed; existing difference documented

Existing JSON transfer preserved:
- yes

Terminology preserved:
- yes — `NALOG ZA OPREMANJE` owner-confirmed

Future Web Pristup not blocked:
- yes

Source changes within scope:
- yes — documentation only

If not compliant, classify:
- NOT PASS

## PASS / NOT PASS Rule

PASS / NOT PASS:
- PASS

## 15. Final status

`AUDIT PASS — EXISTING SOURCE CONFLICTS REQUIRE OWNER REVIEW`

GitHub-visible evidence:

- [branch](https://github.com/Tale74/OPC/tree/task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS)
- [content commit](https://github.com/Tale74/OPC/commit/3cc4e7fc0ea55017516df2637da3c9b0e732e331)
- [IRIU business logic audit](https://github.com/Tale74/OPC/blob/task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS/docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md)
- [IRIU pseudocode](https://github.com/Tale74/OPC/blob/task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS/docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md)
- [Logos index](https://github.com/Tale74/OPC/blob/task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS/docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md)
- [task report](https://github.com/Tale74/OPC/blob/task/OPC-IRIU-BUSINESS-LOGIC-AUDIT-BEFORE-OWNER-PASS/docs/tasks/OPC_TASK_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md)
