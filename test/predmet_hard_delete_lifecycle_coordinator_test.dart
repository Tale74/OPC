import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/features/predmeti/application/predmet_hard_delete_coordinator.dart';
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';
import 'package:opc_v4/features/predmeti/reminders/ceremony_notification_gateway.dart';

import 'test_bootstrap.dart';

void main() {
  group('RI-2 PREDMET hard-delete lifecycle coordinator', () {
    test(
      'deletes every PREDMET child, scoped reminder IDs and exclusive media',
      () async {
        final fixture = await _Fixture.create();
        addTearDown(fixture.dispose);
        final target = await fixture.insertPredmet('RI2-DELETE-001/2026');
        final other = await fixture.insertPredmet('RI2-KEEP-001/2026');
        await fixture.insertAllDependencies(
          target,
          reminderIds: '[51001,51002]',
          photoKey: 'target/exclusive.png',
          symbolKey: 'shared/symbol.png',
        );
        await fixture.insertParte(
          other,
          photoKey: 'shared/symbol.png',
          symbolKey: null,
        );
        await fixture.writeMedia('target/exclusive.png');
        await fixture.writeMedia('shared/symbol.png');

        await fixture.coordinator.deletePredmet(target);

        expect(await fixture.predmetExists(target), isFalse);
        expect(await fixture.predmetExists(other), isTrue);
        expect(await fixture.dependentCount(target), 0);
        expect(await fixture.foreignKeyViolations(), isEmpty);
        expect(fixture.gateway.cancelledIds, [51001, 51002]);
        expect(await fixture.mediaExists('target/exclusive.png'), isFalse);
        expect(await fixture.mediaExists('shared/symbol.png'), isTrue);
      },
    );

    test(
      'database failure restores staged media and reschedules reminder state',
      () async {
        final fixture = await _Fixture.create();
        addTearDown(fixture.dispose);
        final target = await fixture.insertPredmet(
          'RI2-ROLLBACK-001/2026',
          ceremonyDate: '30.07.2099',
          ceremonyTime: '12:00',
        );
        await fixture.insertAllDependencies(
          target,
          reminderIds: '[52001]',
          photoKey: 'rollback/exclusive.png',
          symbolKey: null,
        );
        await fixture.writeMedia('rollback/exclusive.png');
        await fixture.db.customStatement('''
          CREATE TRIGGER ri2_fail_predmet_delete
          BEFORE DELETE ON predmeti
          BEGIN
            SELECT RAISE(ABORT, 'synthetic RI-2 delete failure');
          END
        ''');

        await expectLater(
          fixture.coordinator.deletePredmet(target),
          throwsA(anything),
        );

        expect(await fixture.predmetExists(target), isTrue);
        expect(await fixture.dependentCount(target), greaterThan(0));
        expect(await fixture.mediaExists('rollback/exclusive.png'), isTrue);
        expect(fixture.gateway.cancelledIds, contains(52001));
        expect(fixture.gateway.scheduledIds, isNotEmpty);
        expect(await fixture.foreignKeyViolations(), isEmpty);
      },
    );

    test(
      'notification cancellation failure leaves database and media intact',
      () async {
        final gateway = _FakeNotificationGateway(failNextCancel: true);
        final fixture = await _Fixture.create(gateway: gateway);
        addTearDown(fixture.dispose);
        final target = await fixture.insertPredmet(
          'RI2-CANCEL-FAIL-001/2026',
          ceremonyDate: '30.07.2099',
          ceremonyTime: '12:00',
        );
        await fixture.insertAllDependencies(
          target,
          reminderIds: '[53001]',
          photoKey: 'cancel-failure/exclusive.png',
          symbolKey: null,
        );
        await fixture.writeMedia('cancel-failure/exclusive.png');

        await expectLater(
          fixture.coordinator.deletePredmet(target),
          throwsA(anything),
        );

        expect(await fixture.predmetExists(target), isTrue);
        expect(await fixture.dependentCount(target), greaterThan(0));
        expect(
          await fixture.mediaExists('cancel-failure/exclusive.png'),
          isTrue,
        );
        expect(gateway.scheduledIds, isNotEmpty);
        expect(await fixture.foreignKeyViolations(), isEmpty);
      },
    );
  });
}

class _Fixture {
  _Fixture._({
    required this.db,
    required this.root,
    required this.gateway,
    required this.mediaStore,
    required this.coordinator,
  });

  final AppDatabase db;
  final Directory root;
  final _FakeNotificationGateway gateway;
  final ParteMediaStore mediaStore;
  final PredmetHardDeleteCoordinator coordinator;

  static Future<_Fixture> create({_FakeNotificationGateway? gateway}) async {
    final db = createTestDatabase();
    final root = await Directory.systemTemp.createTemp('opc-ri2-hard-delete-');
    final resolvedGateway = gateway ?? _FakeNotificationGateway();
    final mediaStore = ParteMediaStore(rootDirectory: () async => root);
    return _Fixture._(
      db: db,
      root: root,
      gateway: resolvedGateway,
      mediaStore: mediaStore,
      coordinator: PredmetHardDeleteCoordinator(
        db: db,
        notificationGateway: resolvedGateway,
        mediaStore: mediaStore,
      ),
    );
  }

  Future<void> dispose() async {
    await db.close();
    if (await root.exists()) await root.delete(recursive: true);
  }

