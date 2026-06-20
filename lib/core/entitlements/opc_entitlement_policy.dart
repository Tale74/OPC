enum OpcPackageLevel {
  osnovni,
  srednji,
  potpun,
}

enum OpcEntitlementSourceKind {
  localLicense,
  saas,
  developerAllUnlocked,
  demoTest,
}

enum OpcEntitlementEnvironment {
  production,
  test,
  developer,
}

enum OpcAddOn {
  stanjeRobe,
  advancedParte,
  cituljeSaDeklaracijom,
  lkOcr,
}

enum OpcModule {
  predmetCore,
  katalog,
  usersRoles,
  businessPolicyScenario,
  statistika,
  operationalDocuments,
  jsonSinglePredmetTransfer,
  authRecovery,
  podsetnik,
  nalogCvecari,
  advancedParte,
  cituljeSaDeklaracijom,
  androidLkChipReading,
  windowsMupCelikIntegration,
  ocrIdPassport,
  stanjeRobe,
}

enum OpcSettingsSection {
  podaciFirme,
  refundacijaPio,
  katalog,
  moduli,
  korisnici,
  uputstvoZaPlacanje,
  oAplikaciji,
}

enum OpcDocumentAction {
  predmetPdfSnapshot,
  listaPdf,
  predracunPdf,
  specifikacijaTroskovaPdf,
  nalogZaOpremanjePdf,
  jsonTransfer,
  racunPdf,
}

final class OpcEntitlementPayload {
  const OpcEntitlementPayload({
    required this.schemaVersion,
    required this.sourceKind,
    required this.environment,
    required this.packageLevel,
    this.enabledAddOns = const <OpcAddOn>{},
    this.diagnosticsLabel = '',
  });

  static const int currentSchemaVersion = 1;

  static const safeProductionFallback = OpcEntitlementPayload(
    schemaVersion: currentSchemaVersion,
    sourceKind: OpcEntitlementSourceKind.localLicense,
    environment: OpcEntitlementEnvironment.production,
    packageLevel: OpcPackageLevel.osnovni,
    diagnosticsLabel: 'local_license_safe_fallback',
  );

  static const developerAllUnlocked = OpcEntitlementPayload(
    schemaVersion: currentSchemaVersion,
    sourceKind: OpcEntitlementSourceKind.developerAllUnlocked,
    environment: OpcEntitlementEnvironment.developer,
    packageLevel: OpcPackageLevel.potpun,
    enabledAddOns: <OpcAddOn>{
      OpcAddOn.stanjeRobe,
      OpcAddOn.advancedParte,
      OpcAddOn.cituljeSaDeklaracijom,
      OpcAddOn.lkOcr,
    },
    diagnosticsLabel: 'developer_all_unlocked',
  );

  final int schemaVersion;
  final OpcEntitlementSourceKind sourceKind;
  final OpcEntitlementEnvironment environment;
  final OpcPackageLevel packageLevel;
  final Set<OpcAddOn> enabledAddOns;
  final String diagnosticsLabel;

  bool get isSupportedSchema => schemaVersion == currentSchemaVersion;

  bool get isProductionUnsafe {
    return environment == OpcEntitlementEnvironment.production &&
        (sourceKind == OpcEntitlementSourceKind.developerAllUnlocked ||
            sourceKind == OpcEntitlementSourceKind.demoTest);
  }

  bool get isDeveloperAllUnlocked =>
      sourceKind == OpcEntitlementSourceKind.developerAllUnlocked &&
      environment != OpcEntitlementEnvironment.production;
}

abstract interface class OpcEntitlementSource {
  OpcEntitlementPayload loadPayload();
}

final class OpcLocalLicenseEntitlementSource implements OpcEntitlementSource {
  const OpcLocalLicenseEntitlementSource();

  @override
  OpcEntitlementPayload loadPayload() {
    return OpcEntitlementPayload.safeProductionFallback;
  }
}

final class OpcSaasEntitlementSource implements OpcEntitlementSource {
  const OpcSaasEntitlementSource();

  @override
  OpcEntitlementPayload loadPayload() {
    return OpcEntitlementPayload.safeProductionFallback;
  }
}

