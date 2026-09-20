import 'package:flutter/material.dart';

import '../../../core/entitlements/opc_entitlement_policy.dart';
import '../../auth/domain/session_service.dart';
import '../application/predmet_hard_delete_coordinator.dart';
import '../data/predmeti_repository.dart';
import '../reminders/ceremony_notification_gateway.dart';
import '../reminders/podsetnik_eligibility.dart';

enum PredmetOverflowAction {
  close,
  edit,
  finish,
  documents,
  reminder,
  exportJson,
  anonymize,
  delete,
}

class PredmetOverflowActionDefinition {
  const PredmetOverflowActionDefinition({
    required this.action,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.destructive = false,
  });

  final PredmetOverflowAction action;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool destructive;
}

bool predmetPodsetnikActionEnabled({
  required OpcEntitlementPolicy entitlementPolicy,
  required String predmetStatus,
}) {
  return entitlementPolicy.isModuleAvailable(OpcModule.podsetnik) &&
      isPodsetnikEligibleStatus(predmetStatus);
}

bool predmetJsonExportActionVisible({
  required OpcEntitlementPolicy entitlementPolicy,
  required String predmetStatus,
}) {
  return predmetStatus != 'ANONIMIZOVAN' &&
      entitlementPolicy.isDocumentActionVisible(OpcDocumentAction.jsonTransfer);
}

List<PredmetOverflowActionDefinition> buildPredmetOverflowActions({
  required String predmetStatus,
  required bool canOpenPodsetnik,
  required bool canExportJson,
}) {
  return [
    if (predmetStatus == 'OTVOREN')
      const PredmetOverflowActionDefinition(
        action: PredmetOverflowAction.close,
        label: 'Zatvori predmet',
        icon: Icons.lock_outline,
      ),
    if (predmetStatus == 'ZATVOREN') ...[
      const PredmetOverflowActionDefinition(
        action: PredmetOverflowAction.edit,
        label: 'Otvori za izmenu',
        icon: Icons.edit_outlined,
      ),
      const PredmetOverflowActionDefinition(
        action: PredmetOverflowAction.finish,
        label: 'Označi kao ZAVRŠEN',
        icon: Icons.done_all,
      ),
    ],
    const PredmetOverflowActionDefinition(
      action: PredmetOverflowAction.documents,
      label: 'Dokumenti',
      icon: Icons.folder_outlined,
    ),
    PredmetOverflowActionDefinition(
      action: PredmetOverflowAction.reminder,
      label: 'Podsetnik',
      icon: Icons.notifications_none_outlined,
      enabled: canOpenPodsetnik,
    ),
    if (canExportJson)
      const PredmetOverflowActionDefinition(
        action: PredmetOverflowAction.exportJson,
        label: 'Izvezi JSON',
        icon: Icons.upload_file_outlined,
      ),
    PredmetOverflowActionDefinition(
      action: PredmetOverflowAction.anonymize,
      label: 'GDPR anonimizacija',
      icon: Icons.person_remove_outlined,
      enabled: predmetStatus == 'ZAVRŠEN',
    ),
    const PredmetOverflowActionDefinition(
      action: PredmetOverflowAction.delete,
      label: 'Obriši trajno',
      icon: Icons.delete_forever_outlined,
      destructive: true,
    ),
  ];
}

class PredmetOverflowMenu extends StatelessWidget {
  const PredmetOverflowMenu({
    super.key,
    required this.predmetStatus,
    required this.canOpenPodsetnik,
    required this.canExportJson,
    required this.onSelected,
    this.triggerKey,
    this.compact = false,
  });

