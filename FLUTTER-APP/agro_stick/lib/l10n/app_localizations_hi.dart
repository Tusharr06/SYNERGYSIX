// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एग्रोस्टिक ऐप';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get personalInformation => 'व्यक्तिगत जानकारी';

  @override
  String get name => 'नाम';

  @override
  String get phone => 'फ़ोन';

  @override
  String get farmName => 'खेत का नाम';

  @override
  String get language => 'भाषा';

  @override
  String get saveProfile => 'प्रोफाइल सहेजें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get profileUpdated => 'प्रोफाइल सफलतापूर्वक अपडेट की गई';

  @override
  String profileUpdateError(Object error) {
    return 'प्रोफाइल अपडेट करने में त्रुटि: $error';
  }

  @override
  String get welcome => 'स्वागत है!';

  @override
  String get hi => 'नमस्ते';

  @override
  String get weeklyWeather => 'साप्ताहिक मौसम';

  @override
  String get fetchingWeather => '7-दिवसीय मौसम ला रहे हैं…';

  @override
  String get weatherUnavailable => 'मौसम जानकारी उपलब्ध नहीं';

  @override
  String get espStatus => 'ESP32-S3 स्थिति';

  @override
  String get connected => 'संबद्ध';

  @override
  String get disconnected => 'असंबद्ध';

  @override
  String get batteryLevel => 'बैटरी स्तर';

  @override
  String get temperature => 'तापमान';

  @override
  String get sprayStatus => 'स्प्रे स्थिति';

  @override
  String get idle => 'निष्क्रिय';

  @override
  String get spraying => 'स्प्रे कर रहे हैं';

  @override
  String get blogs => 'ब्लॉग';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get sprayHistory => 'स्प्रे इतिहास';

  @override
  String get today => 'आज';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get sprays => 'स्प्रे';

  @override
  String get sprayDetails => 'स्प्रे विवरण';

  @override
  String get sprayTrend => 'स्प्रे रुझान';

  @override
  String get spray => 'स्प्रे';

  @override
  String get time => 'समय';

  @override
  String get amount => 'मात्रा';

  @override
  String get liters => 'लीटर';

  @override
  String sprayNumber(Object number) {
    return 'स्प्रे $number';
  }

  @override
  String get cropHealth => 'फसल स्वास्थ्य';

  @override
  String get farmMapping => 'खेत मैपिंग';

  @override
  String get farmMappingDescription =>
      'अपनी खेत की सीमा मैप करें और बीमारी के स्थान का पता लगाएं';

  @override
  String get openFarmMapping => 'खेत मैपिंग खोलें';

  @override
  String get scanField => 'सटीक परिणामों के लिए क्षेत्र स्कैन करें';

  @override
  String get scanFieldDescription =>
      'फसल स्वास्थ्य समस्याओं का पता लगाने के लिए क्षेत्र स्कैन शुरू करें';

  @override
  String get fieldScan => 'क्षेत्र स्कैन';

  @override
  String get loadingModel => 'मॉडल लोड हो रहा है...';

  @override
  String get selectImageSource => 'छवि स्रोत चुनें';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get startSpray => 'स्प्रे शुरू करें';

  @override
  String get stopSpray => 'स्प्रे रोकें';

  @override
  String get scheduleSpray => 'स्प्रे शेड्यूल करें';

  @override
  String get environmentalConditions => 'पर्यावरणीय स्थितियां';

  @override
  String get humidity => 'आर्द्रता';

  @override
  String get soilCondition => 'मिट्टी की स्थिति';

  @override
  String get optimal => 'अनुकूल';

  @override
  String get overallInfectionLevel => 'कुल संक्रमण स्तर';

  @override
  String get cropStatus => 'फसल स्थिति';

  @override
  String get healthy => 'स्वस्थ';

  @override
  String get unhealthy => 'अस्वस्थ';

  @override
  String get treatmentRecommendations => 'उपचार सिफारिशें';

  @override
  String get basedOnCurrentInfection => 'वर्तमान संक्रमण स्तर के आधार पर:';

  @override
  String get applyHighDosagePesticide =>
      'उच्च-खुराक लक्षित कीटनाशक का छिड़काव करें';

  @override
  String get inspectAndMonitorDaily =>
      'फैलाव के लिए रोज़ाना जांच करें; 24 घंटे में पुनः-स्कैन करें';

  @override
  String get removeAffectedLeaves =>
      'गंभीर रूप से प्रभावित पत्तियों को हटाएं; बीमार पौधों को अलग करें';

  @override
  String get startingPesticideSpray => 'कीटनाशक स्प्रे शुरू हो रहा है...';

  @override
  String get stoppingPesticideSpray => 'कीटनाशक स्प्रे रुक रहा है...';

  @override
  String get openingSpraySchedule => 'स्प्रे शेड्यूल खोल रहे हैं...';

  @override
  String rateLimitedMessage(Object seconds) {
    return 'रेट सीमित। कृपया $seconds सेकंड प्रतीक्षा करें...';
  }

  @override
  String get analyzingMessage => 'विश्लेषण कर रहे हैं...';

  @override
  String rateLimitedRetryMessage(
    Object seconds,
    Object attempt,
    Object maxRetries,
  ) {
    return 'रेट सीमित। $seconds सेकंड में पुनः प्रयास कर रहे हैं... ($attempt/$maxRetries)';
  }

  @override
  String analysisCompleteMessage(Object disease) {
    return 'विश्लेषण पूरा: $disease';
  }

  @override
  String analysisFailedMessage(Object error) {
    return 'विश्लेषण विफल: $error';
  }

  @override
  String get unknownDiseaseDetected => 'अज्ञात रोग का पता चला';

  @override
  String get couldNotParseAIResponse => 'AI प्रतिक्रिया पार्स नहीं हो सकी';

  @override
  String get notAnalyzed => 'विश्लेषण नहीं किया गया';

  @override
  String get lowSeverity => 'कम';

  @override
  String get mediumSeverity => 'मध्यम';

  @override
  String get highSeverity => 'उच्च';

  @override
  String applyPesticideFormat(
    Object pesticide,
    Object dosage,
    Object frequency,
  ) {
    return '$pesticide को $dosage पर, $frequency।';
  }

  @override
  String get detected => 'पता चला';

  @override
  String get pleaseWaitBeforeScanning =>
      'कृपया स्कैन करने से पहले प्रतीक्षा करें';

  @override
  String get invalidImageMessage =>
      'अपलोड की गई छवि फसल के पत्ते जैसी नहीं लगती। कृपया पत्ते या फसल की स्पष्ट छवि अपलोड करें।';

  @override
  String get tryAgain => 'फिर से प्रयास करें';
}
