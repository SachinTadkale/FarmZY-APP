/**
 * Module: Transaction Response
 * Purpose: Implements the Transaction Response module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/features/transaction/data/model/transaction_model.dart';
import 'package:farmzy/shared/models/pagination_model.dart';

/**
 * Transaction List Response.
 */
class TransactionListResponse {
  final List<TransactionModel> transactions;
  final PaginationModel pagination;

  const TransactionListResponse({
    required this.transactions,
    required this.pagination,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return TransactionListResponse(
      transactions: (data['transactions'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
    );
  }
}
