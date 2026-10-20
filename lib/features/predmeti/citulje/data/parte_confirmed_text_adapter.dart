import '../../parte/application/parte_preparation_service.dart';
import '../../parte/data/parte_preparation_repository.dart';
import '../domain/citulje_models.dart';

/// Reads the same confirmed render plan used by the PARTE preview/PDF path.
/// No rendered document, PDF or image is parsed.
class ParteConfirmedTextAdapter {
  const ParteConfirmedTextAdapter({
    required this.repository,
    required this.service,
  });

  final PartePreparationRepository repository;
  final PartePreparationService service;

  Future<ParteConfirmedPlainText?> readForPredmet(int predmetId) async {
    final preparation = await repository.findForPredmet(predmetId);
    if (preparation == null) return null;
    final plan = await service.buildPlan(preparation: preparation);
    if (preparation.previewConfirmedFingerprint != plan.fingerprint ||
        !plan.canConfirmPreview) {
      return null;
    }
    final text = cituljeConfirmedPlainTextFromPlan(plan.blocks);
    if (text.trim().isEmpty) return null;
    return ParteConfirmedPlainText(
      text: text,
      sourceFingerprint: plan.fingerprint,
    );
  }
}
