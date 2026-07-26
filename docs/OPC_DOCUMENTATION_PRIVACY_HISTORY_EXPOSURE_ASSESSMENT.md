# OPC — documentation privacy-history exposure assessment

**Status:** ASSESSMENT COMPLETE – NO HISTORY REWRITE PERFORMED – CURRENT-TREE EXPANSION DECISION REQUIRED
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

Posle te korekcije još 19 current Git dokumenata odgovara privacy obrascu:

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

## 5. Technical recommendation

1. Proširiti owner autorizaciju na current-tree sanitizaciju svih 19 preostalih dokumenata ili uklanjanje task reportova kada protection mapa postane PASS.
2. Za dva zadržana authority dokumenta i evidence notes izvršiti sadržinski neutralnu zamenu privatnih putanja stabilnim aliasima.
3. Za task reportove ne vršiti zasebnu redakciju ako će odmah biti bezbedno uklonjeni iz current tree-a; do tada ostaju javno izloženi.
4. Ne raditi Git history rewrite.
5. Posle current-tree cleanup-a ponoviti privacy scan i objaviti nulti current exposure rezultat.

## 6. Owner decision required

Predložena odluka:

> Proširujem autorizaciju sanitizacije na sve preostale current-tree dokumente navedene u odeljku 2, uz očuvanje poslovnog i dokaznog značenja. Git history rewrite i dalje nije odobren.
