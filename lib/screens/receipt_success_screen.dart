// lib/screens/receipt_success_screen.dart
// Shown after a successful digital payment.
// Displays confirmation + links to view full receipt.

import 'package:flutter/material.dart';
import '../services/billing_service.dart';

class ReceiptSuccessScreen extends StatefulWidget {
  final String receiptId;
  final String paymentId;
  final double amount;
  final String vehicleType;
  final String requestId;

  const ReceiptSuccessScreen({
    super.key,
    required this.receiptId,
    required this.paymentId,
    required this.amount,
    required this.vehicleType,
    required this.requestId,
  });

  @override
  State<ReceiptSuccessScreen> createState() => _ReceiptSuccessScreenState();
}

class _ReceiptSuccessScreenState extends State<ReceiptSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                // Animated checkmark
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.green.shade400, width: 3),
                    ),
                    child: Icon(Icons.check_rounded,
                        size: 60, color: Colors.green.shade600),
                  ),
                ),
                const SizedBox(height: 24),

                // Logo
                Image.asset(
                  'assets/mechresq_logo.png',
                  height: 48,
                  errorBuilder: (ctx, err, stack) => Icon(
                    Icons.build_circle,
                    size: 48,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('MechResQ',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary)),
                const SizedBox(height: 24),

                // Amount
                Text(
                  BillingService.formatAmount(widget.amount),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 4),
                const Text('Payment Successful',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),

                // Details card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row('Payment ID', widget.paymentId),
                        const Divider(height: 20),
                        _row('Request ID',
                            '#${widget.requestId.substring(0, 8).toUpperCase()}'),
                        const Divider(height: 20),
                        _row('Vehicle', widget.vehicleType),
                        const Divider(height: 20),
                        _row('Method', 'Digital (Razorpay)'),
                        if (widget.receiptId.isNotEmpty) ...[
                          const Divider(height: 20),
                          _row('Receipt ID',
                              '#${widget.receiptId.substring(0, 8).toUpperCase()}'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // View Receipt button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/receipt_detail',
                        arguments: {
                          'receiptId': widget.receiptId,
                          'requestId': widget.requestId,
                        },
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View & Download Receipt',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Go to My Requests
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/my_requests', (r) => false),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View My Requests'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (r) => false),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
