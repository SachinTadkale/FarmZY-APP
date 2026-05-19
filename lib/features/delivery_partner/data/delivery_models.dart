class DeliveryPartnerProfile {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final bool isAvailable;
  final bool isActive;

  const DeliveryPartnerProfile({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.isAvailable,
    required this.isActive,
  });

  factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerProfile(
      id: (json['id'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? 'NA').toString(),
      vehicleNumber: (json['vehicleNumber'] ?? 'NA').toString(),
      licenseNumber: (json['licenseNumber'] ?? 'NA').toString(),
      isAvailable: json['isAvailable'] == true,
      isActive: json['isActive'] != false,
    );
  }
}

class DeliveryJob {
  final String id;
  final String orderId;
  final String status;
  final String productName;
  final String companyName;
  final double quantity;
  final String unit;
  final double deliveryFee;
  final double incentive;
  final double totalPayout;
  final bool isUrgent;
  final String? partnerName;
  final String? vehicleType;
  final bool pickupOtpVerified;
  final bool deliveryOtpVerified;
  final String? pickupOtp;
  final String? deliveryOtp;

  const DeliveryJob({
    required this.id,
    required this.orderId,
    required this.status,
    required this.productName,
    required this.companyName,
    required this.quantity,
    required this.unit,
    required this.deliveryFee,
    required this.incentive,
    required this.totalPayout,
    required this.isUrgent,
    required this.partnerName,
    required this.vehicleType,
    required this.pickupOtpVerified,
    required this.deliveryOtpVerified,
    this.pickupOtp,
    this.deliveryOtp,
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] as Map<String, dynamic>?) ?? const {};
    final product = (order['product'] as Map<String, dynamic>?) ?? const {};
    final company = (order['company'] as Map<String, dynamic>?) ?? const {};
    final partner = (json['partner'] as Map<String, dynamic>?) ?? const {};
    return DeliveryJob(
      id: (json['deliveryId'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      productName: (order['productName'] ?? product['name'] ?? 'Crops').toString(),
      companyName: (company['companyName'] ?? company['name'] ?? 'Unknown Company').toString(),
      quantity: (order['quantity'] as num? ?? 0).toDouble(),
      unit: (order['productUnit'] ?? product['unit'] ?? 'kg').toString(),
      deliveryFee: (order['deliveryFee'] as num? ?? 0).toDouble(),
      incentive: (json['incentive'] as num? ?? 0).toDouble(),
      totalPayout: (json['totalPayout'] as num? ?? (order['deliveryFee'] as num? ?? 0)).toDouble(),
      isUrgent: json['isUrgent'] == true,
      partnerName: partner['user']?['name']?.toString() ?? partner['name']?.toString(),
      vehicleType: partner['vehicleType']?.toString(),
      pickupOtpVerified: json['pickupOtpVerified'] == true,
      deliveryOtpVerified: json['deliveryOtpVerified'] == true,
      pickupOtp: json['pickupOtp']?.toString(),
      deliveryOtp: json['deliveryOtp']?.toString(),
    );
  }
}

class DeliveryDashboardSummary {
  final int availableJobs;
  final int activeDeliveries;

  const DeliveryDashboardSummary({
    required this.availableJobs,
    required this.activeDeliveries,
  });

  factory DeliveryDashboardSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryDashboardSummary(
      availableJobs: (json['availableJobs'] as num? ?? 0).toInt(),
      activeDeliveries: (json['activeDeliveries'] as num? ?? 0).toInt(),
    );
  }
}

class DeliveryWallet {
  final double totalEarnings;
  final double pendingEarnings;
  final double releasedEarnings;
  final int completedDeliveries;
  final double withdrawalHistory;

  const DeliveryWallet({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.releasedEarnings,
    required this.completedDeliveries,
    required this.withdrawalHistory,
  });

  factory DeliveryWallet.fromJson(Map<String, dynamic> json) {
    return DeliveryWallet(
      totalEarnings: (json['totalEarnings'] as num? ?? 0).toDouble(),
      pendingEarnings: (json['pendingEarnings'] as num? ?? 0).toDouble(),
      releasedEarnings: (json['releasedEarnings'] as num? ?? 0).toDouble(),
      completedDeliveries: (json['completedDeliveries'] as num? ?? 0).toInt(),
      withdrawalHistory: (json['withdrawalHistory'] as num? ?? 0).toDouble(),
    );
  }
}

class LogisticsTransaction {
  final String transactionId;
  final String? paymentId;
  final String orderId;
  final double amount;
  final String type;
  final String direction;
  final String status;
  final DateTime createdAt;

  const LogisticsTransaction({
    required this.transactionId,
    this.paymentId,
    required this.orderId,
    required this.amount,
    required this.type,
    required this.direction,
    required this.status,
    required this.createdAt,
  });

  factory LogisticsTransaction.fromJson(Map<String, dynamic> json) {
    return LogisticsTransaction(
      transactionId: (json['transactionId'] ?? '').toString(),
      paymentId: json['paymentId']?.toString(),
      orderId: (json['orderId'] ?? '').toString(),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      type: (json['type'] ?? '').toString(),
      direction: (json['direction'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
