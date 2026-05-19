import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/features/ai/data/models/ai_message.dart';
import 'package:farmzy/features/ai/presentation/controllers/ai_controller.dart';
import 'package:farmzy/features/ai/presentation/screens/ai_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIScreen extends ConsumerStatefulWidget {
  const AIScreen({super.key});

  @override
  ConsumerState<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends ConsumerState<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiChatControllerProvider.notifier).loadPrompts();
      ref.read(aiChatControllerProvider.notifier).loadSessions();
    });
  }

  void _handleSend() {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) return;
    
    _controller.clear();
    final lang = context.locale.languageCode;
    
    ref.read(aiChatControllerProvider.notifier).sendMessage(messageText, lang);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(aiChatControllerProvider);

    // Auto-scroll on dynamic streaming chunks
    if (state.isStreaming) {
      _scrollToBottom();
    }

    return AppScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
              ).createShader(bounds),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Text('ai.title'.tr().isNotEmpty && 'ai.title'.tr() != 'ai.title' ? 'ai.title'.tr() : 'Saira Ai'),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AIHistoryScreen()),
              );
            },
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              ref.read(aiChatControllerProvider.notifier).startNewChat();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New chat session started'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading spinner
          if (state.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.messages.isEmpty)
            // Welcome screen with options
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.stars_rounded, size: 48, color: colors.primary),
                      ).animate().scale(duration: 400.ms),
                      const SizedBox(height: 18),
                      Text(
                        'ai.welcome_title'.tr().isNotEmpty && 'ai.welcome_title'.tr() != 'ai.welcome_title'
                            ? 'ai.welcome_title'.tr()
                            : 'How can I help you today?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ai.welcome_subtitle'.tr().isNotEmpty && 'ai.welcome_subtitle'.tr() != 'ai.welcome_subtitle'
                            ? 'ai.welcome_subtitle'.tr()
                            : 'Ask regarding biological crop health, mandi rates, biological fertilizers, or delivery route plans.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Main Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
                    return const _TypingIndicator();
                  }
                  final message = state.messages[index];
                  return _ChatBubble(message: message).animate().fadeIn().slideY(begin: 0.05, end: 0);
                },
              ),
            ),

          // Suggestion badges scrollbar
          if (state.prompts.isNotEmpty && !state.isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: state.prompts.map((badge) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _SuggestionChip(
                      label: badge.badgeLabel,
                      icon: Icons.stars_rounded,
                      onTap: () {
                        ref.read(aiChatControllerProvider.notifier).handleBadgeSelection(
                          badge,
                          context.locale.languageCode,
                        );
                        _scrollToBottom();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          // Input Area
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            child: _AIInput(
              controller: _controller,
              onSend: _handleSend,
              onStop: () {
                ref.read(aiChatControllerProvider.notifier).stopStreaming();
              },
              isStreaming: state.isStreaming,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.role == 'USER';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                ),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GlassContainer(
              customBorderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              opacity: isUser ? 0.15 : 0.08,
              color: isUser ? colors.primary : colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? Text(
                          message.message,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                          ),
                        )
                      : MarkdownText(
                          text: message.message,
                          style: theme.textTheme.bodyLarge,
                        ),
                  if (!isUser && message.modelUsed != null) ...[
                    const SizedBox(height: 4),
                    const Divider(height: 4, thickness: 0.5, color: Colors.white12),
                    const SizedBox(height: 2),
                    Text(
                      message.modelUsed!.split('/').last.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 32),
          if (!isUser) const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: GlassContainer(
        borderRadius: 99,
        opacity: 0.06,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final bool isStreaming;

  const _AIInput({
    required this.controller,
    required this.onSend,
    required this.onStop,
    required this.isStreaming,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GlassContainer(
      borderRadius: AppRadius.card,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: true,
              decoration: InputDecoration(
                hintText: isStreaming ? 'Saira is typing...' : 'ai.type_message'.tr().isNotEmpty && 'ai.type_message'.tr() != 'ai.type_message' ? 'ai.type_message'.tr() : 'Ask Saira Ai...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: theme.textTheme.bodyLarge,
              onSubmitted: (_) => isStreaming ? null : onSend(),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            onTap: isStreaming ? onStop : onSend,
            isStreaming: isStreaming,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isStreaming;
  const _SendButton({required this.onTap, required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isStreaming 
                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                : const [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: (isStreaming ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isStreaming ? Icons.stop_rounded : Icons.send_rounded, 
          color: Colors.white, 
          size: 22,
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
              ),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          GlassContainer(
            customBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
            opacity: 0.08,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot().animate(onPlay: (c) => c.repeat()).fade(duration: 400.ms, begin: 0.2, end: 1).then().fade(duration: 400.ms, begin: 1, end: 0.2),
                const SizedBox(width: 4),
                _Dot().animate(onPlay: (c) => c.repeat(), delay: 200.ms).fade(duration: 400.ms, begin: 0.2, end: 1).then().fade(duration: 400.ms, begin: 1, end: 0.2),
                const SizedBox(width: 4),
                _Dot().animate(onPlay: (c) => c.repeat(), delay: 400.ms).fade(duration: 400.ms, begin: 0.2, end: 1).then().fade(duration: 400.ms, begin: 1, end: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final lines = text.split('\n');
    final children = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        if (i < lines.length - 1) {
          children.add(const SizedBox(height: 6));
        }
        continue;
      }

      if (trimmed.startsWith('###')) {
        final content = trimmed.substring(3).trim();
        children.add(Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 3.0),
          child: Text(
            content,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ));
        continue;
      }
      if (trimmed.startsWith('##')) {
        final content = trimmed.substring(2).trim();
        children.add(Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            content,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ));
        continue;
      }
      if (trimmed.startsWith('#')) {
        final content = trimmed.substring(1).trim();
        children.add(Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
          child: Text(
            content,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ));
        continue;
      }

      final isBullet = trimmed.startsWith('- ') || trimmed.startsWith('* ') || trimmed.startsWith('• ');
      var cleanText = trimmed;
      if (isBullet) {
        cleanText = trimmed.substring(2).trim();
      }

      final spans = <InlineSpan>[];
      final parts = cleanText.split(RegExp(r'(\*\*|`)'));
      var isBold = false;
      var isCode = false;

      for (final part in parts) {
        if (part == '**') {
          isBold = !isBold;
          continue;
        }
        if (part == '`') {
          isCode = !isCode;
          continue;
        }

        if (isBold) {
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ));
        } else if (isCode) {
          spans.add(TextSpan(
            text: part,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              backgroundColor: Colors.white12,
              color: const Color(0xFFF472B6),
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: part,
            style: style ?? theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.9),
            ),
          ));
        }
      }

      if (isBullet) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0, top: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(children: spans),
                ),
              ),
            ],
          ),
        ));
      } else {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
