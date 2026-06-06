import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/service_reminder.dart';
import '../services/reminder_service.dart';
import '../utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';
import 'add_reminder_screen.dart';

class ServiceRemindersScreen extends StatefulWidget {
  const ServiceRemindersScreen({super.key});

  @override
  State<ServiceRemindersScreen> createState() => _ServiceRemindersScreenState();
}

class _ServiceRemindersScreenState extends State<ServiceRemindersScreen>
    with SingleTickerProviderStateMixin {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ReminderService _reminderService = ReminderService();
  
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serviceReminders),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: scheme.primary,
          labelColor: scheme.primary,
          unselectedLabelColor: scheme.onSurface.withOpacity(0.6),
          tabs: [
            Tab(text: l10n.upcoming, icon: const Icon(Icons.schedule, size: 20)),
            Tab(text: l10n.completed, icon: const Icon(Icons.done, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildCompletedTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddReminder(),
        icon: const Icon(Icons.add),
        label: Text(l10n.addReminder),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // UPCOMING TAB
  // ═══════════════════════════════════════════

  Widget _buildUpcomingTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return StreamBuilder<List<ServiceReminder>>(
      stream: _reminderService.getRemindersStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${l10n.error}: ${snapshot.error}'),
          );
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return _buildEmptyState();
        }

        // Group reminders by status
        final dueReminders = reminders.where((r) => r.isDue).toList();
        final upcomingReminders = reminders.where((r) => !r.isDue).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (dueReminders.isNotEmpty) ...[
              _buildSectionHeader(l10n.dueNow, dueReminders.length, Colors.red),
              ...dueReminders.map((r) => _buildReminderCard(r, isDue: true)),
              const SizedBox(height: 16),
            ],
            if (upcomingReminders.isNotEmpty) ...[
              _buildSectionHeader(l10n.upcoming, upcomingReminders.length, null),
              ...upcomingReminders.map((r) => _buildReminderCard(r)),
            ],
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // COMPLETED TAB
  // ═══════════════════════════════════════════

  Widget _buildCompletedTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return StreamBuilder<List<ServiceReminder>>(
      stream: _reminderService.getCompletedRemindersStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${l10n.error}: ${snapshot.error}'),
          );
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return _buildEmptyCompletedState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            return _buildCompletedReminderCard(reminders[index]);
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // REMINDER CARD
  // ═══════════════════════════════════════════

  Widget _buildReminderCard(ServiceReminder reminder, {bool isDue = false}) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDue ? scheme.errorContainer.withOpacity(0.3) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDue ? scheme.error : scheme.primaryContainer,
          child: Text(
            reminder.typeIcon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDue ? scheme.error : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reminder.vehicleName,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(reminder.reminderDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isDue) ...[
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reminder.daysUntil} ${l10n.days}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.markComplete),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleReminderAction(value.toString(), reminder),
        ),
      ),
    );
  }

  Widget _buildCompletedReminderCard(ServiceReminder reminder) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.surfaceContainerHighest,
          child: Text(
            reminder.typeIcon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reminder.vehicleName,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '${l10n.completedOn} ${dateFormat.format(reminder.completedAt!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () => _handleReminderAction('delete', reminder),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════

  Widget _buildSectionHeader(String title, int count, Color? color) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? scheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? scheme.primary).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: scheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noReminders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapPlusToAddReminder,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCompletedState() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: scheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noCompletedReminders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.completedRemindersAppearHere,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  void _handleReminderAction(String action, ServiceReminder reminder) async {
    switch (action) {
      case 'complete':
        await _markAsComplete(reminder);
        break;
      case 'edit':
        _navigateToEditReminder(reminder);
        break;
      case 'delete':
        await _deleteReminder(reminder);
        break;
    }
  }

  Future<void> _markAsComplete(ServiceReminder reminder) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsCompleteQuestion),
        content: Text(l10n.markAsCompleteMessage(reminder.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.complete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reminderService.markAsCompleted(userId, reminder.id);
      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(context, l10n.reminderMarkedCompleted);
        } else {
          SnackBarHelper.showError(context, l10n.failedToCompleteReminder);
        }
      }
    }
  }

  Future<void> _deleteReminder(ServiceReminder reminder) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReminderQuestion),
        content: Text(l10n.deleteReminderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reminderService.deleteReminder(userId, reminder.id);
      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(context, l10n.reminderDeleted);
        } else {
          SnackBarHelper.showError(context, l10n.failedToDeleteReminder);
        }
      }
    }
  }

  void _navigateToAddReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddReminderScreen(),
      ),
    );
  }

  void _navigateToEditReminder(ServiceReminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReminderScreen(reminder: reminder),
      ),
    );
  }
}
