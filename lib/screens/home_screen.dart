import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';

import '../services/mechanic_firestore_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../widgets/mechanic_card.dart';
import '../screens/help_screen.dart';
import 'mechanic_detail_screen.dart';
import 'my_vehicles_screen.dart';
import 'my_requests_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'sos_screen.dart';
import 'service_reminders_screen.dart';

class MechanicListScreen extends StatefulWidget {
  const MechanicListScreen({super.key});

  @override
  State<MechanicListScreen> createState() => _MechanicListScreenState();
}

class _MechanicListScreenState extends State<MechanicListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _auth = AuthService();
  final MechanicFirestoreService _mechanicService = MechanicFirestoreService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  int _currentIndex = 0; // 0=Home, 1=Requests, 2=RequestHelp, 3=Vehicles

  Map<String, dynamic>? _profile;
  bool _showVehicleAddForm = false;
  String? _currentLocationAddress; // Store current location address

  // filter state
  int? _expYears;
  List<String> _selectedVehicleTypes = [];
  String? _priceRange;
  double? _maxDistanceKm;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Schedule permission check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }

  /// Load current location address
  Future<void> _loadCurrentLocation() async {
    try {
      final address = await _locationService.getCurrentAddress();
      if (mounted) {
        setState(() {
          _currentLocationAddress = address;
        });
      }
    } catch (e) {
      print('Error loading location: $e');
      if (mounted) {
        setState(() {
          _currentLocationAddress = 'Location unavailable';
        });
      }
    }
  }

  /// Check and request permissions with proper sequencing
  Future<void> _checkAndRequestPermissions() async {
    print('📍 Starting permission check...');
    
    // Wait 1 second before starting
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      print('📍 Widget not mounted, skipping permission dialog');
      return;
    }

    // STEP 1: Request location permission FIRST
    print('📍 Requesting location permission...');
    final locationGranted = await _requestLocationPermission();
    
    if (locationGranted) {
      print('📍 Location permission granted, loading location...');
      await _loadCurrentLocation();
    } else {
      print('📍 Location permission denied');
    }

    // STEP 2: Wait 2 seconds after location permission response
    print('🔔 Waiting 2 seconds before notification permission...');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      print('🔔 Widget not mounted, skipping notification dialog');
      return;
    }

    // STEP 3: Now request notification permission
    print('🔔 Checking SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final hasAsked = prefs.getBool('notification_permission_asked') ?? false;

    if (hasAsked) {
      print('🔔 Already asked before, skipping dialog');
      return;
    }

    print('🔔 Checking current notification permission status...');
    final hasPermission = await _notificationService.checkPermissions();
    if (hasPermission) {
      print('🔔 Already has notification permission');
      await prefs.setBool('notification_permission_asked', true);
      return;
    }

    // Show custom notification permission dialog
    if (!mounted) {
      print('🔔 Widget not mounted before showing dialog');
      return;
    }
    
    print('🔔 Showing notification permission dialog...');
    final shouldRequest = await _showNotificationPermissionDialog();

    if (shouldRequest == true) {
      print('🔔 User clicked Allow, requesting notification permissions...');
      final granted = await _notificationService.requestPermissions();
      await prefs.setBool('notification_permission_asked', true);
      
      if (granted) {
        print('🔔 Notification permission granted');
      }
    } else {
      print('🔔 User declined notification permission');
      await prefs.setBool('notification_permission_asked', true);
    }
  }

  /// Show custom notification permission dialog
  Future<bool?> _showNotificationPermissionDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, 
              color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Stay Updated', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allow MechResQ to send notifications to get:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildPermissionBenefit(Icons.location_on, 'Real-time mechanic location updates'),
            _buildPermissionBenefit(Icons.schedule, 'Accurate ETA and arrival notifications'),
            _buildPermissionBenefit(Icons.check_circle, 'Service status updates'),
            _buildPermissionBenefit(Icons.campaign, 'Mechanic nearby alerts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  /// Request location permission and return whether it was granted
  Future<bool> _requestLocationPermission() async {
    final hasPermission = await _locationService.hasPermission();
    if (!hasPermission) {
      final permission = await _locationService.requestPermission();
      // Check if permission was granted (either always or whileInUse)
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    }
    return true; // Already has permission
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _auth.getCurrentUserProfile();
      if (!mounted) return;
      setState(() {
        _profile = p != null ? Map<String, dynamic>.from(p) : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _profile = null);
    }
  }

  List<Map<String, dynamic>> _filterMechanics(
    List<Map<String, dynamic>> mechanics,
  ) {
    var filtered = List<Map<String, dynamic>>.from(mechanics);

    final searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final shopName = (m['shopName'] ?? '').toString().toLowerCase();
        final vehicleTypes = (m['vehicleTypes'] as List? ?? [])
            .map((e) => e.toString().toLowerCase())
            .join(',');
        return name.contains(searchQuery) ||
            shopName.contains(searchQuery) ||
            vehicleTypes.contains(searchQuery);
      }).toList();
    }

    if (_minRating != null) {
      filtered = filtered.where((m) {
        final rating = (m['rating'] ?? 0.0) as double;
        return rating >= _minRating!;
      }).toList();
    }

    if (_selectedVehicleTypes.isNotEmpty) {
      filtered = filtered.where((m) {
        final types = (m['vehicleTypes'] as List? ?? [])
            .map((e) => e.toString())
            .toList();
        return _selectedVehicleTypes.any((vt) => types.contains(vt));
      }).toList();
    }

    return filtered;
  }

  void _resetFilters() {
    setState(() {
      _expYears = null;
      _selectedVehicleTypes = [];
      _priceRange = null;
      _maxDistanceKm = null;
      _minRating = null;
      _searchController.clear();
    });
    Navigator.of(context).maybePop();
  }

  void _applyFilters() {
    setState(() {});
    Navigator.of(context).maybePop();
  }

  Map<String, String> _convertToCardFormat(Map<String, dynamic> mechanic) {
    final vehicleTypes = (mechanic['vehicleTypes'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    final rating = (mechanic['rating'] as num?)?.toDouble() ?? 0.0;
    final distanceKm = (mechanic['distanceKm'] as num?)?.toDouble() ?? 0.0;

    return {
      'id': mechanic['id']?.toString() ?? mechanic['uid']?.toString() ?? '',
      'name': mechanic['name']?.toString() ?? '',
      'shopName': mechanic['shopName']?.toString() ?? '',
      'address': mechanic['address']?.toString() ?? '',
      'experienceYears': (mechanic['experienceYears'] ?? 0).toString(),
      'vehicleTypes': vehicleTypes.join(', '),
      'serviceTypes': (mechanic['serviceTypes'] as List? ?? [])
          .map((e) => e.toString())
          .join(', '),
      'priceRange': mechanic['priceRange']?.toString() ?? '',
      'rating': rating.toStringAsFixed(1),
      'distanceKm': distanceKm.toStringAsFixed(1),
      'phone': mechanic['phone']?.toString() ?? '',
    };
  }

  Widget _buildMechanicTile(Map<String, dynamic> mechanic) {
    final map = _convertToCardFormat(mechanic);
    return MechanicCard(
      mechanic: map,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MechanicDetailScreen(mechanic: map)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _allVehicleTypes(List<Map<String, dynamic>> mechanics) {
    final s = <String>{};
    for (var m in mechanics) {
      final types = (m['vehicleTypes'] as List? ?? [])
          .map((e) => e.toString())
          .toList();
      s.addAll(types);
    }
    return s.toList();
  }

  /// Build Location Chip (Rapido-style)
  Widget _buildLocationChip(ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () async {
        // Reload location when tapped
        await _loadCurrentLocation();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: scheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Green dot indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Location address
            Expanded(
              child: _currentLocationAddress == null
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.fetchingLocation,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _currentLocationAddress!,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            
            const SizedBox(width: 8),
            
            // Chevron icon
            Icon(
              Icons.keyboard_arrow_down,
              color: scheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _auth.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', (r) => false);
    }
  }

  // ═══════════════════════════════════════════
  // FLOATING SOS BUTTON BUILDER
  // ═══════════════════════════════════════════

  Widget _buildFloatingSOSButton() {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SOSScreen()),
      ),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.emergency, size: 24),
      label: Text(
        l10n.sos,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      elevation: 8,
      heroTag: 'sos_button',
    );
  }

  // ═══════════════════════════════════════════
  // BUILD SCREENS PER TAB
  // ═══════════════════════════════════════════

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildMechanicsList();
      case 1:
        return const MyRequestsScreen(showAppBar: false);
      case 3:
        return MyVehiclesScreen(
          showAppBar: false,
          key: ValueKey('vehicles_$_showVehicleAddForm'),
          showAddForm: _showVehicleAddForm,
          onAddFormClosed: () {
            setState(() {
              _showVehicleAddForm = false;
            });
          },
        );
      default:
        return _buildMechanicsList();
    }
  }

  String _getTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentIndex) {
      case 0:
        return l10n.mechanicsNearby;
      case 1:
        return l10n.myRequests;
      case 3:
        return l10n.myVehicles;
      default:
        return 'MechResQ';
    }
  }

  Widget _buildMechanicsList() {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Full-screen map in background
        _buildMapView(),

        // Draggable bottom sheet with mechanics list
        DraggableScrollableSheet(
          initialChildSize: 0.4, // Start at 40% of screen
          minChildSize: 0.15, // Can collapse to 15% (showing just handle and location chip)
          maxChildSize: 0.85, // Can expand to 85%
          snap: true,
          snapSizes: const [0.15, 0.4, 0.85], // Snap to these positions
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle - make this area draggable
                  GestureDetector(
                    onVerticalDragUpdate: (_) {}, // Allows dragging
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        // Location chip
                        _buildLocationChip(scheme),
                        const SizedBox(height: 12),

                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchHint,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      FocusScope.of(context).unfocus();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Mechanics list
                        _buildMechanicsStreamList(scheme),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build map view showing current location and nearby mechanics
  Widget _buildMapView() {
    return FutureBuilder<LatLng?>(
      future: _getCurrentPosition(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentPosition = snapshot.data!;

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true, // Enable zoom controls
          zoomGesturesEnabled: true, // Enable pinch to zoom
          scrollGesturesEnabled: true, // Enable pan gestures
          rotateGesturesEnabled: true, // Enable rotation
          tiltGesturesEnabled: true, // Enable tilt
          mapToolbarEnabled: false,
          padding: const EdgeInsets.only(bottom: 100), // Padding for bottom sheet
          markers: {
            // Current location marker is handled by myLocationEnabled
          },
          onMapCreated: (controller) {
            // Map created
          },
        );
      },
    );
  }

  /// Get current GPS position
  Future<LatLng?> _getCurrentPosition() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return null;
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting position: $e');
      // Default to a fallback location
      return const LatLng(37.7749, -122.4194); // San Francisco
    }
  }

  /// Build mechanics stream list (extracted for reuse)
  Widget _buildMechanicsStreamList(ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _mechanicService.getVerifiedMechanicsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: scheme.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: scheme.error),
                  const SizedBox(height: 12),
                  Text(l10n.somethingWentWrong, style: TextStyle(color: scheme.onSurface)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_circle_outlined, size: 64, color: scheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noMechanicsNearby,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mechanicsWillAppear,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: scheme.onSurface.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.refresh),
                  ),
                ],
              ),
            ),
          );
        }

        final allMechanics = snapshot.data!;
        final filteredMechanics = _filterMechanics(allMechanics);

        if (filteredMechanics.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                l10n.noMatchingMechanics,
                style: TextStyle(color: scheme.onSurface),
              ),
            ),
          );
        }

        return Column(
          children: filteredMechanics.map((mechanic) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildMechanicTile(mechanic),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOldMechanicsList() {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('mechanics'),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Location Chip (Rapido-style)
          _buildLocationChip(scheme),
          const SizedBox(height: 12),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'Search by name, shop or vehicle type...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream:
                  _mechanicService.getVerifiedMechanicsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: scheme.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 60,
                            color: scheme.error
                                .withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('Something went wrong',
                            style: TextStyle(
                                color: scheme.onSurface)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 80,
                          color:
                              scheme.primary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No mechanics nearby',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mechanics will appear here\nonce they come online',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface
                                .withOpacity(0.5),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allMechanics = snapshot.data!;
                final filteredMechanics =
                    _filterMechanics(allMechanics);

                if (filteredMechanics.isEmpty) {
                  return Center(
                    child: Text(
                      'No mechanics match your search.',
                      style:
                          TextStyle(color: scheme.onSurface),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(
                        const Duration(milliseconds: 300));
                  },
                  child: ListView.separated(
                    itemCount: filteredMechanics.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _buildMechanicTile(
                            filteredMechanics[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final displayName = (_profile != null &&
            (_profile!['name'] ?? '').toString().isNotEmpty)
        ? _profile!['name'].toString()
        : 'You';

    final displayPhone = (_profile != null &&
            (_profile!['phone'] ?? '').toString().isNotEmpty)
        ? _profile!['phone'].toString()
        : (_profile != null &&
                (_profile!['email'] ?? '')
                    .toString()
                    .isNotEmpty)
            ? _profile!['email'].toString()
            : '';

    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    // If showing vehicle add form, render body without AppBar/BottomNav
    if (_currentIndex == 3 && _showVehicleAddForm) {
      return Scaffold(
        body: _buildBody(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primary,
              child: Text(
                initial,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: _currentIndex == 0
            ? [
                Builder(
                  builder: (innerCtx) => IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    tooltip: l10n.filters,
                    onPressed: () =>
                        Scaffold.of(innerCtx).openEndDrawer(),
                  ),
                ),
              ]
            : _currentIndex == 3
                ? [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Vehicle',
                      onPressed: () {
                        // Trigger add vehicle form
                        setState(() {
                          _showVehicleAddForm = true;
                        });
                      },
                    ),
                  ]
                : null,
      ),

      // ═══════════════════════════════════════
      // DRAWER — Simplified
      // ═══════════════════════════════════════
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen()),
                  );
                },
                child: Container(
                  color: scheme.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: scheme.onPrimary,
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 26,
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 16,
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (displayPhone.isNotEmpty)
                              const SizedBox(height: 4),
                            if (displayPhone.isNotEmpty)
                              Text(
                                displayPhone,
                                style: TextStyle(
                                  color: scheme.onPrimary
                                      .withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color:
                              scheme.onPrimary.withOpacity(0.7)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.serviceReminders),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ServiceRemindersScreen()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(l10n.helpSupport),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HelpScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.sos_outlined,
                    color: scheme.error),
                title: Text(
                  l10n.sosEmergency,
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SOSScreen()),
                  );
                },
              ),

              const Spacer(),
              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.logout,
                    color: Colors.red),
                title: Text(l10n.logout,
                    style: const TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _handleLogout();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // ═══════════════════════════════════════
      // FILTER DRAWER (right side)
      // ═══════════════════════════════════════
      endDrawer: _currentIndex == 0
          ? Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.filters,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge),
                          TextButton(
                            onPressed: _resetFilters,
                            child: Text(l10n.resetAll),
                          ),
                        ],
                      ),
                      const Divider(),

                      Text(l10n.experienceYears),
                      const SizedBox(height: 6),
                      DropdownButton<int?>(
                        isExpanded: true,
                        value: _expYears,
                        hint: Text(l10n.any),
                        items: [null, 1, 2, 3, 4, 5, 6, 7]
                            .map((v) => DropdownMenuItem<int?>(
                                  value: v,
                                  child: Text(v == null
                                      ? l10n.any
                                      : '$v+ ${l10n.years}'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _expYears = v),
                      ),
                      const SizedBox(height: 12),

                      Text(l10n.vehicleType),
                      const SizedBox(height: 6),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _mechanicService
                            .getVerifiedMechanicsStream(),
                        builder: (context, snapshot) {
                          // Get vehicle types from mechanics or use default list
                          List<String> vehicleTypes = [];
                          
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            vehicleTypes = _allVehicleTypes(snapshot.data!);
                          }
                          
                          // If no vehicle types from mechanics, use default common types
                          if (vehicleTypes.isEmpty) {
                            vehicleTypes = [
                              l10n.car,
                              l10n.bike,
                              l10n.scooter,
                              l10n.auto,
                              l10n.truck,
                              l10n.suv,
                              l10n.bus,
                              l10n.heavyVehicle,
                            ];
                          }
                          
                          return Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: vehicleTypes.map((vt) {
                              final selected =
                                  _selectedVehicleTypes
                                      .contains(vt);
                              return FilterChip(
                                label: Text(vt),
                                selected: selected,
                                onSelected: (s) {
                                  setState(() {
                                    if (s)
                                      _selectedVehicleTypes
                                          .add(vt);
                                    else
                                      _selectedVehicleTypes
                                          .remove(vt);
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      Text(l10n.priceRange),
                      const SizedBox(height: 6),
                      DropdownButton<String?>(
                        isExpanded: true,
                        value: _priceRange,
                        hint: Text(l10n.any),
                        items: <String?>[
                          null,
                          '100-200',
                          '150-250',
                          '200-300',
                          '300-500'
                        ]
                            .map((p) =>
                                DropdownMenuItem<String?>(
                                  value: p,
                                  child: Text(p ?? l10n.any),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _priceRange = v),
                      ),
                      const SizedBox(height: 12),

                      Text(l10n.maxDistance),
                      const SizedBox(height: 6),
                      DropdownButton<double?>(
                        isExpanded: true,
                        value: _maxDistanceKm,
                        hint: Text(l10n.any),
                        items: <double?>[
                          null,
                          2.0,
                          5.0,
                          10.0
                        ]
                            .map((d) =>
                                DropdownMenuItem<double?>(
                                  value: d,
                                  child: Text(d == null
                                      ? l10n.any
                                      : '≤ ${d}${l10n.km}'),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _maxDistanceKm = v),
                      ),
                      const SizedBox(height: 12),

                      Text(l10n.minimumRating),
                      Slider(
                        min: 0,
                        max: 5,
                        divisions: 5,
                        value: _minRating ?? 0,
                        label: (_minRating ?? 0).toString(),
                        onChanged: (val) => setState(() =>
                            _minRating = val == 0 ? null : val),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          child: Text(l10n.applyFilters),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            )
          : null,

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildBody(),
      ),

      // ═══════════════════════════════════════
      // FLOATING SOS BUTTON (Only on Home screen)
      // ═══════════════════════════════════════
      floatingActionButton: _currentIndex == 0 ? _buildFloatingSOSButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ═══════════════════════════════════════
      // BOTTOM NAV
      // ═══════════════════════════════════════
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 2 ? _currentIndex : _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Request Help tab - navigate to create request
            Navigator.pushNamed(context, '/create_request');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_outlined),
            activeIcon: const Icon(Icons.list_alt),
            label: l10n.myRequests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle),
            label: l10n.requestHelp,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car_outlined),
            activeIcon: const Icon(Icons.directions_car),
            label: l10n.myVehicles,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: scheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.8))),
        ],
      ),
    );
  }
}