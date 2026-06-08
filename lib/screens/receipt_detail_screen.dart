// lib/screens/receipt_detail_screen.dart
//
// Full receipt viewer. Shows a professional receipt with MechResQ branding.
// Allows unlimited PDF download / share via system sheet.
//
// Accessed via:
//   • /receipt_detail route with {receiptId, requestId}
//   • "View Receipt" in History tab
//   • "View & Download Receipt" on ReceiptSuccessScreen

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receipt.dart';
import '../services/receipt_service.dart';
import '../services/pdf_receipt_service.dart';
import '../services/billing_service.dart';

class ReceiptDetailScreen extends StatefulWidget {
  /// Pass either [receiptId] (direct lookup) or [requestId] (lookup by request).
  final String? receiptId;
  final String? requestId;

  const ReceiptDetailScreen({
    super.key,
    this.receiptId,
    this.requestId,
  }) : assert(receiptId != null || requestId != null,
            'Provide receiptId or requestId');

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  ServiceReceipt? _receipt;
  bool _loading = true;
  bool _pdfGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      ServiceReceipt? r;
      if (widget.receiptId != null && widget.receiptId!.isNotEmpty) {
        r = await ReceiptService.getReceipt(widget.receiptId!);
      } else if (widget.requestId != null &&
          widget.requestId!.isNotEmpty) {
        r = await ReceiptService.getReceiptByRequest(widget.requestId!);
      }

