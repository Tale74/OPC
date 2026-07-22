import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ParteMediaKind { photo, customSymbol }

class ParteMediaImportResult {
  const ParteMediaImportResult({
    required this.mediaKey,
    required this.width,
    required this.height,
    required this.lowResolution,
  });

  final String mediaKey;
  final int width;
  final int height;
  final bool lowResolution;
}

class ParteMediaException implements Exception {
  const ParteMediaException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ParteMediaDeletionBatch {
  ParteMediaDeletionBatch._(this._entries, this._trashDirectory);

  final List<({File original, File staged})> _entries;
  final Directory? _trashDirectory;

  Future<void> restore() async {
    for (final entry in _entries.reversed) {
      if (!await entry.staged.exists()) continue;
      await entry.original.parent.create(recursive: true);
      await entry.staged.rename(entry.original.path);
    }
    await _deleteEmptyTrashDirectory();
  }

  Future<void> purge() async {
    final directory = _trashDirectory;
    if (directory != null && await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _deleteEmptyTrashDirectory() async {
    final directory = _trashDirectory;
    if (directory == null || !await directory.exists()) return;
    if (await directory.list().isEmpty) await directory.delete();
  }
}

/// Owns only normalized OPC-created temporary media copies.
/// External originals are read by the picker and are never mutation targets.
class ParteMediaStore {
  ParteMediaStore({Future<Directory> Function()? rootDirectory})
    : _rootDirectory = rootDirectory ?? _defaultRoot;

  static const int maxInputBytes = 25 * 1024 * 1024;
  static const int maxDecodedPixels = 60 * 1000 * 1000;
  static const int normalizedLongEdge = 2400;
  static const int lowResolutionShortEdge = 450;
  static const int lowResolutionLongEdge = 600;

  final Future<Directory> Function() _rootDirectory;

  static Future<Directory> _defaultRoot() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'parte_media'));
  }

