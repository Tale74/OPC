# OPC PREDMET Workflow Atlas

Status: public workflow atlas / audit-only documentation.

This document reconstructs the current PREDMET workflow from the user/business perspective. It is not an implementation spec and does not authorize source, database, UI, PDF, JSON, import/export, backup/restore, Web, sync, storage, payment, role, package, or test changes.

## 1. Purpose And Scope

Purpose: explain how a real OPC user moves through one PREDMET, what each point means, what rules fire, what later outputs depend on each point, and what remains incomplete.

Scope: public docs, PREDMET UI source, PREDMET repository/table source, JSON/PDF/IRiU/STANJE ROBE source, and current tests were inspected as evidence.

## 2. Evidence Legend

Labels used: `OWNER DECISION`, `OWNER CLARIFICATION`, `OWNER-REPORTED BEHAVIOR`, `DOCUMENTED POLICY`, `SOURCE-CONFIRMED`, `SOURCE-INFERRED`, `TEST-CONFIRMED`, `RUNTIME-CONFIRMED`, `POLICY EXISTS / IMPLEMENTATION NOT FOUND`, `PARTIALLY IMPLEMENTED`, `NOT IMPLEMENTED`, `IMPLEMENTATION REQUIRED`, `TECHNICAL AUDIT REQUIRED`, `FACT CHECK REQUIRED`, `OWNER DECISION REQUIRED`, `TEST GAP`, `RUNTIME GAP`, `UNCLEAR / NEEDS OWNER REVIEW`.

## 3. PREDMET Workflow Summary

User journey:

```text
Lista predmeta / NOVI PREDMET
-> generated PREDMET metadata and initial IRiU rows
-> Preminulo lice
-> Činjenice o smrti
-> Statusi
-> Platilac
-> Ceremonija
-> Parte
-> Roba i usluge
-> Finansije
-> Dokumenti
-> Pregled i potvrda
-> SAČUVAJ / ZATVORI / IZMENI / GDPR anonimizacija / delete
```

The actual section order is source-confirmed in `lib/features/predmeti/presentation/predmet_screen.dart` via `_PredmetLogicalSection` and `_predmetSectionInfos`.

## 4. User-Facing PREDMET Journey

The user starts from `ListaPredmetaScreen` and creates or opens a PREDMET. Creation generates `brojPredmeta`, stores `datumKreiranja`, adviser/user metadata, status `OTVOREN`, `verzija = 1`, default business scenario, local source identity, and initializes IRiU rows. The user then fills sections in a guided navigation. The app tracks section progress and recommends unfinished/ready sections. `Pregled i potvrda` shows status, version, saved/unsaved state, and lifecycle actions.

Evidence: `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/data/predmeti_repository.dart`.

Classification: `SOURCE-CONFIRMED`.

## 5. Actual PREDMET Points Found In Source

| Source enum | Actual UI label | Widget/source |
| --- | --- | --- |
| `preminuloLice` | `Preminulo lice` | `PreminuloLiceSegment(mode: osnovno)` |
| `cinjeniceOSmrti` | `Činjenice o smrti` | `PreminuloLiceSegment(mode: cinjeniceOSmrti)` |
| `statusi` | `Statusi` | `PreminuloLiceSegment(mode: statusi)` |
| `platilac` | `Platilac` | `NarucilacSegment` |
| `ceremonija` | `Ceremonija` | `CeremonijuSegment` |
| `parte` | `Parte` | `ParteSegment` |
| `robaIUsluge` | `Roba i usluge` | `IriuSegment` |
| `finansije` | `Finansije` | `FinansijeSegment` |
| `dokumenti` | `Dokumenti` | `_buildDocumentsSection` |
| `pregledIPotvrda` | `Pregled i potvrda` | `_buildReviewSection` |

Classification: `SOURCE-CONFIRMED`.

## 6. Point-By-Point Atlas Entries

## POINT-ID: OPC-PREDMET-POINT-001

