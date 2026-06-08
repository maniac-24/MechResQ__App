// lib/widgets/payment_quick_action_button.dart
//
// Reusable payment button widget that can be added to any screen

import 'package:flutter/material.dart';
import '../screens/payment_screen.dart';

/// Quick action button for initiating payment
/// Can be added to any screen where payment is needed
class PaymentQuickActionButton extends StatelessWidget {
  final String bookingId;
  final String? mechanicId;
  final String? mechanicName;
  final String serviceType;
  final String? vehicleInfo;
  final String? location;
  final double totalAmount;
  final bool isAdvancePayment;
  final String? description;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const PaymentQuickActionButton({
    super.key,
    required this.bookingId,
    this.mechanicId,
    this.mechanicName,
    required this.serviceType,
    this.vehicleInfo,
    this.location,
    required this.totalAmount,
    this.isAdvancePayment = true,
    this.description,
    this.onPaymentSuccess,
    this.onPaymentFailed,
  });

  Future<void> _handlePayment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingId: bookingId,
          mechanicId: mechanicId,
          mechanicName: mechanicName,
          serviceType: serviceType,
          vehicleInfo: vehicleInfo,
          location: location,
          totalAmount: totalAmount,
          isAdvancePayment: isAdvancePayment,
          bookingDescription: description,
        ),
      ),
    );

    if (result == true) {
      // Payment successful
      if (onPaymentSuccess != null) {
        onPaymentSuccess!();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Payment failed or cancelled
      if (onPaymentFailed != null) {
        onPaymentFailed!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedAmount = isAdvancePayment 
        ? totalAmount * 0.5 
        : totalAmount;
    
    return ElevatedButton.icon(
      onPressed: () => _handlePayment(context),
      icon: const Icon(Icons.payment),
      label: Text(
        'Pay ₹${calculatedAmount.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}

/// Compact payment button (smaller version)
class PaymentCompactButton extends StatelessWidget {
  final String bookingId;
  final double totalAmount;
  final bool isAdvancePayment;
  final VoidCallback? onPaymentSuccess;

  const PaymentCompactButton({
    super.key,
    required this.bookingId,
    required this.totalAmount,
    this.isAdvancePayment = true,
    this.onPaymentSuccess,
  });

  Future<void> _handlePayment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingId: bookingId,
          serviceType: 'Service',
          totalAmount: totalAmount,
          isAdvancePayment: isAdvancePayment,
        ),
      ),
    );

    if (result == true && onPaymentSuccess != null) {
      onPaymentSuccess!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = isAdvancePayment ? totalAmount * 0.5 : totalAmount;
    
    return TextButton.icon(
      onPressed: () => _handlePayment(context),
      icon: const Icon(Icons.payment, size: 18),
      label: Text('Pay ₹${amount.toStringAsFixed(0)}'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFF6B35),
      ),
    );
  }
}

/// Payment status indicator with optional action button
class PaymentStatusIndicator extends StatelessWidget {
  final String paymentStatus;
  final String bookingId;
  final double? totalAmount;
  final double? paidAmount;
  final VoidCallback? onPayNow;

  const PaymentStatusIndicator({
    super.key,
    required this.paymentStatus,
    required this.bookingId,
    this.totalAmount,
    this.paidAmount,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    bool showPayButton = false;

    switch (paymentStatus.toLowerCase()) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Paid';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Payment Pending';
        showPayButton = true;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Payment Failed';
        showPayButton = true;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.payment;
        statusText = 'No Payment';
        showPayButton = true;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (paidAmount != null && totalAmount != null)
                  Text(
                    '₹${paidAmount!.toStringAsFixed(0)} / ₹${totalAmount!.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: statusColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (showPayButton && onPayNow != null)
            ElevatedButton(
              onPressed: onPayNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Pay Now'),
            ),
        ],
      ),
    );
  }
}
