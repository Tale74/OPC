# OPC Task — MODULI / PAKETI Source-Learning and PODSETNIK Architecture Relocation

## Identity

- Branch: `task/OPC-MODULI-PAKETI-PODSETNIK-ARCHITECTURE-RELOCATION`
- Base commit: `f222a0981c07c6534ad3438834604ada6303dc65`
- Final commit: the immutable SHA of the commit containing this report (recorded in the final handoff after commit creation)
- GitHub branch URL: `https://github.com/Tale74/OPC/tree/task/OPC-MODULI-PAKETI-PODSETNIK-ARCHITECTURE-RELOCATION`
- GitHub commit URL: `https://github.com/Tale74/OPC/commit/<final-commit-sha>` (resolved in final handoff)
- GitHub report URL: `https://github.com/Tale74/OPC/blob/task/OPC-MODULI-PAKETI-PODSETNIK-ARCHITECTURE-RELOCATION/docs/tasks/OPC_TASK_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_RELOCATION_REPORT.md`

## OPC MANIFEST CHECK — TASK START

Manifest read: yes.

- Task class: implementation + documentation.
- Core purpose preserved: yes.
- PREDMET meaning affected: no; reminders remain derived operational state.
- Database ownership / JSON transfer / Future OPC Web affected: no.
- Windows/Android parity affected: no; shared Flutter surface and existing platform gateway are retained.
- Terminology drift risk: controlled; protected package names and PREDMET terminology are retained.
- MODULI/PAKETI/PODSETNIK drift classification: confirmed presentation/navigation ownership drift.
- Local documentation source-learning classification: authoritative policy plus historical checkpoints, requiring a concise Git-tracked migration.
- Implementation allowed: yes.
- Required gates: product terminology and payment/access; both use the existing entitlement policy without changing rights.

## Source learning

Git-tracked paths inspected include entitlement policy, settings UI/repository/table, PREDMET list and screen, CEREMONIJA segment, the reminder model/repository/coordinator/gateway, relevant tests, prior reports, pseudocode index and anti-drift manifest.

### Local documentation findings

Inspected folders: `PROJECT_DOCS`, `RESTORE_POINTS`, `BACKUPS`, and `SMOKE_LOGS` under `<LOCAL_OPC_PROJECT_ROOT>\OPC v.1`.

| Finding | Classification | Migration action |
|---|---|---|
| `OPC_v1_ZAKLJUCANA_PRAVILA.md`: PODSETNIK belongs to Srednji/Potpun and ADMINISTRATOR must be able to adjust notification time/content | authoritative but only partially migrated | summarize package/module boundary in Git pseudocode |
| `OPC_v1_ARCHITECTURE_DECISIONS.md` / `PROJECT_FLOW_AND_DELTA.md`: PREDMET is core; PODSETNIK is an operational and package/add-on module | authoritative and partly present in Git docs | make the module identity and truth boundary explicit |
| `OPC_v1_PROJECT_SOUL.md`: narrow responsibility extraction is preferred; modules must not create parallel truth | already represented by the Git manifest | apply as implementation constraint |
| Restore-point notes | obsolete/historical checkpoints for this decision | no bulk migration |
| Backup archives | preservation evidence, not current product authority | no extraction or migration required |
| Smoke logs | runtime evidence unrelated to current architecture decision | no migration |

No unresolved owner-decision conflict was found. Older local notes describing PODSETNIK as planned are historical and conflict with the newer implemented source; they are not treated as current status.

## PAKETI inventory

| Package | Evidence/status | Effective module rights relevant here |
|---|---|---|
| `osnovni` | implemented in `OpcPackageLevel`; enforced | core capabilities; no PODSETNIK and no STANJE ROBE unless separately allowed policy says otherwise |
| `srednji` | implemented and documented | PODSETNIK and NALOG CVEĆARI; selected Potpun features only through documented add-ons |
| `potpun` | implemented and documented | PODSETNIK plus advanced/package modules including STANJE ROBE |

The source policy, not scattered UI conditions, is the enforcement authority. Local documentation adds product classification detail but no fourth package.

## MODULI inventory

| Concept | Status / package / role | MODULI surface and active-use state | Truth/dependency classification |
|---|---|---|---|
| PREDMET core, KATALOG, users/roles, business policy, STATISTIKA, operational documents, JSON transfer, auth recovery | implemented core/all-package concepts | generally separate product surfaces; no module ON/OFF | core/support or PREDMET-consuming |
| PODSETNIK | implemented reminder engine; Srednji/Potpun; per-PREDMET settings | missing MODULI identity before correction; no global ON/OFF | operational/package module derived from PREDMET/CEREMONIJA facts |
| NALOG CVEĆARI | entitled Srednji/Potpun; document export identity | not a standalone MODULI settings surface | PREDMET-derived document item |
| STANJE ROBE | implemented; Potpun or Srednji add-on; ADMIN controls active use | present in MODULI; only discovered module with persisted global ON/OFF | operational inventory state, separate from PREDMET truth |
| advanced PARTE / ČITULJE, LK/OCR integrations | entitled or future/documented seams | no current MODULI surface or active-use switch | add-on/future concepts; out of scope |

