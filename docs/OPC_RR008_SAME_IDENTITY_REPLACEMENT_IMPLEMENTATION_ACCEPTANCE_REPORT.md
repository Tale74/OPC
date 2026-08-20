# RR-008 Same-Identity PREDMET Replacement
## Implementation and Acceptance Report

Status: `RR-008 IMPLEMENTATION AND ACCEPTANCE COMPLETE — READY FOR LOGOS REVIEW`

### Governing business invariant

The owner oracle is:

`CURRENT PREDMET TRUTH → CURRENT DERIVED STATE`

The current/new same-identity PREDMET is selected by the existing import conflict
workflow and remains the sole business source. This correction does not choose a
universal delete/retain/recreate rule for unrelated derivatives.

### Pre-implementation evidence

The pre-implementation defect map recorded the existing centralized replacement
seam and the proven stale-state cases. Before correction, the transaction reused
the local PREDMET ID but left `parte_pripreme` and stored reminder IDs attached to
that ID. IRiU, contacts, provenance, snapshots, lifecycle decisions and STANJE
ROBE reconciliation were already handled and were not redesigned. The separate
`logIzmena` preserve/append discrepancy remains outside this task.

### Implemented correction

`lib/core/utils/json_export_import.dart` now coordinates replacement side effects
at the existing import seam:

1. read the old PREDMET, PARTE preparation and reminder inventory;
2. stage only app-owned PARTE media in the recoverable media store;
3. cancel only the old stored notification IDs;
4. transactionally replace PREDMET truth, restore the existing SCENARIO carrier
   and STANJE ROBE consequences, remove the stale PARTE row, and clear only the
   scheduled notification IDs while retaining the user's reminder configuration;
5. preserve the existing reminder configuration without creating an implicit one;
   the existing coordinator call is treated only as derived-state reconciliation,
   not as a new PODSETNIK trigger or scheduling policy;
6. purge staged media after commit, or restore staged media and old scheduling
   when the pre-commit operation fails. Post-commit auxiliary failures are
   converted into an explicit warning: committed PREDMET truth is not reported
   as rolled back, every attempted notification ID is cancelled on failure,
   persisted scheduled IDs are reset to an empty inventory, and staged media
   purge is retried. A failed post-commit media cleanup is surfaced in the
   warning rather than hidden.

The single-PREDMET JSON shape is unchanged. No SCENARIO implementation, schema,
database, dependency or platform behavior was changed.

### Acceptance evidence

| Gate | Result | Evidence |
|---|---|---|
| Focused replacement/lifecycle tests | PASS | `test/predmet_lifecycle_referential_characterization_test.dart` - 9/9, including post-commit initialization and partial-scheduling failure injection |
| Analyzer | PASS | `flutter analyze --no-pub`, natural completion, no issues, 24.7s |
| Full test suite | PASS | `flutter test --no-pub --concurrency=1`, 430 passed, 10 skipped, 0 failed, 16m18s |
| Windows release build | PASS | `flutter build windows --release`, `build/windows/x64/runner/Release/OPC.exe`, 319.0s; SHA-256 `CFC5578443C3F38041A169D9A046B393A284967AAC943895A58EF2EAD7E7D255` |
| Canonical database | PROTECTED | No canonical database launch, restore or mutation performed |
| SCENARIO | PROTECTED | No SCENARIO source/data change; lock retained |

The focused tests prove local-ID preservation, new PREDMET truth, stale PARTE
removal, old reminder cancellation, empty replacement IDs, preservation of an
existing reminder configuration without implicit creation, zero FK violations,
and the post-commit failure invariant. Initialization failure and a later
schedule failure both return a warning after commit; the replacement remains
the current business truth, attempted notifications are cancelled, persisted
IDs remain empty, and staged media is not stranded. No user-visible import
failure is reported for a transaction that already committed.
RR-008 does not assert which PREDMET triggers create reminders, when reminders
are scheduled, or whether replacement recreates them; those semantics belong to
the later dedicated PODSETNIK module-definition work.
Existing full-backup, reminder, lifecycle, JSON and SCENARIO suites remain green.

### Scope and remaining work

RR-008 is closed for the implemented same-identity replacement seam. Broader
PARTE print/layout characterization, notification taxonomy/business meaning,
cross-platform physical acceptance, the named PREDMET replacement audit-history
preservation successor, and unrelated JSON/database successors remain separate
program work. No commit or push was performed.