final class OpcDeveloperAllUnlockedEntitlementSource
    implements OpcEntitlementSource {
  const OpcDeveloperAllUnlockedEntitlementSource({
    this.environment = OpcEntitlementEnvironment.developer,
  });

  final OpcEntitlementEnvironment environment;

  @override
  OpcEntitlementPayload loadPayload() {
    if (environment == OpcEntitlementEnvironment.production) {
      return const OpcEntitlementPayload(
        schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
        sourceKind: OpcEntitlementSourceKind.developerAllUnlocked,
        environment: OpcEntitlementEnvironment.production,
        packageLevel: OpcPackageLevel.potpun,
        enabledAddOns: <OpcAddOn>{
          OpcAddOn.stanjeRobe,
          OpcAddOn.advancedParte,
          OpcAddOn.cituljeSaDeklaracijom,
          OpcAddOn.lkOcr,
        },
        diagnosticsLabel: 'blocked_production_developer_all_unlocked',
      );
    }
    return OpcEntitlementPayload.developerAllUnlocked;
  }
}

final class OpcDemoTestEntitlementSource implements OpcEntitlementSource {
  const OpcDemoTestEntitlementSource({
    required this.packageLevel,
    this.enabledAddOns = const <OpcAddOn>{},
    this.environment = OpcEntitlementEnvironment.test,
    this.diagnosticsLabel = 'demo_test_simulated_entitlement',
  });

  final OpcPackageLevel packageLevel;
  final Set<OpcAddOn> enabledAddOns;
  final OpcEntitlementEnvironment environment;
  final String diagnosticsLabel;

  @override
  OpcEntitlementPayload loadPayload() {
    return OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.demoTest,
      environment: environment,
      packageLevel: packageLevel,
      enabledAddOns: enabledAddOns,
      diagnosticsLabel: diagnosticsLabel,
    );
  }
}

final class OpcSelectedEntitlementSource implements OpcEntitlementSource {
  const OpcSelectedEntitlementSource();

  static const _requestedSource = String.fromEnvironment(
    'OPC_ENTITLEMENT_SOURCE',
    defaultValue: '',
  );
  static const _requestedEnvironment = String.fromEnvironment(
    'OPC_ENTITLEMENT_ENVIRONMENT',
    defaultValue: '',
  );
  static const _requestedDemoPackage = String.fromEnvironment(
    'OPC_ENTITLEMENT_DEMO_PACKAGE',
    defaultValue: '',
  );
  static const _requestedDemoAddOns = String.fromEnvironment(
    'OPC_ENTITLEMENT_DEMO_ADDONS',
    defaultValue: '',
  );
  static const _developerAllUnlockedRequested = bool.fromEnvironment(
    'OPC_DEVELOPER_ALL_UNLOCKED',
    defaultValue: false,
  );

  @override
  OpcEntitlementPayload loadPayload() {
    final environment = _environmentFromValue(_requestedEnvironment);
    final source = _normalized(_requestedSource);

    if (_developerAllUnlockedRequested || source == 'developerallunlocked') {
      return OpcDeveloperAllUnlockedEntitlementSource(
        environment: environment,
      ).loadPayload();
    }

    if (source == 'demotest') {
      return OpcDemoTestEntitlementSource(
        packageLevel: _packageLevelFromValue(_requestedDemoPackage),
        enabledAddOns: _addOnsFromValue(_requestedDemoAddOns),
        environment: environment,
      ).loadPayload();
    }

    if (source == 'saas') {
      return const OpcSaasEntitlementSource().loadPayload();
    }

    if (source.isEmpty || source == 'locallicense') {
      return const OpcLocalLicenseEntitlementSource().loadPayload();
    }

    return const OpcEntitlementPayload(
      schemaVersion: OpcEntitlementPayload.currentSchemaVersion,
      sourceKind: OpcEntitlementSourceKind.localLicense,
      environment: OpcEntitlementEnvironment.production,
      packageLevel: OpcPackageLevel.osnovni,
      diagnosticsLabel: 'unknown_source_safe_fallback',
    );
  }

  static OpcEntitlementEnvironment _environmentFromValue(String value) {
    return switch (_normalized(value)) {
      'developer' => OpcEntitlementEnvironment.developer,
      'test' || 'demo' || 'demotest' => OpcEntitlementEnvironment.test,
      _ => OpcEntitlementEnvironment.production,
    };
  }

  static OpcPackageLevel _packageLevelFromValue(String value) {
    return switch (_normalized(value)) {
      'srednji' => OpcPackageLevel.srednji,
      'potpun' => OpcPackageLevel.potpun,
      _ => OpcPackageLevel.osnovni,
    };
  }

