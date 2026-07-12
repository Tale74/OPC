import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opc_v4/core/database/database.dart';
import 'package:opc_v4/core/entitlements/opc_entitlement_policy.dart';
import 'package:opc_v4/core/entitlements/opc_runtime_entitlement_resolver.dart';
import 'package:opc_v4/features/auth/data/auth_repository.dart';

void main() {
  group('Windows Administrator persistence incident audit', () {
    test(
      'file-backed database preserves synthetic Administrator across reopen',
      () async {
        final dbFile = await _temporaryDatabaseFile();

        var db = AppDatabase.forTesting(NativeDatabase(dbFile));
        var authRepo = AuthRepository(db);

        expect(await authRepo.hasKorisnika(), isFalse);

        final admin = await authRepo.kreirajPrvogAdmina(
          imePrezime: 'AUDIT ADMINISTRATOR',
          pin: '2468',
        );
        expect(admin.uloga, 'ADMINISTRATOR');
        expect(await authRepo.sviKorisnici(samoAktivni: true), hasLength(1));
        await db.close();

        for (var cycle = 1; cycle <= 3; cycle += 1) {
          db = AppDatabase.forTesting(NativeDatabase(dbFile));
          authRepo = AuthRepository(db);

          final activeUsers = await authRepo.sviKorisnici(samoAktivni: true);
          expect(
            activeUsers.map((user) => user.imePrezime),
            contains('AUDIT ADMINISTRATOR'),
            reason:
                'synthetic Administrator must persist on reopen cycle $cycle',
          );
          expect(
            activeUsers.where((user) => user.imePrezime == 'TEST'),
            isEmpty,
            reason: 'TEST must not be created by database open cycle $cycle',
          );
          expect(await authRepo.aktivniAdministratori(), hasLength(1));
          expect(
            await authRepo.prijavaKorisnikPin(activeUsers.single.id, '2468'),
            isNotNull,
          );

          await db.close();
        }
      },
    );

    test(
      'presentation entitlement resolver does not mutate user rows',
      () async {
        final dbFile = await _temporaryDatabaseFile();
        final db = AppDatabase.forTesting(NativeDatabase(dbFile));
        addTearDown(db.close);
        final authRepo = AuthRepository(db);

        await authRepo.kreirajPrvogAdmina(
          imePrezime: 'AUDIT PRESENTATION ADMIN',
          pin: '1357',
        );
        final before = await authRepo.sviKorisnici(samoAktivni: true);

        final policy = await const OpcRuntimeEntitlementResolver(
          developmentPotpunActive: true,
        ).resolve();

        final after = await authRepo.sviKorisnici(samoAktivni: true);
        expect(policy.packageLevel, OpcPackageLevel.potpun);
        expect(policy.sourceKind, OpcEntitlementSourceKind.presentationOwner);
        expect(
          after.map((user) => user.imePrezime),
          before.map((user) => user.imePrezime),
        );
        expect(after.single.imePrezime, 'AUDIT PRESENTATION ADMIN');
      },
    );
  });
}

Future<File> _temporaryDatabaseFile() async {
  final directory = await Directory.systemTemp.createTemp(
    'opc_admin_persistence_audit_',
  );
  addTearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  return File('${directory.path}${Platform.pathSeparator}audit.sqlite');
}
