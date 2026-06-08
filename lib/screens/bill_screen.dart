// lib/screens/bill_screen.dart
//
// TWO MODES:
//   mode = BillMode.estimate  → shown right after request creation.
//          Displays the cost estimate. Buttons: Track Mechanic | Cancel Request
//
//   mode = BillMode.payment   → shown from History tab after service is done.
//          Displays the bill with payment buttons: Pay by Cash | Pay Digitally

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../services/billing_service.dart';
import '../services/receipt_service.dart';
import '../services/request_firestore_service.dart';
import '../services/razorpay_service.dart';
import '../core/config/payment_config.dart';

enum BillMode { estimate, payment }

class BillScreen extends StatefulWidget {
  final String requestId;
  final String vehicleType;
  final String issueDescription;
  final String serviceLocation;
  final double distanceKm;
  /// estimate = shown after request creation (no payment yet)
  /// payment  = shown from history after service done
  final BillMode mode;

  const BillScreen({
    super.key,
    required this.requestId,
    required this.vehicleType,
    required this.issueDescription,
    required this.serviceLocation,
    this.distanceKm = 5.0,
    this.mode = BillMode.estimate,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  late final ServiceBill _bill;
  final RazorpayService _razorpayService = RazorpayService();
  final RequestFirestoreService _requestService = RequestFirestoreService();

  bool _isProcessing = false;
  String? _pendingReceiptId;

  @override
  void initState() {
    super.initState();
    _bill = BillingService.calculate(
      requestId: widget.requestId,
      vehicleType: widget.vehicleType,
      issue: widget.issueDescription,
      distanceKm: widget.distanceKm,
    );

    _razorpayService.initialize(
      onPaymentSuccess: _handleRazorpaySuccess,
      onPaymentError: _handleRazorpayError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  // ─── ESTIMATE MODE ACTIONS ────────────────────────────────

  Future<void> _cancelRequest() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          const Icon(Icons.cancel_outlined, color: Colors.red, size: 26),
          const SizedBox(width: 10),
          Text(l10n.billCancelConfirmTitle),
        ]),
        content: Text(l10n.billCancelConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.billKeepRequest),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.billYesCancel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await _requestService.cancelRequest(widget.requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.billRequestCancelledSuccess),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/my_requests', (r) => false);
      }
    } catch (e) {
      developer.log('❌ Cancel error: $e', name: 'BillScreen');
      if (mounted) _showError(l10n.billCouldNotCancel);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── PAY BY CASH ──────────────────────────────────────────

  Future<void> _payCash() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final receipt = ServiceReceipt.fromBill(
        id: '',
        userId: uid,
        bill: _bill,
        serviceLocation: widget.serviceLocation,
        paymentMethod: ReceiptPaymentMethod.cash,
      );
      final receiptId = await ReceiptService.createReceipt(receipt);
      developer.log('💵 Cash receipt created: $receiptId', name: 'BillScreen');
      if (mounted) {
        _showCashConfirmation(receiptId);
      }
    } catch (e) {
      developer.log('❌ Cash receipt error: $e', name: 'BillScreen');
      if (mounted) {
        _showError(l10n.billCouldNotSavePayment);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── PAY DIGITALLY (RAZORPAY) ─────────────────────────────

  Future<void> _payDigital() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Please log in to continue.');
        return;
      }

      // Create a pending receipt first so we can update it on success
      final receipt = ServiceReceipt.fromBill(
        id: '',
        userId: user.uid,
        bill: _bill,
        serviceLocation: widget.serviceLocation,
        paymentMethod: ReceiptPaymentMethod.digital,
      );
      final receiptId = await ReceiptService.createReceipt(receipt);
      _pendingReceiptId = receiptId;

      // Open Razorpay checkout
      _razorpayService.openCheckout(
        amount: _bill.totalAmount,
        bookingId: widget.requestId,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? 'user@mechresq.com',
        userPhone: user.phoneNumber ?? '+919876543210',
        description: 'MechResQ — ${widget.vehicleType} service',
      );
    } catch (e) {
      developer.log('❌ Digital payment error: $e', name: 'BillScreen');
      if (mounted) _showError(l10n.billPaymentInitFailed);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── RAZORPAY CALLBACKS ───────────────────────────────────

  Future<void> _handleRazorpaySuccess(PaymentSuccessResponse res) async {
    developer.log('✅ Razorpay success: ${res.paymentId}', name: 'BillScreen');
    try {
      if (_pendingReceiptId != null) {
        await ReceiptService.markPaidDigital(
          receiptId: _pendingReceiptId!,
          razorpayPaymentId: res.paymentId ?? '',
          razorpayOrderId: res.orderId,
        );
      }
      if (mounted) {
        _navigateToReceiptSuccess(_pendingReceiptId ?? '', res.paymentId ?? '');
      }
    } catch (e) {
      developer.log('❌ Receipt update error: $e', name: 'BillScreen');
      // Payment went through — still show success
      if (mounted) {
        _navigateToReceiptSuccess(_pendingReceiptId ?? '', res.paymentId ?? '');
      }
    }
  }

  Future<void> _handleRazorpayError(PaymentFailureResponse res) async {
    developer.log('❌ Razorpay error: ${res.message}', name: 'BillScreen');
    if (mounted) {
      final msg = RazorpayService.getErrorMessage(res);
      _showError(msg);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse res) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening ${res.walletName}...')),
      );
    }
  }

  // ─── NAVIGATION ───────────────────────────────────────────

  void _navigateToReceiptSuccess(String receiptId, String paymentId) {
    Navigator.pushReplacementNamed(
      context,
      '/receipt_success',
      arguments: {
        'receiptId': receiptId,
        'paymentId': paymentId,
        'amount': _bill.totalAmount,
        'vehicleType': widget.vehicleType,
        'requestId': widget.requestId,
      },
    );
  }

  void _showCashConfirmation(String receiptId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.payments_outlined, color: Colors.teal, size: 28),
          const SizedBox(width: 10),
          Text(l10n.billCashPaymentSelected),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.billCashAmountDue}${BillingService.formatAmount(_bill.totalAmount)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.billCashInstruction,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(
                context,
                '/my_requests',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.billGotIt),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == BillMode.estimate
            ? l10n.billServiceEstimate
            : l10n.billServiceBillPayment),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Test mode banner (only in payment mode)
                    if (widget.mode == BillMode.payment &&
                        RazorpayService.isTestMode)
                      RazorpayService.buildTestModeBanner(context),
                    if (widget.mode == BillMode.payment &&
                        RazorpayService.isTestMode)
                      const SizedBox(height: 16),

                    // Header logo + label
                    _buildHeader(scheme, l10n),
                    const SizedBox(height: 20),

                    // Estimate mode info banner
                    if (widget.mode == BillMode.estimate)
                      _buildEstimateInfoBanner(scheme, l10n),
                    if (widget.mode == BillMode.estimate)
                      const SizedBox(height: 16),

                    // Request summary
                    _buildRequestSummaryCard(scheme, l10n),
                    const SizedBox(height: 16),

                    // Complexity badge
                    _buildComplexityBadge(scheme, l10n),
                    const SizedBox(height: 16),

                    // Itemised breakdown
                    _buildBreakdownCard(scheme, l10n),
                    const SizedBox(height: 16),

                    // GST note
                    _buildGstNote(scheme, l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom buttons — different per mode
            widget.mode == BillMode.estimate
                ? _buildEstimateButtons(scheme, l10n)
                : _buildPaymentButtons(scheme, l10n),
          ],
        ),
      ),
    );
  }

  // ─── WIDGETS ──────────────────────────────────────────────

  Widget _buildHeader(ColorScheme scheme, AppLocalizations l10n) {
    final isEstimate = widget.mode == BillMode.estimate;
    return Row(
      children: [
        Image.asset(
          'assets/mechresq_logo.png',
          height: 48,
          width: 48,
          errorBuilder: (ctx, err, stack) => Icon(
            Icons.build_circle,
            size: 48,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MechResQ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            Text(
              isEstimate ? l10n.billServiceEstimate : l10n.billBillLabel,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isEstimate ? Colors.orange : Colors.green)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isEstimate ? l10n.billEstimateLabel : l10n.billBillLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isEstimate ? Colors.orange.shade700 : Colors.green.shade700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '#${widget.requestId.substring(0, 8).toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Info banner shown in estimate mode
  Widget _buildEstimateInfoBanner(ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.billEstimateInfoTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.billEstimateInfoBody,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ESTIMATE MODE BOTTOM BUTTONS ─────────────────────────

  Widget _buildEstimateButtons(ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Estimated total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.billEstimatedTotal,
                  style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.6))),
              Text(
                BillingService.formatAmount(_bill.totalAmount),
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info banner — mechanic tracking in Active tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location,
                    size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.billTrackingInfo,
                    style: TextStyle(
                        fontSize: 12,
                        color: scheme.primary.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Cancel Request button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _cancelRequest,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cancel_outlined),
              label: Text(
                l10n.billCancelRequest,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.billPaymentAfterService,
            style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.45)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummaryCard(ColorScheme scheme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.billRequestDetails,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface)),
            const Divider(height: 20),
            _detailRow(Icons.directions_car, l10n.billVehicle, widget.vehicleType),
            const SizedBox(height: 8),
            _detailRow(Icons.build, l10n.billIssue,
                widget.issueDescription.length > 80
                    ? '${widget.issueDescription.substring(0, 80)}…'
                    : widget.issueDescription),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on, l10n.billLocation,
                widget.serviceLocation.isEmpty
                    ? l10n.yourLocation
                    : widget.serviceLocation),
            const SizedBox(height: 8),
            _detailRow(Icons.social_distance, l10n.billDistance,
                '${widget.distanceKm.toStringAsFixed(1)} km'),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexityBadge(ColorScheme scheme, AppLocalizations l10n) {
    final badge = BillingService.complexityBadge(_bill.complexityLabel);
    final color = Color(badge.colorValue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.billComplexityPrefix}${_bill.complexityLabel}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14),
                ),
                if (_bill.detectedKeywords.isNotEmpty)
                  Text(
                    '${l10n.billDetected}${_bill.detectedKeywords.take(3).join(', ')}',
                    style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.6)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizeItemLabel(String label, AppLocalizations l10n) {
    switch (label) {
      case 'Base Service Charge':
        return l10n.billBaseServiceCharge;
      case 'Labour Charges':
        return l10n.billLabourCharges;
      case 'Call-Out / Travel Fee':
        return l10n.billCallOutFee;
      case 'Spare Parts (Estimate)':
        return l10n.billSpareParts;
      case 'Platform Fee':
        return l10n.billPlatformFee;
      case 'Sub-Total':
        return l10n.billSubTotal;
      case 'GST (18%)':
        return l10n.billGst;
      default:
        return label;
    }
  }

  Widget _buildBreakdownCard(ColorScheme scheme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.billPriceBreakdown,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface)),
            const Divider(height: 20),

            // Line items
            for (final item in _bill.lineItems)
              if (item.label != 'Sub-Total')
                _lineItemRow(
                  label: _localizeItemLabel(item.label, l10n),
                  description: item.description,
                  amount: item.amount,
                  scheme: scheme,
                  isTotal: false,
                ),

            const Divider(height: 24),

            // Sub-total
            _lineItemRow(
              label: l10n.billSubTotal,
              amount: _bill.subTotal,
              scheme: scheme,
              isTotal: false,
              isBold: true,
            ),

            // GST
            _lineItemRow(
              label: l10n.billGst,
              amount: _bill.gstAmount,
              scheme: scheme,
              isTotal: false,
            ),

            const Divider(height: 20, thickness: 2),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.billTotalAmount,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  BillingService.formatAmount(_bill.totalAmount),
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
    );
  }

  Widget _buildGstNote(ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16, color: scheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.billEstimateNote,
              style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons(ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              Text(l10n.billSubTotal,
                  style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface.withValues(alpha: 0.7))),
              Text(
                BillingService.formatAmount(_bill.totalAmount),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pay by Cash
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _payCash,
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.billPayByCash,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Pay Digitally
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _payDigital,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white),
                    )
                  : const Icon(Icons.credit_card),
              label: Text(
                _isProcessing
                    ? l10n.billProcessing
                    : '${l10n.billPayDigitally}  ${BillingService.formatAmount(_bill.totalAmount)}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            PaymentConfig.isTestMode
                ? l10n.billTestModeNote
                : l10n.billSecuredByRazorpay,
            style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.45)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _lineItemRow({
    required String label,
    String? description,
    required double amount,
    required ColorScheme scheme,
    bool isTotal = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTotal ? 15 : 13,
                    fontWeight: (isTotal || isBold)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: scheme.onSurface,
                  ),
                ),
                if (description != null)
                  Text(
                    description,
                    style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.5)),
                  ),
              ],
            ),
          ),
          Text(
            BillingService.formatAmount(amount),
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
                  (isTotal || isBold) ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? scheme.primary : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
