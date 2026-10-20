import 'package:flutter/material.dart';

import '../help/opc_help.dart';

/// Shared responsive AppBar composition for OPC route titles and identities.
///
/// On narrow Android, primary lifecycle actions are intentionally left to the
/// route's persistent action area. Tools remain available in the AppBar.
class OpcPageChrome extends StatelessWidget implements PreferredSizeWidget {
  const OpcPageChrome({
    super.key,
    this.title,
    this.identity,
    this.status,
    this.primaryActions = const [],
    this.tools = const [],
    this.leading,
    this.narrowAndroid = false,
    this.helpChapterId,
  });

  final Widget? title;
  final Widget? identity;
  final Widget? status;
  final List<Widget> primaryActions;
  final List<Widget> tools;
  final Widget? leading;
  final bool narrowAndroid;
  final String? helpChapterId;

  @override
  Size get preferredSize => Size.fromHeight(
    narrowAndroid && (identity != null || status != null) ? 84 : kToolbarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final hasIdentity = identity != null;
    final titleWidget = narrowAndroid
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?title,
              if (identity != null) ...[
                if (title != null) const SizedBox(height: 2),
              ],
              ?identity,
              if (status != null) ...[
                if (hasIdentity || title != null) const SizedBox(height: 4),
              ],
              ?status,
            ],
          )
        : title != null && identity != null
        ? Row(
            children: [
              title!,
              const SizedBox(width: 12),
              Expanded(child: identity!),
            ],
          )
        : (identity ?? title);

    final appBarTitle = helpChapterId == null || titleWidget == null
        ? titleWidget
        : Row(
            children: [
              OpcHelpButton(chapterId: helpChapterId!),
              const SizedBox(width: 4),
              Expanded(child: titleWidget),
            ],
          );

    return AppBar(
      leading: leading,
      toolbarHeight: narrowAndroid && (hasIdentity || status != null)
          ? 84
          : null,
      titleSpacing: narrowAndroid ? 12 : null,
      title: appBarTitle,
      actions: [
        if (!narrowAndroid) ...[
          ?status,
          if (status != null) const SizedBox(width: 4),
          ...primaryActions,
        ],
        ...tools,
      ],
    );
  }
}
