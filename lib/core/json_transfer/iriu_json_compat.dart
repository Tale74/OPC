import '../database/database.dart';
import '../utils/stable_id_generator.dart';

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
    'cena': 0.0,
    'finansijskiUkljuceno': true,
    'scenarioUpravlja': false,
    'cekaOdlukuKorisnika': false,
    ...json,
    // Legacy JSON has no occurrence identity. Generate it exactly once while
    // materializing the imported row; current JSON preserves the source value.
    'portableOccurrenceId': resolveIriuOccurrencePortableId(
      json['portableOccurrenceId'] is String
          ? json['portableOccurrenceId'] as String
          : null,
    ),
  });
}
