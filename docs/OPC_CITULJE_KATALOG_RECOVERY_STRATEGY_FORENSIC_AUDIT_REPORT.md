# OPC ČITULJE / KATALOG Recovery Strategy Forensic Audit

Date: 2026-08-13

Role: Codex 5.6 Sol, High, audit/forensics only

Production-data authority: read-only

Required next execution role: Codex 5.6 Luna, High, phase-gated implementation

## A. Baseline / authority / branch / SHAs

- Public repository: `https://github.com/Tale74/OPC`.
- Public baseline branch: `task/OPC-CANONICAL-KATALOG-IRIU-PIPELINE-WINDOWS-CLOSURE`.
- Local and public baseline HEAD were independently confirmed as
  `078c54fc2bcd39a420161236616d547ddc879825`.
- Audit branch: `task/OPC-CITULJE-KATALOG-RECOVERY-FORENSIC-AUDIT`.
- Canonical database examined read-only:
  `C:\Users\Steva\Documents\opc_v4_release.sqlite`.
- Canonical database size: `82,829,312` bytes.
- Canonical database SHA-256 before analysis:
  `A09A2D1EF8B9D7B62FA1B699637273F912A4164CFFC1C58C916FE36DCD37BB39`.
- Canonical database `user_version = 27`, `journal_mode = delete`,
  `PRAGMA integrity_check = ok`.
- Exact owner backup examined read-only:
  `C:\Users\Steva\Downloads\KORICE\OPC_backup_13082026_1842.json`.
- Backup size: `107,658,616` bytes.
- Backup SHA-256:
  `189F345B73A0377A72FE398AADEB723005EA444B7B54817F3C12F205DFEF9855`.
- Backup header is `OPC_BACKUP`, schema `8`, entity
  `FULL_DATABASE_BACKUP`, database identity `OPC`, stock policy
  `schema16_stock_complete_v1`, exported at
  `2026-08-13T18:42:39.617690`.

No application source, canonical data, forensic source data or user backup was
changed during this audit. The only intended repository change is this report.

## B. Evidence reviewed

The required closure reports and authority documents were read, including the
canonical KATALOG/IRiU Windows closure, repaired-DB visual closure, real Windows
runtime closure, cross-device continuity closure, authoritative dependency
plan, current development state, source-of-truth map, owner decision index,
backup policy summary, IRiU pseudocode and SCENARIO policy material.

Source and history reviewed included:

- `lib/core/database/database.dart` and table declarations;
- `lib/core/utils/json_export_import.dart`;
- `lib/core/utils/stable_id_generator.dart`;
- `lib/features/predmeti/data/iriu_repository.dart`;
- `lib/features/predmeti/data/predmeti_repository.dart`;
- both production picker implementations in `iriu_segment.dart` and
  `iriu_row_tile.dart`;
- `iriu_display_name_resolver.dart`;
- SCENARIO module persistence, PARTE preparation/media and full-restore
  coordination;
- commits `520b189`, `0857b70`, `9b7608d`, `3b4442b`, `b1cc2d71`,
  `1d71dc5` and `078c54f` where relevant.

Read-only SQLite queries and a direct parse of the exact 107 MB backup were
used. Three focused suites also passed, 16 tests total:

- citation seed reopen/idempotency;
- IRiU catalog display-name behavior and repair characterization;
- PREDMET referential lifecycle/full-restore characterization.

The owner's visible repeated `ČITULJA POLITIKA II/75 mm — Beograd` rows are
not a UI-only duplication. The database contains 86 physical rows for that
exact tuple, IDs `100` through `4443`, with 86 distinct stable IDs.

## C. Canonical DB current duplication counts

The citation business grouping used here is the exact source seed tuple
`(interni_naziv_kategorije, naziv, cena)`. This is appropriate for the two
built-in citation price lists because the current seed guard uses exactly that
tuple. All duplicates were additionally checked across all other article
fields: `fotografija` and `fotografija_path` are null/equal. Only physical
integer ID and stable ID differ.

| Category | Physical rows | Exact business tuples | Duplicate groups | Excess rows | Distinct non-empty stable IDs |
|---|---:|---:|---:|---:|---:|
| `CITULJA_POLITIKA` | 2,924 | 34 | 34 | 2,890 | 2,924 |
| `CITULJA_NOVOSTI` | 1,459 | 17 | 17 | 1,442 | 1,459 |
| Combined | 4,383 | 51 | 51 | 4,332 | 4,383 |

