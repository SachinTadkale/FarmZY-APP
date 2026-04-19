import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/transaction/data/model/transaction_response.dart';
import 'package:farmzy/features/transaction/data/transaction_service.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final service = TransactionService(apiClient);
  return TransactionRepository(service);
});

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository(this._service);

  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int limit = 10,
    String? type,
    String? direction,
    String? status,
    String? search,
    String? sort,
  }) async {
    return _service.getTransactions(
      page: page,
      limit: limit,
      type: type,
      direction: direction,
      status: status,
      search: search,
      sort: sort,
    );
  }
}
