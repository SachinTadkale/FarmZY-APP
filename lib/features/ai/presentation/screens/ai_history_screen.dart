import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/core/theme/app_radius.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/features/ai/presentation/controllers/ai_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIHistoryScreen extends ConsumerWidget {
  const AIHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(aiChatControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text('ai.history_title'.tr().isNotEmpty ? 'ai.history_title'.tr() : 'AI Chat History'),
        backgroundColor: Colors.transparent,
      ),
      body: state.sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: colors.onSurface.withValues(alpha: 0.25)),
                  const SizedBox(height: 16),
                  Text(
                    'ai.no_sessions'.tr().isNotEmpty ? 'ai.no_sessions'.tr() : 'No conversation history found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Dismissible(
                    key: Key(session.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      ref.read(aiChatControllerProvider.notifier).deleteSession(session.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ai.deleted_success'.tr().isNotEmpty 
                              ? 'ai.deleted_success'.tr() 
                              : 'Conversation deleted'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                    ),
                    child: InkWell(
                      onTap: () {
                        ref.read(aiChatControllerProvider.notifier).loadSessionHistory(session.id);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: GlassContainer(
                        borderRadius: AppRadius.card,
                        opacity: state.currentSessionId == session.id ? 0.15 : 0.06,
                        color: state.currentSessionId == session.id ? colors.primary : colors.surface,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary.withValues(alpha: 0.1),
                              ),
                              child: Icon(Icons.chat_bubble_outline_rounded, color: colors.primary, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title ?? 'AI Chat session',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.lastMessage ?? 'No messages yet',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.chevron_right_rounded, color: colors.primary.withValues(alpha: 0.6)),
                                const SizedBox(height: 6),
                                Text(
                                  '${session.totalMessages} msgs',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
