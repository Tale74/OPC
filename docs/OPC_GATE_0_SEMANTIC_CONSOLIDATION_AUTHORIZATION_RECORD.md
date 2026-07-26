# OPC — Gate 0 semantic consolidation authorization record

**Status:** OWNER AUTHORIZED — DOCUMENTATION ONLY — NO DELETION
**Datum:** 26. jul 2026.
**Base branch:** `task/OPC-GATE-0-DOCUMENTATION-BLOCKER-EXTRACTION`
**Base SHA:** `bebefd9e3f84a488f97a0ac00e133acc518f0420`
**Task branch:** `task/OPC-GATE-0-DOCUMENTATION-SEMANTIC-CONSOLIDATION`

## 1. Owner autorizacija

Owner je odobrio:

- tematsku semantičku konsolidaciju 704 tvrdnje koje su u prethodnoj fazi ostale u `OWNER_SEMANTIC_REVIEW_REQUIRED`;
- Codex klasifikaciju tehničkih, arhitektonskih i proceduralnih tvrdnji;
- izdvajanje stvarnih konflikata poslovne politike;
- izdvajanje odluka bez dokazanog autoritativnog naslednika;
- izdvajanje predloženih promena poslovne logike koje nisu owner odluke.

## 2. Granice autorizacije

Nije odobreno:

- brisanje, premeštanje ili arhiviranje ciljnih dokumenata;
- menjanje aplikacionog koda, testova, baze, migracija, build konfiguracije ili runtime ponašanja;
- proglašavanje preporuke owner odlukom;
- Git history rewrite.

## 3. Authority pravilo

Codex može zaključiti tehničku, arhitektonsku i proceduralnu dispoziciju samo ako:

- ne menja PREDMET kao jedinu autoritativnu poslovnu istinu;
- ne menja poslovno značenje SCENARIO, IRiU, KATALOG ili derivata;
- čuva Windows/Android parity poslovnog rezultata;
- ne uvodi novu poslovnu politiku.

Svaka tvrdnja koja prelazi te granice ostaje u owner decision queue-u ili ostaje zaštićena do dokazanog section-level naslednika.
