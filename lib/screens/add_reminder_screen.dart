import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/service_reminder.dart';
import '../models/vehicle.dart';
import '../services/reminder_service.dart';
import '../services/vehicle_service.dart';
import '../utils/snackbar_helper.dart';

class AddReminderScreen extends StatefulWidget {
  final ServiceReminder? reminder; // For editing

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _formKey = GlobalKey<FormState>();
  final ReminderService _reminderService = ReminderService();
  final VehicleService _vehicleService = VehicleService();

  final _titleC = TextEditingController();
  final _descriptionC = TextEditingController();
  final _mileageC = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedVehicleId;
  String? _selectedVehicleName;
  String? _selectedReminderType;

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _initializeForm();
  }

  Future<void> _loadVehicles() async {
    final vehicles = await _vehicleService.getVehicles(userId);
    setState(() {
      _vehicles = vehicles;
      _isLoading = false;
    });
  }

  void _initializeForm() {
    if (widget.reminder != null) {
      final r = widget.reminder!;
      _titleC.text = r.title;
      _descriptionC.text = r.description ?? '';
      _mileageC.text = r.mileage?.toString() ?? '';
      _selectedDate = r.reminderDate;
      _selectedVehicleId = r.vehicleId;
      _selectedVehicleName = r.vehicleName;
      _selectedReminderType = r.reminderType;
    } else {
      _selectedReminderType = ServiceReminder.reminderTypes[0];
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descriptionC.dispose();
    _mileageC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editReminder : l10n.addReminder),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? _buildNoVehiclesState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Selector
                        _buildVehicleSelector(),
                        const SizedBox(height: 16),

                        // Reminder Type
                        _buildReminderTypeDropdown(),
                        const SizedBox(height: 16),

                        // Title
                        _buildTextField(
                          controller: _titleC,
                          label: l10n.reminderTitle,
                          hint: l10n.reminderTitleHint,
                          icon: Icons.title,
                        ),
                        const SizedBox(height: 16),

                        // Description (Optional)
                        _buildTextField(
                          controller: _descriptionC,
                          label: l10n.descriptionOptional,
                          hint: l10n.addNotesOrDetails,
                          icon: Icons.description,
                          maxLines: 3,
                          required: false,
                        ),
                        const SizedBox(height: 16),

                        // Date Picker
                        _buildDatePicker(),
                        const SizedBox(height: 16),

                        // Mileage (Optional)
                        _buildTextField(
                          controller: _mileageC,
                          label: l10n.mileageOptional,
                          hint: l10n.mileageHint,
                          icon: Icons.speed,
                          keyboardType: TextInputType.number,
                          required: false,
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _saveReminder,
                            icon: const Icon(Icons.save),
                            label: Text(
                              isEdit ? l10n.updateReminder : l10n.createReminder,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ═══════════════════════════════════════════
  // FORM WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildVehicleSelector() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.selectVehicle} *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVehicleId,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.directions_car),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          hint: Text(l10n.chooseVehicle),
          items: _vehicles.map((vehicle) {
            return DropdownMenuItem(
              value: vehicle.id,
              child: Row(
                children: [
                  Text(vehicle.typeEmoji),
                  const SizedBox(width: 8),
                  Text(vehicle.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedVehicleId = value;
              _selectedVehicleName =
                  _vehicles.firstWhere((v) => v.id == value).name;
            });
          },
          validator: (v) => v == null ? l10n.pleaseSelectVehicle : null,
        ),
      ],
    );
  }

  Widget _buildReminderTypeDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.reminderType} *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedReminderType,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: ServiceReminder.reminderTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getReminderTypeDisplayName(type, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedReminderType = value;
            });
          },
          validator: (v) => v == null ? l10n.pleaseSelectType : null,
        ),
      ],
    );
  }

  // Helper method to get localized display name for reminder types
  String _getReminderTypeDisplayName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'General Service':
        return l10n.reminderTypeGeneralService;
      case 'Oil Change':
        return l10n.reminderTypeOilChange;
      case 'Tire Rotation':
        return l10n.reminderTypeTireRotation;
      case 'Tire Check':
        return l10n.reminderTypeTireCheck;
      case 'Battery Check':
        return l10n.reminderTypeBatteryCheck;
      case 'Brake Service':
        return l10n.reminderTypeBrakeService;
      case 'Insurance Renewal':
        return l10n.reminderTypeInsuranceRenewal;
      case 'Pollution Check':
        return l10n.reminderTypePollutionCheck;
      case 'Engine Check':
        return l10n.reminderTypeEngineCheck;
      case 'AC Service':
        return l10n.reminderTypeAcService;
      case 'Wheel Alignment':
        return l10n.reminderTypeWheelAlignment;
      case 'Custom':
        return l10n.reminderTypeCustom;
      default:
        return type;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? l10n.required : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.reminderDate} *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? l10n.selectADate
                        : dateFormat.format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate == null
                          ? scheme.onSurface.withOpacity(0.5)
                          : scheme.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: scheme.onSurface),
              ],
            ),
          ),
        ),
        if (_selectedDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              l10n.pleaseSelectDate,
              style: TextStyle(
                fontSize: 12,
                color: scheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoVehiclesState() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              l10n.addVehicleFirstMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) {
      SnackBarHelper.showError(context, l10n.pleaseFillAllRequiredFields);
      return;
    }

    if (_selectedDate == null) {
      SnackBarHelper.showError(context, l10n.pleaseSelectReminderDate);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final isEdit = widget.reminder != null;

      if (isEdit) {
        // Update existing reminder
        final success = await _reminderService.updateReminder(
          userId: userId,
          reminderId: widget.reminder!.id,
          title: _titleC.text.trim(),
          description: _descriptionC.text.trim().isEmpty
              ? null
              : _descriptionC.text.trim(),
          reminderDate: _selectedDate!,
          reminderType: _selectedReminderType!,
          mileage: _mileageC.text.trim().isEmpty
              ? null
              : int.tryParse(_mileageC.text.trim()),
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          final l10n = AppLocalizations.of(context)!;

          if (success) {
            SnackBarHelper.showSuccess(context, l10n.reminderUpdated);
            Navigator.pop(context); // Go back to list
          } else {
            SnackBarHelper.showError(context, l10n.failedToUpdateReminder);
          }
        }
      } else {
        // Create new reminder
        final reminderId = await _reminderService.createReminder(
          userId: userId,
          vehicleId: _selectedVehicleId!,
          vehicleName: _selectedVehicleName!,
          title: _titleC.text.trim(),
          description: _descriptionC.text.trim().isEmpty
              ? null
              : _descriptionC.text.trim(),
          reminderDate: _selectedDate!,
          reminderType: _selectedReminderType!,
          mileage: _mileageC.text.trim().isEmpty
              ? null
              : int.tryParse(_mileageC.text.trim()),
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          final l10n = AppLocalizations.of(context)!;

          if (reminderId != null) {
            SnackBarHelper.showSuccess(context, l10n.reminderCreated);
            Navigator.pop(context); // Go back to list
          } else {
            SnackBarHelper.showError(context, l10n.failedToCreateReminder);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
      }
    }
  }
}
