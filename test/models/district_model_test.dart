import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/core/models/district_model.dart';

void main() {
  group('District Model Tests', () {
    late District testDistrict;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime.now();
      testDistrict = District(
        id: 'east_khasi_hills',
        name: 'East Khasi Hills',
        state: 'Meghalaya',
        latitude: 25.5788,
        longitude: 91.8933,
        population: 825922,
        riskScore: 7.8,
        riskLevel: RiskLevel.high,
        activeReports: 23,
        criticalReports: 3,
        lastUpdated: testDateTime,
        polygonCoordinates: {
          'type': 'Polygon',
          'coordinates': [
            [91.8, 25.6],
            [92.0, 25.7],
            [92.2, 25.5]
          ]
        },
        iotSensorCount: 15,
        healthCentersCount: 8,
        ashaWorkersCount: 45,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    test('should create District with all required fields', () {
      expect(testDistrict.id, equals('east_khasi_hills'));
      expect(testDistrict.name, equals('East Khasi Hills'));
      expect(testDistrict.state, equals('Meghalaya'));
      expect(testDistrict.latitude, equals(25.5788));
      expect(testDistrict.longitude, equals(91.8933));
      expect(testDistrict.population, equals(825922));
      expect(testDistrict.riskScore, equals(7.8));
      expect(testDistrict.riskLevel, equals(RiskLevel.high));
      expect(testDistrict.activeReports, equals(23));
      expect(testDistrict.criticalReports, equals(3));
      expect(testDistrict.iotSensorCount, equals(15));
      expect(testDistrict.healthCentersCount, equals(8));
      expect(testDistrict.ashaWorkersCount, equals(45));
    });

    test('should serialize to JSON correctly', () {
      final json = testDistrict.toJson();

      expect(json['id'], equals('east_khasi_hills'));
      expect(json['name'], equals('East Khasi Hills'));
      expect(json['state'], equals('Meghalaya'));
      expect(json['latitude'], equals(25.5788));
      expect(json['longitude'], equals(91.8933));
      expect(json['population'], equals(825922));
      expect(json['riskScore'], equals(7.8));
      expect(json['riskLevel'], equals('high'));
      expect(json['activeReports'], equals(23));
      expect(json['criticalReports'], equals(3));
      expect(json['iotSensorCount'], equals(15));
      expect(json['healthCentersCount'], equals(8));
      expect(json['ashaWorkersCount'], equals(45));
      expect(json['polygonCoordinates'], isA<Map<String, dynamic>>());
    });

    test('should deserialize from JSON correctly', () {
      final json = testDistrict.toJson();
      final districtFromJson = District.fromJson(json);

      expect(districtFromJson.id, equals(testDistrict.id));
      expect(districtFromJson.name, equals(testDistrict.name));
      expect(districtFromJson.state, equals(testDistrict.state));
      expect(districtFromJson.latitude, equals(testDistrict.latitude));
      expect(districtFromJson.longitude, equals(testDistrict.longitude));
      expect(districtFromJson.population, equals(testDistrict.population));
      expect(districtFromJson.riskScore, equals(testDistrict.riskScore));
      expect(districtFromJson.riskLevel, equals(testDistrict.riskLevel));
      expect(districtFromJson.activeReports, equals(testDistrict.activeReports));
      expect(districtFromJson.criticalReports, equals(testDistrict.criticalReports));
      expect(districtFromJson.iotSensorCount, equals(testDistrict.iotSensorCount));
      expect(districtFromJson.healthCentersCount, equals(testDistrict.healthCentersCount));
      expect(districtFromJson.ashaWorkersCount, equals(testDistrict.ashaWorkersCount));
    });

    test('should create copy with updated fields', () {
      final updatedDistrict = testDistrict.copyWith(
        riskScore: 9.2,
        riskLevel: RiskLevel.critical,
        activeReports: 45,
        criticalReports: 8,
        iotSensorCount: 20,
      );

      expect(updatedDistrict.id, equals(testDistrict.id)); // unchanged
      expect(updatedDistrict.name, equals(testDistrict.name)); // unchanged
      expect(updatedDistrict.riskScore, equals(9.2)); // changed
      expect(updatedDistrict.riskLevel, equals(RiskLevel.critical)); // changed
      expect(updatedDistrict.activeReports, equals(45)); // changed
      expect(updatedDistrict.criticalReports, equals(8)); // changed
      expect(updatedDistrict.iotSensorCount, equals(20)); // changed
      expect(updatedDistrict.population, equals(testDistrict.population)); // unchanged
    });

    test('should validate risk levels correctly', () {
      final lowRiskDistrict = testDistrict.copyWith(riskLevel: RiskLevel.low);
      final mediumRiskDistrict = testDistrict.copyWith(riskLevel: RiskLevel.medium);
      final highRiskDistrict = testDistrict.copyWith(riskLevel: RiskLevel.high);
      final criticalRiskDistrict = testDistrict.copyWith(riskLevel: RiskLevel.critical);

      expect(lowRiskDistrict.isHighRisk, isFalse);
      expect(lowRiskDistrict.isCritical, isFalse);

      expect(mediumRiskDistrict.isHighRisk, isFalse);
      expect(mediumRiskDistrict.isCritical, isFalse);

      expect(highRiskDistrict.isHighRisk, isTrue);
      expect(highRiskDistrict.isCritical, isFalse);

      expect(criticalRiskDistrict.isHighRisk, isTrue);
      expect(criticalRiskDistrict.isCritical, isTrue);
    });

    test('should handle minimal district creation', () {
      final minimalDistrict = District(
        id: 'minimal_district',
        name: 'Minimal District',
        state: 'Test State',
        latitude: 25.0,
        longitude: 91.0,
        population: 100000,
        riskScore: 5.0,
        riskLevel: RiskLevel.medium,
        activeReports: 10,
        criticalReports: 2,
        lastUpdated: testDateTime,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(minimalDistrict.polygonCoordinates, isNull);
      expect(minimalDistrict.iotSensorCount, equals(0)); // default
      expect(minimalDistrict.healthCentersCount, equals(0)); // default
      expect(minimalDistrict.ashaWorkersCount, equals(0)); // default
    });

    test('should validate all risk levels', () {
      expect(RiskLevel.low.toString(), equals('RiskLevel.low'));
      expect(RiskLevel.medium.toString(), equals('RiskLevel.medium'));
      expect(RiskLevel.high.toString(), equals('RiskLevel.high'));
      expect(RiskLevel.critical.toString(), equals('RiskLevel.critical'));
    });

    test('should handle polygon coordinates correctly', () {
      final polygonCoordinates = {
        'type': 'Polygon',
        'coordinates': [
          [91.8, 25.6],
          [92.0, 25.7],
          [92.2, 25.5],
          [91.8, 25.6] // closed polygon
        ]
      };

      final districtWithPolygon = testDistrict.copyWith(
        polygonCoordinates: polygonCoordinates,
      );

      expect(districtWithPolygon.polygonCoordinates, equals(polygonCoordinates));
      expect(districtWithPolygon.polygonCoordinates!['type'], equals('Polygon'));
      expect(districtWithPolygon.polygonCoordinates!['coordinates'], isA<List>());
    });

    test('should validate infrastructure counts', () {
      expect(testDistrict.iotSensorCount, greaterThanOrEqualTo(0));
      expect(testDistrict.healthCentersCount, greaterThanOrEqualTo(0));
      expect(testDistrict.ashaWorkersCount, greaterThanOrEqualTo(0));
      expect(testDistrict.activeReports, greaterThanOrEqualTo(0));
      expect(testDistrict.criticalReports, greaterThanOrEqualTo(0));
      expect(testDistrict.criticalReports, lessThanOrEqualTo(testDistrict.activeReports));
    });
  });
}
