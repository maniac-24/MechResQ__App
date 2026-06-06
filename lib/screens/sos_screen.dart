import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../l10n/app_localizations.dart';
import '../models/emergency_contact.dart';
import '../services/sos_service.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_helper.dart';
import 'emergency_contacts_screen.dart';
import 'sos_history_screen.dart';

/// Full-Screen SOS Emergency Screen
/// Clean, simple, panic-mode friendly UI
class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  final SOSService _sosService = SOSService();
  final FirestoreService _firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _isLoading = false;
  bool _isActivating = false;
  String? _currentLocationText;
  double _latitude = 0.0;
  double _longitude = 0.0;
  List<EmergencyContact> _emergencyContacts = [];
  String _selectedEmergencyType = 'vehicle'; // Default emergency type

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Pulse animation for SOS button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load emergency contacts
    _emergencyContacts = await _sosService.getEmergencyContacts(userId);

    // Get current location
    await _getCurrentLocation();

    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            setState(() => _currentLocationText = l10n.permissionDenied);
          }
          return;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(_latitude, _longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentLocationText = '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _currentLocationText = l10n.couldNotGetLocation);
      }
      print('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emergencySos),
        backgroundColor: scheme.errorContainer,
        foregroundColor: scheme.onErrorContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SOSHistoryScreen(),
              ),
            ),
            tooltip: l10n.viewSosHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildLocationSection(context),
                  _buildEmergencyTypeSelector(context),
                  _buildSOSButton(context),
                  _buildWhatHappens(context),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════
  // UI COMPONENTS
  // ═══════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
      ),
      child: Column(
        children: [
          Icon(
            Icons.emergency,
            size: 64,
            color: scheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emergencySos,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpIsOneKnownAway,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onErrorContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: scheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.currentLocation,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentLocationText ?? l10n.detectingLocation,
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.refreshLocation),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTypeSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final emergencyTypes = [
      {'value': 'vehicle', 'label': l10n.vehicleBreakdown, 'icon': Icons.directions_car},
      {'value': 'medical', 'label': l10n.medicalEmergency, 'icon': Icons.medical_services},
      {'value': 'accident', 'label': l10n.accident, 'icon': Icons.warning},
      {'value': 'safety', 'label': l10n.personalSafety, 'icon': Icons.security},
      {'value': 'other', 'label': l10n.other, 'icon': Icons.more_horiz},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.emergencyType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedEmergencyType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: scheme.surface,
            ),
            items: emergencyTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'] as String,
                child: Text(
                  type['label'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedEmergencyType = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          // Big pulsing SOS button
          ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: _isActivating ? null : () => _confirmActivateSOS(context),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.error,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.error.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _isActivating
                    ? Center(
                        child: CircularProgressIndicator(
                          color: scheme.onError,
                          strokeWidth: 3,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sos,
                            size: 72,
                            color: scheme.onError,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.activateSos.toUpperCase()}\n${l10n.sos.toUpperCase()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: scheme.onError,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tapToActivateEmergency,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatHappens(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatHappensWhenActivate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(l10n.smsContactsSent(_emergencyContacts.length)),
          _buildCheckItem(l10n.nearbyMechanicsAlerted),
          _buildCheckItem(l10n.liveLocationShared),
          _buildCheckItem(l10n.eventLoggedHistory),
          const SizedBox(height: 8),
          if (_emergencyContacts.isEmpty)
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen(),
                ),
              ).then((_) => _loadData()),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: scheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.noEmergencyContactsWarning,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: scheme.onErrorContainer, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickEmergencyActions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.phone,
            label: l10n.callPrimaryContact,
            onTap: _callPrimaryContact,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.local_police,
            label: l10n.call112Emergency,
            onTap: _callEmergencyServices,
            backgroundColor: scheme.tertiaryContainer,
            foregroundColor: scheme.onTertiaryContainer,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.contacts,
            label: l10n.manageEmergencyContacts,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyContactsScreen(),
              ),
            ).then((_) => _loadData()),
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: foregroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: foregroundColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  Future<void> _confirmActivateSOS(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if location is available
    if (_latitude == 0.0 && _longitude == 0.0) {
      SnackBarHelper.showError(
        context,
        l10n.unableToDetectLocation,
      );
      return;
    }

    // Show countdown dialog (3 seconds)
    final shouldActivate = await _showCountdownDialog(context);
    
    if (shouldActivate == true) {
      await _activateSOS();
    }
  }

  // Show countdown dialog (3-2-1)
  Future<bool?> _showCountdownDialog(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _CountdownDialog(scheme: scheme);
      },
    );
  }

  Future<void> _activateSOS() async {
    setState(() => _isActivating = true);

    // Show progress dialog
    if (!mounted) return;
    await _showProgressDialog();
    
    setState(() => _isActivating = false);
  }

  // Show progress dialog with real-time step updates
  Future<void> _showProgressDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Progress state
    int currentStep = 0;
    String? errorMessage;
    int mechanicsAlerted = 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Execute SOS activation steps
            if (currentStep == 0) {
              currentStep = 1;
              _executeSOSSteps(setDialogState, (step, error, mechanics) {
                setDialogState(() {
                  currentStep = step;
                  errorMessage = error;
                  mechanicsAlerted = mechanics;
                });
              });
            }

            return AlertDialog(
              title: Row(
                children: [
                  if (currentStep < 5 && errorMessage == null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  else if (errorMessage != null)
                    Icon(Icons.error, color: scheme.error, size: 20)
                  else
                    Icon(Icons.check_circle, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    errorMessage != null
                        ? l10n.sosFailed
                        : currentStep < 5
                            ? l10n.activatingSos
                            : l10n.sosActivated,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(color: scheme.error),
                    )
                  else ...[
                    _buildProgressStep(
                      context,
                      icon: Icons.location_on,
                      label: l10n.detectingLocation,
                      isComplete: currentStep > 1,
                      isActive: currentStep == 1,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStep(
                      context,
                      icon: Icons.save,
                      label: l10n.savingEvent,
                      isComplete: currentStep > 2,
                      isActive: currentStep == 2,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStep(
                      context,
                      icon: Icons.sms,
                      label: l10n.sendingSms,
                      isComplete: currentStep > 3,
                      isActive: currentStep == 3,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStep(
                      context,
                      icon: Icons.engineering,
                      label: l10n.notifyingMechanics,
                      isComplete: currentStep > 4,
                      isActive: currentStep == 4,
                    ),
                    if (currentStep >= 5) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '✅ ${l10n.contactsNotified(_emergencyContacts.length)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '✅ ${l10n.mechanicsAlerted(mechanicsAlerted)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '✅ ${l10n.locationLabel(_currentLocationText ?? '')}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.staySafeHelpOnWay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              actions: [
                if (currentStep >= 5 || errorMessage != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (errorMessage == null) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(l10n.ok),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isComplete,
    required bool isActive,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Icon or spinner
        if (isComplete)
          Icon(Icons.check_circle, color: scheme.primary, size: 20)
        else if (isActive)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          )
        else
          Icon(
            Icons.circle_outlined,
            color: scheme.outline.withOpacity(0.5),
            size: 20,
          ),
        const SizedBox(width: 12),
        // Label
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isComplete || isActive
                  ? scheme.onSurface
                  : scheme.onSurface.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Execute SOS activation steps sequentially
  Future<void> _executeSOSSteps(
    StateSetter setDialogState,
    Function(int step, String? error, int mechanics) updateProgress,
  ) async {
    try {
      // Step 1: Detecting location (already done, show progress for visibility)
      await Future.delayed(const Duration(milliseconds: 800));
      updateProgress(2, null, 0);

      // Step 2: Get user profile and create SOS event
      await Future.delayed(const Duration(milliseconds: 600));
      
      final userProfile = await _firestoreService.getMyProfile();
      final userName = userProfile?['name'] ?? 'User';
      final userPhone = userProfile?['phone'] ?? '';

      final sosId = await _sosService.activateSOS(
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        location: _currentLocationText ?? '',
        latitude: _latitude,
        longitude: _longitude,
        notes: 'Emergency SOS activated via app',
        emergencyType: _selectedEmergencyType, // Pass emergency type
      );

      if (sosId == null) {
        throw Exception('Failed to create SOS event');
      }

      updateProgress(3, null, 0);
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 3: Send SMS to emergency contacts
      if (_emergencyContacts.isNotEmpty) {
        await _sosService.sendSMSToContacts(
          sosId: sosId,
          contacts: _emergencyContacts,
          userName: userName,
          userPhone: userPhone,
          location: _currentLocationText ?? '',
          latitude: _latitude,
          longitude: _longitude,
        );
      }

      updateProgress(4, null, 0);
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 4: Alert nearby mechanics
      final mechanicsAlerted = await _sosService.alertNearbyMechanics(
        sosId: sosId,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        location: _currentLocationText ?? '',
        latitude: _latitude,
        longitude: _longitude,
      );

      updateProgress(5, null, mechanicsAlerted);
    } catch (e) {
      updateProgress(5, 'Failed to activate SOS: ${e.toString()}', 0);
    }
  }

  Future<void> _callPrimaryContact() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_emergencyContacts.isEmpty) {
      SnackBarHelper.showError(
        context,
        l10n.noEmergencyContactsAdded,
      );
      return;
    }

    final success = await _sosService.callPrimaryContact(userId);
    if (!success && mounted) {
      SnackBarHelper.showError(context, l10n.unableToMakeCall);
    }
  }

  Future<void> _callEmergencyServices() async {
    final l10n = AppLocalizations.of(context)!;
    
    final success = await _sosService.callEmergencyServices();
    if (!success && mounted) {
      SnackBarHelper.showError(context, l10n.unableToDial112);
    }
  }
}

// ═══════════════════════════════════════════
// COUNTDOWN DIALOG (Separate StatefulWidget)
// ═══════════════════════════════════════════

class _CountdownDialog extends StatefulWidget {
  final ColorScheme scheme;

  const _CountdownDialog({required this.scheme});

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _countdown = 3;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (_cancelled || !mounted) return;
      
      setState(() {
        _countdown = i;
      });
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (!_cancelled && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _cancel() {
    setState(() {
      _cancelled = true;
    });
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.scheme.errorContainer,
      title: Row(
        children: [
          Icon(Icons.warning, color: widget.scheme.error),
          const SizedBox(width: 8),
          const Text('Activating SOS'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _countdown.toString(),
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: widget.scheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SOS will be activated in $_countdown second${_countdown > 1 ? 's' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: widget.scheme.onErrorContainer,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _cancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.scheme.surface,
            foregroundColor: widget.scheme.onSurface,
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