Point name: PREDMET opening / basic metadata
Actual UI/source name: `NOVI PREDMET`; `PredmetiRepository.kreirajPredmet`; `ListaPredmetaScreen._noviPredmet`
Business purpose: create the local PREDMET container and initial working state.
User action: user chooses new PREDMET or opens an existing PREDMET.
Fields entered by user: none at creation; adviser/session context is supplied.
Fields derived automatically: `brojPredmeta`, `datumKreiranja`, `status = OTVOREN`, `verzija = 1`, `savetnikId`, `createdByKorisnikId`, `businessScenarioId`, `sourceIdentity`, initial `pismo`, initial IRiU rows.
Required/optional fields: repository requires `savetnikId`; later close requires at least first or last name.
Business rules inside this point: creation is local; `brojPredmeta` is generated but not global identity; initial IRiU rows are inserted from catalog config.
Dependencies from previous points: user/session/adviser must exist.
Effects on later points: every section writes into this PREDMET id; documents/JSON/finance/IRiU attach to it.
Independent choices: creation itself does not require payer, ceremony, finance, or documents.
Conditional choices: if opened with document action, UI can start at `Dokumenti`.
Outputs affected:
- PDF: all future PDFs use this PREDMET.
- JSON: export serializes this PREDMET.
- IRIU: initial rows are created.
- STANJE ROBE: later IRiU choices can create consequences.
- Finance/payment: later finance uses this PREDMET and IRiU.
- PIO/refund: later status/finance fields.
- Parte: later display fields.
- Čitulje: future/IRiU derivative.
- Review/confirmation: status/version shown later.
Source evidence: `lib/features/predmeti/data/predmeti_repository.dart`; `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; `lib/core/database/tables/predmeti_table.dart`.
Test evidence: no direct full creation workflow test found; related smoke in `test/lista_predmeta_screen_smoke_test.dart`.
Runtime evidence: not freshly run.
Current completion state: `PARTIALLY IMPLEMENTED`.
Known gaps: duplicate generated `brojPredmeta` policy/guard needs audit.
Owner decisions: firm-scoped identity is `PIB + Matični broj + brojPredmeta`.
Technical audits required: duplicate creation and firm-scope guard.
Risk if misunderstood: treating generated `brojPredmeta` as global identity.
Future Web/sync relevance: high.

## POINT-ID: OPC-PREDMET-POINT-002

Point name: Preminulo lice
Actual UI/source name: `Preminulo lice`; `PreminuloLiceSegmentMode.osnovno`
Business purpose: identify the deceased person and provide core data for case recognition, documents, parte, JSON, anonymization, and review.
User action: enters name, surname, middle/maiden/name details, JMBG, sex, birth data, address, parents, and display-related personal fields.
Fields entered by user: `ime`, `prezime`, `srednje`, `devojackoPrezime`, `jmbg`, `pol`, `datumRodjenja`, `mestoRodjenja`, `adresa`, parent fields, title/rank/profession/nickname flags where shown by the segment.
Fields derived automatically: normalized text/date values; progress ready when first or last name exists.
Required/optional fields: first or last name is the minimum identity for valid retained/closed PREDMET; many personal fields are optional.
Business rules inside this point: close/save validation depends on minimum identity; anonymization later redacts protected personal/contact fields but leaves names visible in v1 source.
Dependencies from previous points: PREDMET must exist.
Effects on later points: payer can use spouse data; documents/parte/JSON/PDF display identity; import filename recognition uses name only as UX, not identity.
Independent choices: display flags such as title/nickname/parte flags are independent of payer/finance.
Conditional choices: spouse-related later choices depend on spouse fields.
Outputs affected:
- PDF: identity and snapshot/list documents.
- JSON: PREDMET fields exported.
- IRIU: indirect through death/case policy only for some facts.
- STANJE ROBE: indirect through IRiU.
- Finance/payment: mostly independent.
- PIO/refund: status point, not basic identity.
- Parte: name/title/nickname/display flags.
- Čitulje: derivative if implemented.
- Review/confirmation: minimum identity readiness.
Source evidence: `lib/features/predmeti/presentation/segments/preminulo_lice_segment.dart`; `lib/core/database/tables/predmeti_table.dart`; `lib/features/predmeti/presentation/predmet_screen.dart`.
Test evidence: no dedicated point test found.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST GAP`.
Known gaps: no runtime smoke in this task.
Owner decisions: PREDMET remains master truth.
Technical audits required: full UI lifecycle coverage.
Risk if misunderstood: using filename/person name as canonical identity.
Future Web/sync relevance: high for case recognition and privacy.

## POINT-ID: OPC-PREDMET-POINT-003

