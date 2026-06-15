import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../l10n/app_localizations.dart';
import '../services/request_firestore_service.dart';
import '../services/receipt_service.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/request_status_chip.dart' as chip;
import '../models/receipt.dart';
import 'track_mechanic_screen.dart';
import 'receipt_detail_screen.dart';
import 'bill_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  final bool showAppBar;
  const MyRequestsScreen({super.key, this.showAppBar = true});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RequestFirestoreService _requestService = RequestFirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── date helper ─────────────────────────────────────────

  String _formatDate(DateTime d) =>
      DateFormat('dd/MM/yyyy  HH:mm').format(d);

  // ─── delete single request ───────────────────────────────

  Future<void> _deleteRequest(String requestId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.historyDeleteRequest),
        content: Text(l10n.historyDeleteConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _requestService.deleteRequest(requestId);
      if (mounted) SnackBarHelper.showSuccess(context, l10n.historyDeleteSuccess);
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, '${l10n.historyDeleteError}${e.toString()}');
    }
  }

  // ─── delete all history ──────────────────────────────────

  // ─── cancel active request ───────────────────────────────

  void _confirmCancel(String requestId) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(l10n.cancelRequest,
            style: TextStyle(color: scheme.onSurface)),
        content: Text(l10n.cancelRequestConfirm,
            style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.8))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.no)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _requestService.cancelRequest(requestId);
                if (mounted) {
                  SnackBarHelper.showInfo(context, l10n.requestCancelled);
                }
              } catch (e) {
                if (mounted) {
                  SnackBarHelper.showError(
                      context, '${l10n.error}: ${e.toString()}');
                }
              }
            },
            child: Text(l10n.yesCancelRequest),
          ),
        ],
      ),
    );
  }

  // ─── receipt check (uses receipts collection) ────────────

  Future<ServiceReceipt?> _fetchReceipt(String requestId) async {
    try {
      return await ReceiptService.getReceiptByRequest(requestId);
    } catch (e) {
      developer.log('❌ _fetchReceipt: $e', name: 'MyRequestsScreen');
      return null;
    }
  }

  // ─── BUILD ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final tabBar = TabBar(
      controller: _tabController,
      indicatorColor: scheme.primary,
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.6),
      tabs: [
        Tab(text: l10n.active.toUpperCase()),
        Tab(text: l10n.history.toUpperCase()),
      ],
    );

    final body = StreamBuilder<List<Map<String, dynamic>>>(
      stream: _requestService.getUserRequestsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: scheme.primary));
        }
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline, color: scheme.error, size: 48),
              const SizedBox(height: 16),
              Text('${l10n.error}: ${snap.error}',
                  style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => setState(() {}), child: Text(l10n.retry)),
            ]),
          );
        }

        if (!snap.hasData || snap.data!.isEmpty) {
          return TabBarView(
            controller: _tabController,
            children: [
              _emptyState(l10n.noRequestsFound, scheme),
              _emptyState(l10n.noRequestsFound, scheme),
            ],
          );
        }

        final all = snap.data!.map((r) {
          final s = chip.parseRequestStatus(
              (r['status'] ?? 'pending').toString());
          return {...r, '_ps': s};
        }).toList();

        final active = all
            .where((r) => (r['_ps'] as chip.RequestStatus).isActive)
            .toList();
        final history = all
            .where((r) => !(r['_ps'] as chip.RequestStatus).isActive)
            .toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _buildActiveList(active),
            _buildHistoryList(history),
          ],
        );
      },
    );

    if (!widget.showAppBar) {
      return Column(children: [
        Container(color: scheme.surface, child: tabBar),
        Expanded(child: body),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequests),
        bottom: tabBar,
      ),
      body: body,
    );
  }

  Widget _emptyState(String text, ColorScheme scheme) => Center(
      child: Text(text,
          style:
              TextStyle(color: scheme.onSurface.withValues(alpha: 0.7))));

  // ─── ACTIVE LIST ─────────────────────────────────────────

  Widget _buildActiveList(List<Map<String, dynamic>> list) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    if (list.isEmpty) return _emptyState(l10n.noActiveRequests, scheme);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) =>
          _activeCard(list[i], list[i]['requestId'] ?? list[i]['id'] ?? ''),
    );
  }

  Widget _activeCard(Map<String, dynamic> r, String requestId) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final status = chip.parseRequestStatus(
        (r['status'] ?? 'pending').toString());
    final vehicleType = r['vehicleType'] ?? r['vehicle'] ?? 'N/A';
    final issue = r['issue'] ?? '';
    final createdAt = r['createdAt'] as DateTime?;
    final isTrackable = status.isTrackable;

    return Card(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // ── Main info row ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primary,
                child: Text(
                  vehicleType.isNotEmpty ? vehicleType[0].toUpperCase() : 'R',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: scheme.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    issue.length > 50
                        ? '${issue.substring(0, 50)}...'
                        : issue,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text('${l10n.vehicle}: $vehicleType',
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.7))),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(_formatDate(createdAt),
                        style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.4))),
                  ],
                  // Pending hint
                  if (status == chip.RequestStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(children: [
                        Icon(Icons.hourglass_top,
                            size: 11,
                            color: Colors.orange.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          l10n.historyWaitingMechanic,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic),
                        ),
                      ]),
                    ),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                chip.RequestStatusChip(status: status),
                if (status.isCancellable) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => _confirmCancel(requestId),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(l10n.cancel,
                        style:
                            TextStyle(color: scheme.error, fontSize: 12)),
                  ),
                ],
              ]),
            ]),
          ),

          // ── Track on Map button (shown when accepted/onTheWay) ──
          if (isTrackable) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrackMechanicScreen(requestId: requestId),
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: Text(
                    l10n.historyTrackOnMap,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],

          // ── Pending → tap card to view estimate ─────────
          if (status == chip.RequestStatus.pending) ...[
            const Divider(height: 1),
            InkWell(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BillScreen(
                    requestId: requestId,
                    vehicleType: vehicleType,
                    issueDescription: issue,
                    serviceLocation:
                        r['locationAddress'] ?? r['location'] ?? '',
                    mode: BillMode.estimate,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_outlined,
                        size: 15,
                        color: scheme.primary.withValues(alpha: 0.75)),
                    const SizedBox(width: 6),
                    Text(
                      l10n.historyViewEstimateCancel,
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              scheme.primary.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right,
                        size: 16,
                        color: scheme.primary.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── HISTORY LIST ────────────────────────────────────────

  Widget _buildHistoryList(List<Map<String, dynamic>> list) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    if (list.isEmpty) return _emptyState(l10n.noRequestHistory, scheme);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _historyCard(list[i], scheme, l10n),
    );
  }

  Widget _historyCard(
      Map<String, dynamic> r, ColorScheme scheme, AppLocalizations l10n) {
    final requestId = r['requestId'] ?? r['id'] ?? '';
    final vehicleType = r['vehicleType'] ?? r['vehicle'] ?? 'N/A';
    final issue = r['issue'] ?? '';
    final statusString = (r['status'] ?? 'pending').toString();
    final status = chip.parseRequestStatus(statusString);
    final createdAt = r['createdAt'] as DateTime?;
    final isCompleted = statusString.toLowerCase() == 'completed';
    final isCancelled = statusString.toLowerCase() == 'cancelled';

    return FutureBuilder<ServiceReceipt?>(
      // Fetch receipt for ALL history cards (not just completed)
      // so we can control delete button visibility
      future: isCompleted ? _fetchReceipt(requestId) : Future.value(null),
      builder: (context, receiptSnap) {
        final receipt = receiptSnap.data;
        final isPaid = receipt?.isPaid ?? false;

        // Delete is allowed only if:
        //   - Request is cancelled (no payment involved)
        //   - Request is completed AND payment is done
        final canDelete = isCancelled || (isCompleted && isPaid);

        return Card(
          color: scheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            // ── Header row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primary,
                    child: Text(
                      vehicleType.isNotEmpty ? vehicleType[0].toUpperCase() : 'R',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimary,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.length > 50
                              ? '${issue.substring(0, 50)}...'
                              : issue,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text('${l10n.vehicle}: $vehicleType',
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: 0.7))),
                        if (createdAt != null) ...[
                          const SizedBox(height: 2),
                          Text(_formatDate(createdAt),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface.withValues(alpha: 0.4))),
                        ],
                      ],
                    ),
                  ),

                  // Status chip + DELETE button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chip.RequestStatusChip(status: status),
                      const SizedBox(height: 6),

                      // DELETE BUTTON — enabled only after payment
                      canDelete
                          ? GestureDetector(
                              onTap: () => _deleteRequest(requestId),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 14, color: Colors.red.shade700),
                                    const SizedBox(width: 3),
                                    Text(l10n.delete,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )
                          : Tooltip(
                              message: 'Pay first to enable delete',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: scheme.onSurface.withValues(alpha: 0.05),
                                  border: Border.all(
                                      color: scheme.onSurface.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 14,
                                        color: scheme.onSurface.withValues(alpha: 0.3)),
                                    const SizedBox(width: 3),
                                    Text(l10n.delete,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: scheme.onSurface.withValues(alpha: 0.3),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Receipt / payment section (completed only) ───────
            if (isCompleted) ...[
              const Divider(height: 1),
              // Reuse already-fetched receipt data
              if (receiptSnap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else if (receipt == null)
                // No receipt → show View Bill & Pay
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.historyServiceCompleted,
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BillScreen(
                              requestId: requestId,
                              vehicleType: vehicleType,
                              issueDescription: issue,
                              serviceLocation:
                                  r['locationAddress'] ?? r['location'] ?? '',
                              mode: BillMode.payment,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_outlined),
                        label: Text(l10n.historyViewBillPay,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                )
              else if (!receipt.isPaid)
                // Receipt exists, cash pending
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(children: [
                      Icon(Icons.payments_outlined,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.historyCashPending,
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ),
                    ]),
                  ),
                )
              else
                // Paid — show View Receipt
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReceiptDetailScreen(requestId: requestId),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long),
                      label: Text(l10n.receiptViewReceipt,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
            ],
          ]),
        );
      },
    );
  }
}
