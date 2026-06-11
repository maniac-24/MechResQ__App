import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';

class MyVehiclesScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showAddForm;
  final VoidCallback? onAddFormClosed;

  const MyVehiclesScreen({
    super.key,
    this.showAppBar = true,
    this.showAddForm = false,
    this.onAddFormClosed,
  });

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _showAddForm = widget.showAddForm;
  }

  @override
  void didUpdateWidget(MyVehiclesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAddForm != oldWidget.showAddForm) {
      setState(() {
        _showAddForm = widget.showAddForm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddForm) {
      // Show Add Form - Full screen without parent AppBar interference
      return _AddVehicleForm(
        userId: userId,
        onCancel: () {
          setState(() {
            _showAddForm = false;
          });
          widget.onAddFormClosed?.call();
        },
        onSuccess: () {
          setState(() {
            _showAddForm = false;
          });
          widget.onAddFormClosed?.call();
        },
      );
    }

    // Show Vehicle List
    // Only show AppBar if showAppBar is true (when not in tab navigation)
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myVehicles),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _showAddForm = true;
                });
              },
              tooltip: AppLocalizations.of(context)!.addVehicle,
            ),
          ],
        ),
        body: _VehiclesList(userId: userId),
      );
    }

    // No AppBar when shown in tab navigation - NO floating button
    return _VehiclesList(userId: userId);
  }
}

// ═══════════════════════════════════════════
// VEHICLE LIST VIEW
// ═══════════════════════════════════════════

class _VehiclesList extends StatelessWidget {
  final String userId;

  const _VehiclesList({required this.userId});

  @override
  Widget build(BuildContext context) {
    final vehicleService = VehicleService();

    return StreamBuilder<List<Vehicle>>(
      stream: vehicleService.getVehiclesStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final vehicles = snapshot.data ?? [];

        if (vehicles.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            return _buildVehicleCard(context, vehicles[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: scheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noVehiclesAdded,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapPlusToAddVehicle,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showVehicleDetails(context, vehicle),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          radius: 28,
          child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    vehicle.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show emoji if image fails to load
                      return Text(
                        vehicle.typeEmoji,
                        style: const TextStyle(fontSize: 24),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  vehicle.typeEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
        ),
        title: Text(
          vehicle.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${vehicle.displayName}\n${vehicle.licensePlate}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.delete),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'delete') {
              final confirmed = await _confirmDelete(context);
              if (confirmed == true) {
                final vehicleService = VehicleService();
                final success =
                    await vehicleService.deleteVehicle(userId, vehicle.id);

                if (context.mounted) {
                  if (success) {
                    SnackBarHelper.showSuccess(
                      context,
                      AppLocalizations.of(context)!.vehicleDeleted,
                    );
                  } else {
                    SnackBarHelper.showError(
                      context,
                      AppLocalizations.of(context)!.failedToDeleteVehicle,
                    );
                  }
                }
              }
            }
          },
        ),
      ),
    );
  }

  // Show vehicle details dialog
  void _showVehicleDetails(BuildContext context, Vehicle vehicle) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(vehicle.typeEmoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vehicle.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    vehicle.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _detailRow(l10n.type, vehicle.type),
              _detailRow(l10n.make, vehicle.make),
              _detailRow(l10n.model, vehicle.model),
              _detailRow(l10n.year, vehicle.year),
              _detailRow(l10n.licenseplate, vehicle.licensePlate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVehicleQuestion),
        content: Text(l10n.deleteVehiclePermanently),
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
  }
}

// ═══════════════════════════════════════════
// ADD VEHICLE FORM
// ═══════════════════════════════════════════

