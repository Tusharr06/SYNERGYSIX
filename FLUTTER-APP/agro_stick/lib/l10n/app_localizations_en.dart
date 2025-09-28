// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Agrostick App';

  @override
  String get profile => 'Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get farmName => 'Farm Name';

  @override
  String get language => 'Language';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get logout => 'Logout';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String profileUpdateError(Object error) {
    return 'Error updating profile: $error';
  }

  @override
  String get welcome => 'Welcome!';

  @override
  String get hi => 'Hi';

  @override
  String get weeklyWeather => 'Weekly Weather';

  @override
  String get fetchingWeather => 'Fetching 7-day weather…';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get espStatus => 'ESP32-S3 Status';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get temperature => 'Temperature';

  @override
  String get sprayStatus => 'Spray Status';

  @override
  String get idle => 'Idle';

  @override
  String get spraying => 'Spraying';

  @override
  String get blogs => 'Blogs';

  @override
  String get viewAll => 'View All';

  @override
  String get sprayHistory => 'Spray History';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get sprays => 'Sprays';

  @override
  String get sprayDetails => 'Spray Details';

  @override
  String get sprayTrend => 'Spray Trend';

  @override
  String get spray => 'Spray';

  @override
  String get time => 'Time';

  @override
  String get amount => 'Amount';

  @override
  String get liters => 'L';

  @override
  String sprayNumber(Object number) {
    return 'Spray $number';
  }

  @override
  String get cropHealth => 'Crop Health';

  @override
  String get farmMapping => 'Farm Mapping';

  @override
  String get farmMappingDescription =>
      'Map your farm boundary and detect disease locations with precision';

  @override
  String get openFarmMapping => 'Open Farm Mapping';

  @override
  String get scanField => 'Scan Field for Accurate Results';

  @override
  String get scanFieldDescription =>
      'Initiate a field scan to detect crop health issues with high accuracy';

  @override
  String get fieldScan => 'Field Scan';

  @override
  String get loadingModel => 'Loading model...';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get cancel => 'Cancel';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get startSpray => 'Start Spray';

  @override
  String get stopSpray => 'Stop Spray';

  @override
  String get scheduleSpray => 'Schedule Spray';

  @override
  String get environmentalConditions => 'Environmental Conditions';

  @override
  String get humidity => 'Humidity';

  @override
  String get soilCondition => 'Soil Condition';

  @override
  String get optimal => 'Optimal';

  @override
  String get overallInfectionLevel => 'Overall Infection Level';

  @override
  String get cropStatus => 'Crop Status';

  @override
  String get healthy => 'Healthy';

  @override
  String get unhealthy => 'Unhealthy';

  @override
  String get treatmentRecommendations => 'Treatment Recommendations';

  @override
  String get basedOnCurrentInfection => 'Based on current infection level:';

  @override
  String get applyHighDosagePesticide => 'Apply high-dosage targeted pesticide';

  @override
  String get inspectAndMonitorDaily =>
      'Inspect and monitor daily for spread; re-scan in 24 hours';

  @override
  String get removeAffectedLeaves =>
      'Remove heavily affected leaves; isolate diseased plants to limit spread';

  @override
  String get startingPesticideSpray => 'Starting pesticide spray...';

  @override
  String get stoppingPesticideSpray => 'Stopping pesticide spray...';

  @override
  String get openingSpraySchedule => 'Opening spray schedule...';

  @override
  String rateLimitedMessage(Object seconds) {
    return 'Rate limited. Please wait $seconds seconds...';
  }

  @override
  String get analyzingMessage => 'Analyzing...';

  @override
  String rateLimitedRetryMessage(
    Object seconds,
    Object attempt,
    Object maxRetries,
  ) {
    return 'Rate limited. Retrying in $seconds seconds... ($attempt/$maxRetries)';
  }

  @override
  String analysisCompleteMessage(Object disease) {
    return 'Analysis complete: $disease';
  }

  @override
  String analysisFailedMessage(Object error) {
    return 'Analysis failed: $error';
  }

  @override
  String get unknownDiseaseDetected => 'Unknown disease detected';

  @override
  String get couldNotParseAIResponse => 'Could not parse AI response';

  @override
  String get notAnalyzed => 'Not Analyzed';

  @override
  String get lowSeverity => 'Low';

  @override
  String get mediumSeverity => 'Medium';

  @override
  String get highSeverity => 'High';

  @override
  String applyPesticideFormat(
    Object pesticide,
    Object dosage,
    Object frequency,
  ) {
    return 'Apply $pesticide at $dosage, $frequency.';
  }

  @override
  String get detected => 'Detected';

  @override
  String get pleaseWaitBeforeScanning => 'Please wait before scanning again';

  @override
  String get invalidImageMessage =>
      'The uploaded image does not appear to be a crop leaf. Please upload a clear image of the leaf or crop.';

  @override
  String get tryAgain => 'Try Again';
}