Every Politika tuple occurs 86 times. Fourteen Novosti tuples occur 86 times;
the three Online tuples occur 85 times. This is historical production
contamination, not a count copied from a previous report.

Canonical citation references are:

- eight IRiU rows;
- four distinct citation stable IDs;
- zero references from stock items, applied effects or stock consequences.

The eight IRiU rows span six `ZAVRŠEN`, one `ZATVOREN` and one `OTVOREN`
PREDMET. All four referenced catalog IDs already are the minimum integer-ID
survivors of their exact duplicate groups:

| Catalog row | Tuple | IRiU references |
|---:|---|---:|
| 78 | Politika I/90 mm — Cela zemlja | 2 |
| 89 | Politika 1/4 strane — Cela zemlja | 1 |
| 101 | Politika II/90 mm — Beograd | 2 |
| 112 | Novosti Print 1/4 stupca | 3 |

A separate whole-database safety fact must not be hidden by
`integrity_check = ok`: `PRAGMA foreign_key_check` reports 182 existing
violations:

| Child table | Orphans |
|---|---:|
| `iriu_provenance` → `iriu` | 164 |
| `predmet_scenario_snapshots` → `predmeti` | 7 |
| `log_izmena` → `predmeti` | 6 |
| `ceremony_reminder_settings` → `predmeti` | 3 |
| `parte_pripreme` → `predmeti` | 2 |

SQLite foreign-key enforcement is currently off, as explicitly characterized
by the test suite. These orphans are a mandatory independent stop condition
for canonical promotion or a sole-backup reset.

## D. FULL Backup JSON duplication counts

The exact backup contains 4,470 total `katalogArtikli` rows. All have non-empty,
globally unique `stableArticleId` values. Its citation footprint exactly equals
the canonical footprint:

| Category | Physical rows | Exact business tuples | Duplicate groups | Excess rows | Distinct stable IDs |
|---|---:|---:|---:|---:|---:|
| `CITULJA_POLITIKA` | 2,924 | 34 | 34 | 2,890 | 2,924 |
| `CITULJA_NOVOSTI` | 1,459 | 17 | 17 | 1,442 | 1,459 |
| Combined | 4,383 | 51 | 51 | 4,332 | 4,383 |

The owner-visible II/75 Beograd tuple occurs 86 times in the JSON. Within each
duplicate group, every nonidentity catalog value is the same; physical `id`
and nondeterministically generated `stableArticleId` are the only differences.

## E. Backup references to duplicated KATALOG IDs

The JSON contains exactly the same eight IRiU citation references and four
distinct referenced stable IDs described in section C. No citation stable ID
is referenced by `stanjeRobeStavke`, `stanjeRobeAppliedEffects` or
`stanjeRobePosledice`. No additional citation ID was found inside SCENARIO
snapshot/provenance payload fields.

This favorable current reference distribution simplifies the known citation
repair, but it must not become a hardcoded assumption. An implementation must
inventory and remap every stable-ID holder before deletion, including:

- `iriu.katalog_stable_article_id`;
- `stanje_robe_stavke.stable_article_id`;
- `stanje_robe_applied_effects.stable_article_id`;
- `stanje_robe_posledice.katalog_stable_article_id`.

It must also scan structured JSON columns for a future or legacy embedded
reference before committing.

## F. Current recurrence-path audit

| Path | Current behavior | Classification |
|---|---|---|
| Database open/startup citation seed | Since `b1cc2d71`, checks exact category/name/price before insert. Reopen test passes. | Closed for new exact seed duplicates |
| New database initialization | Seeds the intended 34+17 citation tuples once. | Closed |
| PREDMET creation | Creates category-only IRiU rows; does not create catalog articles. | Closed |
| Scenario reconciliation / OSNOVNI rows | Creates or updates IRiU category rows, not catalog articles. | Closed for catalog duplication |
| Migration/additive recovery | No current citation bulk insert outside guarded seed. | Closed on reviewed code |
| KATALOG user create/edit | Generates a stable ID and has no business-tuple uniqueness constraint. This is permitted for general user articles but does not protect built-in citation invariants at the DB boundary. | Partial structural guard |
| Single-PREDMET JSON import | Does not import global catalog rows; raw IRiU stable references may remain unresolved. | Does not multiply catalog; reference risk remains |
| FULL backup restore | Deletes target catalog and inserts every physical JSON row. | Open contamination-ingestion path |
| Legacy PAKET compatibility | Current normal SCENARIO path materializes category snapshots; no active PAKET citation catalog seeder was found. | Closed on reviewed production chain |
| Test/dev seed | Dedicated citation seed uses the same guard; test-only photo catalog is separately gated. | Closed for citation recurrence |

