import '../../../../core/database/database.dart';
import '../../../../core/format/app_text_format.dart';
import '../../../../core/format/app_time_format.dart';
import 'parte_models.dart';

class ParteInitialComposition {
  const ParteInitialComposition({
    required this.draft,
    required this.sourceFingerprint,
    required this.warnings,
  });

  final ParteDraft draft;
  final String sourceFingerprint;
  final List<String> warnings;

  bool get grammarRequiresReview =>
      warnings.contains(ParteInitialComposer.genderWarning);
}

class ParteInitialComposer {
  const ParteInitialComposer();

  static const String genderWarning =
      'Pol nije M ili Z. Uvod i gramatički oblik zahtevaju ručnu proveru.';

  ParteInitialComposition compose({
    required PredmetiData predmet,
    ParteTemplate template = ParteTemplate.builtInStandard,
  }) {
    final warnings = <String>[];
    final pismo = predmet.pismo == 'CIRILICA' ? 'CIRILICA' : 'LATINICA';
    final pol = predmet.pol.trim().toUpperCase();
    final validGender = pol == 'M' || pol == 'Z';
    if (!validGender) warnings.add(genderWarning);

    final rawText = <String, String>{
      'intro': validGender
          ? _fixed(pol == 'Z' ? 'Naša voljena' : 'Naš voljeni', pismo)
          : '',
      'name': _displayName(predmet),
      'profession': _profession(predmet),
      'years': _lifeYears(predmet),
      'death': validGender && predmet.datumSmrti.trim().isNotEmpty
          ? '${_fixed(pol == 'Z' ? 'preminula je' : 'preminuo je', pismo)} '
                '${_dateSentence(predmet.datumSmrti, pismo)}.'
          : '',
      'ceremony': _ceremonySentence(predmet, pismo),
      'secondary': _secondarySentence(predmet, pismo),
      'mournersHeading': _fixed('Ožalošćeni:', pismo),
      'mourners': normalizeText(predmet.ozaloseni),
    };
    final text = rawText.map(
      (key, value) => MapEntry(key, _selectedScript(value, pismo)),
    );

    final source = <String, Object?>{
      'brojPredmeta': predmet.brojPredmeta,
      'ime': predmet.ime,
      'prezime': predmet.prezime,
      'srednje': predmet.srednje,
      'pol': predmet.pol,
      'datumRodjenja': predmet.datumRodjenja,
      'datumSmrti': predmet.datumSmrti,
      'titula': predmet.titula,
      'titulaIspred': predmet.titulaIspred,
      'zanimanje': predmet.zanimanje,
      'zanimanjeNaParti': predmet.zanimanjeNaParti,
      'cin': predmet.cin,
      'cinNaParti': predmet.cinNaParti,
      'srednjeNaParti': predmet.srednjeNaParti,
      'nadimak': predmet.nadimak,
      'nadimakNaParti': predmet.nadimakNaParti,
      'nadimakCrtica': predmet.nadimakCrtica,
      'vrstaCeremonije': predmet.vrstaCeremonije,
      'datumCeremonije': predmet.datumCeremonije,
      'vremeCeremonije': predmet.vremeCeremonije,
      'groblje': predmet.groblje,
      'opelo': predmet.opelo,
      'opeloMesto': predmet.opeloMesto,
      'vremeOpela': predmet.vremeOpela,
      'vremeIspracaja': predmet.vremeIspracaja,
      'simbol': predmet.simbol,
      'pismo': predmet.pismo,
      'ozaloseni': predmet.ozaloseni,
    };

    return ParteInitialComposition(
      draft: ParteDraft(
        textByBlock: text,
        blocks: List<ParteBlockSpec>.from(template.blocks),
        widthMm: template.widthMm,
        heightMm: template.heightMm,
        horizontalMarginMm: template.horizontalMarginMm,
        verticalMarginMm: template.verticalMarginMm,
        symbolId: predmet.simbol,
      ),
      sourceFingerprint: parteCanonicalFingerprint(source),
      warnings: warnings,
    );
  }

  String _fixed(String value, String pismo) =>
      pismo == 'CIRILICA' ? transliterateLatinToCyrillic(value) : value;

  String _selectedScript(String value, String pismo) => pismo == 'CIRILICA'
      ? transliterateLatinToCyrillic(value)
      : transliterateCyrillicToLatin(value);

  String _displayName(PredmetiData p) {
    final result = <String>[];
    final title = normalizeText(p.titula);
    final nickname = normalizeText(p.nadimak);
    if (p.titulaIspred && title.isNotEmpty) result.add(title);
    if (p.ime.trim().isNotEmpty) {
      result.add(normalizeSerbianPersonName(p.ime));
    }
    if (p.srednjeNaParti && p.srednje.trim().isNotEmpty) {
      result.add(normalizeSerbianPersonName(p.srednje));
    }
    if (p.nadimakNaParti && !p.nadimakCrtica && nickname.isNotEmpty) {
      result.add('"${normalizeSerbianPersonName(nickname)}"');
    }
    if (p.prezime.trim().isNotEmpty) {
      result.add(normalizeSerbianPersonName(p.prezime));
    }
    if (p.nadimakNaParti && p.nadimakCrtica && nickname.isNotEmpty) {
      result.add('- ${normalizeSerbianPersonName(nickname)}');
    }
    if (!p.titulaIspred && title.isNotEmpty) result.add(title);
    return result.join(' ');
  }

