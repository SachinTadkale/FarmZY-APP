/**
 * Module: Transaction History Screen
 * Purpose: Implements the Transaction History Screen module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_controller.dart';
import '../widgets/transaction_card.dart';
import '../../../../shared/widgets/app_async_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../core/theme/app_spacing.dart';

/**
 * Transaction History Screen.
 */
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

/**
 * Transaction Filter Tabs.
 */
class _TransactionFilterTabs extends ConsumerWidget {
  @override
/**
 * Build.
 */
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              title: "transactions.earnings".tr(),
              isSelected: selected == TransactionFilter.earnings,
              onTap: () {
                ref.read(transactionFilterProvider.notifier).state =
                    TransactionFilter.earnings;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabPill(
              title: "transactions.expenses".tr(),
              isSelected: selected == TransactionFilter.expenses,
              onTap: () {
                ref.read(transactionFilterProvider.notifier).state =
                    TransactionFilter.expenses;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabPill(
              title: "transactions.all".tr(),
              isSelected: selected == TransactionFilter.all,
              onTap: () {
                ref.read(transactionFilterProvider.notifier).state =
                    TransactionFilter.all;
              },
            ),
          ),
        ],
      ),
    );
  }
}

/**
 * Tab Pill.
 */
class _TabPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/**
 * Transaction History Screen State.
 */
class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
/**
 * Init State.
 */
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
/**
 * Dispose.
 */
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

/**
 * On Search Changed.
 */
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    // 🔴 Requirement: If input is empty → reset immediately
    if (value.isEmpty) {
      ref.read(transactionSearchProvider.notifier).state = '';
      return;
    }

    // 🔴 Requirement: If input < 2 → do NOT call API (don't update provider)
    if (value.length < 2) return;

    // 🔴 Requirement: Use 500ms debounce
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(transactionSearchProvider.notifier).state = value;
    });
  }

  @override
/**
 * Build.
 */
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      isLoading: transactionsAsync.isLoading && transactionsAsync.hasValue,
      body: Column(
        children: [
          // 🔹 Search Bar Group
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'transactions.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(''); // Trigger immediate reset
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.1)),
                ),
              ),
            ),
          ),

          // 🔹 Filter Tabs
          _TransactionFilterTabs(),

          // 🔹 Dropdown Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: "common.status".tr(),
                    value: ref.watch(transactionStatusProvider),
                    items: ["SUCCESS", "FAILED"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text('common.status_${e.toLowerCase()}'.tr()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      ref.read(transactionStatusProvider.notifier).state = val;
                    },
                    hint: "transactions.all_status".tr(),
                    prefixIcon: Icons.filter_list_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdown<String>(
                    label: "marketplace.sort_by".tr(),
                    value: ref.watch(transactionSortProvider),
                    items: [
                      DropdownMenuItem(
                        value: "desc",
                        child: Text("transactions.sort_newest".tr()),
                      ),
                      DropdownMenuItem(
                        value: "asc",
                        child: Text("transactions.sort_oldest".tr()),
                      ),
                    ],
                    onChanged: (val) {
                      ref.read(transactionSortProvider.notifier).state = val!;
                    },
                    prefixIcon: Icons.sort_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: transactionsAsync.when(
              // skipLoadingOnReload: true, ensures we keep showing data while loading in background
              skipLoadingOnReload: true,
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          "transactions.no_transactions".tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(transactionRefreshProvider.notifier).state++;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemBuilder: (_, i) => TransactionCard(txn: transactions[i]),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: transactions.length,
                  ),
                );
              },
              loading: () =>
                  AppLoadingState(message: "transactions.loading".tr()),
              error: (e, _) => AppErrorState(
                error: e,
                title: "transactions.error_load".tr(),
                onRetry: () {
                  ref.read(transactionRefreshProvider.notifier).state++;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
