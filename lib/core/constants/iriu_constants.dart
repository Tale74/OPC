/// Interni nazivi IRIU kategorija — nepromenjivi stringovi.
/// Koriste se za automatsku logiku i Nalog za opremanje.
/// NIKAD se ne prikazuju korisniku direktno.
abstract final class IriuK {
  static const String sanduk = 'SANDUK';
  static const String pokrovGarnitura = 'POKROV_GARNITURA';
  static const String obelezje = 'OBELEZJE';
  static const String peskirZaKrst = 'PESKIR_ZA_KRST';
  static const String posmrtneParte = 'POSMRTNE_PARTE';
  static const String hladnjaca = 'HLADNJACA';
  static const String spremaanjePokojnika = 'SPREMANJE_POKOJNIKA';
  static const String iznosenje = 'IZNOSENJE';
  static const String prevozDoHladnjace = 'PREVOZ_DO_HLADNJACE';
  static const String prevozDoGroblja = 'PREVOZ_DO_GROBLJA';
  static const String prevozSprovoda = 'PREVOZ_SPROVODA';
  static const String crnina = 'CRNINA';
  static const String limeniUlozak = 'LIMENI_ULOZAK';
  static const String lemovanje = 'LEMOVANJE';
  static const String agencijskeUsluge = 'AGENCIJSKE_USLUGE';
  static const String transportnaVreca = 'TRANSPORTNA_VRECA';
  static const String cvece = 'CVECE';
  static const String kompletZaOpelo = 'KOMPLET_ZA_OPELO';
  static const String medjunarodniPrevoz = 'MEDJUNARODNI_PREVOZ';
  static const String medjunarodnaDocumentacija = 'MEDJUNARODNA_DOKUMENTACIJA';
  static const String balsamovanje = 'BALSAMOVANJE';
  static const String cargoTroskovi = 'CARGO_TROSKOVI';
  static const String cituljaP = 'CITULJA_POLITIKA';
  static const String cituljaNo = 'CITULJA_NOVOSTI';

  /// Nazivi za prikaz po internom nazivu — koriste se pri automatskom unosu.
  static const Map<String, String> naziviPrikaz = {
    sanduk: 'Sanduk',
    pokrovGarnitura: 'Pokrov garnitura',
    obelezje: 'Obeležje',
    peskirZaKrst: 'Peškir',
    posmrtneParte: 'Posmrtne parte',
    hladnjaca: 'Hladnjača',
    spremaanjePokojnika: 'Spremanje preminulog lica',
    iznosenje: 'Iznošenje',
    prevozDoHladnjace: 'Prevoz do hladnjače',
    prevozDoGroblja: 'Prevoz do groblja',
    prevozSprovoda: 'Prevoz sprovoda',
    crnina: 'Crnina',
    limeniUlozak: 'Limeni uložak',
    lemovanje: 'Lemovanje',
    agencijskeUsluge: 'Agencijske usluge',
    transportnaVreca: 'Transportna vreća',
    cvece: 'Cveće',
    kompletZaOpelo: 'Komplet za opelo',
    medjunarodniPrevoz: 'Međunarodni prevoz',
    medjunarodnaDocumentacija: 'Međunarodna dokumentacija',
    balsamovanje: 'Balsamovanje',
    cargoTroskovi: 'Cargo troškovi',
    cituljaP: 'Čitulje',
    cituljaNo: 'Čitulje',
  };

  /// Stavke koje se uvek predlažu na novom predmetu (bez uslova).
  static const Set<String> uvekPredlazemo = {
    sanduk,
    obelezje,
    pokrovGarnitura,
    peskirZaKrst,
    posmrtneParte,
    crnina,
    agencijskeUsluge,
    cvece,
    cituljaP,
  };
}
