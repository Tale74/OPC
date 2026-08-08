import '../../../../core/constants/iriu_constants.dart';
import '../../../../core/database/database.dart';
import 'scenario_contract.dart';

/// The owner-controlled policy kernel for the complete SCENARIO map.
///
/// The map is deliberately represented as a finite, generated state space
/// rather than as a hand-maintained list of loosely matching rules.  The
/// generator produces the 864 standard combinations and 144 reception
/// combinations (1,008 total), in the same stable order as the owner map.
/// `MESTO SMRTI` is informational for reception-of-remains combinations.
final class OwnerScenarioPolicyKernel {
  const OwnerScenarioPolicyKernel();

  static const List<String> causes = <String>[
    'PRIRODNA',
    'NASILNA',
    'ZARAZNA',
    'NEDEFINISANA',
  ];

  static const List<String> places = <String>[
    'STAN',
    'DOM ZA STARE',
    'BOLNICA',
    'PRIVATNA BOLNICA',
    'ULICA / JAVNO MESTO',
    'DRUGO',
  ];

  static const List<String> ceremonies = <String>[
    'SAHRANA',
    'SAHRANA EKSPRES',
    'KREMACIJA',
    'KREMACIJA EKSPRES',
  ];

  static const List<String> _cemeteryTypes = <String>['GRADSKO', 'LOKALNO'];
  static const List<String> _burialPlaces = <String>['GROB', 'GROBNICA'];

  /// The owner map's first layer.  It intentionally includes both ČITULJE
  /// categories and SLIKA; KATALOG supplies their display names/articles.
  static const List<String> osnovniPaket = <String>[
    IriuK.sanduk,
    IriuK.obelezje,
    IriuK.pokrovGarnitura,
    IriuK.peskirZaKrst,
    IriuK.posmrtneParte,
    IriuK.crnina,
    IriuK.cvece,
    IriuK.cituljaP,
    IriuK.cituljaNo,
    IriuK.slika,
    IriuK.agencijskeUsluge,
  ];

  /// Generates the exact owner-map cardinality without reading a mutable DB.
  List<OwnerScenarioKey> allKeys() {
    final keys = <OwnerScenarioKey>[];
    for (final cause in causes) {
      for (final place in places) {
        keys.addAll(_keysFor(cause: cause, place: place, docek: false));
      }
      keys.addAll(_keysFor(cause: cause, place: null, docek: true));
    }
    return List<OwnerScenarioKey>.unmodifiable(keys);
  }

  OwnerScenarioResult evaluate(PredmetiData predmet) {
    final input = OwnerScenarioInput.fromPredmet(predmet);
    return evaluateInput(input);
  }

  OwnerScenarioResult evaluateInput(OwnerScenarioInput input) {
    if (!input.isComplete) return OwnerScenarioResult.incomplete(input);
    final key = input.key;
    final consequences = _consequences(input);
    final baseActions = <String, ScenarioConsequenceAction>{
      for (final category in osnovniPaket)
        category: input.docek
            ? ScenarioConsequenceAction.recommended
            : ScenarioConsequenceAction.required,
    };
    if (input.docek && input.promenaSanduka) {
      baseActions[IriuK.sanduk] = ScenarioConsequenceAction.required;
    }
    return OwnerScenarioResult(
      input: input,
      key: key,
      scenarioId: key.stableId,
      baseCategories: Set<String>.unmodifiable(osnovniPaket),
      baseActions: Map<String, ScenarioConsequenceAction>.unmodifiable(
        baseActions,
      ),
      consequences: List<ScenarioConsequence>.unmodifiable(consequences),
    );
  }

