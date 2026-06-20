// ─────────────────────────────────────────────────────────────────────────────
// Konfiguracija build varijante
//
// Primarni hook je --dart-define=BUILD_VARIANT=<varijanta>.
// Ako je define prazan, nepoznat ili izostavljen, fallback namerno ostaje
// produkcijski bezbedan i ne sme aktivirati puni photo seed.
//
// Primeri:
//   PRODUCTION  -> bezbedan podrazumevani runtime bez full-photo seed-a
//   WINDOWS     -> postojece Windows release/specijalno ponasanje
//   WINDOWS_TEST -> eksplicitni Windows test runtime sa full-photo seed-om
//   ANDROID_TEST -> eksplicitni Android test runtime sa full-photo seed-om
// ─────────────────────────────────────────────────────────────────────────────

/// Naziv verzije koji se prikazuje u O APLIKACIJI tabu
const kAppVerzija = '4.0.0';

abstract final class AppBuildVariant {
  static const production = 'PRODUCTION';
  static const windowsTest = 'WINDOWS_TEST';
  static const androidTest = 'ANDROID_TEST';
  static const windows = 'WINDOWS';
}

const _kRequestedBuildVariant =
    String.fromEnvironment('BUILD_VARIANT', defaultValue: '');

final String kBuildVariant = switch (_kRequestedBuildVariant) {
  AppBuildVariant.production => AppBuildVariant.production,
  AppBuildVariant.windowsTest => AppBuildVariant.windowsTest,
  AppBuildVariant.androidTest => AppBuildVariant.androidTest,
  AppBuildVariant.windows => AppBuildVariant.windows,
  _ => AppBuildVariant.production,
};

const kFullPhotoCatalogSeedKategorije = <String>[
  'SANDUK',
  'OBELEZJE',
  'POKROV_GARNITURA',
  'CVECE',
  'CITULJA_POLITIKA',
  'CITULJA_NOVOSTI',
];

bool get kIsProductionBuild => kBuildVariant == AppBuildVariant.production;
bool get kIsWindowsBuild => kBuildVariant == AppBuildVariant.windows;
bool get kIsWindowsTestBuild => kBuildVariant == AppBuildVariant.windowsTest;
bool get kIsAndroidTestBuild => kBuildVariant == AppBuildVariant.androidTest;

// Asset packaging ostaje nepromenjeno u ovom tasku; ovde se samo hardenuje
// odluka da li je dozvoljen full bundled photo seed.
bool get kShouldSeedFullPhotoCatalog =>
    kIsWindowsTestBuild || kIsAndroidTestBuild;

String get kDatabaseName => switch (kBuildVariant) {
      AppBuildVariant.production => 'opc_v4_release',
      AppBuildVariant.windows => 'opc_v4_release',
      AppBuildVariant.windowsTest => 'opc_v4_windows_test',
      AppBuildVariant.androidTest => 'opc_v4_android_test',
      _ => 'opc_v4_release',
    };

/// Variant string za UI prikaz
String get kBuildVarijanta => switch (kBuildVariant) {
      AppBuildVariant.production => 'PRODUCTION',
      AppBuildVariant.windowsTest => 'WINDOWS TEST',
      AppBuildVariant.androidTest => 'ANDROID TEST',
      AppBuildVariant.windows => 'WINDOWS',
      _ => kBuildVariant,
    };
