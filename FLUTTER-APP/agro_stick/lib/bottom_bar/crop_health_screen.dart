import 'package:agro_stick/features/map/farm_boundary/farmbound2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:agro_stick/features/map/farm_boundary/farm_boundary_screen.dart';
import 'package:agro_stick/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../secrets.dart'; // Import secrets

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});

  @override
  _CropHealthScreenState createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  // Dynamic data - initially empty
  String cropStatus = ""; // Initially empty
  double _infectionPercentage = 0.0; // Initially 0
  String _humidity = '65%';
  String _soilMoisture = 'optimal';
  List<Map<String, dynamic>> diseaseAlerts = [];

  // AI response variables
  int? _infectionLevel;
  String? _diseaseName;
  String? _pesticideName;
  String? _dosage;
  String? _frequency;
  String? _precautions;
  bool _isAnalyzing = false;
  bool _isRateLimited = false;
  String _selectedLanguage = 'en'; // Default English

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _rateLimitDelay = Duration(seconds: 10); // Increased for safety
  static const int _maxRetries = 3;
  int _retryCount = 0;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Scan result
  String? _scanResult;
  XFile? _lastImage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _getLanguageFromProfile();
  }

  // Get language from profile/settings
  String _getLanguageFromProfile() {
    // TODO: Implement language retrieval from shared preferences or profile
    return 'en';
  }

  // Rate limiting helper
  Future<bool> _checkRateLimit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    if (_lastRequestTime == null) {
      _lastRequestTime = DateTime.now();
      debugPrint("Rate limit: First request, proceeding.");
      return true;
    }

    final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
    debugPrint("Time since last request: ${timeSinceLastRequest.inSeconds} seconds");
    if (timeSinceLastRequest < _rateLimitDelay) {
      final waitTime = _rateLimitDelay - timeSinceLastRequest;
      debugPrint("Rate limit hit, waiting for ${waitTime.inSeconds} seconds");
      if (mounted) {
        setState(() {
          _isRateLimited = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.rateLimitedMessage(waitTime.inSeconds)),
            duration: waitTime,
          ),
        );
        await Future.delayed(waitTime);
        if (mounted) {
          setState(() {
            _isRateLimited = false;
          });
        }
      }
      return false;
    }

    _lastRequestTime = DateTime.now();
    debugPrint("Rate limit: Cleared, proceeding.");
    return true;
  }

  Widget dataCard(
      String title, String value, Color color, IconData icon, double screenWidth, AppLocalizations t) {
    return Container(
      width: (screenWidth - 60) / 2,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.08),
          SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _startSpray(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.startingPesticideSpray)),
        );
      });
    }
  }

  void _stopSpray(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.stoppingPesticideSpray)),
        );
      });
    }
  }

  void _scheduleSpray(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.openingSpraySchedule)),
    );
  }

  void _openFarmMapping() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmBoundaryScreen2(),
      ),
    );
  }

  Future<Map<String, dynamic>?> _makeApiRequest(
    String base64Image,
    String language, {
    int retryCount = 0,
  }) async {
    if (retryCount > 0 && mounted) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
         content: Text('Retry attempt: $retryCount'),

          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      String prompt = """
You are an expert plant pathologist and agricultural advisor.

Analyze the uploaded plant leaf image and provide:
1. Verify if the image contains a plant leaf relevant to crops.
   - If it is not a leaf or is unrelated, respond with a clear message to the user like: 
     "The uploaded image does not appear to be a crop leaf. Please upload a clear image of the leaf or crop."
2. If it is a valid leaf, provide:
   - Infection level on a scale of 1 (healthy) to 5 (severely infected)
   - Type of infection/disease
   - Pesticide recommendation including:
     - Name
     - Dosage per hectare
     - Application frequency
     - Safety precautions

Always respond in JSON format like:

{
  "valid_leaf": true,
  "infection_level": 3,
  "disease_name": "Early Blight",
  "pesticide": {
    "name": "Mancozeb",
    "dosage": "2.5 kg/ha",
    "frequency": "Every 10 days",
    "precautions": "Wear gloves and mask"
  },
  "message": "Optional guidance message for the user"
}
""";

      if (language != 'en') {
        final languageMap = {'hi': 'Hindi', 'pa': 'Punjabi'};
        final targetLanguage = languageMap[language] ?? 'English';
        prompt = """
First, provide the analysis in English JSON format as specified.
Then, translate the disease name, pesticide name, dosage, frequency, precautions, and user message to $targetLanguage.

Respond with:
1. JSON analysis (in English)
2. TRANSLATED_RESPONSE: [translated disease name, recommendations, and message in $targetLanguage]
""";
      }

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey',
      );

      final headers = {'Content-Type': 'application/json'};

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ]
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty &&
            jsonResponse['candidates'][0]['content']['parts'][0]['text'] != null) {
          final rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          debugPrint("Gemini raw response: $rawText");

          try {
            // Clean the response by removing ```json and ``` markers
            String cleanedText = rawText
                .replaceAll(RegExp(r'^```json\s*|\s*```$', multiLine: true), '')
                .trim();
            final parsedJson = jsonDecode(cleanedText);

            // Validate that parsedJson is a Map
            if (parsedJson is Map<String, dynamic>) {
              return parsedJson;
            } else {
              throw Exception("Parsed response is not a valid JSON object");
            }
          } catch (e) {
            debugPrint("Error parsing JSON: $e");
            return {
              "valid_leaf": false,
              "message": "Could not parse AI response. Please try again."
            };
          }
        } else {
          throw Exception("Invalid API response structure: ${response.body}");
        }
      } else {
        debugPrint("API error ${response.statusCode}: ${response.body}");
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception in _makeApiRequest: $e");

      // Retry with backoff
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
        return _makeApiRequest(base64Image, language, retryCount: retryCount + 1);
      }
      return {
        "valid_leaf": false,
        "message": "Failed after multiple attempts. Please try again later."
      };
    }
  }

  Future<void> _runInferenceOnImage(XFile imageFile, AppLocalizations t) async {
    // Check rate limit first
    final canProceed = await _checkRateLimit(context);
    if (!canProceed) return;

    if (mounted) {
      setState(() {
        _isAnalyzing = true;
        _scanResult = null;
        _retryCount = 0;
        // Reset analysis data
        _infectionLevel = null;
        _diseaseName = null;
        _pesticideName = null;
        _dosage = null;
        _frequency = null;
        _precautions = null;
        cropStatus = "";
        _infectionPercentage = 0.0;
        diseaseAlerts = [];
      });
    }

    try {
      final bytes = await File(imageFile.path).readAsBytes();
      String base64Image = base64Encode(bytes);

      // Additional safety delay
      await Future.delayed(const Duration(milliseconds: 500));

      final parsedJson = await _makeApiRequest(base64Image, _selectedLanguage, retryCount: _retryCount);

      if (parsedJson != null && mounted) {
        // Check if the image contains a valid leaf
        final bool isValidLeaf = parsedJson['valid_leaf'] ?? false;
        final String? message = parsedJson['message'];

        if (!isValidLeaf) {
          // Invalid image - show error message
          if (mounted) {
            setState(() {
              _scanResult = message ?? t.invalidImageMessage;
              _lastImage = imageFile;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message ?? t.invalidImageMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: t.tryAgain,
                textColor: Colors.white,
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _scanResult = null;
                      _lastImage = null;
                    });
                  }
                },
              ),
            ),
          );
        } else {
          // Valid leaf - process analysis
          if (mounted) {
            setState(() {
              _infectionLevel = parsedJson['infection_level'] as int?;
              _diseaseName = parsedJson['disease_name'] as String? ?? parsedJson['translated_disease'] as String?;
              _pesticideName = parsedJson['pesticide']?['name'] as String? ?? parsedJson['translated_pesticide'] as String?;
              _dosage = parsedJson['pesticide']?['dosage'] as String?;
              _frequency = parsedJson['pesticide']?['frequency'] as String?;
              _precautions = parsedJson['pesticide']?['precautions'] as String?;

              // Prioritize translated fields for scan result
              _scanResult = parsedJson['translated_response'] as String? ??
                  parsedJson['translated_message'] as String? ??
                  parsedJson['translated_disease'] as String? ??
                  (_diseaseName ?? t.unknownDiseaseDetected);

              _lastImage = imageFile;

              // Only update crop status if infection level is valid
              if (_infectionLevel != null && _infectionLevel! >= 1 && _infectionLevel! <= 5) {
                cropStatus = (_infectionLevel! <= 2) ? "healthy" : "unhealthy";
                _infectionPercentage = _infectionLevel! / 5.0;
                diseaseAlerts = [
                  {
                    "name": _diseaseName ?? t.unknownDiseaseDetected,
                    "severity": _levelToSeverity(_infectionLevel!, t)
                  },
                ];
              } else {
                cropStatus = "";
                _infectionPercentage = 0.0;
                diseaseAlerts = [];
              }
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.analysisCompleteMessage(_diseaseName ?? t.unknownDiseaseDetected)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (mounted) {
        setState(() {
          _scanResult = t.couldNotParseAIResponse;
          _lastImage = imageFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.couldNotParseAIResponse),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanResult = t.analysisFailedMessage(e.toString());
          _lastImage = imageFile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.analysisFailedMessage(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  String _levelToSeverity(int level, AppLocalizations t) {
    if (level <= 2) return t.lowSeverity;
    if (level == 3) return t.mediumSeverity;
    return t.highSeverity;
  }

  void _scanField(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_isRateLimited || _isAnalyzing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.pleaseWaitBeforeScanning),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            t.selectImageSource,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text(
                  t.camera,
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    await _runInferenceOnImage(image, t);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: Text(
                  t.gallery,
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    await _runInferenceOnImage(image, t);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t.cancel,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(String statusKey, AppLocalizations t) {
    if (statusKey.isEmpty) return t.notAnalyzed;
    switch (statusKey) {
      case 'healthy':
        return t.healthy;
      case 'unhealthy':
        return t.unhealthy;
      case 'optimal':
        return t.optimal;
      default:
        return statusKey;
    }
  }

  Color _getStatusColor(String statusKey) {
    if (statusKey.isEmpty) return Colors.grey;
    switch (statusKey) {
      case 'healthy':
        return Colors.green;
      case 'unhealthy':
        return Colors.red;
      default:
        return Colors.brown;
    }
  }

  IconData _getStatusIcon(String statusKey) {
    if (statusKey.isEmpty) return Icons.help_outline;
    switch (statusKey) {
      case 'healthy':
        return Icons.check_circle;
      case 'unhealthy':
        return Icons.warning;
      default:
        return Icons.grass;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 0.3) {
      return Colors.green;
    } else if (percentage <= 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cropStatusText = _getStatusText(cropStatus, t);
    final soilMoistureText = _getStatusText(_soilMoisture, t);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          t.cropHealth,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Farm Mapping Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, color: AppColors.primaryGreen, size: 24),
                      SizedBox(width: 8),
                      Text(
                        t.farmMapping,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    t.farmMappingDescription,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openFarmMapping,
                      icon: Icon(Icons.map, size: 20),
                      label: Text(
                        t.openFarmMapping,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, screenHeight * 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // 2. Scan Field Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt, color: AppColors.primaryGreen, size: 24),
                      SizedBox(width: 8),
                      Text(
                        t.scanField,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    t.scanFieldDescription,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isAnalyzing || _isRateLimited) ? null : () => _scanField(context),
                      icon: _isAnalyzing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.camera_alt, size: 20),
                      label: Text(
                        _isAnalyzing
                            ? t.analyzingMessage
                            : (_isRateLimited ? t.rateLimitedMessage(2) : t.fieldScan),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isAnalyzing || _isRateLimited)
                            ? AppColors.primaryGreen.withOpacity(0.5)
                            : AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, screenHeight * 0.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_lastImage != null || _scanResult != null) ...[
                    const SizedBox(height: 12),
                    if (_lastImage != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_lastImage!.path),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (_scanResult != null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: (_infectionLevel != null)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (_infectionLevel != null)
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _scanResult!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: (_infectionLevel != null)
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // 3. Quick Actions
            Text(
              t.quickActions,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _startSpray(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: Size(screenWidth * 0.42, screenHeight * 0.07),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 20, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        t.startSpray,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _stopSpray(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(screenWidth * 0.42, screenHeight * 0.07),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop, size: 20, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        t.stopSpray,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: () => _scheduleSpray(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, screenHeight * 0.07),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    t.scheduleSpray,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // 4. Humidity and Soil Condition Cards
            Text(
              t.environmentalConditions,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 15,
              children: [
                dataCard(t.humidity, _humidity, Colors.blue, Icons.water_drop, screenWidth, t),
                dataCard(t.soilCondition, soilMoistureText, Colors.brown, Icons.grass, screenWidth, t),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),

            // 5. Overall Infection Level - Only show after valid analysis
            if (cropStatus.isNotEmpty && _infectionLevel != null) ...[
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.overallInfectionLevel,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: _infectionPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(_infectionPercentage),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0%',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${(_infectionPercentage * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(_infectionPercentage),
                          ),
                        ),
                        Text(
                          '100%',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],

            // 6. Crop Status - Only show after valid analysis
            if (cropStatus.isNotEmpty && _infectionLevel != null) ...[
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.cropStatus,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          cropStatusText,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(cropStatus),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _getStatusIcon(cropStatus),
                      color: _getStatusColor(cropStatus),
                      size: 40,
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],

            // 7. Treatment Recommendations - Only show after valid analysis
            if (cropStatus.isNotEmpty && _pesticideName != null && _dosage != null && _frequency != null) ...[
              Text(
                t.treatmentRecommendations,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.basedOnCurrentInfection,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: AppColors.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.applyPesticideFormat(_pesticideName!, _dosage!, _frequency!),
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_precautions != null) ...[
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Precautions: $_precautions',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ] else if (cropStatus.isNotEmpty && _infectionLevel != null) ...[
              // Show generic recommendations when analysis is done but pesticide info is missing
              Text(
                t.treatmentRecommendations,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.basedOnCurrentInfection,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.inspectAndMonitorDaily,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ],
        ),
      ),
    );
  }
}