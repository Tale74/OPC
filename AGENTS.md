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

## Mandatory post-drift recovery-plan continuity
During the current post-drift recovery phase, every substantive OPC task must
physically read `docs/OPC_POST_DRIFT_RECOVERY_PLAN.md` before task planning or
substantive source-learning. The task report must include the resolved path,
`READ = YES`, the current recovery phase, the immediately preceding accepted
phase or handoff, the single next plan-authorized action relevant to the task,
and confirmation that the task does not skip, reorder, reinterpret or silently
extend the plan. If continuity cannot be established, stop with:
`STOP — RECOVERY PLAN CONTINUITY NOT ESTABLISHED`.

The recovery plan is a governance and continuity control. It does not replace
the detailed residual/deferred ledger or matrix, create product requirements,
or override the engineering-profile, HUMAN GATE, active-source, donor-control,
Docs-as-Code or anti-drift controls.

## Mandatory active-source authority gate
Before source-learning, implementation-causality analysis or any `SOURCE` or
test modification, apply the permanent gate in
`docs/OPC_ACTIVE_SOURCE_AUTHORITY_AND_DONOR_CONTROL.md`. Resolve the current
physical control-package location from current authority, physically read all
five logical inputs, verify current provenance/integrity and the applicable
active-source hashes, then report the five inputs individually. The external
package is current local-only control evidence, not implementation authority
or a donor; prior memory or a prior PASS is not a substitute. Any missing,
ambiguous, unread or unverified input requires:
`ACTIVE SOURCE AUTHORITY PRECHECK — STOP — <reason>`.

## Independent Logos review control
For every substantive Codex task, report or review, Logos must independently
establish task understanding, current continuity and documentation reading
before writing, approving or assessing the result. The review must compare the
Codex output with current OWNER authority, current documentation, source/tests/
runtime evidence where relevant, dependency position and anti-drift controls;
the latest report or conversational memory alone is never sufficient. Logos
must recommend STOP/correction on authority, continuity, drift, unsupported
inference, source/target conflation or insufficient evidence. The reusable
procedure and handoff evidence requirements live in
`.agents/skills/opc-review-handoff/SKILL.md`; this entry is navigation, not a
second governance rulebook.

For substantive Codex work, the pre-execution HUMAN GATE remains mandatory. After producing:
- `ACTIVE SOURCE CONTROL INPUTS` with five individual confirmations, each with
  `resolved physical path`, `READ = YES` and
  `current provenance/integrity: PASS`
- `ACTIVE SOURCE AUTHORITY PRECHECK — PASS`
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
