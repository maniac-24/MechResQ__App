import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'emergency_contacts_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _auth = AuthService();

  // Helper: Get localized gender name
  String _getLocalizedGender(String genderKey, AppLocalizations l10n) {
    switch (genderKey) {
      case "Male":
        return l10n.male;
      case "Female":
        return l10n.female;
      case "Other":
        return l10n.other;
      default:
        return genderKey;
    }
  }

  // Helper: Get localized language name
  String _getLocalizedLanguageName(String languageKey, AppLocalizations l10n) {
    switch (languageKey.trim()) {
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

  // Helper: Get localized state name
  String _getLocalizedStateName(String stateKey, AppLocalizations l10n) {
    switch (stateKey.trim()) {
      case "Andaman & Nicobar Islands":
        return l10n.stateAndaman;
      case "Andhra Pradesh":
        return l10n.stateAndhra;
      case "Arunachal Pradesh":
        return l10n.stateArunachal;
      case "Assam":
        return l10n.stateAssam;
      case "Bihar":
        return l10n.stateBihar;
      case "Chandigarh":
        return l10n.stateChandigarh;
      case "Chhattisgarh":
        return l10n.stateChhattisgarh;
      case "Delhi":
        return l10n.stateDelhi;
      case "Goa":
        return l10n.stateGoa;
      case "Gujarat":
        return l10n.stateGujarat;
      case "Haryana":
        return l10n.stateHaryana;
      case "Himachal Pradesh":
        return l10n.stateHimachal;
      case "Jharkhand":
        return l10n.stateJharkhand;
      case "Karnataka":
        return l10n.stateKarnataka;
      case "Kerala":
        return l10n.stateKerala;
      case "Madhya Pradesh":
        return l10n.stateMadhya;
      case "Maharashtra":
        return l10n.stateMaharashtra;
      case "Punjab":
        return l10n.statePunjab;
      case "Rajasthan":
        return l10n.stateRajasthan;
      case "Tamil Nadu":
        return l10n.stateTamilNadu;
      case "Telangana":
        return l10n.stateTelangana;
      case "Uttar Pradesh":
        return l10n.stateUttar;
      case "West Bengal":
        return l10n.stateWestBengal;
      default:
        return stateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _auth.getMyProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: scheme.primary,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                l10n.couldNotLoadProfile,
                style: TextStyle(color: scheme.onSurface),
              ),
            );
          }

          final profile = snapshot.data!;

          // Safe read from Firestore map
          final name = (profile["name"] ?? "User").toString();
          final email = (profile["email"] ?? "").toString();
          final phone = (profile["phone"] ?? "").toString();
          
          // Personal Information (Primary tab data) - RAW keys from database
          final genderKey = (profile["gender"] ?? "").toString();
          final dob = (profile["dob"] ?? "").toString();
          
          // Languages - get raw keys from database
          List<String> languageKeys = [];
          if (profile["languages"] is List) {
            languageKeys = List<String>.from(profile["languages"]);
          } else if (profile["languages"] is String) {
            final langStr = profile["languages"].toString();
            if (langStr.isNotEmpty) {
              languageKeys = langStr.split(',').map((e) => e.trim()).toList();
            }
          }
          
          // Other Information - RAW keys from database
          final pincode = (profile["pincode"] ?? "").toString();
          final city = (profile["city"] ?? "").toString();
          final stateKey = (profile["state"] ?? "").toString();

          // Now get LOCALIZED versions for display
          final gender = genderKey.isNotEmpty ? _getLocalizedGender(genderKey, l10n) : "";
          final languages = languageKeys.isNotEmpty 
              ? languageKeys.map((key) => _getLocalizedLanguageName(key, l10n)).join(", ")
              : "";
          final state = stateKey.isNotEmpty ? _getLocalizedStateName(stateKey, l10n) : "";

          final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- PROFILE HEADER ----------------
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: scheme.primary,
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- CONTACT INFORMATION ----------------
                Text(
                  l10n.contactInformation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  color: scheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                phone,
                                style: TextStyle(
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          Divider(
                            height: 24,
                            color: scheme.outlineVariant,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: scheme.onSurface.withOpacity(0.7),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- PERSONAL INFORMATION ----------------
                if (gender.isNotEmpty || dob.isNotEmpty || languages.isNotEmpty) ...[
                  Text(
                    l10n.personalInformation,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: scheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (gender.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.person_outline,
                              l10n.gender,
                              gender,
                              scheme,
                            ),
                          ],
                          if (gender.isNotEmpty && (dob.isNotEmpty || languages.isNotEmpty))
                            Divider(height: 24, color: scheme.outlineVariant),
                          
                          if (dob.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.cake_outlined,
                              l10n.dateOfBirth,
                              dob,
                              scheme,
                            ),
                          ],
                          if (dob.isNotEmpty && languages.isNotEmpty)
                            Divider(height: 24, color: scheme.outlineVariant),
                          
                          if (languages.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.language_outlined,
                              l10n.languagesKnown,
                              languages,
                              scheme,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // ---------------- OTHER INFORMATION ----------------
                if (pincode.isNotEmpty || city.isNotEmpty || state.isNotEmpty) ...[
                  Text(
                    l10n.otherInformation,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: scheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (pincode.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.pin_drop_outlined,
                              l10n.pincode,
                              pincode,
                              scheme,
                            ),
                          ],
                          if (pincode.isNotEmpty && (city.isNotEmpty || state.isNotEmpty))
                            Divider(height: 24, color: scheme.outlineVariant),
                          
                          if (city.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.location_city_outlined,
                              l10n.city,
                              city,
                              scheme,
                            ),
                          ],
                          if (city.isNotEmpty && state.isNotEmpty)
                            Divider(height: 24, color: scheme.outlineVariant),
                          
                          if (state.isNotEmpty) ...[
                            _buildInfoRow(
                              Icons.map_outlined,
                              l10n.state,
                              state,
                              scheme,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // ---------------- ACTION BUTTONS ----------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.editProfile),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.contact_emergency),
                    label: Text(l10n.emergencyContacts),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyContactsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "MechResQ • v1.0.0",
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme scheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: scheme.onSurface.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}