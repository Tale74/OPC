# Post-Scenario Forward Action Map

Every non-closed ledger or file-level concern has exactly one named successor.

| Successor type | Explicit successor | Scope |
|---|---|---|
| Characterization task | JSON interoperability characterization | JSON codecs, versioning, round-trip, conflict/rollback |
| Characterization task | Database migration/recovery characterization | schema, migrations, repair, restore, generated output |
| Characterization task | PARTE characterization/acceptance wave | preparation, workspace, media, PDF/DOCX/layout/print, transfer |
| Characterization task | KATALOG acceptance matrix | identity, picker, seed, delete, snapshots, pricing, relationships |
| Characterization task | STANJE ROBE derived-state characterization | effects, reversal, deletion, restore/import/reconciliation |
| Characterization task | IRiU seam characterization | ordering/provenance/finance/stock seams |
| Closed release-risk acceptance | RR-012 Inno Setup running-app protection | CLOSED — compile PASS; I1/I2/I3 PASS; no installation completed; no RR-012 successor |
| Completed correction | RR-008 same-identity replacement derived-state reconciliation | CURRENT PREDMET TRUTH → CURRENT DERIVED STATE; stale PARTE/reminder state no longer remains current after replacement; PODSETNIK trigger/scheduling policy remains separate |
| Completed compatibility/acceptance | PREDMET replacement audit-history preservation | CLOSED — same-identity replacement preserves destination-local `logIzmena` history and appends one local `IMPORT_REPLACE` event in the replacement transaction; separate from RR-008 current-derived-state closure |
| Completed release-required correction | PREDMET local identity / transfer rebinding / backup preflight / collision-safe creation / Case-2 selective fallback | Destination-local actor rebinding, complete deletion references, four-state FIRMA PIB/MB preflight, collision-safe creation and the bounded Case-2 selective import of only new/unambiguous PREDMET families are accepted. Case 1 and Case 3 remain supported; the former Case-2 successor is closed. |
| Compatibility test task | Restore and cross-platform release rehearsal | backup, transfer, Android/Windows and release evidence |
| Release/security work | Identity/recovery acceptance | auth, PIN, local identity and entitlement compatibility |
| Owner business decision | PODSETNIK signal owner decision task | unresolved signal taxonomy/business meaning |
| Owner business decision | policy/finance product semantics decision | package/entitlement and policy meaning |
| Explicit SCENARIO unlock prerequisite | Separate SCENARIO unlock task | only if physical movement or implementation change is requested |
| Dead-code governance | Separate authorized removal task | export_utils_replacement.dart; not removed here |
| Documentation/control work | Next-phase FULL POST-SCENARIO CONTINUITY INTAKE | repeat this control before closure |

No row ends in later, future, TBD, blank or unowned TODO.

Closed release-risk acceptance: RR-010 current-tip Windows startup/login/exit
measurement and owner-authorized login transition acceptance completed with five
successful transitions; no Windows-timing-specific successor remains.

RR-011 is closed by full Android structural acceptance; scenario-snapshot cleanup
and single-PREDMET replacement passed, and no RR-011 successor remains.
