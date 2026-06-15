// lib/services/billing_service.dart
//
// Billing / Estimate calculation engine for MechResQ
// Calculates service cost based on vehicle type, issue keywords,
// distance, service charges, platform fee and GST.

/// A single line item in a bill
class BillLineItem {
  final String label;
  final String? description;
  final double amount;
  final bool isDiscount;

  const BillLineItem({
    required this.label,
    this.description,
    required this.amount,
    this.isDiscount = false,
  });
}

/// Full bill breakdown returned by BillingService
class ServiceBill {
  final String requestId;
  final String vehicleType;
  final String issueDescription;
  final double distanceKm;

  // Line items
  final double baseServiceCharge;    // Based on vehicle type
  final double laborCharge;          // Based on issue complexity
  final double callOutCharge;        // Distance-based travel fee
  final double sparePartsEstimate;   // Rough spare parts estimate
  final double platformFee;          // MechResQ platform fee
  final double subTotal;             // Sum before GST
  final double gstAmount;            // 18% GST on subTotal
  final double totalAmount;          // Final payable amount

  // Meta
  final String complexityLabel;      // "Low" / "Medium" / "High" / "Critical"
  final List<String> detectedKeywords;
  final DateTime generatedAt;

  const ServiceBill({
    required this.requestId,
    required this.vehicleType,
    required this.issueDescription,
    required this.distanceKm,
    required this.baseServiceCharge,
    required this.laborCharge,
    required this.callOutCharge,
    required this.sparePartsEstimate,
    required this.platformFee,
    required this.subTotal,
    required this.gstAmount,
    required this.totalAmount,
    required this.complexityLabel,
    required this.detectedKeywords,
    required this.generatedAt,
  });

  /// Returns all line items for display in the Bill Screen
  List<BillLineItem> get lineItems => [
        BillLineItem(
          label: 'Base Service Charge',
          description: '$vehicleType — standard visit fee',
          amount: baseServiceCharge,
        ),
        BillLineItem(
          label: 'Labour Charges',
          description: 'Complexity: $complexityLabel',
          amount: laborCharge,
        ),
        if (callOutCharge > 0)
          BillLineItem(
            label: 'Call-Out / Travel Fee',
            description: '${distanceKm.toStringAsFixed(1)} km',
            amount: callOutCharge,
          ),
        if (sparePartsEstimate > 0)
          BillLineItem(
            label: 'Spare Parts (Estimate)',
            description: 'Actual cost adjusted after service',
            amount: sparePartsEstimate,
          ),
        BillLineItem(
          label: 'Platform Fee',
          description: 'MechResQ service fee',
          amount: platformFee,
        ),
        BillLineItem(
          label: 'Sub-Total',
          amount: subTotal,
        ),
        BillLineItem(
          label: 'GST (18%)',
          description: 'Goods and Services Tax',
          amount: gstAmount,
        ),
      ];

  /// Build a display bill from the mechanic's FINAL bill map (stored on the
  /// request as `finalBill`). Used in payment mode so the customer sees the
  /// mechanic's actual charges instead of the original auto-estimate.
  factory ServiceBill.fromFinalBill({
    required String requestId,
    required String vehicleType,
    required String issue,
    required Map<String, dynamic> fb,
    double distanceKm = 0,
  }) {
    double d(String k) => (fb[k] as num?)?.toDouble() ?? 0;
    return ServiceBill(
      requestId: requestId,
      vehicleType: vehicleType,
      issueDescription: issue,
      distanceKm: distanceKm,
      baseServiceCharge: d('baseServiceCharge'),
      laborCharge: d('labourCharge'),
      callOutCharge: d('callOutCharge'),
      sparePartsEstimate: d('partsTotal'),
      platformFee: d('platformFee'),
      subTotal: d('subTotal'),
      gstAmount: d('gstAmount'),
      totalAmount: d('totalAmount'),
      complexityLabel: 'Final',
      detectedKeywords: const [],
      generatedAt: DateTime.now(),
    );
  }

  /// Convert to Firestore-friendly map
  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'vehicleType': vehicleType,
        'issueDescription': issueDescription,
        'distanceKm': distanceKm,
        'baseServiceCharge': baseServiceCharge,
        'laborCharge': laborCharge,
        'callOutCharge': callOutCharge,
        'sparePartsEstimate': sparePartsEstimate,
        'platformFee': platformFee,
        'subTotal': subTotal,
        'gstAmount': gstAmount,
        'totalAmount': totalAmount,
        'complexityLabel': complexityLabel,
        'detectedKeywords': detectedKeywords,
        'generatedAt': generatedAt.toIso8601String(),
      };
}

/// Billing Service
/// Pure computation — no Firebase calls here.
class BillingService {
  // ─────────────────────────────────────────
  // CONSTANTS
  // ─────────────────────────────────────────
  static const double _gstRate = 0.18; // 18% GST
  static const double _platformFee = 49.0; // Fixed MechResQ platform fee

  // Base service charge by vehicle type
  static const Map<String, double> _baseChargeByVehicle = {
    'car':        299.0,
    'motorcycle': 199.0,
    'truck':      499.0,
    'auto':       199.0,
    'bus':        599.0,
  };

  // Call-out charge per km
  static const double _callOutPerKm = 12.0;
  static const double _freeCallOutKm = 3.0; // First 3 km free

  // ─────────────────────────────────────────
  // KEYWORD → COMPLEXITY MAPPING
  // ─────────────────────────────────────────

  /// Keywords that indicate LOW complexity
  static const List<String> _lowKeywords = [
    'flat tyre', 'puncture', 'tyre', 'air pressure', 'fill air',
    'jumpstart', 'jump start', 'battery low', 'dead battery',
    'out of fuel', 'no fuel', 'petrol', 'diesel',
    'wiper', 'bulb', 'light', 'fuse',
  ];

