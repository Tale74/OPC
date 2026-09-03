# OPC Current Implementation State

**Status:** `RECOVERED AS-BUILT / RUNTIME AND RELEASE STATUS SEPARATE`

## Identity

- Recovery HEAD: `39bde964d26a9cf7f0eb57939fd52fde9662be37`, detached.
- Existing recovery delta: `0 staged / 29 unstaged / 5 untracked` at cutover start; this documentation task adds only documentation and external review evidence.
- Windows `OPC.exe`: `build/windows/x64/runner/Release/OPC.exe`, SHA-256 `99ED7DB0A07DF74D6249B088DD0B3D63777A6DDE97CF2C14ABF83A107CBEB5E6`.
- Windows `data/app.so`: `build/windows/x64/runner/Release/data/app.so`, SHA-256 `7548E1B1C02B5F6EF11525BE2510F01D08A2C70C249408AD8725AD477A44666B`.
- Android release APK SHA-256: `3FC05CB7A2001EE9E6C6612A8FC0A100BA38B77DA04FE62BE64F76250C0BCE3B`.

## Verification state

Prior recorded evidence says targeted recovery/startup tests, `flutter analyze --no-pub`, full `flutter test --no-pub` (`475 passed, 10 skipped`), Windows build and Android build completed. Prior Windows functional observations covered startup, login, LISTA PREDMETA, existing PREDMET opening and segment navigation 1–10.

These are recorded scoped runtime/build results. The corrected build identity was confirmed and the basic Windows vitality flow was observed as PASS: startup, login, LISTA PREDMETA, existing PREDMET opening and segment navigation 1–10. This is not release or publication acceptance. The canonical DB hash changed after runtime; under the latest OWNER clarification, normal runtime database writes are not by themselves a migration/schema defect, so that hash change is recorded as a runtime evidence fact rather than a Phase 1 failure.

## Known boundary findings

- Canonical DB observations: prior pre-runtime SHA-256 `7868DCD145C565EB3B880302D54BE84C707FACF9C0113AEFA3CBAAD99D92717F`, earlier post-runtime `DF422DA0124A15A57E8211D372898B84CCB23560A7BFB6A5082C416E32062832`, latest read-only observation `EC63CC8110E4AA610806A015D3FD27FDCEF7E7D14BEC3C3C1DDD177166CFC0FA`. No repair, DB operation or causality inference is made.
- Recovery does not contain the internal pseudocode directory; the forensic primary SOURCE contains the referenced internal pseudocode. That source remains forensic-only.
- The legacy documentation set contains contradictory historical/current wording. The disposition manifest, not recency or filename, controls its authority status.

## Required separation of states

| State | Current evidence | Interpretation |
|---|---|---|
| BUSINESS CONTRACT | Direct OWNER decisions and locked continuity records | Meaning only; never inferred from code |
| IMPLEMENTATION | Recovery source at HEAD above | As-built behavior only |
| AUTOMATED QA | Prior recorded targeted tests, analyzer PASS, 475 tests PASS/10 skipped | Verification evidence only |
| WINDOWS RUNTIME | Corrected build basic vitality: startup/login/list/open/segments 1–10 PASS | Observed basic vitality, not full acceptance |
| ANDROID RUNTIME | APK identity/build record above | No Windows-to-Android inference |
| KNOWN GAP | `NALOG CVEĆARI` implementation not established; delivery details remain scoped | Must not be silently closed |
| RELEASE | Separate release gate | Not implied by build output |
| PUBLICATION | No commit, push or publication | Not executed/authorized |

The canonical DB hash observations are retained only as private-runtime
evidence. Normal runtime byte changes are not classified as a migration defect
and do not create a latent follow-up in this documentation task.
