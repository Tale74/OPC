import '../database/database.dart';

/// Čita i stare IRiU JSON redove nastale pre editabilnog SCENARIO modela.
///
/// Nova polja su izvedeni rezultat. Kada ih stari izvoz nema, red ostaje
/// legacy/ručni red: aktivan, obezbeđuje ga firma i finansijski se tumači po
/// postojećem iznosu. Sledeća SCENARIO evaluacija bezbedno materijalizuje
/// aktuelnu politiku bez promene činjenica PREDMETA.
IriuData iriuDataFromCompatibleJson(Map<String, dynamic> json) {
  return IriuData.fromJson(<String, dynamic>{
    'poslovniStatus': 'AKTIVNO',
    'obezbedjuje': 'FIRMA',
    'poslovnoUpozorenje': '',
    'poslovniRazlog': '',
    'poslovnaCelina': 6,
    'poslovniRedosled': 0,
    'finansijskiUkljuceno': true,
    'scenarioUpravlja': false,
    'cekaOdlukuKorisnika': false,
    ...json,
  });
}
