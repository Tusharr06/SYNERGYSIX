import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'zone_division_utils.dart';
import 'package:location/location.dart' as loc;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui; // Added for screenshot functionality
import 'package:flutter/rendering.dart'; // Added for RepaintBoundary

class FarmBoundaryScreen2 extends StatefulWidget {
  const FarmBoundaryScreen2({super.key});

  @override
  _FarmBoundaryScreenState2 createState() => _FarmBoundaryScreenState2();
}

class _FarmBoundaryScreenState2 extends State<FarmBoundaryScreen2> {
  late GoogleMapController mapController;
  bool _mapReady = false;
  final List<LatLng> _boundaryPoints = [];
  final Set<Polygon> _polygons = {};
  final Set<Polygon> _zones = {};
  final Set<Circle> _diseaseCircles = {};
  final Set<Marker> _markers = {};
  final loc.Location _location = loc.Location();
  LatLng? _currentLatLng;
  
  // Toggle mock disease visuals (red markers/circles)
  final bool _showDiseaseMock = false;
  
  double _area = 0.0;
  double _perimeter = 0.0;
  bool _isBoundaryComplete = false;
  bool _showZones = false;
  LatLng? _agroStickCenter;
  
  // NEW: Screenshot functionality variables
  final GlobalKey _mapKey = GlobalKey(); // Key for RepaintBoundary around the map
  Uint8List? _farmScreenshot; // Stores the captured screenshot
  bool _isCapturingScreenshot = false; // Loading state for screenshot capture
  
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
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted &&
            permissionGranted != loc.PermissionStatus.grantedLimited) {
          return;
        }
      }

      final current = await _location.getLocation();
      if (current.latitude != null && current.longitude != null) {
        _currentLatLng = LatLng(current.latitude!, current.longitude!);
        if (_mapReady) {
          // Move camera to current location
          await mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentLatLng!, zoom: 17),
            ),
          );
        }
      }
    } catch (_) {
      // Ignore errors; map will use default position
    }
    if (mounted) setState(() {});
  }

  void _loadDiseaseData() {
    // Always clear any existing disease visuals first
    _markers.removeWhere((m) => m.markerId.value.startsWith('disease_'));
    _diseaseCircles.clear();
    // Generate mock disease data if AgroStick center is available
    if (_agroStickCenter != null) {
      final mockDiseases = ZoneDivisionUtils.generateMockDiseaseData(
        _agroStickCenter!,
        3, // Number of diseases to generate
      );
      
      _diseaseLocations.clear();
      _diseaseLocations.addAll(mockDiseases);
    }
    
    if (_showDiseaseMock) {
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
    // UPDATED: Changed condition to require at least 4 points as per requirements
    if (_boundaryPoints.length >= 4) {
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
    // UPDATED: Changed condition to require at least 4 points
    if (_boundaryPoints.length >= 4) {
      final mpCoords = _boundaryPoints
          .map((e) => mp.LatLng(e.latitude, e.longitude))
          .toList();
      
      _area = mp.SphericalUtil.computeArea(mpCoords).toDouble(); // in sq. meters
      _perimeter = mp.SphericalUtil.computeLength(mpCoords).toDouble(); // in meters
      
      // Set AgroStick center as centroid
      _agroStickCenter = _getCentroid(_boundaryPoints);
      
      // Center computed; generate zones and place zone center markers
      if (_agroStickCenter != null) {
        // Generate zones
        _generateZones();
        
        // Reload disease data with new center
        _loadDiseaseData();

        // Add exactly 3 random red markers inside the selected farm
        _addRandomDiseaseMarkers(3);
      }
    }
  }

  void _addRandomDiseaseMarkers(int count) {
    // Remove any previous disease markers/circles
    _markers.removeWhere((m) => m.markerId.value.startsWith('disease_'));
    _diseaseCircles.clear();

    // UPDATED: Changed condition to require at least 4 points
    if (_boundaryPoints.length < 4) {
      setState(() {});
      return;
    }

    // Bounding box for sampling
    double minLat = _boundaryPoints.first.latitude;
    double maxLat = _boundaryPoints.first.latitude;
    double minLng = _boundaryPoints.first.longitude;
    double maxLng = _boundaryPoints.first.longitude;
    for (final p in _boundaryPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final rng = math.Random();
    int placed = 0;
    int attempts = 0;
    final polygon = _boundaryPoints
        .map((e) => mp.LatLng(e.latitude, e.longitude))
        .toList();

    while (placed < count && attempts < 1000) {
      attempts++;
      final lat = minLat + rng.nextDouble() * (maxLat - minLat);
      final lng = minLng + rng.nextDouble() * (maxLng - minLng);
      final candidate = mp.LatLng(lat, lng);

      final inside = mp.PolygonUtil.containsLocation(candidate, polygon, true);
      if (!inside) continue;

      final marker = Marker(
        markerId: MarkerId('disease_$placed'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Detected Issue'),
      );
      _markers.add(marker);
      placed++;
    }

    setState(() {});
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
    // UPDATED: Changed condition to require at least 4 points
    if (_boundaryPoints.length >= 4) {
      _zones.clear();
      final zones = ZoneDivisionUtils.divideIntoZones(_boundaryPoints, 3, 3);
      _zones.addAll(zones);
      _placeZoneCenterMarkers();
    }
  }

  void _placeZoneCenterMarkers() {
    // Remove previous zone markers
    _markers.removeWhere((m) => m.markerId.value.startsWith('zone_'));
    int i = 0;
    for (final polygon in _zones) {
      if (polygon.points.isNotEmpty) {
        final center = _getCentroid(polygon.points);
        _markers.add(
          Marker(
            markerId: MarkerId('zone_$i'),
            position: center,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Zone Center'),
          ),
        );
        i++;
      }
    }
    setState(() {});
  }

  void _toggleZones() {
    setState(() {
      _showZones = !_showZones;
    });
  }

  void _completeBoundary() {
    // UPDATED: Changed validation to require at least 4 points as per requirements
    if (_boundaryPoints.length >= 4) {
      setState(() {
        _isBoundaryComplete = true;
      });
      _saveFarmBoundary();
      // NEW: Automatically capture screenshot after completing boundary
      _captureMapScreenshot();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark at least 4 points to create a boundary'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Function to capture map screenshot
  Future<void> _captureMapScreenshot() async {
    try {
      setState(() {
        _isCapturingScreenshot = true;
      });

      // Wait a bit for UI to settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the RenderRepaintBoundary
      RenderRepaintBoundary? boundary = _mapKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        // Capture the image
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        
        if (byteData != null) {
          setState(() {
            _farmScreenshot = byteData.buffer.asUint8List();
            _isCapturingScreenshot = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm boundary screenshot captured!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCapturingScreenshot = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing screenshot: $e'),
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
        marker.markerId.value.startsWith('disease_') ||
        marker.markerId.value.startsWith('zone_'));
      _area = 0.0;
      _perimeter = 0.0;
      _isBoundaryComplete = false;
      _showZones = false;
      _agroStickCenter = null;
      // NEW: Clear screenshot when resetting boundary
      _farmScreenshot = null;
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
      body: Column(
        children: [
          // NEW: Map section with RepaintBoundary for screenshot capture
          Expanded(
            flex: _farmScreenshot != null ? 2 : 3, // Adjust flex based on whether screenshot exists
            child: Stack(
              children: [
                // NEW: RepaintBoundary wraps the map for screenshot functionality
                RepaintBoundary(
                  key: _mapKey,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(12.9716, 77.5946), // Example location
                      zoom: 16,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _mapReady = true;
                      if (_currentLatLng != null) {
                        mapController.moveCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: _currentLatLng!, zoom: 17),
                          ),
                        );
                      }
                    },
                    polygons: _showZones ? {..._polygons, ..._zones} : _polygons,
                    circles: _diseaseCircles,
                    markers: _markers,
                    onTap: _onMapTapped,
                    mapType: MapType.satellite,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
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
                        // UPDATED: Changed instruction text to reflect 4-5 points requirement
                        'Tap on the map to mark your farm boundary points (at least 4-5 points). Tap "Complete" when finished.',
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
                    bottom: 20,
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
                if (_showDiseaseMock && _diseaseLocations.isNotEmpty)
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

                // NEW: Loading overlay when capturing screenshot
                if (_isCapturingScreenshot)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Capturing Screenshot...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // NEW: Screenshot display section with "My Farm" heading
          if (_farmScreenshot != null)
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NEW: "My Farm" heading
                    Text(
                      'My Farm',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // NEW: Screenshot display
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _farmScreenshot!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