The correct aggregate classification is `RECURRENCE PARTIAL`: ordinary reopen
no longer creates another 51 rows per start, but restore can reproduce the
entire contaminated physical state. A backup is an active recovery input, so
this cannot be called globally closed.

## G. Historical contamination vs recurrence distinction

- `RECURRENCE PARTIAL`: startup/open seeding is corrected; contaminated full
  restore remains dangerous and there is no database-level citation business
  uniqueness constraint.
- `PRODUCTION DATA CONTAMINATED`: the canonical database still contains all
  4,332 excess rows.
- Prior forensic-copy deduplication proves an algorithm on a copy. It does not
  prove canonical cleanup.
- No clean post-repair backup exists yet.
- No clean-room restore from a clean backup has been accepted yet.

Therefore source fix, targeted test, copy proof, canonical cleanup, clean
backup proof and clean restore proof remain six distinct statuses.

## H. FULL Backup export contract

`_serijalizujBackup` selects the complete physical `katalog_artikli` table and
serializes each `KatalogArtikliData` row directly. It does not group, normalize
or reject duplicate business tuples. Stable IDs and integer IDs are preserved.

Schema-8 export from the examined database contains:

| Section | Rows |
|---|---:|
| PREDMET | 47 |
| IRiU | 631 |
| PREDMET SCENARIO snapshots | 8 |
| IRiU provenance | 181 |
| Contacts | 1 |
| IRiU lifecycle decisions | 40 |
| Users / firm / app settings | 1 / 1 / 1 |
| KATALOG articles / config | 4,470 / 29 |
| Document / PARTE templates | 5 / 2 |
| Change log | 229 |
| Stock items / effects / consequences | 33 / 53 / 46 |
| Logical reminder configs | 8 |

Export deliberately filters orphan log and reminder rows. It does not filter
or validate orphan scenario snapshots/provenance.

## I. FULL Backup restore contract

The source-backed sequence is:

```text
empty/new DB
  → schema creation and default KATALOG seed
  → beforeOpen additive recovery, guarded citation seed, stable-ID work
  → user confirms destructive FULL restore
  → transaction deletes target KATALOG/config and most transferred tables
  → every payload KATALOG row is insertOrReplace'd by physical ID
  → payload PREDMET, IRiU, snapshots/provenance and related rows are inserted
  → missing stable IDs are backfilled and known stock-seed IDs canonicalized
  → later reopen sees each citation tuple, adds none, removes none
```

There is no restore-time business-tuple deduplication and no general
duplicate-to-survivor remap. The existing stable-ID canonicalizer covers known
stock seed identities, not citation rows.

Consequently, restoring the examined backup into a clean database will restore
2,924 Politika and 1,459 Novosti rows. Current startup should not add a 87th
copy, but it will not remove any of the 4,332 excess rows either.

IRiU rows are inserted with their stored category, name, stable ID, unit-price
snapshot, quantity and amount. They are therefore structurally independent of
receiver catalog display/price for ordinary viewing. Unknown stable IDs are
permitted. Full restore does not currently run a general remap.

## J. Backup completeness / losslessness assessment

The label `FULL_DATABASE_BACKUP` is broader than the implemented contract.

| Dataset | Schema-8 behavior | Classification |
|---|---|---|
| PREDMET, IRiU, contacts | Exported/restored | Included authority |
| KATALOG articles/config | Exported/restored physically | Included but contaminated |
| PREDMET SCENARIO snapshots/provenance | Exported/restored | Included, but current payload has 171 orphans |
| SCENARIO module and 1,021 definitions | Not exported; not deleted/restored | Unsafe omission for editable policy |
| OSNOVNI PAKET module setting | Not exported | Unsafe omission; affects future PREDMET creation |
| IRiU lifecycle decisions | Exported/restored | Included |
| Logical reminder configs | Exported; device notification IDs regenerated | Intentional derivative regeneration |
| Change log | Valid-parent rows exported; six current orphans omitted | Partial by design, requires disclosure |
| Stock 33/53/46 | Exported under declared schema-16 stock policy | Included |
| App/firm/user/document settings | Exported as intended | Included |
| Installation security/auth audit | Preserved locally, not transferred | Intentional installation-local state |
| PARTE templates | Exported | Included |
| Three PARTE preparations and owned media | Not exported; preparations deleted and media purged on restore | Intentional current policy, but continuity-lossy |

