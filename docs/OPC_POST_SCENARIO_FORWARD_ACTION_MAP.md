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
| Release-risk correction successor | RR-005 provenance/snapshot orphan cleanup and hard-delete contract correction with disposable acceptance | 34 provenance + 2 snapshot invalid-current-data findings proven by source analysis and disposable reproduction; no canonical mutation |
| Release-risk acceptance successor | Current-tip Windows startup/login/exit measurement | historical timing exists; current-tip measurement remains inconclusive |
| Release-risk acceptance successor | Android PREDMET lifecycle/referential parity acceptance | shared Dart flows characterized; physical parity remains inconclusive |
| Owner business decision | Derived reminder/PARTE replacement-state semantic acceptance | observed local-ID replacement retention remains owner-gated/inconclusive |
| Compatibility test task | Restore and cross-platform release rehearsal | backup, transfer, Android/Windows and release evidence |
| Release/security work | Identity/recovery acceptance | auth, PIN, local identity and entitlement compatibility |
| Owner business decision | PODSETNIK signal owner decision task | unresolved signal taxonomy/business meaning |
| Owner business decision | policy/finance product semantics decision | package/entitlement and policy meaning |
| Explicit SCENARIO unlock prerequisite | Separate SCENARIO unlock task | only if physical movement or implementation change is requested |
| Dead-code governance | Separate authorized removal task | export_utils_replacement.dart; not removed here |
| Documentation/control work | Next-phase FULL POST-SCENARIO CONTINUITY INTAKE | repeat this control before closure |

No row ends in later, future, TBD, blank or unowned TODO.