  /// Keywords that indicate MEDIUM complexity
  static const List<String> _mediumKeywords = [
    'brake', 'brakes', 'clutch', 'gear', 'gearbox',
    'battery', 'alternator', 'starter',
    'overheating', 'radiator', 'coolant', 'temperature',
    'oil leak', 'oil change', 'oil level',
    'suspension', 'shock', 'steering',
    'noise', 'vibration', 'shaking',
    'ac', 'air conditioner', 'cooling',
  ];

  /// Keywords that indicate HIGH complexity
  static const List<String> _highKeywords = [
    'engine', 'engine failure', 'engine noise', 'misfire',
    'transmission', 'gearbox failure',
    'fuel pump', 'injector', 'carburetor',
    'exhaust', 'smoke', 'burning smell',
    'electrical', 'wiring', 'short circuit',
    'turbo', 'turbocharger',
    'head gasket', 'piston',
  ];

  /// Keywords that indicate CRITICAL complexity
  static const List<String> _criticalKeywords = [
    'accident', 'crash', 'collision', 'major damage',
    'fire', 'burning', 'explosion',
    'total breakdown', 'complete failure',
    'engine seized', 'seized',
    'flood damage', 'water damage',
  ];

  // Labour charges by complexity
  static const Map<String, double> _laborByComplexity = {
    'Low':      200.0,
    'Medium':   450.0,
    'High':     800.0,
    'Critical': 1500.0,
  };

  // Spare parts rough estimate by complexity
  static const Map<String, double> _sparesEstimateByComplexity = {
    'Low':      0.0,
    'Medium':   300.0,
    'High':     800.0,
    'Critical': 2000.0,
  };

  // ─────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────

  /// Calculate a service bill estimate.
  ///
  /// [requestId]   — Firestore request document ID
  /// [vehicleType] — "Car", "Motorcycle", "Truck" etc.
  /// [issue]       — Free-text issue description from user
  /// [distanceKm]  — Distance from mechanic to user (use 0 if unknown)
  static ServiceBill calculate({
    required String requestId,
    required String vehicleType,
    required String issue,
    double distanceKm = 5.0,
  }) {
    final issueLC = issue.toLowerCase();
    final vehicleKey = vehicleType.toLowerCase();

    // 1. Detect keywords
    final detected = _detectKeywords(issueLC);

    // 2. Determine complexity
    final complexity = _getComplexity(issueLC);

    // 3. Base service charge
    final base = _baseChargeByVehicle[vehicleKey] ??
        _baseChargeByVehicle['car']!;

    // 4. Labour charge
    final labour = _laborByComplexity[complexity]!;

    // 5. Call-out charge (distance beyond free km)
    final billableKm = (distanceKm - _freeCallOutKm).clamp(0.0, double.infinity);
    final callOut = (billableKm * _callOutPerKm).roundToDouble();

    // 6. Spare parts estimate
    final spares = _sparesEstimateByComplexity[complexity]!;

    // 7. Platform fee (fixed)
    const platform = _platformFee;

    // 8. Sub-total
    final sub = base + labour + callOut + spares + platform;

    // 9. GST
    final gst = double.parse((sub * _gstRate).toStringAsFixed(2));

    // 10. Total
    final total = double.parse((sub + gst).toStringAsFixed(2));

    return ServiceBill(
      requestId: requestId,
      vehicleType: vehicleType,
      issueDescription: issue,
      distanceKm: distanceKm,
      baseServiceCharge: base,
      laborCharge: labour,
      callOutCharge: callOut,
      sparePartsEstimate: spares,
      platformFee: platform,
      subTotal: sub,
      gstAmount: gst,
      totalAmount: total,
      complexityLabel: complexity,
      detectedKeywords: detected,
      generatedAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────

  static String _getComplexity(String issueLC) {
    for (final kw in _criticalKeywords) {
      if (issueLC.contains(kw)) return 'Critical';
    }
    for (final kw in _highKeywords) {
      if (issueLC.contains(kw)) return 'High';
    }
    for (final kw in _mediumKeywords) {
      if (issueLC.contains(kw)) return 'Medium';
    }
    for (final kw in _lowKeywords) {
      if (issueLC.contains(kw)) return 'Low';
    }
    // Default to Medium if no keyword matched
    return 'Medium';
  }

  static List<String> _detectKeywords(String issueLC) {
    final all = [
      ..._criticalKeywords,
      ..._highKeywords,
      ..._mediumKeywords,
      ..._lowKeywords,
    ];
    return all.where((kw) => issueLC.contains(kw)).toList();
  }

  // ─────────────────────────────────────────
  // DISPLAY HELPERS
  // ─────────────────────────────────────────

  /// Format a rupee amount for display in UI
  static String formatAmount(double amount) =>
      '\u20B9${amount.toStringAsFixed(2)}';

  /// Format a rupee amount for PDF (Helvetica font doesn't support rupee symbol)
  static String formatAmountPdf(double amount) =>
      'Rs. ${amount.toStringAsFixed(2)}';

  /// Complexity badge colour
  static ({String label, int colorValue}) complexityBadge(String complexity) {
    switch (complexity) {
      case 'Low':
        return (label: 'Low', colorValue: 0xFF4CAF50);
      case 'Medium':
        return (label: 'Medium', colorValue: 0xFFFF9800);
      case 'High':
        return (label: 'High', colorValue: 0xFFF44336);
      case 'Critical':
        return (label: 'Critical', colorValue: 0xFF9C27B0);
      default:
        return (label: complexity, colorValue: 0xFF607D8B);
    }
  }
}