Point name: Činjenice o smrti
Actual UI/source name: `Činjenice o smrti`; `PreminuloLiceSegmentMode.cinjeniceOSmrti`
Business purpose: record death facts that affect documents and business policy.
User action: enters death date/place/cause and related facts.
Fields entered by user: `datumSmrti`, `mestoSmrti`, `uzrokSmrti`.
Fields derived automatically: `mestoSmrti` is normalized through `IriuTruthRules.normalizeMestoSmrti`.
Required/optional fields: section progress marks ready when death date and place are present; cause is significant but not required by progress source.
Business rules inside this point: death place/cause feed business policy evaluator for hospital death, infectious/violent/undefined override, and biohazard precautions.
Dependencies from previous points: basic PREDMET exists; independent from payer.
Effects on later points: affects IRiU policy and possibly STANJE ROBE through selected/required items; affects documents.
Independent choices: payer/finance can be entered separately.
Conditional choices: infectious/non-hospital death can require precautions in policy evaluator.
Outputs affected:
- PDF: death facts.
- JSON: exported PREDMET fields.
- IRIU: business policy conditions.
- STANJE ROBE: indirect through IRiU.
- Finance/payment: indirect through IRiU rows.
- PIO/refund: independent.
- Parte: death/case narrative context.
- Čitulje: derivative gap.
- Review/confirmation: progress readiness.
Source evidence: `preminulo_lice_segment.dart`; `business_policy_evaluator.dart`; `predmet_screen.dart`.
Test evidence: `test/business_policy_iriu_critical_scenarios_test.dart`.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST-CONFIRMED` for policy evaluator, `TEST GAP` for UI.
Known gaps: exact UI validation coverage.
Owner decisions: none new.
Technical audits required: full scenario matrix.
Risk if misunderstood: missing death facts may hide downstream service requirements.
Future Web/sync relevance: medium/high.

## POINT-ID: OPC-PREDMET-POINT-004

Point name: Statusi / family / pensioner / PIO preconditions
Actual UI/source name: `Statusi`; `PreminuloLiceSegmentMode.statusi`
Business purpose: capture marital, work, pensioner, military, spouse-right, and funeral assistance/refund context.
User action: enters marital status, spouse data, work/pension status, military honors, funeral assistance, spouse rights, and notes.
Fields entered by user: `bracnoStanje`, spouse name/JMBG/sex/maiden fields, `radniStatus`, `vojnePocasti`, `posmrtnaPomoc`, `bracniDrugOstvarujePravo`, `bracniDrugJePenzioner`, `penzionerNapomena`, rank/title-related fields.
Fields derived automatically: legacy flags `penzioner`, `penzionerSrbije`, `vojniPenzioner` derive from `radniStatus`; progress is ready once any status data starts.
Required/optional fields: optional, but drives refund and payer/spouse shortcuts.
Business rules inside this point: Serbian pensioner status makes PIO refund visible/active later; spouse data can be reused in payer/JKP section; military/pensioner fields affect documents.
Dependencies from previous points: spouse data belongs to deceased person/family context.
Effects on later points: Platilac spouse shortcut, finance refund logic, PDF/refund displays.
Independent choices: ceremony can be filled independently.
Conditional choices: refund and spouse fields depend on status choices.
Outputs affected:
- PDF: status/refund/military fields.
- JSON: all fields exported.
- IRIU: limited/indirect.
- STANJE ROBE: independent.
- Finance/payment: PIO refund and payer refund choice.
- PIO/refund: primary source.
- Parte: some rank/title display flags.
- Čitulje: possible derivative gap.
- Review/confirmation: status progress.
Source evidence: `preminulo_lice_segment.dart`; `finansije_segment.dart`; `lista_pdf_data_builder.dart`; `predmeti_table.dart`.
Test evidence: `test/package_downgrade_migration_test.dart` touches refund field migration; no full status workflow test found.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST GAP`.
Known gaps: complete PIO/refund rule tests.
Owner decisions: Platilac display terminology is current.
Technical audits required: refund edge cases.
Risk if misunderstood: refund may be applied/hidden incorrectly.
Future Web/sync relevance: medium.

## POINT-ID: OPC-PREDMET-POINT-005

