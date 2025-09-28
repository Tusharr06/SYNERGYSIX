import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

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
    Locale('hi'),
    Locale('pa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Agrostick App'**
  String get appTitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String profileUpdateError(Object error);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @weeklyWeather.
  ///
  /// In en, this message translates to:
  /// **'Weekly Weather'**
  String get weeklyWeather;

  /// No description provided for @fetchingWeather.
  ///
  /// In en, this message translates to:
  /// **'Fetching 7-day weather…'**
  String get fetchingWeather;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @espStatus.
  ///
  /// In en, this message translates to:
  /// **'ESP32-S3 Status'**
  String get espStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @sprayStatus.
  ///
  /// In en, this message translates to:
  /// **'Spray Status'**
  String get sprayStatus;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @spraying.
  ///
  /// In en, this message translates to:
  /// **'Spraying'**
  String get spraying;

  /// No description provided for @blogs.
  ///
  /// In en, this message translates to:
  /// **'Blogs'**
  String get blogs;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @sprayHistory.
  ///
  /// In en, this message translates to:
  /// **'Spray History'**
  String get sprayHistory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @sprays.
  ///
  /// In en, this message translates to:
  /// **'Sprays'**
  String get sprays;

  /// No description provided for @sprayDetails.
  ///
  /// In en, this message translates to:
  /// **'Spray Details'**
  String get sprayDetails;

  /// No description provided for @sprayTrend.
  ///
  /// In en, this message translates to:
  /// **'Spray Trend'**
  String get sprayTrend;

  /// No description provided for @spray.
  ///
  /// In en, this message translates to:
  /// **'Spray'**
  String get spray;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get liters;

  /// Dynamic spray number like 'Spray 1'
  ///
  /// In en, this message translates to:
  /// **'Spray {number}'**
  String sprayNumber(Object number);

  /// No description provided for @cropHealth.
  ///
  /// In en, this message translates to:
  /// **'Crop Health'**
  String get cropHealth;

  /// No description provided for @farmMapping.
  ///
  /// In en, this message translates to:
  /// **'Farm Mapping'**
  String get farmMapping;

  /// No description provided for @farmMappingDescription.
  ///
  /// In en, this message translates to:
  /// **'Map your farm boundary and detect disease locations with precision'**
  String get farmMappingDescription;

  /// No description provided for @openFarmMapping.
  ///
  /// In en, this message translates to:
  /// **'Open Farm Mapping'**
  String get openFarmMapping;

  /// No description provided for @scanField.
  ///
  /// In en, this message translates to:
  /// **'Scan Field for Accurate Results'**
  String get scanField;

  /// No description provided for @scanFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Initiate a field scan to detect crop health issues with high accuracy'**
  String get scanFieldDescription;

  /// No description provided for @fieldScan.
  ///
  /// In en, this message translates to:
  /// **'Field Scan'**
  String get fieldScan;

  /// No description provided for @loadingModel.
  ///
  /// In en, this message translates to:
  /// **'Loading model...'**
  String get loadingModel;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @startSpray.
  ///
  /// In en, this message translates to:
  /// **'Start Spray'**
  String get startSpray;

  /// No description provided for @stopSpray.
  ///
  /// In en, this message translates to:
  /// **'Stop Spray'**
  String get stopSpray;

  /// No description provided for @scheduleSpray.
  ///
  /// In en, this message translates to:
  /// **'Schedule Spray'**
  String get scheduleSpray;

  /// No description provided for @environmentalConditions.
  ///
  /// In en, this message translates to:
  /// **'Environmental Conditions'**
  String get environmentalConditions;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @soilCondition.
  ///
  /// In en, this message translates to:
  /// **'Soil Condition'**
  String get soilCondition;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @overallInfectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Overall Infection Level'**
  String get overallInfectionLevel;

  /// No description provided for @cropStatus.
  ///
  /// In en, this message translates to:
  /// **'Crop Status'**
  String get cropStatus;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @unhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get unhealthy;

  /// No description provided for @treatmentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Treatment Recommendations'**
  String get treatmentRecommendations;

  /// No description provided for @basedOnCurrentInfection.
  ///
  /// In en, this message translates to:
  /// **'Based on current infection level:'**
  String get basedOnCurrentInfection;

  /// No description provided for @applyHighDosagePesticide.
  ///
  /// In en, this message translates to:
  /// **'Apply high-dosage targeted pesticide'**
  String get applyHighDosagePesticide;

  /// No description provided for @inspectAndMonitorDaily.
  ///
  /// In en, this message translates to:
  /// **'Inspect and monitor daily for spread; re-scan in 24 hours'**
  String get inspectAndMonitorDaily;

  /// No description provided for @removeAffectedLeaves.
  ///
  /// In en, this message translates to:
  /// **'Remove heavily affected leaves; isolate diseased plants to limit spread'**
  String get removeAffectedLeaves;

  /// No description provided for @startingPesticideSpray.
  ///
  /// In en, this message translates to:
  /// **'Starting pesticide spray...'**
  String get startingPesticideSpray;

  /// No description provided for @stoppingPesticideSpray.
  ///
  /// In en, this message translates to:
  /// **'Stopping pesticide spray...'**
  String get stoppingPesticideSpray;

  /// No description provided for @openingSpraySchedule.
  ///
  /// In en, this message translates to:
  /// **'Opening spray schedule...'**
  String get openingSpraySchedule;

  /// No description provided for @rateLimitedMessage.
  ///
  /// In en, this message translates to:
  /// **'Rate limited. Please wait {seconds} seconds...'**
  String rateLimitedMessage(Object seconds);

  /// No description provided for @analyzingMessage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzingMessage;

  /// No description provided for @rateLimitedRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Rate limited. Retrying in {seconds} seconds... ({attempt}/{maxRetries})'**
  String rateLimitedRetryMessage(
    Object seconds,
    Object attempt,
    Object maxRetries,
  );

  /// No description provided for @analysisCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete: {disease}'**
  String analysisCompleteMessage(Object disease);

  /// No description provided for @analysisFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {error}'**
  String analysisFailedMessage(Object error);

  /// No description provided for @unknownDiseaseDetected.
  ///
  /// In en, this message translates to:
  /// **'Unknown disease detected'**
  String get unknownDiseaseDetected;

  /// No description provided for @couldNotParseAIResponse.
  ///
  /// In en, this message translates to:
  /// **'Could not parse AI response'**
  String get couldNotParseAIResponse;

  /// No description provided for @notAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Not Analyzed'**
  String get notAnalyzed;

  /// No description provided for @lowSeverity.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowSeverity;

  /// No description provided for @mediumSeverity.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumSeverity;

  /// No description provided for @highSeverity.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highSeverity;

  /// No description provided for @applyPesticideFormat.
  ///
  /// In en, this message translates to:
  /// **'Apply {pesticide} at {dosage}, {frequency}.'**
  String applyPesticideFormat(
    Object pesticide,
    Object dosage,
    Object frequency,
  );

  /// Label for detected disease in scan results
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detected;

  /// No description provided for @pleaseWaitBeforeScanning.
  ///
  /// In en, this message translates to:
  /// **'Please wait before scanning again'**
  String get pleaseWaitBeforeScanning;

  /// No description provided for @invalidImageMessage.
  ///
  /// In en, this message translates to:
  /// **'The uploaded image does not appear to be a crop leaf. Please upload a clear image of the leaf or crop.'**
  String get invalidImageMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;
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
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
