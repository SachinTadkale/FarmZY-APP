import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_models.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return DeliveryRepository(DeliveryService(apiClient));
});

class DeliveryRepository {
  final DeliveryService _service;

  DeliveryRepository(this._service);

  Future<DeliveryPartnerProfile> getProfile() => _service.getProfile();
  Future<DeliveryPartnerProfile> updateAvailability(bool isAvailable) => _service.updateAvailability(isAvailable);
  Future<List<DeliveryJob>> getJobs() => _service.getJobs();
  Future<List<DeliveryJob>> getActiveDeliveries() => _service.getActiveDeliveries();
  Future<DeliveryDashboardSummary> getDashboard() => _service.getDashboard();
  Future<void> acceptJob(String deliveryId) => _service.acceptJob(deliveryId);
  Future<void> updateStatus({
    required String deliveryId,
    required String status,
    String? pickupOtp,
    String? deliveryOtp,
  }) =>
      _service.updateStatus(
        deliveryId: deliveryId,
        status: status,
        pickupOtp: pickupOtp,
        deliveryOtp: deliveryOtp,
      );

  Future<DeliveryWallet> getWallet() => _service.getWallet();
  Future<List<LogisticsTransaction>> getTransactions() => _service.getTransactions();
  Future<Map<String, double>> getEarningsSummary() => _service.getEarningsSummary();
}