The owner-decided PIB/matični-broj mismatch guard is also still documented as
not implemented. That is an additional restore-identity risk even though firm
data itself is serialized.

On a new DB, missing SCENARIO definitions are regenerated from the application
version's code/assets. On an existing DB, they survive rather than being
replaced even though the UI says all data will be replaced. Neither behavior
reproduces the source database as a backup contract.

The examined payload itself contains seven of eight snapshots pointing to
nonexistent PREDMET IDs and 164 of 181 provenance rows pointing to nonexistent
IRiU IDs. With foreign keys off, restore can reproduce these orphans; with
enforcement enabled it can fail. There is no complete preflight for them.

Result: schema-8 full-backup losslessness is **not proven** and this JSON must
not be the sole authority for deleting/rebuilding the canonical database.

## K. DB-first recovery evaluation

DB-first retains the richest available state and the original rollback unit.
It allows exact copy-level measurements, an explicit stable-ID remap, byte and
semantic comparisons, and promotion only after real runtime proof. PREDMET
snapshots can be held invariant while only references are remapped.

Its risks are manageable but real:

- 182 pre-existing FK violations must be separately classified;
- all reference holders must be remapped before duplicate deletion;
- a wrong survivor policy could break open-row reselection;
- running current source would invoke an unauthorized historical name repair;
- a promoted copy must retain SQLite metadata, permissions and expected path;
- the app must be fully closed throughout copy/promotion.

With the gates in sections T–V, DB-first safety is high. Repaired-copy
promotion is safer than an untested in-place canonical transaction because the
original file remains an immediate rollback artifact.

## L. JSON-first recovery evaluation

JSON-first is low safety for this state:

- 4,332 removed stable IDs may require coordinated rewrites;
- the 107 MB payload contains 171 orphan SCENARIO rows;
- schema 8 omits SCENARIO module/definitions and PARTE preparation/media state;
- the owner-required firm identity mismatch guard is not implemented;
- restore performs its own default seeding and transformations;
- current startup repair can rename historical PREDMET snapshots;
- normalized JSON would be a newly manufactured authority with weaker
  rollback/audit properties than the original SQLite file;
- a DB reset would discard data that the JSON never serialized.

Editing the JSON may be useful only as a derived test fixture after a DB-first
canonical truth is established. It is not an acceptable primary recovery
strategy.

## M. Recommended recovery strategy

`DB-FIRST RECOMMENDED`.

The implementation must be phase-gated:

1. close recurrence and historical-snapshot hazards in source;
2. extend/clarify the backup contract and add orphan preflight;
3. classify and safely repair or explicitly preserve every current FK orphan
   on a forensic copy;
4. deduplicate citations on that copy with reference remap;
5. prove semantic invariance and real Windows reopen behavior;
6. promote the repaired copy with the original canonical file retained;
7. generate a clean backup from the promoted canonical truth;
8. restore into a fresh disposable database and compare semantics;
9. only then call recovery closed.

This is not a hybrid JSON-first reset. JSON is an output and acceptance
artifact of the DB-first recovery.

## N. KATALOG uniqueness/stable-ID semantics

The KATALOG article table has physical integer `id`, nullable
`stable_article_id`, category, name, price and optional photo fields. The
database has a partial unique index only on non-empty stable ID. It has no
business-tuple uniqueness key.

`generateCatalogArticleStableId()` combines current microseconds and random
bytes. It is nondeterministic. Thus inserting the same business tuple on each
startup historically produced different stable IDs, all valid under the
unique stable-ID index.

For current built-in citations:

```text
business identity = exact (category internal name, article name, price)
physical/selection identity = stableArticleId of one stored catalog row
```

The tuple is source-proven by the guarded seed. It must not be generalized to
all user-defined KATALOG articles without an owner rule; two user rows might
intentionally share name/price while differing in meaning or future metadata.

A stable ID identifies a physical/selectable article record. It is not a
deterministic encoding of citation business identity.

## O. Safe duplicate survivor/remap model

For each of the 51 exact built-in citation groups:

1. verify every nonidentity field is equal;
2. collect all stable-ID references across all tables/JSON fields;
3. select a referenced stable ID if only one referenced candidate exists;
4. if several equivalent candidates are referenced, use the minimum physical
   integer ID as the deterministic survivor and remap all others;
5. if reference holders imply non-equivalent semantics, stop that group;
6. update references from every removed stable ID to the survivor stable ID;
7. do **not** change IRiU `naziv_prikaz`, `cena`, `kom` or `iznos`;
8. delete only the now-unreferenced duplicate catalog rows.

In current data, the four referenced stable IDs already belong to minimum-ID
survivors, so the eight existing citation IRiU references require no value
change. The model must still generate and validate the complete removed →
survivor map.

The model is ready for citation duplicates, subject to the independent FK and
historical-repair stop gates.

## P. KATALOG→IRiU current production path inventory

There is one intended persisted snapshot shape but multiple implementation
paths:

| Path | Picker/write behavior |
|---|---|
| Add from KATALOG | `_KatalogPickerDialog` → `dodajStavku` writes category, article name, stable ID, price and amount |
| Existing-row reselection | `_ArtikliPickerContent` → `azurirajKatalogIzborStavke` writes the same fields |
| New PREDMET / OSNOVNI PAKET | Category-only row, no selected article ID |
| Scenario-managed addition | Category-only row, no selected article ID |
| Legacy condition reconciliation | Category-only row through repository helpers |
| Manual add (non-Windows) | PREDMET-local `RUCNO_*` snapshot, not a catalog selection |
| Single-PREDMET import | Direct raw IRiU insert followed by current repair helper |
| Full restore | Direct raw physical insert |
| Ordinary edit | Can edit snapshot name/quantity/amount without reselection |

Therefore the answer to "how many independent paths" is **multiple**. For
concrete user selection there are two separate UI picker implementations and
two repository mutations, although both currently persist the same shape.
Import/restore are additional direct write paths.

The canonical target contract should be a shared immutable selection value:

```text
CatalogSelectionSnapshot {
  categoryInternalName,
  stableArticleId,
  selectedDisplayName,
  appliedUnitPrice
}
```

One repository command should apply that value for both add and reselection;
quantity/amount rules remain explicit. Category-only rows need a separate
type/contract so they cannot masquerade as selected articles.

## Q. CRNINA divergent helper/picker audit

Git evidence does **not** show a current CRNINA-specific picker. Commit
`3b4442b` changed CRNINA from `FIKSNA` to `KATALOSKA`; it now reaches the same
existing-row article picker as other catalog categories.

The proven divergence is instead the new display resolver introduced by
`9b7608d`. It originally preferred current category label over stored PREDMET
snapshot. Later stored-first logic protected good snapshots, but `078c54f`
added `repairMalformedIriuCatalogSnapshots()` on every database open and after
single-PREDMET import.

On the current canonical database that repair has exactly one candidate:

- IRiU row `1732`, PREDMET `113`, status `OTVOREN`;
- category/stored snapshot `CRNINA` / `Crnina`;
- selected stable ID resolves to article `Flor`;
- stored price `100`, quantity/amount equivalent `3` / `300`.

The newly locked owner rule says that this old snapshot is not automatically
wrong. Consequently, the automatic open/import mutation is unauthorized even
though its focused tests pass. A test proves implemented behavior, not business
authorization.

CRNINA no longer bypasses concrete picker persistence, but the divergent
resolver/repair architecture remains partially present. The next task must
remove automatic historical mutation, not add another CRNINA fallback.

## R. Other divergent helper/picker audit

Other divergence remains:

- add and reselection have separate picker widgets and callbacks;
- `resolveIriuCatalogPickerCategoryKeys` specially merges Politika and Novosti
  choices and may change the row category during reselection;
- category-only SCENARIO/OSNOVNI materialization and concrete article selection
  share the same nullable row shape without an explicit selection-state type;
- import and restore bypass the picker/repository selection command;
- the display resolver can fall back from stored data to live category labels;
- the startup/import repair is an independent hidden writer.

The citation union is currently intentional and carries the selected article's
actual category, name and stable ID. It is not the source of the catalog row
multiplication, but it is another path that must be covered by the common
selection contract.

No other category-specific code was found that creates physical citation
catalog duplicates. `repairKnownCatalogIntegrity()` has separate built-in
CRNINA type and SLIKA category migrations; those are category schema repairs,
not article selection.

## S. Historical PREDMET immunity matrix