Point name: Platilac and JKP payer
Actual UI/source name: `Platilac`; `NarucilacSegment`; visible blocks `PLATILAC ROBE I USLUGA` and JKP payer block
Business purpose: identify who pays goods/services and who is responsible for JKP costs.
User action: chooses physical/legal payer, spouse/other person where applicable, enters identity/contact fields, chooses same payer for JKP, and manages contact persons.
Fields entered by user: `naruTip`, `naru*` physical/legal fields, `naruIstiZaJkp`, `jkpTip`, `jkp*` physical/legal fields, contact rows in `KontaktLica`.
Fields derived automatically: spouse option copies spouse identity; `naruIstiZaJkp` copies payer fields into JKP fields; legal representative option can use `FirmaPodaci`; name aggregates such as `naruImePrezime` and `jkpImePrezime`.
Required/optional fields: source shows validation/error hints for payer name/legal name and primary phone; full business requiredness needs runtime/product decision.
Business rules inside this point: same-JKP switch controls whether JKP fields are separately entered; visible `Platilac` is current display term while internal fields remain `naru*`.
Dependencies from previous points: spouse shortcut depends on spouse data; FirmaPodaci can feed legal representative data.
Effects on later points: payment documents, JKP responsibility, finance totals, JSON, contacts, import business choice.
Independent choices: ceremony and IRiU can be filled independently, but documents depend on payer data.
Conditional choices: physical/legal, spouse/other, same-JKP, legal representative.
Outputs affected:
- PDF: payer and JKP payer sections.
- JSON: PREDMET payer fields and `kontaktLica`.
- IRIU: independent.
- STANJE ROBE: independent.
- Finance/payment: JKP responsibility and payer refund meaning.
- PIO/refund: payer refund choice appears in finance.
- Parte: independent.
- Čitulje: unclear.
- Review/confirmation: progress state.
Source evidence: `narucilac_segment.dart`; `kontakt_lica_table.dart`; `kontakt_lica_repository.dart`; `predmeti_table.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`; `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`.
Test evidence: `test/json_transfer_regression_test.dart` covers contact import/replace; no full payer UI test found.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST GAP`.
Known gaps: terminology cleanup and required-field policy.
Owner decisions: `Platilac` visible, `narucilac` internal legacy; keep/replace/cancel preserves business choice because payer may change.
Technical audits required: terminology compatibility plan.
Risk if misunderstood: wrong payer in documents or unsafe import merge.
Future Web/sync relevance: high.

## POINT-ID: OPC-PREDMET-POINT-006

Point name: Ceremonija / groblje / opelo / ispraćaj / special conditions
Actual UI/source name: `Ceremonija`; `CeremonijuSegment`
Business purpose: record where, when, and how the ceremony, burial/placement, opelo, ispraćaj, out-of-country burial, and reception of remains occur.
User action: enters cemetery, cemetery type, ceremony type/date/time, grave/urn/place fields, opelo choices, ispraćaj time, out-of-country and reception data.
Fields entered by user: `groblje`, `tipGroblja`, `vrstaCeremonije`, `datumCeremonije`, `vremeCeremonije`, `opelo`, `opeloMesto`, `vremeOpela`, `vremeIspracaja`, grave fields, urn fields, `sahranaVanSrbije`, `svisZemlja`, `svisGrad`, `docekPosmrtnihOstataka`, `docekMesto`, `docekVreme`.
Fields derived automatically: opelo availability and opelo locations depend on ceremony type; changing ceremony type can reset invalid opelo state; date/time are normalized.
Required/optional fields: progress ready when ceremony date/time and cemetery are present.
Business rules inside this point: ceremony type affects whether opelo is possible; cemetery/death/ceremony facts feed business policy and document narrative.
Dependencies from previous points: death facts and deceased identity provide context; otherwise section can be filled independently.
Effects on later points: PDF/list/nalog text, IRiU business policy, STANJE ROBE through IRiU, review/close/auto-finish by ceremony date.
Independent choices: payer can be independent.
Conditional choices: opelo, urn fields, out-of-country, reception.
Outputs affected:
- PDF: ceremony and opelo/burial text.
- JSON: exported PREDMET fields.
- IRIU: policy evaluator and required/suppressed items.
- STANJE ROBE: indirect via IRiU.
- Finance/payment: indirect through IRiU/JKP.
- PIO/refund: independent.
- Parte: ceremony time/context.
- Čitulje: possible derivative.
- Review/confirmation: progress and lifecycle close/auto-finish.
Source evidence: `ceremonija_segment.dart`; `business_policy_evaluator.dart`; `lista_pdf_data_builder.dart`; `nalog_za_opremanje_pdf_data_builder.dart`; `predmeti_repository.dart`.
Test evidence: `test/business_policy_iriu_critical_scenarios_test.dart`.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST-CONFIRMED` for policy conditions, `TEST GAP` for full UI.
Known gaps: full ceremony UI validation matrix.
Owner decisions: PREDMET remains master.
Technical audits required: runtime parity.
Risk if misunderstood: wrong operational/service/document outcome.
Future Web/sync relevance: high.

## POINT-ID: OPC-PREDMET-POINT-007

Point name: Parte
Actual UI/source name: `Parte`; `ParteSegment`
Business purpose: define public display data for parte and related document output.
User action: chooses symbol/script/display name/mourners and parte-specific flags.
Fields entered by user: `simbol`, `pismo`, `parteIme`, `ozaloseni`, and display flags from deceased-person data.
Fields derived automatically: defaults such as symbol and script; display name may depend on PREDMET personal fields and user override.
Required/optional fields: progress starts when `parteIme` or `ozaloseni` exists.
Business rules inside this point: parte is derivative of PREDMET, not independent truth.
Dependencies from previous points: deceased name/title/nickname fields, ceremony timing.
Effects on later points: parte/PDF/display outputs, JSON transfer.
Independent choices: finance and payer independent.
Conditional choices: script/symbol/display flags.
Outputs affected:
- PDF: parte-related output where implemented.
- JSON: PREDMET fields.
- IRIU: `posmrtneParte` row exists in initial IRiU.
- STANJE ROBE: possible indirect only if parte items have stock consequence.
- Finance/payment: via IRiU if selected/charged.
- PIO/refund: independent.
- Parte: primary.
- Čitulje: related but not fully extracted.
- Review/confirmation: section progress.
Source evidence: `parte_segment.dart`; `predmeti_table.dart`; `predmeti_repository.dart`; `iriu_table.dart`.
Test evidence: no dedicated parte test found.
Runtime evidence: not freshly run.
Current completion state: `PARTIALLY IMPLEMENTED / TEST GAP`.
Known gaps: advanced parte and čitulje full rule extraction.
Owner decisions: documents derive from PREDMET.
Technical audits required: parte/čitulje output audit.
Risk if misunderstood: public display diverges from PREDMET truth.
Future Web/sync relevance: medium.

