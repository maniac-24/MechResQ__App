// lib/screens/bill_approval_screen.dart
//
// Shown when the mechanic submits the final bill (billStatus == 'awaiting_payment').
// User reviews the itemised breakdown, optionally disputes, then approves.
// Approval writes billStatus: 'approved' to Firestore → navigates to BillScreen
// in payment mode so Razorpay / cash flow runs as normal.

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/billing_service.dart';

class BillApprovalScreen extends StatefulWidget {
  const BillApprovalScreen({
    super.key,
    required this.requestId,
    required this.vehicleType,
    required this.issueDescription,
    this.serviceLocation = '',
    this.distanceKm = 5.0,
  });

  final String requestId;
  final String vehicleType;
  final String issueDescription;
  final String serviceLocation;
  final double distanceKm;

  @override
  State<BillApprovalScreen> createState() => _BillApprovalScreenState();
}

class _BillApprovalScreenState extends State<BillApprovalScreen> {
  bool _approving = false;

  // ── Approve & write to Firestore ──────────────────────────
  Future<void> _approveBill() async {
    setState(() => _approving = true);
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'billStatus': 'approved',
        'billApproved': true,
        'billApprovedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      // Navigate to BillScreen in payment mode; replace so back doesn't loop.
      Navigator.pushReplacementNamed(
        context,
        '/bill',
        arguments: {
          'requestId': widget.requestId,
          'vehicleType': widget.vehicleType,
          'issueDescription': widget.issueDescription,
          'serviceLocation': widget.serviceLocation,
          'distanceKm': widget.distanceKm,
          'mode': 'payment',
        },
      );
    } catch (e) {
      developer.log('Bill approval error: $e', name: 'BillApprovalScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not approve bill. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  // ── Dispute dialog ────────────────────────────────────────
  void _showDisputeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dispute Bill'),
        content: const Text(
          'If you believe this bill is incorrect, please contact our support team:\n\n'
          '📧 support@mechresq.com\n'
          '📞 1800-MECHRESQ\n\n'
          'Quote your Request ID when reaching out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Bill'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snap) {
          // ── Loading ──
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: scheme.primary));
          }

          // ── Error / missing ──
          if (snap.hasError || !snap.hasData || !snap.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: scheme.error, size: 48),
                  const SizedBox(height: 16),
                  const Text('Could not load bill. Please try again.'),
                ],
              ),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final fb = data['finalBill'] as Map<String, dynamic>?;
          final billStatus = data['billStatus'] as String?;
          final servicePhotoUrl = data['servicePhotoUrl'] as String?;

          // ── Final bill not yet submitted ──
          if (fb == null || fb.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty,
                        size: 56, color: scheme.onSurface.withOpacity(0.4)),
                    const SizedBox(height: 20),
                    Text(
                      'Waiting for the mechanic to submit the bill…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Already approved — go straight to payment ──
          if (billStatus == 'approved' || billStatus == 'paid' ||
              billStatus == 'cash_pending') {
            // This screen should not be visible once approved;
            // show a minimal "go to payment" recovery state.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  '/bill',
                  arguments: {
                    'requestId': widget.requestId,
                    'vehicleType': widget.vehicleType,
                    'issueDescription': widget.issueDescription,
                    'serviceLocation': widget.serviceLocation,
                    'distanceKm': widget.distanceKm,
                    'mode': 'payment',
                  },
                );
              }
            });
            return Center(child: CircularProgressIndicator(color: scheme.primary));
          }

          // ── Helper: safe double read ──
          double d(String k) => (fb[k] as num?)?.toDouble() ?? 0;

          final base = d('baseServiceCharge');
          final labour = d('labourCharge');
          final callOut = d('callOutCharge');
          final partsTotal = d('partsTotal');
          final platformFee = d('platformFee');
          final gst = d('gstAmount');
          final total = d('totalAmount');
          final partsList =
              (fb['partsList'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
                  [];

          return SafeArea(
            child: Column(
              children: [
                // ── Scrollable breakdown ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_outlined,
                                  color: scheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Your mechanic has submitted the final bill',
                                  style: TextStyle(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Service photo (if taken) ──
                        if (servicePhotoUrl != null &&
                            servicePhotoUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              servicePhotoUrl,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Photo of completed work',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Itemised breakdown card ──
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price Breakdown',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const Divider(height: 20),

                                _row('Base Service Charge',
                                    BillingService.formatAmount(base), scheme),
                                _row('Labour Charge',
                                    BillingService.formatAmount(labour), scheme),
                                if (callOut > 0)
                                  _row('Call-Out / Travel',
                                      BillingService.formatAmount(callOut), scheme),

                                // Parts list
                                if (partsList.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Spare Parts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  for (final part in partsList)
                                    _row(
                                      '  • ${part['name'] ?? 'Part'}',
                                      BillingService.formatAmount(
                                          (part['cost'] as num?)?.toDouble() ??
                                              0),
                                      scheme,
                                      secondary: true,
                                    ),
                                  if (partsList.length > 1)
                                    _row(
                                      '  Parts Total',
                                      BillingService.formatAmount(partsTotal),
                                      scheme,
                                      secondary: true,
                                    ),
                                ],

                                _row('Platform Fee',
                                    BillingService.formatAmount(platformFee),
                                    scheme),

                                const Divider(height: 20),

                                _row(
                                  'GST (18%)',
                                  BillingService.formatAmount(gst),
                                  scheme,
                                ),

                                const Divider(height: 16, thickness: 2),

                                // Total — prominent
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Payable',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      BillingService.formatAmount(total),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // GST note
                        Text(
                          'Prices include 18% GST. Platform fee covers service guarantee.',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withOpacity(0.45),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Bottom action bar ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total reminder
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Due',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            BillingService.formatAmount(total),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dispute (secondary)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: _showDisputeDialog,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: const Text('Dispute Bill',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.error,
                            side: BorderSide(color: scheme.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Approve & Pay (primary)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _approving ? null : _approveBill,
                          icon: _approving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _approving
                                ? 'Approving…'
                                : 'Approve & Pay  ${BillingService.formatAmount(total)}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Row helpers ───────────────────────────────────────────
  Widget _row(String label, String amount, ColorScheme scheme,
      {bool secondary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: secondary ? 12 : 13,
              color: secondary
                  ? scheme.onSurface.withOpacity(0.6)
                  : scheme.onSurface,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: secondary ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: secondary
                  ? scheme.onSurface.withOpacity(0.6)
                  : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