  Future<ParteMediaImportResult> importBytes({
    required Uint8List sourceBytes,
    required String predmetBroj,
    required ParteMediaKind kind,
  }) async {
    if (sourceBytes.isEmpty) {
      throw const ParteMediaException('Izabrani medij je prazan.');
    }
    if (sourceBytes.length > maxInputBytes) {
      throw const ParteMediaException('Izabrani medij je prevelik.');
    }
    final decoded = _decodeImage(sourceBytes);
    if (decoded == null || decoded.width <= 0 || decoded.height <= 0) {
      throw const ParteMediaException(
        'Medij nije podržana ili ispravna slika.',
      );
    }
    if (decoded.width * decoded.height > maxDecodedPixels) {
      throw const ParteMediaException(
        'Slika ima previše piksela za bezbednu obradu.',
      );
    }
    var normalized = img.bakeOrientation(decoded);
    final longest = normalized.width > normalized.height
        ? normalized.width
        : normalized.height;
    if (longest > normalizedLongEdge) {
      final scale = normalizedLongEdge / longest;
      normalized = img.copyResize(
        normalized,
        width: (normalized.width * scale).round(),
        height: (normalized.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }
    final normalizedBytes = Uint8List.fromList(
      img.encodePng(normalized, level: 6),
    );
    if (_decodePng(normalizedBytes) == null) {
      throw const ParteMediaException('Optimizovana kopija nije validna.');
    }

    final root = await _rootDirectory();
    await root.create(recursive: true);
    final caseToken = sha256
        .convert(predmetBroj.codeUnits)
        .toString()
        .substring(0, 20);
    final caseDirectory = Directory(p.join(root.path, caseToken));
    await caseDirectory.create(recursive: true);
    final contentToken = sha256
        .convert(normalizedBytes)
        .toString()
        .substring(0, 24);
    final base =
        '${kind.name}_${DateTime.now().microsecondsSinceEpoch}_$contentToken.png';
    final relativeKey = p.posix.join(caseToken, base);
    final destination = File(p.join(caseDirectory.path, base));
    final temporary = File('${destination.path}.tmp');
    try {
      await temporary.writeAsBytes(normalizedBytes, flush: true);
      final written = await temporary.readAsBytes();
      if (_decodePng(written) == null) {
        throw const ParteMediaException('Privremena kopija nije čitljiva.');
      }
      await temporary.rename(destination.path);
    } on FileSystemException catch (error) {
      if (await temporary.exists()) {
        try {
          await temporary.delete();
        } on FileSystemException {
          // Best effort for an unreferenced OPC-owned temporary file.
        }
      }
      throw ParteMediaException(
        'Upis app kopije nije uspeo: ${error.osError?.message ?? error.message}',
      );
    }

    final shortEdge = normalized.width < normalized.height
        ? normalized.width
        : normalized.height;
    final longEdge = normalized.width > normalized.height
        ? normalized.width
        : normalized.height;
    return ParteMediaImportResult(
      mediaKey: relativeKey,
      width: normalized.width,
      height: normalized.height,
      lowResolution:
          kind == ParteMediaKind.photo &&
          (shortEdge < lowResolutionShortEdge ||
              longEdge < lowResolutionLongEdge),
    );
  }

  Future<Uint8List> read(String mediaKey) async {
    final file = await _resolveOwnedFile(mediaKey);
    if (!await file.exists()) {
      throw const ParteMediaException('App-owned PARTE medij nedostaje.');
    }
    return file.readAsBytes();
  }

  Future<void> deleteOwned(String? mediaKey) async {
    if (mediaKey == null || mediaKey.trim().isEmpty) return;
    final file = await _resolveOwnedFile(mediaKey);
    if (await file.exists()) await file.delete();
  }

  /// Moves exclusively owned media out of the active store before the
  /// preparation record is deleted. The caller can restore the files if the
  /// database operation fails, or purge them after it succeeds.
  Future<ParteMediaDeletionBatch> stageOwnedDeletion(
    Iterable<String> mediaKeys,
  ) async {
    final uniqueKeys = mediaKeys
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet();
    if (uniqueKeys.isEmpty) {
      return ParteMediaDeletionBatch._(const [], null);
    }
    final root = await _rootDirectory();
    final trashDirectory = Directory(
      p.join(
        root.path,
        '.delete_trash',
        DateTime.now().microsecondsSinceEpoch.toString(),
      ),
    );
    final entries = <({File original, File staged})>[];
    try {
      for (final key in uniqueKeys) {
        final original = await _resolveOwnedFile(key);
        if (!await original.exists()) continue;
        await trashDirectory.create(recursive: true);
        final staged = File(
          p.join(trashDirectory.path, '${entries.length}_${p.basename(key)}'),
        );
        await original.rename(staged.path);
        entries.add((original: original, staged: staged));
      }
      return ParteMediaDeletionBatch._(entries, trashDirectory);
    } on Object {
      final batch = ParteMediaDeletionBatch._(entries, trashDirectory);
      try {
        await batch.restore();
      } on Object {
        // The original failure remains authoritative. A later cleanup audit
        // can recover the app-owned staging directory if restoration fails.
      }
      rethrow;
    }
  }

  Future<bool> exists(String? mediaKey) async {
    if (mediaKey == null || mediaKey.trim().isEmpty) return false;
    final file = await _resolveOwnedFile(mediaKey);
    return file.exists();
  }

  Future<File> _resolveOwnedFile(String mediaKey) async {
    if (mediaKey.contains('..') || p.isAbsolute(mediaKey)) {
      throw const ParteMediaException('Nebezbedan PARTE media ključ.');
    }
    final root = await _rootDirectory();
    final rootPath = p.normalize(p.absolute(root.path));
    final candidate = p.normalize(p.absolute(p.join(root.path, mediaKey)));
    if (!p.isWithin(rootPath, candidate)) {
      throw const ParteMediaException('PARTE medij nije app-owned.');
    }
    return File(candidate);
  }

  img.Image? _decodeImage(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  img.Image? _decodePng(Uint8List bytes) {
    try {
      return img.decodePng(bytes);
    } catch (_) {
      return null;
    }
  }
}
