# Bounded Implementation Correction Plan

**Status:** `NO IMPLEMENTATION AUTHORIZED BY THIS DOCUMENTATION TASK`

The current re-baseline found no proven source defect in the bounded URNA/PEPEO paths. Therefore there is no implementation correction to execute now.

If a separately authorized task is opened, it must remain limited to a proven gap and follow this order:

1. identify the exact owner contract and affected source path;
2. reproduce the defect with a disposable database/artifact where database behavior is implicated;
3. make the smallest recovery-worktree correction only;
4. add or adjust only the relevant focused test;
5. run the locked sequential QA/build gates;
6. repeat platform-specific runtime acceptance with exact artifact hashes;
7. update as-built documentation and evidence without changing business authority.

Current evidence-only follow-ups are:

- independently repeat Windows secondary in-app delivery acceptance with exact `OPC.exe` and `data/app.so` identity;
- keep the canonical DB read-only; a normal runtime hash change is recorded only as an observation and is not itself a correction or follow-up trigger;
- keep release/publication and GitHub synchronization as separate gates.
