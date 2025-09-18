import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:agro_stick/features/map/farm_boundary/farm_boundary_screen.dart';
import 'package:image_picker/image_picker.dart'; // Added for image picking
import 'dart:io';

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});

  @override
  _CropHealthScreenState createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  // Placeholder data
  String cropStatus = "Healthy";
  String _humidity = '65%';
  String _soilMoisture = 'Optimal';
  List<Map<String, dynamic>> diseaseAlerts = [
    {"name": "Leaf Rust", "severity": "Low"},
    {"name": "Brown Spot", "severity": "Medium"},
  ];

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  Widget dataCard(String title, String value, Color color, IconData icon, double screenWidth) {
    return Container(
      width: (screenWidth - 60) / 2, // 2 cards per row with spacing
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

  void _startSpray() {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting pesticide spray...')),
      );
    });
  }

  void _stopSpray() {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stopping pesticide spray...')),
      );
    });
  }

  void _scheduleSpray() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening spray schedule...')),
    );
  }

  void _openFarmMapping() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmBoundaryScreen(),
      ),
    );
  }

  // Updated _scanField to show dialog with camera and gallery options
  void _scanField() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Image Source',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text(
                  'Camera',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Image selected from camera: ${image.path}')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Image selected from gallery: ${image.path}')),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Crop Health',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold , color: Colors.white),

        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Status Card
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
                        'Crop Status',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        cropStatus,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: cropStatus == "Healthy"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    cropStatus == "Healthy" ? Icons.check_circle : Icons.warning,
                    color: cropStatus == "Healthy" ? Colors.green : Colors.red,
                    size: 40,
                  )
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Sensor Data Grid (2 per row)
            Wrap(
              spacing: 10,
              runSpacing: 15,
              children: [
                dataCard('Humidity', _humidity, Colors.blue, Icons.water_drop, screenWidth),
                dataCard('Soil Condition', _soilMoisture, Colors.brown, Icons.grass, screenWidth),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Infection Level Progress Indicator
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
                    'Overall Infection Level',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange.withOpacity(0.7),
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
                        '30%',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
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
            // Disease Alerts
            Text(
              'Disease Alerts',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            diseaseAlerts.isEmpty
                ? Text(
                    'No disease detected.',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  )
                : Column(
                    children: diseaseAlerts
                        .map((alert) => Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              margin: EdgeInsets.only(bottom: screenHeight * 0.015),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alert["name"],
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Detected on 2 plants',
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: alert["severity"] == "Low"
                                          ? Colors.green
                                          : alert["severity"] == "Medium"
                                              ? Colors.orange
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      alert["severity"],
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
            SizedBox(height: screenHeight * 0.03),
            // Treatment Recommendations
            Text(
              'Treatment Recommendations',
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
                    'Based on current infection level:',
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
                          'Apply low dosage pesticide spray (20% recommended)',
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
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Schedule next inspection in 3 days',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Farm Mapping Section
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
                        'Farm Mapping',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Map your farm boundary and detect disease locations with precision',
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
                        'Open Farm Mapping',
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
            // Scan Field Section
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
                      Icon(Icons.camera_alt, color: AppColors.primaryGreen, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Scan Field for Accurate Results',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Initiate a field scan to detect crop health issues with high accuracy',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanField,
                      icon: Icon(Icons.camera_alt, size: 20),
                      label: Text(
                        'Field Scan', // Changed from "Start Field Scan"
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
            SizedBox(height: screenHeight * 0.03),
            // Quick Actions
            Text(
              'Quick Actions',
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
                  onPressed: _startSpray,
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
                        'Start Spray',
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
                  onPressed: _stopSpray,
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
                        'Stop Spray',
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
              onPressed: _scheduleSpray,
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
                    'Schedule Spray',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}