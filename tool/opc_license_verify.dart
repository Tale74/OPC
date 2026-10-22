// Offline verification of an OWNER-issued token without displaying its body.
import 'dart:io';

import 'package:opc_v4/core/entitlements/opc_license_public_key_registry.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_model.dart';
import 'package:opc_v4/core/entitlements/opc_local_license_parser.dart';

Future<void> main(List<String> args) async {
  if (args.length != 3) {
    stderr.writeln('Usage: <license-file> <platform> <installation-id>');
    exitCode = 64;
    return;
  }
  final platform = OpcLocalLicensePlatform.values
      .where((candidate) => candidate.name == args[1].toLowerCase())
      .firstOrNull;
  if (platform == null) {
    stderr.writeln('Unsupported platform.');
    exitCode = 64;
    return;
  }
  final result =
      await OpcLocalLicenseParser(
        verifier: OpcLicensePublicKeyRegistry.createProductionVerifier(),
      ).evaluate(
        await File(args[0]).readAsString(),
        currentPlatform: platform,
        installationId: args[2],
      );
  if (!result.isValid || result.payload?.expiresAt != null) {
    stderr.writeln('INVALID: ${result.failureReason?.name ?? 'notPermanent'}');
    exitCode = 1;
    return;
  }
  stdout.writeln('VALID_PERMANENT: ${result.payload!.licenseId}');
}
