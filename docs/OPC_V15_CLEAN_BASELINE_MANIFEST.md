# OPC v1.5 clean baseline manifest — 2026-10-13

## Baseline source and authority

- Repository: OPC source checkout on `codex/opc-v1.5-clean-baseline`.
- Parent checkpoint before closure records: `c37b7d23541408414b6061e6cdb257039762ce43`.
- Final guide implementation evidence: the OWNER-approved 2026-10-12 state,
  documented in `OPC_CURRENT_DEVELOPMENT_STATE.md` §24 and its linked
  traceability/QA package.
- Protected control CSV SHA-256:
  `3FA780EE45874434E11B9B198A5D8855250541CEEE1E5AC543EB8E652EF1CE26`;
  physical check remains `20/28` literal matches with all 8 differences
  provenance-resolved. No rebaseline or claim of `28/28`.
- Product baseline includes accepted source, regression tests, build inputs,
  current state/quality/roadmap records and the offline 33-chapter guide asset.
- The exact committed tree and reviewed file list are in the external
  machine-readable manifest. They are finalized after review and local Git
  publication; this source document intentionally does not contain a
  self-referential commit/tree hash.

## Excluded and retained locally

Private runtime screenshots and records, embedded old review snapshots,
ignored caches/build outputs, local properties, local-only authority package,
pseudocode/experience evidence, logs and the full backup are preserved but not
published. See `OPC_V15_WORKTREE_CLASSIFICATION_AND_CLEANUP_LEDGER.md` and the
external exact-path ledger.

## Reproducibility boundary

The accepted Windows/Android release artifacts and guide resource hashes are
listed in `OPC_V15_OWNER_FINAL_DEVELOPMENT_ACCEPTANCE.md`. They correspond to
the already QA-accepted product state. This closure is documentation and
repository housekeeping; no product source/build input was changed after that
state except closure documentation. Any later discovery of a source/build
input difference invalidates reuse and requires separate authorized QA.
