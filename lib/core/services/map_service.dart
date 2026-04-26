import 'dart:math';
import 'package:flutter/material.dart';

import '../models/district_model.dart';
import '../models/health_report_model.dart';

class MapService {
  static const String _baseUrl = 'https://api.jalguard.ai/maps'; // Mock API URL
  
  // Get district polygons for map visualization
  static Future<List<GeoPolygon>> getDistrictPolygons() async {
    try {
      // Mock data - in real app, this would fetch from GIS API
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        GeoPolygon(
          districtId: 'east_khasi_hills',
          districtName: 'East Khasi Hills',
          coordinates: _getEastKhasiHillsPolygon(),
          riskLevel: RiskLevel.high,
          riskScore: 7.8,
        ),
        GeoPolygon(
          districtId: 'west_khasi_hills',
          districtName: 'West Khasi Hills',
          coordinates: _getWestKhasiHillsPolygon(),
          riskLevel: RiskLevel.medium,
          riskScore: 5.2,
        ),
        GeoPolygon(
          districtId: 'ri_bhoi',
          districtName: 'Ri Bhoi',
          coordinates: _getRiBhoiPolygon(),
          riskLevel: RiskLevel.critical,
          riskScore: 9.1,
        ),
        GeoPolygon(
          districtId: 'jaintia_hills',
          districtName: 'Jaintia Hills',
          coordinates: _getJaintiaHillsPolygon(),
          riskLevel: RiskLevel.low,
          riskScore: 3.4,
        ),
        GeoPolygon(
          districtId: 'garo_hills',
          districtName: 'Garo Hills',
          coordinates: _getGaroHillsPolygon(),
          riskLevel: RiskLevel.medium,
          riskScore: 6.1,
        ),
      ];
    } catch (e) {
      print('Failed to fetch district polygons: $e');
      return [];
    }
  }
  
  // Get risk layers for map visualization
  static Future<List<RiskLayer>> getRiskLayers() async {
    try {
      // Mock data - in real app, this would fetch from risk analysis API
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        RiskLayer(
          id: 'water_quality_risk',
          name: 'Water Quality Risk',
          color: Colors.blue,
          opacity: 0.6,
          data: _generateWaterQualityRiskData(),
        ),
        RiskLayer(
          id: 'disease_outbreak_risk',
          name: 'Disease Outbreak Risk',
          color: Colors.red,
          opacity: 0.7,
          data: _generateDiseaseOutbreakRiskData(),
        ),
        RiskLayer(
          id: 'environmental_risk',
          name: 'Environmental Risk',
          color: Colors.orange,
          opacity: 0.5,
          data: _generateEnvironmentalRiskData(),
        ),
      ];
    } catch (e) {
      print('Failed to fetch risk layers: $e');
      return [];
    }
  }
  
  // Get heatmap data for field reports
  static Future<List<HeatmapPoint>> getHeatmapData() async {
    try {
      // Mock data - in real app, this would fetch from reports API
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        HeatmapPoint(
          latitude: 25.5788,
          longitude: 91.8933,
          intensity: 0.8,
          reportCount: 15,
          severity: ReportSeverity.high,
        ),
        HeatmapPoint(
          latitude: 25.5000,
          longitude: 91.8000,
          intensity: 0.9,
          reportCount: 23,
          severity: ReportSeverity.critical,
        ),
        HeatmapPoint(
          latitude: 25.4000,
          longitude: 91.7000,
          intensity: 0.6,
          reportCount: 8,
          severity: ReportSeverity.medium,
        ),
        HeatmapPoint(
          latitude: 25.6000,
          longitude: 91.9000,
          intensity: 0.4,
          reportCount: 5,
          severity: ReportSeverity.low,
        ),
        HeatmapPoint(
          latitude: 25.3000,
          longitude: 91.6000,
          intensity: 0.7,
          reportCount: 12,
          severity: ReportSeverity.high,
        ),
      ];
    } catch (e) {
      print('Failed to fetch heatmap data: $e');
      return [];
    }
  }
  
  // Update map layers based on type
  static void updateMapLayers(String layerType) {
    // In real app, this would update the map visualization
    print('Updating map layers: $layerType');
  }
  
  // Get district data for a specific district
  static Future<DistrictData?> getDistrictData(String districtId) async {
    try {
      // Mock data - in real app, this would fetch from district API
      await Future.delayed(const Duration(seconds: 1));
      
      switch (districtId) {
        case 'east_khasi_hills':
          return DistrictData(
            id: 'east_khasi_hills',
            name: 'East Khasi Hills',
            population: 825922,
            riskScore: 7.8,
            iotData: _getMockIotData(),
            fieldReports: _getMockFieldReports(),
            lastUpdated: DateTime.now(),
          );
        case 'ri_bhoi':
          return DistrictData(
            id: 'ri_bhoi',
            name: 'Ri Bhoi',
            population: 258380,
            riskScore: 9.1,
            iotData: _getMockIotData(),
            fieldReports: _getMockFieldReports(),
            lastUpdated: DateTime.now(),
          );
        default:
          return null;
      }
    } catch (e) {
      print('Failed to fetch district data: $e');
      return null;
    }
  }
  
  // Helper methods for mock data generation
  static List<LatLng> _getEastKhasiHillsPolygon() {
    return [
      const LatLng(25.6, 91.8),
      const LatLng(25.7, 92.0),
      const LatLng(25.5, 92.2),
      const LatLng(25.3, 92.0),
      const LatLng(25.4, 91.7),
      const LatLng(25.6, 91.8),
    ];
  }
  
  static List<LatLng> _getWestKhasiHillsPolygon() {
    return [
      const LatLng(25.4, 90.8),
      const LatLng(25.6, 91.0),
      const LatLng(25.3, 91.2),
      const LatLng(25.1, 91.0),
      const LatLng(25.2, 90.7),
      const LatLng(25.4, 90.8),
    ];
  }
  
  static List<LatLng> _getRiBhoiPolygon() {
    return [
      const LatLng(25.8, 91.5),
      const LatLng(26.0, 91.7),
      const LatLng(25.7, 91.9),
      const LatLng(25.5, 91.7),
      const LatLng(25.6, 91.4),
      const LatLng(25.8, 91.5),
    ];
  }
  
  static List<LatLng> _getJaintiaHillsPolygon() {
    return [
      const LatLng(25.2, 92.3),
      const LatLng(25.4, 92.5),
      const LatLng(25.1, 92.7),
      const LatLng(24.9, 92.5),
      const LatLng(25.0, 92.2),
      const LatLng(25.2, 92.3),
    ];
  }
  
  static List<LatLng> _getGaroHillsPolygon() {
    return [
      const LatLng(25.0, 90.2),
      const LatLng(25.2, 90.4),
      const LatLng(24.9, 90.6),
      const LatLng(24.7, 90.4),
      const LatLng(24.8, 90.1),
      const LatLng(25.0, 90.2),
    ];
  }
  
  static List<RiskDataPoint> _generateWaterQualityRiskData() {
    final random = Random();
    return List.generate(20, (index) {
      return RiskDataPoint(
        latitude: 25.0 + random.nextDouble() * 1.0,
        longitude: 90.0 + random.nextDouble() * 2.0,
        riskValue: random.nextDouble(),
        timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      );
    });
  }
  
  static List<RiskDataPoint> _generateDiseaseOutbreakRiskData() {
    final random = Random();
    return List.generate(15, (index) {
      return RiskDataPoint(
        latitude: 25.0 + random.nextDouble() * 1.0,
        longitude: 90.0 + random.nextDouble() * 2.0,
        riskValue: random.nextDouble(),
        timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      );
    });
  }
  
  static List<RiskDataPoint> _generateEnvironmentalRiskData() {
    final random = Random();
    return List.generate(25, (index) {
      return RiskDataPoint(
        latitude: 25.0 + random.nextDouble() * 1.0,
        longitude: 90.0 + random.nextDouble() * 2.0,
        riskValue: random.nextDouble(),
        timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      );
    });
  }
  
  static List<SensorData> _getMockIotData() {
    return [
      SensorData(
        id: 'water_quality_001',
        type: 'water_quality',
        value: 'Poor',
        location: const LatLng(25.5788, 91.8933),
        timestamp: DateTime.now(),
      ),
      SensorData(
        id: 'temperature_001',
        type: 'temperature',
        value: '28.5',
        location: const LatLng(25.5788, 91.8933),
        timestamp: DateTime.now(),
      ),
      SensorData(
        id: 'humidity_001',
        type: 'humidity',
        value: '85.2',
        location: const LatLng(25.5788, 91.8933),
        timestamp: DateTime.now(),
      ),
    ];
  }
  
  static List<HealthReport> _getMockFieldReports() {
    return [
      HealthReport(
        id: '1',
        userId: 'user1',
        reporterName: 'ASHA Worker 1',
        location: 'Shillong, East Khasi Hills',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'Water contamination detected in village well.',
        symptoms: ['Diarrhea', 'Vomiting'],
        severity: ReportSeverity.high,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HealthReport(
        id: '2',
        userId: 'user2',
        reporterName: 'ASHA Worker 2',
        location: 'Mawryngkneng, East Khasi Hills',
        latitude: 25.5000,
        longitude: 91.8000,
        description: 'Critical water quality issue.',
        symptoms: ['Diarrhea', 'Fever'],
        severity: ReportSeverity.critical,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

// Data models for map service
class GeoPolygon {
  final String districtId;
  final String districtName;
  final List<LatLng> coordinates;
  final RiskLevel riskLevel;
  final double riskScore;

  GeoPolygon({
    required this.districtId,
    required this.districtName,
    required this.coordinates,
    required this.riskLevel,
    required this.riskScore,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

class RiskLayer {
  final String id;
  final String name;
  final Color color;
  final double opacity;
  final List<RiskDataPoint> data;

  RiskLayer({
    required this.id,
    required this.name,
    required this.color,
    required this.opacity,
    required this.data,
  });
}

class RiskDataPoint {
  final double latitude;
  final double longitude;
  final double riskValue;
  final DateTime timestamp;

  RiskDataPoint({
    required this.latitude,
    required this.longitude,
    required this.riskValue,
    required this.timestamp,
  });
}

class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity;
  final int reportCount;
  final ReportSeverity severity;

  HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.reportCount,
    required this.severity,
  });
}

class SensorData {
  final String id;
  final String type;
  final String value;
  final LatLng location;
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.type,
    required this.value,
    required this.location,
    required this.timestamp,
  });
}

class DistrictData {
  final String id;
  final String name;
  final int population;
  final double riskScore;
  final List<SensorData> iotData;
  final List<HealthReport> fieldReports;
  final DateTime lastUpdated;

  DistrictData({
    required this.id,
    required this.name,
    required this.population,
    required this.riskScore,
    required this.iotData,
    required this.fieldReports,
    required this.lastUpdated,
  });
}
