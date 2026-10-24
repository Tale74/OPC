# OPC — Organizator pogrebne ceremonije

Ovo je kanonski Flutter izvor OPC v1.5 / aplikaciona verzija 4.0.3. Autoritativni prihvaćeni aplikacioni commit je `cc16f94a1a5f2877050a8939f3685ec36ec2e1f0`; dokumentaciona konsolidacija od 24.10.2026. dodaje uputstva bez promene aplikacionog koda. Izvor ne sadrži poslovne baze, privatni licencni seed, signing ključeve ni korisničke podatke.

## Trenutni dokumenti

- [Izvor, gradnja i kontinuitet](docs/SOURCE_BUILD_AND_CONTINUITY_SR.md)
- [Trenutno stanje](docs/OPC_CURRENT_DEVELOPMENT_STATE.md)
- [Prihvatna matrica 4.0.3](docs/FINAL_ACCEPTANCE_MATRIX.md)
- [Proizvod i poslovna pravila](docs/OPC_PRODUCT_AND_DOMAIN.md)
- [Arhitektura](docs/OPC_ARCHITECTURE.md)
- [Razvojni postupak](docs/OPC_DEVELOPMENT.md)
- [Kvalitet i izdavanje](docs/OPC_QUALITY_RELEASE.md)
- [Inženjerski profil](docs/OPC_ENGINEERING_PROFILE.md)
- [Izvor dokumentacije](docs/DOCS_SOURCE_PROVENANCE.csv)

Dodatna pravila terminologije, migracije baze, backup-a, stop-lista i potpuni poslovni snapshot nalaze se u `docs/`. Istorijski radni zapisi nalaze se izvan ovog kanonskog Git stabla. Windows/Android/PWA imaju prethodne izolovane update dokaze; Apple artefakti ostaju nepotpisani tehnički izlazi.

Nakon izmena aplikacionog koda sprovoditi serijski `flutter analyze` i pun `flutter test`, pa tek onda odgovarajući build. Detalji i platformni preduslovi su u vodiču.