  /// Creates the persisted, editable definition for one owner-map key.
  /// The definition is generated only for seeding missing records; runtime
  /// reads the stored definition so a conscious editor change is authoritative.
  ScenarioDefinition definitionForKey(OwnerScenarioKey key) {
    final result = evaluateInput(
      OwnerScenarioInput(
        uzrokSmrti: key.cause,
        mestoSmrti: key.place ?? places.first,
        vrstaCeremonije: key.ceremony,
        tipGroblja: key.cemeteryType,
        tipGrobnogMesta: key.burialPlace,
        opelo: key.opelo,
        sahranaVanSrbije: key.international,
        docek: key.docek,
        promenaSanduka: false,
      ),
    );
    final criteria = <ScenarioCondition>[
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.uzrokSmrti,
          operator: ScenarioCriterionOperator.equals,
          values: [key.cause],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.vrstaCeremonije,
          operator: ScenarioCriterionOperator.equals,
          values: [key.ceremony],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.opelo,
          operator: ScenarioCriterionOperator.equals,
          values: [key.opelo],
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.sahranaVanSrbije,
          operator: key.international
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
      ScenarioCondition.criterion(
        ScenarioCriterion(
          field: ScenarioCriterionField.docekPosmrtnihOstataka,
          operator: key.docek
              ? ScenarioCriterionOperator.isTrue
              : ScenarioCriterionOperator.isFalse,
        ),
      ),
    ];
    if (!key.docek) {
      criteria.add(
        ScenarioCondition.criterion(
          ScenarioCriterion(
            field: ScenarioCriterionField.mestoSmrti,
            operator: ScenarioCriterionOperator.equals,
            values: [key.place!],
          ),
        ),
      );
      if (!key.ceremony.startsWith('KREMACIJA')) {
        criteria
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGroblja,
                operator: ScenarioCriterionOperator.equals,
                values: [key.cemeteryType],
              ),
            ),
          )
          ..add(
            ScenarioCondition.criterion(
              ScenarioCriterion(
                field: ScenarioCriterionField.tipGrobnogMesta,
                operator: ScenarioCriterionOperator.equals,
                values: [key.burialPlace],
              ),
            ),
          );
      }
    }
    return ScenarioDefinition(
      id: key.stableId,
      name: 'SCENARIO ${key.stableId}',
      condition: ScenarioCondition.all(criteria),
      consequences: result.consequences,
      description: 'Owner map definition ${key.stableId}.',
    );
  }

  List<ScenarioConsequence> _consequences(OwnerScenarioInput input) {
    final rows = <ScenarioConsequence>[];
    var order = 10;
    void add(
      String category, {
      ScenarioConsequenceAction action = ScenarioConsequenceAction.required,
      String warning = '',
      String reason = '',
    }) {
      rows.add(
        ScenarioConsequence(
          katalogCategoryInternalName: category,
          action: action,
          order: order,
          section: 2,
          warning: warning,
          reason: reason,
        ),
      );
      order += 10;
    }

    final isHospital = input.mestoSmrti == 'BOLNICA';
    final requiresProtectiveEquipment = input.uzrokSmrti != 'PRIRODNA';
    final biohazard =
        input.uzrokSmrti == 'ZARAZNA' || input.uzrokSmrti == 'NEDEFINISANA';
    final warning = biohazard
        ? 'Postupati prema merama zaštite za zaraznu bolest.'
        : '';

    if (input.docek) {
      add(IriuK.cargoTroskovi);
      add(
        IriuK.iznosenje,
        warning: biohazard ? warning : '',
        reason: biohazard ? 'BIOHAZARD' : '',
      );
      if (requiresProtectiveEquipment) {
        add(IriuK.zastitnaIDodatnaOprema);
      }
      add(IriuK.prevozDoHladnjace);
      add(IriuK.hladnjaca);
      _addBurialAndInternational(rows, input, add);
      if (input.promenaSanduka) {
        add(
          IriuK.spremaanjePokojnika,
          action: ScenarioConsequenceAction.recommended,
          warning: biohazard ? warning : '',
          reason: biohazard ? 'BIOHAZARD' : '',
        );
      }
      if (input.opelo == 'DA') add(IriuK.kompletZaOpelo);
      return rows;
    }

    if (!isHospital) {
      add(IriuK.transportnaVreca);
      add(
        IriuK.iznosenje,
        warning: biohazard ? warning : '',
        reason: biohazard ? 'BIOHAZARD' : '',
      );
      if (requiresProtectiveEquipment) {
        add(IriuK.zastitnaIDodatnaOprema);
      }
      add(IriuK.prevozDoHladnjace);
      add(IriuK.hladnjaca);
      add(
        IriuK.spremaanjePokojnika,
        warning: biohazard ? warning : '',
        reason: biohazard ? 'BIOHAZARD' : '',
      );
    }
    _addBurialAndInternational(rows, input, add);
    if (input.opelo == 'DA') add(IriuK.kompletZaOpelo);
    return rows;
  }

  void _addBurialAndInternational(
    List<ScenarioConsequence> rows,
    OwnerScenarioInput input,
    void Function(
      String, {
      ScenarioConsequenceAction action,
      String warning,
      String reason,
    })
    add,
  ) {
    final isKremacija = input.isKremacija;
    final isBiohazardCause =
        input.uzrokSmrti == 'ZARAZNA' || input.uzrokSmrti == 'NEDEFINISANA';
    final needsMetalInsert = !isKremacija &&
        ((isBiohazardCause && !input.docek) ||
            (!input.sahranaVanSrbije &&
                input.tipGrobnogMesta == 'GROBNICA') ||
            (!input.docek && input.sahranaVanSrbije));
    final localInternationalGrob =
        input.tipGroblja == 'LOKALNO' &&
        input.sahranaVanSrbije &&
        input.tipGrobnogMesta == 'GROB' &&
        !isBiohazardCause;
    var localTransportAdded = false;
    if (localInternationalGrob) {
      add(IriuK.prevozSprovoda, action: ScenarioConsequenceAction.recommended);
      localTransportAdded = true;
    }
    if (needsMetalInsert) {
      final action = input.sahranaVanSrbije
          ? ScenarioConsequenceAction.required
          : input.tipGrobnogMesta == 'GROBNICA'
              ? (input.tipGroblja == 'LOKALNO'
                    ? ScenarioConsequenceAction.recommended
                    : ScenarioConsequenceAction.required)
              : input.mestoSmrti == 'BOLNICA'
                  ? ScenarioConsequenceAction.required
                  : ScenarioConsequenceAction.recommended;
      add(IriuK.limeniUlozak, action: action);
      if (input.mestoSmrti != 'BOLNICA') {
        add(IriuK.lemovanje, action: action);
      }
    }
    if (!isKremacija && input.tipGroblja == 'LOKALNO' && !localTransportAdded) {
      add(IriuK.prevozSprovoda, action: ScenarioConsequenceAction.recommended);
    }
    if (input.sahranaVanSrbije) {
      add(IriuK.medjunarodniPrevoz);
      add(IriuK.medjunarodnaDocumentacija);
      add(IriuK.balsamovanje, action: ScenarioConsequenceAction.recommended);
    } else {
      // Cremation still has a cemetery transport consequence.  The
      // prohibition is only the international cremation combination, which
      // is excluded from the owner-map key generator above.
      add(IriuK.prevozDoGroblja);
    }
  }

  List<OwnerScenarioKey> _keysFor({
    required String cause,
    required String? place,
    required bool docek,
  }) {
    final keys = <OwnerScenarioKey>[];
    for (final ceremony in ceremonies) {
      final isKremacija = ceremony.startsWith('KREMACIJA');
      final tipovi = isKremacija
          ? const <String>['NE PRIMENJUJE SE']
          : _cemeteryTypes;
      final grobna = isKremacija
          ? const <String>['NE PRIMENJUJE SE']
          : _burialPlaces;
      final international = isKremacija
          ? const <bool>[false]
          : const <bool>[true, false];
      for (final tip in tipovi) {
        for (final grob in grobna) {
          for (final opelo in const <String>['DA', 'NE']) {
            for (final intl in international) {
              keys.add(
                OwnerScenarioKey(
                  cause: cause,
                  place: place,
                  ceremony: ceremony,
                  cemeteryType: tip,
                  burialPlace: grob,
                  opelo: opelo,
                  international: intl,
                  docek: docek,
                ),
              );
            }
          }
        }
      }
    }
    return keys;
  }

  /// Truth evaluation for already stored rows also has to work while a
  /// PREDMET is incomplete. In that state no scenario is materialized, but
  /// condition-managed legacy/manual rows still follow the same owner policy
  /// conditions; unrelated manual rows remain operationally active.
  bool isOperationallyActiveForTruth({
    required PredmetiData predmet,
    required String internalName,
  }) {
    final result = evaluate(predmet);
    if (result.isComplete) {
      return result.effectiveCategories.contains(internalName);
    }
    final mesto = normalizeMestoSmrti(predmet.mestoSmrti);
    switch (internalName) {
      case IriuK.hladnjaca:
      case IriuK.spremaanjePokojnika:
      case IriuK.iznosenje:
      case IriuK.prevozDoHladnjace:
      case IriuK.transportnaVreca:
        return mesto.isNotEmpty && mesto != 'BOLNICA';
      case IriuK.prevozDoGroblja:
        return mesto.isNotEmpty;
      case IriuK.limeniUlozak:
      case IriuK.lemovanje:
        return predmet.tipGrobnogMesta.trim().toUpperCase() == 'GROBNICA';
      case IriuK.prevozSprovoda:
        return predmet.tipGroblja.trim().toUpperCase() == 'LOKALNO';
      case IriuK.medjunarodniPrevoz:
      case IriuK.medjunarodnaDocumentacija:
      case IriuK.balsamovanje:
        return predmet.sahranaVanSrbije;
      case IriuK.cargoTroskovi:
        return predmet.docekPosmrtnihOstataka;
      case IriuK.kompletZaOpelo:
        return predmet.opelo.trim().toUpperCase() == 'DA';
      default:
        return true;
    }
  }

  List<String> autoManagedMestoSmrtiForTruth(PredmetiData predmet) {
    final result = evaluate(predmet);
    if (result.isComplete) {
      return List<String>.unmodifiable(
        result.consequences
            .map((item) => item.katalogCategoryInternalName)
            .where(
              (name) =>
                  name == IriuK.hladnjaca ||
                  name == IriuK.spremaanjePokojnika ||
                  name == IriuK.iznosenje ||
                  name == IriuK.prevozDoHladnjace ||
                  name == IriuK.transportnaVreca ||
                  name == IriuK.prevozDoGroblja,
            ),
      );
    }
    final mesto = normalizeMestoSmrti(predmet.mestoSmrti);
    if (mesto == 'BOLNICA') return const <String>[IriuK.prevozDoGroblja];
    if (mesto.isEmpty) return const <String>[];
    return const <String>[
      IriuK.hladnjaca,
      IriuK.spremaanjePokojnika,
      IriuK.iznosenje,
      IriuK.prevozDoHladnjace,
      IriuK.transportnaVreca,
      IriuK.prevozDoGroblja,
    ];
  }

  List<String> autoManagedBlok2ForTruth(PredmetiData predmet) {
    final result = evaluate(predmet);
    if (result.isComplete) {
      return List<String>.unmodifiable(
        result.consequences
            .map((item) => item.katalogCategoryInternalName)
            .where(
              (name) =>
                  name == IriuK.limeniUlozak ||
                  name == IriuK.lemovanje ||
                  name == IriuK.prevozSprovoda,
            ),
      );
    }
    final resultRows = <String>[];
    if (predmet.tipGrobnogMesta.trim().toUpperCase() == 'GROBNICA') {
      resultRows
        ..add(IriuK.limeniUlozak)
        ..add(IriuK.lemovanje);
    }
    if (predmet.tipGroblja.trim().toUpperCase() == 'LOKALNO') {
      resultRows.add(IriuK.prevozSprovoda);
    }
    return List<String>.unmodifiable(resultRows);
  }
}