## POINT-ID: OPC-PREDMET-POINT-008

Point name: Roba i usluge / IRiU / articles/services
Actual UI/source name: `Roba i usluge`; `IriuSegment`
Business purpose: select goods/services for the PREDMET and provide operational/financial/document rows.
User action: checks/edits IRiU rows, display names, quantities, amounts, manual/user catalog items, and notes.
Fields entered by user: IRiU `nazivPrikaz`, `kom`, `iznos`, `cekiran`, row choices, PREDMET `napomena`.
Fields derived automatically: initial rows from catalog; business policy can require/suppress items; financial truth includes positive active rows; row ordering.
Required/optional fields: section is always started in progress source; specific row requirements depend on business policy and owner/product rules.
Business rules inside this point: catalog owns catalog truth; selected PREDMET/IRiU rows are business-visible snapshots; some categories drive STANJE ROBE consequences.
Dependencies from previous points: death/ceremony/cemetery facts feed business policy; entitlement/settings can affect operational stock.
Effects on later points: finance totals, PDFs, nalog za opremanje, JSON transfer, STANJE ROBE consequences.
Independent choices: payer/status can be independent but finance documents combine them.
Conditional choices: row active/checked/suppressed, covered stock categories.
Outputs affected:
- PDF: list, predracun/racun/specification/nalog rows.
- JSON: `iriu` rows and possible stock consequence transfer.
- IRIU: primary.
- STANJE ROBE: covered categories apply/restore/record consequences.
- Finance/payment: total goods/services.
- PIO/refund: refund applies against goods/services.
- Parte: parte-related rows.
- Čitulje: `cituljaP` category exists; full rules pending.
- Review/confirmation: implicit through final state.
Source evidence: `iriu_segment.dart`; `iriu_table.dart`; `iriu_repository.dart`; `predmeti/core_v2/*`; `stanje_robe_lifecycle_service.dart`; `financial_truth_service.dart`.
Test evidence: `test/business_policy_iriu_critical_scenarios_test.dart`; `test/stanje_robe_operational_toggle_test.dart`; `test/json_transfer_regression_test.dart`.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST-CONFIRMED / PARTIALLY IMPLEMENTED`.
Known gaps: complete owner-reviewed IRiU rule map.
Owner decisions: IRiU remains PREDMET-derived/organized, not master truth.
Technical audits required: full rule map and runtime parity.
Risk if misunderstood: wrong finance, documents, or stock consequence.
Future Web/sync relevance: high.

## POINT-ID: OPC-PREDMET-POINT-009

Point name: Finansije
Actual UI/source name: `Finansije`; `FinansijeSegment`
Business purpose: calculate/display payment state from IRiU, JKP, refund, advance, discount, and payment notes.
User action: enters JKP costs, whether JKP pays independently, advance, discount, payment method/notes, and payer refund choice where visible.
Fields entered by user: `troskoviJkp`, `jkpPlacaSamostalno`, `avans`, `popust`, `nacinPlacanja`, `napomenaPlacanja`, `narucilacRefundira`.
Fields derived automatically: `refundacijaPio` from settings when applicable; `robaIUsluge` from IRiU; displayed totals/deductions.
Required/optional fields: optional fields; business financial completeness depends on product use.
Business rules inside this point: PIO refund appears when Serbian pensioner context is active; refund reduces amount unless payer refunds independently; JKP added only when payer does not pay independently.
Dependencies from previous points: status/Pio fields, IRiU total, JKP payer responsibility and ceremony costs.
Effects on later points: financial PDFs, review, JSON export.
Independent choices: notes/payment method independent of ceremony facts.
Conditional choices: refund visibility, JKP self-pay, payment methods.
Outputs affected:
- PDF: financial sections in list/preinvoice/invoice/specification/snapshot.
- JSON: finance fields.
- IRIU: consumes financial truth from IRiU.
- STANJE ROBE: independent.
- Finance/payment: primary.
- PIO/refund: primary calculation/display consumer.
- Parte: independent.
- Čitulje: indirect through IRiU amount if charged.
- Review/confirmation: final business review.
Source evidence: `finansije_segment.dart`; `financial_truth_service.dart`; `lista_pdf_data_builder.dart`; `predmet_pdf_snapshot_export.dart`; `predmeti_table.dart`.
Test evidence: no dedicated finance calculation test found; package migration touches refund setting.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST GAP`.
Known gaps: finance calculation tests.
Owner decisions: package/payment implementation remains blocked.
Technical audits required: finance edge-case tests.
Risk if misunderstood: wrong amount due or refund treatment.
Future Web/sync relevance: medium/high.

