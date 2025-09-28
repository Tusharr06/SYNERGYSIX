import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class ZoneDivisionUtils {
  /// NEW: Divides a farm polygon into zones based on area calculation
  /// 1 acre = 9 zones, 2 acres = 18 zones, etc.
  /// Each zone gets a blue marker at its center
  static Map<String, dynamic> divideIntoZonesByArea(
    List<LatLng> boundaryPoints,
  ) {
    if (boundaryPoints.length < 4) return {'zones': <Polygon>[], 'markers': <Marker>[], 'visitedZones': <String>{}};

    // Calculate farm area in acres
    final double areaInSquareMeters = _calculatePolygonArea(boundaryPoints);
    final double areaInAcres = areaInSquareMeters / 4046.86; // Convert to acres
    
    // Calculate number of zones: 9 zones per acre (minimum 9 zones)
    final int totalZones = math.max(9, (areaInAcres * 9).round());
    
    // Calculate grid dimensions for optimal zone distribution
    final gridDimensions = _calculateOptimalGrid(totalZones);
    final int gridRows = gridDimensions['rows']!;
    final int gridCols = gridDimensions['cols']!;

    // Get bounding box of the polygon
    final bounds = _getBoundingBox(boundaryPoints);
    
    // Calculate grid cell dimensions
    final latStep = (bounds['maxLat']! - bounds['minLat']!) / gridRows;
    final lngStep = (bounds['maxLng']! - bounds['minLng']!) / gridCols;
    
    List<Polygon> zones = [];
    List<Marker> zoneMarkers = [];
    Set<String> visitedZones = {}; // Track visited zones
    
    int zoneIndex = 0;
    
    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {
        // Calculate zone corners
        final topLeft = LatLng(
          bounds['minLat']! + (row * latStep),
          bounds['minLng']! + (col * lngStep),
        );
        final topRight = LatLng(
          bounds['minLat']! + (row * latStep),
          bounds['minLng']! + ((col + 1) * lngStep),
        );
        final bottomLeft = LatLng(
          bounds['minLat']! + ((row + 1) * latStep),
          bounds['minLng']! + (col * lngStep),
        );
        final bottomRight = LatLng(
          bounds['minLat']! + ((row + 1) * latStep),
          bounds['minLng']! + ((col + 1) * lngStep),
        );
        
        // Create zone polygon points
        final zonePoints = [topLeft, topRight, bottomRight, bottomLeft];
        
        // Check if zone center is inside the farm boundary
        final zoneCenter = _getCentroid(zonePoints);
        if (_isPointInPolygon(zoneCenter, boundaryPoints)) {
          final zoneId = 'zone_${row}_$col';
          
          // Create zone polygon (initially transparent, will be colored when visited)
          zones.add(
            Polygon(
              polygonId: PolygonId(zoneId),
              points: zonePoints,
              strokeWidth: 2,
              strokeColor: Colors.blue.withOpacity(0.7),
              fillColor: Colors.transparent, // Initially transparent
            ),
          );
          
          // Create blue marker at zone center
          zoneMarkers.add(
            Marker(
              markerId: MarkerId('zone_marker_$zoneIndex'),
              position: zoneCenter,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: 'Zone ${zoneIndex + 1}',
                snippet: 'Tap to mark as visited',
              ),
            ),
          );
          
          zoneIndex++;
        }
      }
    }
    
    return {
      'zones': zones,
      'markers': zoneMarkers,
      'visitedZones': visitedZones,
      'totalZones': zoneIndex,
      'areaInAcres': areaInAcres,
    };
  }

  /// NEW: Calculate optimal grid dimensions for given number of zones
  static Map<String, int> _calculateOptimalGrid(int totalZones) {
    // Find the best rectangular grid that accommodates all zones
    int bestRows = 1;
    int bestCols = totalZones;
    double bestRatio = double.infinity;
    
    for (int rows = 1; rows <= math.sqrt(totalZones).ceil(); rows++) {
      int cols = (totalZones / rows).ceil();
      if (rows * cols >= totalZones) {
        double ratio = math.max(rows / cols, cols / rows);
        if (ratio < bestRatio) {
          bestRatio = ratio;
          bestRows = rows;
          bestCols = cols;
        }
      }
    }
    
    return {'rows': bestRows, 'cols': bestCols};
  }

  /// NEW: Calculate polygon area using shoelace formula
  static double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0;
    
    double area = 0;
    int n = points.length;
    
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      
      // Convert to meters using approximate conversion
      double lat1 = points[i].latitude * (math.pi / 180);
      double lng1 = points[i].longitude * (math.pi / 180);
      double lat2 = points[j].latitude * (math.pi / 180);
      double lng2 = points[j].longitude * (math.pi / 180);
      
      area += (lng2 - lng1) * (2 + math.sin(lat1) + math.sin(lat2));
    }
    
    area = (area * 6378137 * 6378137 / 2).abs(); // Earth radius squared
    return area;
  }

  /// NEW: Update zone color when marked as visited
  static Polygon updateZoneAsVisited(Polygon zone) {
    return zone.copyWith(
      fillColorParam: Colors.green.withOpacity(0.6),
      strokeColorParam: Colors.green,
    );
  }

  /// NEW: Reset zone to unvisited state
  static Polygon resetZoneToUnvisited(Polygon zone) {
    return zone.copyWith(
      fillColorParam: Colors.transparent,
      strokeColorParam: Colors.blue.withOpacity(0.7),
    );
  }

  /// ORIGINAL: Divides a farm polygon into grid zones (kept for backward compatibility)
  static List<Polygon> divideIntoZones(
    List<LatLng> boundaryPoints,
    int gridRows,
    int gridCols,
  ) {
    if (boundaryPoints.length < 3) return [];

    // Get bounding box of the polygon
    final bounds = _getBoundingBox(boundaryPoints);
    
    // Calculate grid cell dimensions
    final latStep = (bounds['maxLat']! - bounds['minLat']!) / gridRows;
    final lngStep = (bounds['maxLng']! - bounds['minLng']!) / gridCols;
    
    List<Polygon> zones = [];
    
    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {
        // Calculate zone corners
        final topLeft = LatLng(
          bounds['minLat']! + (row * latStep),
          bounds['minLng']! + (col * lngStep),
        );
        final topRight = LatLng(
          bounds['minLat']! + (row * latStep),
          bounds['minLng']! + ((col + 1) * lngStep),
        );
        final bottomLeft = LatLng(
          bounds['minLat']! + ((row + 1) * latStep),
          bounds['minLng']! + (col * lngStep),
        );
        final bottomRight = LatLng(
          bounds['minLat']! + ((row + 1) * latStep),
          bounds['minLng']! + ((col + 1) * lngStep),
        );
        
        // Create zone polygon
        final zonePoints = [topLeft, topRight, bottomRight, bottomLeft];
        
        // Check if zone center is inside the farm boundary
        final zoneCenter = _getCentroid(zonePoints);
        if (_isPointInPolygon(zoneCenter, boundaryPoints)) {
          zones.add(
            Polygon(
              polygonId: PolygonId('zone_${row}_$col'),
              points: zonePoints,
              strokeWidth: 1,
              strokeColor: Colors.blue.withOpacity(0.7),
              fillColor: Colors.blue.withOpacity(0.1),
            ),
          );
        }
      }
    }
    
    return zones;
  }

  /// Gets the bounding box of a polygon
  static Map<String, double> _getBoundingBox(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (var point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    
    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  /// Calculates the centroid of a polygon
  static LatLng _getCentroid(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  /// Checks if a point is inside a polygon using ray casting algorithm
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    int n = polygon.length;
    
    for (int i = 0; i < n; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % n];
      
      if (p1.longitude > p2.longitude) {
        LatLng temp = p1;
        p1 = p2;
        p2 = temp;
      }
      
      if (point.longitude > p1.longitude && 
          point.longitude <= p2.longitude &&
          point.latitude <= p1.latitude + (p2.latitude - p1.latitude) * 
          (point.longitude - p1.longitude) / (p2.longitude - p1.longitude)) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }

  /// Converts distance and angle from AgroStick to GPS coordinates
  static LatLng convertPolarToGPS(
    LatLng center,
    double distanceMeters,
    double angleDegrees,
  ) {
    const double earthRadius = 6378137.0; // Earth radius in meters
    const double degreesToRadians = math.pi / 180.0;
    
    // Convert angle to radians
    double angleRadians = angleDegrees * degreesToRadians;
    
    // Calculate latitude offset
    double dLat = (distanceMeters * math.cos(angleRadians)) / earthRadius;
    
    // Calculate longitude offset
    double dLng = (distanceMeters * math.sin(angleRadians)) / 
                  (earthRadius * math.cos(center.latitude * degreesToRadians));
    
    // Convert back to degrees
    double newLat = center.latitude + dLat * (180.0 / math.pi);
    double newLng = center.longitude + dLng * (180.0 / math.pi);
    
    return LatLng(newLat, newLng);
  }

  /// Calculates distance between two GPS points in meters
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6378137.0; // Earth radius in meters
    const double degreesToRadians = math.pi / 180.0;
    
    double dLat = (point2.latitude - point1.latitude) * degreesToRadians;
    double dLng = (point2.longitude - point1.longitude) * degreesToRadians;
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
               math.cos(point1.latitude * degreesToRadians) *
               math.cos(point2.latitude * degreesToRadians) *
               math.sin(dLng / 2) * math.sin(dLng / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calculates bearing from one point to another
  static double calculateBearing(LatLng from, LatLng to) {
    const double degreesToRadians = math.pi / 180.0;
    const double radiansToDegrees = 180.0 / math.pi;
    
    double dLng = (to.longitude - from.longitude) * degreesToRadians;
    
    double y = math.sin(dLng) * math.cos(to.latitude * degreesToRadians);
    double x = math.cos(from.latitude * degreesToRadians) *
               math.sin(to.latitude * degreesToRadians) -
               math.sin(from.latitude * degreesToRadians) *
               math.cos(to.latitude * degreesToRadians) *
               math.cos(dLng);
    
    double bearing = math.atan2(y, x) * radiansToDegrees;
    
    // Normalize to 0-360 degrees
    return (bearing + 360) % 360;
  }

  /// Generates mock disease detection data for demo
  static List<Map<String, dynamic>> generateMockDiseaseData(
    LatLng agroStickCenter,
    int numberOfDiseases,
  ) {
    List<Map<String, dynamic>> diseases = [];
    final random = math.Random();
    
    final diseaseTypes = ['Leaf Rust', 'Brown Spot', 'Powdery Mildew', 'Blight'];
    final severities = ['Low', 'Medium', 'High'];
    
    for (int i = 0; i < numberOfDiseases; i++) {
      // Generate random distance (5-50 meters) and angle (0-360 degrees)
      double distance = 5 + random.nextDouble() * 45;
      double angle = random.nextDouble() * 360;
      
      // Convert to GPS coordinates
      LatLng position = convertPolarToGPS(agroStickCenter, distance, angle);
      
      diseases.add({
        'position': position,
        'disease': diseaseTypes[random.nextInt(diseaseTypes.length)],
        'severity': severities[random.nextInt(severities.length)],
        'distance': distance,
        'angle': angle,
        'confidence': 0.7 + random.nextDouble() * 0.3, // 70-100% confidence
        'detected_at': DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      });
    }
    
    return diseases;
  }

  /// Creates heatmap data for disease visualization
  static List<Map<String, dynamic>> createHeatmapData(
    List<Map<String, dynamic>> diseases,
  ) {
    return diseases.map((disease) {
      return {
        'latitude': disease['position'].latitude,
        'longitude': disease['position'].longitude,
        'weight': _getSeverityWeight(disease['severity']),
      };
    }).toList();
  }

  /// Converts severity level to heatmap weight
  static double _getSeverityWeight(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return 0.3;
      case 'medium':
        return 0.6;
      case 'high':
        return 1.0;
      default:
        return 0.5;
    }
  }
}
