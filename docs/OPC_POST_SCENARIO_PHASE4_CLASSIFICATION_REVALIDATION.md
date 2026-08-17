# Phase 4 Classification Revalidation

## Method and outcome

The 23 rows in `docs/OPC_PHASE4_INTERVENTION_DECISION_MATRIX.md` were rechecked against the enriched 38-column, 336-row SOURCE/test/platform inventory, Phase 3 target mapping, dependency graph, compatibility register, characterization register and protected-surface checks. Every handwritten production file has a file-specific disposition and successor; classification is evidence-based and remains non-implementing. No Phase 4 technical conclusion changed.

| Phase 4 class | Revalidated count | Result |
|---|---:|---|
| Target fit / retain | 4 | Supported by current responsibility and target mappings |
| Move / rename | 5 | Supported by explicit target homes and compatibility prerequisites |
| Split / merge | 6 | Supported by dependency/ownership concentration evidence |
| Refactor | 2 | Bounded by characterization and contract obligations |
| Bounded recode candidate | 1 | Policy/finance; owner-gated semantics remain separate |
| Partial rewrite candidates | 2 | JSON interoperability monolith and database concentration; characterization required |
| Full reconstruction | 0 | No evidence supports full reconstruction |
| Removal / proven dead | 1 | `export_utils_replacement.dart`; proven dead, not removed |
| Compatibility/migration protected entries | 11 | Protected until rehearsal/acceptance evidence exists |

The generated `database.g.dart` file is not treated as handwritten production responsibility. The SCENARIO implementation and lock SHA are unchanged. No candidate was deleted, recoded, rewritten or physically moved.

## Proven-dead revalidation

A repository-wide search across production source, tests, scripts, tools and platform paths found no reference to `export_utils_replacement.dart`; Git history shows only its baseline placeholder introduction; all active consumers import `export_utils.dart`. The candidate remains retained solely as evidence pending a separately authorized removal task.
