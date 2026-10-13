# OPC v1.5 OWNER final development acceptance — 2026-10-13

## Decision

OWNER accepts the current OPC v1.5 product as stable, functionally correct and
final. The OWNER-approved final guide integration on 2026-10-12 is the last
v1.5 development and correction task. This record closes v1.5 product
development; it does not state that every release or handover gate is complete.

The OWNER-accepted Android Narrow/Wide delta-runtime dated 2026-10-13 is
bounded to the checks actually executed. Its comprehensive coverage label
remains `PARTIAL`; unperformed guide chapters and contextual routes are not
PASS. There is no Windows physical runtime claim.

## Accepted implementation and QA evidence

The final guide integration retained the OWNER-approved 33 chapter content,
stable chapter IDs/order/context routes and the OWNER direction that all guide
text, including headings, is italic. Evidence reports focused regressions
`7/7 PASS`, `flutter analyze --no-pub PASS`, complete serial Flutter suite
`663 PASS / 9 SKIP / 0 FAIL`, Windows release build PASS and Android production
release build PASS. The nine skips remain skips.

Android APK: 79,364,113 bytes,
SHA-256 `2C98AFF3CFB3A37A3C0412DE8DC3AC2DC63D8AEF85EBB3F4E28CE4CA6CCF8489`.
Windows `data/app.so`: 13,140,912 bytes,
SHA-256 `F7A1FD9A0634523E105C6EF3C306CAFD5AA8F18D3B6FB92C962251A4CDC70C04`.
Windows runner `OPC.exe`: 89,600 bytes,
SHA-256 `E6C2805D1F99621DDA30260B916289AF8CF3A1115BD7B28C80B13A0C5F830BAD`.
The packaged guide JSON is 36,424 bytes,
SHA-256 `53F24B8525DF09C251CD550AF113EB260CA55582D920E88953F13BBCAF42FBF7`.

These are retained evidence from the accepted implementation task, not newly
executed QA or proof of installed runtime behavior. See
`OPC_V15_FINAL_CLOSURE_REPORT.md` and the external review package for lineage.

## Separate release states

Windows physical runtime, formal signing, distribution/publisher identity,
release handover and any final public release are distinct from development
closure and are not claimed complete by this decision. No OPC Int audit or
implementation is authorized here.
