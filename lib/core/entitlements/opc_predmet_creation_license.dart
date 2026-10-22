import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../database/database.dart';
import 'opc_license_public_key_registry.dart';
import 'opc_local_license_model.dart';
import 'opc_local_license_parser.dart';

enum OpcPredmetLicenseStatus { trial, expired, activated, clockRollback }

final class OpcPredmetLicenseState {
  const OpcPredmetLicenseState({
    required this.status,
    required this.trialStartedUtc,
    required this.trialEndsUtc,
    required this.installationId,
  });

  final OpcPredmetLicenseStatus status;
  final DateTime trialStartedUtc;
  final DateTime trialEndsUtc;
  final String installationId;

  bool get canCreateNewPredmet =>
      status == OpcPredmetLicenseStatus.trial ||
      status == OpcPredmetLicenseStatus.activated;
}

/// Local, offline, per-installation gate for *manual* opening of a new
/// PREDMET. Its state lives beside, but outside, transferable business backup
/// tables. Imported/rehydrated existing PREDMET records remain available.
final class OpcPredmetCreationLicense {
  OpcPredmetCreationLicense(
    this._db, {
    DateTime Function()? clock,
    OpcLocalLicenseParser? parser,
    OpcLocalLicensePlatform? platform,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _parser =
           parser ??
           OpcLocalLicenseParser(
             verifier: OpcLicensePublicKeyRegistry.createProductionVerifier(),
           ),
       _platform = platform ?? _currentPlatform(),
       _random = random ?? Random.secure();

  final AppDatabase _db;
  final DateTime Function() _clock;
  final OpcLocalLicenseParser _parser;
  final OpcLocalLicensePlatform _platform;
  final Random _random;

  static OpcLocalLicensePlatform _currentPlatform() {
    if (kIsWeb) return OpcLocalLicensePlatform.web;
    if (Platform.isWindows) return OpcLocalLicensePlatform.windows;
    if (Platform.isAndroid) return OpcLocalLicensePlatform.android;
    if (Platform.isIOS) return OpcLocalLicensePlatform.ios;
    if (Platform.isMacOS) return OpcLocalLicensePlatform.macos;
    throw UnsupportedError('OPC licensing does not support this platform.');
  }

  /// Calendar-month addition clamps a 29th/30th/31st to the final day of the
  /// target month. UTC keeps the persisted boundary stable across time zones.
  static DateTime addThreeCalendarMonths(DateTime start) {
    final utc = start.toUtc();
    final targetFirst = DateTime.utc(utc.year, utc.month + 3);
    final targetLastDay = DateTime.utc(
      targetFirst.year,
      targetFirst.month + 1,
      0,
    ).day;
    return DateTime.utc(
      targetFirst.year,
      targetFirst.month,
      utc.day.clamp(1, targetLastDay),
      utc.hour,
      utc.minute,
      utc.second,
      utc.millisecond,
      utc.microsecond,
    );
  }

  Future<OpcPredmetLicenseState> evaluate() async {
    final record = await _readOrCreate();
    final now = _clock().toUtc();
    final started = DateTime.parse(record['trial_started_utc']!);
    final lastSeen = DateTime.parse(record['max_seen_utc']!);
    final installationId = record['installation_id']!;
    final trialEnds = addThreeCalendarMonths(started);
    final rollback = now.isBefore(
      lastSeen.subtract(const Duration(minutes: 5)),
    );

    final license = record['license_text'];
    if (license != null && license.isNotEmpty) {
      final result = await _parser.evaluate(
        license,
        currentPlatform: _platform,
        installationId: installationId,
      );
      if (result.isValid && result.payload?.expiresAt == null) {
        await _rememberTime(now, lastSeen);
        return OpcPredmetLicenseState(
          status: OpcPredmetLicenseStatus.activated,
          trialStartedUtc: started,
          trialEndsUtc: trialEnds,
          installationId: installationId,
        );
      }
    }

    await _rememberTime(now, lastSeen);
    return OpcPredmetLicenseState(
      status: rollback
          ? OpcPredmetLicenseStatus.clockRollback
          : now.isBefore(trialEnds)
          ? OpcPredmetLicenseStatus.trial
          : OpcPredmetLicenseStatus.expired,
      trialStartedUtc: started,
      trialEndsUtc: trialEnds,
      installationId: installationId,
    );
  }

  /// Accept only a signed, permanent token for this installation and platform.
  /// Failed input does not replace an existing valid activation.
  Future<bool> installPermanentActivation(String licenseText) async {
    final record = await _readOrCreate();
    final result = await _parser.evaluate(
      licenseText.trim(),
      currentPlatform: _platform,
      installationId: record['installation_id'],
    );
    if (!result.isValid || result.payload?.expiresAt != null) return false;
    await _db.customStatement(
      'UPDATE opc_local_predmet_license SET license_text = ? WHERE id = 1',
      [licenseText.trim()],
    );
    return true;
  }

  Future<Map<String, String?>> _readOrCreate() async {
    return _db.transaction(() async {
      await _db.customStatement('''
        CREATE TABLE IF NOT EXISTS opc_local_predmet_license (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          trial_started_utc TEXT NOT NULL,
          max_seen_utc TEXT NOT NULL,
          installation_id TEXT NOT NULL,
          license_text TEXT
        )
      ''');
      final existing = await _db
          .customSelect(
            'SELECT trial_started_utc, max_seen_utc, installation_id, '
            'license_text FROM opc_local_predmet_license WHERE id = 1',
          )
          .getSingleOrNull();
      if (existing != null) {
        return existing.data.map(
          (key, value) => MapEntry(key, value as String?),
        );
      }
      final now = _clock().toUtc().toIso8601String();
      final randomBytes = List<int>.generate(16, (_) => _random.nextInt(256));
      final id =
          'opc_install_${DateTime.parse(now).microsecondsSinceEpoch}_'
          '${randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
      await _db.customStatement(
        'INSERT INTO opc_local_predmet_license '
        '(id, trial_started_utc, max_seen_utc, installation_id) '
        'VALUES (1, ?, ?, ?)',
        [now, now, id],
      );
      return <String, String?>{
        'trial_started_utc': now,
        'max_seen_utc': now,
        'installation_id': id,
        'license_text': null,
      };
    });
  }

  Future<void> _rememberTime(DateTime now, DateTime lastSeen) async {
    if (!now.isAfter(lastSeen)) return;
    await _db.customStatement(
      'UPDATE opc_local_predmet_license SET max_seen_utc = ? WHERE id = 1',
      [now.toIso8601String()],
    );
  }
}
