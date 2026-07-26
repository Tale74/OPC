# OPC — PREDMET version import source fact-check

**Status:** SOURCE FACT CONFIRMED — DOCUMENTATION CORRECTION REQUIRED — NO IMPLEMENTATION
**Datum:** 26. jul 2026.
**Base SHA:** `7933e8dd3ae90d268e7c15d55342d1cfd153c28f`
**Task branch:** `task/OPC-GATE-0-PREDMET-VERSION-IMPORT-FACT-CHECK`

## 1. Owner tvrdnja

Owner je korigovao postavljeno pitanje:

> Importovani PREDMET ne može da ima nevalidnu vrednost verzije. Potvrditi ovo nakon review koda.

## 2. Source dokazi

### 2.1. Database/model contract

- `lib/core/database/tables/predmeti_table.dart:L11` definiše `verzija` kao non-null integer sa default vrednošću `1`.
- Generated `PredmetiData` zahteva `int verzija`.
- `PredmetiData.fromJson` poziva `serializer.fromJson<int>(json['verzija'])`.

### 2.2. Official OPC export

- `_serijalizujPredmet` prima typed `PredmetiData`.
- Export koristi `p.toJson()`.
- Zato official OPC single-PREDMET JSON uvek nosi integer vrednost `predmet.verzija`.

### 2.3. Import pre transakcije

- `_procitajPredmetTransferPayload` deserializuje `PredmetiData` pre poziva import/replace transakcije.
- Missing polje daje `null`, a Drift `ValueSerializer.fromJson<int>` pokušava `null as int` i odbija vrednost.
- `null`, string, decimalni broj, boolean ili drugi pogrešan tip pada na runtime cast-u.
- Pošto se deserializacija događa pre DB transakcije, takav dokument ne može proizvesti uspešno importovan PREDMET niti delimično upisati PREDMET podatke.

### 2.4. Full-backup putanja

Full backup dodatno koristi `_kPredmetRequiredIntFields`, koji eksplicitno zahteva integer `id`, `verzija` i `exportVerzija`.

## 3. Zaključak

Owner tvrdnja je potvrđena za:

- sve JSON fajlove koje je proizveo OPC;
- missing `verzija`;
- `null`;
- pogrešan JSON tip;
- svaki PREDMET koji je uspešno prošao current import putanju.

Zato pitanje „kako se ponaša uspešno importovani PREDMET sa missing/malformed verzijom“ nije validna owner business decision tačka. Takav PREDMET nije importovan.

## 4. Tehnički validation gap

Current single-PREDMET import proverava tip, ali nema eksplicitnu semantičku proveru:

```text
verzija >= 1
```

Zbog toga bi ručno izmenjen JSON sa integer vrednošću `0` ili negativnim brojem prošao type cast. Official OPC exporter takvu vrednost ne proizvodi iz normalnog model/lifecycle toka, ali boundary guard nije eksplicitno dokazan.

Dispozicija:

- nije owner poslovna odluka;
- evidentira se kao tehnički characterization/validation dug;
- budući audit treba da potvrdi sve creation/migration/import putanje i, ako je potrebno, uvede zajednički `verzija >= 1` boundary guard;
- do tada se ne uvodi comparator ili hard-block politika zasnovana na relativno višoj/nižoj verziji.

## 5. Test evidence

Postojeći JSON regression testovi potvrđuju typed round-trip, replacement i legacy metadata normalization. Fokusirani testovi za:

- missing `verzija`;
- wrong-type `verzija`;
- `0`;
- negativnu vrednost

nisu pronađeni.

Ovo je test gap, ne otvorena owner odluka.

## 6. Dokumentaciona posledica

Current dokumenti moraju razlikovati:

- `INVALID IMPORT VALUE` — source/boundary validation, Codex tehnički domen;
- `SAME/HIGHER/LOWER VALID VERSION` — buduća conflict UI/business policy tema;
- `keep / replace / cancel` — već potvrđena owner poslovna odluka koja ostaje važeća.

## 7. Status

`OWNER SOURCE CLAIM CONFIRMED — MISSING/MALFORMED VERSION OWNER QUESTION REMOVED — RANGE VALIDATION TECHNICAL GAP RECORDED`
