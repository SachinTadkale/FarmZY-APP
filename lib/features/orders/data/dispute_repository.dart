/**
 * Module: Dispute Repository
 * Purpose: Implements B2B/B2C dispute escalation client for the FarmZy mobile app.
 */
import 'package:farmzy/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return DisputeRepository(apiClient);
});

class DisputeRepository {
  final ApiClient _api;

  DisputeRepository(this._api);

  /// Raise a dispute against the B2B company.
  Future<String> raiseDispute({
    required String orderId,
    required String reason,
    required String description,
  }) async {
    final response = await _api.post(
      'disputes',
      data: {
        'orderId': orderId,
        'reason': reason,
        'description': description,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Dispute submitted successfully';
  }
}