Stored IRiU `naziv_prikaz`, `cena`, `kom` and `iznos` are the business snapshot.
The stable catalog reference supports identity/reselection and selected stock
integration; it must not become authority for retroactive rename/reprice.

| Lifecycle | Display/name truth | Price/amount truth | KATALOG need | Dedup impact |
|---|---|---|---|---|
| `OTVOREN` | Stored IRiU snapshot; user may explicitly edit/reselect | Stored unit price/amount; explicit edit rules apply | Needed for future picker/reselection | Remap stable ID; never auto-rename/reprice |
| `ZAVRŠEN` | Stored snapshot, immutable lifecycle | Stored snapshot | Not needed for ordinary display | Reference may be remapped, fields unchanged |
| `ANONIMIZOVAN` | Stored/redacted PREDMET boundary and stored IRiU | Stored snapshot | Not needed for ordinary display | Reference may be remapped, fields unchanged |
| `ZATVOREN` (present legacy/current state) | Stored snapshot | Stored snapshot | Treat as historical unless explicit lifecycle permits edit | Same invariant |

The eight citation rows prove that a cleanup can preserve names and amounts;
all their references already target selected survivors. However global
historical immunity is only partial while automatic startup/import name repair
exists. Old `Crnina` must not be rewritten to `Flor` without a separately
authorized migration policy and source-at-formation proof.

Open-PREDMET edit safety after dedup is structurally plausible if stable IDs are
remapped and survivors retained, but real runtime reselection after actual
dedup has not been accepted. It remains partial.

## T. Canonical dedup safety procedure

Safest method: **repaired-copy promotion**, not an initial in-place production
transaction.

1. Ensure every OPC process is closed; record process evidence.
2. Re-hash canonical DB and compare with the approved input hash.
3. Make at least two verified byte copies on distinct locations; hash both.
4. Preserve the original canonical file under a timestamped rollback name.
5. Work only on a forensic copy.
6. Record schema, page/journal state, row counts, business semantic digests,
   `integrity_check` and complete `foreign_key_check`.
7. Classify all 182 current FK violations with an owner/data rule; stop on any
   authoritative orphan whose parent cannot be reconstructed safely.
8. Enumerate only exact built-in Politika/Novosti groups and prove equality of
   all nonidentity fields.
9. Generate deterministic survivors and a complete stable-ID remap ledger.
10. In one transaction, remap every reference holder, verify zero references
    to removal IDs, then delete exactly 4,332 rows.
11. Commit only if expected counts are 34/17, duplicate groups are zero,
    `integrity_check = ok` and the approved FK result is exact.
12. Byte/semantic-compare every PREDMET and IRiU field except explicitly
    approved stable-ID remaps; names/prices/quantity/amount must be identical.
13. Open the repaired copy with a build that has no automatic historical
    snapshot writer; reopen twice and remeasure 34/17.
14. Verify KATALOG visually, including II/75 Beograd exactly once.
15. Verify one `OTVOREN`, one `ZAVRŠEN`, one `ANONIMIZOVAN` and the available
    `ZATVOREN` case; test open-row article reselection without saving an
    unintended change.
16. With OPC closed, promote by atomic same-volume rename/copy procedure; never
    overwrite the rollback original until post-promotion gates pass.
17. Hash promoted canonical DB and reopen/remeasure again.
18. If any count, semantic digest, FK decision, runtime result or hash gate
    differs, close OPC and restore the preserved original.

No canonical operation is authorized by this audit alone; Luna must stop for
the explicit owner authorization immediately before promotion.

## U. Clean backup regeneration procedure

After promoted-canonical acceptance only:

1. export with the backup-contract-corrected build;
2. capture name, size, schema, export timestamp and SHA-256;
3. parse it independently, not through application UI only;
4. require 34 Politika and 17 Novosti rows, 51 unique citation tuples, zero
   duplicate groups and zero excess rows;
5. require stable-ID reference closure;
6. require every declared authoritative dataset and explicit classification of
   regenerated/local datasets;
7. require zero rejected/unclassified orphans;
8. retain the contaminated original backup unchanged and label it forensic,
   not clean;
9. never manually normalize the owner's original JSON.

The procedure is ready. The current exporter must first be corrected or the
owner must explicitly accept a narrower, non-lossless backup contract.

## V. Clean-room restore rehearsal design

Use a disposable fresh directory/database, never the canonical path.

