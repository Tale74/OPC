# OPC — documentation privacy-history exposure assessment

**Status:** CURRENT-TREE SANITIZATION COMPLETE – NO HISTORY REWRITE PERFORMED
**Datum:** 26. jul 2026.
**Branch:** `task/OPC-GATE-0-DOCUMENTATION-PROTECTION-MAP`

## 1. Scope

Owner je odobrio:

- sanitizaciju privatne lokalne putanje iz aktuelnog javnog manifesta;
- zasebnu procenu istorijske privacy izloženosti;
- zabranu Git history rewrite-a u ovom trenutku.

Audit je tražio:

- eksplicitni lokalni korisnički identifikator;
- privatne Windows user-root putanje;
- privatne projektne root putanje.

Vrednosti nisu ponovljene u ovom javnom dokumentu.

## 2. Current-tree rezultat

Odobrena sanitizacija izvršena je u:

- `docs/OPC_PURPOSE_AND_ANTI_DRIFT_MANIFEST.md`

Data-ownership i canonical-database poslovno pravilo ostalo je nepromenjeno.

Posle početne korekcije još 19 current Git dokumenata odgovaralo je privacy obrascu. Owner je zatim proširio autorizaciju i svi sledeći dokumenti su sadržinski neutralno sanitizovani stabilnim aliasima:

### Zadržani authority dokumenti

- `docs/OPC_CANONICAL_DATABASE_MIGRATION_POLICY.md`
- `docs/OPC_OWNER_DECISION_GUIDE.md`

### Evidence dokument koji još čeka klasifikaciju

- `docs/OPC_SAFE_UPGRADE_FROM_PSEUDOCODE_NOTES.md`

### Task reportovi predloženi za removal posle protection PASS-a

- `docs/tasks/OPC_TASK_BACKUP_RESTORE_EVIDENCE_CHECK_REPORT.md`
- `docs/tasks/OPC_TASK_CANONICAL_DATABASE_RECOVERY_LEGACY_MIGRATION_COMPATIBILITY_REPORT.md`
- `docs/tasks/OPC_TASK_CLEAN_VALIDATION_AND_BUILD_RUNTIME_TEST_REPORT.md`
- `docs/tasks/OPC_TASK_GROUPED_BUILD_WINDOWS_RUNTIME_VALIDATION_REPORT.md`
- `docs/tasks/OPC_TASK_IRIU_CITULJE_CATALOG_PICKER_NOVOSTI_FIX_REPORT.md`
- `docs/tasks/OPC_TASK_LOCAL_PROJECT_DOCUMENTATION_INVENTORY_AND_CONTINUITY_AUDIT_REPORT.md`
- `docs/tasks/OPC_TASK_MODULI_PAKETI_PODSETNIK_ARCHITECTURE_RELOCATION_REPORT.md`
- `docs/tasks/OPC_TASK_OWNER_DECISION_CONTINUITY_AND_CURRENT_STATE_AUDIT_REPORT.md`
- `docs/tasks/OPC_TASK_PARTE_FINAL_TECHNICAL_TEXT_PLACEMENT_UI_REGRESSION_REPORT.md`
- `docs/tasks/OPC_TASK_PARTE_OWNER_WINDOWS_ANDROID_RUNTIME_DOCUMENTATION_CLOSURE_REPORT.md`
- `docs/tasks/OPC_TASK_PARTE_RUNTIME_CORRECTIONS_MODULE_WORKFLOW_COMPOSER_DOCX_REPORT.md`
- `docs/tasks/OPC_TASK_PDF_LOGO_MAX_LAYOUT_REPORT.md`
- `docs/tasks/OPC_TASK_PODSETNIK_CONTROL_FLOW_USER_CONFIRMATION_AUDIT_REPORT.md`
- `docs/tasks/OPC_TASK_PREIMPLEMENTATION_AUDIT_BEFORE_POINT_4_SMOKE_REPORT.md`
- `docs/tasks/OPC_TASK_PRESENTATION_POTPUN_BUILD_NO_DEMO_LICENSE_BLOCK_REPORT.md`
- `docs/tasks/OPC_TASK_PROJECT_SOUL_INCONSISTENCY_STANDARDS_AND_GROUND_LEVEL_MILESTONE_AUDIT_REPORT.md`

## 3. Git-history rezultat

Privacy obrazac je pronađen u:

- 22 istorijska commita;
- 23 jedinstvene dokumentacione putanje.

Najraniji i relevantni commit lineage uključuje dokumentacione i runtime-validation taskove od kraja juna do kraja jula 2026. Git istorija nije menjana.

Posebno potvrđeni canonical-database exposure commits:

- `a3b6b0df427a6ef2e1ca4673fb4325203fc79664`
- `e6a0c42c8df59ebe1415d91c1e795082d4bfd283`
- `4f8eaa8421f27ef387e3f62866000e396572786c`

## 4. Risk classification

- Nisu pronađeni privatni ključevi, credential secrets ili API tokeni ovim obrascem.
- Pronađeni su lični/lokalni environment identifikatori i apsolutne putanje.
- Current-tree izloženost može se ukloniti bez history rewrite-a.
- Istorijska izloženost ostaje javno dohvatljiva kroz starije commit objekte dok se eventualno ne odobri zasebna history-remediation operacija.
- History rewrite bi promenio commit lineage, branch SHA-ove i kontinuitetne reference i zato nije preporučen bez proporcionalnog privacy/security razloga.

Ponovljeni current-tree scan sada vraća:

`0 current documentation files matching the approved private user/project-root patterns`

## 5. Technical recommendation

1. Zadržati stabilne aliase `<OWNER_USER_HOME>`, `<OWNER_LOCAL_USER>`, `<LOCAL_OPC_PROJECT_ROOT>` i `<LOCAL_PROJECTS_ROOT>` u javnim dokumentima.
2. Ne vraćati privatne apsolutne putanje u task reportove, pseudocode ili primere.
3. Ne raditi Git history rewrite.
4. Posle svakog documentation cleanup-a ponoviti privacy scan i zahtevati nulti current exposure rezultat.

## 6. Owner decision status

- Current-tree expansion: OWNER APPROVED AND COMPLETED.
- Business/evidence meaning: preserved through stable alias substitution.
- Git history rewrite: NOT APPROVED.