      setState(() {
        _receipt = r;
        _loading = false;
        _error = r == null ? 'Receipt not found.' : null;
      });
    } catch (e) {
      developer.log('❌ Load receipt error: $e', name: 'ReceiptDetailScreen');
      setState(() {
        _loading = false;
        _error = 'Failed to load receipt. Please try again.';
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_receipt == null) return;
    setState(() => _pdfGenerating = true);
    try {
      await PdfReceiptService.shareOrSave(_receipt!);
    } catch (e) {
      developer.log('❌ PDF error: $e', name: 'ReceiptDetailScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate PDF. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pdfGenerating = false);
    }
  }

  Future<void> _printPreview() async {
    if (_receipt == null) return;
    setState(() => _pdfGenerating = true);
    try {
      await PdfReceiptService.printPreview(context, _receipt!);
    } catch (e) {
      developer.log('❌ Print error: $e', name: 'ReceiptDetailScreen');
    } finally {
      if (mounted) setState(() => _pdfGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        centerTitle: true,
        actions: [
          if (_receipt != null && !_pdfGenerating)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print / Preview',
              onPressed: _printPreview,
            ),
          if (_receipt != null)
            _pdfGenerating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Download PDF',
                    onPressed: _downloadPdf,
                  ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(scheme)
              : _buildReceipt(scheme),

      // Floating Download PDF button
      floatingActionButton: (_receipt != null && !_loading)
          ? FloatingActionButton.extended(
              onPressed: _pdfGenerating ? null : _downloadPdf,
              icon: _pdfGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_pdfGenerating ? 'Generating…' : 'Download PDF'),
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  // ─── ERROR STATE ──────────────────────────────────────────

  Widget _buildError(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 72, color: scheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: scheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadReceipt();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RECEIPT CONTENT ──────────────────────────────────────

  Widget _buildReceipt(ColorScheme scheme) {
    final r = _receipt!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrandHeader(scheme, r),
          const SizedBox(height: 16),
          _buildStatusBanner(scheme, r),
          const SizedBox(height: 16),
          _buildServiceCard(scheme, r),
          const SizedBox(height: 16),
          _buildBreakdownCard(scheme, r),
          const SizedBox(height: 16),
          _buildPaymentCard(scheme, r),
          const SizedBox(height: 16),
          _buildGstNote(scheme),
          const SizedBox(height: 24),
          _buildThankYou(scheme),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────

  Widget _buildBrandHeader(ColorScheme scheme, ServiceReceipt r) {
    final df = DateFormat('dd MMM yyyy, hh:mm a');
    final date = r.paidAt != null
        ? df.format(r.paidAt!)
        : df.format(r.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/mechresq_logo.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.build_circle,
                  size: 32, color: scheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MechResQ',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary)),
              Text('On-Demand Mechanic Services',
                  style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.55))),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('RECEIPT',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                      letterSpacing: 1.2)),
            ),
            const SizedBox(height: 4),
            Text(
              '#${r.requestId.substring(0, 8).toUpperCase()}',
              style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.5)),
            ),
            Text(
              date,
              style: TextStyle(
                  fontSize: 10,
                  color: scheme.onSurface.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ],
    );
  }

  // ─── STATUS BANNER ────────────────────────────────────────

  Widget _buildStatusBanner(ColorScheme scheme, ServiceReceipt r) {
    final isPaid = r.isPaid;
    final bgColor =
        isPaid ? Colors.green.shade50 : Colors.orange.shade50;
    final borderColor =
        isPaid ? Colors.green.shade400 : Colors.orange.shade400;
    final textColor =
        isPaid ? Colors.green.shade700 : Colors.orange.shade700;
    final label = isPaid ? '✓  PAID' : '⏳  PAYMENT PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(r.paymentMethodDisplay,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              if (r.isPaid && r.paidAt != null)
                Text(
                  DateFormat('dd MMM yyyy').format(r.paidAt!),
                  style: TextStyle(
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.7)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SERVICE INFO CARD ────────────────────────────────────

  Widget _buildServiceCard(ColorScheme scheme, ServiceReceipt r) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Service Details', scheme),
            const Divider(height: 20),
            _infoRow('Vehicle', r.vehicleType, Icons.directions_car,
                scheme),
            const SizedBox(height: 10),
            _infoRow('Issue', r.issueDescription, Icons.build, scheme),
            const SizedBox(height: 10),
            _infoRow(
                'Location',
                r.serviceLocation.isEmpty
                    ? 'Your location'
                    : r.serviceLocation,
                Icons.location_on,
                scheme),
            if (r.mechanicName != null) ...[
              const SizedBox(height: 10),
              _infoRow('Mechanic', r.mechanicName!, Icons.person,
                  scheme),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 18,
                    color: _complexityColor(r.complexityLabel)),
                const SizedBox(width: 8),
                Text('Complexity: ',
                    style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.6))),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _complexityColor(r.complexityLabel)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    r.complexityLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _complexityColor(r.complexityLabel)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── BREAKDOWN CARD ───────────────────────────────────────

  Widget _buildBreakdownCard(ColorScheme scheme, ServiceReceipt r) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Itemised Charges', scheme),
            const Divider(height: 20),
            _amountRow('Base Service Charge', r.baseServiceCharge,
                scheme),
            _amountRow(
                'Labour (${r.complexityLabel})', r.laborCharge, scheme),
            if (r.callOutCharge > 0)
              _amountRow(
                  'Call-Out / Travel Fee', r.callOutCharge, scheme),
            if (r.sparePartsActual > 0)
              _amountRow('Spare Parts', r.sparePartsActual, scheme),
            _amountRow('Platform Fee', r.platformFee, scheme),
            const Divider(height: 20),
            _amountRow('Sub-Total', r.subTotal, scheme, isBold: true),
            _amountRow('GST (18%)', r.gstAmount, scheme,
                color: scheme.onSurface.withValues(alpha: 0.55)),
            const Divider(height: 16, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL AMOUNT',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  BillingService.formatAmount(r.totalAmount),
                  style: const TextStyle(
                    fontSize: 22,
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

  // ─── PAYMENT INFO CARD ────────────────────────────────────

  Widget _buildPaymentCard(ColorScheme scheme, ServiceReceipt r) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Payment Information', scheme),
            const Divider(height: 20),
            _infoRow(
                'Method', r.paymentMethodDisplay, Icons.payment, scheme),
            const SizedBox(height: 10),
            _infoRow('Status', r.statusDisplay,
                r.isPaid ? Icons.check_circle : Icons.pending, scheme,
                valueColor:
                    r.isPaid ? Colors.green : Colors.orange),
            if (r.razorpayPaymentId != null &&
                r.razorpayPaymentId!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow('Transaction ID', r.razorpayPaymentId!,
                  Icons.tag, scheme),
            ],
            if (r.id.isNotEmpty) ...[
              const SizedBox(height: 10),
              _infoRow('Receipt ID',
                  r.id.substring(0, 12).toUpperCase(), Icons.receipt, scheme),
            ],
            if (r.paidAt != null) ...[
              const SizedBox(height: 10),
              _infoRow(
                  'Paid On',
                  DateFormat('dd MMM yyyy, hh:mm a').format(r.paidAt!),
                  Icons.calendar_today,
                  scheme),
            ],
          ],
        ),
      ),
    );
  }

  // ─── GST NOTE ─────────────────────────────────────────────

  Widget _buildGstNote(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 15,
              color: scheme.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This receipt is an estimate. Final charges may vary based on '
              'actual spare parts used. GST @ 18% is included in the total amount. '
              'For disputes contact support@mechresq.com',
              style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.55)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── THANK YOU ────────────────────────────────────────────

  Widget _buildThankYou(ColorScheme scheme) {
    return Column(
      children: [
        Image.asset(
          'assets/mechresq_logo.png',
          height: 36,
          errorBuilder: (ctx, err, stack) => Icon(
            Icons.build_circle,
            size: 36,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text('Thank you for choosing MechResQ!',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: scheme.primary)),
        const SizedBox(height: 4),
        Text('Drive safe. We\'re always here when you need us.',
            style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.55))),
      ],
    );
  }

  // ─── SMALL HELPERS ────────────────────────────────────────

  Widget _sectionTitle(String title, ColorScheme scheme) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface),
    );
  }

  Widget _infoRow(
      String label, String value, IconData icon, ColorScheme scheme,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18, color: scheme.onSurface.withValues(alpha: 0.45)),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.55))),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? scheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _amountRow(String label, double amount, ColorScheme scheme,
      {bool isBold = false, Color? color}) {
    final textColor = color ?? scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: textColor)),
          Text(BillingService.formatAmount(amount),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: textColor)),
        ],
      ),
    );
  }

  Color _complexityColor(String complexity) {
    switch (complexity) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }
}
