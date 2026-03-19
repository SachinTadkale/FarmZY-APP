class AuthResponse {
  final String token;
  final String message;

  AuthResponse({required this.token, required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final auth = nestedData['auth'];
    final nestedAuth = auth is Map<String, dynamic> ? auth : <String, dynamic>{};

    return AuthResponse(
      token:
          (json['token'] ??
                  json['accessToken'] ??
                  json['access_token'] ??
                  nestedData['token'] ??
                  nestedData['accessToken'] ??
                  nestedData['access_token'] ??
                  nestedAuth['token'] ??
                  nestedAuth['accessToken'] ??
                  nestedAuth['access_token'] ??
                  '')
              .toString(),
      message:
          (json['message'] ?? nestedData['message'] ?? json['error'] ?? '')
              .toString(),
    );
  }
}
