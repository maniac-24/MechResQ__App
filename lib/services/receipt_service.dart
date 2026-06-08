// lib/services/receipt_service.dart
// Firestore CRUD for receipts collection.

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receipt.dart';

class ReceiptService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'receipts';

  // ─── CREATE ────────────────────────────────────────────────

  /// Persist a new receipt and return its Firestore ID.
  static Future<String> createReceipt(ServiceReceipt receipt) async {
    try {
      final ref = await _db.collection(_col).add(receipt.toMap());
      developer.log('✅ Receipt created: ${ref.id}', name: 'ReceiptService');
      return ref.id;
    } catch (e) {
      developer.log('❌ createReceipt error: $e', name: 'ReceiptService');
      rethrow;
    }
  }

  // ─── READ ──────────────────────────────────────────────────

  /// Fetch a single receipt by its Firestore document ID.
  static Future<ServiceReceipt?> getReceipt(String receiptId) async {
    try {
      final doc = await _db.collection(_col).doc(receiptId).get();
      if (!doc.exists) return null;
      return ServiceReceipt.fromFirestore(doc);
    } catch (e) {
      developer.log('❌ getReceipt error: $e', name: 'ReceiptService');
      return null;
    }
  }

  /// Fetch the receipt linked to a request (returns null if none).
  static Future<ServiceReceipt?> getReceiptByRequest(String requestId) async {
    try {
      final snap = await _db
          .collection(_col)
          .where('requestId', isEqualTo: requestId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return ServiceReceipt.fromFirestore(snap.docs.first);
    } catch (e) {
      developer.log('❌ getReceiptByRequest error: $e', name: 'ReceiptService');
      return null;
    }
  }

  /// Real-time stream of the receipt for a given request.
  static Stream<ServiceReceipt?> streamReceiptByRequest(String requestId) {
    return _db
        .collection(_col)
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : ServiceReceipt.fromFirestore(snap.docs.first));
  }

  /// All receipts for the currently signed-in user (real-time).
  static Stream<List<ServiceReceipt>> streamUserReceipts() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection(_col)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ServiceReceipt.fromFirestore).toList());
  }

  // ─── UPDATE ────────────────────────────────────────────────

  /// Mark receipt as paid after digital payment succeeds.
  static Future<void> markPaidDigital({
    required String receiptId,
    required String razorpayPaymentId,
    String? razorpayOrderId,
  }) async {
    try {
      await _db.collection(_col).doc(receiptId).update({
        'status': 'paid',
        'paymentMethod': 'digital',
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'paidAt': FieldValue.serverTimestamp(),
      });
      developer.log('✅ Receipt marked paid (digital): $receiptId',
          name: 'ReceiptService');
    } catch (e) {
      developer.log('❌ markPaidDigital error: $e', name: 'ReceiptService');
      rethrow;
    }
  }

  /// Mark receipt as paid by cash (triggered by mechanic app or admin).
  static Future<void> markPaidCash(String receiptId) async {
    try {
      await _db.collection(_col).doc(receiptId).update({
        'status': 'paid',
        'paymentMethod': 'cash',
        'paidAt': FieldValue.serverTimestamp(),
      });
      developer.log('✅ Receipt marked paid (cash): $receiptId',
          name: 'ReceiptService');
    } catch (e) {
      developer.log('❌ markPaidCash error: $e', name: 'ReceiptService');
      rethrow;
    }
  }

  // ─── DELETE ────────────────────────────────────────────────

  /// Delete a receipt (user initiated, e.g. clearing history).
  static Future<void> deleteReceipt(String receiptId) async {
    try {
      await _db.collection(_col).doc(receiptId).delete();
      developer.log('🗑 Receipt deleted: $receiptId', name: 'ReceiptService');
    } catch (e) {
      developer.log('❌ deleteReceipt error: $e', name: 'ReceiptService');
      rethrow;
    }
  }
}
