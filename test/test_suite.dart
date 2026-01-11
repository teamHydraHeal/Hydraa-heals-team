import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'models/user_model_test.dart' as user_model_tests;
import 'models/health_report_model_test.dart' as health_report_tests;
import 'models/district_model_test.dart' as district_model_tests;
import 'services/database_service_test.dart' as database_service_tests;
import 'widgets/heatmap_widget_test.dart' as heatmap_widget_tests;

// Import required models and services for the test
import 'package:jal_guard/core/models/user_model.dart';
import 'package:jal_guard/core/models/health_report_model.dart';
import 'package:jal_guard/core/models/district_model.dart';
import 'package:jal_guard/core/database/validation_service.dart';

void main() {
  group('Jal Guard Test Suite', () {
    group('Model Tests', () {
      user_model_tests.main();
      health_report_tests.main();
      district_model_tests.main();
    });

    group('Service Tests', () {
      database_service_tests.main();
    });

    group('Widget Tests', () {
      heatmap_widget_tests.main();
    });

    // Performance and Load Tests
    group('Performance Tests', () {
      test('Model serialization performance', () {
        final stopwatch = Stopwatch()..start();
        
        // Create and serialize 1000 users
        for (int i = 0; i < 1000; i++) {
          final user = createTestUser(i);
          final json = user.toJson();
          final userFromJson = User.fromJson(json);
          expect(userFromJson.id, equals(user.id));
        }
        
        stopwatch.stop();
        print('1000 user serializations took: ${stopwatch.elapsedMilliseconds}ms');
        
        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('Health report processing performance', () {
        final stopwatch = Stopwatch()..start();
        
        // Create and process 500 health reports
        for (int i = 0; i < 500; i++) {
          final report = createTestHealthReport(i);
          final json = report.toJson();
          final reportFromJson = HealthReport.fromJson(json);
          expect(reportFromJson.id, equals(report.id));
          
          // Test validation performance
          final validation = ValidationService.validateHealthReport(report);
          expect(validation, isA<ValidationResult>());
        }
        
        stopwatch.stop();
        print('500 health report processing took: ${stopwatch.elapsedMilliseconds}ms');
        
        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('District data processing performance', () {
        final stopwatch = Stopwatch()..start();
        
        // Create and process 100 districts
        for (int i = 0; i < 100; i++) {
          final district = createTestDistrict(i);
          final json = district.toJson();
          final districtFromJson = District.fromJson(json);
          expect(districtFromJson.id, equals(district.id));
          
          // Test validation performance
          final validation = ValidationService.validateDistrict(district);
          expect(validation, isA<ValidationResult>());
        }
        
        stopwatch.stop();
        print('100 district processing took: ${stopwatch.elapsedMilliseconds}ms');
        
        // Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    // Edge Case Tests
    group('Edge Case Tests', () {
      test('should handle extreme coordinate values', () {
        final report = HealthReport(
          id: 'edge_test_1',
          userId: 'user_1',
          reporterName: 'Reporter',
          location: 'Edge Location',
          latitude: 90.0, // Max latitude
          longitude: 180.0, // Max longitude
          description: 'Edge case test report',
          symptoms: ['Test'],
          severity: ReportSeverity.low,
          status: ReportStatus.pending,
          reportedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final validation = ValidationService.validateHealthReport(report);
        expect(validation.isValid, isTrue);
      });

      test('should handle very long text fields', () {
        final longDescription = 'A' * 10000; // 10k characters
        final longSymptoms = List.generate(100, (i) => 'Symptom$i');
        
        final report = HealthReport(
          id: 'long_text_test',
          userId: 'user_1',
          reporterName: 'Reporter',
          location: 'Location',
          latitude: 25.0,
          longitude: 91.0,
          description: longDescription,
          symptoms: longSymptoms,
          severity: ReportSeverity.medium,
          status: ReportStatus.pending,
          reportedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = report.toJson();
        final reportFromJson = HealthReport.fromJson(json);
        expect(reportFromJson.description, equals(longDescription));
        expect(reportFromJson.symptoms.length, equals(100));
      });

      test('should handle Unicode characters correctly', () {
        final user = User(
          id: 'unicode_test',
          aadhaarNumber: '123456789012',
          phoneNumber: '+91-9876543210',
          name: 'Test User 测试用户 🧪',
          role: UserRole.citizen,
          isVerified: true,
          districtId: 'खासी_हिल्स',
          state: 'मेघालय',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = user.toJson();
        final userFromJson = User.fromJson(json);
        expect(userFromJson.name, equals('Test User 测试用户 🧪'));
        expect(userFromJson.districtId, equals('खासी_हिल्स'));
        expect(userFromJson.state, equals('मेघालय'));
      });

      test('should handle very large numbers correctly', () {
        final district = District(
          id: 'large_numbers_test',
          name: 'Large District',
          state: 'State',
          latitude: 25.0,
          longitude: 91.0,
          population: 999999999, // Very large population
          riskScore: 9.999999, // High precision risk score
          riskLevel: RiskLevel.critical,
          activeReports: 999999,
          criticalReports: 999999,
          lastUpdated: DateTime.now(),
          iotSensorCount: 999999,
          healthCentersCount: 999999,
          ashaWorkersCount: 999999,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = district.toJson();
        final districtFromJson = District.fromJson(json);
        expect(districtFromJson.population, equals(999999999));
        expect(districtFromJson.iotSensorCount, equals(999999));
      });
    });
  });
}

// Helper functions for creating test data
User createTestUser(int index) {
  final now = DateTime.now();
  return User(
    id: 'test_user_$index',
    aadhaarNumber: '12345678901$index',
    phoneNumber: '+91-987654321$index',
    name: 'Test User $index',
    role: UserRole.values[index % UserRole.values.length],
    isVerified: index % 2 == 0,
    districtId: 'district_${index % 5}',
    state: 'Meghalaya',
    createdAt: now,
    updatedAt: now,
    isActive: true,
  );
}

HealthReport createTestHealthReport(int index) {
  final now = DateTime.now();
  return HealthReport(
    id: 'test_report_$index',
    userId: 'user_$index',
    reporterName: 'Reporter $index',
    location: 'Location $index',
    latitude: 25.0 + (index * 0.01),
    longitude: 91.0 + (index * 0.01),
    description: 'Test health report description $index',
    symptoms: ['Symptom${index}A', 'Symptom${index}B'],
    severity: ReportSeverity.values[index % ReportSeverity.values.length],
    status: ReportStatus.values[index % ReportStatus.values.length],
    reportedAt: now.subtract(Duration(hours: index)),
    districtId: 'district_${index % 5}',
    isOffline: index % 2 == 0,
    isSynced: index % 3 == 0,
    createdAt: now,
    updatedAt: now,
  );
}

District createTestDistrict(int index) {
  final now = DateTime.now();
  return District(
    id: 'test_district_$index',
    name: 'Test District $index',
    state: 'Meghalaya',
    latitude: 25.0 + (index * 0.1),
    longitude: 91.0 + (index * 0.1),
    population: 100000 + (index * 10000),
    riskScore: (index % 10).toDouble(),
    riskLevel: RiskLevel.values[index % RiskLevel.values.length],
    activeReports: index * 5,
    criticalReports: index * 2,
    lastUpdated: now.subtract(Duration(hours: index)),
    iotSensorCount: index * 3,
    healthCentersCount: index * 2,
    ashaWorkersCount: index * 10,
    createdAt: now,
    updatedAt: now,
  );
}
