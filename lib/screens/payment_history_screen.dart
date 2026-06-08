// lib/screens/payment_history_screen.dart
//
// Payment history screen for viewing all past payments

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../services/payment_firestore_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final List<Payment> _allPayments = [];
  final List<Payment> _filteredPayments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, success, failed, pending

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final payments = await PaymentFirestoreService.getPaymentsByUser(user.uid);
        setState(() {
          _allPayments.clear();
          _allPayments.addAll(payments);
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    _filteredPayments.clear();
    
    if (_selectedFilter == 'all') {
      _filteredPayments.addAll(_allPayments);
    } else {
      _filteredPayments.addAll(
        _allPayments.where((payment) {
          switch (_selectedFilter) {
            case 'success':
              return payment.isSuccess;
            case 'failed':
              return payment.isFailed;
            case 'pending':
              return payment.isPending;
            default:
              return true;
          }
        }),
      );
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          
          // Payment List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPayments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            return _buildPaymentCard(_filteredPayments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', _allPayments.length),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Success',
              'success',
              _allPayments.where((p) => p.isSuccess).length,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Failed',
              'failed',
              _allPayments.where((p) => p.isFailed).length,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Pending',
              'pending',
              _allPayments.where((p) => p.isPending).length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => _changeFilter(value),
      selectedColor: const Color(0xFFFF6B35).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFFFF6B35),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No payment history'
                : 'No $_selectedFilter payments',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      payment.description ?? 'Payment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(payment),
                ],
              ),
              const SizedBox(height: 12),
              
              // Amount
              Text(
                payment.amountDisplay,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(payment.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (payment.paymentMethod != null) ...[
                    Icon(Icons.payment, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      payment.methodDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              
              // Payment ID
              if (payment.razorpayPaymentId != null)
                Text(
                  'Payment ID: ${payment.razorpayPaymentId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Payment payment) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (payment.isSuccess) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
    } else if (payment.isFailed) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      icon = Icons.error;
    } else {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            payment.statusDisplay,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final paymentDate = DateTime(date.year, date.month, date.day);

    if (paymentDate == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (paymentDate == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              // Status
              _buildDetailRow('Status', payment.statusDisplay, _buildStatusChip(payment)),
              
              // Amount
              _buildDetailRow('Amount', payment.amountDisplay),
              
              // Payment Method
              if (payment.paymentMethod != null)
                _buildDetailRow('Payment Method', payment.methodDisplay),
              
              // Payment ID
              if (payment.razorpayPaymentId != null)
                _buildDetailRow('Payment ID', payment.razorpayPaymentId!),
              
              // Order ID
              if (payment.razorpayOrderId != null)
                _buildDetailRow('Order ID', payment.razorpayOrderId!),
              
              // Booking ID
              _buildDetailRow('Booking ID', payment.bookingId),
              
              // Date & Time
              _buildDetailRow(
                'Created At',
                DateFormat('MMM dd, yyyy - hh:mm a').format(payment.createdAt),
              ),
              
              if (payment.paidAt != null)
                _buildDetailRow(
                  'Paid At',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(payment.paidAt!),
                ),
              
              // Error Details (if failed)
              if (payment.isFailed) ...[
                const Divider(height: 32),
                const Text(
                  'Error Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                if (payment.errorCode != null)
                  _buildDetailRow('Error Code', payment.errorCode!),
                if (payment.errorDescription != null)
                  _buildDetailRow('Description', payment.errorDescription!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Widget? trailing]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: trailing ?? Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
