import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/core/database/database_manager.dart';
import 'package:jal_guard/core/database/database_service.dart';
import 'package:jal_guard/core/database/validation_service.dart';
import 'package:jal_guard/core/models/user_model.dart';
import 'package:jal_guard/core/models/health_report_model.dart';
import 'package:jal_guard/core/models/district_model.dart';

void main() {
  group('Database Service Tests', () {
    test('should provide database info', () {
      final info = DatabaseManager.getDatabaseInfo();
      
      expect(info, isA<Map<String, dynamic>>());
      expect(info.containsKey('database_name'), isTrue);
      expect(info.containsKey('database_version'), isTrue);
      expect(info.containsKey('timestamp'), isTrue);
      expect(info['database_name'], equals('jal_guard_enhanced.db'));
      expect(info['database_version'], equals(2));
    });

    test('should validate user data correctly', () {
      final validUser = User(
        id: 'valid_user_1',
        aadhaarNumber: '123456789012',
        phoneNumber: '+91-9876543210',
        name: 'Valid User',
        role: UserRole.citizen,
        isVerified: true,
        districtId: 'east_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final validation = ValidationService.validateUser(validUser);
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });

    test('should detect invalid user data', () {
      final invalidUser = User(
        id: '', // empty ID
        aadhaarNumber: '123', // invalid Aadhaar
        phoneNumber: 'invalid', // invalid phone
        name: 'A', // too short name
        role: UserRole.healthOfficial,
        isVerified: false,
        // missing professionalId for health official
        createdAt: DateTime.now().add(const Duration(days: 1)), // future date
        updatedAt: DateTime.now().subtract(const Duration(days: 1)), // before created
      );

      final validation = ValidationService.validateUser(invalidUser);
      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
      expect(validation.warnings, isNotEmpty);
    });

    test('should validate health report data correctly', () {
      final validReport = HealthReport(
        id: 'valid_report_1',
        userId: 'user_123',
        reporterName: 'Valid Reporter',
        location: 'Valid Location with sufficient length',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'This is a valid description with sufficient length for testing',
        symptoms: ['Fever', 'Cough'],
        severity: ReportSeverity.medium,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final validation = ValidationService.validateHealthReport(validReport);
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });

    test('should detect invalid health report data', () {
      final invalidReport = HealthReport(
        id: '', // empty ID
        userId: '', // empty user ID
        reporterName: '', // empty reporter name
        location: '', // empty location
        latitude: 200.0, // invalid latitude
        longitude: -200.0, // invalid longitude
        description: 'Short', // too short description
        symptoms: [], // empty symptoms
        severity: ReportSeverity.medium,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().add(const Duration(hours: 1)), // future date
        createdAt: DateTime.now().add(const Duration(days: 1)), // future date
        updatedAt: DateTime.now().subtract(const Duration(days: 1)), // before created
      );

      final validation = ValidationService.validateHealthReport(invalidReport);
      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
      expect(validation.warnings, isNotEmpty);
    });

    test('should validate district data correctly', () {
      final validDistrict = District(
        id: 'valid_district_1',
        name: 'Valid District',
        state: 'Valid State',
        latitude: 25.5788,
        longitude: 91.8933,
        population: 100000,
        riskScore: 5.5,
        riskLevel: RiskLevel.medium,
        activeReports: 10,
        criticalReports: 2,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      final validation = ValidationService.validateDistrict(validDistrict);
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });

    test('should detect invalid district data', () {
      final invalidDistrict = District(
        id: '', // empty ID
        name: '', // empty name
        state: '', // empty state
        latitude: 200.0, // invalid latitude
        longitude: -200.0, // invalid longitude
        population: -1000, // negative population
        riskScore: 15.0, // invalid risk score (> 10)
        riskLevel: RiskLevel.medium,
        activeReports: -5, // negative reports
        criticalReports: 20, // more critical than active
        lastUpdated: DateTime.now().add(const Duration(hours: 1)), // future date
        createdAt: DateTime.now().add(const Duration(days: 1)), // future date
        updatedAt: DateTime.now().subtract(const Duration(days: 1)), // before created
      );

      final validation = ValidationService.validateDistrict(invalidDistrict);
      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
      expect(validation.warnings, isNotEmpty);
    });

    test('should validate IoT sensor data correctly', () {
      final validSensorData = {
        'sensor_id': 'sensor_001',
        'sensor_type': 'water_quality',
        'value': 7.2,
        'unit': 'pH',
        'latitude': 25.5788,
        'longitude': 91.8933,
        'quality_score': 0.85,
      };

      final validation = ValidationService.validateIotSensorData(validSensorData);
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });

    test('should detect invalid IoT sensor data', () {
      final invalidSensorData = {
        'sensor_id': '', // empty sensor ID
        'sensor_type': '', // empty sensor type
        'value': 'invalid', // non-numeric value
        'unit': '', // empty unit
        'latitude': 200.0, // invalid latitude
        'longitude': -200.0, // invalid longitude
        'quality_score': 1.5, // invalid quality score (> 1)
      };

      final validation = ValidationService.validateIotSensorData(invalidSensorData);
      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
    });

    test('should validate JSON data correctly', () {
      const validJson = '{"key": "value", "number": 123}';
      final validation = ValidationService.validateJsonData(validJson);
      expect(validation.isValid, isTrue);
      expect(validation.errors, isEmpty);
    });

    test('should detect invalid JSON data', () {
      const invalidJson = '{"key": "value", "number": 123'; // missing closing brace
      final validation = ValidationService.validateJsonData(invalidJson);
      expect(validation.isValid, isFalse);
      expect(validation.errors, isNotEmpty);
    });
  });
}
