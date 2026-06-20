import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../format/app_filename_format.dart';

const _kAndroidKoriceChannelName = 'opc_v4/korice_storage';
const _kAndroidKoriceLocationLabel = 'Downloads/KORICE';

const MethodChannel _androidKoriceChannel =
    MethodChannel(_kAndroidKoriceChannelName);

class KoriceFileEntry {
  const KoriceFileEntry({
    required this.name,
    required this.modified,
    required this.locationLabel,
    this.path,
    this.contentUri,
  });

  final String name;
  final DateTime modified;
  final String locationLabel;
  final String? path;
  final String? contentUri;
}

String koriceFajlLokacija(KoriceFileEntry fajl) {
  return '${fajl.locationLabel}/${fajl.name}';
}

Future<Directory> getKoriceDir() async {
  final Directory base;

  if (Platform.isAndroid) {
    base = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
  } else {
    base = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  final korice = Directory('${base.path}${Platform.pathSeparator}KORICE');
  if (!korice.existsSync()) await korice.create(recursive: true);
  return korice;
}

Future<bool> otvoriKoriceDir() async {
  if (Platform.isAndroid) {
    return false;
  }

  final dir = await getKoriceDir();

  if (Platform.isWindows) {
    await Process.start(
      'explorer.exe',
      [dir.path],
      runInShell: true,
    );
    return true;
  }

  if (Platform.isMacOS) {
    await Process.start(
      'open',
      [dir.path],
      runInShell: true,
    );
    return true;
  }

  if (Platform.isLinux) {
    await Process.start(
      'xdg-open',
      [dir.path],
      runInShell: true,
    );
    return true;
  }

  return false;
}

Future<KoriceFileEntry> sacuvajKoricePdfFajlDetalji(
  String naziv,
  Uint8List bytes,
) async {
  if (Platform.isAndroid) {
    final raw = await _androidKoriceChannel.invokeMethod<Map<Object?, Object?>>(
      'savePdfToDownloadsKorice',
      <String, Object>{
        'filename': naziv,
        'bytes': bytes,
      },
    );
    if (raw == null) {
      throw StateError('Android KORICE save nije vratio metapodatke fajla.');
    }
    return KoriceFileEntry(
      name: (raw['name'] as String?) ?? naziv,
      modified: DateTime.now(),
      locationLabel:
          (raw['locationLabel'] as String?) ?? _kAndroidKoriceLocationLabel,
      path: raw['path'] as String?,
      contentUri: raw['contentUri'] as String?,
    );
  }

  final dir = await getKoriceDir();
  final fajl = File('${dir.path}${Platform.pathSeparator}$naziv');
  await fajl.writeAsBytes(bytes, flush: true);
  final modified = await fajl.lastModified();
  return KoriceFileEntry(
    name: naziv,
    modified: modified,
    locationLabel: 'KORICE',
    path: fajl.path,
  );
}

Future<KoriceFileEntry> sacuvajKoriceDokumentFajlDetalji(
  String naziv,
  Uint8List bytes, {
  required String mimeType,
}) async {
  if (Platform.isAndroid) {
    final raw = await _androidKoriceChannel.invokeMethod<Map<Object?, Object?>>(
      'saveDocumentToDownloadsKorice',
      <String, Object>{
        'filename': naziv,
        'bytes': bytes,
        'mimeType': mimeType,
      },
    );
    if (raw == null) {
      throw StateError('Android KORICE save nije vratio metapodatke fajla.');
    }
    return KoriceFileEntry(
      name: (raw['name'] as String?) ?? naziv,
      modified: DateTime.now(),
      locationLabel:
          (raw['locationLabel'] as String?) ?? _kAndroidKoriceLocationLabel,
      path: raw['path'] as String?,
      contentUri: raw['contentUri'] as String?,
    );
  }

  final dir = await getKoriceDir();
  final fajl = File('${dir.path}${Platform.pathSeparator}$naziv');
  await fajl.writeAsBytes(bytes, flush: true);
  final modified = await fajl.lastModified();
  return KoriceFileEntry(
    name: naziv,
    modified: modified,
    locationLabel: 'KORICE',
    path: fajl.path,
  );
}

Future<String> sacuvajKoricePdfFajl(String naziv, Uint8List bytes) async {
  final fajl = await sacuvajKoricePdfFajlDetalji(naziv, bytes);
  return koriceFajlLokacija(fajl);
}

Future<void> otvoriKoriceFajl(KoriceFileEntry fajl) async {
  if (Platform.isAndroid) {
    await _androidKoriceChannel.invokeMethod<void>(
      'openKoriceFile',
      <String, Object>{
        if (fajl.contentUri != null) 'contentUri': fajl.contentUri!,
        if (fajl.path != null) 'path': fajl.path!,
      },
    );
    return;
  }

  final path = fajl.path;
  if (path == null || path.trim().isEmpty) {
    throw StateError('KORICE fajl nema lokalnu putanju za otvaranje.');
  }

  if (Platform.isWindows) {
    await Process.start(
      'explorer.exe',
      [path],
      runInShell: true,
    );
    return;
  }

  if (Platform.isMacOS) {
    await Process.start(
      'open',
      [path],
      runInShell: true,
    );
    return;
  }

  if (Platform.isLinux) {
    await Process.start(
      'xdg-open',
      [path],
      runInShell: true,
    );
    return;
  }

  throw UnsupportedError('Otvaranje KORICE fajla nije podrzano na ovoj platformi.');
}

void prikaziPdfExportSuccessSnackBar(
  BuildContext ctx, {
  required String poruka,
  required KoriceFileEntry fajl,
}) {
  final messenger = ScaffoldMessenger.of(ctx);
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: Text(poruka),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green,
      action: SnackBarAction(
        label: 'PRIKA\u017dI DOKUMENT',
        textColor: Colors.white,
        onPressed: () async {
          try {
            await otvoriKoriceFajl(fajl);
          } catch (e) {
            if (!ctx.mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text('Greska pri otvaranju dokumenta: $e'),
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
            );
          }
        },
      ),
    ),
  );
  Future<void>.delayed(const Duration(seconds: 5), controller.close);
}

