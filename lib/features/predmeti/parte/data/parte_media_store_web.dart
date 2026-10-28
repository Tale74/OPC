import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

const _databaseName = 'opc_v1_parte_media';
const _storeName = 'media';
Future<web.IDBDatabase>? _databaseFuture;

Future<web.IDBDatabase> _database() => _databaseFuture ??= _openDatabase();

Future<web.IDBDatabase> _openDatabase() {
  final completer = Completer<web.IDBDatabase>();
  try {
    final request = web.window.indexedDB.open(_databaseName, 1);
    request.onupgradeneeded = ((web.Event _) {
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(_storeName)) {
        db.createObjectStore(_storeName);
      }
    }).toJS;
    request.onsuccess = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.complete(request.result as web.IDBDatabase);
      }
    }).toJS;
    request.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError(request.error?.message ?? 'IndexedDB open failed.'),
        );
      }
    }).toJS;
  } on Object catch (error, stack) {
    completer.completeError(error, stack);
  }
  return completer.future;
}

Future<JSAny?> _request(web.IDBRequest request) {
  final completer = Completer<JSAny?>();
  request.onsuccess = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.complete(request.result);
    }
  }).toJS;
  request.onerror = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError(request.error?.message ?? 'IndexedDB request failed.'),
      );
    }
  }).toJS;
  return completer.future;
}

Future<void> _transaction(web.IDBTransaction tx) {
  final completer = Completer<void>();
  tx.oncomplete = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }).toJS;
  tx.onabort = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError(tx.error?.message ?? 'IndexedDB transaction aborted.'),
      );
    }
  }).toJS;
  tx.onerror = ((web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError(tx.error?.message ?? 'IndexedDB transaction failed.'),
      );
    }
  }).toJS;
  return completer.future;
}

Future<void> _write(void Function(web.IDBObjectStore store) enqueue) async {
  final db = await _database();
  final tx = db.transaction(_storeName.toJS, 'readwrite');
  final done = _transaction(tx);
  enqueue(tx.objectStore(_storeName));
  await done;
}

Future<void> writeMedia(String key, Uint8List bytes) =>
    _write((store) => store.put(bytes.toJS, key.toJS));

Future<Uint8List?> readMedia(String key) async {
  final db = await _database();
  final tx = db.transaction(_storeName.toJS, 'readonly');
  final done = _transaction(tx);
  final result = await _request(tx.objectStore(_storeName).get(key.toJS));
  await done;
  if (result == null) return null;
  return Uint8List.fromList((result as JSUint8Array).toDart);
}

Future<void> deleteMedia(String key) =>
    _write((store) => store.delete(key.toJS));

Future<bool> existsMedia(String key) async => (await readMedia(key)) != null;

Future<Map<String, String>> stageDeletion(Set<String> keys) async {
  final staged = <String, String>{};
  final values = <String, Uint8List>{};
  for (final key in keys) {
    final bytes = await readMedia(key);
    if (bytes != null) {
      values[key] = bytes;
      final stageKey = StringBuffer('__delete_trash__/')
        ..write(DateTime.now().microsecondsSinceEpoch)
        ..write('/')
        ..write(staged.length);
      staged[key] = stageKey.toString();
    }
  }
  if (staged.isNotEmpty) {
    await _write((store) {
      for (final entry in staged.entries) {
        store.put(values[entry.key]!.toJS, entry.value.toJS);
        store.delete(entry.key.toJS);
      }
    });
  }
  return staged;
}

Future<void> restoreDeletion(Map<String, String> staged) async {
  final values = <String, Uint8List>{};
  for (final entry in staged.entries) {
    final bytes = await readMedia(entry.value);
    if (bytes != null) values[entry.key] = bytes;
  }
  if (values.isEmpty) return;
  await _write((store) {
    for (final entry in values.entries) {
      store.put(entry.value.toJS, entry.key.toJS);
      store.delete(staged[entry.key]!.toJS);
    }
  });
}

Future<void> purgeDeletion(Map<String, String> staged) async {
  if (staged.isEmpty) return;
  await _write((store) {
    for (final key in staged.values) {
      store.delete(key.toJS);
    }
  });
}
