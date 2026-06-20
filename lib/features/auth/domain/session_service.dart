import 'package:flutter/foundation.dart';

import '../../../core/database/database.dart';

/// Čuva aktivnog korisnika tokom sesije.
/// Sesija traje dok se korisnik ručno ne odjavi.
class SessionService extends ChangeNotifier {
  KorisniciData? _korisnik;

  KorisniciData? get korisnik => _korisnik;
  bool get prijavljen => _korisnik != null;
  bool get jeAdmin => _korisnik?.uloga == 'ADMINISTRATOR';

  void prijavi(KorisniciData k) {
    _korisnik = k;
    notifyListeners();
  }

  void odjavi() {
    _korisnik = null;
    notifyListeners();
  }
}
