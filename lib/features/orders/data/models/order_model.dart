import 'package:farmzy/shared/models/pagination_model.dart';

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

class OrderModel {
  final String id;
  final String listingId;
  final OrderProduct product;
  final OrderCompany? company;
  final OrderSnapshot snapshot;
  final String orderStatus;
  final String paymentStatus;
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
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }

  String get effectiveOrderStatus {
    final normalizedOrder = orderStatus.toUpperCase();
    final normalizedPayment = paymentStatus.toUpperCase();

    if (normalizedOrder == 'DISPATCHED' || normalizedOrder == 'IN_TRANSIT') {
      return 'SHIPPED';
    }

    if (normalizedOrder == 'ACCEPTED' || normalizedOrder == 'CONFIRMED') {
      return 'CONFIRMED';
    }

    if (normalizedOrder == 'PAYMENT_SUCCESS' ||
        normalizedPayment == 'PAID' ||
        normalizedPayment == 'SUCCESS' ||
        normalizedPayment == 'ESCROWED' ||
        normalizedPayment == 'RELEASED') {
      return 'PAYMENT_RECEIVED';
    }

    if (normalizedOrder == 'CREATED') {
      return 'INITIATED';
    }

    if (normalizedOrder == 'CANCELLED' || normalizedOrder == 'REJECTED') {
      return 'CANCELLED';
    }

    return normalizedOrder;
  }
}

class OrderProduct {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String? image;

  const OrderProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.image,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown product').toString(),
      category: (json['category'] ?? 'NA').toString(),
      unit: (json['unit'] ?? '').toString(),
      image: json['image']?.toString(),
    );
  }
}

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
