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
| naručilac / narucilac | CURRENT APP TERM / FACT CHECK REQUIRED | Evidence exists in app source, UI, PDF, and local docs. | Owner must confirm final lineage and spelling rules before broad cleanup. |
| Platilac / platilac | CURRENT APP TERM / FACT CHECK REQUIRED | Evidence exists in UI sections, finance controls, PDFs, and local docs. | Confirm exact business relation to `narucilac` before label/schema changes. |
| klijent | OWNER-QUESTIONED / NOT REPLACEMENT | Not established as a replacement app business field in current evidence. | Do not introduce as replacement for `narucilac`. |
| Windows master/admin | FORBIDDEN DRIFT | Incorrect platform-role split. | Do not use. |
| Android field/slave | FORBIDDEN DRIFT | Incorrect platform-role split. | Do not use. |

## Required Terminology Rule

New business, role, package, Web, sync, payment, or data-ownership terms must be marked `PROPOSED TERM - NOT IMPLEMENTED - OWNER DECISION REQUIRED` unless already confirmed in this glossary or the purpose manifest.
