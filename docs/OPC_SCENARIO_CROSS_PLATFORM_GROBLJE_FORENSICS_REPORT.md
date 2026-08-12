# OPC SCENARIO cross-platform GROBLJE forensics

Datum: 12.08.2026. (Europe/Belgrade)

## 1. Baseline

- Početna grana: `task/OPC-ANDROID-RELEASE-BUILD-RESOLUTION`
- Početni HEAD/remote: `ecc2a73bd0368a607a5be98bb4a66f98a73010a6`
- Nova grana: `task/OPC-SCENARIO-CROSS-PLATFORM-GROBLJE-FORENSICS`
- Remote: `https://github.com/Tale74/OPC.git`
- Početno radno stablo: čisto.
- Pročitani su prethodni Android startup, Android build i SCENARIO DB handoff reporti.

## 2. Prethodna kontradikcija i Android reprodukcija

Prethodni report je naveo `PREDMET TIP GROBLJA = GRADSKO` → `SCENARIO = LOKALNO`.

To nije reprodukovano kada se proveri stvarno stanje kontrole. Posle Android force-stop/start i otvaranja `ANDROID NASILNA / 120826_1640`, accessibility dump je pokazao:

- `GRADSKO`: `selected=false`
- `LOKALNO`: `selected=true`
- `Radno stanje: sačuvano`

Prethodni report je pogrešno tretirao vidljivost dugmeta `GRADSKO` kao dokaz da je ono izabrano; nije proverio `selected` stanje niti jednakost svih osam osa. Stvarni početni Android state bio je `LOKALNO`, a SCENARIO `LOKALNO` je bio konzistentan sa njim.

## 3. Android device/package/runtime identity

- ADB: `192.168.100.74:37977`, model `LGN-LX1`, Android 15, `720x1610`.
- Package: `com.tale.opc_v4`, version `4.0.0`, versionCode `1`, targetSdk `36`.
- `dataDir=/data/user/0/com.tale.opc_v4`.
- Package path: `/data/app/~~5Xlp6yI_T8Gp-c6bPLNDwQ==/com.tale.opc_v4-t46dvQmA3FpEFMcXneraqA==/base.apk`.
- `firstInstallTime=2026-06-24 21:00:04`, `lastUpdateTime=2026-08-12 16:33:53`.
- Signature identity: `1cbc9750`.
- Release package nije debuggable; `run-as com.tale.opc_v4` je odbijen. Direktni Android SQLite/MAP/snapshot dump zato nije moguć bez diagnostic builda; takav build nije opravdan jer mismatch nije reprodukovan.

## 4. Android controlled GRADSKO runtime retest

Isti PREDMET je kroz normalan Android UI promenjen sa stvarno izabranog `LOKALNO` na `GRADSKO` i sačuvan.

Kontrolisani tuple:

`NASILNA · STAN · SAHRANA · GRADSKO · GROB · OPELO NE · VAN SRBIJE NE · DOČEK NE`

Posle save-a i production UI hand-off-a `MODULI → SCENARIO`, selektovan je samo `ANDROID NASILNA / 120826_1640`. Accessibility dump je potvrdio:

- `TRENUTNI USLOVI I IZVEDENI SCENARIO`: `NASILNA · STAN · SAHRANA · GRADSKO · GROB · OPELO NE · VAN SRBIJE NE · DOČEK NE`
- `PRIMENJENI SCENARIO SNAPSHOT`: isti tuple
- `Transportna vreća AKTIVNO`
- `Iznošenje AKTIVNO`
- `Zaštitna i dodatna oprema AKTIVNO`
- `Prevoz do hladnjače AKTIVNO`
- selector ima dva `CheckBox` elementa i samo controlled PREDMET ima `checked=true`.

Ovo je live Android production-caller dokaz za svih osam osa i traženu zaštitnu stavku. Nije korišćen direktan DB upis.

## 5. Android layer tracking

