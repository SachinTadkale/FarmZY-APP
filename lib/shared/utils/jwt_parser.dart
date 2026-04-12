import 'dart:convert';

class JwtParser {
  static Map<String, String?> parse(String token) {
    try {
      final segments = token.split('.');
      if (segments.length < 2) {
        return const {};
      }

      final normalized = base64Url.normalize(segments[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);

      if (payload is! Map<String, dynamic>) {
        return const {};
      }

      return {
        'userId': payload['userId']?.toString(),
        'role': payload['role']?.toString(),
        'actorType': payload['actorType']?.toString(),
      };
    } catch (_) {
      return const {};
    }
  }
}