final class OwnerScenarioInput {
  const OwnerScenarioInput({
    required this.uzrokSmrti,
    required this.mestoSmrti,
    required this.vrstaCeremonije,
    required this.tipGroblja,
    required this.tipGrobnogMesta,
    required this.opelo,
    required this.sahranaVanSrbije,
    required this.docek,
    required this.promenaSanduka,
  });

  factory OwnerScenarioInput.fromPredmet(PredmetiData predmet) {
    final ceremony = _normalize(predmet.vrstaCeremonije);
    final cremation = ceremony.startsWith('KREMACIJA');
    return OwnerScenarioInput(
      uzrokSmrti: _normalize(predmet.uzrokSmrti),
      mestoSmrti: normalizeMestoSmrti(predmet.mestoSmrti),
      vrstaCeremonije: ceremony,
      tipGroblja: cremation
          ? 'NE PRIMENJUJE SE'
          : _normalize(predmet.tipGroblja),
      tipGrobnogMesta: cremation
          ? 'NE PRIMENJUJE SE'
          : _normalize(predmet.tipGrobnogMesta),
      opelo: _normalize(predmet.opelo),
      sahranaVanSrbije: predmet.sahranaVanSrbije,
      docek: predmet.docekPosmrtnihOstataka,
      promenaSanduka: predmet.promenaSanduka,
    );
  }

