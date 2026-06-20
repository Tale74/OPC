import '../../../core/database/database.dart';

class NbsIpsQrPayloadResult {
  const NbsIpsQrPayloadResult({
    required this.payload,
    required this.normalizovanRacun,
  });

  final String payload;
  final String normalizovanRacun;
}

class NbsIpsQrPayloadBuilder {
  const NbsIpsQrPayloadBuilder._();

  static const obaveznaSvrhaPlacanja = 'Transakcija po nalogu';
  static const obavezniPozivNaBrojTip = 'IME_PREZIME';
  static const podrazumevanaSifraPlacanja = '289';

  static String? validateConfig(AppPodesavanjaData config) {
    if (_normalizujRacun(config.ziroRacun) == null) {
      return 'Tekući račun za QR mora biti validan broj računa.';
    }
    if (!_isValidSifraPlacanja(config.qrSifraPlacanja)) {
      return 'Šifra plaćanja mora imati tačno 3 cifre.';
    }
    if (config.pozivNaBrojTip != obavezniPozivNaBrojTip) {
      return 'Poziv na broj za QR mora koristiti PREMINULO LICE.';
    }
    return null;
  }

  static NbsIpsQrPayloadResult build({
    required AppPodesavanjaData config,
    required double iznosZaNaplatu,
    required String primalacNaziv,
    String pozivNaBroj = '',
    String? sifraPlacanja,
    String svrhaPlacanja = obaveznaSvrhaPlacanja,
  }) {
    final greska = validateConfig(config);
    if (greska != null) {
      throw ArgumentError(greska);
    }
    if (iznosZaNaplatu < 0) {
      throw ArgumentError('Iznos za QR ne može biti negativan.');
    }
    if (primalacNaziv.trim().isEmpty) {
      throw ArgumentError('Naziv primaoca za QR je obavezan.');
    }
    if (svrhaPlacanja.trim() != obaveznaSvrhaPlacanja) {
      throw ArgumentError(
        'Svrha plaćanja za QR mora biti "$obaveznaSvrhaPlacanja".',
      );
    }
    final resolvedSifraPlacanja = sifraPlacanja ?? config.qrSifraPlacanja;
    if (!_isValidSifraPlacanja(resolvedSifraPlacanja)) {
      throw ArgumentError('Šifra plaćanja mora imati tačno 3 cifre.');
    }

    final racun = _normalizujRacun(config.ziroRacun)!;
    final tagovi = <String>[
      'K:PR',
      'V:01',
      'C:1',
      'R:$racun',
      'N:${primalacNaziv.trim()}',
      'I:${_formatirajIznos(iznosZaNaplatu)}',
      'SF:${resolvedSifraPlacanja.trim()}',
      'S:${svrhaPlacanja.trim()}',
    ];

    if (pozivNaBroj.trim().isNotEmpty) {
      tagovi.add('RO:${pozivNaBroj.trim()}');
    }

    return NbsIpsQrPayloadResult(
      payload: tagovi.join('|'),
      normalizovanRacun: racun,
    );
  }

  static String? _normalizujRacun(String racun) {
    final cifre = racun.replaceAll(RegExp(r'\D'), '');
    if (cifre.isEmpty || cifre.length > 18) {
      return null;
    }
    return cifre.padLeft(18, '0');
  }

  static bool _isValidSifraPlacanja(String vrednost) {
    return RegExp(r'^\d{3}$').hasMatch(vrednost.trim());
  }

  static String _formatirajIznos(double iznos) {
    final fixed = iznos.toStringAsFixed(2);
    final delovi = fixed.split('.');
    final decimal = delovi[1] == '00'
        ? ''
        : delovi[1].endsWith('0')
            ? delovi[1].substring(0, 1)
            : delovi[1];
    return decimal.isEmpty
        ? 'RSD${delovi[0]},'
        : 'RSD${delovi[0]},$decimal';
  }
}
