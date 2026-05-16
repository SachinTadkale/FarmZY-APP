/**
 * Module: Transaction Enums
 * Purpose: Implements the Transaction Enums module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Transaction Type.
 */
enum TransactionType {
  ORDER_PAYMENT,
  ESCROW_RELEASE,
  DELIVERY_PAYOUT,
  PLATFORM_COMMISSION,
  UNKNOWN,
}

/**
 * Transaction Direction.
 */
enum TransactionDirection {
  CREDIT,
  DEBIT,
  UNKNOWN,
}

/**
 * Transaction Status.
 */
enum TransactionStatus {
  PENDING,
  SUCCESS,
  FAILED,
  UNKNOWN,
}

/**
 * Actor Type.
 */
enum ActorType {
  FARMER,
  COMPANY,
  PLATFORM,
  UNKNOWN,
}

TransactionType parseTransactionType(String? value) {
  switch (value) {
    case "ORDER_PAYMENT":
      return TransactionType.ORDER_PAYMENT;
    case "ESCROW_RELEASE":
      return TransactionType.ESCROW_RELEASE;
    case "DELIVERY_PAYOUT":
      return TransactionType.DELIVERY_PAYOUT;
    case "PLATFORM_COMMISSION":
      return TransactionType.PLATFORM_COMMISSION;
    default:
      return TransactionType.UNKNOWN;
  }
}

TransactionDirection parseDirection(String? value) {
  switch (value) {
    case "CREDIT":
      return TransactionDirection.CREDIT;
    case "DEBIT":
      return TransactionDirection.DEBIT;
    default:
      return TransactionDirection.UNKNOWN;
  }
}

TransactionStatus parseStatus(String? value) {
  switch (value) {
    case "PENDING":
      return TransactionStatus.PENDING;
    case "SUCCESS":
      return TransactionStatus.SUCCESS;
    case "FAILED":
      return TransactionStatus.FAILED;
    default:
      return TransactionStatus.UNKNOWN;
  }
}

ActorType parseActorType(String? value) {
  switch (value) {
    case "FARMER":
      return ActorType.FARMER;
    case "COMPANY":
      return ActorType.COMPANY;
    case "PLATFORM":
      return ActorType.PLATFORM;
    default:
      return ActorType.UNKNOWN;
  }
}
