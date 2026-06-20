import '../../../core/constants/iriu_constants.dart';
import '../../../core/database/database.dart';
import '../core_v2/models/iriu_truth_models.dart';
import '../core_v2/services/predmet_iriu_truth_service.dart';
class NalogZaOpremanjePdfPreparedData {
  const NalogZaOpremanjePdfPreparedData({
    required this.fullName,
    required this.godinaRodjenja,
    required this.godinaSmrti,
    required this.mestoSmrti,
    required this.vrstaCeremonije,
    required this.mestoCeremonije,
    required this.datumCeremonije,
    required this.vremeCeremonije,
    required this.oprema,
    required this.usluge,
  });

  final String fullName;
  final String godinaRodjenja;
  final String godinaSmrti;
  final String mestoSmrti;
  final String vrstaCeremonije;
  final String mestoCeremonije;
  final String datumCeremonije;
  final String vremeCeremonije;
  final List<NalogZaOpremanjePdfField> oprema;
  final List<NalogZaOpremanjePdfField> usluge;
}

class NalogZaOpremanjePdfField {
  const NalogZaOpremanjePdfField(
    this.label,
    this.value, {
    this.biohazard = false,
  });

  final String label;
  final String value;
  final bool biohazard;
}

class NalogZaOpremanjePdfDataBuilder {
  const NalogZaOpremanjePdfDataBuilder();

  NalogZaOpremanjePdfPreparedData build({
    required PredmetiData predmet,
    required List<IriuData> iriuStavke,
  }) {
    final truthSnapshot = const PredmetIriuTruthService().evaluate(
      predmet: predmet,
      storedRows: iriuStavke,
    );
    final allRowsByInternalName = <String, IriuTruthRow>{
      for (final row in truthSnapshot.rows) row.storedRow.interniNaziv: row,
    };
    final visibleRows = truthSnapshot.rowsVisibleToDerivative(
      excludedReasons: const <IriuDerivativeExclusion>{
        IriuDerivativeExclusion.notOperationallyActive,
        IriuDerivativeExclusion.documentScopedOut,
      },
    );
    final rowsByInternalName = <String, IriuTruthRow>{
      for (final row in visibleRows) row.storedRow.interniNaziv: row,
    };

    return NalogZaOpremanjePdfPreparedData(
      fullName: _joinNonEmpty([predmet.ime, predmet.prezime]),
      godinaRodjenja: _extractYear(predmet.datumRodjenja),
      godinaSmrti: _extractYear(predmet.datumSmrti),
      mestoSmrti: _displayValue(predmet.mestoSmrti),
      vrstaCeremonije: _vrstaCeremonijeLabel(predmet.vrstaCeremonije),
      mestoCeremonije: _resolveMestoCeremonije(predmet),
      datumCeremonije: _displayValue(predmet.datumCeremonije),
      vremeCeremonije: _displayValue(predmet.vremeCeremonije),
      oprema: <NalogZaOpremanjePdfField>[
        NalogZaOpremanjePdfField(
          'SANDUK',
          _equipmentValue(rowsByInternalName[IriuK.sanduk], IriuK.sanduk),
        ),
        NalogZaOpremanjePdfField(
          'POKROV GARNITURA',
          _equipmentValue(
            rowsByInternalName[IriuK.pokrovGarnitura],
            IriuK.pokrovGarnitura,
          ),
        ),
        NalogZaOpremanjePdfField(
          'OBELEŽJE',
          _equipmentValue(rowsByInternalName[IriuK.obelezje], IriuK.obelezje),
        ),
        NalogZaOpremanjePdfField(
          'PEŠKIR',
          _equipmentValue(
            rowsByInternalName[IriuK.peskirZaKrst],
            IriuK.peskirZaKrst,
          ),
        ),
      ],
      usluge: <NalogZaOpremanjePdfField>[
        NalogZaOpremanjePdfField(
          'Spremanje preminulog lica',
          _serviceValue(allRowsByInternalName[IriuK.spremaanjePokojnika]),
          biohazard:
              allRowsByInternalName[IriuK.spremaanjePokojnika]?.biohazard ??
              false,
        ),
        NalogZaOpremanjePdfField(
          'Limeni uložak',
          _serviceValue(allRowsByInternalName[IriuK.limeniUlozak]),
        ),
        NalogZaOpremanjePdfField(
          'Lemovanje',
          _serviceValue(allRowsByInternalName[IriuK.lemovanje]),
        ),
      ],
    );
  }
}

String _equipmentValue(IriuTruthRow? row, String fallbackInternalName) {
  if (row == null) return '—';
  final naziv = row.storedRow.nazivPrikaz.trim();
  if (naziv.isNotEmpty) return naziv;
  return IriuK.naziviPrikaz[fallbackInternalName] ?? '—';
}

String _serviceValue(IriuTruthRow? row) => row != null && row.active ? 'DA' : 'NE';

String _resolveMestoCeremonije(PredmetiData predmet) {
  final groblje = predmet.groblje.trim();
  if (groblje.isNotEmpty) return groblje;
  final opeloMesto = predmet.opeloMesto.trim();
  if (opeloMesto.isNotEmpty) return _opeloMestoLabel(opeloMesto);
  return '—';
}

String _joinNonEmpty(List<String> values) {
  final joined = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ');
  return joined.isEmpty ? '—' : joined;
}

String _extractYear(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '—';
  for (final separator in const <String>['.', '/', '-']) {
    final parts = trimmed.split(separator);
    if (parts.length == 3) {
      final candidates = separator == '-'
          ? <String>[parts[0], parts[2]]
          : <String>[parts[2]];
      for (final candidate in candidates) {
        final normalized = candidate.trim();
        if (normalized.length == 4 && int.tryParse(normalized) != null) {
          return normalized;
        }
      }
    }
  }
  if (trimmed.length == 4 && int.tryParse(trimmed) != null) {
    return trimmed;
  }
  return trimmed;
}

String _displayValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? '—' : trimmed;
}

String _vrstaCeremonijeLabel(String raw) {
  return switch (raw.trim()) {
    'SAHRANA' || 'SAHRANA_EKSPRES' => 'Sahrana',
    'KREMACIJA' || 'KREMACIJA_EKSPRES' => 'Kremacija',
    'SMESTAJ_URNE' => 'Smeštaj urne',
    'RASIPANJE_PEPELA' => 'Rasipanje pepela',
    _ => _displayValue(raw),
  };
}

String _opeloMestoLabel(String raw) {
  return switch (raw.trim().toUpperCase()) {
    'KAPELA NA GROBLJU' => 'Kapela na groblju',
    'CRKVA NA GROBLJU' => 'Crkva na groblju',
    'U PORODIČNOM DOMU' => 'U porodičnom domu',
    'KOD GROBNOG MESTA' => 'Kod grobnog mesta',
    _ => _displayValue(raw),
  };
}
