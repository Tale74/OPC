// OWNER-only offline issuer. Never put its key file in this repository, builds,
// review packages, chat messages, or a customer backup.
//
// dart run tool/opc_license_issuer.dart init <private-key-file>
// dart run tool/opc_license_issuer.dart issue <private-key-file>
//   <firma-pib> <firma-mb> <customer-label> <output-file> <license-id>
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import 'package:opc_v4/core/entitlements/opc_canonical_json.dart';

const keyId = 'opc-owner-20261022';

Future<void> main(List<String> args) async {
  if (args.length == 2 && args[0] == 'init') {
    final keyFile = File(args[1]);
    if (await keyFile.exists()) {
      throw StateError('Owner signing key already exists; refusing overwrite.');
    }
    await keyFile.parent.create(recursive: true);
    final algorithm = Ed25519();
    final pair = await algorithm.newKeyPair();
    final seed = await pair.extractPrivateKeyBytes();
    await keyFile.writeAsString(base64Encode(seed), flush: true);
    final publicKey = await pair.extractPublicKey();
    stdout.writeln('keyId=$keyId');
    stdout.writeln('publicKeyBase64=${base64Encode(publicKey.bytes)}');
    stdout.writeln(
      'Private key saved at the supplied path; back it up offline.',
    );
    return;
  }
  if (args.length == 7 && args[0] == 'issue') {
    final keyFile = File(args[1]);
    final firmaPib = args[2].trim();
    final firmaMb = args[3].trim();
    final customerLabel = args[4].trim();
    final output = File(args[5]);
    final licenseId = args[6].trim();
    if (firmaPib.isEmpty ||
        firmaMb.isEmpty ||
        customerLabel.isEmpty ||
        licenseId.isEmpty ||
        await output.exists()) {
      throw ArgumentError('Invalid request or output already exists.');
    }
    final seed = base64Decode((await keyFile.readAsString()).trim());
    if (seed.length != 32) throw StateError('Owner key is invalid.');
    final algorithm = Ed25519();
    final pair = await algorithm.newKeyPairFromSeed(seed);
    final payload = <String, Object?>{
      'licenseId': licenseId,
      'customerId': '$firmaPib:$firmaMb',
      'customerLabel': customerLabel,
      'firmaPib': firmaPib,
      'firmaMb': firmaMb,
      'packageLevel': 'potpun',
      'enabledAddOns': <String>[],
      'issuedAt': DateTime.now().toUtc().toIso8601String(),
      'diagnosticsLabel': 'opc_permanent_owner_activation',
    };
    final canonical = OpcCanonicalJsonV1.encode(payload);
    final signature = await algorithm.sign(
      utf8.encode(canonical),
      keyPair: pair,
    );
    await output.parent.create(recursive: true);
    await output.writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 2,
        'payload': payload,
        'signature': base64Encode(signature.bytes),
        'signatureMetadata': <String, Object?>{
          'algorithmId': 'ed25519-v1',
          'keyId': keyId,
        },
      }),
      flush: true,
    );
    stdout.writeln('Signed permanent activation saved: ${output.path}');
    return;
  }
  stderr.writeln(
    'Usage: init <private-key-file> | issue <private-key-file> '
    '<firma-pib> <firma-mb> <customer-label> <output-file> <license-id>',
  );
  exitCode = 64;
}
