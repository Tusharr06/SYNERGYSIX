import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:agro_stick/features/map/farm_boundary/farm_boundary_screen.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _demoSteps = [
    {
      'title': 'Welcome to AgroStick',
      'subtitle': 'Precision Agriculture Made Simple',
      'description': 'Transform your farming with AI-powered disease detection and precision mapping.',
      'icon': Icons.agriculture,
      'color': AppColors.primaryGreen,
    },
    {
      'title': 'Farm Boundary Mapping',
      'subtitle': 'Mark Your Field Boundaries',
      'description': 'Tap on the map to create your farm boundary. The system will automatically calculate area and divide into zones.',
      'icon': Icons.map,
      'color': Colors.blue,
    },
    {
      'title': 'AgroStick Integration',
      'subtitle': 'Center Point Reference',
      'description': 'AgroStick is placed at the center of your farm. It detects diseases and provides precise coordinates.',
      'icon': Icons.center_focus_strong,
      'color': Colors.orange,
    },
    {
      'title': 'Disease Detection',
      'subtitle': 'Real-time Monitoring',
      'description': 'Red markers show detected diseases with severity levels. Tap for detailed information and treatment recommendations.',
      'icon': Icons.warning,
      'color': Colors.red,
    },
    {
      'title': 'Navigation & Treatment',
      'subtitle': 'Guided Precision Spraying',
      'description': 'Get navigation guidance to disease locations and apply targeted treatments with precision.',
      'icon': Icons.navigation,
      'color': Colors.purple,
    },
  ];

  void _nextStep() {
    if (_currentStep < _demoSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _startDemo();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startDemo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmBoundaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _demoSteps.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _demoSteps[_currentStep]['color'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentStep + 1}/${_demoSteps.length}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _demoSteps.length,
                itemBuilder: (context, index) {
                  final step = _demoSteps[index];
                  return _buildStepContent(step, screenWidth, screenHeight);
                },
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _demoSteps[_currentStep]['color'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentStep == _demoSteps.length - 1 ? 'Start Demo' : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    Map<String, dynamic> step,
    double screenWidth,
    double screenHeight,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step['icon'],
              size: 60,
              color: step['color'],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            step['title'],
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            step['subtitle'],
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: step['color'],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            step['description'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Feature highlights
          if (_currentStep == 1) _buildFeatureHighlights([
            'Tap to mark boundary points',
            'Automatic area calculation',
            'Zone division (3x3 grid)',
            'Real-time polygon visualization',
          ]),
          
          if (_currentStep == 2) _buildFeatureHighlights([
            'Centroid calculation',
            'Reference point for sensors',
            'Coordinate system origin',
            'Distance and angle measurements',
          ]),
          
          if (_currentStep == 3) _buildFeatureHighlights([
            'AI-powered disease detection',
            'Severity level classification',
            'Real-time monitoring',
            'Treatment recommendations',
          ]),
          
          if (_currentStep == 4) _buildFeatureHighlights([
            'GPS navigation integration',
            'Precision spraying guidance',
            'Distance and direction info',
            'Treatment scheduling',
          ]),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(List<String> features) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