  final String uzrokSmrti;
  final String mestoSmrti;
  final String vrstaCeremonije;
  final String tipGroblja;
  final String tipGrobnogMesta;
  final String opelo;
  final bool sahranaVanSrbije;
  final bool docek;
  final bool promenaSanduka;

  bool get isKremacija => vrstaCeremonije.startsWith('KREMACIJA');

  bool get isComplete {
    if (!OwnerScenarioPolicyKernel.causes.contains(uzrokSmrti) ||
        !OwnerScenarioPolicyKernel.ceremonies.contains(vrstaCeremonije) ||
        !<String>{'DA', 'NE'}.contains(opelo)) {
      return false;
    }
    if (docek) {
      if (sahranaVanSrbije && isKremacija) return false;
      return isKremacija || (_isKnownCemetery && _isKnownBurialPlace);
    }
    if (!OwnerScenarioPolicyKernel.places.contains(mestoSmrti)) return false;
    if (isKremacija) {
      return !sahranaVanSrbije;
    }
    return _isKnownCemetery && _isKnownBurialPlace;
  }

  bool get _isKnownCemetery =>
      <String>{'GRADSKO', 'LOKALNO'}.contains(tipGroblja);

  bool get _isKnownBurialPlace =>
      <String>{'GROB', 'GROBNICA'}.contains(tipGrobnogMesta);

