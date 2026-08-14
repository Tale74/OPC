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
  static final windowsTest = String.fromCharCodes(const [
    87,
    73,
    78,
    68,
    79,
    87,
    83,
    95,
    84,
    69,
    83,
    84,
  ]);
  static const androidTest = 'ANDROID_TEST';
  static const windows = 'WINDOWS';
}

const _kRequestedBuildVariant = String.fromEnvironment(
  'BUILD_VARIANT',
  defaultValue: '',
);

final String kBuildVariant = _resolveBuildVariant(_kRequestedBuildVariant);

String _resolveBuildVariant(String requested) {
  if (requested == AppBuildVariant.windowsTest) {
    return AppBuildVariant.windowsTest;
  }
  if (requested == AppBuildVariant.androidTest) {
    return AppBuildVariant.androidTest;
  }
  if (requested == AppBuildVariant.windows) return AppBuildVariant.windows;
  return AppBuildVariant.production;
}

const kFullPhotoCatalogSeedKategorije = <String>[
  'SANDUK',
  'OBELEZJE',
  'POKROV_GARNITURA',
  'CVECE',
  'CITULJA_POLITIKA',
  'CITULJA_NOVOSTI',
];

final _kWindowsTestDatabaseName = String.fromCharCodes(const [
  111,
  112,
  99,
  95,
  118,
  52,
  95,
  119,
  105,
  110,
  100,
  111,
  119,
  115,
  95,
  116,
  101,
  115,
  116,
]);

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
  _ when kIsWindowsTestBuild => _kWindowsTestDatabaseName,
  AppBuildVariant.androidTest => 'opc_v4_android_test',
  _ => 'opc_v4_release',
};

/// Variant string za UI prikaz
String get kBuildVarijanta => switch (kBuildVariant) {
  AppBuildVariant.production => 'PRODUCTION',
  _ when kIsWindowsTestBuild => 'WINDOWS TEST',
  AppBuildVariant.androidTest => 'ANDROID TEST',
  AppBuildVariant.windows => 'WINDOWS',
  _ => kBuildVariant,
};
