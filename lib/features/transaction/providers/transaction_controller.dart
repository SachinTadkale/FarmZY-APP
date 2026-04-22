import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/features/transaction/data/transaction_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 🔹 Refresh trigger
final transactionRefreshProvider = StateProvider<int>((ref) => 0);
final transactionSearchProvider = StateProvider<String>((ref) => '');
final transactionStatusProvider = StateProvider<String?>((ref) => null);
final transactionSortProvider = StateProvider<String>((ref) => "desc");

/// 🔹 Filter
enum TransactionFilter {
  earnings, // CREDIT
  expenses, // DEBIT (future)
  all,
}

/// 🔹 Filter provider
final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.earnings,
);

final transactionsProvider = FutureProvider((ref) async {
  ref.watch(transactionRefreshProvider);

  final search = ref.watch(transactionSearchProvider);
  final status = ref.watch(transactionStatusProvider);
  final sort = ref.watch(transactionSortProvider);
  final filter = ref.watch(transactionFilterProvider);

  String? direction;
  if (filter == TransactionFilter.earnings) {
    direction = "CREDIT";
  } else if (filter == TransactionFilter.expenses) {
    direction = "DEBIT";
  }

  final response = await ref.read(transactionRepositoryProvider).getTransactions(
        page: 1,
        limit: 20,
        direction: direction,
        search: search,
        status: status,
        sort: sort,
      );

  return response.transactions;
});
