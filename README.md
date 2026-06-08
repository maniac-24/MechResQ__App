# MechResQ - Emergency Roadside Assistance App

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

**MechResQ** is a comprehensive emergency roadside assistance mobile application built with Flutter. It connects users with nearby mechanics during vehicle emergencies, providing real-time tracking, service billing, digital payments, receipt generation, and multi-language support.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Localization](#localization)
- [Firebase Setup](#firebase-setup)
- [Permissions](#permissions)
- [Build and Run](#build-and-run)
- [Key Services](#key-services)
- [App Statistics](#app-statistics)
- [Theming](#theming)
- [Roadmap](#roadmap)
- [License](#license)

---

## Features

### Core Features
- **Emergency SOS** - Quick access to emergency assistance with one tap
- **Real-time Location Tracking** - Live mechanic tracking with Google Maps integration
- **Find Nearby Mechanics** - Discover mechanics based on your current location
- **In-app Chat** - Direct communication with assigned mechanics
- **Ratings and Reviews** - Rate and review mechanic services
- **Service Request Management** - Create, track, and manage service requests

### Billing and Payments
- **Smart Bill Screen** - Auto-calculated service estimate shown immediately after request creation
- **Dynamic Pricing Engine** - Calculates cost based on vehicle type, issue complexity, distance, labour, spare parts, platform fee, and GST (18%)
- **Pay by Cash or Digitally** - Razorpay integration for digital payments; cash payment flow with confirmation
- **Digital Receipts** - Instant PDF receipt generation after digital payment
- **PDF Download** - Unlimited receipt downloads with MechResQ branding
- **Payment History** - Full payment history screen with filter options

### Request Lifecycle
- **Estimate Mode** - Bill screen shown after submission with Cancel Request option
- **Tracking Mode** - Track on Map button appears in Active tab when request is accepted
- **History Mode** - View Bill and Pay button in History tab for completed requests
- **Receipt View** - View Receipt button after payment; accessible from History tab indefinitely

### User Management
- **Multi-auth Support** - Email/Password and Google Sign-In
- **Profile Management** - Complete user profile with personal and vehicle information
- **Vehicle Management** - Add and manage multiple vehicles
- **Emergency Contacts** - Store and manage emergency contact information
- **Service Reminders** - Schedule and receive vehicle service reminders

### Additional Features
- **Multi-language Support** - English and Kannada with full localization coverage
- **Dark and Light Theme** - Hazard-focused theme with customizable appearance
- **Push Notifications** - Real-time notifications for service updates with smart navigation
- **Request History** - View all past service requests with delete options (individual and bulk)
- **SOS History** - Track all emergency events
- **Legal and Support** - Terms, Privacy Policy, and Help documentation

---

## Architecture

MechResQ follows a feature-based architecture with clear separation of concerns:

```
lib/
+-- core/           # Core utilities and constants
+-- l10n/           # Localization files (English and Kannada)
+-- models/         # Data models
+-- screens/        # UI screens
+-- services/       # Business logic and Firebase integration
+-- utils/          # Helper utilities
+-- widgets/        # Reusable UI components
+-- locale_provider.dart    # Language management
+-- theme_controller.dart   # Theme management
+-- theme.dart              # App theming
+-- main.dart               # App entry point
```

### Design Patterns
- **Provider** for state management
- **Service Layer** for business logic separation
- **Repository Pattern** for data access
- **Singleton Pattern** for Firebase services

---

## Tech Stack

### Frontend
- **Flutter** 3.10+ - Cross-platform UI framework
- **Material Design 3** - Modern UI components
- **Provider** - State management solution

### Backend and Services
- **Firebase Authentication** - User authentication (Email, Google)
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Storage** - Image and file storage
- **Firebase Cloud Messaging** - Push notifications

### Maps and Location
- **Google Maps Flutter** - Map integration
- **Geolocator** - Location services
- **Geocoding** - Address resolution

### Payments
- **Razorpay Flutter** - Payment gateway (Test and Live mode support)
- **PDF** - Receipt and invoice generation
- **Printing** - PDF preview, download, and share

### Additional Packages
- **flutter_localizations** - Internationalization
- **intl** - Date/time formatting and localization
- **cached_network_image** - Efficient image loading
- **image_picker** - Camera and gallery access
- **url_launcher** - External link handling
- **flutter_secure_storage** - Secure data storage
- **permission_handler** - Runtime permissions
- **timezone** - Timezone handling
- **path_provider** - File system access for PDF saving

---

## Project Structure

```
MechResQ_App/
+-- android/                    # Android native code
+-- ios/                        # iOS native code
+-- assets/                     # Images, icons, and assets
|   +-- icons/                 # App icons
|   +-- mechresq_logo.png      # App logo (used in receipts and PDF)
|   +-- mechresq_logo.svg      # SVG version of logo
+-- lib/
|   +-- core/                  # Core utilities
|   |   +-- config/
|   |       +-- payment_config.dart   # Razorpay keys and settings
|   +-- l10n/                  # Localization
|   |   +-- app_en.arb         # English translations (350+ strings)
|   |   +-- app_kn.arb         # Kannada translations (350+ strings)
|   |   +-- app_localizations.dart
|   +-- models/                # Data models
|   |   +-- emergency_contact.dart
|   |   +-- payment.dart
|   |   +-- receipt.dart
|   |   +-- request_tracking.dart
|   |   +-- service_reminder.dart
|   |   +-- sos_event.dart
|   |   +-- vehicle.dart
|   +-- screens/               # UI Screens
|   |   +-- bill_screen.dart
|   |   +-- chat_mechanic_screen.dart
|   |   +-- create_request_screen.dart
|   |   +-- home_screen.dart
|   |   +-- login_screen.dart
|   |   +-- my_requests_screen.dart
|   |   +-- payment_history_screen.dart
|   |   +-- receipt_detail_screen.dart
|   |   +-- receipt_success_screen.dart
|   |   +-- request_tracking_screen.dart
|   |   +-- settings_screen.dart
|   |   +-- submit_review_screen.dart
|   |   +-- track_mechanic_screen.dart
|   |   +-- ... (additional screens)
|   +-- services/              # Business logic services
|   |   +-- auth_service.dart
|   |   +-- billing_service.dart
|   |   +-- firestore_service.dart
|   |   +-- location_service.dart
|   |   +-- notification_service.dart
|   |   +-- payment_firestore_service.dart
|   |   +-- pdf_receipt_service.dart
|   |   +-- razorpay_service.dart
|   |   +-- receipt_service.dart
|   |   +-- request_firestore_service.dart
|   |   +-- request_tracking_service.dart
|   |   +-- review_service.dart
|   |   +-- sos_service.dart
|   |   +-- vehicle_service.dart
|   +-- utils/                 # Helper utilities
|   +-- widgets/               # Reusable components
|   +-- locale_provider.dart   # Language management
|   +-- theme_controller.dart  # Theme management
|   +-- theme.dart             # App theming
|   +-- main.dart              # Entry point
+-- test/                      # Unit and widget tests
+-- pubspec.yaml               # Dependencies
+-- l10n.yaml                  # Localization config
+-- README.md                  # This file
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher
- Android Studio or Xcode (for mobile development)
- Firebase Account (for backend services)
- Google Maps API Key (for map features)
- Razorpay Account (for payment features)

### Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd MechResQ_App
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Generate localization files
   ```bash
   flutter gen-l10n
   ```

4. Configure Firebase (see Firebase Setup section)

5. Add Google Maps API Key (see Configuration section)

6. Run the app
   ```bash
   flutter run
   ```

---

## Configuration

### Google Maps API Key

1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android and Maps SDK for iOS
3. Add the key to:

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS:** `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### Razorpay Configuration

Open `lib/core/config/payment_config.dart` and update:

```dart
static const String razorpayKeyId = 'rzp_live_YOUR_KEY_HERE';
static const bool isTestMode = false;
```

For test mode, use the test key. For production, replace with your live key from the Razorpay Dashboard.

---

## Localization

MechResQ supports multi-language internationalization.

### Supported Languages
- English (en) - Complete (350+ strings)
- Kannada (kn) - Complete (350+ strings)

### Planned Languages
- Hindi (hi)
- Tamil (ta)
- Telugu (te)
- Malayalam (ml)

### Coverage
- All screens fully localized
- Dynamic language switching at runtime
- Language preference persisted across app restarts
- Billing and receipt screens fully translated

### Adding a New Language

1. Create a new ARB file: `lib/l10n/app_<locale>.arb`
2. Copy `app_en.arb` and translate all strings
3. Add the locale to `main.dart` supported locales:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('kn'),
     Locale('hi'), // New language
   ]
   ```
4. Run `flutter gen-l10n`

---

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android and/or iOS app

### 2. Download Configuration Files

**Android:**
- Download `google-services.json`
- Place in `android/app/`

**iOS:**
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

### 3. Enable Firebase Services

- Authentication: Email/Password and Google Sign-In
- Cloud Firestore: Create database
- Cloud Storage: Create storage bucket
- Cloud Messaging: Enable for push notifications

### 4. Firestore Collections

The app uses the following Firestore collections:

| Collection | Purpose |
|---|---|
| `users` | User profiles |
| `requests` | Service requests |
| `requestTracking` | Real-time mechanic tracking |
| `payments` | Payment transactions (legacy) |
| `receipts` | Service receipts (current) |
| `reviews` | Mechanic ratings and reviews |
| `mechanics` | Mechanic profiles (read by user app) |
| `sosEvents` | SOS emergency events |

### 5. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    match /receipts/{receiptId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

---

## Permissions

### Android Permissions (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### iOS Permissions (`Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby mechanics</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location for real-time tracking</string>

<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of vehicle issues</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

---

## Build and Run

### Development Build

```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Production Build

**Android APK (single file):**
```bash
flutter build apk --release
```

**Android APK (split by architecture - smaller size):**
```bash
flutter build apk --release --split-per-abi
```

**Android App Bundle (Play Store - recommended):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

### Debug Commands

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated

# Clean build cache
flutter clean && flutter pub get
```

---

## Key Services

### BillingService (`billing_service.dart`)
- Calculates service estimates based on vehicle type, issue description keywords, distance, and fixed charges
- Complexity detection: Low, Medium, High, Critical based on keywords
- Charges: Base service fee, Labour, Call-out/travel, Spare parts estimate, Platform fee, GST 18%

### RazorpayService (`razorpay_service.dart`)
- Wraps the Razorpay Flutter SDK
- Handles payment success, failure, and external wallet events
- Test mode and live mode configuration

### ReceiptService (`receipt_service.dart`)
- CRUD operations on the `receipts` Firestore collection
- Marks receipts as paid (digital via Razorpay or cash via mechanic confirmation)
- Real-time stream of user receipts

### PdfReceiptService (`pdf_receipt_service.dart`)
- Generates single-page A4 PDF receipts using the `pdf` package
- Includes MechResQ logo, itemised breakdown, payment info, GST note
- Share or save via system sheet using the `printing` package

### RequestTrackingService (`request_tracking_service.dart`)
- Manages the `requestTracking` Firestore collection
- Creates tracking documents on request submission
- Falls back to `requests` collection if tracking doc is missing (auto-creates)
- Sends local notifications on status transitions

### NotificationService (`notification_service.dart`)
- Local notifications via `flutter_local_notifications`
- FCM integration via `firebase_messaging`
- Smart navigation on notification tap
- Typed convenience methods for each notification event

### ReviewService (`review_service.dart`)
- Submit, update, and delete mechanic reviews
- Recalculates mechanic average rating on each submission
- Helpful/not-helpful vote system

### AuthService (`auth_service.dart`)
- Email/Password registration and login
- Google Sign-In
- Password reset and session management

---

## App Statistics

| Metric | Value |
|---|---|
| Screens | 35+ |
| Services | 15+ |
| Models | 7 |
| Localized Strings | 350+ per language |
| Supported Languages | 2 (English, Kannada) |
| Firebase Services | 4 (Auth, Firestore, Storage, Messaging) |
| Payment Gateway | Razorpay |

---

## Theming

MechResQ uses a hazard-focused theme:

- **Primary Color:** High-visibility yellow (#FFD400)
- **Accent Color:** Orange (#FF8A00)
- **Dark Theme:** Full dark mode support with hazard palette
- **Light Theme:** Clean white background with yellow primary
- **Material Design 3:** Modern accessible UI components
- **Dynamic Switching:** Users can switch Light, Dark, or System in Settings

---

## Roadmap

### Version 1.0 (Current)
- [x] Core service request and tracking features
- [x] Real-time location tracking
- [x] Bill screen with smart pricing engine
- [x] Razorpay digital payments
- [x] PDF receipt generation and download
- [x] Multi-language support (English, Kannada)
- [x] Push notifications with smart navigation
- [x] User profile and vehicle management
- [x] SOS emergency features
- [x] Ratings and reviews system
- [x] Request history with bulk delete

### Version 1.1 (Upcoming)
- [ ] Mechanic app (separate app for mechanics)
- [ ] Cash payment confirmation by mechanic
- [ ] Auto-trigger review screen after service completion
- [ ] Real GPS distance passed to billing
- [ ] FCM token saved to Firestore for server-push notifications
- [ ] Chat with Firebase Realtime integration
- [ ] Add more languages (Hindi, Tamil, Telugu)

### Version 1.2 (Future)
- [ ] AI-powered issue diagnosis
- [ ] Video call support
- [ ] Subscription plans for mechanics
- [ ] Referral and promo code system
- [ ] Advanced analytics dashboard

---

## License

This project is proprietary software. All rights reserved.

---

## Support

For support, email support@mechresq.com or open an issue in the repository.

---

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Razorpay Flutter SDK](https://pub.dev/packages/razorpay_flutter)
- [Provider Package](https://pub.dev/packages/provider)
