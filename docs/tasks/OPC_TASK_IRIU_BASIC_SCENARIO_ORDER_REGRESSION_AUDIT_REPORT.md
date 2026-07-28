# OPC IRiU basic/scenario row-order regression audit

Status: **AUDIT COMPLETE — REGRESSION CONFIRMED — CORRECTION NOT IMPLEMENTED**

Audit date: 2026-07-28

Task branch: `task/OPC-IRIU-BASIC-SCENARIO-ORDER-REGRESSION-AUDIT`

Base branch: `task/OPC-PHASE-1-FULL-CODE-ARCHITECTURE-REVIEW`

Base SHA: `a86c3c70535fdf77dad8208a6007a65bbeb5ff9f`

## 1. Scope and owner runtime finding

This was a read-only regression audit. It did not change application source,
tests, database, migrations, build configuration or runtime behavior.

Owner runtime finding:

- IRiU previously displayed `SANDUK` and the remaining basic rows first, then
  scenario-dependent rows;
- the installed Windows application now displays scenario-dependent rows
  before the basic rows;
- the symptom was first noticed for `JAVNO MESTO/ULICA` and was then observed
  for the other scenarios.

The audit did not open or modify the canonical owner database.

## 2. Conclusion

**CONFIRMED CODE REGRESSION.**

The row-order inversion was introduced by commit:

- SHA: `c6fae079482097231f4513f683367d30f4e13f58`
- date: 2026-07-17
- subject: `Implement IRiU basic catalog category policy`
- parent: `4f8eaa8421f27ef387e3f62866000e396572786c`

Before that commit, the fixed system sequence was:

1. `SANDUK` and the remaining built-in basic rows;
2. `Agencijske usluge`, `Cveće` and obituary rows;
3. scenario-dependent rows.

The commit moved the complete scenario-dependent category block to the start
of the fixed sequence and moved the built-in basics after it. The same commit
added a focused test that explicitly requires scenario rows to precede the
basic rows, and its task report documented the inverted order as intended.
Consequently, later validation protected the regression instead of detecting
it.

This was not caused by SQLite nondeterminism, a display-only widget reversal,
the `JAVNO MESTO/ULICA` predicate itself, or a database migration that globally
rewrote all PREDMET records.

## 3. Independent local-backup evidence

Two local source backup archives independently preserve the pre-regression
implementation:

- `LOCAL_BACKUPS_ROOT/OPC_v1_backup_20260704_0730_before_pdf_logo_max_layout.zip`
- `LOCAL_BACKUPS_ROOT/OPC_v1_backup_20260716_183812_pre_canonical_schema_recovery.zip`

In both archives:

- entry:
  `SOURCE/lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`;
- `_systemCategoryOrder` starts with `IriuK.sanduk`;
- the remaining basic rows precede `IriuK.iznosenje` and the other
  scenario-dependent categories.

The 2026-07-16 backup predates the regression commit by less than seven hours
and is therefore direct local evidence of the last known correct ordering.

The same basics-first implementation is present in the regression commit's
parent SHA:

`4f8eaa8421f27ef387e3f62866000e396572786c:lib/features/predmeti/core_v2/services/iriu_ordering_service.dart`

`LOCAL_BACKUPS_ROOT` is a documentation alias. No private absolute owner path
is published.

## 4. Current executable source path

### 4.1 Fixed sequence

`lib/features/predmeti/core_v2/services/iriu_ordering_service.dart:7-29`

The current `_systemCategoryOrder` starts with the scenario-dependent
categories (`IZNOSENJE` through `CARGO_TROSKOVI`) and only then appends
`IriuK.ugradjeneOsnovnePreAgencijskih`. Its line-8 comment explicitly describes
the scenario block as the leading block.

### 4.2 Forced persistent rewrite

`lib/features/predmeti/core_v2/services/iriu_ordering_service.dart:37-65`

