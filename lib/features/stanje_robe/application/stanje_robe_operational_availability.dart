import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../podesavanja/data/podesavanja_repository.dart';

enum StanjeRobeOperationalStatus {
  notLicensed,
  disabled,
  active,
}

extension StanjeRobeOperationalStatusX on StanjeRobeOperationalStatus {
  bool get isActive => this == StanjeRobeOperationalStatus.active;
}

class StanjeRobeOperationalAvailability {
  const StanjeRobeOperationalAvailability({
    required PodesavanjaRepository podesavanjaRepository,
    OpcEntitlementPolicy entitlementPolicy = const OpcEntitlementPolicy.current(),
  })  : _podesavanjaRepository = podesavanjaRepository,
        _entitlementPolicy = entitlementPolicy;

  final PodesavanjaRepository _podesavanjaRepository;
  final OpcEntitlementPolicy _entitlementPolicy;

  Future<StanjeRobeOperationalStatus> readStatus() async {
    if (!_entitlementPolicy.isModuleAvailable(OpcModule.stanjeRobe)) {
      return StanjeRobeOperationalStatus.notLicensed;
    }
    final enabled =
        await _podesavanjaRepository.isStanjeRobeOperativnoOmoguceno();
    return enabled
        ? StanjeRobeOperationalStatus.active
        : StanjeRobeOperationalStatus.disabled;
  }

  Stream<StanjeRobeOperationalStatus> watchStatus() {
    if (!_entitlementPolicy.isModuleAvailable(OpcModule.stanjeRobe)) {
      return Stream<StanjeRobeOperationalStatus>.value(
        StanjeRobeOperationalStatus.notLicensed,
      );
    }
    return _podesavanjaRepository.watchStanjeRobeOperativnoOmoguceno().map(
          (enabled) => enabled
              ? StanjeRobeOperationalStatus.active
              : StanjeRobeOperationalStatus.disabled,
        );
  }

  Future<bool> isActive() async => (await readStatus()).isActive;
}
