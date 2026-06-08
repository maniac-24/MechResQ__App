// lib/services/pdf_receipt_service.dart
// Generates a single-page A4 PDF receipt for MechResQ.

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/receipt.dart';
import '../services/billing_service.dart';

class PdfReceiptService {
  // Brand colours
  static const _orange  = PdfColor.fromInt(0xFFFF6B35);
  static const _darkGrey = PdfColor.fromInt(0xFF333333);
  static const _lightGrey = PdfColor.fromInt(0xFFF5F5F5);
  static const _midGrey  = PdfColor.fromInt(0xFF9E9E9E);
  static const _green   = PdfColor.fromInt(0xFF4CAF50);
  static const _white   = PdfColors.white;

  // ─── Public API ──────────────────────────────────────────

  static Future<Uint8List> generate(ServiceReceipt receipt) async {
    final doc = pw.Document(title: 'MechResQ Receipt', author: 'MechResQ');

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/mechresq_logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final bold    = pw.Font.helveticaBold();
    final regular = pw.Font.helvetica();
    final df      = DateFormat('dd MMM yyyy, hh:mm a');
    final dateStr = receipt.paidAt != null
        ? df.format(receipt.paidAt!)
        : df.format(receipt.createdAt);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(logo, receipt, dateStr),
            pw.SizedBox(height: 6),
            _statusBanner(receipt),
            pw.SizedBox(height: 6),
            // Two columns: service info | payment info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _serviceBox(receipt)),
                pw.SizedBox(width: 6),
                pw.Expanded(child: _paymentBox(receipt, dateStr)),
              ],
            ),
            pw.SizedBox(height: 6),
            _table(receipt),
            pw.SizedBox(height: 6),
            _totals(receipt),
            pw.SizedBox(height: 6),
            _note(),
            pw.Spacer(),
            _thankYou(logo),
            pw.SizedBox(height: 4),
            _footer(),
          ],
        ),
      ),
    );

    return doc.save();
  }

  static Future<void> shareOrSave(ServiceReceipt receipt) async {
    final bytes = await generate(receipt);
    final name =
        'MechResQ_Receipt_${receipt.requestId.substring(0, 8).toUpperCase()}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: name);
  }

  static Future<void> printPreview(
      dynamic context, ServiceReceipt receipt) async {
    await Printing.layoutPdf(
      onLayout: (_) async => generate(receipt),
      name: 'MechResQ_Receipt_${receipt.requestId.substring(0, 8).toUpperCase()}',
    );
  }

  // ─── SECTIONS ────────────────────────────────────────────

  static pw.Widget _header(
      pw.MemoryImage? logo, ServiceReceipt r, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _orange, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(children: [
            if (logo != null) ...[
              pw.Image(logo, width: 32, height: 32),
              pw.SizedBox(width: 6),
            ],
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('MechResQ',
                  style: pw.TextStyle(
                      font: pw.Font.helveticaBold(), fontSize: 16, color: _orange)),
              pw.Text('On-Demand Mechanic Services',
                  style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
            ]),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('SERVICE RECEIPT',
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 11,
                    color: _darkGrey,
                    letterSpacing: 1.0)),
            pw.Text('#${r.requestId.substring(0, 8).toUpperCase()}',
                style: const pw.TextStyle(fontSize: 8, color: _midGrey)),
            pw.Text(dateStr,
                style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
          ]),
        ],
      ),
    );
  }

  static pw.Widget _statusBanner(ServiceReceipt r) {
    final isPaid = r.isPaid;
    final color  = isPaid ? _green : _orange;
    final bgInt  = isPaid ? 0xFFE8F5E9 : 0xFFFFF3E0;
    final label  = isPaid ? '✓  PAID' : '⏳  PAYMENT PENDING';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(bgInt),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: pw.Font.helveticaBold(), fontSize: 10, color: color)),
          pw.Text(r.paymentMethodDisplay.toUpperCase(),
              style: pw.TextStyle(
                  font: pw.Font.helveticaBold(), fontSize: 9, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _serviceBox(ServiceReceipt r) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        _boxTitle('SERVICE DETAILS'),
        pw.SizedBox(height: 5),
        _kv('Vehicle', r.vehicleType),
        _kv('Complexity', r.complexityLabel),
        _kv('Issue',
            r.issueDescription.length > 60
                ? '${r.issueDescription.substring(0, 60)}…'
                : r.issueDescription),
        _kv('Location',
            r.serviceLocation.isEmpty ? 'Your location' : r.serviceLocation),
        if (r.mechanicName != null) _kv('Mechanic', r.mechanicName!),
      ]),
    );
  }

  static pw.Widget _paymentBox(ServiceReceipt r, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        _boxTitle('PAYMENT INFORMATION'),
        pw.SizedBox(height: 5),
        _kv('Method', r.paymentMethodDisplay),
        _kv('Status', r.statusDisplay.toUpperCase()),
        if (r.razorpayPaymentId != null && r.razorpayPaymentId!.isNotEmpty)
          _kv('Txn ID', r.razorpayPaymentId!),
        if (r.id.isNotEmpty)
          _kv('Receipt', r.id.substring(0, 10).toUpperCase()),
        _kv('Customer', r.userId.substring(0, 8).toUpperCase()),
        _kv('Date', dateStr.split(',').first),
      ]),
    );
  }

  static pw.Widget _boxTitle(String t) => pw.Text(t,
      style: pw.TextStyle(
          font: pw.Font.helveticaBold(),
          fontSize: 7,
          color: _midGrey,
          letterSpacing: 0.8));

  static pw.Widget _kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 60,
              child: pw.Text(k,
                  style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
            ),
            pw.Expanded(
              child: pw.Text(v,
                  style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 8,
                      color: _darkGrey)),
            ),
          ],
        ),
      );

  static pw.Widget _table(ServiceReceipt r) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _darkGrey),
        children: [
          _th('DESCRIPTION'),
          _th('AMOUNT', right: true),
        ],
      ),
      _tr('Base Service Charge (${r.vehicleType})', r.baseServiceCharge),
      _tr('Labour Charges (${r.complexityLabel})', r.laborCharge),
      if (r.callOutCharge > 0) _tr('Call-Out / Travel Fee', r.callOutCharge),
      if (r.sparePartsActual > 0) _tr('Spare Parts', r.sparePartsActual),
      _tr('MechResQ Platform Fee', r.platformFee),
    ];

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _boxTitle('ITEMISED CHARGES'),
      pw.SizedBox(height: 4),
      pw.Table(
        border: pw.TableBorder.all(
            color: const PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(1.5),
        },
        children: rows,
      ),
    ]);
  }

  static pw.TableRow _tr(String label, double amount) => pw.TableRow(
        children: [
          _td(label),
          _td(BillingService.formatAmountPdf(amount), right: true),
        ],
      );

  static pw.Widget _th(String t, {bool right = false}) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        alignment: right ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(t,
            style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: 7,
                color: _white,
                letterSpacing: 0.3)),
      );

  static pw.Widget _td(String t, {bool right = false}) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        alignment: right ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: pw.Text(t,
            style: const pw.TextStyle(fontSize: 8, color: _darkGrey)),
      );

  static pw.Widget _totals(ServiceReceipt r) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF8F5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _orange, width: 1),
      ),
      child: pw.Column(children: [
        _totalRow('Sub-Total', r.subTotal),
        pw.SizedBox(height: 2),
        _totalRow('GST (18%)', r.gstAmount, color: _midGrey),
        pw.Divider(color: _orange, thickness: 1),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOTAL AMOUNT',
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 12,
                    color: _darkGrey)),
            pw.Text(BillingService.formatAmountPdf(r.totalAmount),
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 15,
                    color: _orange)),
          ],
        ),
      ]),
    );
  }

  static pw.Widget _totalRow(String label, double amount,
      {PdfColor color = _darkGrey}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color)),
        pw.Text(BillingService.formatAmountPdf(amount),
            style: pw.TextStyle(
                font: pw.Font.helveticaBold(), fontSize: 9, color: color)),
      ],
    );
  }

  static pw.Widget _note() => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
              color: const PdfColor.fromInt(0xFFE0E0E0), width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        ),
        child: pw.Text(
          '* Estimate receipt. Final charges may vary based on actual spare parts. '
          'GST @ 18% included. Disputes: support@mechresq.com',
          style: const pw.TextStyle(fontSize: 7, color: _midGrey),
        ),
      );

  static pw.Widget _thankYou(pw.MemoryImage? logo) {
    return pw.Center(
      child: pw.Column(children: [
        pw.Text('Thank you for choosing MechResQ!',
            style: pw.TextStyle(
                font: pw.Font.helveticaBold(), fontSize: 10, color: _orange)),
        pw.SizedBox(height: 2),
        pw.Text("Drive safe. We're always here when you need us.",
            style: const pw.TextStyle(fontSize: 8, color: _midGrey)),
      ]),
    );
  }

  static pw.Widget _footer() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: _lightGrey, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('support@mechresq.com',
              style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
          pw.Text('MechResQ © 2026',
              style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
          pw.Text('www.mechresq.com',
              style: const pw.TextStyle(fontSize: 7, color: _midGrey)),
        ],
      ),
    );
  }
}