## POINT-ID: OPC-PREDMET-POINT-010

Point name: Dokumenti and JSON export
Actual UI/source name: `Dokumenti`; `_buildDocumentsSection`
Business purpose: produce PREDMET-derived documents and single-PREDMET JSON transfer.
User action: selects PDF/JSON actions.
Fields entered by user: none here; outputs use already-entered PREDMET/IRiU/Firma/user/settings data.
Fields derived automatically: document visibility from entitlement policy; export metadata and filename for JSON/PDF.
Required/optional fields: document actions may be visible/hidden by entitlement.
Business rules inside this point: documents and JSON are derivatives; JSON filename is UX only; `exportDatum` is metadata; single-PREDMET JSON is distinct from full backup.
Dependencies from previous points: depends on all data needed by each document/action.
Effects on later points: export artifacts; import elsewhere can create/replace PREDMET by conflict rules.
Independent choices: generating a document does not change master business truth except export metadata paths where source implements export behavior.
Conditional choices: entitlement controls visible document actions.
Outputs affected:
- PDF: specification, predracun, lista, nalog za opremanje, snapshot, racun.
- JSON: single-PREDMET JSON.
- IRIU: serialized in JSON/PDF rows.
- STANJE ROBE: unresolved consequence transfer only when safe.
- Finance/payment: payment PDFs.
- PIO/refund: financial documents.
- Parte: document output.
- Čitulje: related gaps.
- Review/confirmation: documents are not master truth.
Source evidence: `predmet_screen.dart`; `lib/features/predmeti/pdf/*`; `json_export_import.dart`; `predmet_json_transfer_core.dart`; `opc_entitlement_policy.dart`.
Test evidence: `test/json_transfer_regression_test.dart`; no PDF render tests found.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST-CONFIRMED` for JSON, `TEST GAP` for PDF.
Known gaps: PDF terminology and render tests.
Owner decisions: filename UX only; `exportDatum` not freshness authority.
Technical audits required: PDF output regression coverage.
Risk if misunderstood: documents/exports become treated as master truth.
Future Web/sync relevance: high for transfer, medium for PDFs.

## POINT-ID: OPC-PREDMET-POINT-011

Point name: Pregled i potvrda / save / close / reopen / version
Actual UI/source name: `Pregled i potvrda`; `_buildReviewSection`
Business purpose: final review of work state, version, and lifecycle actions.
User action: reviews status/version/saved state, chooses `SAČUVAJ`, `ZATVORI`, or `IZMENI`; header/menu also exposes lifecycle/delete/anonymize actions where allowed.
Fields entered by user: no direct business fields; lifecycle action selection.
Fields derived automatically: saved/unsaved state, `verzija`, close snapshots, save snapshots, logs.
Required/optional fields: close requires minimum deceased identity and no unresolved STANJE ROBE blocker; saved state affects review readiness.
Business rules inside this point: save records business snapshot; close sets `ZATVOREN` and increments `verzija` only after prior confirmed snapshot with business changes; reopen returns to `OTVOREN`; future change-log overview belongs here but is not implemented.
Dependencies from previous points: every business section feeds review; stock blocker can prevent close.
Effects on later points: lifecycle state, version, logs, documents/import/export meaning.
Independent choices: save vs close are different lifecycle actions.
Conditional choices: `IZMENI` only for closed; anonymize only for eligible finished; delete is destructive after confirmation.
Outputs affected:
- PDF: status/version can appear in outputs.
- JSON: exports status/version/log-related fields in PREDMET.
- IRIU: no direct edit, but close may be blocked by consequences.
- STANJE ROBE: unresolved blocker affects close.
- Finance/payment: review includes final business readiness.
- PIO/refund: review confirms final state.
- Parte: review confirms final state.
- Čitulje: review confirms final state.
- Review/confirmation: primary.
Source evidence: `predmet_screen.dart`; `predmeti_repository.dart`; `log_izmena_table.dart`; `stanje_robe_lifecycle_service.dart`.
Test evidence: no full review/close UI test found; STANJE ROBE close-block behavior has related tests.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST GAP / IMPLEMENTATION REQUIRED` for future change-log overview.
Known gaps: PREDMET change-log overview missing; version increment coverage audit required.
Owner decisions: `verzija` is business-version signal; change-log overview future location is `Pregled i potvrda`.
Technical audits required: version/log/change-log audit and UI suitability.
Risk if misunderstood: closing/versioning could be treated as mere export timestamp or silent conflict authority.
Future Web/sync relevance: high.

## POINT-ID: OPC-PREDMET-POINT-012

