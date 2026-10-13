# OPC v1.5 worktree classification and cleanup ledger — 2026-10-13

## Inventory checkpoint

Before closure documentation edits, the current branch was
`codex/opc-v1.5-clean-baseline`, HEAD `c37b7d23541408414b6061e6cdb257039762ce43`,
upstream `origin/codex/opc-v1.5-clean-baseline`; the two refs were equal.
The mixed worktree contained 54 modified tracked paths, zero deleted/renamed
paths, 118 untracked files, 2,979 ignored files and zero staged paths. The
verified inventory and exact per-path decisions are in the external review
ZIP. No `reset`, `restore`, `stash`, cleanup, or deletion was performed.

## Dispositions

| Set | Count | Classification | Publication disposition |
| --- | ---: | --- | --- |
| Modified tracked Dart files | 32 | Accepted v1.5 implementation accumulated from authorized tasks | Include only after exact-path diff review and final QA/build evidence identity check. |
| Modified tracked tests | 15 | Regression/contract coverage for accepted implementation | Include only after exact-path diff review. |
| Modified tracked current/supporting docs | 5 at intake; 6 content-diff paths after the closure plan edit | Current authority/supporting documentation; includes protected-path divergences from prior accepted work | Preserve; inspect each diff; do not rewrite active-source controls. Closure docs add new dated authority. |
| Modified tracked build/config | 2 content-diff paths | `analysis_options.yaml` and `pubspec.yaml` | Retain only after exact diff review. |
| Generated Windows plugin registrations | 3 status-only paths; index/worktree blob IDs match | Generated plugin registrations show Git status modified, but have no textual diff from HEAD | Preserve locally; exclude from content commit unless a later exact review proves a meaningful diff. |
| Untracked accepted source/assets/widgets | 7 | Final guide/help, accepted manual-entry and shared UI source/assets | Include after source/build evidence identity check. |
| Untracked regression tests | 10 | Focused coverage for accepted behavior | Include after exact-path review. |
| Untracked current task traceability/handoff docs | 16 at intake | Supporting historical and recent task evidence | Individually review privacy, authority references and current relevance; stage only selected public traceability records. |
| PARTE Android runtime screenshots | 34 | Physical runtime evidence; may contain private PREDMET/UI data | Preserve locally; do not publish in source baseline or external ZIP. |
| Nested historical Logos review package | 51 files | Embedded snapshot/evidence package under `docs/tasks` | Preserve locally; do not treat copies as current authority or publish. |
| Ignored `build/` and `.dart_tool/` | 2,886 | Generated build/cache outputs | Preserve local; exclude from Git publication. |
| Ignored `windows/` generated/ephemeral | 59 | Generated Windows ephemeral content including 12 Pub-cache symlink objects | Preserve local; exclude. Backup restore fidelity is verified for materialized target contents and all 12 reconstructed symlink objects/target mappings. |
| Ignored `android/` | 16 | Gradle/local.properties/generated plugin registration | Preserve local; exclude. |
| Ignored active controls/pseudocode | 11 | Local-only current-source controls and internal continuity evidence | Preserve locally; exclude from Git/public ZIP. |
| Ignored old review ZIPs in docs | 2 | Historical review archives | Preserve locally; exclude from current publication. |
| Other ignored files | 5 | Plugin dependency file and four Flutter logs | Preserve local; exclude from Git publication. |

The intake counts overlap only by their stated Git categories. The 2,979
ignored total is: build 2,666; `.dart_tool` 220; generated Windows 59; Android
16; internal control 11; old docs review ZIPs 2; plugin dependency file 1;
Flutter logs 4. Generated/private objects were not removed. Uncertain material
remains preserved and unstaged.

## Final closure inventory and proposed baseline

The closure-package inventory found 55 tracked content-diff paths, 3
additional tracked status-only Windows generated paths, 126 untracked files
and 2,979 ignored files. Nothing was staged at inventory time. The exact
per-path inventory records size and SHA-256 for tracked/untracked content,
and exact path/class/size for ignored content.

The proposed baseline contains the 55 content-diff tracked paths plus 30
selected untracked product source, tests, guide asset, current closure records
and recent traceability documents: 85 paths total. It excludes the 3
status-only generated paths, 34 Android screenshots, all 51 files in the old
nested review snapshot, 10 unrelated historical untracked documents and all
2,979 ignored files. Everything excluded remains preserved locally. The
external review package contains the exact allowlist, complete inventory,
tracked diff and proposed file snapshots. Final staging is conditional on
independent Logos review; the package itself is evidence, not authority.

Any changed path outside the selected allowlist is an explicit residual, not
an implicit deletion or rejection.
