import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/snackbar_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  
  bool _isLoading = true;
  bool _isSaving = false;

  // PRIMARY INFO
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _dobC = TextEditingController();

  String? _gender; // Made nullable
  List<String> _languages = [];

  // OTHER INFO
  final _pincodeC = TextEditingController();
  final _cityC = TextEditingController();
  String? _state; // Made nullable

  // SETTINGS (only essential for emergency app)
  bool _serviceReminders = true;

  final List<String> _languagesList = [
    "English",
    "Hindi",
    "Kannada",
    "Tamil",
    "Telugu",
    "Malayalam",
    "Bengali",
    "Marathi",
    "Gujarati",
    "Punjabi",
    "Odia",
    "Urdu",
  ];

  final List<String> _states = [
    "Andaman & Nicobar Islands",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chandigarh",
    "Chhattisgarh",
    "Delhi",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Telangana",
    "Uttar Pradesh",
    "West Bengal",
  ];

  // Get localized language names
  List<String> _getLocalizedLanguages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.langEnglish,
      l10n.langHindi,
      l10n.langKannada,
      l10n.langTamil,
      l10n.langTelugu,
      l10n.langMalayalam,
      l10n.langBengali,
      l10n.langMarathi,
      l10n.langGujarati,
      l10n.langPunjabi,
      l10n.langOdia,
      l10n.langUrdu,
    ];
  }

  // Get localized name for a single language (by English key)
  String _getLocalizedLanguageName(String languageKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (languageKey) {
      case "English":
        return l10n.langEnglish;
      case "Hindi":
        return l10n.langHindi;
      case "Kannada":
        return l10n.langKannada;
      case "Tamil":
        return l10n.langTamil;
      case "Telugu":
        return l10n.langTelugu;
      case "Malayalam":
        return l10n.langMalayalam;
      case "Bengali":
        return l10n.langBengali;
      case "Marathi":
        return l10n.langMarathi;
      case "Gujarati":
        return l10n.langGujarati;
      case "Punjabi":
        return l10n.langPunjabi;
      case "Odia":
        return l10n.langOdia;
      case "Urdu":
        return l10n.langUrdu;
      default:
        return languageKey;
    }
  }

  // Get localized state names
  List<String> _getLocalizedStates(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.stateAndaman,
      l10n.stateAndhra,
      l10n.stateArunachal,
      l10n.stateAssam,
      l10n.stateBihar,
      l10n.stateChandigarh,
      l10n.stateChhattisgarh,
      l10n.stateDelhi,
      l10n.stateGoa,
      l10n.stateGujarat,
      l10n.stateHaryana,
      l10n.stateHimachal,
      l10n.stateJharkhand,
      l10n.stateKarnataka,
      l10n.stateKerala,
      l10n.stateMadhya,
      l10n.stateMaharashtra,
      l10n.statePunjab,
      l10n.stateRajasthan,
      l10n.stateTamilNadu,
      l10n.stateTelangana,
      l10n.stateUttar,
      l10n.stateWestBengal,
    ];
  }

  // Get localized name for a single state (by English key)
  String _getLocalizedStateName(String stateKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Trim whitespace and normalize the key for comparison
    final normalizedKey = stateKey.trim();
    
    // Direct mapping ensures we always get the correct localized name
    String result;
    switch (normalizedKey) {
      case "Andaman & Nicobar Islands":
        result = l10n.stateAndaman;
        break;
      case "Andhra Pradesh":
        result = l10n.stateAndhra;
        break;
      case "Arunachal Pradesh":
        result = l10n.stateArunachal;
        break;
      case "Assam":
        result = l10n.stateAssam;
        break;
      case "Bihar":
        result = l10n.stateBihar;
        break;
      case "Chandigarh":
        result = l10n.stateChandigarh;
        break;
      case "Chhattisgarh":
        result = l10n.stateChhattisgarh;
        break;
      case "Delhi":
        result = l10n.stateDelhi;
        break;
      case "Goa":
        result = l10n.stateGoa;
        break;
      case "Gujarat":
        result = l10n.stateGujarat;
        break;
      case "Haryana":
        result = l10n.stateHaryana;
        break;
      case "Himachal Pradesh":
        result = l10n.stateHimachal;
        break;
      case "Jharkhand":
        result = l10n.stateJharkhand;
        break;
      case "Karnataka":
        result = l10n.stateKarnataka;
        break;
      case "Kerala":
        result = l10n.stateKerala;
        break;
      case "Madhya Pradesh":
        result = l10n.stateMadhya;
        break;
      case "Maharashtra":
        result = l10n.stateMaharashtra;
        break;
      case "Punjab":
        result = l10n.statePunjab;
        break;
      case "Rajasthan":
        result = l10n.stateRajasthan;
        break;
      case "Tamil Nadu":
        result = l10n.stateTamilNadu;
        break;
      case "Telangana":
        result = l10n.stateTelangana;
        break;
      case "Uttar Pradesh":
        result = l10n.stateUttar;
        break;
      case "West Bengal":
        result = l10n.stateWestBengal;
        break;
      default:
        result = stateKey; // Fallback to English key if not found
    }
    
    return result;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  /// Load existing profile data from Firestore
  Future<void> _loadProfileData() async {
    try {
      final profile = await _auth.getMyProfile();
      
      if (profile != null && mounted) {
        setState(() {
          // Primary Info
          _nameC.text = (profile['name'] ?? '').toString();
          _emailC.text = (profile['email'] ?? '').toString();
          _phoneC.text = (profile['phone'] ?? '').toString();
          _gender = profile['gender']?.toString();
          
          // Languages - handle both List and String
          if (profile['languages'] is List) {
            _languages = List<String>.from(profile['languages']);
          } else if (profile['languages'] is String) {
            final langStr = profile['languages'].toString();
            _languages = langStr.isNotEmpty 
                ? langStr.split(',').map((e) => e.trim()).toList()
                : [];
          }
          
          _dobC.text = (profile['dob'] ?? '').toString();
          
          // Other Info
          _pincodeC.text = (profile['pincode'] ?? '').toString();
          _cityC.text = (profile['city'] ?? '').toString();
          _state = profile['state']?.toString();
          
          // Settings
          _serviceReminders = profile['serviceReminders'] ?? true;
          
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, "${AppLocalizations.of(context)!.failedToLoadProfile}: $e");
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _dobC.dispose();
    _pincodeC.dispose();
    _cityC.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // LANGUAGE SELECTOR
  // ------------------------------------------------------------------
  void _openLanguageSelector() {
    final localizedLanguages = _getLocalizedLanguages(context);
    
    showDialog(
      context: context,
      builder: (_) => _LanguageDialog(
        initial: List.from(_languages),
        allLanguagesKeys: _languagesList,
        allLanguagesDisplay: localizedLanguages,
        onSave: (selected) {
          setState(() => _languages = selected);
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // STATE SELECTOR
  // ------------------------------------------------------------------
  void _openStateSelector() {
    final localizedStates = _getLocalizedStates(context);
    
    showDialog(
      context: context,
      builder: (_) => _StateDialog(
        initialKey: _state ?? _states.first,
        allStatesKeys: _states,
        allStatesDisplay: localizedStates,
        onSave: (selected) {
          setState(() => _state = selected);
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // DATE PICKER
  // ------------------------------------------------------------------
  void _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      setState(() {
        _dobC.text = formatter.format(picked);
      });
    }
  }

  // ------------------------------------------------------------------
  // SAVE PROFILE (PRIMARY + OTHER INFO)
  // ------------------------------------------------------------------
  Future<void> _savePrimaryAndOtherInfo() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Validate required fields
    if (_nameC.text.trim().isEmpty) {
      SnackBarHelper.showError(context, l10n.nameRequired);
      return;
    }
    
    if (_phoneC.text.trim().isEmpty) {
      SnackBarHelper.showError(context, l10n.phoneRequired);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Prepare data - only send non-empty values
      await _firestore.updateCompleteUserProfile(
        name: _nameC.text.trim(),
        email: _emailC.text.trim().isNotEmpty ? _emailC.text.trim() : null,
        phone: _phoneC.text.trim(),
        gender: _gender,
        languages: _languages.isNotEmpty ? _languages : null,
        dob: _dobC.text.trim().isNotEmpty ? _dobC.text.trim() : null,
        pincode: _pincodeC.text.trim().isNotEmpty ? _pincodeC.text.trim() : null,
        city: _cityC.text.trim().isNotEmpty ? _cityC.text.trim() : null,
        state: _state,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.profileSaved);
        
        // Wait a moment for Firestore to propagate the change
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Pop back to profile screen (StreamBuilder will auto-update)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "${l10n.failedToSaveProfile}: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ------------------------------------------------------------------
  // SAVE SETTINGS
  // ------------------------------------------------------------------
  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isSaving = true);

    try {
      await _firestore.updateCompleteUserProfile(
        serviceReminders: _serviceReminders,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.settingsSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, "${l10n.failedToSaveSettings}: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Show loading indicator while profile data is loading
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: scheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: scheme.primary,
          tabs: [
            Tab(text: l10n.primary),
            Tab(text: l10n.otherInfo),
            Tab(text: l10n.settings),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_primaryTab(), _otherInfoTab(), _settingsTab()],
      ),
    );
  }

  // ------------------------------------------------------------------
  // TABS
  // ------------------------------------------------------------------
  Widget _primaryTab() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    // Gender options - store as English but display as localized
    final genderOptions = ["Male", "Female", "Other"];
    final genderDisplayMap = {
      "Male": l10n.male,
      "Female": l10n.female,
      "Other": l10n.other,
    };
    
    // Get localized language display text - lookup fresh for each language
    String languageDisplayText = "";
    if (_languages.isNotEmpty) {
      final displayNames = <String>[];
      for (var lang in _languages) {
        displayNames.add(_getLocalizedLanguageName(lang, context));
      }
      languageDisplayText = displayNames.join(", ");
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _input(l10n.fullName, _nameC),
          _input(l10n.email, _emailC),
          _input(l10n.phone, _phoneC),
          _dropdownWithMapping(
            label: l10n.gender,
            value: _gender,
            items: genderOptions,
            displayMap: genderDisplayMap,
            onChanged: (v) => setState(() => _gender = v),
          ),
          _picker(
            l10n.languagesKnown,
            languageDisplayText,
            _openLanguageSelector,
          ),
          _picker(
            l10n.dob,
            _dobC.text,
            _pickDOB,
          ),
          
          const SizedBox(height: 24),
          
          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSaving ? null : _savePrimaryAndOtherInfo,
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.saveProfile,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherInfoTab() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    // Get localized state display text - lookup fresh each time to ensure correct locale
    String stateDisplayText = "";
    if (_state != null) {
      stateDisplayText = _getLocalizedStateName(_state!, context);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _input(l10n.pincode, _pincodeC),
          _input(l10n.city, _cityC),
          _picker(l10n.state, stateDisplayText, _openStateSelector),
          
          const SizedBox(height: 24),
          
          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSaving ? null : _savePrimaryAndOtherInfo,
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.saveProfile,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTab() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NOTIFICATIONS ---
          _sectionHeader(l10n.notifications, Icons.notifications_outlined),
          _settingSwitch(
            l10n.serviceReminders,
            l10n.serviceRemindersDesc,
            _serviceReminders,
            (v) => setState(() => _serviceReminders = v),
          ),

          const SizedBox(height: 24),

          // --- ACCOUNT ACTIONS ---
          _sectionHeader(l10n.account, Icons.person_outline),
          _settingTile(
            l10n.deleteAccount,
            l10n.deleteAccountDesc,
            Icons.delete_forever_outlined,
            () => _confirmDeleteAccount(),
            color: scheme.error,
          ),

          const SizedBox(height: 28),

          // SAVE
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSaving ? null : _saveSettings,
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.saveSettings,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // SETTINGS HELPERS
  // ------------------------------------------------------------------
  Widget _sectionHeader(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: scheme.primary,
        inactiveThumbColor: scheme.outline,
        inactiveTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _settingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: scheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }

  void _confirmDeleteAccount() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(
          l10n.deleteAccountTitle,
          style: TextStyle(color: scheme.onSurface),
        ),
        content: Text(
          l10n.deleteAccountMessage,
          style: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              SnackBarHelper.showWarning(
                context,
                l10n.accountDeletionRequested,
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // PRIMARY / OTHER INFO HELPERS
  // ------------------------------------------------------------------
  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text("${l10n.select} $label"),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _dropdownWithMapping({
    required String label,
    required String? value,
    required List<String> items,
    required Map<String, String> displayMap,
    required ValueChanged<String?> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text("${l10n.select} $label"),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(displayMap[e] ?? e),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _picker(String label, String value, VoidCallback onTap) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            value.isEmpty ? "${l10n.select} $label" : value,
            style: TextStyle(
              color: value.isEmpty 
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// LANGUAGE DIALOG
// ==================================================================
class _LanguageDialog extends StatefulWidget {
  final List<String> initial;
  final List<String> allLanguagesKeys;
  final List<String> allLanguagesDisplay;
  final ValueChanged<List<String>> onSave;

  const _LanguageDialog({
    required this.initial,
    required this.allLanguagesKeys,
    required this.allLanguagesDisplay,
    required this.onSave,
  });

  @override
  State<_LanguageDialog> createState() => __LanguageDialogState();
}

class __LanguageDialogState extends State<_LanguageDialog> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      backgroundColor: scheme.surface,
      title: Text(
        l10n.languagesKnown,
        style: TextStyle(color: scheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            itemCount: widget.allLanguagesKeys.length,
            itemBuilder: (_, i) {
              final langKey = widget.allLanguagesKeys[i];
              final langDisplay = widget.allLanguagesDisplay[i];
              
              return CheckboxListTile(
                title: Text(
                  langDisplay,
                  style: TextStyle(color: scheme.onSurface),
                ),
                value: _selected.contains(langKey),
                activeColor: scheme.primary,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selected.add(langKey);
                    } else {
                      _selected.remove(langKey);
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selected);
            Navigator.pop(context);
          },
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}

// ==================================================================
// STATE DIALOG
// ==================================================================
class _StateDialog extends StatefulWidget {
  final String initialKey;
  final List<String> allStatesKeys;
  final List<String> allStatesDisplay;
  final ValueChanged<String> onSave;

  const _StateDialog({
    required this.initialKey,
    required this.allStatesKeys,
    required this.allStatesDisplay,
    required this.onSave,
  });

  @override
  State<_StateDialog> createState() => __StateDialogState();
}

class __StateDialogState extends State<_StateDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialKey;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      backgroundColor: scheme.surface,
      title: Text(
        l10n.selectState,
        style: TextStyle(color: scheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            itemCount: widget.allStatesKeys.length,
            itemBuilder: (_, i) {
              final stateKey = widget.allStatesKeys[i];
              final stateDisplay = widget.allStatesDisplay[i];
              
              return RadioListTile<String>(
                title: Text(
                  stateDisplay,
                  style: TextStyle(color: scheme.onSurface),
                ),
                value: stateKey,
                groupValue: _selected,
                activeColor: scheme.primary,
                onChanged: (v) {
                  setState(() => _selected = v!);
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selected);
            Navigator.pop(context);
          },
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}