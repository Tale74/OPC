# RR-005 Migration / Recovery Acceptance Matrix

| Case | Evidence | Result | Closure implication |
|---|---|---|---|
| A — current-tip no-op/reopen | Disposable copy, owner-copy test 1/1, v27, SHA and counts unchanged, integrity_check `ok` | PASS | Copy boundary and current-tip reopen are proven; FK baseline remains unresolved |
| B — historical migration chain | Current-branch canonical migration/recovery suite 40/40; versions 1–26 and populated recovery states | PASS | Historical compatibility and migration sequencing remain valid |
| C — recovery/repair | Recovery states, DDL-before-failure retry, package-downgrade suite 6/6 | PASS | Controlled repair/recovery behavior is evidenced without canonical mutation |
| D — controlled failure | Unsupported/newer/malformed/missing/conflicting schemas plus selector suite 9/9 | PASS | Fail-closed boundaries and disposable-lane selection are proven |
| Referential-integrity closure oracle | Pre/post canonical and copy each report 36 identical `foreign_key_check` rows | INCONCLUSIVE | Requires named follow-up; not a proven RR-005 defect and not a closure PASS |

## Required closure evidence for the successor

1. Explicitly classify the 36 baseline findings (34 `iriu_provenance → iriu`, 2 `predmet_scenario_snapshots → predmeti`) against the accepted current data/recovery authority.
2. Run any repair/recovery rehearsal only on a disposable copy and record before/after SHA, `integrity_check`, `foreign_key_check`, user_version and protected row counts.
3. Prove canonical SHA and metadata pre/post identity.
4. Preserve rejection behavior for unsupported, malformed, conflicting and non-disposable paths.

No production repair, schema change or migration rewrite is implied.
