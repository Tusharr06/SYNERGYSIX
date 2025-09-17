import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'zone_division_utils.dart';

class FarmBoundaryScreen extends StatefulWidget {
  const FarmBoundaryScreen({super.key});

  @override
  _FarmBoundaryScreenState createState() => _FarmBoundaryScreenState();
}

class _FarmBoundaryScreenState extends State<FarmBoundaryScreen> {
  late GoogleMapController mapController;
  final List<LatLng> _boundaryPoints = [];
  final Set<Polygon> _polygons = {};
  final Set<Polygon> _zones = {};
  final Set<Circle> _diseaseCircles = {};
  final Set<Marker> _markers = {};
  
  double _area = 0.0;
  double _perimeter = 0.0;
  bool _isBoundaryComplete = false;
  bool _showZones = false;
  LatLng? _agroStickCenter;
  
  // Mock disease detection data (replace with real sensor data)
  final List<Map<String, dynamic>> _diseaseLocations = [
    {
      'position': LatLng(12.9718, 77.5950),
      'disease': 'Leaf Rust',
      'severity': 'Medium',
      'distance': 25.5,
      'angle': 45.0,
    },
    {
      'position': LatLng(12.9714, 77.5948),
      'disease': 'Brown Spot',
      'severity': 'Low',
      'distance': 18.2,
      'angle': 120.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
  }

  void _loadDiseaseData() {
    // Generate mock disease data if AgroStick center is available
    if (_agroStickCenter != null) {
      final mockDiseases = ZoneDivisionUtils.generateMockDiseaseData(
        _agroStickCenter!,
        3, // Number of diseases to generate
      );
      
      _diseaseLocations.clear();
      _diseaseLocations.addAll(mockDiseases);
    }
    
    // Add disease markers and circles
    for (int i = 0; i < _diseaseLocations.length; i++) {
      final disease = _diseaseLocations[i];
      final position = disease['position'] as LatLng;
      
      _markers.add(
        Marker(
          markerId: MarkerId('disease_$i'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: disease['disease'],
            snippet: 'Severity: ${disease['severity']}',
          ),
          onTap: () => _showDiseaseDetails(disease),
        ),
      );
      
      _diseaseCircles.add(
        Circle(
          circleId: CircleId('disease_circle_$i'),
          center: position,
          radius: 8.0, // 8 meters radius
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
    }
  }

  void _onMapTapped(LatLng point) {
    if (!_isBoundaryComplete) {
      setState(() {
        _boundaryPoints.add(point);
        _updatePolygon();
        _calculateAreaAndPerimeter();
      });
    }
  }

  void _updatePolygon() {
    _polygons.clear();
    if (_boundaryPoints.length > 3) {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId("farm_boundary"),
          points: _boundaryPoints,
          strokeWidth: 3,
          strokeColor: AppColors.primaryGreen,
          fillColor: AppColors.primaryGreen.withOpacity(0.2),
        ),
      );
    }
  }

  void _calculateAreaAndPerimeter() {
    if (_boundaryPoints.length > 3) {
      final mpCoords = _boundaryPoints
          .map((e) => mp.LatLng(e.latitude, e.longitude))
          .toList();
      
      _area = mp.SphericalUtil.computeArea(mpCoords).toDouble(); // in sq. meters
      _perimeter = mp.SphericalUtil.computeLength(mpCoords).toDouble(); // in meters
      
      // Set AgroStick center as centroid
      _agroStickCenter = _getCentroid(_boundaryPoints);
      
      // Add AgroStick marker
      if (_agroStickCenter != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('agro_stick'),
            position: _agroStickCenter!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(
              title: 'AgroStick Center',
              snippet: 'Reference point for disease detection',
            ),
          ),
        );
        
        // Generate zones
        _generateZones();
        
        // Reload disease data with new center
        _loadDiseaseData();
      }
    }
  }

  LatLng _getCentroid(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _generateZones() {
    if (_boundaryPoints.length > 3) {
      _zones.clear();
      final zones = ZoneDivisionUtils.divideIntoZones(_boundaryPoints, 3, 3);
      _zones.addAll(zones);
    }
  }

  void _toggleZones() {
    setState(() {
      _showZones = !_showZones;
    });
  }

  void _completeBoundary() {
    if (_boundaryPoints.length > 3) {
      setState(() {
        _isBoundaryComplete = true;
      });
      _saveFarmBoundary();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark at least 4 points to create a boundary'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetBoundary() {
    setState(() {
      _boundaryPoints.clear();
      _polygons.clear();
      _zones.clear();
      _diseaseCircles.clear();
      _markers.removeWhere((marker) => 
        marker.markerId.value == 'agro_stick' || 
        marker.markerId.value.startsWith('disease_'));
      _area = 0.0;
      _perimeter = 0.0;
      _isBoundaryComplete = false;
      _showZones = false;
      _agroStickCenter = null;
    });
  }

  void _saveFarmBoundary() async {
    try {
      await FirebaseFirestore.instance.collection('farms').add({
        'boundary_points': _boundaryPoints.map((p) => {
          'latitude': p.latitude,
          'longitude': p.longitude,
        }).toList(),
        'area': _area,
        'perimeter': _perimeter,
        'agro_stick_center': {
          'latitude': _agroStickCenter?.latitude,
          'longitude': _agroStickCenter?.longitude,
        },
        'created_at': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm boundary saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving boundary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDiseaseDetails(Map<String, dynamic> disease) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          disease['disease'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Severity: ${disease['severity']}'),
            Text('Distance: ${disease['distance']}m'),
            Text('Angle: ${disease['angle']}°'),
            const SizedBox(height: 16),
            const Text(
              'Recommended Treatment:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Apply fungicide spray'),
            const Text('• Monitor for 3 days'),
            const Text('• Re-inspect affected area'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToDisease(disease['position']),
            child: const Text('Navigate'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToDisease(LatLng position) async {
    // Open Google Maps navigation
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open navigation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Farm Boundary Mapping',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_isBoundaryComplete) ...[
            IconButton(
              icon: Icon(_showZones ? Icons.grid_off : Icons.grid_on),
              onPressed: _toggleZones,
              tooltip: _showZones ? 'Hide Zones' : 'Show Zones',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetBoundary,
              tooltip: 'Reset Boundary',
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(12.9716, 77.5946), // Example location
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            polygons: _showZones ? {..._polygons, ..._zones} : _polygons,
            circles: _diseaseCircles,
            markers: _markers,
            onTap: _onMapTapped,
            mapType: MapType.satellite,
          ),
          
          // Instructions overlay
          if (!_isBoundaryComplete)
            Positioned(
              top: 20,
              left: 20,
              right: _diseaseLocations.isNotEmpty ? 120 : 20, // Leave space for disease box
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Tap on the map to mark your farm boundary points. Tap "Complete" when finished.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          // Area and perimeter info
          if (_area > 0)
            Positioned(
              bottom: 120,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Farm Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Area: ${(_area / 10000).toStringAsFixed(2)} hectares',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      'Perimeter: ${_perimeter.toStringAsFixed(2)} meters',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    if (_agroStickCenter != null)
                      Text(
                        'AgroStick: ${_agroStickCenter!.latitude.toStringAsFixed(6)}, ${_agroStickCenter!.longitude.toStringAsFixed(6)}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          
          // Disease detection info
          if (_diseaseLocations.isNotEmpty)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${_diseaseLocations.length} Disease\nDetected',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_isBoundaryComplete
          ? FloatingActionButton.extended(
              onPressed: _completeBoundary,
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Complete',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
