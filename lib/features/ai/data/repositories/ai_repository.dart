import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:farmzy/core/network/dio_provider.dart';
import 'package:farmzy/features/ai/data/models/ai_chat_session.dart';
import 'package:farmzy/features/ai/data/models/ai_message.dart';
import 'package:farmzy/features/ai/data/models/ai_prompt_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIRepository {
  final Dio _dio;

  AIRepository(this._dio);

  /// Fetch dynamic quick badges by role
  Future<List<AiPromptTemplate>> fetchPrompts() async {
    try {
      final response = await _dio.get('/ai/prompts');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => AiPromptTemplate.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Resolve dynamic contextual badge template content
  Future<String> resolveBadgePrompt(String badgeLabel, String language) async {
    try {
      final response = await _dio.post(
        '/ai/badge-prompt',
        data: {
          'badgeLabel': badgeLabel,
          'language': language,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['resolvedPrompt'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Fetch active sessions for a user
  Future<List<AiChatSession>> fetchSessions() async {
    try {
      final response = await _dio.get('/ai/sessions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => AiChatSession.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get historical details and messages of an individual session
  Future<List<AiMessage>> fetchSessionHistory(String sessionId) async {
    try {
      final response = await _dio.get('/ai/sessions/$sessionId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data']['messages'] as List<dynamic>;
        return list.map((e) => AiMessage.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Soft delete a chat session
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _dio.delete('/ai/sessions/$sessionId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Submits prompt to the SSE endpoint and emits raw chunk strings.
  Stream<String> submitChatPromptStream(
    String message, {
    String? sessionId,
    required String language,
  }) async* {
    final response = await _dio.post(
      '/ai/chat?stream=true',
      data: {
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
        'language': language,
      },
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data!.stream as Stream<Uint8List>;
    var buffer = '';

    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      buffer += text;

      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // Keep trailing partial chunk

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('data: ')) {
          final dataStr = trimmed.substring(6);
          yield dataStr;
        }
      }
    }
  }
}

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(ref.watch(dioProvider));
});
