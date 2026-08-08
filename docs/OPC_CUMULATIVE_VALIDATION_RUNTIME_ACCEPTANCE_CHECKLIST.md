# OPC Cumulative Validation — Runtime Acceptance Checklist

Build evidence and technical gates are recorded in
`docs/OPC_CUMULATIVE_VALIDATION_BUILD_RUNTIME_PREPARATION_REPORT.md` and
`C:\Projekti\OPC\OPC v.1\RUNTIME`.

Runtime acceptance is an owner action. Codex must not mark either platform as
runtime PASS without the owner completing the checks below.

## A. SCENARIO basic

- [ ] Open the SCENARIO module.
- [ ] Confirm no legacy SCENARIO UI is visible.
- [ ] Confirm no internal MAP IDs are shown to the user.
- [ ] Confirm the applied scenario is clearly tied to the active PREDMET.

## B. 1008 business confidence

- [ ] Exercise representative scenario flows only; do not attempt 1008 manual
  checks. The complete 1008 matrix is covered by the golden gate.

## C. KATALOG FIKSNA

- [ ] Open a FIKSNA catalog item.
- [ ] Enter a price, save, close, and reopen.
- [ ] Confirm the saved price is retained.
- [ ] Confirm no photo placeholder is present.

## D. CRNINA

- [ ] Confirm CRNINA behaves as KATALOŠKA.
- [ ] Confirm no duplicate CRNINA category is created.
- [ ] Confirm CRNINA remains in OSNOVNI PAKET.

## E. IRiU pricing

- [ ] Add an item with a catalog price and `KOM=1`; verify automatic IZNOS.
- [ ] Change to `KOM>1`; verify `KOM × CENA = IZNOS`.
- [ ] Apply a manual IZNOS override and save/reopen.
- [ ] Confirm the manual override remains intact.

## F. Scenario change/diff

- [ ] Apply Scenario A.
- [ ] Change the active PREDMET condition so a diff appears.
- [ ] Before confirmation, confirm IRiU is unchanged.
- [ ] Confirm the displayed ADD/REMOVE/CHANGE diff is correct and PREDMET-scoped.
- [ ] Confirm manual rows remain, including their KOM and manual IZNOS.
- [ ] Confirm newly added rows receive snapshot price and the correct automatic amount.

## G. A → B → C

- [ ] Change the condition twice before confirming.
- [ ] Confirm the final diff is calculated from the last applied A to C.

## H. Multi-PREDMET

- [ ] Open two PREDMETI.
- [ ] Create a pending diff in only one.
- [ ] Confirm the other PREDMET remains completely isolated and unchanged.

## I. Reopen

- [ ] Close and reopen the PREDMET.
- [ ] Confirm applied scenario, IRiU rows, snapshot prices, and manual override
  remain consistent.

## J. Windows/Android parity

- [ ] Repeat the same representative PREDMET flow on Windows.
- [ ] Repeat it on Android.
- [ ] Confirm both platforms produce the same business result.

Owner notes:

```text
Windows result:
Android result:
Observed differences / evidence paths:
Owner name and date:
```

Final owner decision:

```text
WINDOWS RUNTIME — PENDING OWNER ACCEPTANCE
ANDROID RUNTIME — PENDING OWNER ACCEPTANCE
```
