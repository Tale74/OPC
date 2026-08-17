# OPC Phase 3 ADR Candidate Register

These are lightweight decision records to write only when a later implementation phase adopts the target. They are not business-rule documents and do not authorize changes.

| ID | Candidate decision | Why it matters | Evidence / owner gate |
|---|---|---|---|
| ADR-P3-01 | Adopt hybrid feature-first with internal domain/application/data/presentation layers | Sets the physical organization and transfer-team navigation model | Target tree and current feature seams; implementation approval required |
| ADR-P3-02 | Keep one app composition boundary and inject ports | Prevents repeated wiring and hidden service locators | `main.dart`/`app.dart` responsibility audit; startup characterization |
| ADR-P3-03 | Make PREDMET the sole aggregate/application authority for applied snapshots | Prevents parallel truth in SCENARIO, IRiU, stock and exports | Product/domain home, lock, lifecycle tests |
| ADR-P3-04 | Place SCENARIO behind a published locked contract | Allows future relocation without semantic drift | SCENARIO lock; `REQUIRES EXPLICIT SCENARIO UNLOCK TASK` |
| ADR-P3-05 | Expose KATALOG as a feature contract, not a PREDMET or persistence concern | Clarifies catalog-versus-snapshot ownership | KATALOG tests and snapshot evidence |
| ADR-P3-06 | Decompose interoperability into format, validation, transfer, backup, restore and reporting | Removes monolithic JSON/backup coupling | `json_export_import.dart` concentration and JSON/recovery tests |
| ADR-P3-07 | Decompose persistence into schema, migrations, seed, repair, recovery and repositories | Protects compatibility while reducing concentration | `database.dart`, migration/recovery evidence |
| ADR-P3-08 | Use immutable snapshot inputs for PARTE and document generation | Keeps derivatives from becoming authorities | PDF/PARTE contracts and fidelity tests |
| ADR-P3-09 | Isolate platform adapters behind filesystem/notification/window ports | Preserves parity and makes platform variance explicit | Windows/Android runtime and release evidence |
| ADR-P3-10 | Adopt contract-taxonomy tests with locked and forensic lanes | Makes behavior and migration obligations discoverable | Existing flat tests, SCENARIO lock and recovery suites |
| ADR-P3-11 | Keep PODSETNIK placement provisional until signal semantics are owner-approved | Avoids encoding unresolved business meaning | Owner decision queue; no Phase 3 semantic decision |
