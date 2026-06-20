import '../../auth/data/auth_security_repository.dart';
import '../../auth/domain/session_service.dart';

enum SetupReadinessItem {
  recoverySecurityCode,
}

class SetupReadinessState {
  const SetupReadinessState({
    required this.missingItems,
  });

  const SetupReadinessState.ready() : missingItems = const [];

  final List<SetupReadinessItem> missingItems;

  bool get isReady => missingItems.isEmpty;

  bool isMissing(SetupReadinessItem item) => missingItems.contains(item);
}

class SetupReadinessService {
  const SetupReadinessService({
    required AuthSecurityRepository authSecurityRepository,
  }) : _authSecurityRepository = authSecurityRepository;

  final AuthSecurityRepository _authSecurityRepository;

  Future<SetupReadinessState> evaluateForSession(
    SessionService session,
  ) async {
    if (!session.jeAdmin) {
      return const SetupReadinessState.ready();
    }

    final hasRecoveryMaterial =
        await _authSecurityRepository.hasInstallationRecoveryMaterial();
    if (hasRecoveryMaterial) {
      return const SetupReadinessState.ready();
    }

    return const SetupReadinessState(
      missingItems: [SetupReadinessItem.recoverySecurityCode],
    );
  }
}