1. create/open a new schema-27 database and record its default state;
2. restore the new clean backup with external reminder/media coordination
   replaced by isolated test adapters;
3. require the restore preflight to reject any orphan/duplicate payload before
   destructive deletion;
4. run `integrity_check` and `foreign_key_check`;
5. reopen twice and prove citation counts remain 34/17;
6. compare source canonical and restored DB by:
   - exact counts for all contract tables;
   - exact stable identities where the contract promises them;
   - sorted citation business tuples;
   - complete PREDMET field snapshots;
   - complete IRiU business snapshots, including name/price/quantity/amount;
   - contacts, lifecycle decisions, stock and logical reminders;
   - SCENARIO module, OSNOVNI PAKET, definitions, assignment snapshots and
     provenance under the corrected contract;
7. exercise the lifecycle matrix without mutating source canonical data;
8. export a second backup from the restored DB;
9. compare a canonicalized business representation, excluding documented
   volatile fields such as export timestamp and regenerated device IDs;
10. require idempotent business data and zero duplicate regeneration.

File hashes are expected to differ after a logical export/restore because
SQLite layout, audit events and timestamps may differ. Hashes are exact gates
for preserved input/copies; semantic digests are the restore-equivalence gate.

The acceptance design is ready, but it cannot pass against the current backup
contract without the section J corrections.

## W. Owner actions required, if any

No further screenshot is required to prove current catalog contamination; DB
evidence confirms the owner's runtime observation.

Before the irreversible promotion stage, the owner must:

- approve the classification/disposition ledger for the 182 FK violations;
- decide the intended portability of SCENARIO module/definitions and PARTE
  preparation/media state if the corrected contract presents alternatives;
- approve the exact canonical input hash and repaired-copy output evidence;
- confirm OPC is closed and authorize repaired-copy promotion;
- perform/observe the final installed Windows visual acceptance if automation
  cannot capture it reliably.

The owner must not delete the canonical DB or replace the original backup.

## X. Risks / stop conditions

Stop immediately if any of the following occurs:

- canonical hash differs from the approved preflight hash;
- OPC or a SQLite writer is running;
- a duplicate group differs in any nonidentity field;
- more or fewer than 51 groups / 4,332 deletion candidates are found;
- a stable reference cannot be mapped uniquely;
- any IRiU name, price, quantity or amount changes;
- the automatic historical snapshot repair remains active in the execution
  build;
- any FK orphan is silently deleted, imported or newly created;
- backup preflight does not cover snapshots/provenance and catalog duplicates;
- firm identity is not verified by the owner-required PIB/MB mismatch guard;
- SCENARIO/OSNOVNI policy differs without an approved transfer rule;
- PARTE media/preparation is purged without its explicit policy gate;
- reopened counts differ from 34/17;
- clean-room restore or second export is not semantically idempotent;
- rollback original or its verified hash is unavailable.

Do not use the current contaminated JSON as sole rebuild authority. Do not run
the current hidden startup repair against canonical data. Do not generalize the
citation tuple rule to all user KATALOG articles.

## Y. Exact Luna High implementation handoff scope

Luna High should execute in this exact order.

### Phase 1 — source safety, no canonical mutation

1. Remove `repairMalformedIriuCatalogSnapshots()` from `beforeOpen` and both
   single-PREDMET import calls. Retain it only as explicitly invoked audit
   logic or remove it; do not replace it with another fallback.
2. Add regression tests proving open/import never rewrites historical
   `nazivPrikaz`, including `Crnina` stable-ID-to-`Flor` evidence.
3. Introduce one shared KATALOG selection snapshot/command used by add and
   reselection. Keep category-only SCENARIO/OSNOVNI rows explicitly distinct.
4. Cover citation category-union selection through that same contract.
5. Keep PREDMET and IRiU name/price/quantity/amount snapshots authoritative.

Source areas:

- `lib/core/database/database.dart`;
- `lib/core/utils/json_export_import.dart`;
- `lib/features/predmeti/data/iriu_repository.dart`;
- `lib/features/predmeti/presentation/segments/iriu_segment.dart`;
- `lib/features/predmeti/presentation/segments/iriu_row_tile.dart`;
- `lib/features/predmeti/core_v2/services/iriu_display_name_resolver.dart`.

### Phase 2 — backup contract and preflight, no canonical mutation

