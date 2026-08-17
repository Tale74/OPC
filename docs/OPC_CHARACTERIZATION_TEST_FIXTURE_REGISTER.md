# Characterization Test / Fixture Register

No production, SCENARIO, dependency, schema, or test-source files were added or modified by this wave. Existing focused tests were executed as characterization evidence:

| Artifact | Role | Result | Notes |
|---|---|---:|---|
| `test/migration_test_database_selector_test.dart` | Canonical-copy lane guard and alias rejection | 9 passed | Protects canonical DB from test migration lane |
| `test/predmet_completion_state_characterization_test.dart` | Lifecycle transition and immutable completion oracle | 5 passed | Explicit-only completion |
| `test/predmet_lifecycle_referential_characterization_test.dart` | FK mode, orphan inventory, delete/anonymize/replace/restore behavior | 5 passed | Replacement-derived-state semantic gap recorded |
| `test/predmet_hard_delete_lifecycle_coordinator_test.dart` | Hard-delete coordination | 4 passed | Synthetic disposable DB |
| `test/full_backup_restore_lifecycle_coordination_test.dart` | Full backup/restore coordination and stale-state cleanup | 8 passed | Synthetic/disposable lane |
| `test/canonical_database_migration_recovery_test.dart` | Current-tip migration/recovery characterization | INCONCLUSIVE | Timed out/tooling native-asset instability; not a PASS |
| `flutter analyze --no-pub` | Required static validation | INCONCLUSIVE | Timed out after 184 seconds; no source change |

Generated Flutter/native-asset cache files were not treated as deliverables and are excluded from the review package.

