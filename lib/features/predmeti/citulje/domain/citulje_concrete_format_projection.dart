import '../../../../core/constants/iriu_constants.dart';
import '../../core_v2/services/iriu_display_name_resolver.dart';

/// Resolves the current user-facing ČITULJA format without changing the
/// persisted preparation identity. [articleType] remains the stable category
/// used by persistence and transfer; the current IRiU row supplies the
/// category-to-concrete display transition.
String resolveCituljeConcreteFormatDisplay({
  required String articleType,
  String? currentDisplayName,
}) {
  final categoryLabel = cituljaArticleDisplayValue(articleType);
  final storedName = currentDisplayName?.trim();
  if (storedName == null ||
      storedName.isEmpty ||
      _categoryDisplayNames(articleType, categoryLabel).contains(storedName)) {
    return categoryLabel;
  }

  final resolution = resolveIriuDisplayName(
    internalName: articleType,
    storedDisplayName: storedName,
  );
  final concreteDisplayName = resolution.displayName?.trim();
  return concreteDisplayName == null || concreteDisplayName.isEmpty
      ? categoryLabel
      : concreteDisplayName;
}

Set<String> _categoryDisplayNames(String articleType, String categoryLabel) => {
  articleType.trim(),
  categoryLabel,
  switch (articleType) {
    IriuK.cituljaP => 'Čitulja Politika',
    IriuK.cituljaNo => 'Čitulja Novosti',
    _ => '',
  },
  IriuK.naziviPrikaz[articleType]?.trim() ?? '',
}..remove('');

String cituljaArticleDisplayValue(String articleType) => switch (articleType) {
  IriuK.cituljaP => 'ČITULJA POLITIKA',
  IriuK.cituljaNo => 'ČITULJA NOVOSTI',
  _ => articleType.trim(),
};
