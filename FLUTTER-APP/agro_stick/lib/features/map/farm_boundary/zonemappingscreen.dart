import 'package:agro_stick/features/map/farm_boundary/zonedivisionutilities.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart'; 
import 'package:location/location.dart' as loc;

class ZoneMappingScreen extends StatefulWidget {
  // NEW: Accept boundary points from farm boundary screen
  final List<LatLng>? boundaryPoints;
  
  const ZoneMappingScreen({
    super.key,
    this.boundaryPoints,
  });

  @override
  _ZoneMappingScreenState createState() => _ZoneMappingScreenState();
}

class _ZoneMappingScreenState extends State<ZoneMappingScreen> {
  late GoogleMapController mapController;
  bool _mapReady = false;
  
  // NEW: Dynamic boundary points and zone management
  List<LatLng> _boundaryPoints = [];
  final Set<Polygon> _farmBoundary = {};
  Set<Polygon> _zones = {};
  Set<Marker> _zoneMarkers = {};
  Set<String> _visitedZones = {}; // Track which zones have been visited
  
  final loc.Location _location = loc.Location();
  LatLng? _currentLatLng;
  
  // NEW: Zone statistics
  int _totalZones = 0;
  double _farmAreaInAcres = 0.0;
  
  @override
  void initState() {
    super.initState();
    // NEW: Initialize with provided boundary points or empty list
    if (widget.boundaryPoints != null) {
      _boundaryPoints = List.from(widget.boundaryPoints!);
      _generateFarmBoundaryAndZones();
    }
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

  // NEW: Allow users to create boundary by tapping if none provided
  void _onMapTapped(LatLng point) {
    if (_boundaryPoints.length < 4 || widget.boundaryPoints == null) {
      setState(() {
        _boundaryPoints.add(point);
        _updateFarmBoundary();
        // Generate zones when we have at least 4 points
        if (_boundaryPoints.length >= 4) {
          _generateFarmBoundaryAndZones();
        }
      });
    }
  }

  // NEW: Update farm boundary polygon display
  void _updateFarmBoundary() {
    _farmBoundary.clear();
    if (_boundaryPoints.length >= 4) {
      _farmBoundary.add(
        Polygon(
          polygonId: const PolygonId("farm_boundary"),
          points: _boundaryPoints,
          strokeWidth: 3,
          strokeColor: AppColors.primaryGreen,
          fillColor: AppColors.primaryGreen.withOpacity(0.1),
        ),
      );
    }
  }

  // NEW: Generate zones based on farm area calculation
  void _generateFarmBoundaryAndZones() {
    if (_boundaryPoints.length < 4) return;
    
    // Update farm boundary display
    _updateFarmBoundary();
    
    // Generate zones using the new area-based method
    final zoneData = ZoneDivisionUtils.divideIntoZonesByArea(_boundaryPoints);
    
    setState(() {
      _zones = Set.from(zoneData['zones'] as List<Polygon>);
      _zoneMarkers = Set.from(zoneData['markers'] as List<Marker>);
      _visitedZones = Set.from(zoneData['visitedZones'] as Set<String>);
      _totalZones = zoneData['totalZones'] as int;
      _farmAreaInAcres = zoneData['areaInAcres'] as double;
    });
  }

  // NEW: Handle zone marker tap to mark as visited
  void _onZoneMarkerTapped(String markerId) {
    // Extract zone index from marker ID
    final zoneIndex = markerId.replaceAll('zone_marker_', '');
    final zoneId = 'zone_visited_$zoneIndex';
    
    setState(() {
      if (_visitedZones.contains(zoneId)) {
        // Unmark as visited
        _visitedZones.remove(zoneId);
        // Reset zone color to unvisited
        _zones = _zones.map((zone) {
          if (zone.polygonId.value.contains(zoneIndex)) {
            return ZoneDivisionUtils.resetZoneToUnvisited(zone);
          }
          return zone;
        }).toSet();
      } else {
        // Mark as visited
        _visitedZones.add(zoneId);
        // Update zone color to green
        _zones = _zones.map((zone) {
          if (zone.polygonId.value.contains(zoneIndex)) {
            return ZoneDivisionUtils.updateZoneAsVisited(zone);
          }
          return zone;
        }).toSet();
      }
    });
    
    // Show feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _visitedZones.contains(zoneId) 
            ? 'Zone ${int.parse(zoneIndex) + 1} marked as visited!'
            : 'Zone ${int.parse(zoneIndex) + 1} marked as pending',
        ),
        backgroundColor: _visitedZones.contains(zoneId) ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // NEW: Reset all visited zones
  void _resetVisitedZones() {
    setState(() {
      _visitedZones.clear();
      // Reset all zones to unvisited color
      _zones = _zones.map((zone) {
        return ZoneDivisionUtils.resetZoneToUnvisited(zone);
      }).toSet();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All zones reset to pending status'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // NEW: Clear boundary and start over
  void _clearBoundary() {
    setState(() {
      _boundaryPoints.clear();
      _farmBoundary.clear();
      _zones.clear();
      _zoneMarkers.clear();
      _visitedZones.clear();
      _totalZones = 0;
      _farmAreaInAcres = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Calculate completion percentage for progress display
    final completionPercentage = _totalZones > 0 
        ? (_visitedZones.length / _totalZones * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Zone Mapping',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_totalZones > 0) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetVisitedZones,
              tooltip: 'Reset All Zones',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearBoundary,
              tooltip: 'Clear Boundary',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // NEW: Farm statistics header
          if (_totalZones > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_farmAreaInAcres.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'Acres',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_totalZones',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'Total Zones',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_visitedZones.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$completionPercentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Map section
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
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
                  polygons: {..._farmBoundary, ..._zones},
                  markers: _zoneMarkers.map((marker) {
                    // NEW: Make markers tappable to mark zones as visited
                    return marker.copyWith(
                      onTapParam: () => _onZoneMarkerTapped(marker.markerId.value),
                    );
                  }).toSet(),
                  onTap: _onMapTapped,
                  mapType: MapType.satellite,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                
                // NEW: Instructions overlay when no boundary exists
                if (_boundaryPoints.length < 4 && widget.boundaryPoints == null)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
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
                        'Tap on the map to mark at least 4 points to create your farm boundary. Zones will be automatically generated based on your farm area.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // NEW: Zone interaction instructions
                if (_totalZones > 0)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app, color: Colors.white, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'Tap blue markers\nto mark zones\nas visited',
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
          ),

          // NEW: Legend/Index at the bottom
          if (_totalZones > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zone Status Legend',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Completed zones indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.6),
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completed (${_visitedZones.length})',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(width: 24),
                      
                      // Pending zones indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.blue.withOpacity(0.7), width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pending (${_totalZones - _visitedZones.length})',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  
                  // NEW: Progress bar
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Progress: ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _totalZones > 0 ? _visitedZones.length / _totalZones : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionPercentage == 100 ? Colors.green : Colors.blue,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$completionPercentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: completionPercentage == 100 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  // NEW: Completion message
                  if (completionPercentage == 100)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Congratulations! All zones completed!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
