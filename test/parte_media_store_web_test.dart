import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:opc_v4/features/predmeti/parte/data/parte_media_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Web media persists in IndexedDB and staged deletion can restore or purge',
    () async {
      final source = Uint8List.fromList(
        img.encodePng(img.Image(width: 720, height: 960)),
      );
      final writer = ParteMediaStore();
      final imported = await writer.importBytes(
        sourceBytes: source,
        predmetBroj: 'SYNTHETIC-WEB-PARTE-001',
        kind: ParteMediaKind.photo,
      );
      expect(await writer.exists(imported.mediaKey), isTrue);
      final reopenedStore = ParteMediaStore();
      final persistedBytes = await reopenedStore.read(imported.mediaKey);
      expect(img.decodePng(persistedBytes), isNotNull);
      final rollback = await reopenedStore.stageOwnedDeletion(<String>[
        imported.mediaKey,
      ]);
      expect(await reopenedStore.exists(imported.mediaKey), isFalse);
      await rollback.restore();
      expect(await reopenedStore.exists(imported.mediaKey), isTrue);
      expect(
        img.decodePng(await reopenedStore.read(imported.mediaKey)),
        isNotNull,
      );

      final committed = await reopenedStore.stageOwnedDeletion(<String>[
        imported.mediaKey,
      ]);
      await committed.purge();
      expect(await reopenedStore.exists(imported.mediaKey), isFalse);
    },
    skip: !kIsWeb,
  );
}
