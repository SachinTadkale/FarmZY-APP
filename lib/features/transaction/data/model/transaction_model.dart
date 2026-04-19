import 'transaction_enums.dart';

class TransactionModel {
  final String transactionId;
  final String? orderId;
  final String? paymentId;

  final ActorType actorType;
  final TransactionType type;
  final TransactionDirection direction;
  final TransactionStatus status;

  final double amount;
  final int? amountInPaise;

  final DateTime? createdAt;

  const TransactionModel({
    required this.transactionId,
    this.orderId,
    this.paymentId,
    required this.actorType,
    required this.type,
    required this.direction,
    required this.status,
    required this.amount,
    this.amountInPaise,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: (json['transactionId'] ?? '').toString(),
      orderId: json['orderId']?.toString(),
      paymentId: json['paymentId']?.toString(),

      actorType: parseActorType(json['actorType']),
      type: parseTransactionType(json['type']),
      direction: parseDirection(json['direction']),
      status: parseStatus(json['status']),

      amount: (json['amount'] as num? ?? 0).toDouble(),
      amountInPaise: (json['amountInPaise'] as num?)?.toInt(),

      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
    );
  }
}