class _AddVehicleForm extends StatefulWidget {
  final String userId;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const _AddVehicleForm({
    required this.userId,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<_AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<_AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Standard vehicle types — "Other" triggers custom text field
  static const List<String> _standardTypes = [
    'Car', 'Bike', 'Truck', 'Scooter', 'Auto', 'Bus', 'Other'
  ];

  // Fuel type options
  static const List<String> _fuelTypes = [
    'Petrol', 'Diesel', 'CNG', 'Electric'
  ];

  // Custom vehicle types added by users (in-memory, persisted to Firestore later)
  static final List<String> _customTypes = [];

  final _customTypeC = TextEditingController(); // "Other" custom type
  final _makeC = TextEditingController();       // Brand/Company
  final _modelC = TextEditingController();
  final _yearC = TextEditingController();
  final _plateC = TextEditingController();

  String? _selectedType;   // selected from dropdown
  String? _finalType;      // resolved type (standard or custom)
  String? _fuelType;
  File? _image;
  bool _showCustomTypeField = false;

  @override
  void dispose() {
    _customTypeC.dispose();
    _makeC.dispose();
    _modelC.dispose();
    _yearC.dispose();
    _plateC.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // PERMISSION EXPLANATION (only WHY, not HOW)
  // ------------------------------------------------
  Future<bool?> _showPermissionExplanation() async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.storageAccessNeeded,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.needAccessPhotosUpload,
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.continueButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
            ],
          ),
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
                  l10n.uploadVehicleImage,
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
  // ✅ CORRECTED PERMISSION FLOW
  // ------------------------------------------------
  Future<void> _chooseImage() async {
    try {
      // Check permission status FIRST
      PermissionStatus storageStatus;
      if (Platform.isAndroid) {
        final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
        storageStatus = sdk >= 33
            ? await Permission.photos.status
            : await Permission.storage.status;
      } else {
        storageStatus = await Permission.storage.status;
      }

      // ONLY show explanation if permission is NOT granted
      if (!storageStatus.isGranted) {
        if (!mounted) return;
        final userWantsToContinue = await _showPermissionExplanation();

        if (userWantsToContinue != true) {
          if (!mounted) return;
          SnackBarHelper.showWarning(
            context,
            AppLocalizations.of(context)!.permissionNeededUpload,
          );
          return;
        }

        // Now request actual system permission
        PermissionStatus newPermission;
        if (Platform.isAndroid) {
          final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
          newPermission = sdk >= 33
              ? await Permission.photos.request()
              : await Permission.storage.request();
        } else {
          newPermission = await Permission.storage.request();
        }

        // Handle denial
        if (newPermission.isDenied) {
          if (!mounted) return;
          SnackBarHelper.showError(
            context,
            AppLocalizations.of(context)!.permissionDeniedCannotUpload,
          );
          return;
        }

        // Handle permanently denied
        if (newPermission.isPermanentlyDenied) {
          if (!mounted) return;
          SnackBarHelper.showWarning(
            context,
            AppLocalizations.of(context)!.permissionPermanentlyDeniedOpening,
          );
          await Future.delayed(const Duration(seconds: 2));
          await openAppSettings();
          return;
        }
      }

      // Permission is now granted → show file picker
      if (!mounted) return;
      final fileChoice = await _showFilePickerBottomSheet();
      if (fileChoice == null) return;

      XFile? result;

      if (fileChoice == 'camera') {
        // Check camera status FIRST
        final cameraStatus = await Permission.camera.status;

        if (!cameraStatus.isGranted) {
          final cameraPermission = await Permission.camera.request();
          if (!cameraPermission.isGranted) {
            if (!mounted) return;
            SnackBarHelper.showError(
              context,
              AppLocalizations.of(context)!.cameraPermissionRequired,
            );
            return;
          }
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
      } else if (fileChoice == 'file') {
        result = await openFile(
          acceptedTypeGroups: [
            XTypeGroup(
              label: 'Images',
              extensions: ['jpg', 'jpeg', 'png'],
            ),
          ],
        );
      }

      // File selected successfully
      if (result != null && result.path.isNotEmpty) {
        setState(() {
          _image = File(result!.path);
        });

        if (!mounted) return;
        SnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.imageSelected(result.name),
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

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    // Resolve final vehicle type
    if (_selectedType == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.vehiclePleaseSelectType)),
      );
      return;
    }

    if (_selectedType == 'Other') {
      final custom = _customTypeC.text.trim();
      if (custom.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.vehiclePleaseEnterType)),
        );
        return;
      }
      _finalType = custom;
      // Save custom type so future dropdowns show it
      if (!_customTypes.contains(custom)) {
        setState(() => _customTypes.add(custom));
      }
    } else {
      _finalType = _selectedType;
    }

    // Derive vehicle name from brand + model
    final make = _makeC.text.trim();
    final model = _modelC.text.trim();
    final derivedName = make.isNotEmpty && model.isNotEmpty
        ? '$make $model'
        : (make.isNotEmpty ? make : (_finalType ?? 'Vehicle'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final vehicleService = VehicleService();
      final vehicleId = await vehicleService.addVehicle(
        userId: widget.userId,
        name: derivedName,
        type: _finalType!,
        make: make,
        model: model,
        year: _yearC.text.trim(),
        licensePlate: _plateC.text.trim(),
        fuelType: _fuelType,
        imageFile: _image,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (vehicleId != null) {
        SnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.vehicleAddedSuccessfully,
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedType = null;
          _fuelType = null;
          _image = null;
          _showCustomTypeField = false;
          _customTypeC.clear();
          _makeC.clear();
          _modelC.clear();
          _yearC.clear();
          _plateC.clear();
        });
        widget.onSuccess();
      } else {
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.failedToAddVehicle,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      SnackBarHelper.showError(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // All vehicle types: standard + any user-added custom types
    final standardTypes = [
      l10n.vehicleTypeCar,
      l10n.vehicleTypeBike,
      l10n.vehicleTypeTruck,
      l10n.vehicleTypeScooter,
      l10n.vehicleTypeAuto,
      l10n.vehicleTypeBus,
      l10n.vehicleTypeOther,
    ];
    final fuelTypes = [
      l10n.vehicleFuelPetrol,
      l10n.vehicleFuelDiesel,
      l10n.vehicleFuelCng,
      l10n.vehicleFuelElectric,
    ];
    final allTypes = [...standardTypes, ..._customTypes];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
        title: Text(l10n.addVehicle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. VEHICLE TYPE (first field, with "Other" option)
              _InlineDropdown(
                label: l10n.vehicleTypeLabel,
                value: _selectedType,
                items: allTypes,
                onChanged: (val) {
                  setState(() {
                    _selectedType = val;
                    _showCustomTypeField = val == l10n.vehicleTypeOther;
                  });
                },
                scheme: scheme,
              ),
              const SizedBox(height: 14),

              // 1b. Custom vehicle type field
              if (_showCustomTypeField) ...[
                TextFormField(
                  controller: _customTypeC,
                  decoration: InputDecoration(
                    labelText: l10n.vehicleTypeLabel,
                    hintText: l10n.vehicleCustomTypeHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => _selectedType == l10n.vehicleTypeOther &&
                          (v == null || v.trim().isEmpty)
                      ? l10n.required
                      : null,
                ),
                const SizedBox(height: 14),
              ],

              // 2. BRAND
              TextFormField(
                controller: _makeC,
                decoration: InputDecoration(
                  labelText: l10n.vehicleBrandLabel,
                  hintText: l10n.vehicleBrandHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),

              // 3. MODEL
              TextFormField(
                controller: _modelC,
                decoration: InputDecoration(
                  labelText: l10n.model,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),

              // 4. FUEL TYPE
              _InlineDropdown(
                label: l10n.vehicleFuelTypeLabel,
                value: _fuelType,
                items: fuelTypes,
                onChanged: (val) => setState(() => _fuelType = val),
                scheme: scheme,
              ),
              const SizedBox(height: 14),

              // 5. REGISTRATION NUMBER
              TextFormField(
                controller: _plateC,
                decoration: InputDecoration(
                  labelText: l10n.vehicleRegistrationLabel,
                  hintText: l10n.vehicleRegistrationHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 14),

              // 6. YEAR
              TextFormField(
                controller: _yearC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.yearEg2020,
                  hintText: 'e.g., 2020',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 18),

              // 7. IMAGE PICKER
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(6),
                      color: scheme.surfaceContainerHigh,
                    ),
                    child: _image == null
                        ? Center(
                            child: Text(
                              l10n.noImage,
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    onPressed: _chooseImage,
                    icon: const Icon(Icons.image),
                    label: Text(l10n.chooseImage),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // 8. CANCEL / ADD VEHICLE BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _addVehicle,
                      child: Text(
                        l10n.addVehicle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? l10n.required : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// INLINE DROPDOWN — expands list just below the field
// ═══════════════════════════════════════════

class _InlineDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final ColorScheme scheme;

  const _InlineDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.scheme,
  });

  @override
  State<_InlineDropdown> createState() => _InlineDropdownState();
}

class _InlineDropdownState extends State<_InlineDropdown> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final selected = widget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The tap target that looks like a text field
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _open
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.35),
                width: _open ? 2 : 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(6),
                topRight: const Radius.circular(6),
                bottomLeft: Radius.circular(_open ? 0 : 6),
                bottomRight: Radius.circular(_open ? 0 : 6),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected ?? widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: selected == null
                          ? scheme.onSurface.withValues(alpha: 0.45)
                          : scheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        // The expandable list — renders inline just below the field
        if (_open)
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: scheme.primary, width: 2),
                right: BorderSide(color: scheme.primary, width: 2),
                bottom: BorderSide(color: scheme.primary, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: widget.items.map((item) {
                final isSelected = item == selected;
                return InkWell(
                  onTap: () {
                    widget.onChanged(item);
                    setState(() => _open = false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check,
                              size: 18, color: scheme.primary),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