  final String predmetStatus;
  final bool canOpenPodsetnik;
  final bool canExportJson;
  final ValueChanged<PredmetOverflowAction> onSelected;
  final Key? triggerKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final triggerFill = isDarkTheme
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.95)
        : scheme.surface.withValues(alpha: 0.9);
    final triggerBorder = isDarkTheme
        ? scheme.outline.withValues(alpha: 0.7)
        : scheme.outlineVariant.withValues(alpha: 0.85);
    final triggerIconColor = isDarkTheme
        ? scheme.onSurface
        : scheme.onSurfaceVariant;

    final menuButton = PopupMenuButton<PredmetOverflowAction>(
      key: triggerKey,
      tooltip: 'Više opcija',
      padding: compact ? EdgeInsets.zero : const EdgeInsets.all(8),
      splashRadius: compact ? 20 : null,
      icon: Icon(
        Icons.more_vert,
        size: compact ? 20 : null,
        color: compact ? triggerIconColor : null,
      ),
      onSelected: onSelected,
      itemBuilder: (_) => _buildItems(context),
    );

    if (!compact) return menuButton;

    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: triggerFill,
          shape: BoxShape.circle,
          border: Border.all(color: triggerBorder),
        ),
        child: menuButton,
      ),
    );
  }

  List<PopupMenuEntry<PredmetOverflowAction>> _buildItems(
    BuildContext context,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final actions = buildPredmetOverflowActions(
      predmetStatus: predmetStatus,
      canOpenPodsetnik: canOpenPodsetnik,
      canExportJson: canExportJson,
    );
    final entries = <PopupMenuEntry<PredmetOverflowAction>>[];
    for (final definition in actions) {
      if (definition.action == PredmetOverflowAction.delete) {
        entries.add(
          const PopupMenuDivider(key: Key('predmet-overflow-divider-delete')),
        );
      }
      entries.add(
        PopupMenuItem<PredmetOverflowAction>(
          key: Key('predmet-overflow-action-${definition.action.name}'),
          value: definition.action,
          enabled: definition.enabled,
          child: ListTile(
            leading: Icon(
              definition.icon,
              color: definition.destructive ? scheme.error : null,
            ),
            title: Text(
              definition.label,
              style: definition.destructive
                  ? TextStyle(color: scheme.error)
                  : null,
            ),
            dense: true,
          ),
        ),
      );
    }
    return entries;
  }
}

AlertDialog buildPredmetOverflowDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  final isNarrowAndroid =
      Theme.of(context).platform == TargetPlatform.android &&
      MediaQuery.of(context).size.width < 600;
  return AlertDialog(
    insetPadding: isNarrowAndroid
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
        : null,
    scrollable: isNarrowAndroid,
    actionsOverflowDirection: VerticalDirection.down,
    actionsOverflowAlignment: OverflowBarAlignment.end,
    title: title,
    content: content,
    actions: actions,
  );
}

Future<bool> finishPredmetFromOverflow({
  required BuildContext context,
  required PredmetiRepository predmetiRepo,
  required SessionService session,
  required int predmetId,
  required String currentStatus,
}) async {
  if (currentStatus != 'ZATVOREN' || !context.mounted) return false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => buildPredmetOverflowDialog(
      context: dialogContext,
      title: const Text('Označi predmet kao ZAVRŠEN'),
      content: const Text(
        'Predmet će biti označen kao ZAVRŠEN i trajno zaključan za izmene.\n'
        'Posle ove potvrde više nije moguće otvoriti predmet za izmenu.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('OZNAČI KAO ZAVRŠEN'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  await predmetiRepo.zavrsiPredmet(predmetId, korisnikId: session.korisnik!.id);
  return true;
}

Future<bool> anonymizePredmetFromOverflow({
  required BuildContext context,
  required PredmetiRepository predmetiRepo,
  required int predmetId,
  required String predmetNumber,
  required String currentStatus,
}) async {
  if (currentStatus != 'ZAVRŠEN' || !context.mounted) return false;
  if (await predmetiRepo.imaAktivnuNezavrsenuPartePripremu(predmetId)) {
    if (!context.mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => buildPredmetOverflowDialog(
        context: dialogContext,
        title: const Text('Predmet ne može biti anonimizovan'),
        content: const Text(
          'PARTE priprema je započeta i nije završena. Završite KORICE PDF '
          'izvoz i izaberite PRIPREMA ZAVRŠENA.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('U REDU'),
          ),
        ],
      ),
    );
    return false;
  }
  if (!context.mounted) return false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => buildPredmetOverflowDialog(
      context: dialogContext,
      title: const Text('GDPR anonimizacija'),
      content: Text(
        'Anonimizovati predmet $predmetNumber?\n\n'
        'GDPR zaštita podataka o ličnosti trajno uklanja zaštićene '
        'identifikacione i kontakt podatke.\n\n'
        'Imena ostaju vidljiva. Predmet ostaje u evidenciji sa statusom '
        'ANONIMIZOVAN.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('OTKAŽI'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('ANONIMIZUJ'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  await predmetiRepo.anonimizujPredmet(predmetId);
  return true;
}

Future<bool> deletePredmetFromOverflow({
  required BuildContext context,
  required PredmetiRepository predmetiRepo,
  required int predmetId,
  required String predmetNumber,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => buildPredmetOverflowDialog(
      context: dialogContext,
      title: const Text('Trajno brisanje predmeta'),
      content: Text(
        'Predmet $predmetNumber će biti trajno obrisan.\n\n'
        'Biće nepovratno uklonjeni i svi njegovi zavisni podaci.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('ODUSTANI'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('OBRIŠI TRAJNO'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  await PredmetHardDeleteCoordinator(
    db: predmetiRepo.db,
    notificationGateway: AndroidCeremonyNotificationGateway(),
  ).deletePredmet(predmetId);
  return true;
}