1. Version the FULL backup contract.
2. Include SCENARIO module/definitions and OSNOVNI PAKET, or encode an explicit
   owner-approved regeneration policy that can be proven equivalent.
3. Resolve PARTE preparation/media portability explicitly; do not silently
   call a destructive restore lossless.
4. Add strict preflight for citation duplicate tuples, stable IDs, every parent
   reference, scenario snapshots/provenance, stock and reminders before any
   target deletion.
5. Implement the locked PIB/matični-broj mismatch block before destructive
   restore proceeds.
6. Ensure restore either rejects contaminated backups with a clear message or
   uses an explicitly reviewed migration stage; it must never silently accept
   4,332 excess citation rows.
7. Add clean-fixture and exact contaminated-backup regression tests on copies.

Source areas additionally include:

- `lib/features/predmeti/application/full_backup_restore_coordinator.dart`;
- SCENARIO module repository/tables;
- PARTE media/preparation stores and policy tests;
- backup/restore regression suites.

### Phase 3 — RI classification and forensic-copy repair

1. Reacquire canonical hash and verified backups.
2. Produce a machine-readable ledger for all 182 current FK violations.
3. Apply only owner-approved reconstruction/removal rules to a forensic copy.
4. Run the citation survivor/remap transaction on that copy.
5. Assert exact 34/17 counts, zero duplicate groups, zero stale references and
   invariant PREDMET/IRiU business snapshots.

### Phase 4 — runtime and promotion gate

1. Run analyzer, full tests and Windows release build.
2. Open/reopen the repaired copy twice and complete visual/lifecycle checks.
3. Present before/after hashes, count/digest evidence and rollback artifact.
4. Stop for explicit owner authorization.
5. Promote repaired copy while OPC is closed; retain the original.
6. Repeat hash, integrity, FK, semantic and runtime gates on the promoted DB.

### Phase 5 — clean backup and clean-room proof

1. Export the first clean backup and independently validate it.
2. Restore it into a fresh disposable DB.
3. Run the complete section V comparison and runtime reopen.
4. Export again and prove business-level idempotence.
5. Only then update closure status to canonical clean / backup clean / restore
   proven.

Rollback points exist after every phase. Any source/test failure rolls back the
branch only; any forensic-copy failure discards the copy; any promotion failure
restores the retained original canonical file. The contaminated user backup,
historical PREDMET snapshots, unrelated KATALOG user articles and installation
security state must not be touched.

This handoff is ready as a bounded implementation contract. It is **not** an
authorization to mutate canonical data before phases 1–4 and owner approval
pass.

## Z. Final verdicts

- `CANONICAL KATALOG DUPLICATION — PRESENT`
- `FULL BACKUP DUPLICATION — PRESENT`
- `DUPLICATION RECURRENCE PATH — PARTIAL`
- `PRODUCTION DATA CLEANUP — NOT DONE`
- `FULL BACKUP RESTORE CAN REINTRODUCE DUPLICATION — YES`
- `FULL BACKUP LOSSLESSNESS — NOT PROVEN`
- `DB-FIRST RECOVERY SAFETY — HIGH`
- `JSON-FIRST RECOVERY SAFETY — LOW`
- `RECOMMENDED RECOVERY STRATEGY — DB-FIRST`
- `KATALOG STABLE-ID SEMANTICS — PROVEN`
- `SAFE ČITULJE SURVIVOR/REMAP — READY`
- `HISTORICAL PREDMET IMMUNITY — PARTIAL`
- `OPEN PREDMET EDIT SAFETY AFTER DEDUP — PARTIAL`
- `STANDARD KATALOG→IRiU PIPELINE — MULTIPLE`
- `CRNINA DIVERGENT PATH — PARTIAL`
- `OTHER DIVERGENT KATALOG PATHS — PRESENT`
- `CLEAN BACKUP REGENERATION PLAN — READY`
- `CLEAN-ROOM RESTORE ACCEPTANCE PLAN — READY`
- `CANONICAL DB MUTATED DURING AUDIT — NO`
- `USER BACKUP MUTATED DURING AUDIT — NO`
- `LUNA HIGH IMPLEMENTATION HANDOFF — READY`

Overall audit status:

`AUDIT PASS — RECOVERY STRATEGY PROVEN — READY FOR LUNA HIGH IMPLEMENTATION`

This PASS means the safe strategy and implementation gates are proven. It does
not mean the canonical database is clean, the current backup is sufficient for
rebuild, or cleanup/restore is presently authorized.