## Diagnosis before correction

- PAKETI in source is a centralized entitlement model with `osnovni`, `srednji`, and `potpun`; local docs add the product allocation rules and agree that PODSETNIK is Srednji/Potpun.
- MODULI in source is both an entitlement vocabulary and a settings section, but the settings section currently renders only STANJE ROBE. Local TASK 040 decisions classify PODSETNIK as an operational/package module around PREDMET.
- PODSETNIK persistence, scheduling and delivery are implemented and correct. Its package policy and anonymized-PREDMET protection are also correct.
- The drift is UI ownership: reminder controls live only inside CEREMONIJA, the MODULI screen has no PODSETNIK identity, tests bless CEREMONIJA as the target, and Git pseudocode calls the overflow action a CEREMONIJA shortcut.
- CEREMONIJA correctly owns editable ceremony facts and currently also incorrectly acts as the only PODSETNIK settings surface.
- The minimal safe correction is a PODSETNIK-owned per-PREDMET screen reachable from MODULI and the PREDMET overflow. It reads ceremony facts, persists settings through the existing repository, and reschedules through the existing coordinator/gateway. CEREMONIJA continues to edit facts and trigger the same coordinator when facts change.
- No new database table, reminder model, scheduling algorithm, delivery path, package right, or PREDMET truth is needed.

## Implementation evidence

### PODSETNIK drift correction

The PREDMET overflow now opens `MODULI / PODSETNIK`, not `PredmetScreen(openCeremony: true)`. The new module surface can select a non-anonymized PREDMET, displays its ceremony facts as inputs, and owns only reminder enabled/delivery-time controls. `CeremonijuSegment` no longer renders those settings controls, but still reschedules through the shared coordinator after source facts change.

Changed source files:

- `lib/features/podsetnik/presentation/podsetnik_module_screen.dart`
- `lib/features/podesavanja/presentation/podesavanja_screen.dart`
- `lib/features/predmeti/presentation/lista_predmeta_screen.dart`
- `lib/features/predmeti/presentation/segments/ceremonija_segment.dart`

Changed tests:

- `test/lista_predmeta_screen_smoke_test.dart`
- `test/podesavanja_screen_smoke_test.dart`

Changed docs/pseudocode:

- `docs/OPC_PREBUILD_STANJE_ROBE_PODSETNIK_PSEUDOCODE.md`
- `docs/OPC_PSEUDOCODE_INDEX_FOR_LOGOS.md`
- `docs/OPC_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_PSEUDOCODE.md`
- `docs/tasks/OPC_TASK_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_RELOCATION_REPORT.md`

### Safe boundary and business meaning

No database schema, PREDMET meaning, JSON, IRiU, finance, KATALOG, PDF, STANJE ROBE policy/default, scheduling algorithm, notification gateway, runner or platform behavior changed. Reminder configuration remains in the existing table/repository and scheduling/delivery remain in the existing coordinator/gateway. The architectural change is ownership and navigation, not a second reminder implementation.

Tests prove Osnovni remains blocked, Srednji/Potpun remain entitled, anonymized PREDMET remains blocked, the overflow reaches the PODSETNIK identity, and the old CEREMONIJA settings key is absent from that route. Existing reminder persistence/scheduling and STANJE ROBE suites remain green.

## Validation and GitHub completion

- `flutter analyze`: PASS, zero findings.
- `flutter test`: PASS, all 117 tests.
- Build/runtime/smoke: not run, as required.
- Manifest gate: PASS against required base `f222a0981c07c6534ad3438834604ada6303dc65`.
- GitHub completion: pending commit/push verification; exact evidence is recorded in the final handoff because a commit cannot contain its own SHA.

## OPC MANIFEST COMPLIANCE — TASK END

Manifest compliance checked: yes.

- Core purpose preserved: yes.
- PREDMET meaning preserved: yes.
- Database ownership preserved: yes.
- Windows/Android parity preserved: yes.
- Existing JSON transfer preserved: yes.
- Terminology preserved: yes.
- Future Web Pristup not blocked: yes.
- Source changes within scope: yes.
- MODULI/PAKETI/PODSETNIK correction: PASS.
- Local authoritative facts migrated to Git documentation: PASS.
- If not compliant: not applicable.

Status: PASS, subject to the mandatory GitHub visibility gate.

PASS / NOT PASS: PASS.
