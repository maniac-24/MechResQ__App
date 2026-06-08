import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn'),
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'MechResQ'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stuck on road? Help is on the way.'**
  String get welcomeSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @createUserAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createUserAccountButton;

  /// No description provided for @mechanicRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you a mechanic? Register here'**
  String get mechanicRegisterPrompt;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get googleLoginFailed;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Min {count} characters'**
  String minCharacters(int count);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRole;

  /// No description provided for @mechanicRole.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get mechanicRole;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @whatsYourNumber.
  ///
  /// In en, this message translates to:
  /// **'What\'s your number?'**
  String get whatsYourNumber;

  /// No description provided for @phoneNumberMust10Digits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get phoneNumberMust10Digits;

  /// No description provided for @pleaseEnterOnlyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Please enter only numbers'**
  String get pleaseEnterOnlyNumbers;

  /// No description provided for @enterValid10DigitMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get enterValid10DigitMobile;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @byContinu18Years.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you confirm that you are 18 years\nof age and agree to the'**
  String get byContinu18Years;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get codeSentTo;

  /// No description provided for @enterComplete6DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete 6-digit OTP'**
  String get enterComplete6DigitOtp;

  /// No description provided for @invalidOtpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtpTryAgain;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Try again.'**
  String get verificationFailed;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// No description provided for @helpUsPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience'**
  String get helpUsPersonalize;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @emailAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get emailAddressOptional;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'yourname@example.com'**
  String get emailPlaceholder;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @infoSecureMessage.
  ///
  /// In en, this message translates to:
  /// **'Your information is secure and will only be used for service delivery.'**
  String get infoSecureMessage;

  /// No description provided for @mechanicsNearby.
  ///
  /// In en, this message translates to:
  /// **'Mechanics Nearby'**
  String get mechanicsNearby;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @myVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, shop or vehicle type...'**
  String get searchHint;

  /// No description provided for @fetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get fetchingLocation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @noMechanicsNearby.
  ///
  /// In en, this message translates to:
  /// **'No mechanics nearby'**
  String get noMechanicsNearby;

  /// No description provided for @mechanicsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Mechanics will appear here\nonce they come online'**
  String get mechanicsWillAppear;

  /// No description provided for @noMatchingMechanics.
  ///
  /// In en, this message translates to:
  /// **'No mechanics match your search.'**
  String get noMatchingMechanics;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutMechResQ.
  ///
  /// In en, this message translates to:
  /// **'About MechResQ'**
  String get aboutMechResQ;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @themeSetTo.
  ///
  /// In en, this message translates to:
  /// **'Theme set to {theme}'**
  String themeSetTo(String theme);

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(String language);

  /// No description provided for @aboutMechResQDescription.
  ///
  /// In en, this message translates to:
  /// **'MechResQ\nVersion {version} (Build {build})\n\nA fast and reliable vehicle breakdown assistance app.\n\nFind nearby mechanics, request service, track your requests â€” all in one place.\n\nÂ© 2026 MechResQ. All rights reserved.'**
  String aboutMechResQDescription(String version, String build);

  /// No description provided for @allRequests.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allRequests;

  /// No description provided for @activeRequests.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeRequests;

  /// No description provided for @completedRequests.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedRequests;

  /// No description provided for @cancelledRequests.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledRequests;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @noRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'When you request help, your service requests will appear here.'**
  String get noRequestsMessage;

  /// No description provided for @requestHelp.
  ///
  /// In en, this message translates to:
  /// **'Request Help'**
  String get requestHelp;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestConfirm;

  /// No description provided for @yesCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancelRequest;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @trackMechanic.
  ///
  /// In en, this message translates to:
  /// **'Track Mechanic'**
  String get trackMechanic;

  /// No description provided for @contactMechanic.
  ///
  /// In en, this message translates to:
  /// **'Contact Mechanic'**
  String get contactMechanic;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @mechanicEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Mechanic En Route'**
  String get mechanicEnRoute;

  /// No description provided for @mechanicNearby.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Nearby'**
  String get mechanicNearby;

  /// No description provided for @mechanicArrived.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Arrived'**
  String get mechanicArrived;

  /// No description provided for @workInProgress.
  ///
  /// In en, this message translates to:
  /// **'Work in Progress'**
  String get workInProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @trackingYourRequest.
  ///
  /// In en, this message translates to:
  /// **'Tracking Your Request'**
  String get trackingYourRequest;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @mechanicDetails.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Details'**
  String get mechanicDetails;

  /// No description provided for @callMechanic.
  ///
  /// In en, this message translates to:
  /// **'Call Mechanic'**
  String get callMechanic;

  /// No description provided for @chatWithMechanic.
  ///
  /// In en, this message translates to:
  /// **'Chat with Mechanic'**
  String get chatWithMechanic;

  /// No description provided for @requestTimeline.
  ///
  /// In en, this message translates to:
  /// **'Request Timeline'**
  String get requestTimeline;

  /// No description provided for @requestPlaced.
  ///
  /// In en, this message translates to:
  /// **'Request Placed'**
  String get requestPlaced;

  /// No description provided for @mechanicAccepted.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Accepted'**
  String get mechanicAccepted;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get onTheWay;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @workStarted.
  ///
  /// In en, this message translates to:
  /// **'Work Started'**
  String get workStarted;

  /// No description provided for @workCompleted.
  ///
  /// In en, this message translates to:
  /// **'Work Completed'**
  String get workCompleted;

  /// No description provided for @awayFromYou.
  ///
  /// In en, this message translates to:
  /// **'away from you'**
  String get awayFromYou;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @emergencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Emergency Help'**
  String get emergencyHelp;

  /// No description provided for @sosDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this feature only in case of emergencies. This will send your location to nearby mechanics and emergency contacts.'**
  String get sosDescription;

  /// No description provided for @sendSosAlert.
  ///
  /// In en, this message translates to:
  /// **'Send SOS Alert'**
  String get sendSosAlert;

  /// No description provided for @sosAlertSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Alert Sent!'**
  String get sosAlertSent;

  /// No description provided for @sosAlertSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your emergency alert has been sent to nearby mechanics and your emergency contacts.'**
  String get sosAlertSentMessage;

  /// No description provided for @callEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call Emergency'**
  String get callEmergency;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @addEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Add Emergency Contact'**
  String get addEmergencyContact;

  /// No description provided for @noEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts added'**
  String get noEmergencyContacts;

  /// No description provided for @addEmergencyContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Add trusted contacts who will be notified in case of emergencies.'**
  String get addEmergencyContactMessage;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe Issue'**
  String get describeIssue;

  /// No description provided for @describeIssuePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem (e.g., engine stalls when idling)...'**
  String get describeIssuePlaceholder;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload Images (Optional)'**
  String get uploadImages;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @pleaseSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle'**
  String get pleaseSelectVehicle;

  /// No description provided for @pleaseSelectService.
  ///
  /// In en, this message translates to:
  /// **'Please select a service'**
  String get pleaseSelectService;

  /// No description provided for @pleaseDescribeIssue.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue.'**
  String get pleaseDescribeIssue;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get pleaseSelectLocation;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request Created'**
  String get requestCreated;

  /// No description provided for @requestCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to nearby mechanics. You\'ll be notified when a mechanic accepts.'**
  String get requestCreatedMessage;

  /// No description provided for @serviceTypes.
  ///
  /// In en, this message translates to:
  /// **'Service Types'**
  String get serviceTypes;

  /// No description provided for @flatTire.
  ///
  /// In en, this message translates to:
  /// **'Flat Tire'**
  String get flatTire;

  /// No description provided for @batteryJump.
  ///
  /// In en, this message translates to:
  /// **'Battery Jump'**
  String get batteryJump;

  /// No description provided for @engineIssue.
  ///
  /// In en, this message translates to:
  /// **'Engine Issue'**
  String get engineIssue;

  /// No description provided for @brakeIssue.
  ///
  /// In en, this message translates to:
  /// **'Brake Issue'**
  String get brakeIssue;

  /// No description provided for @fuelDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fuel Delivery'**
  String get fuelDelivery;

  /// No description provided for @towing.
  ///
  /// In en, this message translates to:
  /// **'Towing'**
  String get towing;

  /// No description provided for @otherServiceType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherServiceType;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @otherInformation.
  ///
  /// In en, this message translates to:
  /// **'Other Information'**
  String get otherInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @languagesKnown.
  ///
  /// In en, this message translates to:
  /// **'Languages Known'**
  String get languagesKnown;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile.'**
  String get couldNotLoadProfile;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @otherInfo.
  ///
  /// In en, this message translates to:
  /// **'Other Info'**
  String get otherInfo;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get dob;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @selectLanguagesKnown.
  ///
  /// In en, this message translates to:
  /// **'Select Languages Known'**
  String get selectLanguagesKnown;

  /// No description provided for @selectDOB.
  ///
  /// In en, this message translates to:
  /// **'Select DOB'**
  String get selectDOB;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully âœ…'**
  String get profileSaved;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @failedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get failedToSaveProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @serviceReminders.
  ///
  /// In en, this message translates to:
  /// **'Service Reminders'**
  String get serviceReminders;

  /// No description provided for @serviceRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders for upcoming service requests'**
  String get serviceRemindersDesc;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID to login'**
  String get biometricLoginDesc;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account'**
  String get deleteAccountDesc;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved âœ…'**
  String get settingsSaved;

  /// No description provided for @failedToSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get failedToSaveSettings;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. This action cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @accountDeletionRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get accountDeletionRequested;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service History'**
  String get serviceHistory;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @logoutFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Logout from Account'**
  String get logoutFromAccount;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Make'**
  String get vehicleMake;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @vehicleYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehicleYear;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @addNewVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add New Vehicle'**
  String get addNewVehicle;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// No description provided for @deleteVehicle.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicle;

  /// No description provided for @noVehiclesYet.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get noVehiclesYet;

  /// No description provided for @addYourFirstVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to get started'**
  String get addYourFirstVehicle;

  /// No description provided for @deleteVehicleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vehicle?'**
  String get deleteVehicleConfirm;

  /// No description provided for @yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get yesDelete;

  /// No description provided for @vehicleAdded.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added successfully'**
  String get vehicleAdded;

  /// No description provided for @vehicleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get vehicleUpdated;

  /// No description provided for @vehicleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Vehicle deleted'**
  String get vehicleDeleted;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @bike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// No description provided for @scooter.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get scooter;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @suv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @heavyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Heavy Vehicle'**
  String get heavyVehicle;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @viewReviews.
  ///
  /// In en, this message translates to:
  /// **'View Reviews'**
  String get viewReviews;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @awayLabel.
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get awayLabel;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed Now'**
  String get closedNow;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @cancelRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request?'**
  String get cancelRequestTitle;

  /// No description provided for @cancelRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? You can only cancel before the mechanic starts travelling.'**
  String get cancelRequestMessage;

  /// No description provided for @trackingNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking not available'**
  String get trackingNotAvailable;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get loadingMap;

  /// No description provided for @viewOnGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View on Google Maps'**
  String get viewOnGoogleMaps;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySos;

  /// No description provided for @sosEmergency.
  ///
  /// In en, this message translates to:
  /// **'SOS Emergency'**
  String get sosEmergency;

  /// No description provided for @refreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get refreshLocation;

  /// No description provided for @activatingSos.
  ///
  /// In en, this message translates to:
  /// **'Activating SOS...'**
  String get activatingSos;

  /// No description provided for @sosHistory.
  ///
  /// In en, this message translates to:
  /// **'SOS History'**
  String get sosHistory;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @markCompleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete?'**
  String get markCompleteQuestion;

  /// No description provided for @markCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{title}\" as completed?'**
  String markCompleteMessage(String title);

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder?'**
  String get deleteReminder;

  /// No description provided for @deleteReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteReminderMessage;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @noUpcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders'**
  String get noUpcomingReminders;

  /// No description provided for @noOverdueReminders.
  ///
  /// In en, this message translates to:
  /// **'No overdue reminders'**
  String get noOverdueReminders;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileage;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @dueNow.
  ///
  /// In en, this message translates to:
  /// **'Due Now'**
  String get dueNow;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @markAsCompleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete?'**
  String get markAsCompleteQuestion;

  /// No description provided for @markAsCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{title}\" as completed?'**
  String markAsCompleteMessage(String title);

  /// No description provided for @reminderMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder marked as completed âœ…'**
  String get reminderMarkedCompleted;

  /// No description provided for @failedToCompleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete reminder'**
  String get failedToCompleteReminder;

  /// No description provided for @deleteReminderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder?'**
  String get deleteReminderQuestion;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @failedToDeleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reminder'**
  String get failedToDeleteReminder;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No Reminders'**
  String get noReminders;

  /// No description provided for @tapPlusToAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first service reminder'**
  String get tapPlusToAddReminder;

  /// No description provided for @noCompletedReminders.
  ///
  /// In en, this message translates to:
  /// **'No Completed Reminders'**
  String get noCompletedReminders;

  /// No description provided for @completedRemindersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Completed reminders will appear here'**
  String get completedRemindersAppearHere;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on'**
  String get completedOn;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @chooseVehicle.
  ///
  /// In en, this message translates to:
  /// **'Choose a vehicle'**
  String get chooseVehicle;

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// No description provided for @pleaseSelectType.
  ///
  /// In en, this message translates to:
  /// **'Please select a type'**
  String get pleaseSelectType;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Title'**
  String get reminderTitle;

  /// No description provided for @reminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Oil Change Due'**
  String get reminderTitleHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @addNotesOrDetails.
  ///
  /// In en, this message translates to:
  /// **'Add notes or details'**
  String get addNotesOrDetails;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @reminderDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder Date'**
  String get reminderDate;

  /// No description provided for @selectADate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectADate;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @mileageOptional.
  ///
  /// In en, this message translates to:
  /// **'Mileage (Optional)'**
  String get mileageOptional;

  /// No description provided for @mileageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 50000'**
  String get mileageHint;

  /// No description provided for @updateReminder.
  ///
  /// In en, this message translates to:
  /// **'Update Reminder'**
  String get updateReminder;

  /// No description provided for @createReminder.
  ///
  /// In en, this message translates to:
  /// **'Create Reminder'**
  String get createReminder;

  /// No description provided for @noVehiclesAdded.
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Added'**
  String get noVehiclesAdded;

  /// No description provided for @addVehicleFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle first to create service reminders'**
  String get addVehicleFirstMessage;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @pleaseSelectReminderDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a reminder date'**
  String get pleaseSelectReminderDate;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated âœ…'**
  String get reminderUpdated;

  /// No description provided for @failedToUpdateReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to update reminder'**
  String get failedToUpdateReminder;

  /// No description provided for @reminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Reminder created âœ…'**
  String get reminderCreated;

  /// No description provided for @failedToCreateReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to create reminder'**
  String get failedToCreateReminder;

  /// No description provided for @reminderTypeGeneralService.
  ///
  /// In en, this message translates to:
  /// **'General Service'**
  String get reminderTypeGeneralService;

  /// No description provided for @reminderTypeOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change'**
  String get reminderTypeOilChange;

  /// No description provided for @reminderTypeTireRotation.
  ///
  /// In en, this message translates to:
  /// **'Tire Rotation'**
  String get reminderTypeTireRotation;

  /// No description provided for @reminderTypeTireCheck.
  ///
  /// In en, this message translates to:
  /// **'Tire Check'**
  String get reminderTypeTireCheck;

  /// No description provided for @reminderTypeBatteryCheck.
  ///
  /// In en, this message translates to:
  /// **'Battery Check'**
  String get reminderTypeBatteryCheck;

  /// No description provided for @reminderTypeBrakeService.
  ///
  /// In en, this message translates to:
  /// **'Brake Service'**
  String get reminderTypeBrakeService;

  /// No description provided for @reminderTypeInsuranceRenewal.
  ///
  /// In en, this message translates to:
  /// **'Insurance Renewal'**
  String get reminderTypeInsuranceRenewal;

  /// No description provided for @reminderTypePollutionCheck.
  ///
  /// In en, this message translates to:
  /// **'Pollution Check'**
  String get reminderTypePollutionCheck;

  /// No description provided for @reminderTypeEngineCheck.
  ///
  /// In en, this message translates to:
  /// **'Engine Check'**
  String get reminderTypeEngineCheck;

  /// No description provided for @reminderTypeAcService.
  ///
  /// In en, this message translates to:
  /// **'AC Service'**
  String get reminderTypeAcService;

  /// No description provided for @reminderTypeWheelAlignment.
  ///
  /// In en, this message translates to:
  /// **'Wheel Alignment'**
  String get reminderTypeWheelAlignment;

  /// No description provided for @reminderTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get reminderTypeCustom;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @helpDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re here 24/7 to assist you during vehicle breakdowns'**
  String get helpDescription;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get callSupport;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorials;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I request a mechanic?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'1. Go to Home screen\n2. Browse nearby mechanics or search by filters\n3. Select a mechanic\n4. Tap \'Request Service\'\n5. Fill in your vehicle details and issue\n6. Confirm your location\n7. Submit the request'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How is distance calculated?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Distance is calculated using GPS coordinates between your current location and the mechanic\'s workshop. Make sure location services are enabled for accurate results.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Can I add multiple vehicles?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Yes! Open the menu by tapping your profile icon, select \'My Vehicles\', and add unlimited vehicles. You can switch between them when creating service requests.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'What should I do in an emergency?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'1. Tap the SOS button (red button in menu)\n2. Your location will be shared automatically\n3. Emergency contacts will be notified\n4. Nearest mechanics will be alerted\n5. Stay calm and safe in your vehicle'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'How do payments work?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'All payments are processed securely through the app. You can pay via UPI, cards, or wallets after the service is completed. Cash payments are also accepted at the mechanic\'s discretion.'**
  String get faqAnswer5;

  /// No description provided for @faqQuestion6.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a request?'**
  String get faqQuestion6;

  /// No description provided for @faqAnswer6.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can cancel before the mechanic accepts it. Go to My Requests â†’ Select request â†’ Tap \'Cancel\'. Cancellation charges may apply if mechanic has already started traveling.'**
  String get faqAnswer6;

  /// No description provided for @emergencySafety.
  ///
  /// In en, this message translates to:
  /// **'Emergency & Safety'**
  String get emergencySafety;

  /// No description provided for @safetyGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Safety Guidelines'**
  String get safetyGuidelines;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'â€¢ If stranded in an unsafe location, stay inside your vehicle with doors locked\nâ€¢ Turn on hazard lights and use warning triangles if available\nâ€¢ Use the SOS Call feature for immediate emergency assistance\nâ€¢ Never share OTPs, passwords, or banking details with anyone\nâ€¢ Verify mechanic ID and rating before accepting service\nâ€¢ All payments should be done through the app only\nâ€¢ Take photos of damage before and after repair\nâ€¢ Keep emergency numbers saved in your phone'**
  String get safetyTips;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @phoneSupport.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// No description provided for @supportHours.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get supportHours;

  /// No description provided for @support24x7.
  ///
  /// In en, this message translates to:
  /// **'24/7 Emergency Support'**
  String get support24x7;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationIndia.
  ///
  /// In en, this message translates to:
  /// **'India (All Major Cities)'**
  String get locationIndia;

  /// No description provided for @submitSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit a Support Ticket'**
  String get submitSupportTicket;

  /// No description provided for @openingIssueReport.
  ///
  /// In en, this message translates to:
  /// **'Opening issue report form...'**
  String get openingIssueReport;

  /// No description provided for @openingVideoTutorials.
  ///
  /// In en, this message translates to:
  /// **'Opening video tutorials...'**
  String get openingVideoTutorials;

  /// No description provided for @openingFullFaq.
  ///
  /// In en, this message translates to:
  /// **'Opening full FAQ page...'**
  String get openingFullFaq;

  /// No description provided for @openingSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Opening support ticket form...'**
  String get openingSupportTicket;

  /// No description provided for @mechresqVersion.
  ///
  /// In en, this message translates to:
  /// **'MechResQ • Version 1.0.0'**
  String get mechresqVersion;

  /// No description provided for @copyrightMechresq.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MechResQ. All rights reserved.'**
  String get copyrightMechresq;

  /// No description provided for @reviewsRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsRatings;

  /// No description provided for @mostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get mostRecent;

  /// No description provided for @highestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get highestRated;

  /// No description provided for @lowestRated.
  ///
  /// In en, this message translates to:
  /// **'Lowest Rated'**
  String get lowestRated;

  /// No description provided for @mostHelpful.
  ///
  /// In en, this message translates to:
  /// **'Most Helpful'**
  String get mostHelpful;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In en, this message translates to:
  /// **'Not Helpful'**
  String get notHelpful;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted successfully.'**
  String get requestSubmitted;

  /// No description provided for @viewMyRequests.
  ///
  /// In en, this message translates to:
  /// **'View My Requests'**
  String get viewMyRequests;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @serviceComplete.
  ///
  /// In en, this message translates to:
  /// **'Service Complete'**
  String get serviceComplete;

  /// No description provided for @rateService.
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rateService;

  /// No description provided for @howWasService.
  ///
  /// In en, this message translates to:
  /// **'How was the service?'**
  String get howWasService;

  /// No description provided for @writeYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback...'**
  String get writeYourFeedback;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @thankYouFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a messageâ€¦'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @emergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContactsTitle;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @noContactsAdded.
  ///
  /// In en, this message translates to:
  /// **'No contacts added'**
  String get noContactsAdded;

  /// No description provided for @noEmergencyContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Emergency Contacts'**
  String get noEmergencyContactsTitle;

  /// No description provided for @addTrustedContactsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add trusted contacts who will be notified\nduring emergencies'**
  String get addTrustedContactsMessage;

  /// No description provided for @addFirstContact.
  ///
  /// In en, this message translates to:
  /// **'Add your first emergency contact'**
  String get addFirstContact;

  /// No description provided for @addFirstContactButton.
  ///
  /// In en, this message translates to:
  /// **'Add First Contact'**
  String get addFirstContactButton;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get phoneNumberRequired;

  /// No description provided for @relationshipRequired.
  ///
  /// In en, this message translates to:
  /// **'Relationship *'**
  String get relationshipRequired;

  /// No description provided for @relationshipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Father, Wife, Friend'**
  String get relationshipHint;

  /// No description provided for @setAsPrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'Set as Primary Contact'**
  String get setAsPrimaryContact;

  /// No description provided for @primaryContactCalledFirst.
  ///
  /// In en, this message translates to:
  /// **'Primary contact is called first'**
  String get primaryContactCalledFirst;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @aboutEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'About Emergency Contacts'**
  String get aboutEmergencyContacts;

  /// No description provided for @emergencyContactsInfoDetails.
  ///
  /// In en, this message translates to:
  /// **'â€¢ Add up to 5 trusted contacts\n\nâ€¢ Contacts are notified during SOS activation\n\nâ€¢ Primary contact is called first\n\nâ€¢ SMS with your location is sent automatically\n\nâ€¢ Works even without internet (via SMS)\n\nâ€¢ Keep contact details updated'**
  String get emergencyContactsInfoDetails;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @deleteContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact?'**
  String get deleteContactQuestion;

  /// No description provided for @deleteContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from emergency contacts?'**
  String deleteContactMessage(String name);

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @contactUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact updated'**
  String get contactUpdatedSuccess;

  /// No description provided for @contactAdded.
  ///
  /// In en, this message translates to:
  /// **'Contact added successfully'**
  String get contactAdded;

  /// No description provided for @contactAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact added'**
  String get contactAddedSuccess;

  /// No description provided for @contactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully'**
  String get contactUpdated;

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted successfully'**
  String get contactDeleted;

  /// No description provided for @contactDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeletedSuccess;

  /// No description provided for @failedToUpdateContact.
  ///
  /// In en, this message translates to:
  /// **'Failed to update contact'**
  String get failedToUpdateContact;

  /// No description provided for @failedToAddContactMax5.
  ///
  /// In en, this message translates to:
  /// **'Failed to add contact (max 5 allowed)'**
  String get failedToAddContactMax5;

  /// No description provided for @failedToDeleteContact.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete contact'**
  String get failedToDeleteContact;

  /// No description provided for @unableToMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to make call'**
  String get unableToMakeCall;

  /// No description provided for @deleteContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this contact?'**
  String get deleteContactConfirm;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @giveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give Feedback'**
  String get giveFeedback;

  /// No description provided for @wrongApp.
  ///
  /// In en, this message translates to:
  /// **'Wrong App'**
  String get wrongApp;

  /// No description provided for @wrongAppMessage.
  ///
  /// In en, this message translates to:
  /// **'This is the MechResQ User App. Please download the MechResQ Mechanic App to continue.'**
  String get wrongAppMessage;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Type'**
  String get selectVehicleType;

  /// No description provided for @enterVehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle make'**
  String get enterVehicleMake;

  /// No description provided for @enterVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle model'**
  String get enterVehicleModel;

  /// No description provided for @enterVehicleYear.
  ///
  /// In en, this message translates to:
  /// **'Enter year'**
  String get enterVehicleYear;

  /// No description provided for @enterVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle number'**
  String get enterVehicleNumber;

  /// No description provided for @vehicleTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type is required'**
  String get vehicleTypeRequired;

  /// No description provided for @vehicleMakeRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle make is required'**
  String get vehicleMakeRequired;

  /// No description provided for @vehicleModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle model is required'**
  String get vehicleModelRequired;

  /// No description provided for @vehicleYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Year is required'**
  String get vehicleYearRequired;

  /// No description provided for @vehicleNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get vehicleNumberRequired;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'miles'**
  String get miles;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get requestDate;

  /// No description provided for @requestTime.
  ///
  /// In en, this message translates to:
  /// **'Request Time'**
  String get requestTime;

  /// No description provided for @serviceCost.
  ///
  /// In en, this message translates to:
  /// **'Service Cost'**
  String get serviceCost;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLess;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get locationPermission;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermission;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required'**
  String get storagePermission;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkConnection;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryConnection;

  /// No description provided for @confirmServiceCharges.
  ///
  /// In en, this message translates to:
  /// **'Please confirm service charges before repair.'**
  String get confirmServiceCharges;

  /// No description provided for @paymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment options may include Cash / UPI.'**
  String get paymentOptions;

  /// No description provided for @verifyMechanicIdentity.
  ///
  /// In en, this message translates to:
  /// **'Always verify mechanic identity before proceeding.'**
  String get verifyMechanicIdentity;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get shareFeatureComingSoon;

  /// No description provided for @doYouWantToCall.
  ///
  /// In en, this message translates to:
  /// **'Do you want to call {phone}?'**
  String doYouWantToCall(String phone);

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling {phone}...'**
  String calling(String phone);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @noActiveRequests.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get noActiveRequests;

  /// No description provided for @noRequestHistory.
  ///
  /// In en, this message translates to:
  /// **'No request history'**
  String get noRequestHistory;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @createServiceRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Service Request'**
  String get createServiceRequest;

  /// No description provided for @provideDetailsQuickly.
  ///
  /// In en, this message translates to:
  /// **'Provide details so a mechanic can assist you quickly.'**
  String get provideDetailsQuickly;

  /// No description provided for @describeTheIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe the Issue'**
  String get describeTheIssue;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach Photo'**
  String get attachPhoto;

  /// No description provided for @noPhotosAttached.
  ///
  /// In en, this message translates to:
  /// **'No photos attached'**
  String get noPhotosAttached;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @detectMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect My Location'**
  String get detectMyLocation;

  /// No description provided for @detecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting...'**
  String get detecting;

  /// No description provided for @liveLocationDetected.
  ///
  /// In en, this message translates to:
  /// **'Live location detected successfully!'**
  String get liveLocationDetected;

  /// No description provided for @locationDetectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location detected successfully!'**
  String get locationDetectedSuccessfully;

  /// No description provided for @pleaseDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please detect your location first.'**
  String get pleaseDetectLocation;

  /// No description provided for @failedToSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request'**
  String get failedToSubmitRequest;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @uploadIdDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Document'**
  String get uploadIdDocument;

  /// No description provided for @choosePdfFile.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF / File'**
  String get choosePdfFile;

  /// No description provided for @cannotAttachFiles.
  ///
  /// In en, this message translates to:
  /// **'Cannot attach files.'**
  String get cannotAttachFiles;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Opening settings...'**
  String get permissionPermanentlyDenied;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermissionRequired;

  /// No description provided for @attached.
  ///
  /// In en, this message translates to:
  /// **'Attached: {name}'**
  String attached(String name);

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please turn on GPS.'**
  String get locationServicesDisabled;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get couldNotGetLocation;

  /// No description provided for @mechresqWantsAccessStorage.
  ///
  /// In en, this message translates to:
  /// **'MechResQ wants to access your storage'**
  String get mechresqWantsAccessStorage;

  /// No description provided for @neededToAttachPhotos.
  ///
  /// In en, this message translates to:
  /// **'This is needed to attach photos to your request'**
  String get neededToAttachPhotos;

  /// No description provided for @whileUsingApp.
  ///
  /// In en, this message translates to:
  /// **'While using the app'**
  String get whileUsingApp;

  /// No description provided for @onlyThisTime.
  ///
  /// In en, this message translates to:
  /// **'Only this time'**
  String get onlyThisTime;

  /// No description provided for @dontAllow.
  ///
  /// In en, this message translates to:
  /// **'Don\'t allow'**
  String get dontAllow;

  /// No description provided for @vehicleName.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicleName;

  /// No description provided for @enterVehicleName.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle name'**
  String get enterVehicleName;

  /// No description provided for @make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @yearEg2020.
  ///
  /// In en, this message translates to:
  /// **'Year (e.g., 2020)'**
  String get yearEg2020;

  /// No description provided for @licenseplate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licenseplate;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseImage;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAddress;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone'**
  String get enterPhone;

  /// No description provided for @selectLanguageKnown.
  ///
  /// In en, this message translates to:
  /// **'Select Language Known'**
  String get selectLanguageKnown;

  /// No description provided for @selectDob.
  ///
  /// In en, this message translates to:
  /// **'Select DOB'**
  String get selectDob;

  /// No description provided for @requestSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted'**
  String get requestSubmittedTitle;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @vehicleServiceRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your {vehicle} service request has been submitted successfully. A nearby mechanic will contact you shortly.'**
  String vehicleServiceRequestSubmitted(String vehicle);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @serviceCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Complete'**
  String get serviceCompleteTitle;

  /// No description provided for @serviceCompletedExclaim.
  ///
  /// In en, this message translates to:
  /// **'Service Completed!'**
  String get serviceCompletedExclaim;

  /// No description provided for @thankYouForUsingMechresq.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using MechResQ'**
  String get thankYouForUsingMechresq;

  /// No description provided for @serviceSummary.
  ///
  /// In en, this message translates to:
  /// **'Service Summary'**
  String get serviceSummary;

  /// No description provided for @mechanic.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get mechanic;

  /// No description provided for @issue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issue;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @serviceCharge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get serviceCharge;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax (5%)'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @upiCashAtSite.
  ///
  /// In en, this message translates to:
  /// **'UPI / Cash at site'**
  String get upiCashAtSite;

  /// No description provided for @rateYourMechanic.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Mechanic'**
  String get rateYourMechanic;

  /// No description provided for @writeYourFeedbackOptional.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback (optional)â€¦'**
  String get writeYourFeedbackOptional;

  /// No description provided for @submitAndClose.
  ///
  /// In en, this message translates to:
  /// **'Submit & Close'**
  String get submitAndClose;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get ratingExcellent;

  /// No description provided for @tapStarToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get tapStarToRate;

  /// No description provided for @trackRequest.
  ///
  /// In en, this message translates to:
  /// **'Track Request'**
  String get trackRequest;

  /// No description provided for @mechanicLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get mechanicLabel;

  /// No description provided for @statusTimeline.
  ///
  /// In en, this message translates to:
  /// **'Status Timeline'**
  String get statusTimeline;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted'**
  String get requestAccepted;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @errorTrackingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error tracking request: {error}'**
  String errorTrackingRequest(String error);

  /// No description provided for @checkingMechanicLocation.
  ///
  /// In en, this message translates to:
  /// **'Checking for mechanic location updates...'**
  String get checkingMechanicLocation;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minAgo(int minutes);

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour ago'**
  String hourAgo(int hours);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @reviewsRatingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsRatingsTitle;

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews'**
  String get errorLoadingReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review!'**
  String get beFirstToReview;

  /// No description provided for @ratingDistribution.
  ///
  /// In en, this message translates to:
  /// **'Rating Distribution'**
  String get ratingDistribution;

  /// No description provided for @wasThisHelpful.
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get wasThisHelpful;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @failedToRecordVote.
  ///
  /// In en, this message translates to:
  /// **'Failed to record vote'**
  String get failedToRecordVote;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @rateYourExperienceWith.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with'**
  String get rateYourExperienceWith;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this mechanic...\n\nWas the service timely?\nHow was the quality of work?\nWould you recommend them?'**
  String get shareYourExperience;

  /// No description provided for @pleaseWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Please write a review'**
  String get pleaseWriteReview;

  /// No description provided for @reviewMustBe10Chars.
  ///
  /// In en, this message translates to:
  /// **'Review must be at least 10 characters'**
  String get reviewMustBe10Chars;

  /// No description provided for @reviewUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review updated successfully'**
  String get reviewUpdatedSuccessfully;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review: {error}'**
  String failedToSubmitReview(String error);

  /// No description provided for @updateReview.
  ///
  /// In en, this message translates to:
  /// **'Update Review'**
  String get updateReview;

  /// No description provided for @tipsForHelpfulReview.
  ///
  /// In en, this message translates to:
  /// **'Tips for a helpful review'**
  String get tipsForHelpfulReview;

  /// No description provided for @reviewTips.
  ///
  /// In en, this message translates to:
  /// **'â€¢ Be specific about the service provided\nâ€¢ Mention timeliness and professionalism\nâ€¢ Share what you liked or didn\'t like\nâ€¢ Keep it honest and constructive'**
  String get reviewTips;

  /// No description provided for @whereAreYou.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get whereAreYou;

  /// No description provided for @imAtTheGate.
  ///
  /// In en, this message translates to:
  /// **'I\'m at the gate'**
  String get imAtTheGate;

  /// No description provided for @pleaseHurry.
  ///
  /// In en, this message translates to:
  /// **'Please hurry'**
  String get pleaseHurry;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get thankYou;

  /// No description provided for @canYouCallMe.
  ///
  /// In en, this message translates to:
  /// **'Can you call me?'**
  String get canYouCallMe;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @noAttachmentsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No attachments uploaded'**
  String get noAttachmentsUploaded;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @attachmentApproved.
  ///
  /// In en, this message translates to:
  /// **'Attachment approved ✓'**
  String get attachmentApproved;

  /// No description provided for @attachmentRejected.
  ///
  /// In en, this message translates to:
  /// **'Attachment rejected'**
  String get attachmentRejected;

  /// No description provided for @failedToUpdateAttachment.
  ///
  /// In en, this message translates to:
  /// **'Failed to update attachment: {error}'**
  String failedToUpdateAttachment(String error);

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @cannotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this file'**
  String get cannotOpenFile;

  /// No description provided for @failedToDownload.
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String failedToDownload(String error);

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get expired;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get statusRejected;

  /// No description provided for @requestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found'**
  String get requestNotFound;

  /// No description provided for @waitingForMechanicAssignment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for mechanic assignmentâ€¦'**
  String get waitingForMechanicAssignment;

  /// No description provided for @userLocationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User location not available'**
  String get userLocationNotAvailable;

  /// No description provided for @mechanicDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mechanic data not found'**
  String get mechanicDataNotFound;

  /// No description provided for @mechanicLocationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mechanic location not available'**
  String get mechanicLocationNotAvailable;

  /// No description provided for @mechanicOffline.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Offline'**
  String get mechanicOffline;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @fullMap.
  ///
  /// In en, this message translates to:
  /// **'Full Map'**
  String get fullMap;

  /// No description provided for @cannotLaunchPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Cannot launch phone dialer'**
  String get cannotLaunchPhoneDialer;

  /// No description provided for @areYouSureCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? You can only cancel before the mechanic starts travelling.'**
  String get areYouSureCancelRequest;

  /// No description provided for @failedToCancel.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel: {error}'**
  String failedToCancel(String error);

  /// No description provided for @sosCallInitiated.
  ///
  /// In en, this message translates to:
  /// **'🚨 SOS call initiated!'**
  String get sosCallInitiated;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @languageKnown.
  ///
  /// In en, this message translates to:
  /// **'Language Known'**
  String get languageKnown;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @remindUpcomingServiceDates.
  ///
  /// In en, this message translates to:
  /// **'Remind me for upcoming service dates'**
  String get remindUpcomingServiceDates;

  /// No description provided for @useFingerprintFaceid.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID to sign in'**
  String get useFingerprintFaceid;

  /// No description provided for @permanentlyRemoveAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account'**
  String get permanentlyRemoveAccount;

  /// No description provided for @primaryContactNotified.
  ///
  /// In en, this message translates to:
  /// **'Primary contact is notified first in emergencies'**
  String get primaryContactNotified;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'Experience (years)'**
  String get experienceYears;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @maxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max distance (km)'**
  String get maxDistance;

  /// No description provided for @minimumRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get minimumRating;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get resetAll;

  /// No description provided for @thankYouNote.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We\'ll alert nearby mechanics & phone you shortly.'**
  String get thankYouNote;

  /// No description provided for @cancelLowercase.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLowercase;

  /// No description provided for @emergencyDescription.
  ///
  /// In en, this message translates to:
  /// **'In case of emergency, press the button below to alert nearby mechanics and your emergency contacts.'**
  String get emergencyDescription;

  /// No description provided for @activateSos.
  ///
  /// In en, this message translates to:
  /// **'Activate SOS'**
  String get activateSos;

  /// No description provided for @yourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Current Location'**
  String get yourCurrentLocation;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not detected'**
  String get notDetected;

  /// No description provided for @detectLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect Location'**
  String get detectLocation;

  /// No description provided for @sosActivated.
  ///
  /// In en, this message translates to:
  /// **'SOS Activated'**
  String get sosActivated;

  /// No description provided for @sosActivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Emergency alert sent to nearby mechanics and your emergency contacts.'**
  String get sosActivatedMessage;

  /// No description provided for @deactivateSos.
  ///
  /// In en, this message translates to:
  /// **'Deactivate SOS'**
  String get deactivateSos;

  /// No description provided for @viewSosHistory.
  ///
  /// In en, this message translates to:
  /// **'View SOS History'**
  String get viewSosHistory;

  /// No description provided for @addFirstVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to get started'**
  String get addFirstVehicle;

  /// No description provided for @trackingRequest.
  ///
  /// In en, this message translates to:
  /// **'Tracking Request'**
  String get trackingRequest;

  /// No description provided for @mechanicOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Mechanic is on the way'**
  String get mechanicOnTheWay;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @mechanicInfo.
  ///
  /// In en, this message translates to:
  /// **'Mechanic Info'**
  String get mechanicInfo;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @requestInfo.
  ///
  /// In en, this message translates to:
  /// **'Request Info'**
  String get requestInfo;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Issue Description'**
  String get issueDescription;

  /// No description provided for @requestLocation.
  ///
  /// In en, this message translates to:
  /// **'Request Location'**
  String get requestLocation;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// No description provided for @requestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested on'**
  String get requestedOn;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with'**
  String get rateYourExperience;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblem;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @allReviews.
  ///
  /// In en, this message translates to:
  /// **'All Reviews'**
  String get allReviews;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// No description provided for @writeAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeAReview;

  /// No description provided for @tellUsMore.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about your experience...'**
  String get tellUsMore;

  /// No description provided for @postReview.
  ///
  /// In en, this message translates to:
  /// **'Post Review'**
  String get postReview;

  /// No description provided for @requestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Successful!'**
  String get requestSuccess;

  /// No description provided for @mechanicsNotified.
  ///
  /// In en, this message translates to:
  /// **'Nearby mechanics have been notified.'**
  String get mechanicsNotified;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @vehicleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Breakdown'**
  String get vehicleBreakdown;

  /// No description provided for @medicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get medicalEmergency;

  /// No description provided for @accident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// No description provided for @personalSafety.
  ///
  /// In en, this message translates to:
  /// **'Personal Safety'**
  String get personalSafety;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @tapToActivateEmergency.
  ///
  /// In en, this message translates to:
  /// **'Tap to activate emergency alert'**
  String get tapToActivateEmergency;

  /// No description provided for @whatHappensWhenActivate.
  ///
  /// In en, this message translates to:
  /// **'What happens when you activate SOS?'**
  String get whatHappensWhenActivate;

  /// No description provided for @smsContactsSent.
  ///
  /// In en, this message translates to:
  /// **'SMS sent to {count} emergency contacts'**
  String smsContactsSent(int count);

  /// No description provided for @nearbyMechanicsAlerted.
  ///
  /// In en, this message translates to:
  /// **'Nearby mechanics alerted (up to 5)'**
  String get nearbyMechanicsAlerted;

  /// No description provided for @liveLocationShared.
  ///
  /// In en, this message translates to:
  /// **'Live location shared automatically'**
  String get liveLocationShared;

  /// No description provided for @eventLoggedHistory.
  ///
  /// In en, this message translates to:
  /// **'Event logged in your SOS history'**
  String get eventLoggedHistory;

  /// No description provided for @noEmergencyContactsWarning.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts added. Tap to add.'**
  String get noEmergencyContactsWarning;

  /// No description provided for @quickEmergencyActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Emergency Actions'**
  String get quickEmergencyActions;

  /// No description provided for @callPrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'Call Primary Contact'**
  String get callPrimaryContact;

  /// No description provided for @call112Emergency.
  ///
  /// In en, this message translates to:
  /// **'Call 112 (Emergency Services)'**
  String get call112Emergency;

  /// No description provided for @manageEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Manage Emergency Contacts'**
  String get manageEmergencyContacts;

  /// No description provided for @helpIsOneKnownAway.
  ///
  /// In en, this message translates to:
  /// **'Help is one tap away'**
  String get helpIsOneKnownAway;

  /// No description provided for @unableToDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to detect location. Please enable GPS and refresh.'**
  String get unableToDetectLocation;

  /// No description provided for @sosFailed.
  ///
  /// In en, this message translates to:
  /// **'SOS Failed'**
  String get sosFailed;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting location...'**
  String get detectingLocation;

  /// No description provided for @savingEvent.
  ///
  /// In en, this message translates to:
  /// **'Saving event...'**
  String get savingEvent;

  /// No description provided for @sendingSms.
  ///
  /// In en, this message translates to:
  /// **'Sending SMS...'**
  String get sendingSms;

  /// No description provided for @notifyingMechanics.
  ///
  /// In en, this message translates to:
  /// **'Notifying mechanics...'**
  String get notifyingMechanics;

  /// No description provided for @contactsNotified.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts notified'**
  String contactsNotified(int count);

  /// No description provided for @mechanicsAlerted.
  ///
  /// In en, this message translates to:
  /// **'{count} mechanics alerted'**
  String mechanicsAlerted(int count);

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String locationLabel(String location);

  /// No description provided for @staySafeHelpOnWay.
  ///
  /// In en, this message translates to:
  /// **'Stay safe. Help is on the way.'**
  String get staySafeHelpOnWay;

  /// No description provided for @noEmergencyContactsAdded.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts added'**
  String get noEmergencyContactsAdded;

  /// No description provided for @unableToDial112.
  ///
  /// In en, this message translates to:
  /// **'Unable to dial 112'**
  String get unableToDial112;

  /// No description provided for @hideArchived.
  ///
  /// In en, this message translates to:
  /// **'Hide Archived'**
  String get hideArchived;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get showArchived;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get errorLoadingHistory;

  /// No description provided for @noArchivedEvents.
  ///
  /// In en, this message translates to:
  /// **'No Archived Events'**
  String get noArchivedEvents;

  /// No description provided for @noSosHistory.
  ///
  /// In en, this message translates to:
  /// **'No SOS History'**
  String get noSosHistory;

  /// No description provided for @archivedEventsMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t archived any SOS events'**
  String get archivedEventsMessage;

  /// No description provided for @sosHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your emergency SOS activations\nwill appear here'**
  String get sosHistoryMessage;

  /// No description provided for @contacted.
  ///
  /// In en, this message translates to:
  /// **'contacted'**
  String get contacted;

  /// No description provided for @alerted.
  ///
  /// In en, this message translates to:
  /// **'alerted'**
  String get alerted;

  /// No description provided for @sosEventDetails.
  ///
  /// In en, this message translates to:
  /// **'SOS Event Details'**
  String get sosEventDetails;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @contactsNotifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Contacts Notified'**
  String get contactsNotifiedLabel;

  /// No description provided for @mechanicsAlertedLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanics Alerted'**
  String get mechanicsAlertedLabel;

  /// No description provided for @respondedBy.
  ///
  /// In en, this message translates to:
  /// **'Responded By'**
  String get respondedBy;

  /// No description provided for @archiveEvent.
  ///
  /// In en, this message translates to:
  /// **'Archive Event'**
  String get archiveEvent;

  /// No description provided for @unarchiveEvent.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Event'**
  String get unarchiveEvent;

  /// No description provided for @archiveEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will hide the event from your main view. You can view archived events by tapping the archive icon.'**
  String get archiveEventConfirm;

  /// No description provided for @unarchiveEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will restore the event to your main SOS history.'**
  String get unarchiveEventConfirm;

  /// No description provided for @eventArchived.
  ///
  /// In en, this message translates to:
  /// **'Event archived'**
  String get eventArchived;

  /// No description provided for @eventUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Event unarchived'**
  String get eventUnarchived;

  /// No description provided for @failedToArchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive'**
  String get failedToArchive;

  /// No description provided for @failedToUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to unarchive'**
  String get failedToUnarchive;

  /// No description provided for @tapPlusToAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first vehicle'**
  String get tapPlusToAddVehicle;

  /// No description provided for @failedToDeleteVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete vehicle'**
  String get failedToDeleteVehicle;

  /// No description provided for @deleteVehicleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle?'**
  String get deleteVehicleQuestion;

  /// No description provided for @deleteVehiclePermanently.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this vehicle from your account.'**
  String get deleteVehiclePermanently;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @storageAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'Storage Access Needed'**
  String get storageAccessNeeded;

  /// No description provided for @needAccessPhotosUpload.
  ///
  /// In en, this message translates to:
  /// **'We need access to your photos to upload vehicle images.'**
  String get needAccessPhotosUpload;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @uploadVehicleImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Vehicle Image'**
  String get uploadVehicleImage;

  /// No description provided for @permissionNeededUpload.
  ///
  /// In en, this message translates to:
  /// **'Permission needed to upload images.'**
  String get permissionNeededUpload;

  /// No description provided for @permissionDeniedCannotUpload.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Cannot upload images.'**
  String get permissionDeniedCannotUpload;

  /// No description provided for @permissionPermanentlyDeniedOpening.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Opening settings...'**
  String get permissionPermanentlyDeniedOpening;

  /// No description provided for @imageSelected.
  ///
  /// In en, this message translates to:
  /// **'Image selected: {name}'**
  String imageSelected(String name);

  /// No description provided for @vehicleAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added successfully âœ…'**
  String get vehicleAddedSuccessfully;

  /// No description provided for @failedToAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'Failed to add vehicle'**
  String get failedToAddVehicle;

  /// No description provided for @otherVehicle.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherVehicle;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHindi;

  /// No description provided for @langKannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get langKannada;

  /// No description provided for @langTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get langTamil;

  /// No description provided for @langTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get langTelugu;

  /// No description provided for @langMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get langMalayalam;

  /// No description provided for @langBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get langBengali;

  /// No description provided for @langMarathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get langMarathi;

  /// No description provided for @langGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get langGujarati;

  /// No description provided for @langPunjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get langPunjabi;

  /// No description provided for @langOdia.
  ///
  /// In en, this message translates to:
  /// **'Odia'**
  String get langOdia;

  /// No description provided for @langUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get langUrdu;

  /// No description provided for @stateAndaman.
  ///
  /// In en, this message translates to:
  /// **'Andaman & Nicobar Islands'**
  String get stateAndaman;

  /// No description provided for @stateAndhra.
  ///
  /// In en, this message translates to:
  /// **'Andhra Pradesh'**
  String get stateAndhra;

  /// No description provided for @stateArunachal.
  ///
  /// In en, this message translates to:
  /// **'Arunachal Pradesh'**
  String get stateArunachal;

  /// No description provided for @stateAssam.
  ///
  /// In en, this message translates to:
  /// **'Assam'**
  String get stateAssam;

  /// No description provided for @stateBihar.
  ///
  /// In en, this message translates to:
  /// **'Bihar'**
  String get stateBihar;

  /// No description provided for @stateChandigarh.
  ///
  /// In en, this message translates to:
  /// **'Chandigarh'**
  String get stateChandigarh;

  /// No description provided for @stateChhattisgarh.
  ///
  /// In en, this message translates to:
  /// **'Chhattisgarh'**
  String get stateChhattisgarh;

  /// No description provided for @stateDelhi.
  ///
  /// In en, this message translates to:
  /// **'Delhi'**
  String get stateDelhi;

  /// No description provided for @stateGoa.
  ///
  /// In en, this message translates to:
  /// **'Goa'**
  String get stateGoa;

  /// No description provided for @stateGujarat.
  ///
  /// In en, this message translates to:
  /// **'Gujarat'**
  String get stateGujarat;

  /// No description provided for @stateHaryana.
  ///
  /// In en, this message translates to:
  /// **'Haryana'**
  String get stateHaryana;

  /// No description provided for @stateHimachal.
  ///
  /// In en, this message translates to:
  /// **'Himachal Pradesh'**
  String get stateHimachal;

  /// No description provided for @stateJharkhand.
  ///
  /// In en, this message translates to:
  /// **'Jharkhand'**
  String get stateJharkhand;

  /// No description provided for @stateKarnataka.
  ///
  /// In en, this message translates to:
  /// **'Karnataka'**
  String get stateKarnataka;

  /// No description provided for @stateKerala.
  ///
  /// In en, this message translates to:
  /// **'Kerala'**
  String get stateKerala;

  /// No description provided for @stateMadhya.
  ///
  /// In en, this message translates to:
  /// **'Madhya Pradesh'**
  String get stateMadhya;

  /// No description provided for @stateMaharashtra.
  ///
  /// In en, this message translates to:
  /// **'Maharashtra'**
  String get stateMaharashtra;

  /// No description provided for @statePunjab.
  ///
  /// In en, this message translates to:
  /// **'Punjab'**
  String get statePunjab;

  /// No description provided for @stateRajasthan.
  ///
  /// In en, this message translates to:
  /// **'Rajasthan'**
  String get stateRajasthan;

  /// No description provided for @stateTamilNadu.
  ///
  /// In en, this message translates to:
  /// **'Tamil Nadu'**
  String get stateTamilNadu;

  /// No description provided for @stateTelangana.
  ///
  /// In en, this message translates to:
  /// **'Telangana'**
  String get stateTelangana;

  /// No description provided for @stateUttar.
  ///
  /// In en, this message translates to:
  /// **'Uttar Pradesh'**
  String get stateUttar;

  /// No description provided for @stateWestBengal.
  ///
  /// In en, this message translates to:
  /// **'West Bengal'**
  String get stateWestBengal;

  /// No description provided for @locationNotDetectedTap.
  ///
  /// In en, this message translates to:
  /// **'Location not detected. Tap \"Detect My Location\" to set your location on the map.'**
  String get locationNotDetectedTap;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @tipProvideDescription.
  ///
  /// In en, this message translates to:
  /// **'Tip: Provide clear description and photos for faster help.'**
  String get tipProvideDescription;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsAndRatings;

  /// No description provided for @sortMostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get sortMostRecent;

  /// No description provided for @sortHighestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get sortHighestRated;

  /// No description provided for @sortLowestRated.
  ///
  /// In en, this message translates to:
  /// **'Lowest Rated'**
  String get sortLowestRated;

  /// No description provided for @sortMostHelpful.
  ///
  /// In en, this message translates to:
  /// **'Most Helpful'**
  String get sortMostHelpful;

  /// No description provided for @beTheFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review!'**
  String get beTheFirstToReview;

  /// No description provided for @pleaseWriteAReview.
  ///
  /// In en, this message translates to:
  /// **'Please write a review'**
  String get pleaseWriteAReview;

  /// No description provided for @reviewMinLength.
  ///
  /// In en, this message translates to:
  /// **'Review must be at least 10 characters'**
  String get reviewMinLength;

  /// No description provided for @reviewUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated successfully'**
  String get reviewUpdated;

  /// No description provided for @tipsForReview.
  ///
  /// In en, this message translates to:
  /// **'Tips for a helpful review'**
  String get tipsForReview;

  /// No description provided for @reviewTip1.
  ///
  /// In en, this message translates to:
  /// **'• Be specific about the service provided'**
  String get reviewTip1;

  /// No description provided for @reviewTip2.
  ///
  /// In en, this message translates to:
  /// **'• Mention timeliness and professionalism'**
  String get reviewTip2;

  /// No description provided for @reviewTip3.
  ///
  /// In en, this message translates to:
  /// **'• Share what you liked or didn\'t like'**
  String get reviewTip3;

  /// No description provided for @reviewTip4.
  ///
  /// In en, this message translates to:
  /// **'• Keep it honest and constructive'**
  String get reviewTip4;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessage;

  /// No description provided for @quickReplyWhereAreYou.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get quickReplyWhereAreYou;

  /// No description provided for @quickReplyAtGate.
  ///
  /// In en, this message translates to:
  /// **'I\'m at the gate'**
  String get quickReplyAtGate;

  /// No description provided for @quickReplyHurry.
  ///
  /// In en, this message translates to:
  /// **'Please hurry'**
  String get quickReplyHurry;

  /// No description provided for @quickReplyThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get quickReplyThankYou;

  /// No description provided for @quickReplyCallMe.
  ///
  /// In en, this message translates to:
  /// **'Can you call me?'**
  String get quickReplyCallMe;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments uploaded'**
  String get noAttachments;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get statusExpired;

  /// No description provided for @waitingForMechanic.
  ///
  /// In en, this message translates to:
  /// **'Waiting for mechanic assignment…'**
  String get waitingForMechanic;

  /// No description provided for @timelineAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get timelineAccepted;

  /// No description provided for @timelineOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get timelineOnTheWay;

  /// No description provided for @timelineCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get timelineCompleted;

  /// No description provided for @cannotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Cannot launch phone dialer'**
  String get cannotLaunchDialer;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @mechresqTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'MechResQ Terms & Conditions'**
  String get mechresqTermsConditions;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @termsAgreementFooter.
  ///
  /// In en, this message translates to:
  /// **'By using MechResQ, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.'**
  String get termsAgreementFooter;

  /// No description provided for @mechresqPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'MechResQ Privacy Policy'**
  String get mechresqPrivacyPolicy;

  /// No description provided for @yourDataRights.
  ///
  /// In en, this message translates to:
  /// **'Your Data Rights'**
  String get yourDataRights;

  /// No description provided for @dataRightsDescription.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, delete, or restrict the processing of your personal data. Contact us anytime to exercise these rights.'**
  String get dataRightsDescription;

  /// No description provided for @loginHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get loginHelp;

  /// No description provided for @needHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re here 24/7 to assist you during vehicle breakdowns'**
  String get needHelpDescription;

  /// No description provided for @faqUnableToLogin.
  ///
  /// In en, this message translates to:
  /// **'I\'m unable to login to the app'**
  String get faqUnableToLogin;

  /// No description provided for @faqUnableToLoginAnswer.
  ///
  /// In en, this message translates to:
  /// **'Login issues generally arise due to poor network connectivity. Please check your internet connectivity and the signal strength of your network provider. You could also try reinstalling the app from Play Store.\n\nIf you don\'t receive the SMS with your OTP details, please check that the mobile number entered is valid.\n\nIf the mobile number entered is correct and you haven\'t received the SMS with OTP details, we request you to wait for a few minutes as there could be a delay in receiving SMS due to network issues.\n\nHowever, if you are still facing any issue, please contact our support team.'**
  String get faqUnableToLoginAnswer;

  /// No description provided for @faqNotReceivingOtp.
  ///
  /// In en, this message translates to:
  /// **'Not receiving OTP'**
  String get faqNotReceivingOtp;

  /// No description provided for @faqNotReceivingOtpAnswer.
  ///
  /// In en, this message translates to:
  /// **'• Check your mobile network signal strength\n• Verify the mobile number entered is correct\n• OTP messages can take up to 2-3 minutes to arrive\n• Check if SMS storage is full on your device\n• Try restarting your phone and request OTP again\n• Make sure you haven\'t blocked SMS from unknown numbers\n\nIf issue persists after 5 minutes, tap \"Resend OTP\" or contact support.'**
  String get faqNotReceivingOtpAnswer;

  /// No description provided for @faqInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP error'**
  String get faqInvalidOtp;

  /// No description provided for @faqInvalidOtpAnswer.
  ///
  /// In en, this message translates to:
  /// **'This error occurs when:\n\n• You entered the wrong OTP code\n• The OTP has expired (valid for 10 minutes only)\n• Network delay caused verification timeout\n\nSolutions:\n1. Double-check the 6-digit code from SMS\n2. Request a new OTP if more than 10 minutes have passed\n3. Ensure stable internet connection during verification\n4. Try copying and pasting the OTP instead of typing'**
  String get faqInvalidOtpAnswer;

  /// No description provided for @faqAppCrashes.
  ///
  /// In en, this message translates to:
  /// **'App crashes during login'**
  String get faqAppCrashes;

  /// No description provided for @faqAppCrashesAnswer.
  ///
  /// In en, this message translates to:
  /// **'If the app crashes or freezes during login:\n\n1. Force close the app completely\n2. Clear app cache: Settings → Apps → MechResQ → Clear Cache\n3. Check for app updates in Play Store\n4. Ensure you have stable internet (WiFi recommended)\n5. Free up phone storage (at least 100MB free space)\n6. Restart your device\n\nIf problem continues, uninstall and reinstall the app. Your data is safe and will be restored after logging in.'**
  String get faqAppCrashesAnswer;

  /// No description provided for @faqChangedPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Changed my phone number'**
  String get faqChangedPhoneNumber;

  /// No description provided for @faqChangedPhoneNumberAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you\'ve changed your mobile number:\n\n1. Login with your NEW phone number\n2. Complete the OTP verification\n3. Your account will be created with the new number\n4. You can then set up your profile again\n\nNote: Previous service history cannot be transferred to the new number. Contact support if you need to link your old account data.'**
  String get faqChangedPhoneNumberAnswer;

  /// No description provided for @wasThisArticleHelpful.
  ///
  /// In en, this message translates to:
  /// **'Was this article helpful?'**
  String get wasThisArticleHelpful;

  /// No description provided for @feedbackYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get feedbackYes;

  /// No description provided for @feedbackNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get feedbackNo;

  /// No description provided for @sorryContactSupport.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry. Please contact support for more help.'**
  String get sorryContactSupport;

  /// No description provided for @unableToOpenPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Unable to open phone dialer. Please call +91 98765 00000 manually.'**
  String get unableToOpenPhoneDialer;

  /// No description provided for @phoneDialerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone dialer not available. Call +91 98765 00000 manually.'**
  String get phoneDialerNotAvailable;

  /// No description provided for @unableToOpenEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email app. Please email support@mechresq.com manually.'**
  String get unableToOpenEmailApp;

  /// No description provided for @emailAppNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Email app not available. Email support@mechresq.com manually.'**
  String get emailAppNotAvailable;

  /// No description provided for @mechanicNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mechanic not found'**
  String get mechanicNotFound;

  /// No description provided for @noRatings.
  ///
  /// In en, this message translates to:
  /// **'No ratings'**
  String get noRatings;

  /// No description provided for @vehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Types'**
  String get vehicleTypes;

  /// No description provided for @lastSeenMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Last seen {minutes} min ago'**
  String lastSeenMinutesAgo(int minutes);

  /// No description provided for @currentlyOffline.
  ///
  /// In en, this message translates to:
  /// **'Currently Offline'**
  String get currentlyOffline;

  /// No description provided for @supportedVehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Supported Vehicle Types'**
  String get supportedVehicleTypes;

  /// No description provided for @ratingOverview.
  ///
  /// In en, this message translates to:
  /// **'Rating Overview'**
  String get ratingOverview;

  /// No description provided for @basedOnReviews.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} reviews'**
  String basedOnReviews(int count);

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @fullScreenLiveMap.
  ///
  /// In en, this message translates to:
  /// **'Full-Screen Live Map'**
  String get fullScreenLiveMap;

  /// No description provided for @mechanicHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Mechanic has arrived!'**
  String get mechanicHasArrived;

  /// No description provided for @atYourLocation.
  ///
  /// In en, this message translates to:
  /// **'At your location'**
  String get atYourLocation;

  /// No description provided for @onTheWayToYou.
  ///
  /// In en, this message translates to:
  /// **'On the way to you'**
  String get onTheWayToYou;

  /// No description provided for @generalVehicleRepairServices.
  ///
  /// In en, this message translates to:
  /// **'General vehicle repair services.'**
  String get generalVehicleRepairServices;

  /// No description provided for @billServiceEstimate.
  ///
  /// In en, this message translates to:
  /// **'Service Estimate'**
  String get billServiceEstimate;

  /// No description provided for @billServiceBillPayment.
  ///
  /// In en, this message translates to:
  /// **'Service Bill & Payment'**
  String get billServiceBillPayment;

  /// No description provided for @billEstimateLabel.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATE'**
  String get billEstimateLabel;

  /// No description provided for @billBillLabel.
  ///
  /// In en, this message translates to:
  /// **'BILL'**
  String get billBillLabel;

  /// No description provided for @billRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get billRequestDetails;

  /// No description provided for @billVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get billVehicle;

  /// No description provided for @billIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get billIssue;

  /// No description provided for @billLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get billLocation;

  /// No description provided for @billDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get billDistance;

  /// No description provided for @billComplexityPrefix.
  ///
  /// In en, this message translates to:
  /// **'Complexity: '**
  String get billComplexityPrefix;

  /// No description provided for @billDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected: '**
  String get billDetected;

  /// No description provided for @billPriceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get billPriceBreakdown;

  /// No description provided for @billBaseServiceCharge.
  ///
  /// In en, this message translates to:
  /// **'Base Service Charge'**
  String get billBaseServiceCharge;

  /// No description provided for @billLabourCharges.
  ///
  /// In en, this message translates to:
  /// **'Labour Charges'**
  String get billLabourCharges;

  /// No description provided for @billCallOutFee.
  ///
  /// In en, this message translates to:
  /// **'Call-Out / Travel Fee'**
  String get billCallOutFee;

  /// No description provided for @billSpareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts (Estimate)'**
  String get billSpareParts;

  /// No description provided for @billSparePartsNote.
  ///
  /// In en, this message translates to:
  /// **'Actual cost adjusted after service'**
  String get billSparePartsNote;

  /// No description provided for @billPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get billPlatformFee;

  /// No description provided for @billPlatformFeeNote.
  ///
  /// In en, this message translates to:
  /// **'MechResQ service fee'**
  String get billPlatformFeeNote;

  /// No description provided for @billSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub-Total'**
  String get billSubTotal;

  /// No description provided for @billGst.
  ///
  /// In en, this message translates to:
  /// **'GST (18%)'**
  String get billGst;

  /// No description provided for @billGstNote.
  ///
  /// In en, this message translates to:
  /// **'Goods and Services Tax'**
  String get billGstNote;

  /// No description provided for @billTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get billTotalAmount;

  /// No description provided for @billEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'This is an estimate. Final amount may vary based on actual spare parts used. GST @ 18% included.'**
  String get billEstimateNote;

  /// No description provided for @billEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get billEstimatedTotal;

  /// No description provided for @billEstimateInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'This is an estimated cost'**
  String get billEstimateInfoTitle;

  /// No description provided for @billEstimateInfoBody.
  ///
  /// In en, this message translates to:
  /// **'The final amount will be confirmed by the mechanic after service. You will pay only after the service is completed.'**
  String get billEstimateInfoBody;

  /// No description provided for @billTrackingInfo.
  ///
  /// In en, this message translates to:
  /// **'Once a mechanic accepts, you can track them from My Requests → Active.'**
  String get billTrackingInfo;

  /// No description provided for @billPaymentAfterService.
  ///
  /// In en, this message translates to:
  /// **'Payment happens only after service is completed'**
  String get billPaymentAfterService;

  /// No description provided for @billCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get billCancelRequest;

  /// No description provided for @billKeepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep Request'**
  String get billKeepRequest;

  /// No description provided for @billYesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get billYesCancel;

  /// No description provided for @billCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get billCancelConfirmTitle;

  /// No description provided for @billCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?\n\nThe mechanic will be notified and no charges will apply.'**
  String get billCancelConfirmBody;

  /// No description provided for @billRequestCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled successfully.'**
  String get billRequestCancelledSuccess;

  /// No description provided for @billCouldNotCancel.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel request. Try again.'**
  String get billCouldNotCancel;

  /// No description provided for @billPayByCash.
  ///
  /// In en, this message translates to:
  /// **'Pay by Cash'**
  String get billPayByCash;

  /// No description provided for @billPayDigitally.
  ///
  /// In en, this message translates to:
  /// **'Pay Digitally'**
  String get billPayDigitally;

  /// No description provided for @billProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get billProcessing;

  /// No description provided for @billSecuredByRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Secured by Razorpay'**
  String get billSecuredByRazorpay;

  /// No description provided for @billTestModeNote.
  ///
  /// In en, this message translates to:
  /// **'🧪 Test mode — no real charges'**
  String get billTestModeNote;

  /// No description provided for @billCouldNotSavePayment.
  ///
  /// In en, this message translates to:
  /// **'Could not save your payment preference. Please try again.'**
  String get billCouldNotSavePayment;

  /// No description provided for @billPaymentInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment initiation failed. Try again.'**
  String get billPaymentInitFailed;

  /// No description provided for @billCashPaymentSelected.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment Selected'**
  String get billCashPaymentSelected;

  /// No description provided for @billCashAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due: '**
  String get billCashAmountDue;

  /// No description provided for @billCashInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please pay the mechanic in cash when the service is complete.\n\nYour receipt will be generated once the mechanic confirms payment.'**
  String get billCashInstruction;

  /// No description provided for @billGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get billGotIt;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptServiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get receiptServiceDetails;

  /// No description provided for @receiptItemisedCharges.
  ///
  /// In en, this message translates to:
  /// **'Itemised Charges'**
  String get receiptItemisedCharges;

  /// No description provided for @receiptPaymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get receiptPaymentInformation;

  /// No description provided for @receiptPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get receiptPaymentMethod;

  /// No description provided for @receiptPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get receiptPaymentStatus;

  /// No description provided for @receiptTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get receiptTransactionId;

  /// No description provided for @receiptReceiptId.
  ///
  /// In en, this message translates to:
  /// **'Receipt ID'**
  String get receiptReceiptId;

  /// No description provided for @receiptPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid On'**
  String get receiptPaidOn;

  /// No description provided for @receiptIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get receiptIssue;

  /// No description provided for @receiptVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get receiptVehicle;

  /// No description provided for @receiptLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get receiptLocation;

  /// No description provided for @receiptMechanic.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get receiptMechanic;

  /// No description provided for @receiptComplexity.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get receiptComplexity;

  /// No description provided for @receiptCustomerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get receiptCustomerId;

  /// No description provided for @receiptSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub-Total'**
  String get receiptSubTotal;

  /// No description provided for @receiptGst.
  ///
  /// In en, this message translates to:
  /// **'GST (18%)'**
  String get receiptGst;

  /// No description provided for @receiptTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get receiptTotalAmount;

  /// No description provided for @receiptBaseCharge.
  ///
  /// In en, this message translates to:
  /// **'Base Service Charge'**
  String get receiptBaseCharge;

  /// No description provided for @receiptLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get receiptLabour;

  /// No description provided for @receiptCallOut.
  ///
  /// In en, this message translates to:
  /// **'Call-Out / Travel Fee'**
  String get receiptCallOut;

  /// No description provided for @receiptSpareParts.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts'**
  String get receiptSpareParts;

  /// No description provided for @receiptPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get receiptPlatformFee;

  /// No description provided for @receiptPaid.
  ///
  /// In en, this message translates to:
  /// **'✓  PAID'**
  String get receiptPaid;

  /// No description provided for @receiptPending.
  ///
  /// In en, this message translates to:
  /// **'⏳  PAYMENT PENDING'**
  String get receiptPending;

  /// No description provided for @receiptGstNote.
  ///
  /// In en, this message translates to:
  /// **'This receipt is an estimate. Final charges may vary based on actual spare parts used. GST @ 18% is included in the total amount. For disputes contact support@mechresq.com'**
  String get receiptGstNote;

  /// No description provided for @receiptThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for choosing MechResQ!'**
  String get receiptThankYou;

  /// No description provided for @receiptTagline.
  ///
  /// In en, this message translates to:
  /// **'Drive safe. We\'re always here when you need us.'**
  String get receiptTagline;

  /// No description provided for @receiptDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get receiptDownloadPdf;

  /// No description provided for @receiptGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get receiptGenerating;

  /// No description provided for @receiptPrintPreview.
  ///
  /// In en, this message translates to:
  /// **'Print / Preview'**
  String get receiptPrintPreview;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found.'**
  String get receiptNotFound;

  /// No description provided for @receiptLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load receipt. Please try again.'**
  String get receiptLoadFailed;

  /// No description provided for @receiptPdfError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF. Please try again.'**
  String get receiptPdfError;

  /// No description provided for @receiptViewDownload.
  ///
  /// In en, this message translates to:
  /// **'View & Download Receipt'**
  String get receiptViewDownload;

  /// No description provided for @receiptViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get receiptViewReceipt;

  /// No description provided for @receiptDigitalMethod.
  ///
  /// In en, this message translates to:
  /// **'Digital (Razorpay)'**
  String get receiptDigitalMethod;

  /// No description provided for @receiptSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get receiptSuccessTitle;

  /// No description provided for @receiptSuccessPaymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get receiptSuccessPaymentId;

  /// No description provided for @receiptSuccessRequestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get receiptSuccessRequestId;

  /// No description provided for @receiptSuccessVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get receiptSuccessVehicle;

  /// No description provided for @receiptSuccessMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get receiptSuccessMethod;

  /// No description provided for @receiptSuccessReceiptId.
  ///
  /// In en, this message translates to:
  /// **'Receipt ID'**
  String get receiptSuccessReceiptId;

  /// No description provided for @receiptSuccessViewDownload.
  ///
  /// In en, this message translates to:
  /// **'View & Download Receipt'**
  String get receiptSuccessViewDownload;

  /// No description provided for @historyDeleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete Request'**
  String get historyDeleteRequest;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this request from history? This cannot be undone.'**
  String get historyDeleteConfirm;

  /// No description provided for @historyDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request deleted.'**
  String get historyDeleteSuccess;

  /// No description provided for @historyDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: '**
  String get historyDeleteError;

  /// No description provided for @historyDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All History'**
  String get historyDeleteAll;

  /// No description provided for @historyDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all completed and cancelled requests? Cannot be undone.'**
  String get historyDeleteAllConfirm;

  /// No description provided for @historyDeleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get historyDeleteAllButton;

  /// No description provided for @historyDeleteAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} item(s).'**
  String historyDeleteAllSuccess(int count);

  /// No description provided for @historyViewBillPay.
  ///
  /// In en, this message translates to:
  /// **'View Bill & Pay'**
  String get historyViewBillPay;

  /// No description provided for @historyServiceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service completed. View your bill and pay.'**
  String get historyServiceCompleted;

  /// No description provided for @historyCashPending.
  ///
  /// In en, this message translates to:
  /// **'Cash payment pending. Pay mechanic when service is done.'**
  String get historyCashPending;

  /// No description provided for @historyWaitingMechanic.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a mechanic...'**
  String get historyWaitingMechanic;

  /// No description provided for @historyViewEstimateCancel.
  ///
  /// In en, this message translates to:
  /// **'View Estimate & Cancel'**
  String get historyViewEstimateCancel;

  /// No description provided for @historyTrackOnMap.
  ///
  /// In en, this message translates to:
  /// **'Track on Map'**
  String get historyTrackOnMap;

  /// No description provided for @historyPaymentPendingBill.
  ///
  /// In en, this message translates to:
  /// **'Service completed. View your bill and pay.'**
  String get historyPaymentPendingBill;

  /// No description provided for @historyKeepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep Request'**
  String get historyKeepRequest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
