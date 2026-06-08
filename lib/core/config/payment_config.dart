// lib/core/config/payment_config.dart
//
// Razorpay payment configuration for MechResQ
// Contains API keys and payment settings

class PaymentConfig {
  // ═══════════════════════════════════════════
  // RAZORPAY TEST MODE CREDENTIALS
  // ═══════════════════════════════════════════
  
  /// Razorpay Test Key ID
  /// TODO: Replace with production key when going live
  /// Get production key from: https://dashboard.razorpay.com/app/keys
  static const String razorpayKeyId = 'rzp_test_SypZde9zVDIpoJ';
  
  /// Razorpay Test Key Secret (Keep this secure, never expose in client)
  /// Only use on secure backend/server
  /// This is included here for reference only - DO NOT use in production client code
  static const String razorpayKeySecret = '7rmPAnRxqMzvjHprbHqW6cz7';

  // ═══════════════════════════════════════════
  // PAYMENT SETTINGS
  // ═══════════════════════════════════════════
  
  /// Company/App name displayed on Razorpay checkout
  static const String companyName = 'MechResQ';
  
  /// Company description
  static const String companyDescription = 'On-demand mechanic services';
  
  /// Company logo URL (optional)
  /// TODO: Upload company logo and add URL here
  static const String? companyLogoUrl = null;
  
  /// Currency code (INR for Indian Rupees)
  static const String currency = 'INR';
  
  /// Contact email for payment queries
  static const String contactEmail = 'support@mechresq.com';
  
  /// Contact phone for payment queries
  static const String contactPhone = '+919876543210';

  // ═══════════════════════════════════════════
  // PAYMENT AMOUNTS (in smallest currency unit - paise for INR)
  // ═══════════════════════════════════════════
  
  /// Minimum advance payment amount (in rupees)
  static const double minAdvanceAmount = 100.0;
  
  /// Default advance payment percentage (50%)
  static const double defaultAdvancePercentage = 0.5;
  
  /// Convert amount from rupees to paise (smallest unit for Razorpay)
  static int convertToPaise(double amountInRupees) {
    return (amountInRupees * 100).round();
  }
  
  /// Convert amount from paise to rupees
  static double convertToRupees(int amountInPaise) {
    return amountInPaise / 100.0;
  }

  // ═══════════════════════════════════════════
  // PAYMENT FEATURES
  // ═══════════════════════════════════════════
  
  /// Enable retry on payment failure
  static const bool enableRetry = true;
  
  /// Maximum payment retry attempts
  static const int maxRetryAttempts = 3;
  
  /// Payment timeout in seconds
  static const int paymentTimeoutSeconds = 300; // 5 minutes
  
  /// Auto-capture payment (true = auto-capture, false = manual capture)
  static const bool autoCapture = true;

  // ═══════════════════════════════════════════
  // PAYMENT METHODS
  // ═══════════════════════════════════════════
  
  /// Available payment methods
  static const List<String> paymentMethods = [
    'card',
    'netbanking',
    'wallet',
    'upi',
  ];

  // ═══════════════════════════════════════════
  // TEST MODE INDICATORS
  // ═══════════════════════════════════════════
  
  /// Is test mode active
  static const bool isTestMode = true;
  
  /// Test mode banner message
  static const String testModeBanner = '🧪 TEST MODE - No real money will be charged';
  
  /// Get environment-specific message
  static String get environmentMessage {
    return isTestMode 
        ? 'Running in TEST mode. Use test cards for payment.'
        : 'Running in LIVE mode. Real transactions will be processed.';
  }

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════
  
  /// Validate amount is within acceptable range
  static bool isValidAmount(double amount) {
    return amount >= minAdvanceAmount;
  }
  
  /// Calculate advance amount from total
  static double calculateAdvanceAmount(double totalAmount) {
    final advance = totalAmount * defaultAdvancePercentage;
    return advance < minAdvanceAmount ? minAdvanceAmount : advance;
  }
  
  /// Format amount for display
  static String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
  
  /// Format amount in paise for display
  static String formatAmountFromPaise(int amountInPaise) {
    return formatAmount(convertToRupees(amountInPaise));
  }

  // ═══════════════════════════════════════════
  // PRODUCTION CHECKLIST
  // ═══════════════════════════════════════════
  
  /// Production deployment checklist
  /// 
  /// Before going live:
  /// 1. Replace razorpayKeyId with production key from Razorpay dashboard
  /// 2. Set isTestMode = false
  /// 3. Remove razorpayKeySecret from client code (use server-side only)
  /// 4. Update contactEmail and contactPhone
  /// 5. Add company logo URL
  /// 6. Test all payment flows thoroughly
  /// 7. Implement proper error handling and logging
  /// 8. Set up webhook handlers on server for payment verification
  /// 9. Implement proper security measures (SSL, key management)
  /// 10. Review Razorpay compliance requirements
}
