# OPC Product Direction

## Product identity

OPC Windows and OPC Android are equal versions of the same OPC product. There is no role separation between them: Windows is not an “admin” application and Android is not a “field” application.

Platform differences may exist where required by the operating system, screen size, input model, UI form factor, packaging, or platform APIs. Those differences must not redefine the product into separate role-based applications.

## Data model and access direction

Current OPC case databases are local to the user. Real databases, customer data, case data, exports, and private configuration are outside this public repository.

A web/SaaS model is a possible future third access model for the same product logic. It should not replace or subordinate the current Windows and Android versions.

Current architecture and implementation decisions should preserve the option to later extract or reuse:

- domain and business rules;
- database schema and migrations;
- licensing and entitlement logic;
- import/export contracts;
- web-facing services or shared application logic.

## Priorities

The project priority is simplicity, stability, and reliability. Changes should remain reviewable, reversible, and proportionate to actual product needs.