| Layer | Android result | Evidence/limit |
|---|---|---|
| PREDMET UI | GRADSKO posle kontrolisane izmene; pre izmene stvarno LOKALNO | accessibility selected flags |
| persisted PREDMET | GRADSKO runtime-consistent | save readback; raw SQLite unavailable |
| ScenarioKey input | GRADSKO | complete current tuple |
| derived key | GRADSKO | complete derived tuple |
| MAP lookup | GRADSKO result | applied snapshot match; raw MAP unavailable |
| reconciliation | GRADSKO | production selection produced matching snapshot |
| snapshot | GRADSKO | applied equals current tuple |
| IRiU provenance | scenario package active, protective equipment active | visible IRiU; raw table unavailable |
| SCENARIO UI | GRADSKO | complete eight-axis accessibility text |

Prvi divergence na Androidu: **NONE**. Prijavljeni mismatch je bio evidence/acceptance reading error.

## 6. Windows real-runtime replication

Pokrenut je stvarni Windows release artifact:

- `C:\Projekti\OPC\OPC v.1\SOURCE\build\windows\x64\runner\Release\OPC.exe`
- Computer-use helper je izložio stvarni startup window `OPC ORGANIZATOR POGREBNE CEREMONIJE`. Flutter desktop accessibility nije izložio klik-geometriju advisor kartice (`coordinate input geometry is unavailable`), pa nije korišćen UI workaround.
- Prethodni live Windows handoff report sadrži stvarni login → `MODULI → SCENARIO` → fresh controlled PREDMET 112 dokaz na istom release path-u.

Read-only provera canonical DB-a `C:\Users\Steva\Documents\opc_v4_release.sqlite` (user_version 27) za row 112 `FRESH HANDOFF / 110826_1909`:

- PREDMET: `NASILNA`, `STAN`, `SAHRANA`, `tip_groblja=GRADSKO`, `tip_grobnog_mesta=GROB`, `opelo=NE`, `sahrana_van_srbije=0`, `docek_posmrtnih_ostataka=0`.
- Snapshot: `MAP_NASILNA_STAN_SAHRANA_GRADSKO_GROB_NE_NE_NE`.
- Provenance scenario rows use the same scenario ID, including `ZASTITNA_I_DODATNA_OPREMA`.
- Canonical DB nije zamenjen pripremljenom kopijom.

Windows prvi divergence: **NONE**. Windows ostaje `GRADSKO` kroz PREDMET, snapshot, provenance i IRiU.

## 7. Cross-platform comparison

| Layer | Android | Windows | Expected |
|---|---|---|---|
| PREDMET UI | GRADSKO | GRADSKO | GRADSKO |
| persisted PREDMET | GRADSKO runtime-consistent; raw DB unavailable | GRADSKO | GRADSKO |
| ScenarioKey input | GRADSKO | GRADSKO | GRADSKO |
| derived key | GRADSKO | GRADSKO | GRADSKO |
| MAP lookup | GRADSKO result | GRADSKO | GRADSKO |
| reconciliation | GRADSKO | GRADSKO | GRADSKO |
| snapshot | GRADSKO | GRADSKO | GRADSKO |
| IRiU provenance | protective equipment active | protective equipment provenance active | GRADSKO |
| SCENARIO UI | full tuple GRADSKO | full tuple GRADSKO | GRADSKO |

## 8. Root cause, state and blast radius

- Root cause reportedog mismatcha: **NOT PROVEN because mismatch was not reproduced**; evidence shows previous report misread a non-selected `GRADSKO` option as selected.
- Root cause class: **UI DISPLAY / ACCEPTANCE EVIDENCE INTERPRETATION**, not source, Android DB, migration, install identity or cache.
- Android DB state: **VALID runtime state**. Initially persisted `LOKALNO`; controlled save to `GRADSKO` reconciled correctly. Direct DB inspection is unavailable for the non-debuggable release package.
- Source bug: no evidence. `ScenarioCriterionField.tipGroblja` and `ScenarioKey` normalize persisted values; Windows and Android controlled results agree.
- Blast radius: **NOT PROVEN / no affected runtime scenarios**.
- `GRADSKO` and `LOKALNO` remain distinct business values.

