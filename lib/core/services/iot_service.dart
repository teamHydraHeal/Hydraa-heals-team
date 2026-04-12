import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

/// Service to fetch live IoT sensor data from the Flask backend.
/// Connects to ESP32 sensor pods via the /api/iot/ endpoints.
class IoTService {
  static String _baseUrl = _detectBaseUrl();

  static String _detectBaseUrl() {
    if (kIsWeb) {
      final location = web.window.location;
      final port = location.port;
      final isNginxServed = port == '' || port == '80' || port == '9090';
      if (isNginxServed) {
        return location.origin;
      }
      return 'http://${location.hostname}:5001';
    }
    return 'http://localhost:5001';
  }

  static void setBaseUrl(String url) => _baseUrl = url;

  /// Fetch latest readings from all sensors (or a specific one).
  /// Returns the API response map with a 'readings' list.
  static Future<List<Map<String, dynamic>>> getLatestReadings({
    String? sensorId,
  }) async {
    try {
      final uri = sensorId != null
          ? Uri.parse('$_baseUrl/api/iot/latest?sensor_id=$sensorId')
          : Uri.parse('$_baseUrl/api/iot/latest');

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['readings'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('[IoTService] Failed to fetch latest readings: $e');
      return [];
    }
  }

  /// Fetch device status summary — useful for dashboard widgets.
  static Future<List<Map<String, dynamic>>> getDeviceStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/iot/status'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['devices'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('[IoTService] Failed to fetch device status: $e');
      return [];
    }
  }

  /// Convert raw API reading into the Map format expected by IotDataWidget
  /// and AIAnalyticsService (water_quality, temperature, turbidity, etc.)
  static Map<String, dynamic> readingToIotData(Map<String, dynamic> reading) {
    final tds = (reading['tds'] as num?)?.toDouble() ?? 0;
    final temp = (reading['temperature'] as num?)?.toDouble() ?? 0;
    final turb = (reading['turbidity'] as num?)?.toDouble() ?? 0;
    final qualityStatus = reading['quality_status'] ?? reading['combined_status'] ?? 'Unknown';

    return {
      'water_quality': qualityStatus,
      'temperature': temp,
      'humidity': null, // ESP32 pod doesn't have humidity sensor
      'ph_level': null, // ESP32 pod doesn't have pH sensor
      'turbidity': turb,
      'chlorine_level': null,
      'tds': tds,
      'sensor_id': reading['sensor_id'],
      'location_id': reading['location_id'],
      'combined_risk': reading['combined_risk'],
      'battery': reading['battery'],
      'last_updated': reading['received_at'] ?? reading['timestamp'],
    };
  }

  /// Fetch the latest reading and return it in the format expected by widgets.
  /// Falls back to mock data if no live data is available.
  static Future<Map<String, dynamic>> getLatestIotData() async {
    try {
      final readings = await getLatestReadings();
      if (readings.isNotEmpty) {
        // Use the most recent reading
        return readingToIotData(readings.first);
      }
    } catch (e) {
      debugPrint('[IoTService] Falling back to mock data: $e');
    }

    // Fallback mock data when no sensor is connected
    return {
      'water_quality': 'Unknown',
      'temperature': null,
      'humidity': null,
      'ph_level': null,
      'turbidity': null,
      'chlorine_level': null,
      'tds': null,
    };
  }
}
