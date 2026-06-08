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

  final _nameC = TextEditingController();
  final _makeC = TextEditingController();
  final _modelC = TextEditingController();
  final _yearC = TextEditingController();
  final _plateC = TextEditingController();

  String? _vehicleType;
  File? _image;

  @override
  void dispose() {
    _nameC.dispose();
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

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Add vehicle to Firestore
      final vehicleService = VehicleService();
      final vehicleId = await vehicleService.addVehicle(
        userId: widget.userId,
        name: _nameC.text.trim(),
        type: _vehicleType!,
        make: _makeC.text.trim(),
        model: _modelC.text.trim(),
        year: _yearC.text.trim(),
        licensePlate: _plateC.text.trim(),
        imageFile: _image,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      if (vehicleId != null) {
        SnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.vehicleAddedSuccessfully,
        );

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _vehicleType = null;
          _image = null;
          _nameC.clear();
          _makeC.clear();
          _modelC.clear();
          _yearC.clear();
          _plateC.clear();
        });

        // Call success callback to switch to list view
        widget.onSuccess();
      } else {
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.failedToAddVehicle,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      SnackBarHelper.showError(
        context,
        'Error: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Get localized vehicle types
    final vehicleTypes = [
      l10n.car,
      l10n.bike,
      l10n.truck,
      l10n.otherVehicle,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
        title: Text(l10n.addVehicle),
        // No actions, no extra buttons
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _input(_nameC, l10n.vehicleName),
            const SizedBox(height: 14),
            _dropdown(
              label: l10n.vehicleType,
              value: _vehicleType,
              items: vehicleTypes,
              onChanged: (v) => setState(() => _vehicleType = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _input(_makeC, l10n.make)),
                const SizedBox(width: 12),
                Expanded(child: _input(_modelC, l10n.model)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _input(
                    _yearC,
                    l10n.yearEg2020,
                    keyboard: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _input(_plateC, l10n.licenseplate)),
              ],
            ),
            const SizedBox(height: 18),
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
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      setState(() {
                        _vehicleType = null;
                        _image = null;
                      });
                    },
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