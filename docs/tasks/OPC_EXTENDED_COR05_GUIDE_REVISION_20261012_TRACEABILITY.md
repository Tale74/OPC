# Extended COR-05 guide revision and PREDMETI header

**Date:** 2026-10-12\
**Status:** Implemented; QA and both release builds completed; ready for Logos/OWNER review.\
**Authority:** OWNER authorization in `OPC v1.5 – EXTENDED COR-05 USER GUIDE REVISION AND PREDMETI HEADER CORRECTION`.\
**Scope:** Revise the existing offline guide against current OPC behavior and rename only the visible entry-screen title to `PREDMETI`.

## Authority and boundary

The current OPC source and governing product documentation determine factual behavior. The Logos revision is the editorial baseline, not technical or business authority. The guide keeps all 33 existing stable chapter IDs and the existing help architecture. This change does not alter business rules, database or transfer contracts, authentication, SCENARIO/IRiU behavior, PARTE/ČITULJE processing, or the accepted Narrow `O APLIKACIJI` layout finding. No physical runtime, rebaseline, commit, or push is in scope.

The protected active-source control remains unchanged: the active 28-row CSV hash is `3FA780EE45874434E11B9B198A5D8855250541CEEE1E5AC543EB8E652EF1CE26`; the applicable live precheck is 20/28, with the same eight previously provenance-resolved differences. No historic baseline was edited.

## Source-grounded content reconciliations

- The entry chapter keeps contextual help ID `lista`; its user-facing title is now `PREDMETI`, matching the visible list-screen heading.
- The first-use sequence distinguishes first administrator setup and PIN login from later firm, catalog, optional scenario, and first-record work. It does not assume the database already contains cases or user-created catalog articles.
- Current startup behavior can materialize initial IRiU rows from the current SCENARIO `OSNOVNI PAKET`. The guide explains that such rows are not proof that concrete catalog articles have been selected; article selection is done from KATALOG where the row provides that choice.
- Document examples use the actions currently exposed by PREDMET. The unsupported `PONUDA` and `POTVRDA` examples in the Logos draft were replaced with source-confirmed document actions; `RAČUN DOCX` is described as conditional on the applicable company setting.
- Single-PREDMET JSON transfer is distinguished from full OPC Backup restore/merge and its confirmation behavior. No claim is made that either operation is harmless or always replaces data.
- The guide's SCENARIO entry identifies its current access through `MODULI`. Other workflow descriptions were checked against their current screen actions and stable chapter routing.

## Files and verification

The integrated product resource is `assets/opc_user_guide.json`. The header change is in `lib/features/predmeti/presentation/lista_predmeta_screen.dart`; the corresponding smoke and guide tests assert the new title and stable `lista` routing. The externally packaged evidence includes the complete final user-facing text, all chapter IDs, Logos-to-source reconciliations, changed-file inventory, and completed QA/build logs.

The complete guide text is reproduced in the task's external review artifact `OPC_RAD_U_APLIKACIJI_SOURCE_VERIFIED_FINAL_TEXT.md`. Focused tests passed 21/21, `flutter analyze --no-pub` reported no issues, the full serial suite completed with 662 passed, 9 skipped and 0 failed, and Windows and Android production release builds completed successfully. The built guide resource hash matches the source resource on both platforms. This traceability record is not a replacement for the current product authority or the external review evidence.
