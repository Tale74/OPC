import '../../../core/database/database.dart';
import '../domain/recovery_material_codec.dart';
import '../domain/temporary_pin_generator.dart';

class AuthAuditEventRecord {
  const AuthAuditEventRecord({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.actorType,
    required this.actorUserId,
    required this.targetUserId,
    required this.result,
    required this.details,
    required this.installContext,
  });

  final int id;
  final String timestamp;
  final String eventType;
  final String actorType;
  final int? actorUserId;
  final int? targetUserId;
  final String result;
  final String details;
  final String installContext;
}

class RecoveryMaterialStatus {
  const RecoveryMaterialStatus({
    required this.exists,
    required this.version,
    required this.configuredAt,
    required this.regeneratedAt,
  });

  final bool exists;
  final String version;
  final String configuredAt;
  final String regeneratedAt;
}

class CreateRecoveryMaterialResult {
  const CreateRecoveryMaterialResult({
    required this.plaintext,
    required this.version,
    required this.createdAt,
  });

  final String plaintext;
  final String version;
  final String createdAt;
}

class AuthSecurityRepository {
  AuthSecurityRepository(
    this._db, {
    RecoveryMaterialCodec? recoveryCodec,
    TemporaryPinGenerator? temporaryPinGenerator,
  })  : _recoveryCodec = recoveryCodec ?? RecoveryMaterialCodec(),
        _temporaryPinGenerator =
            temporaryPinGenerator ?? TemporaryPinGenerator();

  final AppDatabase _db;
  final RecoveryMaterialCodec _recoveryCodec;
  final TemporaryPinGenerator _temporaryPinGenerator;

  Future<bool> hasInstallationRecoveryMaterial() async {
    final row = await _db.customSelect(
      '''
        SELECT recovery_code_hash
        FROM security_settings
        WHERE id = 1
      ''',
      readsFrom: {},
    ).getSingleOrNull();
    final hash = row?.read<String>('recovery_code_hash') ?? '';
    return hash.isNotEmpty;
  }

  Future<RecoveryMaterialStatus> getRecoveryMaterialStatus() async {
    final row = await _db.customSelect(
      '''
        SELECT
          recovery_code_hash,
          recovery_code_version,
          recovery_configured_at,
          recovery_regenerated_at
        FROM security_settings
        WHERE id = 1
      ''',
      readsFrom: {},
    ).getSingleOrNull();

    return RecoveryMaterialStatus(
      exists: (row?.read<String>('recovery_code_hash') ?? '').isNotEmpty,
      version: row?.read<String>('recovery_code_version') ?? '',
      configuredAt: row?.read<String>('recovery_configured_at') ?? '',
      regeneratedAt: row?.read<String>('recovery_regenerated_at') ?? '',
    );
  }

  Future<CreateRecoveryMaterialResult> createInstallationRecoveryMaterial({
    required String actorType,
    int? actorUserId,
    bool regenerated = false,
    String details = '',
    String installContext = '',
  }) async {
    final generated = _recoveryCodec.generate();
    final now = DateTime.now().toIso8601String();

    await _db.customStatement(
      '''
        INSERT INTO security_settings (
          id,
          recovery_code_hash,
          recovery_code_salt,
          recovery_code_version,
          recovery_configured_at,
          recovery_regenerated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          recovery_code_hash = excluded.recovery_code_hash,
          recovery_code_salt = excluded.recovery_code_salt,
          recovery_code_version = excluded.recovery_code_version,
          recovery_regenerated_at = excluded.recovery_regenerated_at,
          recovery_configured_at = CASE
            WHEN security_settings.recovery_configured_at = ''
              THEN excluded.recovery_configured_at
            ELSE security_settings.recovery_configured_at
          END
      ''',
      [
        1,
        generated.hash,
        generated.salt,
        generated.version,
        now,
        regenerated ? now : '',
      ],
    );

    await writeAuthAuditEvent(
      eventType: regenerated
          ? 'recovery_material_regenerated'
          : 'recovery_material_created',
      actorType: actorType,
      actorUserId: actorUserId,
      result: 'SUCCESS',
      details: details,
      installContext: installContext,
    );

    return CreateRecoveryMaterialResult(
      plaintext: generated.plaintext,
      version: generated.version,
      createdAt: now,
    );
  }

  Future<bool> verifyInstallationRecoveryMaterial(String plaintext) async {
    final row = await _db.customSelect(
      '''
        SELECT
          recovery_code_hash,
          recovery_code_salt,
          recovery_code_version
        FROM security_settings
        WHERE id = 1
      ''',
      readsFrom: {},
    ).getSingleOrNull();
    if (row == null) return false;

    final hash = row.read<String>('recovery_code_hash');
    final salt = row.read<String>('recovery_code_salt');
    final version = row.read<String>('recovery_code_version');
    if (hash.isEmpty || salt.isEmpty || version.isEmpty) return false;

    return _recoveryCodec.verify(
      plaintext: plaintext,
      hash: hash,
      salt: salt,
      storedVersion: version,
    );
  }

  Future<void> writeAuthAuditEvent({
    required String eventType,
    required String actorType,
    required String result,
    int? actorUserId,
    int? targetUserId,
    String details = '',
    String installContext = '',
  }) {
    return _db.customStatement(
      '''
        INSERT INTO auth_audit_log (
          timestamp,
          event_type,
          actor_type,
          actor_user_id,
          target_user_id,
          result,
          details,
          install_context
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        DateTime.now().toIso8601String(),
        eventType,
        actorType,
        actorUserId,
        targetUserId,
        result,
        details,
        installContext,
      ],
    );
  }

  Future<List<AuthAuditEventRecord>> getLatestAuthAuditEvents({
    int limit = 50,
  }) async {
    final safeLimit = limit < 1 ? 1 : limit;
    final rows = await _db.customSelect(
      '''
        SELECT
          id,
          timestamp,
          event_type,
          actor_type,
          actor_user_id,
          target_user_id,
          result,
          details,
          install_context
        FROM auth_audit_log
        ORDER BY id DESC
        LIMIT $safeLimit
      ''',
      readsFrom: {},
    ).get();

    return rows
        .map(
          (row) => AuthAuditEventRecord(
            id: row.read<int>('id'),
            timestamp: row.read<String>('timestamp'),
            eventType: row.read<String>('event_type'),
            actorType: row.read<String>('actor_type'),
            actorUserId: row.read<int>('actor_user_id'),
            targetUserId: row.read<int>('target_user_id'),
            result: row.read<String>('result'),
            details: row.read<String>('details'),
            installContext: row.read<String>('install_context'),
          ),
        )
        .toList(growable: false);
  }

  String generateTemporaryPin() => _temporaryPinGenerator.generate();
}
