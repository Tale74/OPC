# OPC Canonical Terminology Glossary

Status: public baseline with explicit owner-review queue.

| Term | Canonical status | Meaning / use | Action |
| --- | --- | --- | --- |
| OPC | CANONICAL | Product name. | Preserve. |
| OPC Web | CANONICAL FUTURE RUNTIME TERM | Future complementary browser-access runtime for the same OPC product logic. | Use in new public docs. |
| OPC Web Pristup | HISTORICAL / SUPPORTING | Earlier wording for future Web access. | Do not use as the new primary term. |
| SaaS | NOT PRIMARY PRODUCT TERMINOLOGY | Commercial/software delivery concept, not the OPC product identity. | Avoid as primary description; keep only when auditing historical/internal references. |
| saas | INTERNAL / CLEANUP CANDIDATE | Existing internal code/doc label for future-facing entitlement/access placeholders. | Do not rename in this task; schedule controlled cleanup only after audit. |
| PREDMET | CANONICAL MASTER BUSINESS TRUTH | Central business entity and master business truth. | Preserve across UI, PDF, JSON, Web, sync, packages, and architecture work. |
| Firma | CANONICAL BUSINESS OWNER | Firm/user that owns and controls its OPC database. | Preserve. |
| FirmaPodaci | CANONICAL BUT NOT STABLE ID ALONE | Editable firm data table used by current app. | Use carefully; stable identity needs technical audit and change tracking. |
| PIB | CANONICAL IDENTITY FIELD | Firm tax identity field. | Import/restore mismatch must block. |
| Matični broj | CANONICAL IDENTITY FIELD | Firm registration identity field. | Import/restore mismatch must block. |
| Administrator | CANONICAL ROLE TERM | Current/future admin role term. | Stable role identity requires technical audit before architecture changes. |
| Savetnik | CANONICAL ROLE TERM | Current/future advisor role term. | Stable role identity requires technical audit before architecture changes. |
| Osnovni | CANONICAL PACKAGE TERM | Package level. | Preserve casing/meaning. |
| Srednji | CANONICAL PACKAGE TERM | Package level. | Preserve casing/meaning. |
| Potpuni | CANONICAL PACKAGE TERM | Full package level; OPC is built as full product. | Package gating must not change `PREDMET` truth. |
| naručilac / narucilac | MIXED INTERNAL/LEGACY TERM / OWNER REVIEW REQUIRED | Current database/code/JSON keys and one PDF snapshot section still use `narucilac`/`NARUČILAC`, while the current visible PREDMET tab and payer PDFs use `Platilac`. | Do not rename in this task; future cleanup needs owner-approved source/database/PDF/JSON plan. |
| Platilac / platilac | CURRENT UI/PDF/BUSINESS DISPLAY TERM | Current PREDMET navigation, payer segment headings, finance refund wording, and main payer PDF sections use `Platilac`/`PLATILAC`. | Treat as current display term; confirm final relationship to internal `narucilac` fields before implementation cleanup. |
| klijent | NON-CANONICAL FOR PREDMET PARTY / LICENSING-CUSTOMER ONLY | Not found as current PREDMET UI/PDF/business party term. English `customer` appears in licensing/test/docs contexts. | Do not introduce `klijent` as replacement for `narucilac` or `Platilac`. |
| Windows master/admin | FORBIDDEN DRIFT | Incorrect platform-role split. | Do not use. |
| Android field/slave | FORBIDDEN DRIFT | Incorrect platform-role split. | Do not use. |

## Required Terminology Rule

New business, role, package, Web, sync, payment, or data-ownership terms must be marked `PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED` unless already confirmed in this glossary or the purpose manifest.

## Lineage Evidence

Detailed evidence is recorded in `docs/OPC_TERMINOLOGY_LINEAGE_REPORT.md`.
