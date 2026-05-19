class AiPromptTemplate {
  final String id;
  final String title;
  final String roleContext;
  final String badgeLabel;
  final String promptTemplate;

  const AiPromptTemplate({
    required this.id,
    required this.title,
    required this.roleContext,
    required this.badgeLabel,
    required this.promptTemplate,
  });

  factory AiPromptTemplate.fromJson(Map<String, dynamic> json) {
    return AiPromptTemplate(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      roleContext: json['roleContext'] ?? '',
      badgeLabel: json['badgeLabel'] ?? '',
      promptTemplate: json['promptTemplate'] ?? '',
    );
  }
}
