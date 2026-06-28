# OPC Product Direction

## Product identity

OPC Windows and OPC Android are equal versions of the same OPC product. There is no role separation between them: Windows is not an “admin” application and Android is not a “field” application.

Platform differences may exist where required by the operating system, screen size, input model, UI form factor, packaging, or platform APIs. Those differences must not redefine the product into separate role-based applications.

## Data model and access direction

Current OPC case databases are local to the user. Real databases, customer data, case data, exports, and private configuration are outside this public repository.

OPC Web is a possible future third runtime form for the same product logic. It should not replace or subordinate the current Windows and Android versions.

OPC Web is a complementary OS-proof commercial access/runtime direction, not the primary product name, not a replacement for the local Windows/Android product, and not a presumption that a server becomes the master `PREDMET` database. Server-side components may host access, licensing, package, backup, transfer, signaling, or mediation functions only under a future owner-approved architecture.

Current architecture and implementation decisions should preserve the option to later extract or reuse:

- domain and business rules;
- database schema and migrations;
- licensing and entitlement logic;
- import/export contracts;
- web-facing services or shared application logic.

The current canonical product terminology is `OPC Web`. Older public references to `OPC Web Pristup` are historical/supporting wording and must not be used as the new primary term.

## Priorities

The project priority is simplicity, stability, and reliability. Changes should remain reviewable, reversible, and proportionate to actual product needs.
