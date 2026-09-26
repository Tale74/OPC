import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';

/// Row-scoped CVEĆE ribbon text governed by the surrounding PREDMET editor.
class IriuCveceRibbonFields extends StatefulWidget {
  const IriuCveceRibbonFields({
    super.key,
    required this.database,
    required this.rows,
    required this.enabled,
  });

  final AppDatabase database;
  final List<IriuData> rows;
  final bool enabled;

  @override
  State<IriuCveceRibbonFields> createState() => _IriuCveceRibbonFieldsState();
}

class _IriuCveceRibbonFieldsState extends State<IriuCveceRibbonFields> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant IriuCveceRibbonFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeIds = widget.rows.map((row) => row.id).toSet();
    for (final id in _controllers.keys.toList()) {
      if (!activeIds.contains(id)) _controllers.remove(id)?.dispose();
    }
  }

  TextEditingController _controllerFor(IriuData row) {
    return _controllers.putIfAbsent(
      row.id,
      () => TextEditingController(text: row.tekstTrake ?? ''),
    );
  }

  Future<void> _saveRibbonText(int rowId, String value) async {
    if (!widget.enabled) return;
    await (widget.database.update(widget.database.iriu)
          ..where((item) => item.id.equals(rowId)))
        .write(IriuCompanion(tekstTrake: Value(value)));
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('iriu-cvece-ribbon-fields'),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TEKST TRAKE ZA CVEĆE',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final row in widget.rows)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                key: ValueKey('iriu-cvece-ribbon-${row.id}'),
                controller: _controllerFor(row),
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: row.nazivPrikaz.trim().isEmpty
                      ? 'CVEĆE'
                      : row.nazivPrikaz.trim(),
                  hintText: 'TEKST TRAKE',
                  border: const OutlineInputBorder(),
                ),
                onChanged: widget.enabled
                    ? (value) => _saveRibbonText(row.id, value)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
