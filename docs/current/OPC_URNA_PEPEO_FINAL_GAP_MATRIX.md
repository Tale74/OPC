# URNA/PEPEO Final Gap Matrix

**Classification:** recovered as-built source/test evidence; no business inference and no runtime acceptance claim.

| OWNER contract | Current recovery source | Current test | Gap / status |
|---|---|---|---|
| `ZAVRŠEN` blocker | `PredmetiRepository.zavrsiPredmet()` calls `hasUnfinishedUrnaPepeoBlocker()` before writing `ZAVRŠEN`; rule is `futureBlocker` and completion is evaluated by current fingerprint | `test/predmet_completion_state_characterization_test.dart`; obligation foundation tests | Source hook is present. No new runtime acceptance in this documentation task. |
| Immediate completion → cancel | coordinator cancels stored primary and secondary IDs before rescheduling; terminal status fail-closes and `zavrsiPredmet()` deactivates after commit | `test/ceremony_reminder_system_test.dart` | Technical path and focused test exist; platform runtime evidence remains separate. |
| Notification enable/disable | `CeremonyReminderConfig.enabled`, normalized config persistence and coordinator fail-closed branch | `test/ceremony_reminder_system_test.dart` | No source gap established; no new QA run in this docs-only task. |
| Windows secondary delivery | `lista_predmeta_screen.dart` evaluates `activeUrnaPepeoSecondaryReminderSlot()` during startup/resume on Windows and adds the semantic line to the existing in-app dialog | Windows secondary-slot test in `test/ceremony_reminder_system_test.dart` | **Source path present. Independent Windows runtime delivery acceptance is not established here.** |
| Fallback `Groblje za polaganje urne nije uneto` | `ceremony_reminder_text.dart` applies exact fallback when cemetery is empty | wording/fallback assertions in `test/ceremony_reminder_system_test.dart` | Source and test evidence present; owner wording remains contract-controlled. |
| Parent labels | `urnaPepeoParentLabel()` returns `POLAGANJE URNE` or `RASIPANJE PEPELA`; notification title follows same branch | wording/label assertions in `test/ceremony_reminder_system_test.dart` | No demonstrated implementation gap. |
| Same semantic wording in PODSETNIK and notification body | both Windows due-line and gateway body call `buildUrnaPepeoSecondaryReminderText()` | shared wording test in `test/ceremony_reminder_system_test.dart` | Source/test trace present; runtime visual/body acceptance not repeated. |
| No raw keys | stable rule/payload identity is separate from semantic title/body; user-facing builders do not emit the rule ID | wording assertions and obligation foundation tests | No raw-key output gap demonstrated; payload identity remains technical by design. |
| `+3` activation | `urnaPepeoSecondaryActivation()` and occurrence/active-slot builders use ceremony date plus three calendar days | secondary activation tests in `test/ceremony_reminder_system_test.dart` | Source/test trace present. |
| `deliveryTimes` | config normalization, one occurrence per selected time and stored JSON delivery times | delivery-time assertions in `test/ceremony_reminder_system_test.dart` | Source/test trace present. |
| Duplicate-cycle protection | stored IDs are cancelled before reschedule; deterministic IDs and Windows per-session dialog keys prevent repeat display in one session | reschedule/cancellation and slot tests in `test/ceremony_reminder_system_test.dart` | Source/test trace present; cross-restart runtime evidence not part of this cutover. |
| `KREMACIJA_EKSPRES` | included by `isUrnaPepeoSecondaryRelevant()` and obligation derivation | express-ceremony cases in `test/ceremony_reminder_system_test.dart` | Source/test trace present. |
| `NAKNADNO` | excluded in reminder relevance and obligation derivation | fail-closed `NAKNADNO` cases in `test/ceremony_reminder_system_test.dart` | Source/test trace present. |

## Matrix conclusion

No source implementation gap is asserted by this documentation re-baseline for the listed paths. The remaining gaps are evidence/status gaps: independent Windows runtime delivery acceptance, any future release/publication decision, and any new QA required by a future implementation change. `WINDOWS SECONDARY DELIVERY` is no longer classified as “not demonstrated in source”; it is classified as source-present but runtime-unaccepted.