  static Set<OpcAddOn> _addOnsFromValue(String value) {
    if (value.trim().isEmpty) return const <OpcAddOn>{};

    final addOns = <OpcAddOn>{};
    for (final token in value.split(RegExp(r'[,; ]+'))) {
      switch (_normalized(token)) {
        case 'stanjerobe':
          addOns.add(OpcAddOn.stanjeRobe);
        case 'advancedparte':
          addOns.add(OpcAddOn.advancedParte);
        case 'cituljesadeklaracijom':
          addOns.add(OpcAddOn.cituljeSaDeklaracijom);
        case 'lkocr':
          addOns.add(OpcAddOn.lkOcr);
      }
    }
    return addOns;
  }

  static String _normalized(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '');
  }
}

final class OpcEntitlementDiagnostics {
  const OpcEntitlementDiagnostics({
    required this.sourceKind,
    required this.environment,
    required this.packageLevel,
    required this.enabledAddOns,
    required this.safeLabel,
    required this.isFailClosed,
    this.failClosedReason,
  });

  final OpcEntitlementSourceKind sourceKind;
  final OpcEntitlementEnvironment environment;
  final OpcPackageLevel packageLevel;
  final List<OpcAddOn> enabledAddOns;
  final String safeLabel;
  final bool isFailClosed;
  final String? failClosedReason;

  factory OpcEntitlementDiagnostics._fromEvaluation(
    _OpcEntitlementEvaluation evaluation,
  ) {
    final rawPayload = evaluation.rawPayload;
    final effectivePayload = evaluation.effectivePayload;
    return OpcEntitlementDiagnostics(
      sourceKind: rawPayload.sourceKind,
      environment: rawPayload.environment,
      packageLevel: effectivePayload.packageLevel,
      enabledAddOns: List<OpcAddOn>.unmodifiable(
        effectivePayload.enabledAddOns,
      ),
      safeLabel: rawPayload.diagnosticsLabel,
      isFailClosed: evaluation.isFailClosed,
      failClosedReason: evaluation.failClosedReason,
    );
  }

  Map<String, Object?> toSafeMap() {
    return <String, Object?>{
      'sourceKind': sourceKind.name,
      'environment': environment.name,
      'packageLevel': packageLevel.name,
      'enabledAddOns': enabledAddOns.map((addOn) => addOn.name).toList(),
      'safeLabel': safeLabel,
      'isFailClosed': isFailClosed,
      'failClosedReason': failClosedReason,
    };
  }
}

final class OpcEntitlementPolicy {
  const OpcEntitlementPolicy._(this._source);

  const OpcEntitlementPolicy.current()
      : this._(const OpcSelectedEntitlementSource());

  const OpcEntitlementPolicy.fromSource(OpcEntitlementSource source)
      : this._(source);

  OpcEntitlementPolicy.fromPayload(OpcEntitlementPayload payload)
      : this._(_StaticOpcEntitlementSource(payload));

  final OpcEntitlementSource _source;

  _OpcEntitlementEvaluation get _evaluation {
    final rawPayload = _source.loadPayload();
    if (!rawPayload.isSupportedSchema) {
      return _OpcEntitlementEvaluation.failClosed(
        rawPayload,
        'unsupported_schema',
      );
    }
    if (rawPayload.isProductionUnsafe) {
      return _OpcEntitlementEvaluation.failClosed(
        rawPayload,
        'production_unsafe_source',
      );
    }
    return _OpcEntitlementEvaluation.allowed(rawPayload);
  }

  OpcEntitlementPayload get payload => _evaluation.effectivePayload;

  OpcEntitlementDiagnostics get diagnostics =>
      OpcEntitlementDiagnostics._fromEvaluation(_evaluation);

  OpcPackageLevel get packageLevel => payload.packageLevel;

  OpcEntitlementSourceKind get sourceKind => payload.sourceKind;

  OpcEntitlementEnvironment get environment => payload.environment;

  Set<OpcAddOn> get enabledAddOns => payload.enabledAddOns;

  bool get isDeveloperAllUnlocked => payload.isDeveloperAllUnlocked;

  static const List<OpcSettingsSection> currentSettingsSections = [
    OpcSettingsSection.podaciFirme,
    OpcSettingsSection.refundacijaPio,
    OpcSettingsSection.katalog,
    OpcSettingsSection.moduli,
    OpcSettingsSection.korisnici,
    OpcSettingsSection.uputstvoZaPlacanje,
    OpcSettingsSection.oAplikaciji,
  ];