  String _profession(PredmetiData p) {
    final result = <String>[];
    if (p.zanimanjeNaParti && p.zanimanje.trim().isNotEmpty) {
      result.add(normalizeText(p.zanimanje));
    }
    if (p.cinNaParti && p.vojniPenzioner == 'DA' && p.cin.trim().isNotEmpty) {
      result.add(normalizeText(p.cin));
    }
    return result.join('\n');
  }

  String _lifeYears(PredmetiData p) {
    final birth = _year(p.datumRodjenja);
    final death = _year(p.datumSmrti);
    if (birth.isEmpty && death.isEmpty) return '';
    return '$birth — $death.';
  }

  String _year(String value) {
    final parts = value.split('.');
    if (parts.length >= 3 && parts[2].trim().length == 4) {
      return parts[2].trim();
    }
    return value.trim().length == 4 ? value.trim() : '';
  }

  String _dateSentence(String value, String pismo) {
    final parts = value.split('.');
    if (parts.length < 3) return value.trim();
    final day = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final year = parts[2].trim();
    const months = [
      '',
      'januara',
      'februara',
      'marta',
      'aprila',
      'maja',
      'juna',
      'jula',
      'avgusta',
      'septembra',
      'oktobra',
      'novembra',
      'decembra',
    ];
    final monthName = month >= 1 && month <= 12 ? months[month] : '';
    return '$day. ${_fixed(monthName, pismo)} $year. ${_fixed('godine', pismo)}';
  }

  String _weekday(String value, String pismo) {
    final parts = value.split('.');
    if (parts.length < 3) return '';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return '';
    const days = [
      'ponedeljak',
      'utorak',
      'sredu',
      'četvrtak',
      'petak',
      'subotu',
      'nedelju',
    ];
    try {
      return _fixed(days[DateTime(year, month, day).weekday - 1], pismo);
    } catch (_) {
      return '';
    }
  }

  String _ceremonySentence(PredmetiData p, String pismo) {
    if (p.datumCeremonije.trim().isEmpty || p.groblje.trim().isEmpty) {
      return '';
    }
    final type = switch (p.vrstaCeremonije) {
      'SAHRANA' || 'SAHRANA_EKSPRES' => 'Sahrana',
      'KREMACIJA' || 'KREMACIJA_EKSPRES' => 'Kremacija',
      'SMESTAJ_URNE' => 'Smeštaj urne',
      'RASIPANJE_PEPELA' => 'Rasipanje pepela',
      _ => 'Ceremonija',
    };
    final time = formatTimeForSentence(p.vremeCeremonije);
    final timePart = time.isEmpty
        ? ''
        : ' ${_fixed('u', pismo)} $time ${_fixed('časova', pismo)}';
    return '${_fixed(type, pismo)} ${_fixed('je u', pismo)} '
        '${_weekday(p.datumCeremonije, pismo)}, '
        '${_dateSentence(p.datumCeremonije, pismo)}$timePart '
        '${_fixed('na groblju', pismo)} ${toTitleCaseWords(p.groblje)}.';
  }

  String _secondarySentence(PredmetiData p, String pismo) {
    if (p.opelo == 'DA' && p.vremeOpela.trim().isNotEmpty) {
      final time = formatTimeForSentence(p.vremeOpela);
      final place = p.opeloMesto.trim().isEmpty
          ? ''
          : ' ${_fixed('u', pismo)} ${_opeloPlace(p.opeloMesto, pismo)}';
      return '${_fixed('Opelo počinje u', pismo)} $time ${_fixed('časova', pismo)}$place.';
    }
    if (p.opelo != 'DA' && p.vremeIspracaja.trim().isNotEmpty) {
      final time = formatTimeForSentence(p.vremeIspracaja);
      return '${_fixed('Ispraćaj počinje u', pismo)} $time ${_fixed('časova', pismo)}.';
    }
    return '';
  }

  String _opeloPlace(String value, String pismo) {
    final fixed = switch (value.toUpperCase().trim()) {
      'KAPELA NA GROBLJU' => 'kapeli na groblju',
      'CRKVA NA GROBLJU' => 'crkvi na groblju',
      'U PORODIČNOM DOMU' => 'porodičnom domu',
      'KOD GROBNOG MESTA' => 'kod grobnog mesta',
      _ => '',
    };
    return fixed.isEmpty ? toTitleCaseWords(value) : _fixed(fixed, pismo);
  }
}
