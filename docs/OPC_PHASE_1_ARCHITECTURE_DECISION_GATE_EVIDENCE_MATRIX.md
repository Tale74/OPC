# OPC — Phase 1 Architecture Decision Gate evidence matrix

Status: `ACTIVE PHASE 1 CONTROL MATRIX — DECISION GATE NOT YET OPEN`

Base SHA: `f546aac3dd848ccfa780f1c7edbbca85afd20c27`

| Evidence family | Current state | Strongest evidence | Remaining gate requirement | Implementation |
| --- | --- | --- | --- | --- |
| Full source/architecture inventory | COMPLETE | `docs/OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md` | None for source inventory | Not authorized |
| PREDMET identity/version/log | SOURCE/OWNER/AUDIT COMPLETE WITH IMPLEMENTATION GAPS | identity, version and `logIzmena` Gate 0 reports | implementation design only after Architecture Gate | Not authorized |
| PREDMET dependent-data lifecycle | FIXTURE-CONFIRMED DEFECTS / DESIGN COMPLETE | referential audit and lifecycle matrix | RI-1–RI-5 implementation and migration proof after Gate | Not authorized |
| PODSETNIK referential/OS lifecycle | ROOT CAUSE CONFIRMED | orphan audit + referential audit | later implementation; informed model waits for signal inventory | Not authorized |
| Windows multiple instance | AUDIT COMPLETE / RISK CONFIRMED | no native guard; shared production lane; isolated concurrent open/write blocking; source operation matrix | named-mutex and installer coordination implementation only after authorization | Not authorized |
| Windows startup | SOURCE AUDIT COMPLETE / QUANTITATIVE BASELINE BLOCKED | pre-`runApp` waits; first DB query routing; repeated recovery/validation, 74 seed attempts, policy update and full KATALOG scan; post-login side effects | owner-authorized current-HEAD isolated WINDOWS_TEST instrumentation/build, cold/warm phase timings and owner target | Not authorized |
| Android PARTE performance | SOURCE CANDIDATES ONLY | viewport rebuild and media-load paths | latest-HEAD reproduction and profiler evidence | Not authorized |
| SCENARIO/IRiU | PARTIAL CORE_V2 / KNOWN BUSINESS DEFECTS | evaluator, truth rules and focused tests | full condition/storage/stale-row/urn audit | Not authorized |
| JSON/backup/restore | TESTED FOUNDATION / HIGH COUPLING / RESTORE RISK | transfer core, large orchestration file, migration tests | supported-version and product-profile synthesis; reliable full suite | Not authorized |
| UI/UX parity | SOURCE RESPONSIVE BRANCHES / RUNTIME GAP | shared Flutter tree and platform branches | fixed Android narrow/wide and Windows scenario matrix | Not authorized |
| Localization/country profiles | NOT IMPLEMENTED / READINESS CHARACTERIZED | fixed Serbian locale and embedded strings | post-Serbia product-line architecture | Not authorized |
| Dual currency | NOT IMPLEMENTED / RSD-BOUND CURRENT OUTPUTS | fixed money/QR/document labels | later owner-approved MODUL DVE VALUTE design | Not authorized |
| Signing/release identity | NOT READY | Android debug release signing; incomplete custody evidence | separate signing readiness audit | Not authorized |
| Static validation | PASS | `flutter analyze --no-pub`, no issues | none for current source snapshot | Does not authorize implementation |
| Complete Flutter test suite | NOT COMPLETED | 15-minute run produced no final result; orphan tester remained | isolate runner/test hang and obtain final suite result | Build gate closed |

## Decision readiness

Current provisional technical direction:

`RETAIN + PROGRESSIVE REFACTOR`.

Permitted partial-rewrite candidates for later comparison:

- scenario/configuration persistence and evaluation boundary;
- JSON/full-backup orchestration shell;
- PARTE presentation/render state boundary only if profiling proves need.

Full rewrite is not supported by current evidence.

The Architecture Decision Gate opens only after every row required by Phase 1
has either:

- a complete evidence result; or
- an explicit, documented owner-approved deferral that cannot change the
  architecture decision.
