import 'package:drift/drift.dart';

class Predmeti extends Table {
  // ── Meta ─────────────────────────────────────────────────────────────────
  IntColumn get id => integer().autoIncrement()();
  TextColumn get brojPredmeta => text().withDefault(const Constant(''))();
  // OTVOREN / ZAVRŠEN
  TextColumn get status => text().withDefault(const Constant('OTVOREN'))();
  TextColumn get datumKreiranja => text().withDefault(const Constant(''))();
  IntColumn get savetnikId => integer().nullable()();
  IntColumn get verzija => integer().withDefault(const Constant(1))();
  TextColumn get businessScenarioId =>
      text().withDefault(const Constant('default_funeral_ceremony_policy'))();
  TextColumn get sourceIdentity =>
      text().withDefault(const Constant('local_opc'))();
  IntColumn get createdByKorisnikId => integer().nullable()();
  IntColumn get lastBusinessModifiedByKorisnikId => integer().nullable()();
  TextColumn get lastBusinessModifiedAt => text().nullable()();

  // ── Preminulo lice ───────────────────────────────────────────────────────
  TextColumn get ime => text().withDefault(const Constant(''))();
  TextColumn get prezime => text().withDefault(const Constant(''))();
  TextColumn get srednje => text().withDefault(const Constant(''))();
  TextColumn get devojackoPrezime => text().withDefault(const Constant(''))();
  TextColumn get jmbg => text().withDefault(const Constant(''))();
  // M / Z
  TextColumn get pol => text().withDefault(const Constant('M'))();
  TextColumn get datumRodjenja => text().withDefault(const Constant(''))();
  TextColumn get mestoRodjenja => text().withDefault(const Constant(''))();
  TextColumn get datumSmrti => text().withDefault(const Constant(''))();
  TextColumn get mestoSmrti => text().withDefault(const Constant(''))();
  TextColumn get uzrokSmrti => text().withDefault(const Constant(''))();
  TextColumn get adresa => text().withDefault(const Constant(''))();
  TextColumn get imeOca => text().withDefault(const Constant(''))();
  TextColumn get imeMajke => text().withDefault(const Constant(''))();
  TextColumn get bracnoStanje => text().withDefault(const Constant(''))();
  TextColumn get bracniDrugIme => text().withDefault(const Constant(''))();
  TextColumn get bracniDrugPrezime => text().withDefault(const Constant(''))();
  // M / Z
  TextColumn get bracniDrugPol => text().withDefault(const Constant(''))();
  TextColumn get bracniDrugJmbg => text().withDefault(const Constant(''))();
  TextColumn get bracniDrugDevojacko =>
      text().withDefault(const Constant(''))();
  TextColumn get zanimanje => text().withDefault(const Constant(''))();
  BoolColumn get zanimanjeNaParti =>
      boolean().withDefault(const Constant(false))();
  TextColumn get titula => text().withDefault(const Constant(''))();
  BoolColumn get titulaIspred => boolean().withDefault(const Constant(false))();
  TextColumn get cin => text().withDefault(const Constant(''))();
  BoolColumn get cinNaParti => boolean().withDefault(const Constant(false))();
  BoolColumn get srednjeNaParti =>
      boolean().withDefault(const Constant(false))();
  TextColumn get nadimak => text().withDefault(const Constant(''))();
  BoolColumn get nadimakNaParti =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get nadimakCrtica =>
      boolean().withDefault(const Constant(false))();

  // ── Radni status ─────────────────────────────────────────────────────────
  // ''/PENZIONER_SRBIJE/VOJNI_PENZIONER/INOSTRANI_PENZIONER/U_RADNOM_ODNOSU/DRUGO
  TextColumn get radniStatus => text().withDefault(const Constant(''))();