  bool isAddOnEnabled(OpcAddOn addOn) {
    return isDeveloperAllUnlocked || enabledAddOns.contains(addOn);
  }

  bool _isSrednjiOrPotpun() {
    return packageLevel != OpcPackageLevel.osnovni;
  }

  bool _isPotpunOrSrednjiAddOn(OpcAddOn addOn) {
    return packageLevel == OpcPackageLevel.potpun ||
        (packageLevel == OpcPackageLevel.srednji && isAddOnEnabled(addOn));
  }

  bool isModuleAvailable(OpcModule module) {
    if (isDeveloperAllUnlocked) return true;

    return switch (module) {
      OpcModule.predmetCore ||
      OpcModule.katalog ||
      OpcModule.usersRoles ||
      OpcModule.businessPolicyScenario ||
      OpcModule.statistika ||
      OpcModule.operationalDocuments ||
      OpcModule.jsonSinglePredmetTransfer ||
      OpcModule.authRecovery => true,
      OpcModule.podsetnik || OpcModule.nalogCvecari =>
        _isSrednjiOrPotpun(),
      OpcModule.advancedParte =>
        _isPotpunOrSrednjiAddOn(OpcAddOn.advancedParte),
      OpcModule.cituljeSaDeklaracijom =>
        _isPotpunOrSrednjiAddOn(OpcAddOn.cituljeSaDeklaracijom),
      OpcModule.androidLkChipReading ||
      OpcModule.windowsMupCelikIntegration ||
      OpcModule.ocrIdPassport =>
        _isPotpunOrSrednjiAddOn(OpcAddOn.lkOcr),
      OpcModule.stanjeRobe =>
        _isPotpunOrSrednjiAddOn(OpcAddOn.stanjeRobe),
    };
  }

  bool isSettingsSectionVisible(OpcSettingsSection section) {
    return switch (section) {
      OpcSettingsSection.podaciFirme ||
      OpcSettingsSection.refundacijaPio ||
      OpcSettingsSection.katalog ||
      OpcSettingsSection.korisnici ||
      OpcSettingsSection.uputstvoZaPlacanje ||
      OpcSettingsSection.oAplikaciji => true,
      OpcSettingsSection.moduli => isModuleAvailable(OpcModule.stanjeRobe),
    };
  }

  bool isDocumentActionVisible(OpcDocumentAction action) {
    return switch (action) {
      OpcDocumentAction.predmetPdfSnapshot ||
      OpcDocumentAction.listaPdf ||
      OpcDocumentAction.predracunPdf ||
      OpcDocumentAction.specifikacijaTroskovaPdf ||
      OpcDocumentAction.nalogZaOpremanjePdf =>
        isModuleAvailable(OpcModule.operationalDocuments),
      OpcDocumentAction.jsonTransfer =>
        isModuleAvailable(OpcModule.jsonSinglePredmetTransfer),
      OpcDocumentAction.racunPdf =>
        isModuleAvailable(OpcModule.operationalDocuments),
    };
  }

  bool get hasVisibleSettingsSections =>
      currentSettingsSections.any(isSettingsSectionVisible);
}

final class _OpcEntitlementEvaluation {
  const _OpcEntitlementEvaluation({
    required this.rawPayload,
    required this.effectivePayload,
    required this.failClosedReason,
  });

  factory _OpcEntitlementEvaluation.allowed(OpcEntitlementPayload payload) {
    return _OpcEntitlementEvaluation(
      rawPayload: payload,
      effectivePayload: payload,
      failClosedReason: null,
    );
  }

  factory _OpcEntitlementEvaluation.failClosed(
    OpcEntitlementPayload rawPayload,
    String reason,
  ) {
    return _OpcEntitlementEvaluation(
      rawPayload: rawPayload,
      effectivePayload: OpcEntitlementPayload.safeProductionFallback,
      failClosedReason: reason,
    );
  }

  final OpcEntitlementPayload rawPayload;
  final OpcEntitlementPayload effectivePayload;
  final String? failClosedReason;

  bool get isFailClosed => failClosedReason != null;
}

final class _StaticOpcEntitlementSource implements OpcEntitlementSource {
  const _StaticOpcEntitlementSource(this._payload);

  final OpcEntitlementPayload _payload;

  @override
  OpcEntitlementPayload loadPayload() => _payload;
}
