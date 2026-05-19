/**
 * Module: Order Model
 * Purpose: Implements the Order Model module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/models/translation_model.dart';
import 'package:farmzy/shared/models/pagination_model.dart';

/**
 * Order List Response.
 */
class OrderListResponse {
  final List<OrderModel> orders;
  final PaginationModel? pagination;

  const OrderListResponse({
    required this.orders,
    this.pagination,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final dataList = rawData is List ? rawData : const [];
    final paginationJson = json['pagination'];

    return OrderListResponse(
      orders: dataList
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList(),
      pagination: paginationJson is Map<String, dynamic>
          ? PaginationModel.fromJson(paginationJson)
          : null,
    );
  }
}

/**
 * Order Model.
 */
class OrderModel {
  final String id;
  final String listingId;
  final OrderProduct product;
  final OrderCompany? company;
  final OrderSnapshot snapshot;
  final String orderStatus;
  final String paymentStatus;
  final OrderDelivery? delivery;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.listingId,
    required this.product,
    required this.company,
    required this.snapshot,
    required this.orderStatus,
    required this.paymentStatus,
    required this.delivery,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listingId'] ?? '').toString(),
      product: OrderProduct.fromJson(
        (json['product'] as Map<String, dynamic>?) ?? const {},
      ),
      company: json['company'] is Map<String, dynamic>
          ? OrderCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      snapshot: OrderSnapshot.fromJson(
        (json['snapshot'] as Map<String, dynamic>?) ?? const {},
      ),
      orderStatus: (json['orderStatus'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      delivery: json['delivery'] is Map<String, dynamic>
          ? OrderDelivery.fromJson(json['delivery'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }

  String get effectiveOrderStatus {
    final normalizedOrder = orderStatus.toUpperCase();
    final normalizedPayment = paymentStatus.toUpperCase();
    final normalizedDelivery = (delivery?.status ?? '').toUpperCase();

    if (normalizedOrder == 'REJECTED') return 'REJECTED';
    if (normalizedOrder == 'CANCELLED') return 'CANCELLED';
    if (normalizedOrder == 'DISPUTED') return 'DISPUTED';
    if (normalizedOrder == 'COMPLETED') return 'COMPLETED';
    if (normalizedOrder == 'DELIVERED') return 'DELIVERED';
    if (normalizedOrder == 'IN_TRANSIT' || normalizedDelivery == 'IN_TRANSIT') return 'IN_TRANSIT';
    if (normalizedOrder == 'DISPATCHED' || normalizedDelivery == 'PICKED_UP') return 'DISPATCHED';
    if (normalizedDelivery == 'ASSIGNED') return 'DELIVERY_ASSIGNED';
    if (normalizedOrder == 'PROCESSING') return 'DELIVERY_PROCESSING';
    if (normalizedPayment == 'HELD' || normalizedPayment == 'ESCROWED' || normalizedOrder == 'CONFIRMED') return 'PAYMENT_HELD';
    if (normalizedOrder == 'PAYMENT_PENDING' || normalizedOrder == 'ACCEPTED') return 'PAYMENT_PENDING';
    if (normalizedOrder == 'CREATED') return 'PENDING_ACCEPTANCE';

    return normalizedOrder;
  }
}

class OrderDelivery {
  final String id;
  final String status;
  final bool pickupOtpVerified;
  final bool deliveryOtpVerified;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final OrderDeliveryPartner? partner;

  const OrderDelivery({
    required this.id,
    required this.status,
    required this.pickupOtpVerified,
    required this.deliveryOtpVerified,
    required this.pickupTime,
    required this.deliveryTime,
    required this.partner,
  });

  factory OrderDelivery.fromJson(Map<String, dynamic> json) {
    return OrderDelivery(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      pickupOtpVerified: json['pickupOtpVerified'] == true,
      deliveryOtpVerified: json['deliveryOtpVerified'] == true,
      pickupTime: DateTime.tryParse((json['pickupTime'] ?? '').toString()),
      deliveryTime: DateTime.tryParse((json['deliveryTime'] ?? '').toString()),
      partner: json['partner'] is Map<String, dynamic>
          ? OrderDeliveryPartner.fromJson(json['partner'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderDeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;

  const OrderDeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
  });

  factory OrderDeliveryPartner.fromJson(Map<String, dynamic> json) {
    return OrderDeliveryPartner(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? '').toString(),
      vehicleNumber: (json['vehicleNumber'] ?? '').toString(),
    );
  }
}

/**
 * Order Product.
 */
class OrderProduct {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String? image;
  final EntityTranslations translations;

  const OrderProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.image,
    required this.translations,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown product').toString(),
      category: (json['category'] ?? 'NA').toString(),
      unit: (json['unit'] ?? '').toString(),
      image: json['image']?.toString(),
      translations: EntityTranslations.fromJson(
        json['translations'] as Map<String, dynamic>?,
      ),
    );
  }
}

/**
 * Order Company.
 */
class OrderCompany {
  final String id;
  final String name;
  final String email;
  final String? hqLocation;

  const OrderCompany({
    required this.id,
    required this.name,
    required this.email,
    required this.hqLocation,
  });

  factory OrderCompany.fromJson(Map<String, dynamic> json) {
    return OrderCompany(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      hqLocation: json['hqLocation']?.toString(),
    );
  }
}

/**
 * Order Snapshot.
 */
class OrderSnapshot {
  final double unitPrice;
  final double quantity;
  final double finalPrice;

  const OrderSnapshot({
    required this.unitPrice,
    required this.quantity,
    required this.finalPrice,
  });

  factory OrderSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderSnapshot(
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] as num? ?? 0).toDouble(),
    );
  }
}
