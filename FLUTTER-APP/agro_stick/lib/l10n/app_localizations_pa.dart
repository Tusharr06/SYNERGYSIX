// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'ਐਗਰੋਸਟਿਕ ਐਪ';

  @override
  String get profile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get personalInformation => 'ਨਿੱਜੀ ਜਾਣਕਾਰੀ';

  @override
  String get name => 'ਨਾਮ';

  @override
  String get phone => 'ਫ਼ੋਨ';

  @override
  String get farmName => 'ਖੇਤ ਦਾ ਨਾਮ';

  @override
  String get language => 'ਭਾਸ਼ਾ';

  @override
  String get saveProfile => 'ਪ੍ਰੋਫਾਈਲ ਸੰਭਾਲੋ';

  @override
  String get logout => 'ਲਾਗਆਉਟ';

  @override
  String get profileUpdated => 'ਪ੍ਰੋਫਾਈਲ ਸਫਲਤਾਪੂਰਵਕ ਅਪਡੇਟ ਕੀਤੀ ਗਈ';

  @override
  String profileUpdateError(Object error) {
    return 'ਪ੍ਰੋਫਾਈਲ ਅਪਡੇਟ ਕਰਨ ਵਿੱਚ ਗਲਤੀ: $error';
  }

  @override
  String get welcome => 'ਸਵਾਗਤ ਹੈ!';

  @override
  String get hi => 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ';

  @override
  String get weeklyWeather => 'ਹਫ਼ਤਾਵਾਰੀ ਮੌਸਮ';

  @override
  String get fetchingWeather => '7-ਦਿਨਾਂ ਦਾ ਮੌਸਮ ਲੈ ਰਹੇ ਹਾਂ…';

  @override
  String get weatherUnavailable => 'ਮੌਸਮ ਜਾਣਕਾਰੀ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get espStatus => 'ESP32-S3 ਹਾਲਤ';

  @override
  String get connected => 'ਜੁੜਿਆ ਹੋਇਆ';

  @override
  String get disconnected => 'ਅਣਜੁੜਿਆ';

  @override
  String get batteryLevel => 'ਬੈਟਰੀ ਪੱਧਰ';

  @override
  String get temperature => 'ਤਾਪਮਾਨ';

  @override
  String get sprayStatus => 'ਸਪਰੇ ਹਾਲਤ';

  @override
  String get idle => 'ਨਿਸ਼ਕ੍ਰਿਆ';

  @override
  String get spraying => 'ਸਪਰੇ ਕਰ ਰਹੇ ਹਾਂ';

  @override
  String get blogs => 'ਬਲੌਗ';

  @override
  String get viewAll => 'ਸਭ ਵੇਖੋ';

  @override
  String get sprayHistory => 'ਸਪਰੇ ਇਤਿਹਾਸ';

  @override
  String get today => 'ਅੱਜ';

  @override
  String get thisWeek => 'ਇਸ ਹਫ਼ਤੇ';

  @override
  String get thisMonth => 'ਇਸ ਮਹੀਨੇ';

  @override
  String get sprays => 'ਸਪਰੇ';

  @override
  String get sprayDetails => 'ਸਪਰੇ ਵੇਰਵੇ';

  @override
  String get sprayTrend => 'ਸਪਰੇ ਰੁਝਾਨ';

  @override
  String get spray => 'ਸਪਰੇ';

  @override
  String get time => 'ਸਮਾਂ';

  @override
  String get amount => 'ਮਾਤਰਾ';

  @override
  String get liters => 'ਲੀਟਰ';

  @override
  String sprayNumber(Object number) {
    return 'ਸਪਰੇ $number';
  }

  @override
  String get cropHealth => 'ਫਸਲ ਸਿਹਤ';

  @override
  String get farmMapping => 'ਖੇਤ ਨਕਸ਼ਾ';

  @override
  String get farmMappingDescription =>
      'ਆਪਣੀ ਖੇਤ ਦੀ ਸੀਮਾ ਨੂੰ ਨਕਸ਼ੇ \'ਤੇ ਦਰਜ ਕਰੋ ਅਤੇ ਬੀਮਾਰੀ ਦੇ ਸਥਾਨਾਂ ਦਾ ਪਤਾ ਲਗਾਓ';

  @override
  String get openFarmMapping => 'ਖੇਤ ਨਕਸ਼ਾ ਖੋਲ੍ਹੋ';

  @override
  String get scanField => 'ਸਹੀ ਨਤੀਜਿਆਂ ਲਈ ਖੇਤ ਸਕੈਨ ਕਰੋ';

  @override
  String get scanFieldDescription =>
      'ਫਸਲ ਸਿਹਤ ਸਮੱਸਿਆਵਾਂ ਦਾ ਪਤਾ ਲਗਾਉਣ ਲਈ ਖੇਤ ਸਕੈਨ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get fieldScan => 'ਖੇਤ ਸਕੈਨ';

  @override
  String get loadingModel => 'ਮਾਡਲ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get selectImageSource => 'ਚਿੱਤਰ ਸਰੋਤ ਚੁਣੋ';

  @override
  String get camera => 'ਕੈਮਰਾ';

  @override
  String get gallery => 'ਗੈਲਰੀ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get quickActions => 'ਤੇਜ਼ ਕਾਰਵਾਈਆਂ';

  @override
  String get startSpray => 'ਸਪਰੇ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get stopSpray => 'ਸਪਰੇ ਰੁਕੋ';

  @override
  String get scheduleSpray => 'ਸਪਰੇ ਸ਼ਿਡਿਊਲ ਕਰੋ';

  @override
  String get environmentalConditions => 'ਪਰਿਬੇਸ਼ਕ ਸਥਿਤੀਆਂ';

  @override
  String get humidity => 'ਨਮੀ';

  @override
  String get soilCondition => 'ਮਿੱਟੀ ਦੀ ਹਾਲਤ';

  @override
  String get optimal => 'ਵਧੀਆ';

  @override
  String get overallInfectionLevel => 'ਕੁੱਲ ਸੰਕਰਮਣ ਪੱਧਰ';

  @override
  String get cropStatus => 'ਫਸਲ ਹਾਲਤ';

  @override
  String get healthy => 'ਸਿਹਤਮੰਦ';

  @override
  String get unhealthy => 'ਅਸਿਹਤਮੰਦ';

  @override
  String get treatmentRecommendations => 'ਇਲਾਜ ਸਿਫਾਰਸ਼ਾਂ';

  @override
  String get basedOnCurrentInfection => 'ਮੌਜੂਦਾ ਸੰਕਰਮਣ ਪੱਧਰ ਦੇ ਅਧਾਰ \'ਤੇ:';

  @override
  String get applyHighDosagePesticide => 'ਉੱਚ-ਖੁਰਾਕ ਟਾਰਗੇਟ ਕੀਟਨਾਸ਼ਕ ਲਗਾਓ';

  @override
  String get inspectAndMonitorDaily =>
      'ਫੈਲਣ ਲਈ ਰੋਜ਼ਾਨਾ ਜਾਂਚ ਕਰੋ; 24 ਘੰਟਿਆਂ ਵਿੱਚ ਦੁਬਾਰਾ ਸਕੈਨ ਕਰੋ';

  @override
  String get removeAffectedLeaves =>
      'ਭਾਰੀ ਪ੍ਰਭਾਵਿਤ ਪੱਤੇ ਹਟਾਓ; ਬੀਮਾਰ ਪੌਦਿਆਂ ਨੂੰ ਵੱਖ ਕਰੋ';

  @override
  String get startingPesticideSpray => 'ਕੀਟਨਾਸ਼ਕ ਸਪਰੇ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get stoppingPesticideSpray => 'ਕੀਟਨਾਸ਼ਕ ਸਪਰੇ ਰੁਕ ਰਿਹਾ ਹੈ...';

  @override
  String get openingSpraySchedule => 'ਸਪਰੇ ਸ਼ਿਡਿਊਲ ਖੋਲ੍ਹ ਰਹੇ ਹਾਂ...';

  @override
  String rateLimitedMessage(Object seconds) {
    return 'ਰੇਟ ਸੀਮਿਤ। ਕਿਰਪਾ ਕਰਕੇ $seconds ਸਕਿੰਟ ਰੁਕੋ...';
  }

  @override
  String get analyzingMessage => 'ਵਿਸ਼ਲੇਸ਼ਣ ਕਰ ਰਹੇ ਹਾਂ...';

  @override
  String rateLimitedRetryMessage(
    Object seconds,
    Object attempt,
    Object maxRetries,
  ) {
    return 'ਰੇਟ ਸੀਮਿਤ। $seconds ਸਕਿੰਟ ਵਿੱਚ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰ ਰਹੇ ਹਾਂ... ($attempt/$maxRetries)';
  }

  @override
  String analysisCompleteMessage(Object disease) {
    return 'ਵਿਸ਼ਲੇਸ਼ਣ ਪੂਰਾ: $disease';
  }

  @override
  String analysisFailedMessage(Object error) {
    return 'ਵਿਸ਼ਲੇਸ਼ਣ ਅਸਫਲ: $error';
  }

  @override
  String get unknownDiseaseDetected => 'ਅਗਿਆਤ ਬਿਮਾਰੀ ਦਾ ਪਤਾ ਲੱਗਾ';

  @override
  String get couldNotParseAIResponse => 'AI ਜਵਾਬ ਨੂੰ ਪਾਰਸ ਕਰਨ ਵਿੱਚ ਅਸਫਲ';

  @override
  String get notAnalyzed => 'ਵਿਸ਼ਲੇਸ਼ਣ ਨਹੀਂ ਕੀਤਾ';

  @override
  String get lowSeverity => 'ਘੱਟ';

  @override
  String get mediumSeverity => 'ਮੱਧਮ';

  @override
  String get highSeverity => 'ਉੱਚਾ';

  @override
  String applyPesticideFormat(
    Object pesticide,
    Object dosage,
    Object frequency,
  ) {
    return '$pesticide ਨੂੰ $dosage \'ਤੇ, $frequency।';
  }

  @override
  String get detected => 'ਪਤਾ ਲੱਗਾ';

  @override
  String get pleaseWaitBeforeScanning => 'ਕਿਰਪਾ ਕਰਕੇ ਸਕੈਨ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਉਡੀਕੋ';

  @override
  String get invalidImageMessage =>
      'ਅਪਲੋਡ ਕੀਤੀ ਤਸਵੀਰ ਫਸਲ ਦੇ ਪੱਤੇ ਵਰਗੀ ਨਹੀਂ ਲੱਗਦੀ। ਕਿਰਪਾ ਕਰਕੇ ਪੱਤੇ ਜਾਂ ਫਸਲ ਦੀ ਸਾਫ਼ ਤਸਵੀਰ ਅਪਲੋਡ ਕਰੋ।';

  @override
  String get tryAgain => 'ਵਾਪਸ ਕੋਸ਼ਿਸ਼ ਕਰੋ';
}
