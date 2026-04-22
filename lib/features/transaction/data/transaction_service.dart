import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/transaction/data/model/transaction_response.dart';

class TransactionService {
  final ApiClient _api;

  TransactionService(this._api);

  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int limit = 10,
    String? type,
    String? direction,
  String? status,
    String? search,
    String? sort,
  }) async {
    final response = await _api.get(
      '/transactions/getTransactions',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null && type.isNotEmpty) 'type': type,
        if (direction != null && direction.isNotEmpty) 'direction': direction,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
    );

    return TransactionListResponse.fromJson(response.data);
  }
}
