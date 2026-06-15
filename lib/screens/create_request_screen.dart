// lib/screens/create_request_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../services/request_firestore_service.dart';
import '../services/request_tracking_service.dart';
import '../services/cloudinary_service.dart';
import '../utils/location_permission_utils.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/map_location_picker.dart';
import '../l10n/app_localizations.dart';

class CreateRequestScreen extends StatefulWidget {
  final Map<String, String>? mechanic;

  const CreateRequestScreen({super.key, this.mechanic});

  @override
  _CreateRequestScreenState createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _descriptionController = TextEditingController();
  final _vehicleDetailsController = TextEditingController();
  final _customVehicleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedVehicle = 'Car';
  bool _showCustomVehicle = false;
  final List<String> _attachedFiles = []; // absolute file paths
  String? _detectedAddress;
  double? _userLat;
  double? _userLng;
  bool _locationDetected = false;
  bool _detecting = false;
  bool _submitting = false;

  Map<String, String>? _mechanic;
  final RequestFirestoreService _requestService = RequestFirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.mechanic != null) _mechanic = widget.mechanic;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mechanic == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, String>) _mechanic = args;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _vehicleDetailsController.dispose();
    _customVehicleController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // PERMISSION BOTTOM SHEET
  // ------------------------------------------------
  Future<String?> _showPermissionBottomSheet() async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  l10n.mechresqWantsAccessStorage,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  l10n.neededToAttachPhotos,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: scheme.outlineVariant, height: 1),
              _permissionOption(context,
                  title: l10n.whileUsingApp, value: 'while_using'),
              Divider(color: scheme.outlineVariant, height: 1),
              _permissionOption(context,
                  title: l10n.onlyThisTime, value: 'only_this_time'),
              Divider(color: scheme.outlineVariant, height: 1),
              _permissionOption(context, title: l10n.dontAllow, value: null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionOption(BuildContext context,
      {required String title, required String? value}) {
    final scheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Text(
          title,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ------------------------------------------------
  // FILE PICKER BOTTOM SHEET
  // ------------------------------------------------
  Future<String?> _showFilePickerBottomSheet() async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  l10n.uploadIdDocument,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: scheme.outlineVariant, height: 1),
              _fileOption(context,
                  icon: Icons.camera_alt,
                  title: l10n.takePhoto,
                  value: 'camera'),
              Divider(color: scheme.outlineVariant, height: 1),
              _fileOption(context,
                  icon: Icons.photo_library,
                  title: l10n.chooseFromGallery,
                  value: 'gallery'),
              Divider(color: scheme.outlineVariant, height: 1),
              _fileOption(context,
                  icon: Icons.videocam,
                  title: 'Record / choose video',
                  value: 'video'),
              Divider(color: scheme.outlineVariant, height: 1),
              _fileOption(context,
                  icon: Icons.insert_drive_file,
                  title: l10n.choosePdfFile,
                  value: 'file'),
              Divider(color: scheme.outlineVariant, height: 1),
              _fileOption(context,
                  icon: Icons.close, title: l10n.cancel, value: null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileOption(BuildContext context,
      {required IconData icon, required String title, required String? value}) {
    final scheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // ATTACH FILE WITH PERMISSION & FILE PICKER
  // ------------------------------------------------
  Future<void> _attachFile() async {
    try {
      // Step 1: ALWAYS show permission bottom sheet first
      final permissionChoice = await _showPermissionBottomSheet();

      // User tapped "Don't allow" or dismissed
      if (permissionChoice == null) {
        if (!mounted) return;
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.cannotAttachFiles,
        );
        return;
      }

      // Step 2: Check and request actual system permission
      PermissionStatus permissionStatus;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permissionStatus = await Permission.photos.status;
        } else {
          permissionStatus = await Permission.storage.status;
        }
      } else {
        permissionStatus = await Permission.storage.status;
      }

      // Request permission if not granted
      if (!permissionStatus.isGranted) {
        PermissionStatus newPermission;
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            newPermission = await Permission.photos.request();
          } else {
            newPermission = await Permission.storage.request();
          }
        } else {
          newPermission = await Permission.storage.request();
        }

        // Handle system permission denial
        if (newPermission.isDenied) {
          if (!mounted) return;
          SnackBarHelper.showError(
            context,
            AppLocalizations.of(context)!.cannotAttachFiles,
          );
          return;
        }

        // Handle permanently denied → redirect to settings
        if (newPermission.isPermanentlyDenied) {
          if (!mounted) return;
          SnackBarHelper.showWarning(
            context,
            AppLocalizations.of(context)!.permissionPermanentlyDenied,
          );
          await Future.delayed(const Duration(seconds: 2));
          await openAppSettings();
          return;
        }
      }

      // Step 3: Permission granted → show file picker options
      if (!mounted) return;
      final fileChoice = await _showFilePickerBottomSheet();
      if (fileChoice == null) return;

      XFile? result;

      if (fileChoice == 'camera') {
        // Request camera permission separately
        final cameraPermission = await Permission.camera.request();
        if (!cameraPermission.isGranted) {
          if (!mounted) return;
          SnackBarHelper.showError(
            context,
            AppLocalizations.of(context)!.cameraPermissionRequired,
          );
          return;
        }
        result = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      } else if (fileChoice == 'gallery') {
        result = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
      } else if (fileChoice == 'video') {
        result = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60),
        );
      } else if (fileChoice == 'file') {
        result = await openFile(
          acceptedTypeGroups: [
            XTypeGroup(
              label: 'Documents',
              extensions: ['pdf', 'jpg', 'jpeg', 'png'],
            ),
          ],
        );
      }

      // Step 4: File selected successfully
      if (result != null && result.path.isNotEmpty) {
        setState(() {
          _attachedFiles.add(result!.path);
        });

        if (!mounted) return;
        SnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.attached(result.name),
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        'Error: ${e.toString()}',
      );
    }
  }

  /// Optionally convert lat/lng to a readable address using Geocoding API.
  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if (p.street != null && p.street!.isNotEmpty) p.street!,
        if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
          p.administrativeArea!,
        if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
        if (p.country != null && p.country!.isNotEmpty) p.country!,
      ];
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _detecting = true;
      _locationDetected = false;
      _detectedAddress = null;
      _userLat = null;
      _userLng = null;
    });

    try {
      // First, check if location permission is already granted
      final permission = await Geolocator.checkPermission();
      
      LocationPermissionResult result;
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        // Permission already granted, no need to show dialog
        result = LocationPermissionResult.granted;
      } else {
        // Permission not granted, show dialog and request
        result = await requestLocationPermissionWithExplanation(context);
      }
      
      if (!mounted) return;

      if (result != LocationPermissionResult.granted) {
        handlePermissionResult(context, result: result);
        setState(() => _detecting = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final lat = position.latitude;
      final lng = position.longitude;

      // Get address directly
      final address = await _reverseGeocode(lat, lng);
      
      if (mounted) {
        setState(() {
          _userLat = lat;
          _userLng = lng;
          _detectedAddress = address ??
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
          _locationDetected = true;
        });
        
        SnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.locationDetectedSuccessfully,
        );
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.locationServicesDisabled,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          '${AppLocalizations.of(context)!.couldNotGetLocation}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _removeAttached(String f) => setState(() => _attachedFiles.remove(f));

  Future<void> _onSubmit() async {
    final issueText = _descriptionController.text.trim();
    final vehicleDetails = _vehicleDetailsController.text.trim();
    final effectiveVehicle = _selectedVehicle == 'Other'
        ? _customVehicleController.text.trim()
        : _selectedVehicle;

    if (_selectedVehicle == 'Other' && effectiveVehicle.isEmpty) {
      SnackBarHelper.showError(context, 'Please enter your vehicle type');
      return;
    }
    if (vehicleDetails.isEmpty) {
      SnackBarHelper.showError(
        context,
        'Please enter your vehicle brand, model & year',
      );
      return;
    }
    if (issueText.isEmpty) {
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.pleaseDescribeIssue,
      );
      return;
    }
    if (!_locationDetected) {
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.pleaseDetectLocation,
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // Extract mechanicId if mechanic is present
      String? mechanicId;
      if (_mechanic != null && _mechanic!['id'] != null) {
        mechanicId = _mechanic!['id'];
      }

      // Upload attached media to Cloudinary (free hosting) so the
      // mechanic can actually view the photos/videos.
      List<String>? mediaUrls;
      if (_attachedFiles.isNotEmpty) {
        try {
          mediaUrls = await CloudinaryService.uploadAll(
            _attachedFiles.map((p) => File(p)).toList(),
            folder: 'requests',
          );
        } catch (e) {
          // Non-fatal: submit the request without media rather than block.
          if (mounted) {
            SnackBarHelper.showWarning(
              context,
              'Could not upload media, submitting without it.',
            );
          }
        }
      }

      // Create request in Firestore (with lat/lng and optional address)
      final requestId = await _requestService.createRequest(
        vehicleType: effectiveVehicle,
        issue: issueText,
        vehicleDetails: vehicleDetails,
        location: _detectedAddress ?? '',
        mechanicId: mechanicId,
        images: mediaUrls,
        userLat: _userLat,
        userLng: _userLng,
        locationAddress: _detectedAddress,
      );

      // Create tracking document immediately so Track screen works
      try {
        final uid = _requestService.currentUserId;
        if (uid != null && _userLat != null && _userLng != null) {
          await RequestTrackingService().createTracking(
            requestId: requestId,
            userId: uid,
            userLatitude: _userLat!,
            userLongitude: _userLng!,
            userAddress: _detectedAddress,
          );
        }
      } catch (_) {
        // Non-fatal — trackRequest() will auto-create as fallback
      }

      // Clear form (optional)
      if (mounted) {
        setState(() {
          _descriptionController.clear();
          _vehicleDetailsController.clear();
          _customVehicleController.clear();
          _showCustomVehicle = false;
          _attachedFiles.clear();
          _locationDetected = false;
          _detectedAddress = null;
          _userLat = null;
          _userLng = null;
        });
      }

      // Navigate to bill screen instead of generic success screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/bill',
          arguments: {
            'requestId': requestId,
            'vehicle': effectiveVehicle,
            'issue': issueText,
            'location': _detectedAddress ?? '',
            'distanceKm': 5.0, // default; replaced by real mechanic distance later
          },
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          '${AppLocalizations.of(context)!.failedToSubmitRequest}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _mechanicHeader() {
    if (_mechanic == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final name = _mechanic!['name'] ?? '';
    final shop = _mechanic!['shopName'] ?? '';
    final rating = _mechanic!['rating'] ?? '';
    final distance = _mechanic!['distanceKm'] ?? '';

    return Card(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: scheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'M',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: scheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.place,
                        size: 14,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$distance km',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachedChips() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    if (_attachedFiles.isEmpty) {
      return Text(
        l10n.noPhotosAttached,
        style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _attachedFiles.map((f) {
        final name = f.split(Platform.pathSeparator).last;
        return Chip(
          label: Text(name),
          backgroundColor: scheme.surfaceContainerHighest,
          labelStyle: TextStyle(color: scheme.onSurface),
          onDeleted: () => _removeAttached(f),
        );
      }).toList(),
    );
  }

  Widget _vehicleSelector() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    Widget btn(String type, IconData icon, String label) {
      final selected = _selectedVehicle == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _selectedVehicle = type;
            _showCustomVehicle = type == 'Other';
          }),
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? scheme.primary : scheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('Car', Icons.directions_car, l10n.car),
        btn('Bike', Icons.two_wheeler, 'Bike'),
        btn('Auto', Icons.electric_rickshaw, 'Auto'),
        btn('Other', Icons.more_horiz, 'Other'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createServiceRequest),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              color: scheme.surfaceContainerHighest,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18.0,
                  horizontal: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_mechanic != null) _mechanicHeader(),
                    const SizedBox(height: 4),
                    Text(
                      l10n.requestDetails,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.provideDetailsQuickly,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.local_taxi, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.selectVehicleType,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _vehicleSelector(),
                    if (_showCustomVehicle) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customVehicleController,
                        style: TextStyle(color: scheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Enter vehicle type (e.g. Bus, Tractor)',
                          hintStyle: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: scheme.outlineVariant),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vehicle Brand, Model & Year',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleDetailsController,
                      style: TextStyle(color: scheme.onSurface),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. Honda Activa, 2019',
                        hintStyle: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        helperText:
                            'Helps the mechanic bring the right tools & parts',
                        helperStyle: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.build, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.describeTheIssue,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 8,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: l10n.describeIssuePlaceholder,
                        hintStyle: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _attachFile,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: scheme.onPrimary,
                          ),
                          label: Text(
                            l10n.attachPhoto,
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _attachedChips()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.place, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.yourLocation,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _detecting ? null : _detectLocation,
                          icon: _detecting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  color: scheme.onPrimary,
                                ),
                          label: Text(
                            _detecting ? l10n.detecting : l10n.detectMyLocation,
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_locationDetected) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: scheme.tertiary),
                        ),
                        child: Text(
                          l10n.liveLocationDetected,
                          style: TextStyle(color: scheme.onTertiaryContainer),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        readOnly: true,
                        style: TextStyle(color: scheme.onSurface),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          border: const OutlineInputBorder(),
                          hintText: _detectedAddress,
                          hintStyle: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerLowest,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else
                      Text(
                        l10n.locationNotDetectedTap,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _onSubmit,
                        icon: _submitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : Icon(Icons.send, color: scheme.onPrimary),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Text(
                            _submitting ? l10n.submitting : l10n.submitRequest,
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        l10n.tipProvideDescription,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(l10n.cancel),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}