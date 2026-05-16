class HelpArticle {
  final String id;
  final String categoryId;
  final String titleKey;
  final String descriptionKey;
  final List<String> contentKeys;
  final List<String> stepKeys;
  final List<String> faqKeys;
  final String icon;

  const HelpArticle({
    required this.id,
    required this.categoryId,
    required this.titleKey,
    required this.descriptionKey,
    required this.contentKeys,
    this.stepKeys = const [],
    this.faqKeys = const [],
    this.icon = 'help_outline_rounded',
  });
}

class HelpCategory {
  final String id;
  final String titleKey;
  final String icon;
  final String color;

  const HelpCategory({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
  });
}
