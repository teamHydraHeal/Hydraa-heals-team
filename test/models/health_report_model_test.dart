import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/core/models/health_report_model.dart';

void main() {
  group('HealthReport Model Tests', () {
    late HealthReport testReport;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime.now();
      testReport = HealthReport(
        id: 'test_report_1',
        userId: 'test_user_1',
        reporterName: 'Test Reporter',
        location: 'Shillong, East Khasi Hills',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'Water contamination detected in village well',
        symptoms: ['Diarrhea', 'Vomiting', 'Fever'],
        severity: ReportSeverity.high,
        status: ReportStatus.pending,
        photoUrls: ['photo1.jpg', 'photo2.jpg'],
        reportedAt: testDateTime,
        processedAt: testDateTime.add(const Duration(hours: 2)),
        aiAnalysis: 'High risk water contamination detected',
        aiEntities: {'location': 'village well', 'contaminant': 'bacteria'},
        triageResponse: 'Immediate water testing required',
        districtId: 'east_khasi_hills',
        blockId: 'Shillong',
        villageId: 'Mawryngkneng',
        isOffline: true,
        isSynced: false,
        syncAttempts: 2,
        lastSyncAttempt: testDateTime.subtract(const Duration(minutes: 30)),
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    test('should create HealthReport with all required fields', () {
      expect(testReport.id, equals('test_report_1'));
      expect(testReport.userId, equals('test_user_1'));
      expect(testReport.reporterName, equals('Test Reporter'));
      expect(testReport.location, equals('Shillong, East Khasi Hills'));
      expect(testReport.latitude, equals(25.5788));
      expect(testReport.longitude, equals(91.8933));
      expect(testReport.description, equals('Water contamination detected in village well'));
      expect(testReport.symptoms, equals(['Diarrhea', 'Vomiting', 'Fever']));
      expect(testReport.severity, equals(ReportSeverity.high));
      expect(testReport.status, equals(ReportStatus.pending));
      expect(testReport.districtId, equals('east_khasi_hills'));
      expect(testReport.isOffline, isTrue);
      expect(testReport.isSynced, isFalse);
      expect(testReport.syncAttempts, equals(2));
    });

    test('should serialize to JSON correctly', () {
      final json = testReport.toJson();

      expect(json['id'], equals('test_report_1'));
      expect(json['userId'], equals('test_user_1'));
      expect(json['reporterName'], equals('Test Reporter'));
      expect(json['location'], equals('Shillong, East Khasi Hills'));
      expect(json['latitude'], equals(25.5788));
      expect(json['longitude'], equals(91.8933));
      expect(json['description'], equals('Water contamination detected in village well'));
      expect(json['symptoms'], equals(['Diarrhea', 'Vomiting', 'Fever']));
      expect(json['severity'], equals('high'));
      expect(json['status'], equals('pending'));
      expect(json['photoUrls'], equals(['photo1.jpg', 'photo2.jpg']));
      expect(json['aiAnalysis'], equals('High risk water contamination detected'));
      expect(json['aiEntities'], equals({'location': 'village well', 'contaminant': 'bacteria'}));
      expect(json['triageResponse'], equals('Immediate water testing required'));
      expect(json['districtId'], equals('east_khasi_hills'));
      expect(json['blockId'], equals('Shillong'));
      expect(json['villageId'], equals('Mawryngkneng'));
      expect(json['isOffline'], isTrue);
      expect(json['isSynced'], isFalse);
      expect(json['syncAttempts'], equals(2));
    });

    test('should deserialize from JSON correctly', () {
      final json = testReport.toJson();
      final reportFromJson = HealthReport.fromJson(json);

      expect(reportFromJson.id, equals(testReport.id));
      expect(reportFromJson.userId, equals(testReport.userId));
      expect(reportFromJson.reporterName, equals(testReport.reporterName));
      expect(reportFromJson.location, equals(testReport.location));
      expect(reportFromJson.latitude, equals(testReport.latitude));
      expect(reportFromJson.longitude, equals(testReport.longitude));
      expect(reportFromJson.description, equals(testReport.description));
      expect(reportFromJson.symptoms, equals(testReport.symptoms));
      expect(reportFromJson.severity, equals(testReport.severity));
      expect(reportFromJson.status, equals(testReport.status));
      expect(reportFromJson.districtId, equals(testReport.districtId));
      expect(reportFromJson.isOffline, equals(testReport.isOffline));
      expect(reportFromJson.isSynced, equals(testReport.isSynced));
      expect(reportFromJson.syncAttempts, equals(testReport.syncAttempts));
    });

    test('should create copy with updated fields', () {
      final updatedReport = testReport.copyWith(
        status: ReportStatus.processed,
        isSynced: true,
        syncAttempts: 0,
        aiAnalysis: 'Updated AI analysis',
      );

      expect(updatedReport.id, equals(testReport.id)); // unchanged
      expect(updatedReport.status, equals(ReportStatus.processed)); // changed
      expect(updatedReport.isSynced, isTrue); // changed
      expect(updatedReport.syncAttempts, equals(0)); // changed
      expect(updatedReport.aiAnalysis, equals('Updated AI analysis')); // changed
      expect(updatedReport.severity, equals(testReport.severity)); // unchanged
    });

    test('should validate severity levels correctly', () {
      final lowReport = testReport.copyWith(severity: ReportSeverity.low);
      final mediumReport = testReport.copyWith(severity: ReportSeverity.medium);
      final highReport = testReport.copyWith(severity: ReportSeverity.high);
      final criticalReport = testReport.copyWith(severity: ReportSeverity.critical);

      expect(lowReport.isCritical, isFalse);
      expect(lowReport.isHigh, isFalse);
      expect(lowReport.needsAttention, isFalse);

      expect(mediumReport.isCritical, isFalse);
      expect(mediumReport.isHigh, isFalse);
      expect(mediumReport.needsAttention, isFalse);

      expect(highReport.isCritical, isFalse);
      expect(highReport.isHigh, isTrue);
      expect(highReport.needsAttention, isTrue);

      expect(criticalReport.isCritical, isTrue);
      expect(criticalReport.isHigh, isFalse);
      expect(criticalReport.needsAttention, isTrue);
    });

    test('should handle minimal report creation', () {
      final minimalReport = HealthReport(
        id: 'minimal_report',
        userId: 'user_123',
        reporterName: 'Reporter',
        location: 'Location',
        latitude: 25.0,
        longitude: 91.0,
        description: 'Description',
        symptoms: ['Symptom'],
        severity: ReportSeverity.low,
        status: ReportStatus.pending,
        reportedAt: testDateTime,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(minimalReport.photoUrls, equals([])); // default empty list
      expect(minimalReport.processedAt, isNull);
      expect(minimalReport.aiAnalysis, isNull);
      expect(minimalReport.aiEntities, isNull);
      expect(minimalReport.triageResponse, isNull);
      expect(minimalReport.districtId, isNull);
      expect(minimalReport.blockId, isNull);
      expect(minimalReport.villageId, isNull);
      expect(minimalReport.isOffline, isFalse); // default
      expect(minimalReport.isSynced, isTrue); // default
      expect(minimalReport.syncAttempts, equals(0)); // default
      expect(minimalReport.lastSyncAttempt, isNull);
    });

    test('should validate report status transitions', () {
      final pendingReport = testReport.copyWith(status: ReportStatus.pending);
      final processingReport = testReport.copyWith(status: ReportStatus.processing);
      final processedReport = testReport.copyWith(status: ReportStatus.processed);
      final escalatedReport = testReport.copyWith(status: ReportStatus.escalated);

      expect(pendingReport.status, equals(ReportStatus.pending));
      expect(processingReport.status, equals(ReportStatus.processing));
      expect(processedReport.status, equals(ReportStatus.processed));
      expect(escalatedReport.status, equals(ReportStatus.escalated));
    });
  });
}