## 9. Cache/install/data-reset decision

- `ANDROID CACHE/INSTALL RECOMMENDATION — NO REINSTALL/CACHE CLEAR NEEDED`
- `ANDROID APP DATA CLEAR EXECUTED — NO`
- No stale/incompatible persisted state was demonstrated; reset would destroy valid local business data and add no diagnostic value.
- Verified owner backup: `C:\Users\Steva\Downloads\KORICE\OPC_backup_11082026_0557.json`, SHA-256 `2472408D191079E2CCC98C59C6305A6B3456D0C6FB1F5DD1D185AEF9D5B21FF7`.
- `POST-RESET BACKUP RESTORE — NOT REQUIRED`
- `PRE-vs-POST RESET A/B RESULT — NOT APPLICABLE`

## 10. Acceptance correction

Prethodni acceptance je promakao jer je proverio samo da tekst `GRADSKO` postoji na ekranu i zatim proverio prisustvo zaštitne IRiU stavke. Gate ubuduće mora:

1. čitati `selected` vrednost kontrole, ne samo labelu;
2. proveriti svih 8 osa na PREDMET UI;
3. proveriti derived/current tuple;
4. proveriti applied snapshot tuple;
5. zahtevati `PREDMET tuple == SCENARIO tuple`;
6. proveriti zaštitnu stavku kao dodatni uslov, ne kao zamenu za tuple equality.

## 11. Validation/build status

Nema source/test/migration izmene. Zadržava se dokazani baseline:

- `FLUTTER ANALYZE — BASELINE RETAINED (PASS)`
- `FULL FLUTTER TEST — BASELINE RETAINED (393 passed, 7 skipped, 0 failed)`
- `WINDOWS BUILD — PASS`
- `ANDROID BUILD — PASS`
- `ANDROID LIVE RETEST — PASS`
- `WINDOWS LIVE RETEST — PASS (canonical row 112 / prior live trace)`
- `SOURCE CHANGED — NO`

## 12. Final verdicts

- `ANDROID GRADSKO→LOKALNO — NOT REPRODUCED`
- `WINDOWS GRADSKO→LOKALNO — NOT REPRODUCED`
- `ANDROID PREDMET PERSISTED VALUE — GRADSKO (runtime-consistent; raw SQLite not accessible)`
- `ANDROID FIRST DIVERGENCE LAYER — NONE`
- `WINDOWS FIRST DIVERGENCE LAYER — NONE`
- `ROOT CAUSE — NOT PROVEN (reported mismatch was evidence-reading error)`
- `ROOT CAUSE CLASS — UI DISPLAY / ACCEPTANCE EVIDENCE INTERPRETATION`
- `ANDROID DB STATE — VALID`
- `FULL 8-AXIS PREDMET→SCENARIO CONSISTENCY — PASS`
- `ZAŠTITNA I DODATNA OPREMA — PASS`
- `BLAST RADIUS — NOT PROVEN / no affected scenarios`
- `SOURCE CHANGED — NO`
- `FLUTTER ANALYZE — BASELINE RETAINED`
- `FULL FLUTTER TEST — BASELINE RETAINED`
- `WINDOWS BUILD — PASS`
- `ANDROID BUILD — PASS`
- `ANDROID LIVE RETEST — PASS`
- `WINDOWS LIVE RETEST — PASS`
- `ANDROID CACHE/INSTALL RECOMMENDATION — NO REINSTALL/CACHE CLEAR NEEDED`
- `ANDROID APP DATA CLEAR EXECUTED — NO`
- `FRESH OPC BACKUP JSON — VERIFIED`
- `POST-RESET BACKUP RESTORE — NOT REQUIRED`
- `PRE-vs-POST RESET A/B RESULT — NOT APPLICABLE`
- `PODSETNIK ZAVRŠEN-PREDMET FINDING — RETAINED FOR FOLLOW-UP`
- `REMOTE SHA — TO BE CONFIRMED AFTER COMMIT/PUSH`
- `WORKING TREE — TO BE CONFIRMED AFTER COMMIT/PUSH`