  // ── Penzioner (legacy — računato iz radniStatus) ──────────────────────────
  // DA / NE
  TextColumn get penzioner => text().withDefault(const Constant('NE'))();
  TextColumn get penzionerSrbije => text().withDefault(const Constant('NE'))();
  TextColumn get vojniPenzioner => text().withDefault(const Constant('NE'))();
  TextColumn get vojnePocasti => text().withDefault(const Constant('NE'))();
  TextColumn get posmrtnaPomoc => text().withDefault(const Constant('NE'))();
  RealColumn get refundacijaPio => real().withDefault(const Constant(0.0))();
  // DA / NE
  TextColumn get narucilacRefundira =>
      text().withDefault(const Constant('NE'))();
  TextColumn get bracniDrugOstvarujePravo =>
      text().withDefault(const Constant('NE'))();
  TextColumn get bracniDrugJePenzioner =>
      text().withDefault(const Constant('NE'))();
  TextColumn get penzionerNapomena =>
      text().withDefault(const Constant(''))();

  // ── Naručilac opreme i usluga ────────────────────────────────────────────
  // FIZICKO_LICE / PRAVNO_LICE
  TextColumn get naruTip => text().withDefault(const Constant(''))();
  TextColumn get naruIme => text().withDefault(const Constant(''))();
  TextColumn get naruPrezime => text().withDefault(const Constant(''))();
  TextColumn get naruImePrezime => text().withDefault(const Constant(''))();
  TextColumn get naruJmbg => text().withDefault(const Constant(''))();
  TextColumn get naruAdresa => text().withDefault(const Constant(''))();
  TextColumn get naruBrojLk => text().withDefault(const Constant(''))();
  TextColumn get naruTelefon1 => text().withDefault(const Constant(''))();
  TextColumn get naruTelefon2 => text().withDefault(const Constant(''))();
  TextColumn get naruEmail => text().withDefault(const Constant(''))();
  TextColumn get naruPlNaziv => text().withDefault(const Constant(''))();
  TextColumn get naruPlAdresa => text().withDefault(const Constant(''))();
  TextColumn get naruPlPib => text().withDefault(const Constant(''))();
  TextColumn get naruPlMb => text().withDefault(const Constant(''))();
  TextColumn get naruPlOdgovornoLice =>
      text().withDefault(const Constant(''))();
  TextColumn get naruPlTelefon1 => text().withDefault(const Constant(''))();
  TextColumn get naruPlTelefon2 => text().withDefault(const Constant(''))();
  TextColumn get naruPlEmail => text().withDefault(const Constant(''))();
  // Ako DA — JKP blok se ne unosi posebno
  BoolColumn get naruIstiZaJkp =>
      boolean().withDefault(const Constant(false))();

  // ── Naručilac troškova JKP ───────────────────────────────────────────────
  TextColumn get jkpTip => text().withDefault(const Constant(''))();
  TextColumn get jkpIme => text().withDefault(const Constant(''))();
  TextColumn get jkpPrezime => text().withDefault(const Constant(''))();
  TextColumn get jkpImePrezime => text().withDefault(const Constant(''))();
  TextColumn get jkpJmbg => text().withDefault(const Constant(''))();
  TextColumn get jkpAdresa => text().withDefault(const Constant(''))();
  TextColumn get jkpBrojLk => text().withDefault(const Constant(''))();
  TextColumn get jkpTelefon1 => text().withDefault(const Constant(''))();
  TextColumn get jkpTelefon2 => text().withDefault(const Constant(''))();
  TextColumn get jkpEmail => text().withDefault(const Constant(''))();
  TextColumn get jkpPlNaziv => text().withDefault(const Constant(''))();
  TextColumn get jkpPlAdresa => text().withDefault(const Constant(''))();
  TextColumn get jkpPlPib => text().withDefault(const Constant(''))();
  TextColumn get jkpPlMb => text().withDefault(const Constant(''))();
  TextColumn get jkpPlOdgovornoLice =>
      text().withDefault(const Constant(''))();
  TextColumn get jkpPlTelefon1 => text().withDefault(const Constant(''))();
  TextColumn get jkpPlEmail => text().withDefault(const Constant(''))();

