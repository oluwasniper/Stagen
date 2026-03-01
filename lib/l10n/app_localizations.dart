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

  /// The QR code
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

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