Point name: Import/replace relation to PREDMET workflow
Actual UI/source name: single-PREDMET JSON import; `uvoziIzFajla`; conflict keep/replace/cancel
Business purpose: bring a PREDMET from JSON into the local database or replace a matching local PREDMET by explicit user choice.
User action: imports JSON; if same `brojPredmeta` conflict exists, chooses cancel, keep local, or replace imported.
Fields entered by user: decision only.
Fields derived automatically: candidate metadata, imported PREDMET/IRiU/contacts/consequence transfer.
Required/optional fields: imported `brojPredmeta` drives current conflict lookup when non-empty.
Business rules inside this point: replacement keeps local technical id; deletes/reinserts related rows; reconciles STANJE ROBE; no automatic version comparator/hard block currently source-confirmed.
Dependencies from previous points: current local data and imported data both represent full PREDMET workflow state.
Effects on later points: all PREDMET sections may be replaced by imported business state.
Independent choices: user choice intentionally preserved.
Conditional choices: zero/one/multiple local matches change flow.
Outputs affected:
- PDF: future documents use resulting PREDMET state.
- JSON: import consumes JSON.
- IRIU: replaced/imported.
- STANJE ROBE: reconciled and incoming unresolved consequence imported.
- Finance/payment: replaced/imported through PREDMET/IRiU.
- PIO/refund: replaced/imported.
- Parte: replaced/imported.
- Čitulje: related through IRiU.
- Review/confirmation: resulting state must be reviewed by user.
Source evidence: `json_export_import.dart`; `predmeti_repository.dart`; `predmet_json_transfer_core.dart`.
Test evidence: `test/json_transfer_regression_test.dart`.
Runtime evidence: not freshly run.
Current completion state: `SOURCE-CONFIRMED / TEST-CONFIRMED / POLICY EXISTS / IMPLEMENTATION NOT FOUND` for future firm/version guard.
Known gaps: firm identity guard, PIB/MB guard, version warnings.
Owner decisions: keep/replace/cancel is intentional; filename UX only.
Technical audits required: identity/version warning implementation design.
Risk if misunderstood: unsafe overwrite or false conflict.
Future Web/sync relevance: high.

## 7. End-To-End Scenario Flow

```text
1. New PREDMET creates local case shell and initial IRiU rows.
2. User identifies deceased person.
3. User records death facts and status/pension/family context.
4. User defines Platilac and JKP payer/responsibility.
5. User defines ceremony, burial/urn/opelo/reception details.
6. User prepares parte display fields.
7. User selects/adjusts goods and services.
8. Stock consequence logic may apply or record unresolved blockers for covered IRiU rows.
9. User reviews financial totals, refund, JKP, advance, discount, payment notes.
10. User generates documents/JSON as derivatives.
11. User reviews and saves/closes in Pregled i potvrda.
12. Later user may reopen, replace by import, anonymize, delete, or export again.
```

## 8. Business Rules Inside Each Point

See point entries above. The highest-impact rules are: minimum deceased identity for close/retention, death/ceremony facts feeding IRiU policy, same-JKP payer copy/clear behavior, PIO refund conditions, IRiU financial truth, STANJE ROBE consequences, document/JSON derivative status, explicit import choice, and review/close version behavior.

## 9. Cross-Point Dependency Summary

Detailed dependencies are in `docs/OPC_PREDMET_DEPENDENCY_MAP.md`.

## 10. Outputs By Point

| Point | Main outputs |
| --- | --- |
| Opening/basic metadata | local PREDMET id, `brojPredmeta`, version/status, initial IRiU |
| Preminulo lice | identity fields for documents, JSON, parte, review |
| Činjenice o smrti | death facts for policy, documents, JSON |
| Statusi | spouse/pension/refund/military context |
| Platilac | payer/JPK data, contacts, payment documents |
| Ceremonija | ceremony/cemetery/opelo/urn/reception data, policy inputs |
| Parte | public display/parte data |
| Roba i usluge | IRiU rows, finance basis, stock consequences |
| Finansije | payment/refund totals and notes |
| Dokumenti | PDFs and JSON transfer artifacts |
| Pregled i potvrda | save/close/reopen/version/log state |

## 11. Documents/PDF Effects

PDF actions are visible through entitlement policy and include specification, predracun, lista, nalog za opremanje, PREDMET snapshot, and racun. Main evidence: `lib/features/predmeti/presentation/predmet_screen.dart`; `lib/features/predmeti/pdf/*`.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 12. JSON Effects

Single-PREDMET JSON serializes PREDMET, IRiU, contacts, metadata, and approved unresolved STANJE ROBE consequence transfer block. Import can create or replace PREDMET by explicit user decision.

