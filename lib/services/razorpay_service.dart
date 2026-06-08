// lib/services/razorpay_service.dart
//
// Razorpay payment service for MechResQ
// Handles payment initialization, success, failure, and wallet events

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/config/payment_config.dart';

/// Razorpay Payment Service
/// Manages all Razorpay payment operations
class RazorpayService {
  late Razorpay _razorpay;
  
  // Callbacks
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  /// Initialize Razorpay service
  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    developer.log('🎬 Initializing Razorpay Service', name: 'RazorpayService');
    
    _razorpay = Razorpay();
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;

    // Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    developer.log('✅ Razorpay Service initialized successfully', name: 'RazorpayService');
  }

  // ═══════════════════════════════════════════
  // OPEN PAYMENT CHECKOUT
  // ═══════════════════════════════════════════

  /// Open Razorpay checkout screen
  /// 
  /// [amount] - Amount in rupees (will be converted to paise internally)
  /// [bookingId] - Unique booking/request ID
  /// [userName] - Name of the user making payment
  /// [userEmail] - Email of the user
  /// [userPhone] - Phone number of the user
  /// [description] - Payment description
  void openCheckout({
    required double amount,
    required String bookingId,
    required String userName,
    required String userEmail,
    required String userPhone,
    String? description,
  }) {
    developer.log(
      '💳 Opening Razorpay checkout for ₹$amount',
      name: 'RazorpayService',
    );

    // Validate amount
    if (!PaymentConfig.isValidAmount(amount)) {
      developer.log(
        '❌ Invalid amount: ₹$amount (minimum: ₹${PaymentConfig.minAdvanceAmount})',
        name: 'RazorpayService',
      );
      throw Exception('Amount must be at least ₹${PaymentConfig.minAdvanceAmount}');
    }

    // Convert amount to paise (smallest currency unit)
    final amountInPaise = PaymentConfig.convertToPaise(amount);
    
    developer.log(
      '📊 Payment details: Amount=₹$amount, AmountInPaise=$amountInPaise, BookingId=$bookingId',
      name: 'RazorpayService',
    );

    var options = {
      'key': PaymentConfig.razorpayKeyId,
      'amount': amountInPaise, // amount in paise
      'currency': PaymentConfig.currency,
      'name': PaymentConfig.companyName,
      'description': description ?? 'Payment for booking #$bookingId',
      'timeout': PaymentConfig.paymentTimeoutSeconds,
      'retry': {'enabled': PaymentConfig.enableRetry, 'max_count': PaymentConfig.maxRetryAttempts},
      
      // Prefill customer details
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      
      // Notes (for internal reference)
      'notes': {
        'booking_id': bookingId,
        'app_name': PaymentConfig.companyName,
        'payment_type': 'advance',
      },
      
      // Theme customization
      'theme': {
        'color': '#FF6B35', // MechResQ primary color
      },
      
      // Additional options
      'send_sms_hash': true,
      'remember_customer': false,
      'readonly': {
        'contact': false,
        'email': false,
      },
      
      // Order details (optional - for better tracking)
      'order_id': null, // Can be generated from backend if needed
    };

    // Add logo if available
    if (PaymentConfig.companyLogoUrl != null) {
      options['image'] = PaymentConfig.companyLogoUrl;
    }

    try {
      _razorpay.open(options);
      developer.log('🚀 Razorpay checkout opened', name: 'RazorpayService');
    } catch (e) {
      developer.log('❌ Error opening checkout: $e', name: 'RazorpayService');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // EVENT HANDLERS
  // ═══════════════════════════════════════════

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    developer.log(
      '✅ Payment Success: PaymentId=${response.paymentId}, OrderId=${response.orderId}, Signature=${response.signature}',
      name: 'RazorpayService',
    );
    
    if (_onPaymentSuccess != null) {
      _onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log(
      '❌ Payment Error: Code=${response.code}, Message=${response.message}',
      name: 'RazorpayService',
    );
    
    if (_onPaymentError != null) {
      _onPaymentError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log(
      '👛 External Wallet Selected: ${response.walletName}',
      name: 'RazorpayService',
    );
    
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  /// Calculate advance payment amount
  static double calculateAdvanceAmount(double totalAmount) {
    return PaymentConfig.calculateAdvanceAmount(totalAmount);
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return PaymentConfig.formatAmount(amount);
  }

  /// Check if amount is valid
  static bool isValidAmount(double amount) {
    return PaymentConfig.isValidAmount(amount);
  }

  /// Get minimum payment amount
  static double get minAmount => PaymentConfig.minAdvanceAmount;

  /// Get test mode status
  static bool get isTestMode => PaymentConfig.isTestMode;

  /// Get test mode banner message
  static String get testModeBanner => PaymentConfig.testModeBanner;

  // ═══════════════════════════════════════════
  // PAYMENT ERROR HELPERS
  // ═══════════════════════════════════════════

  /// Get user-friendly error message
  static String getErrorMessage(PaymentFailureResponse response) {
    switch (response.code) {
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your internet connection and try again.';
      case Razorpay.INVALID_OPTIONS:
        return 'Invalid payment configuration. Please contact support.';
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment cancelled by user.';
      case Razorpay.TLS_ERROR:
        return 'Security error. Please update your device and try again.';
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return 'Payment plugin incompatible. Please update the app.';
      case Razorpay.UNKNOWN_ERROR:
      default:
        return response.message ?? 'Payment failed. Please try again.';
    }
  }

  /// Check if error is recoverable (user can retry)
  static bool isRecoverableError(int? code) {
    return code == Razorpay.NETWORK_ERROR ||
           code == Razorpay.PAYMENT_CANCELLED;
  }

  // ═══════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════

  /// Clean up and dispose Razorpay instance
  /// IMPORTANT: Call this when the screen is disposed
  void dispose() {
    developer.log('🧹 Disposing Razorpay Service', name: 'RazorpayService');
    
    try {
      _razorpay.clear();
      developer.log('✅ Razorpay Service disposed successfully', name: 'RazorpayService');
    } catch (e) {
      developer.log('⚠️ Error disposing Razorpay: $e', name: 'RazorpayService');
    }
  }

  // ═══════════════════════════════════════════
  // TEST MODE HELPERS
  // ═══════════════════════════════════════════

  /// Show test mode banner (for UI)
  static Widget buildTestModeBanner(BuildContext context) {
    if (!isTestMode) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(color: Colors.amber.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.science, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              testModeBanner,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get test card numbers for testing
  static List<Map<String, String>> getTestCards() {
    return [
      {
        'name': 'Successful Payment',
        'number': '4111 1111 1111 1111',
        'cvv': 'Any',
        'expiry': 'Any future date',
      },
      {
        'name': 'Failed Payment',
        'number': '4000 0000 0000 0002',
        'cvv': 'Any',
        'expiry': 'Any future date',
      },
      {
        'name': 'UPI',
        'number': 'success@razorpay',
        'cvv': '-',
        'expiry': '-',
      },
    ];
  }
}
