import 'package:farmzy/features/help/data/models/help_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final helpCategoriesProvider = Provider<List<HelpCategory>>((ref) {
  return const [
    HelpCategory(
      id: 'gs',
      titleKey: 'help.getting_started',
      icon: 'rocket_launch_rounded',
      color: '0xFF6366F1',
    ),
    HelpCategory(
      id: 'market',
      titleKey: 'help.marketplace',
      icon: 'storefront_rounded',
      color: '0xFF10B981',
    ),
    HelpCategory(
      id: 'sell',
      titleKey: 'help.selling',
      icon: 'shopping_cart_rounded',
      color: '0xFFF59E0B',
    ),
    HelpCategory(
      id: 'orders',
      titleKey: 'help.orders',
      icon: 'payments_rounded',
      color: '0xFFEC4899',
    ),
    HelpCategory(
      id: 'delivery',
      titleKey: 'help.delivery',
      icon: 'local_shipping_rounded',
      color: '0xFF3B82F6',
    ),
    HelpCategory(
      id: 'profile',
      titleKey: 'help.profile',
      icon: 'account_circle_rounded',
      color: '0xFF8B5CF6',
    ),
    HelpCategory(
      id: 'ai',
      titleKey: 'help.ai_usage',
      icon: 'smart_toy_rounded',
      color: '0xFF14B8A6',
    ),
    HelpCategory(
      id: 'faq',
      titleKey: 'help.faq',
      icon: 'quiz_rounded',
      color: '0xFF64748B',
    ),
  ];
});

final helpArticlesProvider = Provider<List<HelpArticle>>((ref) {
  return const [
    HelpArticle(
      id: 'gs_intro',
      categoryId: 'gs',
      titleKey: 'help.articles.gs_intro.title',
      descriptionKey: 'help.articles.gs_intro.content',
      contentKeys: ['help.articles.gs_intro.content'],
      icon: 'rocket_launch_rounded',
    ),
    HelpArticle(
      id: 'gs_register',
      categoryId: 'gs',
      titleKey: 'help.articles.gs_register.title',
      descriptionKey: 'help.articles.gs_register.content',
      contentKeys: ['help.articles.gs_register.content'],
      stepKeys: [
        'help.articles.gs_register.steps.0',
        'help.articles.gs_register.steps.1',
        'help.articles.gs_register.steps.2',
        'help.articles.gs_register.steps.3',
        'help.articles.gs_register.steps.4',
      ],
      icon: 'person_add_rounded',
    ),
    HelpArticle(
      id: 'market_list',
      categoryId: 'market',
      titleKey: 'help.articles.market_list.title',
      descriptionKey: 'help.articles.market_list.content',
      contentKeys: ['help.articles.market_list.content'],
      stepKeys: [
        'help.articles.market_list.steps.0',
        'help.articles.market_list.steps.1',
        'help.articles.market_list.steps.2',
        'help.articles.market_list.steps.3',
        'help.articles.market_list.steps.4',
      ],
      icon: 'add_business_rounded',
    ),
  ];
});

final helpSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredArticlesProvider = Provider<List<HelpArticle>>((ref) {
  final query = ref.watch(helpSearchQueryProvider).toLowerCase();
  final articles = ref.watch(helpArticlesProvider);

  if (query.isEmpty) return [];

  return articles.where((article) {
    // Note: Ideally we should search translated content, but for now we search keys or a mock search
    // Since we are in a mock-like setup, we'll just search the ID or some keywords
    return article.id.toLowerCase().contains(query) ||
        article.categoryId.toLowerCase().contains(query);
  }).toList();
});
