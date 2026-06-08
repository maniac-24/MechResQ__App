// Debug screen to check payment status
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../services/payment_firestore_service.dart';

class PaymentDebugScreen extends StatefulWidget {
  const PaymentDebugScreen({super.key});

  @override
  State<PaymentDebugScreen> createState() => _PaymentDebugScreenState();
}

class _PaymentDebugScreenState extends State<PaymentDebugScreen> {
  final TextEditingController _bookingIdController = TextEditingController(
    text: 'tQMTVmXe9HXWmRFLPKI4', // Your booking ID
  );
  
  String _result = '';
  bool _isLoading = false;

  Future<void> _checkPayments() async {
    setState(() {
      _isLoading = true;
      _result = 'Checking...';
    });

    try {
      final bookingId = _bookingIdController.text.trim();
      developer.log('🔍 Checking payments for booking: $bookingId');

      final payments = await PaymentFirestoreService.getPaymentsByBooking(bookingId);

      final buffer = StringBuffer();
      buffer.writeln('📊 PAYMENT CHECK RESULTS\n');
      buffer.writeln('Booking ID: $bookingId');
      buffer.writeln('Found ${payments.length} payment(s)\n');

      if (payments.isEmpty) {
        buffer.writeln('⚠️ No payments found!');
        buffer.writeln('\nPossible reasons:');
        buffer.writeln('1. Booking ID is incorrect');
        buffer.writeln('2. Payments are in different collection');
        buffer.writeln('3. BookingId field mismatch');
      } else {
        double totalPaid = 0;
        for (var i = 0; i < payments.length; i++) {
          final p = payments[i];
          buffer.writeln('Payment ${i + 1}:');
          buffer.writeln('  ID: ${p.id}');
          buffer.writeln('  Amount: ₹${p.amount}');
          buffer.writeln('  Status: ${p.statusDisplay}');
          buffer.writeln('  Razorpay ID: ${p.razorpayPaymentId ?? "N/A"}');
          buffer.writeln('  Created: ${p.createdAt}');
          if (p.isSuccess) {
            totalPaid += p.amount;
          }
          buffer.writeln('');
        }

        buffer.writeln('💰 Total Successful Payments: ₹$totalPaid');
        buffer.writeln('📈 Expected Full Amount: ₹2000');
        
        if (totalPaid >= 2000) {
          buffer.writeln('\n✅ PAYMENT COMPLETE!');
        } else {
          buffer.writeln('\n⏳ Payment Incomplete');
          buffer.writeln('   Remaining: ₹${2000 - totalPaid}');
        }
      }

      setState(() {
        _result = buffer.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ ERROR:\n${e.toString()}';
        _isLoading = false;
      });
      developer.log('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Check Payment Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bookingIdController,
              decoration: const InputDecoration(
                labelText: 'Booking ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkPayments,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Check Payments'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result.isEmpty ? 'Results will appear here...' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _result.isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: _result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Results'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }
}
