// lib/screens/payment_screen.dart
//
// Payment screen for MechResQ booking payments
// Displays booking details and initiates Razorpay payment flow

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/razorpay_service.dart';
import '../services/payment_firestore_service.dart';
import '../core/config/payment_config.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String? mechanicId;
  final String? mechanicName;
  final String serviceType;
  final String? vehicleInfo;
  final String? location;
  final double totalAmount;
  final bool isAdvancePayment;
  final String? bookingDescription;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.mechanicId,
    this.mechanicName,
    required this.serviceType,
    this.vehicleInfo,
    this.location,
    required this.totalAmount,
    this.isAdvancePayment = true,
    this.bookingDescription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final RazorpayService _razorpayService = RazorpayService();
  bool _isProcessing = false;
  String? _currentPaymentId;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════

  void _initializeRazorpay() {
    developer.log('🎬 Initializing Razorpay on Payment Screen', name: 'PaymentScreen');
    
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  // ═══════════════════════════════════════════
  // PAYMENT AMOUNT CALCULATION
  // ═══════════════════════════════════════════

  double get paymentAmount {
    if (widget.isAdvancePayment) {
      return RazorpayService.calculateAdvanceAmount(widget.totalAmount);
    }
    return widget.totalAmount;
  }

  String get paymentTypeLabel {
    return widget.isAdvancePayment ? 'Advance Payment' : 'Full Payment';
  }

  // ═══════════════════════════════════════════
  // PAYMENT INITIATION
  // ═══════════════════════════════════════════

  Future<void> _initiatePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('User not authenticated. Please login again.');
        setState(() => _isProcessing = false);
        return;
      }

      developer.log('💳 Initiating payment for booking: ${widget.bookingId}', name: 'PaymentScreen');

      // Create payment record in Firestore
      final paymentId = await PaymentFirestoreService.createPayment(
        bookingId: widget.bookingId,
        userId: user.uid,
        mechanicId: widget.mechanicId,
        amount: paymentAmount,
        description: widget.bookingDescription ?? 'Payment for ${widget.serviceType}',
      );

      _currentPaymentId = paymentId;
      developer.log('✅ Payment record created: $paymentId', name: 'PaymentScreen');

      // Get user details
      final userName = user.displayName ?? 'User';
      final userEmail = user.email ?? 'user@mechresq.com';
      final userPhone = user.phoneNumber ?? '+919876543210';

      // Open Razorpay checkout
      _razorpayService.openCheckout(
        amount: paymentAmount,
        bookingId: widget.bookingId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        description: widget.bookingDescription ?? 'Payment for ${widget.serviceType}',
      );

      setState(() => _isProcessing = false);
    } catch (e) {
      developer.log('❌ Error initiating payment: $e', name: 'PaymentScreen');
      setState(() => _isProcessing = false);
      _showErrorDialog('Failed to initiate payment. Please try again.');
    }
  }

  // ═══════════════════════════════════════════
  // PAYMENT EVENT HANDLERS
  // ═══════════════════════════════════════════

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    developer.log('✅ Payment successful: ${response.paymentId}', name: 'PaymentScreen');

    try {
      if (_currentPaymentId != null) {
        // Update payment record in Firestore
        await PaymentFirestoreService.updatePaymentSuccess(
          paymentId: _currentPaymentId!,
          razorpayPaymentId: response.paymentId ?? '',
          razorpayOrderId: response.orderId,
          razorpaySignature: response.signature,
        );

        // Update booking payment status
        await PaymentFirestoreService.updateBookingPaymentStatus(
          bookingId: widget.bookingId,
          paymentId: _currentPaymentId!,
          amount: paymentAmount,
        );

        developer.log('✅ Payment and booking updated successfully', name: 'PaymentScreen');
      }

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      developer.log('❌ Error updating payment success: $e', name: 'PaymentScreen');
      // Still show success to user since payment went through
      if (mounted) {
        _showSuccessDialog(response);
      }
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    developer.log('❌ Payment failed: ${response.code} - ${response.message}', name: 'PaymentScreen');

    try {
      if (_currentPaymentId != null) {
        // Update payment record with failure
        await PaymentFirestoreService.updatePaymentFailure(
          paymentId: _currentPaymentId!,
          errorCode: response.code.toString(),
          errorDescription: response.message ?? 'Payment failed',
        );

        // Update booking payment status
        await PaymentFirestoreService.updateBookingPaymentFailure(
          bookingId: widget.bookingId,
          reason: response.message ?? 'Payment failed',
        );
      }
    } catch (e) {
      developer.log('❌ Error updating payment failure: $e', name: 'PaymentScreen');
    }

    // Show error dialog
    if (mounted) {
      final errorMessage = RazorpayService.getErrorMessage(response);
      final canRetry = RazorpayService.isRecoverableError(response.code);
      _showFailureDialog(errorMessage, canRetry);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log('👛 External wallet selected: ${response.walletName}', name: 'PaymentScreen');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${response.walletName}...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════
  // DIALOG HELPERS
  // ═══════════════════════════════════════════

  void _showSuccessDialog(PaymentSuccessResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment ID: ${response.paymentId ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Amount Paid: ${RazorpayService.formatAmount(paymentAmount)}'),
            const SizedBox(height: 8),
            Text('Booking ID: ${widget.bookingId}'),
            const SizedBox(height: 16),
            const Text(
              'Your payment has been processed successfully. The mechanic will be notified.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to previous screen with success
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(String message, bool canRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Payment Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (canRetry) ...[
              const SizedBox(height: 16),
              const Text(
                'You can try again.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ],
        ),
        actions: [
          if (canRetry)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initiatePayment();
              },
              child: const Text('Retry'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(false); // Return to previous screen
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // UI BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Test Mode Banner
                    RazorpayService.buildTestModeBanner(context),
                    const SizedBox(height: 20),

                    // Booking Details Card
                    _buildBookingDetailsCard(),
                    const SizedBox(height: 20),

                    // Amount Breakdown Card
                    _buildAmountBreakdownCard(),
                    const SizedBox(height: 20),

                    // Test Cards Info (only in test mode)
                    if (RazorpayService.isTestMode)
                      _buildTestCardsInfo(),
                  ],
                ),
              ),
            ),

            // Bottom Payment Button
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.build, 'Service', widget.serviceType),
            if (widget.vehicleInfo != null)
              _buildDetailRow(Icons.directions_car, 'Vehicle', widget.vehicleInfo!),
            if (widget.location != null)
              _buildDetailRow(Icons.location_on, 'Location', widget.location!),
            if (widget.mechanicName != null)
              _buildDetailRow(Icons.person, 'Mechanic', widget.mechanicName!),
            _buildDetailRow(Icons.confirmation_number, 'Booking ID', widget.bookingId),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Service Amount'),
                Text(
                  RazorpayService.formatAmount(widget.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (widget.isAdvancePayment) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advance (${(PaymentConfig.defaultAdvancePercentage * 100).toInt()}%)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    RazorpayService.formatAmount(paymentAmount),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  paymentTypeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  RazorpayService.formatAmount(paymentAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCardsInfo() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline, color: Colors.blue),
        title: const Text(
          'Test Payment Cards',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: RazorpayService.getTestCards().map((card) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Number: ${card['number']}'),
                      Text('CVV: ${card['cvv']}'),
                      Text('Expiry: ${card['expiry']}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _initiatePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment),
                      const SizedBox(width: 8),
                      Text(
                        'Pay ${RazorpayService.formatAmount(paymentAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
