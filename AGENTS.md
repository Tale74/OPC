# OPC Agent Control Map

This file is a navigation/control map, not the OPC knowledge base.

## Authoritative entry points
Read the current task-relevant authority before source-learning or implementation:

1. `docs/OPC_PRODUCT_AND_DOMAIN.md` — product meaning, PREDMET authority, business invariants.
2. `docs/OPC_ARCHITECTURE.md` — current technical/deployment responsibilities.
3. `docs/OPC_DEVELOPMENT.md` — development workflow, protected boundaries, QA sequence.
4. `docs/OPC_QUALITY_RELEASE.md` — quality, runtime evidence, release/acceptance rules.
5. `docs/OPC_ENGINEERING_PROFILE.md` — adopted engineering profile.
6. `docs/OPC_SOURCE_OF_TRUTH_MAP.md` and task-relevant current supporting records when the five homes point to them.
7. Local internal pseudocode/logical maps under the project-root `INTERNAL_DEVELOPMENT_CONTROL/PSEUDOCODE/` boundary when available.

Current authority beats historical reports. Later explicit owner decisions beat conflicting older material.

## Permanent engineering-profile control
The adopted `docs/OPC_ENGINEERING_PROFILE.md` profile is a permanent
cross-cutting control for every substantive OPC task, not an optional or
historical standards topic. Apply it proportionately to task scope and risk by
establishing the relevant:
- business/domain authority and requirements/traceability impact;
- architecture, dependency and data-contract impact;
- implementation and compatibility boundaries;
- verification and runtime/acceptance obligations;
- quality/release implications; and
- authoritative current-state documentation reconciliation.

Record an explicit reason when a link is not applicable; do not create
irrelevant artifacts merely to satisfy a checklist. The harness, HUMAN GATE,
internal pseudocode and external `REVIEW` evidence support this profile but do
not replace it or current authority.

## Stable OPC invariants
- PREDMET is the sole authoritative business truth for a concrete case.
- Windows and Android are equal functional peers.
- SCENARIO production behavior remains protected unless explicitly in scope.
- Source/tests prove implemented technical behavior; runtime proves observed behavior; neither may invent owner business policy.
- If authority is unresolved, report `OWNER DECISION REQUIRED` with proven facts, the exact unresolved question, valid options and consequences. Do not choose business policy.
- Canonical/private runtime databases are read-only unless an explicitly approved disposable-copy workflow says otherwise.
- `REVIEW` stays outside SOURCE. `SOURCE/REVIEW` must remain absent.
- Internal pseudocode is continuity/logical-functional material, not product runtime data or product authority.
- A material incidental finding discovered inside an approved task must be captured in task-local review evidence, classified, assessed for current-task impact and given a non-orphan disposition. It must not expand scope or become business authority by observation. Owner attention is required only for an authority/business decision, blocking condition, new authorization boundary or another explicit HUMAN GATE event.
- Do not commit/push unless explicitly authorized.

## Task flow
Use these skills as applicable:
- `.agents/skills/opc-context/SKILL.md`
- `.agents/skills/opc-source-learning/SKILL.md`
- `.agents/skills/opc-qa/SKILL.md`
- `.agents/skills/opc-review-handoff/SKILL.md`

For substantive Codex work, the pre-execution HUMAN GATE remains mandatory. After producing:
- `TASK CONTROL INTEGRITY PRECHECK — PASS`
- `TASK UNDERSTANDING CONFIRMATION`
- `CONTINUITY ESTABLISHMENT CONFIRMATION`
- `DOCUMENTATION READING CONFIRMATION`
- `OWNER CONFIRMATION GATE — WAITING FOR EXPLICIT CONTINUE`

STOP until explicit owner authorization.

## QA invariant
For code/config/schema/build-affecting tasks:
targeted tests when relevant → `flutter analyze` PASS → full `flutter test` PASS → authorized build.

`flutter analyze` and full `flutter test` run sequentially, never in parallel with another Flutter/Dart/Gradle QA process. Do not impose an arbitrary elapsed-time timeout; incomplete output or missing exit status is not PASS.