  // ── Ceremonija ───────────────────────────────────────────────────────────
  TextColumn get groblje => text().withDefault(const Constant(''))();
  // GRADSKO / LOKALNO
  TextColumn get tipGroblja =>
      text().withDefault(const Constant('GRADSKO'))();
  TextColumn get vrstaCeremonije =>
      text().withDefault(const Constant('SAHRANA'))();
  TextColumn get datumCeremonije => text().withDefault(const Constant(''))();
  TextColumn get vremeCeremonije => text().withDefault(const Constant(''))();
  // DA / NE
  TextColumn get opelo => text().withDefault(const Constant('NE'))();
  TextColumn get opeloMesto => text().withDefault(const Constant(''))();
  TextColumn get vremeOpela => text().withDefault(const Constant(''))();
  TextColumn get vremeIspracaja => text().withDefault(const Constant(''))();
  // NOVO / POSTOJECE
  TextColumn get grobnoMesto =>
      text().withDefault(const Constant('NOVO'))();
  // GROB / GROBNICA
  TextColumn get tipGrobnogMesta =>
      text().withDefault(const Constant('GROB'))();
  TextColumn get parcela => text().withDefault(const Constant(''))();
  TextColumn get grobBroj => text().withDefault(const Constant(''))();
  TextColumn get redGrob => text().withDefault(const Constant(''))();
  TextColumn get npk => text().withDefault(const Constant(''))();
  TextColumn get grobnica => text().withDefault(const Constant(''))();
  TextColumn get urnaSifra => text().withDefault(const Constant(''))();
  // NAKNADNO / U_GROB / U_GROBNICU / KOLUMBARIJUM / ROZARIJUM / KUĆA / RASIPANJE
  TextColumn get tipPolaganja =>
      text().withDefault(const Constant('NAKNADNO'))();
  TextColumn get urnaParcela => text().withDefault(const Constant(''))();
  TextColumn get urnaBroj => text().withDefault(const Constant(''))();
  TextColumn get urnaRed => text().withDefault(const Constant(''))();
  TextColumn get urnaNpk => text().withDefault(const Constant(''))();
  BoolColumn get sahranaVanSrbije =>
      boolean().withDefault(const Constant(false))();
  TextColumn get svisZemlja => text().withDefault(const Constant(''))();
  TextColumn get svisGrad => text().withDefault(const Constant(''))();
  BoolColumn get docekPosmrtnihOstataka =>
      boolean().withDefault(const Constant(false))();
  TextColumn get docekMesto => text().withDefault(const Constant(''))();
  TextColumn get docekVreme => text().withDefault(const Constant(''))();

  // ── Parte ────────────────────────────────────────────────────────────────
  TextColumn get simbol =>
      text().withDefault(const Constant('PRAVOSLAVNI_KRST_SVETOSAVSKI'))();
  // LATINICA / CIRILICA
  TextColumn get pismo =>
      text().withDefault(const Constant('LATINICA'))();
  TextColumn get parteIme => text().withDefault(const Constant(''))();
  TextColumn get ozaloseni => text().withDefault(const Constant(''))();

  // ── Finansije ────────────────────────────────────────────────────────────
  RealColumn get avans => real().withDefault(const Constant(0.0))();
  RealColumn get troskoviJkp => real().withDefault(const Constant(0.0))();
  BoolColumn get jkpPlacaSamostalno =>
      boolean().withDefault(const Constant(false))();
  RealColumn get popust => real().withDefault(const Constant(0.0))();
  // JSON lista: ["KES","KARTICA","PRENOS","CEKOVI","NA_RATE"]
  TextColumn get nacinPlacanja => text().withDefault(const Constant('[]'))();
  TextColumn get napomenaPlacanja => text().withDefault(const Constant(''))();
  TextColumn get napomena => text().withDefault(const Constant(''))();

  /// Verzija JSON izvoza jednog PREDMETA — uvećava se pri svakom exportu.
  IntColumn get exportVerzija => integer().withDefault(const Constant(0))();
}
