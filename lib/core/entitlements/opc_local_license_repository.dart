import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef OpcLocalLicenseDirectoryProvider = Future<Directory> Function();

final class OpcLocalLicenseRepository {
  OpcLocalLicenseRepository({
    OpcLocalLicenseDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  static const fileName = 'opc_license.opc-license';

  final OpcLocalLicenseDirectoryProvider _directoryProvider;

  Future<String?> readInstalledLicenseText() async {
    final file = await _licenseFile();
    if (!await file.exists()) return null;

    final value = (await file.readAsString()).trim();
    return value.isEmpty ? null : value;
  }

  Future<void> installLicenseText(String rawLicenseText) async {
    final file = await _licenseFile();
    await file.create(recursive: true);
    await file.writeAsString(rawLicenseText, flush: true);
  }

  Future<void> clearInstalledLicense() async {
    final file = await _licenseFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _licenseFile() async {
    final directory = await _directoryProvider();
    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }
}
