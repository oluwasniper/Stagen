import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// The current language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// The name of the software application
  ///
  /// In en, this message translates to:
  /// **'Scagen'**
  String get appName;

  /// Onboarding screen content heading
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingHeader;

  /// Onboarding screen content subheading
  ///
  /// In en, this message translates to:
  /// **'Go and enjoy our features for free and make your life easy with us.'**
  String get onboardingSubHeader;

  /// Button to skip the onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go'**
  String get onboardingSkipButton;

  /// Button label to move to the next onboarding page
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Generate QR Codes'**
  String get onboardingPage2Title;

  /// Onboarding page 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Create QR codes for text, Wi-Fi, contacts, events and more in seconds.'**
  String get onboardingPage2Subtitle;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Track Your History'**
  String get onboardingPage3Title;

  /// Onboarding page 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'All your scanned and generated QR codes stored securely and synced across devices.'**
  String get onboardingPage3Subtitle;

  /// Error message when page is not found
  ///
  /// In en, this message translates to:
  /// **'Error: Page not found'**
  String get errorText;

  /// Error message to show OR
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get errorOR;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get errorGoBack;

  /// Screen to generate a QR code
  ///
  /// In en, this message translates to:
  /// **'Generate QR'**
  String get generateQR;

  /// Text to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textQR;

  /// Website to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteQR;

  /// Wi-Fi details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifiQR;

  /// Event details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventQR;

  /// Contact details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactQR;

  /// Business details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessQR;

  /// Location details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationQR;

  /// WhatsApp details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappQR;

  /// Email details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailQR;

  /// Twitter details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitterQR;

  /// Instagram details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagramQR;

  /// Telephone details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get telephoneQR;

  /// SMS details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get smsQR;

  /// Telegram details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegramQR;

  /// LinkedIn details to be converted to QR code
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedinQR;

  /// Button to generate a code
  ///
  /// In en, this message translates to:
  /// **'Generate a Code'**
  String get generateCode;

  /// Tab to view the history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Tab to generate a QR code
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Tab to scan a QR code
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Scanner success banner when a QR is detected
  ///
  /// In en, this message translates to:
  /// **'✓  QR Code Detected'**
  String get qrCodeDetected;

  /// Tab to create a QR code
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Tab to view the settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Setting to enable or disable vibration
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get vibrate;

  /// Description of the setting to enable or disable vibration
  ///
  /// In en, this message translates to:
  /// **'Vibration when scan is done'**
  String get vibrateDesc;

  /// Setting to enable or disable beep
  ///
  /// In en, this message translates to:
  /// **'Beep'**
  String get beep;

  /// Description of the setting to enable or disable beep
  ///
  /// In en, this message translates to:
  /// **'Beep when scan is done'**
  String get beepDesc;

  /// Tab to view the support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Button to rate the app
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// Description to rate the app
  ///
  /// In en, this message translates to:
  /// **'Your best reward to us'**
  String get rateUsDesc;

  /// Button to share the app
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareApp;

  /// Description to share the app
  ///
  /// In en, this message translates to:
  /// **'Share app with others.'**
  String get shareDesc;

  /// Button to view the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Description to view the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Follow our policies that benefits you.'**
  String get privacyPolicyDesc;

  /// The Header of the result screen
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get openFileHeader;

  /// Button to show the QR code
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQRCode;

  /// Button to share the QR code
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareBtn;

  /// Button to copy the QR code
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyBtn;

  /// Button to open a scanned URL
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openBtn;

  /// Button label to return to QR generation home
  ///
  /// In en, this message translates to:
  /// **'Back to Generate'**
  String get backToGenerate;

  /// Button label to return to scan home
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// The QR code
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// Fallback label for generated QR content type
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generatedLabel;

  /// Title shown on the scanned result card
  ///
  /// In en, this message translates to:
  /// **'Scanned Result'**
  String get scannedResultTitle;

  /// Placeholder text when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Button to save the QR code
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// Button to generate the QR code
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get generateQRCodeBtn;

  /// Label for the text input
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textLabel;

  /// Hint for the text input
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get textHint;

  /// Label for the website URL input
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteURLLabel;

  /// Hint for the website URL input
  ///
  /// In en, this message translates to:
  /// **'Eg: https://www.example.com'**
  String get websiteURLHint;

  /// Label for the network input
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// Hint for the network input
  ///
  /// In en, this message translates to:
  /// **'Enter network name'**
  String get networkHint;

  /// Button text to choose an SSID from nearby device Wi-Fi networks
  ///
  /// In en, this message translates to:
  /// **'Choose from device Wi-Fi'**
  String get wifiChooseFromDevice;

  /// Button text while Wi-Fi networks are being scanned
  ///
  /// In en, this message translates to:
  /// **'Loading Wi-Fi networks...'**
  String get wifiLoadingNetworks;

  /// Title for Wi-Fi network picker sheet
  ///
  /// In en, this message translates to:
  /// **'Select Wi-Fi network'**
  String get wifiPickerTitle;

  /// Message when no Wi-Fi SSIDs are found
  ///
  /// In en, this message translates to:
  /// **'No Wi-Fi networks found'**
  String get wifiNoNetworksFound;

  /// Message when app cannot scan Wi-Fi due to missing permission or service
  ///
  /// In en, this message translates to:
  /// **'Location service and permission are required to scan Wi-Fi'**
  String get wifiScanPermissionRequired;

  /// Label shown for the current connected Wi-Fi network in picker
  ///
  /// In en, this message translates to:
  /// **'Current connected network'**
  String get wifiUseConnectedNetwork;

  /// Message shown when app auto-fills SSID using current connected network
  ///
  /// In en, this message translates to:
  /// **'Using current connected Wi-Fi network'**
  String get wifiUsingConnectedNetwork;

  /// Label for the password input
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Hint for the password input
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// Label for the event name input
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventNamelabel;

  /// Hint for the event name input
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get eventNameHint;

  /// Label for the start date and time input
  ///
  /// In en, this message translates to:
  /// **'Start Date And Time'**
  String get startDateAndTimeLabel;

  /// Hint for the start date and time input
  ///
  /// In en, this message translates to:
  /// **'Eg: 12 Dec 2025 12:00 PM'**
  String get startDateAndTimeHint;

  /// Label for the end date and time input
  ///
  /// In en, this message translates to:
  /// **'End Date And Time'**
  String get endDateAndTimeLabel;

  /// Hint for the end date and time input
  ///
  /// In en, this message translates to:
  /// **'Eg: 12 Dec 2025 12:00 PM'**
  String get endDateAndTimeHint;

  /// Label for the event location input
  ///
  /// In en, this message translates to:
  /// **'Event Location'**
  String get eventLocationLabel;

  /// Hint for the event location input
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get eventLocationHint;

  /// Label for the description input
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Hint for the description input
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get descriptionHint;

  /// Label for the first name input
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// Hint for the first name input
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get firstNameHint;

  /// Label for the last name input
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// Hint for the last name input
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get lastNameHint;

  /// Label for the company input
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// Hint for the company input
  ///
  /// In en, this message translates to:
  /// **'Enter company'**
  String get companyHint;

  /// Label for the job input
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get jobLabel;

  /// Hint for the job input
  ///
  /// In en, this message translates to:
  /// **'Enter job'**
  String get jobHint;

  /// Label for the phone input
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Hint for the phone input
  ///
  /// In en, this message translates to:
  /// **'Enter phone'**
  String get phoneHint;

  /// Label for the email input
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Hint for the email input
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailHint;

  /// Label for the website input
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// Hint for the website input
  ///
  /// In en, this message translates to:
  /// **'Enter website'**
  String get websiteHint;

  /// Label for the address input
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// Hint for the address input
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get addressHint;

  /// Label for the city input
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// Hint for the city input
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get cityHint;

  /// Label for the country input
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// Hint for the country input
  ///
  /// In en, this message translates to:
  /// **'Enter country'**
  String get countryHint;

  /// Label for the WhatsApp number input
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumberLabel;

  /// Hint for the WhatsApp number input
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get whatsappNumberHint;

  /// Label for the Twitter username input
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get twitterUsernameLabel;

  /// Hint for the Twitter username input
  ///
  /// In en, this message translates to:
  /// **'Enter Twitter username'**
  String get twitterUsernameHint;

  /// Label for the Instagram username input
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get instagramUsernameLabel;

  /// Hint for the Instagram username input
  ///
  /// In en, this message translates to:
  /// **'Enter Instagram username'**
  String get instagramUsernameHint;

  /// Label for the phone number input
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// Hint for the phone number input
  ///
  /// In en, this message translates to:
  /// **'+92xxxxxxxxxx'**
  String get phoneNumberHint;

  /// Label for the SMS recipient number input
  ///
  /// In en, this message translates to:
  /// **'SMS Number'**
  String get smsNumberLabel;

  /// Hint for the SMS recipient number input
  ///
  /// In en, this message translates to:
  /// **'Enter recipient number'**
  String get smsNumberHint;

  /// Label for the SMS message body input
  ///
  /// In en, this message translates to:
  /// **'SMS Message'**
  String get smsMessageLabel;

  /// Hint for the SMS message body input
  ///
  /// In en, this message translates to:
  /// **'Enter message (optional)'**
  String get smsMessageHint;

  /// Label for Telegram username input
  ///
  /// In en, this message translates to:
  /// **'Telegram Username'**
  String get telegramUsernameLabel;

  /// Hint for Telegram username input
  ///
  /// In en, this message translates to:
  /// **'Enter username or @handle'**
  String get telegramUsernameHint;

  /// Label for LinkedIn profile input
  ///
  /// In en, this message translates to:
  /// **'LinkedIn Profile'**
  String get linkedinProfileLabel;

  /// Hint for LinkedIn profile input
  ///
  /// In en, this message translates to:
  /// **'Enter profile URL or username'**
  String get linkedinProfileHint;

  /// Validation error when SMS number is missing
  ///
  /// In en, this message translates to:
  /// **'SMS number is required'**
  String get validationSmsNumberRequired;

  /// Validation error when SMS number format is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid SMS number'**
  String get validationSmsNumberInvalid;

  /// Validation error when Telegram username is missing
  ///
  /// In en, this message translates to:
  /// **'Telegram username is required'**
  String get validationTelegramRequired;

  /// Validation error when Telegram input is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Telegram username or t.me link'**
  String get validationTelegramInvalid;

  /// Validation error when LinkedIn profile is missing
  ///
  /// In en, this message translates to:
  /// **'LinkedIn profile is required'**
  String get validationLinkedinRequired;

  /// Validation error when LinkedIn input is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid LinkedIn profile URL or username'**
  String get validationLinkedinInvalid;

  /// Button label to use the device current location
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get locationUseCurrentLocation;

  /// Button label shown while fetching current location
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get locationGettingCurrentLocation;

  /// Divider text between current location action and manual coordinate entry
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get locationOrDivider;

  /// Label for the latitude input
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get locationLatitudeLabel;

  /// Hint for the latitude input
  ///
  /// In en, this message translates to:
  /// **'Enter latitude'**
  String get locationLatitudeHint;

  /// Label for the longitude input
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get locationLongitudeLabel;

  /// Hint for the longitude input
  ///
  /// In en, this message translates to:
  /// **'Enter longitude'**
  String get locationLongitudeHint;

  /// Label for the language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get changeLanguage;

  /// Description for the language setting
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeLanguageDesc;

  /// Button label to import a contact from the phone address book
  ///
  /// In en, this message translates to:
  /// **'Import from Phone Contacts'**
  String get importFromContacts;

  /// Message shown when the user denies contacts permission
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied. Please allow access in settings.'**
  String get contactPermissionDenied;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// Email input hint
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Password input hint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Name input hint
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get authName;

  /// Validation message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// Validation message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailInvalid;

  /// Validation message when password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// Validation message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordTooShort;

  /// Link to switch to sign up mode
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get authSwitchToSignUp;

  /// Link to switch to sign in mode
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get authSwitchToSignIn;

  /// Divider text between auth options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// Button to continue as anonymous user
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get authContinueAnonymous;

  /// Log out button label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get authLogout;

  /// Log out description
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get authLogoutDesc;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authAccount;

  /// Title for linking anonymous account to email/password
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccountTitle;

  /// Subtitle shown in settings tile for account linking
  ///
  /// In en, this message translates to:
  /// **'Upgrade to email/password account'**
  String get linkAccountSubtitle;

  /// Label for the email input field in the account linking form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get linkAccountEmailLabel;

  /// Label for the password input field in the account linking form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get linkAccountPasswordLabel;

  /// Label for the optional name input field in the account linking form
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get linkAccountNameOptionalLabel;

  /// Cancel button label in the account linking dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get linkAccountCancel;

  /// Submit button label in the account linking dialog
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkAccountAction;

  /// Validation message shown when the email field is empty in the account linking form
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get linkAccountEmailRequired;

  /// Validation message shown when the password is shorter than 8 characters in the account linking form
  ///
  /// In en, this message translates to:
  /// **'Min 8 chars'**
  String get linkAccountPasswordMin;

  /// Snackbar message when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get snackbarLocationPermissionDenied;

  /// Snackbar message when location permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Please enable them in settings.'**
  String get snackbarLocationPermissionPermanentlyDenied;

  /// Snackbar message when getting location fails
  ///
  /// In en, this message translates to:
  /// **'Failed to get location: {error}'**
  String snackbarFailedToGetLocation(String error);

  /// Snackbar message when required fields are empty
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields'**
  String get snackbarFillRequiredFields;

  /// Snackbar message when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get snackbarCopiedToClipboard;

  /// Shown when user picks an image that has no decodable QR code
  ///
  /// In en, this message translates to:
  /// **'No QR code found in selected image'**
  String get noQrFoundInImage;

  /// Error when user tries to register with an existing email
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get apiErrorUserAlreadyExists;

  /// Error when login credentials are wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get apiErrorInvalidCredentials;

  /// Error when user account is blocked
  ///
  /// In en, this message translates to:
  /// **'This account has been blocked. Please contact support.'**
  String get apiErrorUserBlocked;

  /// Error when user account is not found
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get apiErrorUserNotFound;

  /// Error when email is already taken
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get apiErrorEmailAlreadyExists;

  /// Error when password does not match
  ///
  /// In en, this message translates to:
  /// **'The password you entered is incorrect.'**
  String get apiErrorPasswordMismatch;

  /// Error when trying to create a session while one exists
  ///
  /// In en, this message translates to:
  /// **'A session is already active. Please sign out first.'**
  String get apiErrorSessionAlreadyExists;

  /// Error when user is not authorised
  ///
  /// In en, this message translates to:
  /// **'You are not authorised to perform this action.'**
  String get apiErrorUnauthorized;

  /// Error when password was recently used
  ///
  /// In en, this message translates to:
  /// **'This password was recently used. Please choose a different one.'**
  String get apiErrorPasswordRecentlyUsed;

  /// Error when rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get apiErrorRateLimitExceeded;

  /// Error when server encounters an internal error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again later.'**
  String get apiErrorServerError;

  /// Fallback error message for unrecognised errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get apiErrorUnknown;

  /// Message when history fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get historyLoadFailed;

  /// Button to retry loading history
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get historyRetry;

  /// Message when there is no history
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmpty;

  /// Action to trigger manual history synchronization
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// Shown when manual history sync completes
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncCompleted;

  /// Badge for records waiting to be synced
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingSync;

  /// Privacy section header in settings
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Toggle title to share anonymous analytics
  ///
  /// In en, this message translates to:
  /// **'Share Analytics'**
  String get shareAnalytics;

  /// Toggle subtitle explaining anonymous analytics sharing
  ///
  /// In en, this message translates to:
  /// **'Help improve Scagen by sharing anonymous usage data'**
  String get shareAnalyticsSubtitle;

  /// Error message shown when sharing fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share'**
  String get failedToShare;

  /// Error message shown when scanned content cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open this content'**
  String get unableToOpenContent;

  /// Banner shown when the device has no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// Tagline shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Scan · Generate · Share'**
  String get scanGenerateShare;
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
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
