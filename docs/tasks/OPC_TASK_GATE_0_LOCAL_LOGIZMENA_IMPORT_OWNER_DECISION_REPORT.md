# OPC task report — Gate 0 local `logIzmena` import owner decision

**Status:** OWNER DECISION RECORDED — IMPLEMENTATION GAP IDENTIFIED — NO APPLICATION CHANGE
**Datum:** 26. jul 2026.

## 1. Git baseline

- Base branch: `task/OPC-GATE-0-PREDMET-VERSION-IMPORT-FACT-CHECK`
- Base SHA: `49aab54710ae166f981279faf4cf725d1af45dfc`
- Task branch: `task/OPC-GATE-0-REPLACEMENT-IMPORT-HISTORY-OWNER-DECISION`
- Final SHA: Git object ID commita koji sadrži ovaj report; navodi se u completion odgovoru.

## 2. Source evidence

- `logIzmena` exists and is related to PREDMET by `predmetId`.
- individual PREDMET JSON does not include `logIzmena`;
- full database backup includes `logIzmena`;
- current replacement preserves the local technical PREDMET id but deletes local `logIzmena`;
- current replacement does not append a local replacement event;
- current save/close log paths use snapshot values that require a later privacy/retention audit.

## 3. Owner decision

- `logIzmena` remains a local audit record;
- individual PREDMET JSON does not transfer foreign logs or foreign user ids;
- new import records a local import event;
- replacement preserves the existing local log and appends a local replacement event;
- local actor and local timestamp are authoritative for that event;
- full backup/restore remains a separate operation;
- `logIzmena` must not become parallel PREDMET business truth.

## 4. Documentation changes

Created:

- `docs/tasks/OPC_TASK_GATE_0_LOCAL_LOGIZMENA_IMPORT_OWNER_DECISION_REPORT.md`

Updated:

- `docs/OPC_OWNER_DECISION_REPORT.md`
- `docs/OPC_DOCUMENTATION_SEMANTIC_OWNER_DECISION_QUEUE.md`
- `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`
- `docs/OPC_PREDMET_IDENTITY_VERSION_CHANGELOG_GAP_REGISTER.md`
- `docs/OPC_PREDMET_OWNER_REVIEW_QUEUE.md`

## 5. Scope boundary

- application, test, database, migration, build and runtime changes: 0;
- deletion: 0;
- Git history rewrite: not performed;
- current runtime deviation is documented, not corrected;
- future implementation requires a separate authorized technical task.

## 6. Gate

`LOCAL LOGIZMENA IMPORT POLICY RECORDED — CURRENT REPLACEMENT DELETION IDENTIFIED AS IMPLEMENTATION GAP`