`orderedRows` first reads the stored order, then regroups known categories by
the fixed `_systemCategoryOrder`. The stored `redosled` cannot preserve the
earlier basics-first order for known system categories.

`lib/features/predmeti/data/iriu_repository.dart:418-430`

`_rebuildBusinessOrdering` writes the resulting positions back into
`iriu.redosled` inside a transaction.

`lib/features/predmeti/data/iriu_repository.dart:34-44`

Both UI watch and ordinary repository read return rows ascending by the now
persisted `redosled`. The UI therefore displays the rewritten order; it does
not independently invert it.

### 4.3 Mutation paths that trigger the inversion

`lib/features/predmeti/data/iriu_repository.dart:46-77`

Adding any IRiU item calls `_rebuildBusinessOrdering`.

`lib/features/predmeti/data/iriu_repository.dart:168-193`

Deleting an IRiU item calls `_rebuildBusinessOrdering`.

`lib/features/predmeti/data/iriu_repository.dart:359-386`

Inserting a managed `MESTO SMRTI` scenario row calls
`_rebuildBusinessOrdering`.

`lib/features/predmeti/data/iriu_repository.dart:389-415`

Inserting a managed Blok-2 scenario row calls `_rebuildBusinessOrdering`.

Therefore the regression can affect an existing PREDMET when a later IRiU or
scenario lifecycle mutation occurs. There is no evidence of one migration that
reordered every existing PREDMET at application startup.

## 5. Why `JAVNO MESTO/ULICA` exposed it first

`lib/features/predmeti/core_v2/rules/iriu_truth_rules.dart:256-274`

Both `ULICA` and `JAVNO MESTO` normalize to the same qualified
`ULICA / JAVNO MESTO` condition.

`lib/features/predmeti/presentation/segments/iriu_segment.dart:326-359`

After a relevant condition change, the IRiU segment resolves conflicts and
calls `syncMestoSmrtiManagedRows`.

When that sync inserts a scenario-managed row,
`IriuRepository.syncMestoSmrtiManagedRows` invokes the global business-order
rebuild. The new fixed sequence then moves the scenario rows ahead of
`SANDUK`. This explains why the owner first observed the inversion on the
`JAVNO MESTO/ULICA` path and later saw it after other scenario/IRiU mutations.

The scenario predicate revealed the ordering defect; it did not create the
incorrect ordering policy.

## 6. Regression locked by test and report

`test/iriu_catalog_basic_category_policy_test.dart:160-194`

The test is named:

`scenario rows precede built-in basics, agency and user basics`

It adds `IZNOSENJE` and asserts that it becomes the first row. That assertion
matches the regression and must be corrected together with production order;
otherwise a valid basics-first correction would intentionally fail the
existing test.

`docs/tasks/OPC_TASK_KATALOG_OSNOVNE_KATEGORIJE_IRIU_AUDIT_IMPLEMENTATION_REPORT.md:97-103`

The task report lists scenario-dependent rows first and built-in basics second.
This is a documentation defect introduced with the code defect. It conflicts
with both the pre-regression source evidence and the current `SANDUK`-first
truth rule.

## 7. Documentation conflict

The current documentation contains mutually incompatible statements:

- `docs/OPC_IRIU_BUSINESS_LOGIC_PSEUDOCODE.md:393-396` says the fixed sequence
  has `SANDUK` as the first truth anchor;
- `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md:95-108` lists the initial
  basics block starting with `SANDUK`;
- `docs/OPC_IRIU_BUSINESS_LOGIC_AUDIT_REPORT.md:137` says the protected anchor
  means first order;
- `docs/OPC_OWNER_DECISION_INDEX.md:173-180` preserves the basic-category
  boundary and states that built-in basics precede `Agencijske usluge`;
- the schema-22 task report and its focused test require scenario-first order.

The owner runtime statement on 2026-07-28 confirms that the earlier
basics-first behavior is the required business result:

**`SANDUK` and the other basic rows first; scenario-dependent rows afterward.**

