import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "ai.welcome_msg".tr(),
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isTyping = false;

  void _handleSend([String? text]) {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;
    
    setState(() {
      _messages.add(_ChatMessage(
        text: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Mock response
    Future.delayed(1500.ms, () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: "This is a simulated AI response about: $messageText",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
              ).createShader(bounds),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Text('ai.title'.tr()),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _TypingIndicator();
                }
                final message = _messages[index];
                return _ChatBubble(message: message).animate().fadeIn().slideY(begin: 0.1, end: 0);
              },
            ),
          ),
          
          // Suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _SuggestionChip(label: 'ai.quick_market'.tr(), icon: Icons.trending_up_rounded, onTap: () => _handleSend('ai.quick_market'.tr())),
                const SizedBox(width: 8),
                _SuggestionChip(label: 'ai.quick_crop'.tr(), icon: Icons.agriculture_rounded, onTap: () => _handleSend('ai.quick_crop'.tr())),
                const SizedBox(width: 8),
                _SuggestionChip(label: 'ai.quick_weather'.tr(), icon: Icons.wb_sunny_outlined, onTap: () => _handleSend('ai.quick_weather'.tr())),
                const SizedBox(width: 8),
                _SuggestionChip(label: 'ai.quick_sell'.tr(), icon: Icons.sell_outlined, onTap: () => _handleSend('ai.quick_sell'.tr())),
              ],
            ),
          ),
          
          // Input Area
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, MediaQuery.of(context).padding.bottom + AppSpacing.md),
            child: _AIInput(
              controller: _controller,
              onSend: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
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
              child: Text(
                message.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isUser ? colors.onSurface : theme.textTheme.bodyLarge?.color,
                ),
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

  const _AIInput({required this.controller, required this.onSend});

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
              decoration: InputDecoration(
                hintText: 'ai.type_message'.tr(),
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: theme.textTheme.bodyLarge,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(onTap: onSend),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
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
