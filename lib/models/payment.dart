// lib/models/payment.dart
//
// Payment model for MechResQ payment transactions

import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment Status Enum
enum PaymentStatus {
  pending,
  success,
  failed,
  refunded,
  cancelled,
}

/// Payment Method Enum
enum PaymentMethod {
  card,
  upi,
  netbanking,
  wallet,
  unknown,
}

/// Payment Model
/// Represents a payment transaction in the MechResQ app
class Payment {
  final String id;
  final String bookingId;
  final String userId;
  final String? mechanicId;
  
  // Amount details
  final double amount; // in rupees
  final String currency;
  final String? description;
  
  // Payment gateway details
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  
  // Status
  final PaymentStatus status;
  final PaymentMethod? paymentMethod;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? refundedAt;
  
  // Error details
  final String? errorCode;
  final String? errorDescription;
  final String? errorReason;
  
  // Additional metadata
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    this.mechanicId,
    required this.amount,
    this.currency = 'INR',
    this.description,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    this.failedAt,
    this.refundedAt,
    this.errorCode,
    this.errorDescription,
    this.errorReason,
    this.metadata,
  });

  // ═══════════════════════════════════════════
  // FACTORIES
  // ═══════════════════════════════════════════

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment.fromMap(data, doc.id);
  }

  factory Payment.fromMap(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      mechanicId: data['mechanicId'],
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      description: data['description'],
      razorpayOrderId: data['razorpayOrderId'],
      razorpayPaymentId: data['razorpayPaymentId'],
      razorpaySignature: data['razorpaySignature'],
      status: _statusFromString(data['status'] ?? 'pending'),
      paymentMethod: _methodFromString(data['paymentMethod']),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      paidAt: data['paidAt'] != null
          ? (data['paidAt'] as Timestamp).toDate()
          : null,
      failedAt: data['failedAt'] != null
          ? (data['failedAt'] as Timestamp).toDate()
          : null,
      refundedAt: data['refundedAt'] != null
          ? (data['refundedAt'] as Timestamp).toDate()
          : null,
      errorCode: data['errorCode'],
      errorDescription: data['errorDescription'],
      errorReason: data['errorReason'],
      metadata: data['metadata'],
    );
  }

  // ═══════════════════════════════════════════
  // TO MAP
  // ═══════════════════════════════════════════

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'mechanicId': mechanicId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'status': _statusToString(status),
      'paymentMethod': paymentMethod != null ? _methodToString(paymentMethod!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'failedAt': failedAt != null ? Timestamp.fromDate(failedAt!) : null,
      'refundedAt': refundedAt != null ? Timestamp.fromDate(refundedAt!) : null,
      'errorCode': errorCode,
      'errorDescription': errorDescription,
      'errorReason': errorReason,
      'metadata': metadata,
    };
  }

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  static PaymentStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  static String _statusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.cancelled:
        return 'cancelled';
      case PaymentStatus.pending:
        return 'pending';
    }
  }

  static PaymentMethod? _methodFromString(String? method) {
    if (method == null) return null;
    switch (method.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'upi':
        return PaymentMethod.upi;
      case 'netbanking':
        return PaymentMethod.netbanking;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.unknown;
    }
  }

  static String _methodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.netbanking:
        return 'netbanking';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.unknown:
        return 'unknown';
    }
  }

  // ═══════════════════════════════════════════
  // DISPLAY HELPERS
  // ═══════════════════════════════════════════

  String get statusDisplay {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get methodDisplay {
    if (paymentMethod == null) return 'N/A';
    switch (paymentMethod!) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.netbanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.unknown:
        return 'Unknown';
    }
  }

  String get amountDisplay {
    return '₹${amount.toStringAsFixed(2)}';
  }

  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isRefunded => status == PaymentStatus.refunded;
  bool get isCancelled => status == PaymentStatus.cancelled;

  // ═══════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════

  Payment copyWith({
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? paidAt,
    DateTime? failedAt,
    DateTime? refundedAt,
    String? errorCode,
    String? errorDescription,
    String? errorReason,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id,
      bookingId: bookingId,
      userId: userId,
      mechanicId: mechanicId,
      amount: amount,
      currency: currency,
      description: description,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
      failedAt: failedAt ?? this.failedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      errorCode: errorCode ?? this.errorCode,
      errorDescription: errorDescription ?? this.errorDescription,
      errorReason: errorReason ?? this.errorReason,
      metadata: metadata ?? this.metadata,
    );
  }
}
