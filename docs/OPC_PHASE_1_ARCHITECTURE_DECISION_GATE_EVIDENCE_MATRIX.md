# OPC — Phase 1 Architecture Decision Gate evidence matrix

Status: `POST-ZERO TECHNICAL ARCHITECTURE DECISION PASS - IMPLEMENTATION NOT AUTHORIZED`

Post-zero controlling synthesis:
`docs/OPC_POST_ZERO_ARCHITECTURE_DECISION_GATE_SYNTHESIS.md`.

Pre-zero owner statements in this matrix are historical/prospective evidence
only.

Base SHA: `f546aac3dd848ccfa780f1c7edbbca85afd20c27`

| Evidence family | Current state | Strongest evidence | Remaining gate requirement | Implementation |
| --- | --- | --- | --- | --- |
| Full source/architecture inventory | COMPLETE | `docs/OPC_PHASE_1_FULL_CODE_ARCHITECTURE_REVIEW.md` | None for source inventory | Not authorized |
| PREDMET identity/version/log | SOURCE/OWNER/AUDIT COMPLETE WITH IMPLEMENTATION GAPS | identity, version and `logIzmena` Gate 0 reports | implementation design only after Architecture Gate | Not authorized |
| PREDMET dependent-data lifecycle | FIXTURE-CONFIRMED DEFECTS / DESIGN COMPLETE | referential audit and lifecycle matrix | RI-1–RI-5 implementation and migration proof after Gate | Not authorized |
| PODSETNIK referential/OS lifecycle | ROOT CAUSE CONFIRMED | orphan audit + referential audit | later implementation; informed model waits for signal inventory | Not authorized |
| Windows multiple instance | AUDIT COMPLETE / RISK CONFIRMED | no native guard; shared production lane; isolated concurrent open/write blocking; source operation matrix | named-mutex and installer coordination implementation only after authorization | Not authorized |
| Windows startup | INSTALLED OWNER BASELINE CONFIRMED / CURRENT-HEAD BASELINE PENDING | installed owner version reaches login in approximately 8–9 s; startup changed canonical DB by +8,192 bytes while integrity remained `ok`; Android owner runtime is perceptually immediate; source maps Windows/pre-`runApp`, DB scale and repeated recovery/validation candidates | owner-authorized current-HEAD isolated WINDOWS_TEST instrumentation/build, cold/warm phase timings and owner target; later controlled Android comparison | Not authorized |
| Windows exit | OWNER SLOW-EXIT CONFIRMED / SOURCE CANDIDATE IDENTIFIED | historical normal-close timing 12.8 s; current owner finding; `windowManager.destroy()` awaited without explicit production `AppDatabase.close()` or shutdown coordinator | instrument DB/background/plugin/window shutdown phases before correction | Not authorized |
| Android PARTE performance | SOURCE AUDIT COMPLETE / LIVE PROFILING PENDING | sequential N+1 preparation queries; whole-viewport rebuild on each pan/zoom update; fresh media reads and synchronous image effects on the UI isolate; edit persistence followed by full plan reload | targeted latest-HEAD profiler run on an owner-provided Android device, with narrow/wide and media/no-media fixtures, before selecting or accepting a correction | Not authorized |
| SCENARIO/IRiU | COMPLETE SOURCE AUDIT / POST-ZERO BUSINESS GATES REMAIN SEPARATE | one scenario ID over hard-coded condition families; confirmed ordering incident; no row provenance; no FIRMA template storage; current suppress/dialog behavior | bounded scenario/configuration boundary is technically justified; lifecycle, reconciliation, user-facing meaning and any new PREDMET business field require a post-zero owner gate before implementation | Not authorized |
| JSON/backup/restore | TESTED FOUNDATION / HIGH COUPLING / RESTORE RISK | transfer core, large orchestration file, migration tests | supported-version and product-profile synthesis; reliable full suite | Not authorized |
| UI/UX parity | SOURCE RESPONSIVE BRANCHES / RUNTIME GAP | shared Flutter tree and platform branches | fixed Android narrow/wide and Windows scenario matrix | Not authorized |
| Localization/country profiles | NOT IMPLEMENTED / READINESS CHARACTERIZED | fixed Serbian locale and embedded strings | post-Serbia product-line architecture | Not authorized |
| Dual currency | NOT IMPLEMENTED / RSD-BOUND CURRENT OUTPUTS | fixed money/QR/document labels | later owner-approved MODUL DVE VALUTE design | Not authorized |
| Signing/release identity | NOT READY | Android debug release signing; incomplete custody evidence | separate signing readiness audit | Not authorized |
| Static/full-suite validation | PASS FOR UNCHANGED APPLICATION TREE | at application source `e9ea4a9679f0a9f80521fc3aa362e78b7993d073`: `flutter analyze --no-pub` PASS; complete `flutter test --no-pub` PASS with 247 passed, 1 skipped, 0 failed; subsequent Phase 1 changes are documentation-only | rerun only after a source/test/configuration change, without an artificial short timeout | Does not authorize implementation |
| Redundant later Flutter attempt | NO NEW RESULT / DOES NOT INVALIDATE PASS | a later attempt stopped without a final result on the identical application tree | do not repeat for documentation-only changes; any future application change reopens the successive gate | Does not authorize implementation |

## Post-zero decision result

Technical direction:

`RETAIN + PROGRESSIVE REFACTOR`.

Permitted partial-rewrite candidates for later comparison:

- scenario/configuration persistence and evaluation boundary;
- JSON/full-backup orchestration shell;
- PARTE presentation/render state boundary only if profiling proves need.

Full rewrite is not supported by current evidence.

The whole-codebase technical Architecture Decision Gate is closed by the
post-zero synthesis. Deferred measurement rows remain mandatory sub-gates
before their affected implementation areas:

- current-HEAD Windows timing before startup/shutdown performance work;
- latest-HEAD Android profiling before PARTE performance work or partial
  rewrite;
- post-zero business gates before lifecycle/SCENARIO meaning changes.
