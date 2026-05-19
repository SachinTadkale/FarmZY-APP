import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_models.dart';

class DeliveryService {
  final ApiClient _api;

  DeliveryService(this._api);

  Future<DeliveryPartnerProfile> getProfile() async {
    final response = await _api.get('delivery-partners/profile');
    return DeliveryPartnerProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DeliveryPartnerProfile> updateAvailability(bool isAvailable) async {
    final response = await _api.patch('delivery-partners/availability', data: {
      'isAvailable': isAvailable,
    });
    return DeliveryPartnerProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<DeliveryJob>> getJobs() async {
    final response = await _api.get('deliveries/jobs');
    final list = response.data['data'] as List<dynamic>? ?? const [];
    return list.whereType<Map<String, dynamic>>().map(DeliveryJob.fromJson).toList();
  }

  Future<List<DeliveryJob>> getActiveDeliveries() async {
    final response = await _api.get('deliveries/active');
    final list = response.data['data'] as List<dynamic>? ?? const [];
    return list.whereType<Map<String, dynamic>>().map(DeliveryJob.fromJson).toList();
  }

  Future<DeliveryDashboardSummary> getDashboard() async {
    final response = await _api.get('deliveries/dashboard');
    return DeliveryDashboardSummary.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> acceptJob(String deliveryId) async {
    await _api.post('deliveries/accept/$deliveryId');
  }

  Future<void> updateStatus({
    required String deliveryId,
    required String status,
    String? pickupOtp,
    String? deliveryOtp,
  }) async {
    await _api.patch('deliveries/$deliveryId/status', data: {
      'status': status,
      if (pickupOtp != null && pickupOtp.isNotEmpty) 'pickupOtp': pickupOtp,
      if (deliveryOtp != null && deliveryOtp.isNotEmpty) 'deliveryOtp': deliveryOtp,
    });
  }

  Future<DeliveryWallet> getWallet() async {
    final response = await _api.get('deliveries/wallet');
    return DeliveryWallet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<LogisticsTransaction>> getTransactions() async {
    final response = await _api.get('deliveries/transactions');
    final list = response.data['data'] as List<dynamic>? ?? const [];
    return list.whereType<Map<String, dynamic>>().map(LogisticsTransaction.fromJson).toList();
  }

  Future<Map<String, double>> getEarningsSummary() async {
    final response = await _api.get('deliveries/earnings/summary');
    final data = response.data['data'] as Map<String, dynamic>? ?? const {};
    return data.map((key, value) => MapEntry(key, (value as num? ?? 0).toDouble()));
  }
}