  OwnerScenarioKey get key => OwnerScenarioKey(
    cause: uzrokSmrti,
    place: docek ? null : mestoSmrti,
    ceremony: vrstaCeremonije,
    cemeteryType: tipGroblja,
    burialPlace: tipGrobnogMesta,
    opelo: opelo,
    international: sahranaVanSrbije,
    docek: docek,
  );
}

final class OwnerScenarioKey {
  const OwnerScenarioKey({
    required this.cause,
    required this.place,
    required this.ceremony,
    required this.cemeteryType,
    required this.burialPlace,
    required this.opelo,
    required this.international,
    required this.docek,
  });

  final String cause;
  final String? place;
  final String ceremony;
  final String cemeteryType;
  final String burialPlace;
  final String opelo;
  final bool international;
  final bool docek;

  String get businessSummary => <String>[
    cause,
    place ?? 'MESTO SMRTI INFORMATIVNO',
    ceremony,
    cemeteryType,
    burialPlace,
    'OPELO $opelo',
    'VAN SRBIJE ${international ? 'DA' : 'NE'}',
    'DOÄŒEK ${docek ? 'DA' : 'NE'}',
  ].join(' Â· ');

  String get stableId {
    final fields = <String>[
      cause,
      place ?? 'INFORMATIVNO',
      ceremony,
      cemeteryType,
      burialPlace,
      opelo,
      international ? 'DA' : 'NE',
      docek ? 'DA' : 'NE',
    ];
    return 'MAP_${fields.map(_slug).join('_')}';
  }

  @override
  bool operator ==(Object other) =>
      other is OwnerScenarioKey &&
      other.cause == cause &&
      other.place == place &&
      other.ceremony == ceremony &&
      other.cemeteryType == cemeteryType &&
      other.burialPlace == burialPlace &&
      other.opelo == opelo &&
      other.international == international &&
      other.docek == docek;

  @override
  int get hashCode => Object.hash(
    cause,
    place,
    ceremony,
    cemeteryType,
    burialPlace,
    opelo,
    international,
    docek,
  );
}

final class OwnerScenarioResult {
  const OwnerScenarioResult({
    required this.input,
    required this.key,
    required this.scenarioId,
    required this.baseCategories,
    required this.baseActions,
    required this.consequences,
  });

  const OwnerScenarioResult.incomplete(this.input)
    : key = null,
      scenarioId = null,
      baseCategories = const <String>{
        IriuK.sanduk,
        IriuK.obelezje,
        IriuK.pokrovGarnitura,
        IriuK.peskirZaKrst,
        IriuK.posmrtneParte,
        IriuK.crnina,
        IriuK.cvece,
        IriuK.cituljaP,
        IriuK.cituljaNo,
        IriuK.slika,
        IriuK.agencijskeUsluge,
      },
      baseActions = const <String, ScenarioConsequenceAction>{
        IriuK.sanduk: ScenarioConsequenceAction.required,
        IriuK.obelezje: ScenarioConsequenceAction.required,
        IriuK.pokrovGarnitura: ScenarioConsequenceAction.required,
        IriuK.peskirZaKrst: ScenarioConsequenceAction.required,
        IriuK.posmrtneParte: ScenarioConsequenceAction.required,
        IriuK.crnina: ScenarioConsequenceAction.required,
        IriuK.cvece: ScenarioConsequenceAction.required,
        IriuK.cituljaP: ScenarioConsequenceAction.required,
        IriuK.cituljaNo: ScenarioConsequenceAction.required,
        IriuK.slika: ScenarioConsequenceAction.required,
        IriuK.agencijskeUsluge: ScenarioConsequenceAction.required,
      },
      consequences = const <ScenarioConsequence>[];

  final OwnerScenarioInput input;
  final OwnerScenarioKey? key;
  final String? scenarioId;
  final Set<String> baseCategories;
  final Map<String, ScenarioConsequenceAction> baseActions;
  final List<ScenarioConsequence> consequences;

  bool get isComplete => key != null;

  Set<String> get effectiveCategories => {
    ...baseCategories,
    for (final consequence in consequences)
      if (consequence.action != ScenarioConsequenceAction.suppressed)
        consequence.katalogCategoryInternalName,
  };
}

String normalizeMestoSmrti(String value) {
  final normalized = _normalize(value);
  if (normalized == 'ULICA' || normalized == 'JAVNO MESTO') {
    return 'ULICA / JAVNO MESTO';
  }
  return normalized;
}

String _normalize(String value) => value.trim().toUpperCase();

String _slug(String value) => value
    .trim()
    .toUpperCase()
    .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');
