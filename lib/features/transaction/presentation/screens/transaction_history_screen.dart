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
    final theme = Theme.of(context);

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
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? selectedColor : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        ref.read(transactionSearchProvider.notifier).state = '';
        return;
      }
      if (value.length < 2) return;

      ref.read(transactionSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final search = ref.watch(transactionSearchProvider);

    return AppScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by txn id or amount',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(transactionSearchProvider.notifier).state =
                              '';
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          _TransactionFilterTabs(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                /// 🔹 Status Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: ref.watch(transactionStatusProvider),
                    hint: const Text("Status"),
                    items: ["SUCCESS", "FAILED"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      ref.read(transactionStatusProvider.notifier).state = val;
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔹 Sort Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: ref.watch(transactionSortProvider),
                    items: [
                      DropdownMenuItem(value: "desc", child: Text("Newest")),
                      DropdownMenuItem(value: "asc", child: Text("Oldest")),
                    ],
                    onChanged: (val) {
                      ref.read(transactionSortProvider.notifier).state = val!;
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text("No transactions found"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(transactionRefreshProvider.notifier).state++;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemBuilder: (_, i) =>
                        TransactionCard(txn: transactions[i]),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
