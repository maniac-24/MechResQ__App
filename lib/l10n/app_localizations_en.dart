// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'MechResQ';

  @override
  String get welcomeSubtitle => 'Stuck on road? Help is on the way.';

  @override
  String get loginButton => 'Login';

  @override
  String get createUserAccountButton => 'Create Account';

  @override
  String get mechanicRegisterPrompt => 'Are you a mechanic? Register here';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get googleLoginFailed => 'Google login failed';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get loginTitle => 'Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterValidEmail => 'Enter valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String minCharacters(int count) {
    return 'Min $count characters';
  }

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get userRole => 'User';

  @override
  String get mechanicRole => 'Mechanic';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get confirm => 'Confirm';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get whatsYourNumber => 'What\'s your number?';

  @override
  String get phoneNumberMust10Digits => 'Phone number must be 10 digits';

  @override
  String get pleaseEnterOnlyNumbers => 'Please enter only numbers';

  @override
  String get enterValid10DigitMobile => 'Enter a valid 10-digit mobile number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get help => 'Help';

  @override
  String get byContinu18Years =>
      'By continuing, you confirm that you are 18 years\nof age and agree to the';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get codeSentTo => 'Code sent to';

  @override
  String get enterComplete6DigitOtp => 'Enter the complete 6-digit OTP';

  @override
  String get invalidOtpTryAgain => 'Invalid OTP. Please try again.';

  @override
  String get resendIn => 'Resend in';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get verificationFailed => 'Verification failed. Try again.';

  @override
  String get completeYourProfile => 'Complete Your Profile';

  @override
  String get helpUsPersonalize => 'Help us personalize your experience';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get emailAddressOptional => 'Email Address (Optional)';

  @override
  String get emailPlaceholder => 'yourname@example.com';

  @override
  String get getStarted => 'Get Started';

  @override
  String get infoSecureMessage =>
      'Your information is secure and will only be used for service delivery.';

  @override
  String get mechanicsNearby => 'Mechanics Nearby';

  @override
  String get myRequests => 'My Requests';

  @override
  String get myVehicles => 'My Vehicles';

  @override
  String get searchHint => 'Search by name, shop or vehicle type...';

  @override
  String get fetchingLocation => 'Fetching location...';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get noMechanicsNearby => 'No mechanics nearby';

  @override
  String get mechanicsWillAppear =>
      'Mechanics will appear here\nonce they come online';

  @override
  String get noMatchingMechanics => 'No mechanics match your search.';

  @override
  String get filters => 'Filters';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get appLanguage => 'App Language';

  @override
  String get about => 'About';

  @override
  String get aboutMechResQ => 'About MechResQ';

  @override
  String get version => 'Version';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String themeSetTo(String theme) {
    return 'Theme set to $theme';
  }

  @override
  String languageChangedTo(String language) {
    return 'Language changed to $language';
  }

  @override
  String aboutMechResQDescription(String version, String build) {
    return 'MechResQ\nVersion $version (Build $build)\n\nA fast and reliable vehicle breakdown assistance app.\n\nFind nearby mechanics, request service, track your requests â€” all in one place.\n\nÂ© 2026 MechResQ. All rights reserved.';
  }

  @override
  String get allRequests => 'All';

  @override
  String get activeRequests => 'Active';

  @override
  String get completedRequests => 'Completed';

  @override
  String get cancelledRequests => 'Cancelled';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get noRequestsMessage =>
      'When you request help, your service requests will appear here.';

  @override
  String get requestHelp => 'Request Help';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get cancelRequestConfirm =>
      'Are you sure you want to cancel this request?';

  @override
  String get yesCancelRequest => 'Yes, Cancel';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String get viewDetails => 'View Details';

  @override
  String get trackMechanic => 'Track Mechanic';

  @override
  String get contactMechanic => 'Contact Mechanic';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get mechanicEnRoute => 'Mechanic En Route';

  @override
  String get mechanicNearby => 'Mechanic Nearby';

  @override
  String get mechanicArrived => 'Mechanic Arrived';

  @override
  String get workInProgress => 'Work in Progress';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get trackingYourRequest => 'Tracking Your Request';

  @override
  String get estimatedArrival => 'Estimated Arrival';

  @override
  String get minutes => 'min';

  @override
  String get mechanicDetails => 'Mechanic Details';

  @override
  String get callMechanic => 'Call Mechanic';

  @override
  String get chatWithMechanic => 'Chat with Mechanic';

  @override
  String get requestTimeline => 'Request Timeline';

  @override
  String get requestPlaced => 'Request Placed';

  @override
  String get mechanicAccepted => 'Mechanic Accepted';

  @override
  String get onTheWay => 'On the Way';

  @override
  String get arrived => 'Arrived';

  @override
  String get workStarted => 'Work Started';

  @override
  String get workCompleted => 'Work Completed';

  @override
  String get awayFromYou => 'away from you';

  @override
  String get sos => 'SOS';

  @override
  String get emergencyHelp => 'Emergency Help';

  @override
  String get sosDescription =>
      'Use this feature only in case of emergencies. This will send your location to nearby mechanics and emergency contacts.';

  @override
  String get sendSosAlert => 'Send SOS Alert';

  @override
  String get sosAlertSent => 'SOS Alert Sent!';

  @override
  String get sosAlertSentMessage =>
      'Your emergency alert has been sent to nearby mechanics and your emergency contacts.';

  @override
  String get callEmergency => 'Call Emergency';

  @override
  String get call => 'Call';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get addEmergencyContact => 'Add Emergency Contact';

  @override
  String get noEmergencyContacts => 'No emergency contacts added';

  @override
  String get addEmergencyContactMessage =>
      'Add trusted contacts who will be notified in case of emergencies.';

  @override
  String get createRequest => 'Create Request';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get selectService => 'Select Service';

  @override
  String get describeIssue => 'Describe Issue';

  @override
  String get describeIssuePlaceholder =>
      'Describe the problem (e.g., engine stalls when idling)...';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get uploadImages => 'Upload Images (Optional)';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get pleaseSelectVehicle => 'Please select a vehicle';

  @override
  String get pleaseSelectService => 'Please select a service';

  @override
  String get pleaseDescribeIssue => 'Please describe the issue.';

  @override
  String get pleaseSelectLocation => 'Please select a location';

  @override
  String get requestCreated => 'Request Created';

  @override
  String get requestCreatedMessage =>
      'Your request has been sent to nearby mechanics. You\'ll be notified when a mechanic accepts.';

  @override
  String get serviceTypes => 'Service Types';

  @override
  String get flatTire => 'Flat Tire';

  @override
  String get batteryJump => 'Battery Jump';

  @override
  String get engineIssue => 'Engine Issue';

  @override
  String get brakeIssue => 'Brake Issue';

  @override
  String get fuelDelivery => 'Fuel Delivery';

  @override
  String get towing => 'Towing';

  @override
  String get otherServiceType => 'Other';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get otherInformation => 'Other Information';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Gender';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get languagesKnown => 'Languages Known';

  @override
  String get pincode => 'Pincode';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get notProvided => 'Not provided';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get couldNotLoadProfile => 'Could not load profile.';

  @override
  String get primary => 'Primary';

  @override
  String get otherInfo => 'Other Info';

  @override
  String get phone => 'Phone';

  @override
  String get dob => 'DOB';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get selectLanguagesKnown => 'Select Languages Known';

  @override
  String get selectDOB => 'Select DOB';

  @override
  String get selectState => 'Select State';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileSaved => 'Profile saved successfully âœ…';

  @override
  String get nameRequired => 'Name *';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get failedToSaveProfile => 'Failed to save profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get serviceReminders => 'Service Reminders';

  @override
  String get serviceRemindersDesc => 'Reminders for upcoming service requests';

  @override
  String get security => 'Security';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get biometricLoginDesc => 'Use fingerprint or face ID to login';

  @override
  String get account => 'Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDesc => 'Permanently remove your account';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved âœ…';

  @override
  String get failedToSaveSettings => 'Failed to save settings';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'This will permanently delete your account and all associated data. This action cannot be undone.';

  @override
  String get accountDeletionRequested => 'Account deletion requested';

  @override
  String get select => 'Select';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get serviceHistory => 'Service History';

  @override
  String get savedAddresses => 'Saved Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get language => 'Language';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get aboutApp => 'About App';

  @override
  String get logoutFromAccount => 'Logout from Account';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get vehicleMake => 'Vehicle Make';

  @override
  String get vehicleModel => 'Vehicle Model';

  @override
  String get vehicleYear => 'Year';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get addNewVehicle => 'Add New Vehicle';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get deleteVehicle => 'Delete Vehicle';

  @override
  String get noVehiclesYet => 'No vehicles yet';

  @override
  String get addYourFirstVehicle => 'Add your first vehicle to get started';

  @override
  String get deleteVehicleConfirm =>
      'Are you sure you want to delete this vehicle?';

  @override
  String get yesDelete => 'Yes, Delete';

  @override
  String get vehicleAdded => 'Vehicle added successfully';

  @override
  String get vehicleUpdated => 'Vehicle updated successfully';

  @override
  String get vehicleDeleted => 'Vehicle deleted';

  @override
  String get car => 'Car';

  @override
  String get bike => 'Bike';

  @override
  String get scooter => 'Scooter';

  @override
  String get auto => 'Auto';

  @override
  String get truck => 'Truck';

  @override
  String get suv => 'SUV';

  @override
  String get bus => 'Bus';

  @override
  String get heavyVehicle => 'Heavy Vehicle';

  @override
  String get shopName => 'Shop Name';

  @override
  String get experience => 'Experience';

  @override
  String get years => 'years';

  @override
  String get rating => 'Rating';

  @override
  String get reviews => 'Reviews';

  @override
  String get specialization => 'Specialization';

  @override
  String get servicesOffered => 'Services Offered';

  @override
  String get availability => 'Availability';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get viewReviews => 'View Reviews';

  @override
  String get bookService => 'Book Service';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get awayLabel => 'away';

  @override
  String get openNow => 'Open Now';

  @override
  String get closedNow => 'Closed Now';

  @override
  String get goBack => 'Go Back';

  @override
  String get cancelRequestTitle => 'Cancel Request?';

  @override
  String get cancelRequestMessage =>
      'Are you sure? You can only cancel before the mechanic starts travelling.';

  @override
  String get trackingNotAvailable => 'Tracking not available';

  @override
  String get loadingMap => 'Loading map...';

  @override
  String get viewOnGoogleMaps => 'View on Google Maps';

  @override
  String get emergencySos => 'Emergency SOS';

  @override
  String get sosEmergency => 'SOS Emergency';

  @override
  String get refreshLocation => 'Refresh Location';

  @override
  String get activatingSos => 'Activating SOS...';

  @override
  String get sosHistory => 'SOS History';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get markCompleteQuestion => 'Mark as Complete?';

  @override
  String markCompleteMessage(String title) {
    return 'Mark \"$title\" as completed?';
  }

  @override
  String get complete => 'Complete';

  @override
  String get deleteReminder => 'Delete Reminder?';

  @override
  String get deleteReminderMessage => 'This action cannot be undone.';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get overdue => 'Overdue';

  @override
  String get noUpcomingReminders => 'No upcoming reminders';

  @override
  String get noOverdueReminders => 'No overdue reminders';

  @override
  String get dueDate => 'Due Date';

  @override
  String get mileage => 'Mileage';

  @override
  String get notes => 'Notes';

  @override
  String get dueNow => 'Due Now';

  @override
  String get days => 'days';

  @override
  String get markAsCompleteQuestion => 'Mark as Complete?';

  @override
  String markAsCompleteMessage(String title) {
    return 'Mark \"$title\" as completed?';
  }

  @override
  String get reminderMarkedCompleted => 'Reminder marked as completed âœ…';

  @override
  String get failedToCompleteReminder => 'Failed to complete reminder';

  @override
  String get deleteReminderQuestion => 'Delete Reminder?';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get failedToDeleteReminder => 'Failed to delete reminder';

  @override
  String get noReminders => 'No Reminders';

  @override
  String get tapPlusToAddReminder => 'Tap + to add your first service reminder';

  @override
  String get noCompletedReminders => 'No Completed Reminders';

  @override
  String get completedRemindersAppearHere =>
      'Completed reminders will appear here';

  @override
  String get completedOn => 'Completed on';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get chooseVehicle => 'Choose a vehicle';

  @override
  String get reminderType => 'Reminder Type';

  @override
  String get pleaseSelectType => 'Please select a type';

  @override
  String get reminderTitle => 'Reminder Title';

  @override
  String get reminderTitleHint => 'e.g., Oil Change Due';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get addNotesOrDetails => 'Add notes or details';

  @override
  String get required => 'Required';

  @override
  String get reminderDate => 'Reminder Date';

  @override
  String get selectADate => 'Select a date';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get mileageOptional => 'Mileage (Optional)';

  @override
  String get mileageHint => 'e.g., 50000';

  @override
  String get updateReminder => 'Update Reminder';

  @override
  String get createReminder => 'Create Reminder';

  @override
  String get noVehiclesAdded => 'No Vehicles Added';

  @override
  String get addVehicleFirstMessage =>
      'Add a vehicle first to create service reminders';

  @override
  String get pleaseFillAllRequiredFields => 'Please fill all required fields';

  @override
  String get pleaseSelectReminderDate => 'Please select a reminder date';

  @override
  String get reminderUpdated => 'Reminder updated âœ…';

  @override
  String get failedToUpdateReminder => 'Failed to update reminder';

  @override
  String get reminderCreated => 'Reminder created âœ…';

  @override
  String get failedToCreateReminder => 'Failed to create reminder';

  @override
  String get reminderTypeGeneralService => 'General Service';

  @override
  String get reminderTypeOilChange => 'Oil Change';

  @override
  String get reminderTypeTireRotation => 'Tire Rotation';

  @override
  String get reminderTypeTireCheck => 'Tire Check';

  @override
  String get reminderTypeBatteryCheck => 'Battery Check';

  @override
  String get reminderTypeBrakeService => 'Brake Service';

  @override
  String get reminderTypeInsuranceRenewal => 'Insurance Renewal';

  @override
  String get reminderTypePollutionCheck => 'Pollution Check';

  @override
  String get reminderTypeEngineCheck => 'Engine Check';

  @override
  String get reminderTypeAcService => 'AC Service';

  @override
  String get reminderTypeWheelAlignment => 'Wheel Alignment';

  @override
  String get reminderTypeCustom => 'Custom';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get helpDescription =>
      'We\'re here 24/7 to assist you during vehicle breakdowns';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get callSupport => 'Call Support';

  @override
  String get emailUs => 'Email Us';

  @override
  String get reportIssue => 'Report an Issue';

  @override
  String get tutorials => 'Tutorials';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get viewAll => 'View All';

  @override
  String get faqQuestion1 => 'How do I request a mechanic?';

  @override
  String get faqAnswer1 =>
      '1. Go to Home screen\n2. Browse nearby mechanics or search by filters\n3. Select a mechanic\n4. Tap \'Request Service\'\n5. Fill in your vehicle details and issue\n6. Confirm your location\n7. Submit the request';

  @override
  String get faqQuestion2 => 'How is distance calculated?';

  @override
  String get faqAnswer2 =>
      'Distance is calculated using GPS coordinates between your current location and the mechanic\'s workshop. Make sure location services are enabled for accurate results.';

  @override
  String get faqQuestion3 => 'Can I add multiple vehicles?';

  @override
  String get faqAnswer3 =>
      'Yes! Open the menu by tapping your profile icon, select \'My Vehicles\', and add unlimited vehicles. You can switch between them when creating service requests.';

  @override
  String get faqQuestion4 => 'What should I do in an emergency?';

  @override
  String get faqAnswer4 =>
      '1. Tap the SOS button (red button in menu)\n2. Your location will be shared automatically\n3. Emergency contacts will be notified\n4. Nearest mechanics will be alerted\n5. Stay calm and safe in your vehicle';

  @override
  String get faqQuestion5 => 'How do payments work?';

  @override
  String get faqAnswer5 =>
      'All payments are processed securely through the app. You can pay via UPI, cards, or wallets after the service is completed. Cash payments are also accepted at the mechanic\'s discretion.';

  @override
  String get faqQuestion6 => 'Can I cancel a request?';

  @override
  String get faqAnswer6 =>
      'Yes, you can cancel before the mechanic accepts it. Go to My Requests â†’ Select request â†’ Tap \'Cancel\'. Cancellation charges may apply if mechanic has already started traveling.';

  @override
  String get emergencySafety => 'Emergency & Safety';

  @override
  String get safetyGuidelines => 'Safety Guidelines';

  @override
  String get safetyTips =>
      'â€¢ If stranded in an unsafe location, stay inside your vehicle with doors locked\nâ€¢ Turn on hazard lights and use warning triangles if available\nâ€¢ Use the SOS Call feature for immediate emergency assistance\nâ€¢ Never share OTPs, passwords, or banking details with anyone\nâ€¢ Verify mechanic ID and rating before accepting service\nâ€¢ All payments should be done through the app only\nâ€¢ Take photos of damage before and after repair\nâ€¢ Keep emergency numbers saved in your phone';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get supportHours => 'Support Hours';

  @override
  String get support24x7 => '24/7 Emergency Support';

  @override
  String get location => 'Location';

  @override
  String get locationIndia => 'India (All Major Cities)';

  @override
  String get submitSupportTicket => 'Submit a Support Ticket';

  @override
  String get openingIssueReport => 'Opening issue report form...';

  @override
  String get openingVideoTutorials => 'Opening video tutorials...';

  @override
  String get openingFullFaq => 'Opening full FAQ page...';

  @override
  String get openingSupportTicket => 'Opening support ticket form...';

  @override
  String get mechresqVersion => 'MechResQ • Version 1.0.0';

  @override
  String get copyrightMechresq => '© 2026 MechResQ. All rights reserved.';

  @override
  String get reviewsRatings => 'Reviews & Ratings';

  @override
  String get mostRecent => 'Most Recent';

  @override
  String get highestRated => 'Highest Rated';

  @override
  String get lowestRated => 'Lowest Rated';

  @override
  String get mostHelpful => 'Most Helpful';

  @override
  String get writeReview => 'Write Review';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get yourReview => 'Your Review';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get reviewSubmitted => 'Review submitted successfully';

  @override
  String get helpful => 'Helpful';

  @override
  String get notHelpful => 'Not Helpful';

  @override
  String get requestDetails => 'Request Details';

  @override
  String get requestSubmitted =>
      'Your request has been submitted successfully.';

  @override
  String get viewMyRequests => 'View My Requests';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get serviceComplete => 'Service Complete';

  @override
  String get rateService => 'Rate Service';

  @override
  String get howWasService => 'How was the service?';

  @override
  String get writeYourFeedback => 'Write your feedback...';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get thankYouFeedback => 'Thank you for your feedback!';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Type a messageâ€¦';

  @override
  String get send => 'Send';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get typing => 'Typing...';

  @override
  String get emergencyContactsTitle => 'Emergency Contacts';

  @override
  String get info => 'Info';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get relationship => 'Relationship';

  @override
  String get noContactsAdded => 'No contacts added';

  @override
  String get noEmergencyContactsTitle => 'No Emergency Contacts';

  @override
  String get addTrustedContactsMessage =>
      'Add trusted contacts who will be notified\nduring emergencies';

  @override
  String get addFirstContact => 'Add your first emergency contact';

  @override
  String get addFirstContactButton => 'Add First Contact';

  @override
  String get phoneNumberRequired => 'Phone Number *';

  @override
  String get relationshipRequired => 'Relationship *';

  @override
  String get relationshipHint => 'e.g., Father, Wife, Friend';

  @override
  String get setAsPrimaryContact => 'Set as Primary Contact';

  @override
  String get primaryContactCalledFirst => 'Primary contact is called first';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get aboutEmergencyContacts => 'About Emergency Contacts';

  @override
  String get emergencyContactsInfoDetails =>
      'â€¢ Add up to 5 trusted contacts\n\nâ€¢ Contacts are notified during SOS activation\n\nâ€¢ Primary contact is called first\n\nâ€¢ SMS with your location is sent automatically\n\nâ€¢ Works even without internet (via SMS)\n\nâ€¢ Keep contact details updated';

  @override
  String get gotIt => 'Got it';

  @override
  String get deleteContactQuestion => 'Delete Contact?';

  @override
  String deleteContactMessage(String name) {
    return 'Are you sure you want to remove $name from emergency contacts?';
  }

  @override
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get contactUpdatedSuccess => 'Contact updated';

  @override
  String get contactAdded => 'Contact added successfully';

  @override
  String get contactAddedSuccess => 'Contact added';

  @override
  String get contactUpdated => 'Contact updated successfully';

  @override
  String get contactDeleted => 'Contact deleted successfully';

  @override
  String get contactDeletedSuccess => 'Contact deleted';

  @override
  String get failedToUpdateContact => 'Failed to update contact';

  @override
  String get failedToAddContactMax5 => 'Failed to add contact (max 5 allowed)';

  @override
  String get failedToDeleteContact => 'Failed to delete contact';

  @override
  String get unableToMakeCall => 'Unable to make call';

  @override
  String get deleteContactConfirm =>
      'Are you sure you want to delete this contact?';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get giveFeedback => 'Give Feedback';

  @override
  String get wrongApp => 'Wrong App';

  @override
  String get wrongAppMessage =>
      'This is the MechResQ User App. Please download the MechResQ Mechanic App to continue.';

  @override
  String get selectVehicleType => 'Select Vehicle Type';

  @override
  String get enterVehicleMake => 'Enter vehicle make';

  @override
  String get enterVehicleModel => 'Enter vehicle model';

  @override
  String get enterVehicleYear => 'Enter year';

  @override
  String get enterVehicleNumber => 'Enter vehicle number';

  @override
  String get vehicleTypeRequired => 'Vehicle type is required';

  @override
  String get vehicleMakeRequired => 'Vehicle make is required';

  @override
  String get vehicleModelRequired => 'Vehicle model is required';

  @override
  String get vehicleYearRequired => 'Year is required';

  @override
  String get vehicleNumberRequired => 'Vehicle number is required';

  @override
  String get distance => 'Distance';

  @override
  String get km => 'km';

  @override
  String get miles => 'miles';

  @override
  String get meters => 'meters';

  @override
  String get requestId => 'Request ID';

  @override
  String get requestDate => 'Request Date';

  @override
  String get requestTime => 'Request Time';

  @override
  String get serviceCost => 'Service Cost';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get readMore => 'Read More';

  @override
  String get readLess => 'Read Less';

  @override
  String get photo => 'Photo';

  @override
  String get photos => 'Photos';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get submit => 'Submit';

  @override
  String get remove => 'Remove';

  @override
  String get change => 'Change';

  @override
  String get choose => 'Choose';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get clear => 'Clear';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get now => 'Now';

  @override
  String get soon => 'Soon';

  @override
  String get later => 'Later';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get paste => 'Paste';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get locationPermission => 'Location permission is required';

  @override
  String get cameraPermission => 'Camera permission is required';

  @override
  String get storagePermission => 'Storage permission is required';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get noInternet => 'No Internet Connection';

  @override
  String get checkConnection => 'Please check your internet connection';

  @override
  String get retryConnection => 'Retry';

  @override
  String get confirmServiceCharges =>
      'Please confirm service charges before repair.';

  @override
  String get paymentOptions => 'Payment options may include Cash / UPI.';

  @override
  String get verifyMechanicIdentity =>
      'Always verify mechanic identity before proceeding.';

  @override
  String get shareFeatureComingSoon => 'Share feature coming soon';

  @override
  String doYouWantToCall(String phone) {
    return 'Do you want to call $phone?';
  }

  @override
  String calling(String phone) {
    return 'Calling $phone...';
  }

  @override
  String get active => 'Active';

  @override
  String get history => 'History';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get noActiveRequests => 'No active requests';

  @override
  String get noRequestHistory => 'No request history';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get createServiceRequest => 'Create Service Request';

  @override
  String get provideDetailsQuickly =>
      'Provide details so a mechanic can assist you quickly.';

  @override
  String get describeTheIssue => 'Describe the Issue';

  @override
  String get attachPhoto => 'Attach Photo';

  @override
  String get noPhotosAttached => 'No photos attached';

  @override
  String get yourLocation => 'Your Location';

  @override
  String get detectMyLocation => 'Detect My Location';

  @override
  String get detecting => 'Detecting...';

  @override
  String get liveLocationDetected => 'Live location detected successfully!';

  @override
  String get locationDetectedSuccessfully => 'Location detected successfully!';

  @override
  String get pleaseDetectLocation => 'Please detect your location first.';

  @override
  String get failedToSubmitRequest => 'Failed to submit request';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get uploadIdDocument => 'Upload ID Document';

  @override
  String get choosePdfFile => 'Choose PDF / File';

  @override
  String get cannotAttachFiles => 'Cannot attach files.';

  @override
  String get permissionPermanentlyDenied =>
      'Permission permanently denied. Opening settings...';

  @override
  String get cameraPermissionRequired => 'Camera permission required';

  @override
  String attached(String name) {
    return 'Attached: $name';
  }

  @override
  String get locationServicesDisabled =>
      'Location services are disabled. Please turn on GPS.';

  @override
  String get couldNotGetLocation => 'Could not get location';

  @override
  String get mechresqWantsAccessStorage =>
      'MechResQ wants to access your storage';

  @override
  String get neededToAttachPhotos =>
      'This is needed to attach photos to your request';

  @override
  String get whileUsingApp => 'While using the app';

  @override
  String get onlyThisTime => 'Only this time';

  @override
  String get dontAllow => 'Don\'t allow';

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get enterVehicleName => 'Enter vehicle name';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get yearEg2020 => 'Year (e.g., 2020)';

  @override
  String get licenseplate => 'License Plate';

  @override
  String get chooseImage => 'Choose Image';

  @override
  String get noImage => 'No image';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get emailAddress => 'Email';

  @override
  String get enterPhone => 'Enter phone';

  @override
  String get selectLanguageKnown => 'Select Language Known';

  @override
  String get selectDob => 'Select DOB';

  @override
  String get requestSubmittedTitle => 'Request Submitted';

  @override
  String get requestSent => 'Request Sent';

  @override
  String vehicleServiceRequestSubmitted(String vehicle) {
    return 'Your $vehicle service request has been submitted successfully. A nearby mechanic will contact you shortly.';
  }

  @override
  String get summary => 'Summary';

  @override
  String get serviceCompleteTitle => 'Service Complete';

  @override
  String get serviceCompletedExclaim => 'Service Completed!';

  @override
  String get thankYouForUsingMechresq => 'Thank you for using MechResQ';

  @override
  String get serviceSummary => 'Service Summary';

  @override
  String get mechanic => 'Mechanic';

  @override
  String get issue => 'Issue';

  @override
  String get payment => 'Payment';

  @override
  String get serviceCharge => 'Service Charge';

  @override
  String get tax => 'Tax (5%)';

  @override
  String get total => 'Total';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get upiCashAtSite => 'UPI / Cash at site';

  @override
  String get rateYourMechanic => 'Rate Your Mechanic';

  @override
  String get writeYourFeedbackOptional => 'Write your feedback (optional)â€¦';

  @override
  String get submitAndClose => 'Submit & Close';

  @override
  String get thankYouForFeedback => 'Thank you for your feedback!';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingVeryGood => 'Very Good';

  @override
  String get ratingExcellent => 'Excellent!';

  @override
  String get tapStarToRate => 'Tap a star to rate';

  @override
  String get trackRequest => 'Track Request';

  @override
  String get mechanicLabel => 'Mechanic';

  @override
  String get statusTimeline => 'Status Timeline';

  @override
  String get eta => 'ETA';

  @override
  String get requestAccepted => 'Request Accepted';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String errorTrackingRequest(String error) {
    return 'Error tracking request: $error';
  }

  @override
  String get checkingMechanicLocation =>
      'Checking for mechanic location updates...';

  @override
  String get justNow => 'Just now';

  @override
  String minAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hourAgo(int hours) {
    return '$hours hour ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get reviewsRatingsTitle => 'Reviews & Ratings';

  @override
  String get errorLoadingReviews => 'Error loading reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to review!';

  @override
  String get ratingDistribution => 'Rating Distribution';

  @override
  String get wasThisHelpful => 'Was this helpful?';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get failedToRecordVote => 'Failed to record vote';

  @override
  String get editReview => 'Edit Review';

  @override
  String get rateYourExperienceWith => 'Rate your experience with';

  @override
  String get shareYourExperience =>
      'Share your experience with this mechanic...\n\nWas the service timely?\nHow was the quality of work?\nWould you recommend them?';

  @override
  String get pleaseWriteReview => 'Please write a review';

  @override
  String get reviewMustBe10Chars => 'Review must be at least 10 characters';

  @override
  String get reviewUpdatedSuccessfully => 'Review updated successfully';

  @override
  String get reviewSubmittedSuccessfully => 'Review submitted successfully';

  @override
  String failedToSubmitReview(String error) {
    return 'Failed to submit review: $error';
  }

  @override
  String get updateReview => 'Update Review';

  @override
  String get tipsForHelpfulReview => 'Tips for a helpful review';

  @override
  String get reviewTips =>
      'â€¢ Be specific about the service provided\nâ€¢ Mention timeliness and professionalism\nâ€¢ Share what you liked or didn\'t like\nâ€¢ Keep it honest and constructive';

  @override
  String get whereAreYou => 'Where are you?';

  @override
  String get imAtTheGate => 'I\'m at the gate';

  @override
  String get pleaseHurry => 'Please hurry';

  @override
  String get thankYou => 'Thank you';

  @override
  String get canYouCallMe => 'Can you call me?';

  @override
  String get attachments => 'Attachments';

  @override
  String get noAttachmentsUploaded => 'No attachments uploaded';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get attachmentApproved => 'Attachment approved ✓';

  @override
  String get attachmentRejected => 'Attachment rejected';

  @override
  String failedToUpdateAttachment(String error) {
    return 'Failed to update attachment: $error';
  }

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get cannotOpenFile => 'Cannot open this file';

  @override
  String failedToDownload(String error) {
    return 'Failed to download: $error';
  }

  @override
  String get expired => 'EXPIRED';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusApproved => 'APPROVED';

  @override
  String get statusRejected => 'REJECTED';

  @override
  String get requestNotFound => 'Request not found';

  @override
  String get waitingForMechanicAssignment =>
      'Waiting for mechanic assignmentâ€¦';

  @override
  String get userLocationNotAvailable => 'User location not available';

  @override
  String get mechanicDataNotFound => 'Mechanic data not found';

  @override
  String get mechanicLocationNotAvailable => 'Mechanic location not available';

  @override
  String get mechanicOffline => 'Mechanic Offline';

  @override
  String get you => 'You';

  @override
  String get fullMap => 'Full Map';

  @override
  String get cannotLaunchPhoneDialer => 'Cannot launch phone dialer';

  @override
  String get areYouSureCancelRequest =>
      'Are you sure? You can only cancel before the mechanic starts travelling.';

  @override
  String failedToCancel(String error) {
    return 'Failed to cancel: $error';
  }

  @override
  String get sosCallInitiated => '🚨 SOS call initiated!';

  @override
  String get other => 'Other';

  @override
  String get languageKnown => 'Language Known';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get remindUpcomingServiceDates =>
      'Remind me for upcoming service dates';

  @override
  String get useFingerprintFaceid => 'Use fingerprint or Face ID to sign in';

  @override
  String get permanentlyRemoveAccount => 'Permanently remove your account';

  @override
  String get primaryContactNotified =>
      'Primary contact is notified first in emergencies';

  @override
  String get experienceYears => 'Experience (years)';

  @override
  String get priceRange => 'Price range';

  @override
  String get any => 'Any';

  @override
  String get maxDistance => 'Max distance (km)';

  @override
  String get minimumRating => 'Minimum rating';

  @override
  String get resetAll => 'Reset all';

  @override
  String get thankYouNote =>
      'Thanks! We\'ll alert nearby mechanics & phone you shortly.';

  @override
  String get cancelLowercase => 'Cancel';

  @override
  String get emergencyDescription =>
      'In case of emergency, press the button below to alert nearby mechanics and your emergency contacts.';

  @override
  String get activateSos => 'Activate SOS';

  @override
  String get yourCurrentLocation => 'Your Current Location';

  @override
  String get notDetected => 'Not detected';

  @override
  String get detectLocation => 'Detect Location';

  @override
  String get sosActivated => 'SOS Activated';

  @override
  String get sosActivatedMessage =>
      'Emergency alert sent to nearby mechanics and your emergency contacts.';

  @override
  String get deactivateSos => 'Deactivate SOS';

  @override
  String get viewSosHistory => 'View SOS History';

  @override
  String get addFirstVehicle => 'Add your first vehicle to get started';

  @override
  String get trackingRequest => 'Tracking Request';

  @override
  String get mechanicOnTheWay => 'Mechanic is on the way';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get mechanicInfo => 'Mechanic Info';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get requestInfo => 'Request Info';

  @override
  String get issueDescription => 'Issue Description';

  @override
  String get requestLocation => 'Request Location';

  @override
  String get serviceType => 'Service Type';

  @override
  String get requestedOn => 'Requested on';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get rateYourExperience => 'Rate your experience with';

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get reportProblem => 'Report a Problem';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get appVersion => 'App Version';

  @override
  String get allReviews => 'All Reviews';

  @override
  String get filterBy => 'Filter by';

  @override
  String get sortBy => 'Sort by';

  @override
  String get stars => 'stars';

  @override
  String get writeAReview => 'Write a Review';

  @override
  String get tellUsMore => 'Tell us more about your experience...';

  @override
  String get postReview => 'Post Review';

  @override
  String get requestSuccess => 'Request Successful!';

  @override
  String get mechanicsNotified => 'Nearby mechanics have been notified.';

  @override
  String get emergencyType => 'Emergency Type';

  @override
  String get vehicleBreakdown => 'Vehicle Breakdown';

  @override
  String get medicalEmergency => 'Medical Emergency';

  @override
  String get accident => 'Accident';

  @override
  String get personalSafety => 'Personal Safety';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get tapToActivateEmergency => 'Tap to activate emergency alert';

  @override
  String get whatHappensWhenActivate => 'What happens when you activate SOS?';

  @override
  String smsContactsSent(int count) {
    return 'SMS sent to $count emergency contacts';
  }

  @override
  String get nearbyMechanicsAlerted => 'Nearby mechanics alerted (up to 5)';

  @override
  String get liveLocationShared => 'Live location shared automatically';

  @override
  String get eventLoggedHistory => 'Event logged in your SOS history';

  @override
  String get noEmergencyContactsWarning =>
      'No emergency contacts added. Tap to add.';

  @override
  String get quickEmergencyActions => 'Quick Emergency Actions';

  @override
  String get callPrimaryContact => 'Call Primary Contact';

  @override
  String get call112Emergency => 'Call 112 (Emergency Services)';

  @override
  String get manageEmergencyContacts => 'Manage Emergency Contacts';

  @override
  String get helpIsOneKnownAway => 'Help is one tap away';

  @override
  String get unableToDetectLocation =>
      'Unable to detect location. Please enable GPS and refresh.';

  @override
  String get sosFailed => 'SOS Failed';

  @override
  String get detectingLocation => 'Detecting location...';

  @override
  String get savingEvent => 'Saving event...';

  @override
  String get sendingSms => 'Sending SMS...';

  @override
  String get notifyingMechanics => 'Notifying mechanics...';

  @override
  String contactsNotified(int count) {
    return '$count contacts notified';
  }

  @override
  String mechanicsAlerted(int count) {
    return '$count mechanics alerted';
  }

  @override
  String locationLabel(String location) {
    return 'Location: $location';
  }

  @override
  String get staySafeHelpOnWay => 'Stay safe. Help is on the way.';

  @override
  String get noEmergencyContactsAdded => 'No emergency contacts added';

  @override
  String get unableToDial112 => 'Unable to dial 112';

  @override
  String get hideArchived => 'Hide Archived';

  @override
  String get showArchived => 'Show Archived';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get noArchivedEvents => 'No Archived Events';

  @override
  String get noSosHistory => 'No SOS History';

  @override
  String get archivedEventsMessage => 'You haven\'t archived any SOS events';

  @override
  String get sosHistoryMessage =>
      'Your emergency SOS activations\nwill appear here';

  @override
  String get contacted => 'contacted';

  @override
  String get alerted => 'alerted';

  @override
  String get sosEventDetails => 'SOS Event Details';

  @override
  String get status => 'Status';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get contactsNotifiedLabel => 'Contacts Notified';

  @override
  String get mechanicsAlertedLabel => 'Mechanics Alerted';

  @override
  String get respondedBy => 'Responded By';

  @override
  String get archiveEvent => 'Archive Event';

  @override
  String get unarchiveEvent => 'Unarchive Event';

  @override
  String get archiveEventConfirm =>
      'This will hide the event from your main view. You can view archived events by tapping the archive icon.';

  @override
  String get unarchiveEventConfirm =>
      'This will restore the event to your main SOS history.';

  @override
  String get eventArchived => 'Event archived';

  @override
  String get eventUnarchived => 'Event unarchived';

  @override
  String get failedToArchive => 'Failed to archive';

  @override
  String get failedToUnarchive => 'Failed to unarchive';

  @override
  String get tapPlusToAddVehicle =>
      'Tap the + button to add your first vehicle';

  @override
  String get failedToDeleteVehicle => 'Failed to delete vehicle';

  @override
  String get deleteVehicleQuestion => 'Delete Vehicle?';

  @override
  String get deleteVehiclePermanently =>
      'This will permanently delete this vehicle from your account.';

  @override
  String get type => 'Type';

  @override
  String get storageAccessNeeded => 'Storage Access Needed';

  @override
  String get needAccessPhotosUpload =>
      'We need access to your photos to upload vehicle images.';

  @override
  String get continueButton => 'Continue';

  @override
  String get uploadVehicleImage => 'Upload Vehicle Image';

  @override
  String get permissionNeededUpload => 'Permission needed to upload images.';

  @override
  String get permissionDeniedCannotUpload =>
      'Permission denied. Cannot upload images.';

  @override
  String get permissionPermanentlyDeniedOpening =>
      'Permission permanently denied. Opening settings...';

  @override
  String imageSelected(String name) {
    return 'Image selected: $name';
  }

  @override
  String get vehicleAddedSuccessfully => 'Vehicle added successfully âœ…';

  @override
  String get failedToAddVehicle => 'Failed to add vehicle';

  @override
  String get otherVehicle => 'Other';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Kannada';

  @override
  String get langTamil => 'Tamil';

  @override
  String get langTelugu => 'Telugu';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langMarathi => 'Marathi';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langPunjabi => 'Punjabi';

  @override
  String get langOdia => 'Odia';

  @override
  String get langUrdu => 'Urdu';

  @override
  String get stateAndaman => 'Andaman & Nicobar Islands';

  @override
  String get stateAndhra => 'Andhra Pradesh';

  @override
  String get stateArunachal => 'Arunachal Pradesh';

  @override
  String get stateAssam => 'Assam';

  @override
  String get stateBihar => 'Bihar';

  @override
  String get stateChandigarh => 'Chandigarh';

  @override
  String get stateChhattisgarh => 'Chhattisgarh';

  @override
  String get stateDelhi => 'Delhi';

  @override
  String get stateGoa => 'Goa';

  @override
  String get stateGujarat => 'Gujarat';

  @override
  String get stateHaryana => 'Haryana';

  @override
  String get stateHimachal => 'Himachal Pradesh';

  @override
  String get stateJharkhand => 'Jharkhand';

  @override
  String get stateKarnataka => 'Karnataka';

  @override
  String get stateKerala => 'Kerala';

  @override
  String get stateMadhya => 'Madhya Pradesh';

  @override
  String get stateMaharashtra => 'Maharashtra';

  @override
  String get statePunjab => 'Punjab';

  @override
  String get stateRajasthan => 'Rajasthan';

  @override
  String get stateTamilNadu => 'Tamil Nadu';

  @override
  String get stateTelangana => 'Telangana';

  @override
  String get stateUttar => 'Uttar Pradesh';

  @override
  String get stateWestBengal => 'West Bengal';

  @override
  String get locationNotDetectedTap =>
      'Location not detected. Tap \"Detect My Location\" to set your location on the map.';

  @override
  String get submitting => 'Submitting...';

  @override
  String get tipProvideDescription =>
      'Tip: Provide clear description and photos for faster help.';

  @override
  String get reviewsAndRatings => 'Reviews & Ratings';

  @override
  String get sortMostRecent => 'Most Recent';

  @override
  String get sortHighestRated => 'Highest Rated';

  @override
  String get sortLowestRated => 'Lowest Rated';

  @override
  String get sortMostHelpful => 'Most Helpful';

  @override
  String get beTheFirstToReview => 'Be the first to review!';

  @override
  String get pleaseWriteAReview => 'Please write a review';

  @override
  String get reviewMinLength => 'Review must be at least 10 characters';

  @override
  String get reviewUpdated => 'Review updated successfully';

  @override
  String get tipsForReview => 'Tips for a helpful review';

  @override
  String get reviewTip1 => '• Be specific about the service provided';

  @override
  String get reviewTip2 => '• Mention timeliness and professionalism';

  @override
  String get reviewTip3 => '• Share what you liked or didn\'t like';

  @override
  String get reviewTip4 => '• Keep it honest and constructive';

  @override
  String get typeAMessage => 'Type a message…';

  @override
  String get quickReplyWhereAreYou => 'Where are you?';

  @override
  String get quickReplyAtGate => 'I\'m at the gate';

  @override
  String get quickReplyHurry => 'Please hurry';

  @override
  String get quickReplyThankYou => 'Thank you';

  @override
  String get quickReplyCallMe => 'Can you call me?';

  @override
  String get noAttachments => 'No attachments uploaded';

  @override
  String get statusExpired => 'EXPIRED';

  @override
  String get waitingForMechanic => 'Waiting for mechanic assignment…';

  @override
  String get timelineAccepted => 'Accepted';

  @override
  String get timelineOnTheWay => 'On the Way';

  @override
  String get timelineCompleted => 'Completed';

  @override
  String get cannotLaunchDialer => 'Cannot launch phone dialer';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get mechresqTermsConditions => 'MechResQ Terms & Conditions';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get termsAgreementFooter =>
      'By using MechResQ, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.';

  @override
  String get mechresqPrivacyPolicy => 'MechResQ Privacy Policy';

  @override
  String get yourDataRights => 'Your Data Rights';

  @override
  String get dataRightsDescription =>
      'You have the right to access, correct, delete, or restrict the processing of your personal data. Contact us anytime to exercise these rights.';

  @override
  String get loginHelp => 'Help & Support';

  @override
  String get needHelpDescription =>
      'We\'re here 24/7 to assist you during vehicle breakdowns';

  @override
  String get faqUnableToLogin => 'I\'m unable to login to the app';

  @override
  String get faqUnableToLoginAnswer =>
      'Login issues generally arise due to poor network connectivity. Please check your internet connectivity and the signal strength of your network provider. You could also try reinstalling the app from Play Store.\n\nIf you don\'t receive the SMS with your OTP details, please check that the mobile number entered is valid.\n\nIf the mobile number entered is correct and you haven\'t received the SMS with OTP details, we request you to wait for a few minutes as there could be a delay in receiving SMS due to network issues.\n\nHowever, if you are still facing any issue, please contact our support team.';

  @override
  String get faqNotReceivingOtp => 'Not receiving OTP';

  @override
  String get faqNotReceivingOtpAnswer =>
      '• Check your mobile network signal strength\n• Verify the mobile number entered is correct\n• OTP messages can take up to 2-3 minutes to arrive\n• Check if SMS storage is full on your device\n• Try restarting your phone and request OTP again\n• Make sure you haven\'t blocked SMS from unknown numbers\n\nIf issue persists after 5 minutes, tap \"Resend OTP\" or contact support.';

  @override
  String get faqInvalidOtp => 'Invalid OTP error';

  @override
  String get faqInvalidOtpAnswer =>
      'This error occurs when:\n\n• You entered the wrong OTP code\n• The OTP has expired (valid for 10 minutes only)\n• Network delay caused verification timeout\n\nSolutions:\n1. Double-check the 6-digit code from SMS\n2. Request a new OTP if more than 10 minutes have passed\n3. Ensure stable internet connection during verification\n4. Try copying and pasting the OTP instead of typing';

  @override
  String get faqAppCrashes => 'App crashes during login';

  @override
  String get faqAppCrashesAnswer =>
      'If the app crashes or freezes during login:\n\n1. Force close the app completely\n2. Clear app cache: Settings → Apps → MechResQ → Clear Cache\n3. Check for app updates in Play Store\n4. Ensure you have stable internet (WiFi recommended)\n5. Free up phone storage (at least 100MB free space)\n6. Restart your device\n\nIf problem continues, uninstall and reinstall the app. Your data is safe and will be restored after logging in.';

  @override
  String get faqChangedPhoneNumber => 'Changed my phone number';

  @override
  String get faqChangedPhoneNumberAnswer =>
      'If you\'ve changed your mobile number:\n\n1. Login with your NEW phone number\n2. Complete the OTP verification\n3. Your account will be created with the new number\n4. You can then set up your profile again\n\nNote: Previous service history cannot be transferred to the new number. Contact support if you need to link your old account data.';

  @override
  String get wasThisArticleHelpful => 'Was this article helpful?';

  @override
  String get feedbackYes => 'Yes';

  @override
  String get feedbackNo => 'No';

  @override
  String get sorryContactSupport =>
      'We\'re sorry. Please contact support for more help.';

  @override
  String get unableToOpenPhoneDialer =>
      'Unable to open phone dialer. Please call +91 98765 00000 manually.';

  @override
  String get phoneDialerNotAvailable =>
      'Phone dialer not available. Call +91 98765 00000 manually.';

  @override
  String get unableToOpenEmailApp =>
      'Unable to open email app. Please email support@mechresq.com manually.';

  @override
  String get emailAppNotAvailable =>
      'Email app not available. Email support@mechresq.com manually.';

  @override
  String get mechanicNotFound => 'Mechanic not found';

  @override
  String get noRatings => 'No ratings';

  @override
  String get vehicleTypes => 'Vehicle Types';

  @override
  String lastSeenMinutesAgo(int minutes) {
    return 'Last seen $minutes min ago';
  }

  @override
  String get currentlyOffline => 'Currently Offline';

  @override
  String get supportedVehicleTypes => 'Supported Vehicle Types';

  @override
  String get ratingOverview => 'Rating Overview';

  @override
  String basedOnReviews(int count) {
    return 'Based on $count reviews';
  }

  @override
  String get contact => 'Contact';

  @override
  String get liveTracking => 'Live Tracking';

  @override
  String get fullScreenLiveMap => 'Full-Screen Live Map';

  @override
  String get mechanicHasArrived => 'Mechanic has arrived!';

  @override
  String get atYourLocation => 'At your location';

  @override
  String get onTheWayToYou => 'On the way to you';

  @override
  String get generalVehicleRepairServices => 'General vehicle repair services.';
}
