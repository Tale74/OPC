import 'package:flutter/material.dart';

/// Highlights an enabled, empty manual-entry field using the GROBLJE pattern.
///
/// The child remains responsible for validation, optionality, labels and
/// accessibility. The wrapper only changes the decoration while no value has
/// been entered.
class ManualEntryAffordance extends StatelessWidget {
  const ManualEntryAffordance({
    super.key,
    required this.controller,
    required this.enabled,
    required this.child,
  });

  final TextEditingController controller;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final inviteInput = enabled && value.text.trim().isEmpty;
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final borderColor = inviteInput
              ? colors.primary
              : theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
                    colors.outline;
          final fieldTheme = theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: inviteInput
                ? colors.secondaryContainer
                : Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: borderColor,
                width: inviteInput ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          );
          return Theme(
            data: theme.copyWith(inputDecorationTheme: fieldTheme),
            child: child,
          );
        },
      );
}
