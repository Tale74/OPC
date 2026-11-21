import 'package:flutter/material.dart';

Future<List<String>?> showIriuOrderDialog(
  BuildContext context, {
  required String title,
  required List<({String id, String label})> rows,
}) {
  final draft = rows.toList();
  final labels = MaterialLocalizations.of(context);
  return showDialog<List<String>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void move(int from, int to) {
          setState(() => draft.insert(to, draft.removeAt(from)));
        }

        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 470,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, row) in draft.indexed)
                    Row(
                      key: ValueKey(row.id),
                      children: [
                        Expanded(child: Text(row.label)),
                        IconButton(
                          tooltip: 'Gore',
                          onPressed: index > 0
                              ? () => move(index, index - 1)
                              : null,
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: 'Dole',
                          onPressed: index + 1 < draft.length
                              ? () => move(index, index + 1)
                              : null,
                          icon: const Icon(Icons.arrow_downward),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(labels.cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context, draft.map((item) => item.id).toList(),
              ),
              child: Text(labels.okButtonLabel),
            ),
          ],
        );
      },
    ),
  );
}
