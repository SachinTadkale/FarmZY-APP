class AiChatSession {
  final String id;
  final String roleContext;
  final String? title;
  final String? lastMessage;
  final String? language;
  final int totalMessages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiChatSession({
    required this.id,
    required this.roleContext,
    this.title,
    this.lastMessage,
    this.language,
    required this.totalMessages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AiChatSession.fromJson(Map<String, dynamic> json) {
    return AiChatSession(
      id: json['id'] ?? '',
      roleContext: json['roleContext'] ?? '',
      title: json['title'],
      lastMessage: json['lastMessage'],
      language: json['language'],
      totalMessages: json['totalMessages'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
