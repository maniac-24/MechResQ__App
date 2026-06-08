// lib/services/payment_firestore_service.dart
//
// Firestore service for payment operations
// Handles all payment-related Firestore operations

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

/// Payment Firestore Service
/// Manages payment data in Cloud Firestore
class PaymentFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static const String _paymentsCollection = 'payments';
  static const String _bookingsCollection = 'bookings';
  static const String _requestTrackingCollection = 'request_tracking';

  // ═══════════════════════════════════════════
  // CREATE PAYMENT
  // ═══════════════════════════════════════════

  /// Create a new payment record in Firestore
  static Future<String> createPayment({
    required String bookingId,
    required String userId,
    String? mechanicId,
    required double amount,
    String? description,
  }) async {
    try {
      developer.log(
        '📝 Creating payment record for booking: $bookingId',
        name: 'PaymentFirestoreService',
      );

      final paymentData = {
        'bookingId': bookingId,
        'userId': userId,
        'mechanicId': mechanicId,
        'amount': amount,
        'currency': 'INR',
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(_paymentsCollection)
          .add(paymentData);

      developer.log(
        '✅ Payment record created: ${docRef.id}',
        name: 'PaymentFirestoreService',
      );

      return docRef.id;
    } catch (e) {
      developer.log(
        '❌ Error creating payment: $e',
        name: 'PaymentFirestoreService',
      );
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // UPDATE PAYMENT
  // ═══════════════════════════════════════════

  /// Update payment status to success
  static Future<void> updatePaymentSuccess({
    required String paymentId,
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    String? paymentMethod,
  }) async {
    try {
      developer.log(
        '✅ Updating payment to success: $paymentId',
        name: 'PaymentFirestoreService',
      );

      final updateData = {
        'status': 'success',
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpaySignature': razorpaySignature,
        'paymentMethod': paymentMethod,
        'paidAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .update(updateData);

      developer.log(
        '✅ Payment updated successfully',
        name: 'PaymentFirestoreService',
      );
    } catch (e) {
      developer.log(
        '❌ Error updating payment success: $e',
        name: 'PaymentFirestoreService',
      );
      rethrow;
    }
  }

  /// Update payment status to failed
  static Future<void> updatePaymentFailure({
    required String paymentId,
    required String errorCode,
    required String errorDescription,
    String? errorReason,
  }) async {
    try {
      developer.log(
        '❌ Updating payment to failed: $paymentId',
        name: 'PaymentFirestoreService',
      );

      final updateData = {
        'status': 'failed',
        'errorCode': errorCode,
        'errorDescription': errorDescription,
        'errorReason': errorReason,
        'failedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .update(updateData);

      developer.log(
        '✅ Payment failure recorded',
        name: 'PaymentFirestoreService',
      );
    } catch (e) {
      developer.log(
        '❌ Error updating payment failure: $e',
        name: 'PaymentFirestoreService',
      );
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // UPDATE BOOKING PAYMENT STATUS
  // ═══════════════════════════════════════════

  /// Update booking payment status after successful payment
  static Future<void> updateBookingPaymentStatus({
    required String bookingId,
    required String paymentId,
    required double amount,
  }) async {
    try {
      developer.log(
        '📝 Updating booking payment status: $bookingId',
        name: 'PaymentFirestoreService',
      );

      // Try updating in request_tracking collection (if it exists)
      final trackingDoc = await _firestore
          .collection(_requestTrackingCollection)
          .doc(bookingId)
          .get();

      if (trackingDoc.exists) {
        await _firestore
            .collection(_requestTrackingCollection)
            .doc(bookingId)
            .update({
          'paymentStatus': 'success',
          'paymentId': paymentId,
          'paidAmount': amount,
          'paidAt': FieldValue.serverTimestamp(),
        });
        
        developer.log(
          '✅ Request tracking updated with payment info',
          name: 'PaymentFirestoreService',
        );
      }

      // Also try updating in bookings collection (if it exists)
      final bookingDoc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        await _firestore
            .collection(_bookingsCollection)
            .doc(bookingId)
            .update({
          'paymentStatus': 'success',
          'paymentId': paymentId,
          'paidAmount': amount,
          'paidAt': FieldValue.serverTimestamp(),
        });
        
        developer.log(
          '✅ Booking updated with payment info',
          name: 'PaymentFirestoreService',
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error updating booking payment status: $e',
        name: 'PaymentFirestoreService',
      );
      // Don't rethrow - this is a secondary operation
    }
  }

  /// Update booking payment status to failed
  static Future<void> updateBookingPaymentFailure({
    required String bookingId,
    required String reason,
  }) async {
    try {
      developer.log(
        '📝 Updating booking payment failure: $bookingId',
        name: 'PaymentFirestoreService',
      );

      // Try updating in request_tracking collection
      final trackingDoc = await _firestore
          .collection(_requestTrackingCollection)
          .doc(bookingId)
          .get();

      if (trackingDoc.exists) {
        await _firestore
            .collection(_requestTrackingCollection)
            .doc(bookingId)
            .update({
          'paymentStatus': 'failed',
          'paymentFailureReason': reason,
        });
      }

      // Also try updating in bookings collection
      final bookingDoc = await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        await _firestore
            .collection(_bookingsCollection)
            .doc(bookingId)
            .update({
          'paymentStatus': 'failed',
          'paymentFailureReason': reason,
        });
      }
    } catch (e) {
      developer.log(
        '❌ Error updating booking payment failure: $e',
        name: 'PaymentFirestoreService',
      );
      // Don't rethrow
    }
  }

  // ═══════════════════════════════════════════
  // GET PAYMENT
  // ═══════════════════════════════════════════

  /// Get payment by ID
  static Future<Payment?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(_paymentsCollection)
          .doc(paymentId)
          .get();

      if (!doc.exists) {
        developer.log(
          '⚠️ Payment not found: $paymentId',
          name: 'PaymentFirestoreService',
        );
        return null;
      }

      return Payment.fromFirestore(doc);
    } catch (e) {
      developer.log(
        '❌ Error getting payment: $e',
        name: 'PaymentFirestoreService',
      );
      return null;
    }
  }

  /// Get all payments for a booking
  static Future<List<Payment>> getPaymentsByBooking(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log(
        '❌ Error getting payments for booking: $e',
        name: 'PaymentFirestoreService',
      );
      return [];
    }
  }

  /// Get all payments for a user
  static Future<List<Payment>> getPaymentsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log(
        '❌ Error getting payments for user: $e',
        name: 'PaymentFirestoreService',
      );
      return [];
    }
  }

  // ═══════════════════════════════════════════
  // PAYMENT HISTORY & STATISTICS
  // ═══════════════════════════════════════════

  /// Get successful payments for a user
  static Future<List<Payment>> getSuccessfulPayments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'success')
          .orderBy('paidAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log(
        '❌ Error getting successful payments: $e',
        name: 'PaymentFirestoreService',
      );
      return [];
    }
  }

  /// Stream payments for a user (real-time updates)
  static Stream<List<Payment>> streamUserPayments(String userId) {
    return _firestore
        .collection(_paymentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromFirestore(doc))
            .toList());
  }

  /// Stream payment by ID (real-time updates)
  static Stream<Payment?> streamPayment(String paymentId) {
    return _firestore
        .collection(_paymentsCollection)
        .doc(paymentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Payment.fromFirestore(doc);
    });
  }
}
