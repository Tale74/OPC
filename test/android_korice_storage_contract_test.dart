import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android KORICE storage contract', () {
    late String manifest;
    late String activity;
    late String dartExport;
    late String docxExport;

    setUpAll(() {
      manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      activity = File(
        'android/app/src/main/kotlin/com/tale/opc_v4/MainActivity.kt',
      ).readAsStringSync();
      dartExport = File('lib/core/utils/export_utils.dart').readAsStringSync();
      docxExport = File(
        'lib/features/predmeti/parte/docx/parte_docx_exporter.dart',
      ).readAsStringSync();
    });

    test('legacy write permission is limited to API 28', () {
      expect(manifest, contains('WRITE_EXTERNAL_STORAGE'));
      expect(manifest, contains('android:maxSdkVersion="28"'));
      expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
      expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
    });

    test('API 29+ uses MediaStore Downloads/KORICE', () {
      expect(activity, contains('Build.VERSION_CODES.Q'));
      expect(activity, contains('MediaStore.Downloads.EXTERNAL_CONTENT_URI'));
      expect(activity, contains('Environment.DIRECTORY_DOWNLOADS}/KORICE/'));
      expect(activity, contains('MediaStore.Downloads.IS_PENDING'));
    });

    test(
      'legacy denial and direct-write failure have a system picker retry',
      () {
        expect(activity, contains('requestPermissions'));
        expect(activity, contains('permission_denied'));
        expect(activity, contains('permission_permanently_denied'));
        expect(activity, contains('Intent.ACTION_CREATE_DOCUMENT'));
        expect(activity, contains('destination_cancelled'));
        expect(activity, contains('write_failed'));
        expect(dartExport, contains("'ensureKoriceAccess'"));
        expect(dartExport, contains("'saveDocumentWithSystemPicker'"));
      },
    );

    test('PDF and DOCX share verified document-save implementation', () {
      expect(dartExport, contains("mimeType: 'application/pdf'"));
      expect(dartExport, contains('_sacuvajAndroidKoriceDokument('));
      expect(
        docxExport,
        contains(
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ),
      );
      expect(dartExport, contains('Android izvoz nije potvrdio'));
    });
  });
}
