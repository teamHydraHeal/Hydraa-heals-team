import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/core/database/database_manager.dart';
import 'package:jal_guard/core/models/user_model.dart';
import 'package:jal_guard/core/models/health_report_model.dart';
import 'package:jal_guard/core/models/district_model.dart';

void main() {
  group('Database Tests', () {
    test('User model serialization', () {
      final now = DateTime.now();
      final user = User(
        id: 'test_user_1',
        aadhaarNumber: '123456789012',
        phoneNumber: '+91-9876543210',
        name: 'Test User',
        role: UserRole.citizen,
        isVerified: true,
        districtId: 'test_district',
        state: 'Meghalaya',
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      expect(userFromJson.id, equals(user.id));
      expect(userFromJson.name, equals(user.name));
      expect(userFromJson.role, equals(user.role));
      expect(userFromJson.isVerified, equals(user.isVerified));
      expect(userFromJson.districtId, equals(user.districtId));
      expect(userFromJson.isActive, equals(user.isActive));
    });

    test('HealthReport model serialization', () {
      final now = DateTime.now();
      final report = HealthReport(
        id: 'test_report_1',
        userId: 'test_user_1',
        reporterName: 'Test Reporter',
        location: 'Test Location',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'Test health report',
        symptoms: ['Fever', 'Cough'],
        severity: ReportSeverity.medium,
        status: ReportStatus.pending,
        reportedAt: now,
        districtId: 'test_district',
        isOffline: true,
        isSynced: false,
        createdAt: now,
        updatedAt: now,
      );

      final json = report.toJson();
      final reportFromJson = HealthReport.fromJson(json);

      expect(reportFromJson.id, equals(report.id));
      expect(reportFromJson.userId, equals(report.userId));
      expect(reportFromJson.severity, equals(report.severity));
      expect(reportFromJson.status, equals(report.status));
      expect(reportFromJson.districtId, equals(report.districtId));
      expect(reportFromJson.isOffline, equals(report.isOffline));
      expect(reportFromJson.isSynced, equals(report.isSynced));
    });

    test('District model serialization', () {
      final now = DateTime.now();
      final district = District(
        id: 'test_district_1',
        name: 'Test District',
        state: 'Meghalaya',
        latitude: 25.5788,
        longitude: 91.8933,
        population: 100000,
        riskScore: 7.5,
        riskLevel: RiskLevel.high,
        activeReports: 10,
        criticalReports: 2,
        lastUpdated: now,
        iotSensorCount: 5,
        healthCentersCount: 3,
        ashaWorkersCount: 15,
        createdAt: now,
        updatedAt: now,
      );

      final json = district.toJson();
      final districtFromJson = District.fromJson(json);

      expect(districtFromJson.id, equals(district.id));
      expect(districtFromJson.name, equals(district.name));
      expect(districtFromJson.riskLevel, equals(district.riskLevel));
      expect(districtFromJson.population, equals(district.population));
      expect(districtFromJson.iotSensorCount, equals(district.iotSensorCount));
      expect(districtFromJson.healthCentersCount, equals(district.healthCentersCount));
      expect(districtFromJson.ashaWorkersCount, equals(district.ashaWorkersCount));
    });

    test('Database manager info', () {
      final info = DatabaseManager.getDatabaseInfo();
      
      expect(info, isA<Map<String, dynamic>>());
      expect(info.containsKey('database_name'), isTrue);
      expect(info.containsKey('database_version'), isTrue);
      expect(info.containsKey('timestamp'), isTrue);
    });
  });
}

