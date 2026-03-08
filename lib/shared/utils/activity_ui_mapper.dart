import 'package:flutter/material.dart';
import '../enums/activity_type.dart';

class ActivityUIMapper {
  static IconData getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.companyRequest:
        return Icons.campaign;

      case ActivityType.orderPicked:
        return Icons.local_shipping;

      case ActivityType.paymentReceived:
        return Icons.currency_rupee;

      case ActivityType.deliveryCompleted:
        return Icons.check_circle;

      case ActivityType.cropApproved:
        return Icons.agriculture;
    }
  }

  static Color getColor(ActivityType type) {
    switch (type) {
      case ActivityType.companyRequest:
        return Colors.orange;

      case ActivityType.orderPicked:
        return Colors.blue;

      case ActivityType.paymentReceived:
        return Colors.green;

      case ActivityType.deliveryCompleted:
        return Colors.teal;

      case ActivityType.cropApproved:
        return Colors.greenAccent;
    }
  }
}