Evidence: `lib/core/utils/json_export_import.dart`; `lib/core/json_transfer/predmet_json_transfer_core.dart`; `test/json_transfer_regression_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 13. IRIU / STANJE ROBE Effects

IRiU is initialized on PREDMET creation and later adjusted in `Roba i usluge`. Business policy and covered categories can trigger STANJE ROBE lifecycle effects or unresolved consequences.

Evidence: `iriu_repository.dart`; `business_policy_evaluator.dart`; `stanje_robe_lifecycle_service.dart`; `test/business_policy_iriu_critical_scenarios_test.dart`; `test/stanje_robe_operational_toggle_test.dart`.

Classification: `SOURCE-CONFIRMED / TEST-CONFIRMED`.

## 14. Finance / Payment Effects

Finance combines IRiU total, refund context, JKP cost/self-pay, advance, discount, payment methods, and notes. Dedicated finance tests are still missing.

Evidence: `finansije_segment.dart`; `financial_truth_service.dart`; `lista_pdf_data_builder.dart`.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 15. PIO / Refund Effects

PIO/refund depends on status fields and settings refund amount. Finance display applies refund only when context is active and payer does not refund independently.

Evidence: `preminulo_lice_segment.dart`; `finansije_segment.dart`; `podesavanja_screen.dart`; `lista_pdf_data_builder.dart`.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 16. Parte / Čitulje Effects

Parte fields are source-confirmed. Čitulje appear as IRiU/category/entitlement area but full workflow is not fully extracted.

Evidence: `parte_segment.dart`; `predmeti_repository.dart`; `opc_entitlement_policy.dart`; `docs/OPC_BUSINESS_LOGIC_RULE_INVENTORY.md`.

Classification: `PARTIALLY IMPLEMENTED / TECHNICAL AUDIT REQUIRED`.

## 17. Pregled I Potvrda Role

`Pregled i potvrda` is the operational review and lifecycle point. It currently shows status, `verzija`, saved state, and save/close/edit actions. Owner decision says future version/change-log overview belongs here, but current implementation does not provide that overview.

Evidence: `predmet_screen.dart`; `predmeti_repository.dart`; owner decision report.

Classification: `SOURCE-CONFIRMED / OWNER DECISION / IMPLEMENTATION REQUIRED`.

## 18. Lifecycle / Version / Log Role

Save writes save snapshots. Close writes confirmed-close snapshots and increments `verzija` only when business data changed after a prior confirmed state. Reopen writes work-cycle logs. Delete/replacement clears logs for that PREDMET. Future change-log overview remains missing.

Evidence: `predmeti_repository.dart`; `log_izmena_table.dart`; `json_transfer_regression_test.dart` for replacement side effects.

Classification: `SOURCE-CONFIRMED / TEST GAP`.

## 19. What Is Complete

- Actual PREDMET section structure is source-confirmed.
- PREDMET creation/open/save/close/reopen/delete/anonymize paths exist.
- JSON transfer and replacement paths are source/test-confirmed.
- IRiU/STANJE ROBE critical paths have tests.
- Entitlement-controlled document actions exist.

## 20. What Is Incomplete

- Full UI workflow runtime smoke is not confirmed.
- PDF render regression tests are not found.
- Finance calculation tests are incomplete.
- Parte/čitulje full workflow is not fully extracted.
- Firm-scoped identity guard and PIB/MB guard are not implemented/proven.
- Version/change-log overview is not implemented.

## 21. What Is Policy-Only

- Future-safe identity `PIB + Matični broj + brojPredmeta`.
- `exportDatum` not freshness authority.
- Version conflict matrix warnings.
- Future change-log overview in `Pregled i potvrda`.
- OPC Web/sync boundaries.

## 22. What Is Source-Confirmed

PREDMET points, fields, repository lifecycle, IRiU rows, contacts, finance source, documents section, JSON transfer, entitlement visibility, and local user/session metadata.

## 23. What Is Test-Confirmed

JSON transfer/replacement, stock consequence transfer, STANJE ROBE operations, IRiU critical scenarios, licensing/package parser/migration, and smoke tests for selected screens.

## 24. Runtime Gaps

No fresh Windows/Android runtime confirmation was run. Dialogs, PDFs, and full PREDMET workflow remain `RUNTIME GAP` in this task.

## 25. Owner Decisions Required

- duplicate `brojPredmeta` creation policy;
- final `Platilac`/`narucilac` cleanup strategy;
- exact version warning text and hard-block policy if any;
- change-log content and retention;
- čitulje workflow/product rules.

## 26. Technical Audits Required

- full PREDMET UI workflow runtime smoke;
- finance/PDF/parte/čitulje tests;
- `verzija` increment/survival audit;
- `Pregled i potvrda` change-log suitability;
- firm identity and import/restore guard design.

## 27. Implementation Stop-List Summary

This atlas does not authorize implementation. Blocked work remains: Web/sync/backend/storage, migrations, identity guards, JSON schema changes, import behavior changes, version comparator, change-log DB/UI, PDF/UI behavior changes, payment/licensing/role implementation, and terminology renames.

## 28. Recommended Next Steps

Findings-only sequencing:

1. Runtime-smoke the full PREDMET workflow on Windows/Android.
2. Audit `Pregled i potvrda` for version/change-log display suitability.
3. Add finance/PDF/parte/čitulje rule tests after owner confirms expected outputs.
