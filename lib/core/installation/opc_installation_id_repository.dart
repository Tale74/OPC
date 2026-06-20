import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

final class OpcInstallationIdRepository {
  OpcInstallationIdRepository({Random? random})
      : _random = random ?? Random.secure();

  static const _fileName = 'opc_installation_id.txt';
  static final _validInstallationIdPattern = RegExp(
    r'^opc_install_[0-9]+_[0-9a-f]{32}$',
  );

  final Random _random;

  Future<String> getOrCreateInstallationId() async {
    final file = await _installationIdFile();
    final existing = await _readExistingInstallationId(file);
    if (existing != null) return existing;

    final generated = _generateInstallationId();
    await file.create(recursive: true);
    await file.writeAsString(generated, flush: true);
    return generated;
  }

  Future<String?> readInstallationId() async {
    return _readExistingInstallationId(await _installationIdFile());
  }

  Future<File> _installationIdFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  Future<String?> _readExistingInstallationId(File file) async {
    if (!await file.exists()) return null;

    final value = (await file.readAsString()).trim();
    if (_validInstallationIdPattern.hasMatch(value)) return value;
    return null;
  }

  String _generateInstallationId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomPart = List<int>.generate(
      16,
      (_) => _random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return 'opc_install_${timestamp}_$randomPart';
  }
}
