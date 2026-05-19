import 'dart:convert';
import 'package:farmzy/features/ai/data/models/ai_chat_session.dart';
import 'package:farmzy/features/ai/data/models/ai_message.dart';
import 'package:farmzy/features/ai/data/models/ai_prompt_template.dart';
import 'package:farmzy/features/ai/data/repositories/ai_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class AIChatState {
  final List<AiMessage> messages;
  final List<AiChatSession> sessions;
  final List<AiPromptTemplate> prompts;
  final String? currentSessionId;
  final bool isStreaming;
  final bool isLoading;

  const AIChatState({
    this.messages = const [],
    this.sessions = const [],
    this.prompts = const [],
    this.currentSessionId,
    this.isStreaming = false,
    this.isLoading = false,
  });

  AIChatState copyWith({
    List<AiMessage>? messages,
    List<AiChatSession>? sessions,
    List<AiPromptTemplate>? prompts,
    String? currentSessionId,
    bool? isStreaming,
    bool? isLoading,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      prompts: prompts ?? this.prompts,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isStreaming: isStreaming ?? this.isStreaming,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AIChatController extends StateNotifier<AIChatState> {
  final AIRepository _repository;

  AIChatController(this._repository) : super(const AIChatState());

  /// Load available dynamic prompt badges
  Future<void> loadPrompts() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.fetchPrompts();
      state = state.copyWith(prompts: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Load user active chat sessions
  Future<void> loadSessions() async {
    try {
      final data = await _repository.fetchSessions();
      state = state.copyWith(sessions: data);
    } catch (e) {
      // Safe ignore
    }
  }

  /// Load individual chat session history
  Future<void> loadSessionHistory(String sessionId) async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.fetchSessionHistory(sessionId);
      state = state.copyWith(
        messages: list,
        currentSessionId: sessionId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Reset to clean conversation room
  void startNewChat() {
    state = state.copyWith(
      messages: const [],
      currentSessionId: null,
    );
  }

  /// Soft delete conversation
  Future<void> deleteSession(String sessionId) async {
    try {
      final success = await _repository.deleteSession(sessionId);
      if (success) {
        loadSessions();
        if (state.currentSessionId == sessionId) {
          startNewChat();
        }
      }
    } catch (e) {
      // Safe ignore
    }
  }

  /// Submits dynamic badge and resolves context before auto-posting
  Future<void> handleBadgeSelection(AiPromptTemplate badge, String language) async {
    state = state.copyWith(isStreaming: true);
    try {
      // Create optimistic User query
      final userMessage = AiMessage(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        role: 'USER',
        message: badge.promptTemplate,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, userMessage]);

      // Resolve the actual context values (regional mandi, pincode, etc.)
      final resolvedPrompt = await _repository.resolveBadgePrompt(badge.badgeLabel, language);

      // Create optimistic Assistant answer placeholder
      final assistantMessageId = 'ai-${DateTime.now().millisecondsSinceEpoch}';
      final assistantPlaceholder = AiMessage(
        id: assistantMessageId,
        role: 'ASSISTANT',
        message: '',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, assistantPlaceholder]);

      // Read chunk-by-chunk
      final sseStream = _repository.submitChatPromptStream(
        resolvedPrompt.isNotEmpty ? resolvedPrompt : badge.promptTemplate,
        sessionId: state.currentSessionId,
        language: language,
      );

      await for (final rawData in sseStream) {
        try {
          final Map<String, dynamic> data = jsonDecode(rawData);
          
          if (data['error'] != null) {
            _updateLastMessageError(assistantMessageId, data['error'].toString());
            break;
          }

          if (data['chunk'] != null) {
            final chunkText = data['chunk'].toString();
            state = state.copyWith(
              messages: state.messages.map((msg) {
                if (msg.id == assistantMessageId) {
                  return AiMessage(
                    id: msg.id,
                    role: msg.role,
                    message: msg.message + chunkText,
                    modelUsed: msg.modelUsed,
                    tokenUsage: msg.tokenUsage,
                    responseTimeMs: msg.responseTimeMs,
                    createdAt: msg.createdAt,
                  );
                }
                return msg;
              }).toList(),
            );
          }

          if (data['done'] == true) {
            final finalSessionId = data['sessionId']?.toString();
            state = state.copyWith(
              currentSessionId: finalSessionId,
              isStreaming: false,
            );
            loadSessions();
            break;
          }
        } catch (jsonErr) {
          // JSON parsing of partial boundary, safe skip
        }
      }
    } catch (e) {
      state = state.copyWith(isStreaming: false);
    }
  }

  /// Sends a raw text message via stream
  Future<void> sendMessage(String text, String language) async {
    if (text.trim().isEmpty || state.isStreaming) return;
    
    state = state.copyWith(isStreaming: true);
    
    final userMessage = AiMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: 'USER',
      message: text,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, userMessage]);

    final assistantMessageId = 'ai-${DateTime.now().millisecondsSinceEpoch}';
    final assistantPlaceholder = AiMessage(
      id: assistantMessageId,
      role: 'ASSISTANT',
      message: '',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, assistantPlaceholder]);

    try {
      final sseStream = _repository.submitChatPromptStream(
        text,
        sessionId: state.currentSessionId,
        language: language,
      );

      await for (final rawData in sseStream) {
        try {
          final Map<String, dynamic> data = jsonDecode(rawData);

          if (data['error'] != null) {
            _updateLastMessageError(assistantMessageId, data['error'].toString());
            break;
          }

          if (data['chunk'] != null) {
            final chunkText = data['chunk'].toString();
            state = state.copyWith(
              messages: state.messages.map((msg) {
                if (msg.id == assistantMessageId) {
                  return AiMessage(
                    id: msg.id,
                    role: msg.role,
                    message: msg.message + chunkText,
                    modelUsed: msg.modelUsed,
                    tokenUsage: msg.tokenUsage,
                    responseTimeMs: msg.responseTimeMs,
                    createdAt: msg.createdAt,
                  );
                }
                return msg;
              }).toList(),
            );
          }

          if (data['done'] == true) {
            final finalSessionId = data['sessionId']?.toString();
            state = state.copyWith(
              currentSessionId: finalSessionId,
              isStreaming: false,
            );
            loadSessions();
            break;
          }
        } catch (jsonErr) {
          // JSON parsing of partial boundary, safe skip
        }
      }
    } catch (e) {
      _updateLastMessageError(assistantMessageId, 'Error connecting to streaming server');
      state = state.copyWith(isStreaming: false);
    }
  }

  void _updateLastMessageError(String messageId, String errorMessage) {
    state = state.copyWith(
      isStreaming: false,
      messages: state.messages.map((msg) {
        if (msg.id == messageId) {
          return AiMessage(
            id: msg.id,
            role: msg.role,
            message: 'Error: $errorMessage',
            createdAt: msg.createdAt,
          );
        }
        return msg;
      }).toList(),
    );
  }
}

final aiChatControllerProvider = StateNotifierProvider<AIChatController, AIChatState>((ref) {
  return AIChatController(ref.watch(aiRepositoryProvider));
});
