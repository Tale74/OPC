# OPC Phase 3 Target SOURCE Tree Proposal

This is a physical target proposal, not a move manifest. It follows the logical model and may be implemented only by a later authorized migration phase.

```text
lib/
  app/
    composition/
    runtime/
    navigation/
  domain/
    shared/
      identity/
      money/
      result/
      time/
      validation/
  features/
    predmeti/
      domain/
      application/
      data/
      presentation/
    scenario/
      domain/
      application/
      data/
      presentation/
    iriu/
      domain/
      application/
      data/
      presentation/
    katalog/
      domain/
      application/
      data/
      presentation/
    stanje_robe/
      domain/
      application/
      data/
      presentation/
    parte/
      domain/
      application/
      data/
      presentation/
      rendering/
    documents/
      domain/
      application/
      rendering/
      presentation/
    policy_finance/
      domain/
        policy/
        finance/
      application/
      presentation/
    podsetnik/
      domain/
      application/
      data/
      presentation/
    identity_settings/
      domain/
      application/
      data/
      presentation/
    interoperability/
      domain/
      application/
      presentation/
  infrastructure/
    persistence/
      schema/
      migrations/
      recovery/
      seed/
      repositories/
    interoperability/
      codecs/
      filesystem/
      persistence_adapters/
    generated/
  platform/
    windows/
    android/
    shared/
test/
  support/
  fixtures/
  domain/
  application/
  data/
  contracts/
  migration/
  characterization/
  platform/
  integration/
  forensic/
```

## Why hybrid feature-first

Feature-first placement makes PREDMET, SCENARIO, IRiU, KATALOG, stock, reminders, PARTE, documents, policy/finance and interoperability workflows discoverable to a transferring team. Internal `domain/application/data/presentation` layers prevent UI, persistence and policy from collapsing into the feature root. `app`, `infrastructure`, `platform` and `domain/shared` are reserved for genuinely cross-feature responsibilities. A layer-first tree would hide business ownership; a purely feature-local tree would duplicate persistence/platform composition.

## Major placement rules

- `features/predmeti/domain` is the PREDMET aggregate and lifecycle boundary. It may expose ports, not Drift tables.
- `features/scenario` is the future logical home of the currently nested locked implementation. Physical relocation is prohibited until an explicit SCENARIO unlock task.
- `features/iriu` receives ordering/selection contracts currently under PREDMET when extraction preserves the invariant.
- `features/katalog` becomes the visible home for catalog domain and application contracts; persistence tables remain under infrastructure.
- `features/policy_finance` is the explicit home for policy and finance projections, with separate `domain/policy` and `domain/finance` sub-blocks; neither becomes PREDMET authority.
- `features/interoperability/application` owns single-PREDMET transfer, full-backup and restore coordination. `infrastructure/interoperability` supplies codecs, filesystem transport and persistence adapters through ports.
- `infrastructure/persistence/generated` contains generated Drift output; hand-written repository and migration policy remain outside generated code.
- `platform` contains OS adapters only. Shared workflows depend on ports, never on Windows/Android packages.
- Test-only fixtures, carriers and deterministic clocks live under top-level `test/support` and `test/fixtures`, never under production `lib`. A helper belongs in production only when it is genuinely runtime-shared and named as such.

No target directory is permission to create a second PREDMET authority, a second SCENARIO engine, or a generic `utils`/`core_v2` dumping ground.