  Future<int> insertPredmet(
    String broj, {
    String ceremonyDate = '',
    String ceremonyTime = '',
  }) {
    return db
        .into(db.predmeti)
        .insert(
          PredmetiCompanion.insert(
            brojPredmeta: Value(broj),
            datumKreiranja: const Value('2026-07-30T14:00:00.000'),
            ime: const Value('Sinteticki'),
            prezime: const Value('Predmet'),
            vrstaCeremonije: const Value('SAHRANA'),
            datumCeremonije: Value(ceremonyDate),
            vremeCeremonije: Value(ceremonyTime),
          ),
        );
  }

  Future<void> insertAllDependencies(
    int predmetId, {
    required String reminderIds,
    required String? photoKey,
    required String? symbolKey,
  }) async {
    await db.customStatement(
      'INSERT INTO kontakt_lica '
      '(predmet_id, blok, ime_prezime) VALUES (?, ?, ?)',
      [predmetId, 'NARU_OPREMA', 'Sinteticki kontakt'],
    );
    final iriuId = await db.customInsert(
      'INSERT INTO iriu '
      '(predmet_id, interni_naziv, naziv_prikaz, kom, iznos, redosled) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withInt(predmetId),
        Variable.withString('SANDUK'),
        Variable.withString('Sanduk'),
        Variable.withString('1'),
        Variable.withReal(0),
        Variable.withInt(0),
      ],
    );
    await db.customStatement(
      'INSERT INTO iriu_lifecycle_decisions '
      '(predmet_id, interni_naziv, scope_key, decision_key, created_at) '
      'VALUES (?, ?, ?, ?, ?)',
      [predmetId, 'SANDUK', 'ri2-test', 'KEEP', '2026-07-30T14:00:00.000'],
    );
    await db.customStatement(
      'INSERT INTO log_izmena '
      '(predmet_id, korisnik_id, datum_vreme, polje) VALUES (?, ?, ?, ?)',
      [predmetId, 1, '2026-07-30T14:00:00.000', 'ri2-test'],
    );
    await db.customStatement(
      'INSERT INTO stanje_robe_posledice '
      '(predmet_id, iriu_id, kategorija, katalog_stable_article_id, '
      'selected_naziv_snapshot, consequence_type, status, created_at, '
      'updated_at, source_lifecycle_event) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        predmetId,
        iriuId,
        'SANDUK',
        'ri2-stable-id',
        'Sanduk',
        'INSUFFICIENT_STOCK',
        'UNRESOLVED',
        '2026-07-30T14:00:00.000',
        '2026-07-30T14:00:00.000',
        'RI2_TEST',
      ],
    );
    await db.customStatement(
      'INSERT INTO ceremony_reminder_settings '
      '(predmet_id, enabled, delivery_times, scheduled_notification_ids, '
      'updated_at) VALUES (?, 1, ?, ?, ?)',
      [predmetId, '["09:00"]', reminderIds, '2026-07-30T14:00:00.000'],
    );
    await insertParte(predmetId, photoKey: photoKey, symbolKey: symbolKey);
  }

  Future<void> insertParte(
    int predmetId, {
    required String? photoKey,
    required String? symbolKey,
  }) {
    return db.customStatement(
      'INSERT INTO parte_pripreme '
      '(predmet_id, predmet_broj, status, created_at, updated_at, '
      'source_fingerprint, template_id, template_snapshot_json, draft_json, '
      'photo_media_key, custom_symbol_media_key) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        predmetId,
        'RI2-$predmetId',
        'COMPLETED',
        '2026-07-30T14:00:00.000',
        '2026-07-30T14:00:00.000',
        'ri2-fingerprint',
        'ri2-template',
        '{}',
        '{}',
        photoKey,
        symbolKey,
      ],
    );
  }

  Future<void> writeMedia(String key) async {
    final file = File(p.join(root.path, p.fromUri(key)));
    await file.parent.create(recursive: true);
    await file.writeAsBytes([1, 2, 3], flush: true);
  }

  Future<bool> mediaExists(String key) =>
      File(p.join(root.path, p.fromUri(key))).exists();

  Future<bool> predmetExists(int predmetId) async {
    final row = await (db.select(
      db.predmeti,
    )..where((item) => item.id.equals(predmetId))).getSingleOrNull();
    return row != null;
  }

  Future<int> dependentCount(int predmetId) async {
    const tables = [
      'kontakt_lica',
      'iriu',
      'iriu_lifecycle_decisions',
      'log_izmena',
      'parte_pripreme',
      'stanje_robe_posledice',
      'ceremony_reminder_settings',
    ];
    var count = 0;
    for (final table in tables) {
      final row = await db
          .customSelect(
            'SELECT COUNT(*) AS row_count FROM $table WHERE predmet_id = ?',
            variables: [Variable.withInt(predmetId)],
          )
          .getSingle();
      count += row.read<int>('row_count');
    }
    return count;
  }

  Future<List<QueryRow>> foreignKeyViolations() =>
      db.customSelect('PRAGMA foreign_key_check').get();
}

class _FakeNotificationGateway implements CeremonyNotificationGateway {
  _FakeNotificationGateway({this.failNextCancel = false});

  bool failNextCancel;
  final List<int> cancelledIds = [];
  final List<int> scheduledIds = [];

  @override
  Future<void> initialize({required bool requestPermission}) async {}

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    if (failNextCancel) {
      failNextCancel = false;
      throw StateError('synthetic notification cancellation failure');
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduledIds.add(id);
  }
}
