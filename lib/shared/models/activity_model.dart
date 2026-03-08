import 'package:farmzy/shared/enums/activity_type.dart';

class Activity {
  final String title;
  final ActivityType type;
  final String referenceId;

  Activity({
    required this.title,
    required this.type,
    required this.referenceId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      title: json['message'],
      type: _mapType(json['type']),
      referenceId: json['referenceId'],
    );
  }

  static ActivityType _mapType(String type) {
    switch (type) {
      case "COMPANY_REQUEST":
        return ActivityType.companyRequest;

      case "ORDER_PICKED":
        return ActivityType.orderPicked;

      case "PAYMENT_RECEIVED":
        return ActivityType.paymentReceived;

      case "DELIVERY_COMPLETED":
        return ActivityType.deliveryCompleted;

      case "CROP_APPROVED":
        return ActivityType.cropApproved;

      default:
        return ActivityType.companyRequest;
    }
  }
}