Future<List<KoriceFileEntry>> procitajKoriceFajlove() async {
  if (Platform.isAndroid) {
    final raw = await _androidKoriceChannel.invokeMethod<List<Object?>>(
      'listKoriceFiles',
    );
    if (raw == null) return const <KoriceFileEntry>[];

    return raw
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => KoriceFileEntry(
            name: (item['name'] as String?) ?? '',
            modified: DateTime.fromMillisecondsSinceEpoch(
              (item['modifiedEpochMs'] as int?) ?? 0,
            ),
            locationLabel:
                (item['locationLabel'] as String?) ??
                _kAndroidKoriceLocationLabel,
            path: item['path'] as String?,
            contentUri: item['contentUri'] as String?,
          ),
        )
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  final dir = await getKoriceDir();
  if (!dir.existsSync()) {
    return const <KoriceFileEntry>[];
  }

  final fajlovi = dir
      .listSync()
      .whereType<File>()
      .toList(growable: false);

  fajlovi.sort(
    (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
  );

  return fajlovi
      .map(
        (fajl) => KoriceFileEntry(
          name: fajl.uri.pathSegments.isNotEmpty
              ? fajl.uri.pathSegments.last
              : fajl.path,
          modified: fajl.statSync().modified,
          locationLabel: 'KORICE',
          path: fajl.path,
        ),
      )
      .toList(growable: false);
}

Future<Uint8List> ucitajKoriceFajlZaDeljenje(KoriceFileEntry fajl) async {
  if (Platform.isAndroid && fajl.contentUri != null) {
    final bytes = await _androidKoriceChannel.invokeMethod<Uint8List>(
      'readKoriceFileBytes',
      <String, Object>{
        'contentUri': fajl.contentUri!,
      },
    );
    if (bytes != null) return bytes;
    throw StateError('Android KORICE fajl nije mogu\u0107e u\u010Ditati za deljenje.');
  }

  final path = fajl.path;
  if (path == null || path.trim().isEmpty) {
    throw StateError('KORICE fajl nema lokalnu putanju za deljenje.');
  }

  return File(path).readAsBytes();
}

String koriceFajlNaziv(PredmetiData p, String ext) {
  return joinFilenameParts(
    [p.brojPredmeta, p.ime, p.prezime],
    ext,
  );
}

String koricePdfDerivatFajlNaziv(
  PredmetiData p,
  String nazivDokumenta, {
  bool includePredmetVersion = true,
}) {
  return joinFilenameParts(
    [
      p.prezime,
      p.ime,
      p.brojPredmeta,
      nazivDokumenta,
      if (includePredmetVersion) 'v${p.verzija}',
    ],
    'pdf',
  );
}

