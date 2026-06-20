import 'package:flutter/material.dart';

class PredmetBooleanDecisionTile extends StatelessWidget {
  const PredmetBooleanDecisionTile({
    super.key,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.subtitle,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeColor = enabled ? scheme.primary : scheme.onSurfaceVariant;
    final borderColor = value ? activeColor : scheme.outlineVariant;
    final textColor = enabled ? scheme.onSurface : scheme.onSurfaceVariant;

    final titleStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodyMedium;
    final stateStyle = compact
        ? theme.textTheme.labelMedium
        : theme.textTheme.labelLarge;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleStyle?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    final stateControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value ? 'DA' : 'NE',
          style: stateStyle?.copyWith(
            color: activeColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: compact ? 6 : 8),
        Transform.scale(
          scale: compact ? 0.86 : 1,
          child: Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < (compact ? 240 : 300);

        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 0 : 8),
          child: Material(
            color: value
                ? scheme.primaryContainer.withValues(
                    alpha: enabled ? 0.55 : 0.22,
                  )
                : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: enabled ? () => onChanged(!value) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 7 : 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: borderColor, width: value ? 1.4 : 1),
                ),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          titleBlock,
                          SizedBox(height: compact ? 6 : 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: stateControl,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: titleBlock),
                          const SizedBox(width: 12),
                          stateControl,
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PredmetSelectionChip extends StatelessWidget {
  const PredmetSelectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      showCheckmark: true,
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.22),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
        width: selected ? 1.4 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class PredmetProtectedTextField extends StatelessWidget {
  const PredmetProtectedTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.focusNode,
    this.maxLines = 1,
    this.hintText,
  });

  final String labelText;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? errorText;
  final FocusNode? focusNode;
  final int maxLines;
  final String? hintText;

  bool get _isRedacted => controller.text.trim().toLowerCase() == 'redacted';

  @override
  Widget build(BuildContext context) {
    if (_isRedacted) {
      return PredmetRedactedField(labelText: labelText);
    }

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }
}

class PredmetRedactedField extends StatelessWidget {
  const PredmetRedactedField({
    super.key,
    required this.labelText,
    this.fillColor,
  });

  final String labelText;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        isDense: true,
        filled: true,
        fillColor: fillColor ?? scheme.surfaceContainerHighest,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 96,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
