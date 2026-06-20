final class StockCatalogIdentity {
  const StockCatalogIdentity._();

  static const sandukV0StableId = 'opc_seed_sanduk_v0';
  static const legacySandukV0StableId =
      'opc_seed_sanduk_v0_legacy_placeholder';
  static const sandukV17PolukovcegStableId = 'opc_seed_sanduk_v17_polukovceg';

  static String? stableIdForSeedArticle({
    required String interniNazivKategorije,
    required String naziv,
  }) {
    return _seedStableArticleIds[_key(interniNazivKategorije, naziv)];
  }

  static String? canonicalStableIdForKnownLegacySeedReference({
    required String interniNazivKategorije,
    required String naziv,
    required String currentStableArticleId,
  }) {
    final canonical = stableIdForSeedArticle(
      interniNazivKategorije: interniNazivKategorije,
      naziv: naziv,
    );
    if (canonical == null) return null;

    final legacy = _legacySeedStableArticleIds[_key(
      interniNazivKategorije,
      naziv,
    )];
    if (legacy == null || currentStableArticleId.trim() != legacy) {
      return null;
    }
    return canonical;
  }

  static String _key(String interniNazivKategorije, String naziv) {
    return '${interniNazivKategorije.trim()}|${naziv.trim()}';
  }

  static const Map<String, String> _seedStableArticleIds = {
    'SANDUK|SANDUK V-0': sandukV0StableId,
    'SANDUK|SANDUK V-4': 'opc_seed_sanduk_v4',
    'SANDUK|SANDUK V-4 CVET': 'opc_seed_sanduk_v4_cvet',
    'SANDUK|SANDUK V-5 ELEGANCE': 'opc_seed_sanduk_v5_elegance',
    'SANDUK|SANDUK V-5 LJILJAN': 'opc_seed_sanduk_v5_ljiljan',
    'SANDUK|SANDUK V-5 CVEĆE': 'opc_seed_sanduk_v5_cvece',
    'SANDUK|SANDUK V-14 CVET POLUKOVČEG': 'opc_seed_sanduk_v14_cvet_polukovceg',
    'SANDUK|SANDUK V-15 POLUKOVČEG': 'opc_seed_sanduk_v15_polukovceg',
    'SANDUK|SANDUK V-16 CVEĆE POLUKOVČEG':
        'opc_seed_sanduk_v16_cvece_polukovceg',
    'SANDUK|SANDUK V-16 POLUKOVČEG': 'opc_seed_sanduk_v16_polukovceg',
    'SANDUK|SANDUK V-17 POLUKOVČEG': sandukV17PolukovcegStableId,
    'SANDUK|SANDUK V-18 POLUKOVČEG': 'opc_seed_sanduk_v18_polukovceg',
    'SANDUK|SANDUK V-19 KOVČEG': 'opc_seed_sanduk_v19_kovceg',
    'SANDUK|SANDUK V-20 KOVČEG': 'opc_seed_sanduk_v20_kovceg',
    'SANDUK|SANDUK V-21 KOVČEG': 'opc_seed_sanduk_v21_kovceg',
    'SANDUK|SANDUK V-ŠESTOUGAONI TV': 'opc_seed_sanduk_v_sestougaoni_tv',
    'SANDUK|SANDUK VH-22 POLUKOVČEG': 'opc_seed_sanduk_vh22_polukovceg',
    'SANDUK|SANDUK VH-PALMA POLUKOVČEG': 'opc_seed_sanduk_vh_palma_polukovceg',
    'SANDUK|SANDUK VH-AMER POLUKOVČEG': 'opc_seed_sanduk_vh_amer_polukovceg',
    'SANDUK|SANDUK VH-84 HRAST': 'opc_seed_sanduk_vh84_hrast',
    'SANDUK|SANDUK VH-87 KOVČEG': 'opc_seed_sanduk_vh87_kovceg',
    'SANDUK|SANDUK VH-JAMBO': 'opc_seed_sanduk_vh_jambo',
    'SANDUK|SANDUK VH-AMERIKAN': 'opc_seed_sanduk_vh_amerikan',
    'SANDUK|SANDUK V-BELI': 'opc_seed_sanduk_v_beli',
    'SANDUK|SANDUK V-BELI ŠESTOUGAONI': 'opc_seed_sanduk_v_beli_sestougaoni',
    'POKROV_GARNITURA|POKROV GARNITURA BELA': 'opc_seed_pokrov_garnitura_bela',
    'POKROV_GARNITURA|POKROV GARNITURA BRAON':
        'opc_seed_pokrov_garnitura_braon',
    'POKROV_GARNITURA|POKROV GARNITURA ST. ZLATO':
        'opc_seed_pokrov_garnitura_st_zlato',
    'POKROV_GARNITURA|POKROV GARNITURA KREM': 'opc_seed_pokrov_garnitura_krem',
    'POKROV_GARNITURA|POKROV GARNITURA BORDO':
        'opc_seed_pokrov_garnitura_bordo',
    'OBELEZJE|SVETOSAVSKI KRST Topola/Hrast':
        'opc_seed_obelezje_svetosavski_krst_topola_hrast',
    'OBELEZJE|KRST Topola/Bukva/Hrast':
        'opc_seed_obelezje_krst_topola_bukva_hrast',
    'OBELEZJE|PIRAMIDA': 'opc_seed_obelezje_piramida',
  };

  static const Map<String, String> _legacySeedStableArticleIds = {
    'SANDUK|SANDUK V-0': legacySandukV0StableId,
  };
}
