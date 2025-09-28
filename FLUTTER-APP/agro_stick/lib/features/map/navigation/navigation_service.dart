import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agro_stick/features/map/farm_boundary/zone_division_utils.dart';

class NavigationService {
  /// Opens Google Maps navigation to a specific location
  static Future<void> navigateToLocation(LatLng destination) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      throw Exception('Could not open navigation: $e');
    }
  }

  /// Calculates and displays navigation guidance
  static Widget buildNavigationGuidance(
    LatLng currentLocation,
    LatLng targetLocation,
    String diseaseName,
    String severity,
  ) {
    final distance = ZoneDivisionUtils.calculateDistance(currentLocation, targetLocation);
    final bearing = ZoneDivisionUtils.calculateBearing(currentLocation, targetLocation);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.navigation, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Navigation to $diseaseName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.green),
                const SizedBox(width: 8),
                Text('Distance: ${distance.toStringAsFixed(1)} meters'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.explore, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Direction: ${_getDirectionText(bearing)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning, color: _getSeverityColor(severity)),
                const SizedBox(width: 8),
                Text('Severity: $severity'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => navigateToLocation(targetLocation),
                icon: const Icon(Icons.directions),
                label: const Text('Open Navigation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts bearing angle to direction text
  static String _getDirectionText(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    if (bearing >= 292.5 && bearing < 337.5) return 'Northwest';
    return 'Unknown';
  }

  /// Gets color based on disease severity
  static Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Creates a compass widget showing direction to target
  static Widget buildCompass(double bearing) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Stack(
        children: [
          // Compass background
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // North indicator
          const Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Text(
              'N',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          // Direction arrow
          Center(
            child: Transform.rotate(
              angle: bearing * 3.14159 / 180,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
