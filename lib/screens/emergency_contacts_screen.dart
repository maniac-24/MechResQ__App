import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact.dart';
import '../services/sos_service.dart';
import '../utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';

/// Emergency Contacts Management Screen
/// Simple, clean UI for managing emergency contacts
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final SOSService _sosService = SOSService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencyContactsTitle),
        backgroundColor: scheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: l10n.info,
          ),
        ],
      ),
      body: StreamBuilder<List<EmergencyContact>>(
        stream: _sosService.getEmergencyContactsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _buildContactCard(context, contacts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text(
          AppLocalizations.of(context)!.addContact,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // UI COMPONENTS
  // ═══════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 80,
              color: scheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noEmergencyContactsTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addTrustedContactsMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstContactButton),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, EmergencyContact contact) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: contact.isPrimary
                      ? scheme.primary
                      : scheme.secondaryContainer,
                  radius: 24,
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: contact.isPrimary
                          ? scheme.onPrimary
                          : scheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and relationship
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: scheme.onPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.primary,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: scheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.relationship,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Phone number
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _testCall(contact.phone),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(l10n.call),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddEditDialog(context, contact: contact),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.secondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, contact),
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(l10n.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════

  void _showAddEditDialog(BuildContext context, {EmergencyContact? contact}) {
    final isEditing = contact != null;
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    final relationshipController =
        TextEditingController(text: contact?.relationship ?? '');
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final scheme = Theme.of(context).colorScheme;

            return AlertDialog(
              title: Text(isEditing ? l10n.editContact : l10n.addContact),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.nameRequired,
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    // Phone field
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumberRequired,
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '+91 9876543210',
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Relationship field
                    TextField(
                      controller: relationshipController,
                      decoration: InputDecoration(
                        labelText: l10n.relationshipRequired,
                        prefixIcon: const Icon(Icons.people),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: l10n.relationshipHint,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    // Primary contact toggle
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: Text(l10n.setAsPrimaryContact),
                        subtitle: Text(
                          l10n.primaryContactCalledFirst,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: isPrimary,
                        onChanged: (value) {
                          setDialogState(() {
                            isPrimary = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => _saveContact(
                    context,
                    contact: contact,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    relationship: relationshipController.text.trim(),
                    isPrimary: isPrimary,
                  ),
                  child: Text(isEditing ? l10n.update : l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Bullet points using l10n keys
    final points = [
      l10n.emergencyAboutPoint1,
      l10n.emergencyAboutPoint2,
      l10n.emergencyAboutPoint3,
      l10n.emergencyAboutPoint4,
      l10n.emergencyAboutPoint5,
      l10n.emergencyAboutPoint6,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(Icons.info, color: scheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.aboutEmergencyContacts,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.black,
            ),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmergencyContact contact) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteContactQuestion),
        content: Text(l10n.deleteContactMessage(contact.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact(contact.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  Future<void> _saveContact(
    BuildContext context, {
    EmergencyContact? contact,
    required String name,
    required String phone,
    required String relationship,
    required bool isPrimary,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Validation
    if (name.isEmpty || phone.isEmpty || relationship.isEmpty) {
      SnackBarHelper.showError(context, l10n.pleaseFillAllRequiredFields);
      return;
    }

    if (phone.length < 10) {
      SnackBarHelper.showError(context, l10n.pleaseEnterValidPhoneNumber);
      return;
    }

    // Create or update contact
    final newContact = EmergencyContact(
      id: contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      relationship: relationship,
      isPrimary: isPrimary,
      createdAt: contact?.createdAt ?? DateTime.now(),
    );

    final isEditing = contact != null;
    final success = isEditing
        ? await _sosService.updateEmergencyContact(userId, newContact)
        : await _sosService.addEmergencyContact(userId, newContact);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      SnackBarHelper.showSuccess(
        context,
        isEditing ? l10n.contactUpdatedSuccess : l10n.contactAddedSuccess,
      );
    } else {
      SnackBarHelper.showError(
        context,
        isEditing ? l10n.failedToUpdateContact : l10n.failedToAddContactMax5,
      );
    }
  }

  Future<void> _deleteContact(String contactId) async {
    final success = await _sosService.deleteEmergencyContact(userId, contactId);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (success) {
      SnackBarHelper.showSuccess(context, l10n.contactDeletedSuccess);
    } else {
      SnackBarHelper.showError(context, l10n.failedToDeleteContact);
    }
  }

  Future<void> _testCall(String phone) async {
    final success = await _sosService.makeCall(phone);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (!success) {
      SnackBarHelper.showError(context, l10n.unableToMakeCall);
    }
  }
}
