import 'dart:convert';

import '../../../core/database/database.dart';

enum PredmetSegmentFillState { empty, partial, filled, noFields }

class PredmetSegmentFieldCount {
  const PredmetSegmentFieldCount({required this.filled, required this.total});

  final int filled;
  final int total;

  PredmetSegmentFillState get state {
    if (total == 0) return PredmetSegmentFillState.noFields;
    if (filled == 0) return PredmetSegmentFillState.empty;
    if (filled == total) return PredmetSegmentFillState.filled;
    return PredmetSegmentFillState.partial;
  }

  String get stateLabel => switch (state) {
    PredmetSegmentFillState.empty => 'NEMA UNETIH PODATAKA',
    PredmetSegmentFillState.partial => 'DELIMIČNO POPUNJENO',
    PredmetSegmentFillState.filled => 'POPUNJENO',
    PredmetSegmentFillState.noFields => 'NEMA POLJA ZA RUČNI UNOS',
  };
}

/// Counts currently applicable editable inputs by PREDMET segment.
///
/// The count is presentation-only. Selected options (including displayed
/// defaults) are complete selections; decision switches are excluded. Derived
/// values, read-only mirrors, calculated totals and navigation-only sections
/// are not manual inputs.
PredmetSegmentFieldCount countPredmetSegmentManualFields({
  required int segmentNumber,
  required PredmetiData predmet,
  List<IriuData> iRiuRows = const <IriuData>[],
  FirmaPodaciData? firmaPodaci,
}) {
  final values = <bool>[];
  void text(String value, {bool included = true}) {
    if (included) {
      final normalized = value.trim();
      values.add(
        normalized.isNotEmpty && normalized.toLowerCase() != 'redacted',
      );
    }
  }

  void choice(String value, String defaultValue, {bool included = true}) {
    if (included) {
      values.add(value.trim().isNotEmpty || defaultValue.trim().isNotEmpty);
    }
  }

  switch (segmentNumber) {
    case 1:
      text(predmet.ime);
      text(predmet.prezime);
      text(predmet.srednje);
      text(predmet.devojackoPrezime, included: predmet.pol == 'Z');
      text(predmet.jmbg);
      text(predmet.datumRodjenja);
      text(predmet.mestoRodjenja);
      text(predmet.adresa);
      text(predmet.imeOca);
      text(predmet.imeMajke);
      choice(predmet.pol, 'M');
    case 2:
      text(predmet.datumSmrti);
      text(predmet.mestoSmrti);
      text(predmet.uzrokSmrti);
    case 3:
      text(predmet.bracnoStanje);
      final hasSpouse = const {
        'OŽENJEN',
        'UDATA',
        'UDOVAC',
        'UDOVICA',
      }.contains(predmet.bracnoStanje);
      text(predmet.bracniDrugIme, included: hasSpouse);
      text(predmet.bracniDrugPrezime, included: hasSpouse);
      final spouseSex = _effectiveSpouseSex(predmet);
      text(
        predmet.bracniDrugDevojacko,
        included: hasSpouse && spouseSex == 'Z',
      );
      text(predmet.bracniDrugJmbg, included: hasSpouse);
      final statuses = <String>{..._decodedValues(predmet.radniStatus)};
      if (statuses.isEmpty) {
        if (predmet.vojniPenzioner == 'DA') {
          statuses.addAll({'PENZIONER_SRBIJE', 'VOJNI_PENZIONER'});
        } else if (predmet.penzionerSrbije == 'DA') {
          statuses.add('PENZIONER_SRBIJE');
        } else if (predmet.penzioner == 'DA') {
          statuses.add('INOSTRANI_PENZIONER');
        }
      }
      values.add(statuses.isNotEmpty);
      final militaryPensioner = statuses.contains('VOJNI_PENZIONER');
      text(predmet.cin, included: militaryPensioner);
      // Military and spouse-rights DA/NE controls are decisions, not manual
      // text fields. Their dependent inputs above remain conditionally counted.
    case 4:
      final requesterType = predmet.naruTip.isEmpty
          ? 'FIZICKO_LICE'
          : predmet.naruTip;
      choice(requesterType, 'FIZICKO_LICE');
      final requesterIsPerson = requesterType != 'PRAVNO_LICE';
      final requesterIsSpouse =
          requesterIsPerson &&
          const {'OŽENJEN', 'UDATA'}.contains(predmet.bracnoStanje) &&
          predmet.bracniDrugIme.isNotEmpty &&
          predmet.naruIme == predmet.bracniDrugIme &&
          predmet.naruPrezime == predmet.bracniDrugPrezime;
      if (requesterIsPerson && !requesterIsSpouse) {
        text(predmet.naruIme);
        text(predmet.naruPrezime);
        text(predmet.naruJmbg);
        text(predmet.naruAdresa);
        text(predmet.naruBrojLk);
        text(predmet.naruTelefon1);
        text(predmet.naruTelefon2);
        text(predmet.naruEmail);
      } else if (requesterIsPerson) {
        text(predmet.naruAdresa);
        text(predmet.naruBrojLk);
        text(predmet.naruTelefon1);
        text(predmet.naruTelefon2);
        text(predmet.naruEmail);
      } else {
        text(predmet.naruPlNaziv);
        text(predmet.naruPlAdresa);
        text(predmet.naruPlPib);
        text(predmet.naruPlMb);
        text(predmet.naruPlOdgovornoLice);
        text(predmet.naruPlTelefon1);
        text(predmet.naruPlTelefon2);
        text(predmet.naruPlEmail);
      }
      if (!predmet.naruIstiZaJkp) {
        final jkpType = predmet.jkpTip.isEmpty
            ? 'FIZICKO_LICE'
            : predmet.jkpTip;
        choice(jkpType, 'FIZICKO_LICE');
        final jkpIsPerson = jkpType != 'PRAVNO_LICE';
        final jkpIsSpouse =
            jkpIsPerson &&
            const {'OŽENJEN', 'UDATA'}.contains(predmet.bracnoStanje) &&
            predmet.bracniDrugIme.isNotEmpty &&
            predmet.jkpIme == predmet.bracniDrugIme &&
            predmet.jkpPrezime == predmet.bracniDrugPrezime;
        if (jkpIsPerson && !jkpIsSpouse) {
          text(predmet.jkpIme);
          text(predmet.jkpPrezime);
          text(predmet.jkpJmbg);
          text(predmet.jkpAdresa);
          text(predmet.jkpBrojLk);
          text(predmet.jkpTelefon1);
          text(predmet.jkpTelefon2);
          text(predmet.jkpEmail);
        } else if (jkpIsPerson) {
          text(predmet.jkpAdresa);
          text(predmet.jkpBrojLk);
          text(predmet.jkpTelefon1);
          text(predmet.jkpTelefon2);
          text(predmet.jkpEmail);
        } else if (firmaPodaci == null ||
            firmaPodaci.naziv.isEmpty ||
            predmet.jkpPlNaziv != firmaPodaci.naziv ||
            predmet.jkpPlPib != firmaPodaci.pib) {
          text(predmet.jkpPlNaziv);
          text(predmet.jkpPlAdresa);
          text(predmet.jkpPlPib);
          text(predmet.jkpPlMb);
          text(predmet.jkpPlOdgovornoLice);
          text(predmet.jkpPlTelefon1);
          text(predmet.jkpPlEmail);
        }
      }
    case 5:
      text(predmet.groblje);
      text(predmet.datumCeremonije);
      text(predmet.vremeCeremonije);
      choice(predmet.tipGroblja, 'GRADSKO');
      choice(predmet.vrstaCeremonije, 'SAHRANA');
      final ceremonyAllowsOpelo = !const {
        'KREMACIJA_EKSPRES',
        'SMESTAJ_URNE',
        'RASIPANJE_PEPELA',
      }.contains(predmet.vrstaCeremonije);
      if (predmet.opelo == 'DA' && ceremonyAllowsOpelo) {
        choice(predmet.opeloMesto, '');
        text(predmet.vremeOpela);
      } else if (ceremonyAllowsOpelo) {
        text(predmet.vremeIspracaja);
      }
      if (predmet.vrstaCeremonije.startsWith('SAHRANA')) {
        choice(predmet.grobnoMesto, 'NOVO');
        choice(predmet.tipGrobnogMesta, 'GROB');
        if (predmet.grobnoMesto == 'POSTOJECE') {
          text(predmet.parcela);
          text(predmet.grobBroj);
          text(predmet.redGrob);
          text(predmet.npk);
        }
      }
      final isCremation = const {
        'KREMACIJA',
        'KREMACIJA_EKSPRES',
      }.contains(predmet.vrstaCeremonije);
      if (isCremation) {
        text(predmet.grobljePolaganjaUrne);
        text(predmet.urnaSifra);
        choice(predmet.tipPolaganja, '');
        if (const {
          'GROB',
          'GROBNICA',
          'KOLUMBARIJUM',
          'ROZARIJUM',
        }.contains(predmet.tipPolaganja)) {
          text(predmet.urnaParcela);
          text(predmet.urnaBroj);
          text(predmet.urnaRed);
          text(predmet.urnaNpk);
        }
      }
      if (predmet.sahranaVanSrbije) {
        text(predmet.svisZemlja);
        text(predmet.svisGrad);
      }
      if (predmet.docekPosmrtnihOstataka) {
        text(predmet.docekMesto);
        text(predmet.docekDatum);
        text(predmet.docekVreme);
      }
    case 6:
      if (predmet.partePotrebna) {
        text(predmet.titula);
        text(predmet.zanimanje);
        text(predmet.nadimak);
        text(predmet.ozaloseni);
        choice(predmet.simbol, 'PRAVOSLAVNI_KRST_SVETOSAVSKI');
        choice(predmet.pismo, 'LATINICA');
        // The position selector appears only with the nickname option. It is
        // already selected in either position; switches themselves do not
        // represent empty manual-entry fields.
        if (predmet.nadimakNaParti) values.add(true);
      }
    case 7:
      text(predmet.napomena);
      for (final row in iRiuRows) {
        text(row.nazivPrikaz);
        text(row.kom);
      }
    case 8:
      values.add(predmet.troskoviJkp != 0);
      values.add(predmet.avans != 0);
      values.add(predmet.popust != 0);
    case 9:
    case 10:
      break;
    default:
      throw RangeError.range(segmentNumber, 1, 10, 'segmentNumber');
  }

  final filled = values.where((isFilled) => isFilled).length;
  return PredmetSegmentFieldCount(filled: filled, total: values.length);
}

Set<String> _decodedValues(String encoded) {
  if (encoded.trim().isEmpty) return const <String>{};
  if (encoded.trim().startsWith('[')) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is List) return decoded.whereType<String>().toSet();
      return <String>{encoded};
    } on FormatException {
      return <String>{encoded};
    }
  }
  return <String>{encoded};
}

String _effectiveSpouseSex(PredmetiData predmet) {
  if (predmet.bracniDrugPol.isNotEmpty) return predmet.bracniDrugPol;
  switch (predmet.bracnoStanje) {
    case 'OŽENJEN':
    case 'UDOVAC':
    case 'RAZVEDEN':
    case 'NEOŽENJEN':
      return 'Z';
    case 'UDATA':
    case 'UDOVICA':
    case 'RAZVEDENA':
    case 'NEUDATA':
      return 'M';
    default:
      return predmet.pol == 'M' ? 'Z' : 'M';
  }
}
