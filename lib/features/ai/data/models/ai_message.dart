class AiMessage {
  final String id;
  final String role; // "USER" | "ASSISTANT" | "SYSTEM"
  final String message;
  final int? responseTimeMs;
  final int? tokenUsage;
  final String? modelUsed;
  final DateTime createdAt;

  const AiMessage({
    required this.id,
    required this.role,
    required this.message,
    this.responseTimeMs,
    this.tokenUsage,
    this.modelUsed,
    required this.createdAt,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] ?? '',
      role: json['role'] ?? 'USER',
      message: json['message'] ?? '',
      responseTimeMs: json['responseTimeMs'],
      tokenUsage: json['tokenUsage'],
      modelUsed: json['modelUsed'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