The schema-22 task's scenario-first ordering was an incorrect technical
inference, not a required consequence of the `Osnovna u svakom PREDMETU`
feature.

## 8. Installed Windows application evidence

The installed Windows application files and the retained Windows release build
output are byte-identical:

| File alias | SHA-256 |
|---|---|
| `INSTALLED_OPC_ROOT/OPC.exe` | `32172CD5C2760D5A222A949A0F03C8BCE431D76E7F42A9155B6C2312A84B8F39` |
| `SOURCE_BUILD_ROOT/OPC.exe` | `32172CD5C2760D5A222A949A0F03C8BCE431D76E7F42A9155B6C2312A84B8F39` |
| `INSTALLED_OPC_ROOT/data/app.so` | `C2D949AE813AFCF089483F0050AB76D9969F24DBCDC95A533764E3D129CEA780` |
| `SOURCE_BUILD_ROOT/data/app.so` | `C2D949AE813AFCF089483F0050AB76D9969F24DBCDC95A533764E3D129CEA780` |

The retained `app.so` was built on 2026-07-22. The regression commit is an
ancestor of the source branch used for the 2026-07-22 build line and remains an
ancestor of the current source HEAD. No later correction of the fixed sequence
exists. This confirms that the installed runtime contains the audited
scenario-first implementation.

Aliases:

- `INSTALLED_OPC_ROOT` — installed OPC application root;
- `SOURCE_BUILD_ROOT` — `build/windows/x64/runner/Release`.

No canonical database content or personal data was read for this comparison.

## 9. Safe correction recommendation

The correction should be a small, separately authorized business-order task,
not a scenario-engine rewrite:

1. restore a single explicit basics-first fixed sequence with `SANDUK` first;
2. preserve the established relative order of all other built-in basics;
3. place scenario-dependent rows after the complete basic block;
4. define the exact boundary for enabled user-configurable basics and
   manual/unknown rows before implementation;
5. replace the inverse focused test with positive basics-first and
   mutation-path regression coverage;
6. cover at least `JAVNO MESTO/ULICA`, one Blok-2 scenario and an existing
   PREDMET that receives a later scenario row;
7. update the schema-22 task report only by an explicit correction note; retain
   the historical evidence that the earlier task introduced the defect;
8. do not introduce a data migration merely to reorder all canonical records.
   The shared repository rebuild can normalize eligible records when the
   owner-authorized correction is applied through a controlled runtime path;
9. before deciding whether old completed PREDMET rows may be rewritten, apply
   the existing PREDMET historical-stability rules. This audit does not
   authorize such a rewrite.

Because the logic is shared Dart/Drift code, the correction must produce the
same business result on Windows and Android.

## 10. Validation gate for a future correction

This audit did not run Flutter analyze, tests or builds because it made no
application change and the existing focused test already proves the currently
encoded inverse expectation.

For a separately authorized correction:

1. run the focused ordering and scenario lifecycle tests;
2. run `flutter analyze --no-pub` to a conclusive PASS;
3. only then run the complete `flutter test --no-pub` to a conclusive PASS,
   without an artificial short timeout;
4. only after both PASS results may the owner authorize Windows and Android
   builds;
5. record technical PASS separately from owner Windows/Android runtime
   acceptance.

## 11. Audit controls and status

- Git/source history inspection: PASS.
- Independent local backup comparison: PASS.
- Installed/build artifact hash comparison: PASS.
- Canonical owner database opened or modified: NO.
- Application source/test/schema/migration/build change: NO.
- Flutter command executed: NO.
- Owner physical intervention required: NO.
- Correction implemented: NO.

Final audit status:

**IRiU BASIC/SCENARIO ORDER REGRESSION CONFIRMED — INTRODUCED 2026-07-17 — INSTALLED RUNTIME AFFECTED — SAFE CORRECTION SCOPE IDENTIFIED — IMPLEMENTATION NOT STARTED**
