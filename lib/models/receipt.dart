// lib/models/receipt.dart
// Receipt model for MechResQ — generated after payment completion.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/billing_service.dart';

enum ReceiptPaymentMethod { digital, cash }

enum ReceiptStatus { pending, paid }

class ServiceReceipt {
  final String id;
  final String requestId;
  final String userId;
  final String? mechanicId;
  final String? mechanicName;

  // Service info
  final String vehicleType;
  final String issueDescription;
  final String serviceLocation;

  // Billing breakdown
  final double baseServiceCharge;
  final double laborCharge;
  final double callOutCharge;
  final double sparePartsActual;
  final double platformFee;
  final double subTotal;
  final double gstAmount;
  final double totalAmount;
  final String complexityLabel;

  // Payment info
  final ReceiptPaymentMethod paymentMethod;
  final ReceiptStatus status;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;

  // Timestamps
  final DateTime createdAt;
  final DateTime? paidAt;

  const ServiceReceipt({
    required this.id,
    required this.requestId,
    required this.userId,
    this.mechanicId,
    this.mechanicName,
    required this.vehicleType,
    required this.issueDescription,
    required this.serviceLocation,
    required this.baseServiceCharge,
    required this.laborCharge,
    required this.callOutCharge,
    required this.sparePartsActual,
    required this.platformFee,
    required this.subTotal,
    required this.gstAmount,
    required this.totalAmount,
    required this.complexityLabel,
    required this.paymentMethod,
    required this.status,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    required this.createdAt,
    this.paidAt,
  });

  // ─── factories ────────────────────────────────────────────

  factory ServiceReceipt.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ServiceReceipt(
      id: doc.id,
      requestId: d['requestId'] ?? '',
      userId: d['userId'] ?? '',
      mechanicId: d['mechanicId'],
      mechanicName: d['mechanicName'],
      vehicleType: d['vehicleType'] ?? '',
      issueDescription: d['issueDescription'] ?? '',
      serviceLocation: d['serviceLocation'] ?? '',
      baseServiceCharge: (d['baseServiceCharge'] ?? 0).toDouble(),
      laborCharge: (d['laborCharge'] ?? 0).toDouble(),
      callOutCharge: (d['callOutCharge'] ?? 0).toDouble(),
      sparePartsActual: (d['sparePartsActual'] ?? 0).toDouble(),
      platformFee: (d['platformFee'] ?? 0).toDouble(),
      subTotal: (d['subTotal'] ?? 0).toDouble(),
      gstAmount: (d['gstAmount'] ?? 0).toDouble(),
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      complexityLabel: d['complexityLabel'] ?? 'Medium',
      paymentMethod: d['paymentMethod'] == 'cash'
          ? ReceiptPaymentMethod.cash
          : ReceiptPaymentMethod.digital,
      status: d['status'] == 'paid'
          ? ReceiptStatus.paid
          : ReceiptStatus.pending,
      razorpayPaymentId: d['razorpayPaymentId'],
      razorpayOrderId: d['razorpayOrderId'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      paidAt: d['paidAt'] != null
          ? (d['paidAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Build from BillingService estimate
  factory ServiceReceipt.fromBill({
    required String id,
    required String userId,
    required ServiceBill bill,
    required String serviceLocation,
    String? mechanicId,
    String? mechanicName,
    ReceiptPaymentMethod paymentMethod = ReceiptPaymentMethod.digital,
  }) {
    return ServiceReceipt(
      id: id,
      requestId: bill.requestId,
      userId: userId,
      mechanicId: mechanicId,
      mechanicName: mechanicName,
      vehicleType: bill.vehicleType,
      issueDescription: bill.issueDescription,
      serviceLocation: serviceLocation,
      baseServiceCharge: bill.baseServiceCharge,
      laborCharge: bill.laborCharge,
      callOutCharge: bill.callOutCharge,
      sparePartsActual: bill.sparePartsEstimate,
      platformFee: bill.platformFee,
      subTotal: bill.subTotal,
      gstAmount: bill.gstAmount,
      totalAmount: bill.totalAmount,
      complexityLabel: bill.complexityLabel,
      paymentMethod: paymentMethod,
      status: ReceiptStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  // ─── serialisation ─────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'userId': userId,
        'mechanicId': mechanicId,
        'mechanicName': mechanicName,
        'vehicleType': vehicleType,
        'issueDescription': issueDescription,
        'serviceLocation': serviceLocation,
        'baseServiceCharge': baseServiceCharge,
        'laborCharge': laborCharge,
        'callOutCharge': callOutCharge,
        'sparePartsActual': sparePartsActual,
        'platformFee': platformFee,
        'subTotal': subTotal,
        'gstAmount': gstAmount,
        'totalAmount': totalAmount,
        'complexityLabel': complexityLabel,
        'paymentMethod':
            paymentMethod == ReceiptPaymentMethod.cash ? 'cash' : 'digital',
        'status': status == ReceiptStatus.paid ? 'paid' : 'pending',
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'createdAt': Timestamp.fromDate(createdAt),
        'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      };

  // ─── helpers ───────────────────────────────────────────────

  bool get isPaid => status == ReceiptStatus.paid;
  bool get isDigital => paymentMethod == ReceiptPaymentMethod.digital;

  String get paymentMethodDisplay =>
      paymentMethod == ReceiptPaymentMethod.cash ? 'Cash' : 'Digital (Razorpay)';

  String get statusDisplay => status == ReceiptStatus.paid ? 'Paid' : 'Pending';

  ServiceReceipt copyWith({
    ReceiptStatus? status,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    DateTime? paidAt,
    String? mechanicId,
    String? mechanicName,
    double? sparePartsActual,
  }) {
    return ServiceReceipt(
      id: id,
      requestId: requestId,
      userId: userId,
      mechanicId: mechanicId ?? this.mechanicId,
      mechanicName: mechanicName ?? this.mechanicName,
      vehicleType: vehicleType,
      issueDescription: issueDescription,
      serviceLocation: serviceLocation,
      baseServiceCharge: baseServiceCharge,
      laborCharge: laborCharge,
      callOutCharge: callOutCharge,
      sparePartsActual: sparePartsActual ?? this.sparePartsActual,
      platformFee: platformFee,
      subTotal: subTotal,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      complexityLabel: complexityLabel,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
