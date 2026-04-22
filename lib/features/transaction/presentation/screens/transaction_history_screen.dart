import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_controller.dart';
import '../widgets/transaction_card.dart';
import '../../../../shared/widgets/app_async_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionFilterTabs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              title: "Earnings",
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
              title: "Expenses",
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
              title: "All",
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
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.2),
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

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

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
                hintText: 'Search by txn id or amount',
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
                      color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: ref.watch(transactionStatusProvider),
                        hint: const Text("All Status"),
                        isDense: true,
                        items: ["SUCCESS", "FAILED"]
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: theme.textTheme.bodyMedium)))
                            .toList(),
                        onChanged: (val) {
                          ref.read(transactionStatusProvider.notifier).state = val;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sort By",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: ref.watch(transactionSortProvider),
                        isDense: true,
                        items: [
                          DropdownMenuItem(
                              value: "desc",
                              child: Text("Newest",
                                  style: theme.textTheme.bodyMedium)),
                          DropdownMenuItem(
                              value: "asc",
                              child: Text("Oldest",
                                  style: theme.textTheme.bodyMedium)),
                        ],
                        onChanged: (val) {
                          ref.read(transactionSortProvider.notifier).state = val!;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
                          "No transactions found",
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
                  const AppLoadingState(message: "Fetching transactions..."),
              error: (e, _) => AppErrorState(
                error: e,
                title: "Failed to load transactions",
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
