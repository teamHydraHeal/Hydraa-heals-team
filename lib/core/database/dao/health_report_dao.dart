import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../../models/health_report_model.dart';
import '../database_service.dart';

class HealthReportDAO {
  static String get _tableName => DatabaseService.healthReportsTable;

  // Create health report
  static Future<String> createHealthReport(HealthReport report) async {
    final db = DatabaseService.database!;

    try {
      await db.insert(_tableName, _healthReportToMap(report));
      return report.id;
    } catch (e) {
      print('Failed to create health report: $e');
      rethrow;
    }
  }

  // Get health report by ID
  static Future<HealthReport?> getHealthReportById(String id) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToHealthReport(maps.first);
      }
      return null;
    } catch (e) {
      print('Failed to get health report by ID: $e');
      return null;
    }
  }

  // Get health reports by user ID
  static Future<List<HealthReport>> getHealthReportsByUserId(String userId) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports by user ID: $e');
      return [];
    }
  }

  // Get health reports by district
  static Future<List<HealthReport>> getHealthReportsByDistrict(String districtId) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'district_id = ?',
        whereArgs: [districtId],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports by district: $e');
      return [];
    }
  }

  // Get health reports by severity
  static Future<List<HealthReport>> getHealthReportsBySeverity(ReportSeverity severity) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'severity = ?',
        whereArgs: [severity.toString().split('.').last],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports by severity: $e');
      return [];
    }
  }

  // Get health reports by status
  static Future<List<HealthReport>> getHealthReportsByStatus(ReportStatus status) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: [status.toString().split('.').last],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports by status: $e');
      return [];
    }
  }

  // Get critical health reports
  static Future<List<HealthReport>> getCriticalHealthReports() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'severity = ?',
        whereArgs: ['critical'],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get critical health reports: $e');
      return [];
    }
  }

  // Get pending health reports
  static Future<List<HealthReport>> getPendingHealthReports() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'reported_at ASC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get pending health reports: $e');
      return [];
    }
  }

  // Get offline health reports
  static Future<List<HealthReport>> getOfflineHealthReports() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'is_offline = ? AND is_synced = ?',
        whereArgs: [1, 0],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get offline health reports: $e');
      return [];
    }
  }

  // Get health reports in date range
  static Future<List<HealthReport>> getHealthReportsInDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? districtId,
    ReportSeverity? severity,
  }) async {
    final db = DatabaseService.database!;

    try {
      String whereClause = 'reported_at >= ? AND reported_at <= ?';
      List<dynamic> whereArgs = [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];

      if (districtId != null) {
        whereClause += ' AND district_id = ?';
        whereArgs.add(districtId);
      }

      if (severity != null) {
        whereClause += ' AND severity = ?';
        whereArgs.add(severity.toString().split('.').last);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports in date range: $e');
      return [];
    }
  }

  // Get health reports by location (within radius)
  static Future<List<HealthReport>> getHealthReportsByLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final db = DatabaseService.database!;

    try {
      // Using Haversine formula for distance calculation
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM $_tableName 
        WHERE (
          6371 * acos(
            cos(radians(?)) * cos(radians(latitude)) * 
            cos(radians(longitude) - radians(?)) + 
            sin(radians(?)) * sin(radians(latitude))
          )
        ) <= ?
        ORDER BY reported_at DESC
      ''', [latitude, longitude, latitude, radiusKm]);

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get health reports by location: $e');
      return [];
    }
  }

  // Update health report
  static Future<bool> updateHealthReport(HealthReport report) async {
    final db = DatabaseService.database!;

    try {
      final updatedReport = report.copyWith(updatedAt: DateTime.now());
      final result = await db.update(
        _tableName,
        _healthReportToMap(updatedReport),
        where: 'id = ?',
        whereArgs: [report.id],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update health report: $e');
      return false;
    }
  }

  // Update health report status
  static Future<bool> updateHealthReportStatus(String reportId, ReportStatus status) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'status': status.toString().split('.').last,
          'processed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update health report status: $e');
      return false;
    }
  }

  // Update AI analysis
  static Future<bool> updateAiAnalysis(
    String reportId,
    String aiAnalysis,
    Map<String, dynamic>? aiEntities,
    String? triageResponse,
  ) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'ai_analysis': aiAnalysis,
          'ai_entities': aiEntities != null ? json.encode(aiEntities) : null,
          'triage_response': triageResponse,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update AI analysis: $e');
      return false;
    }
  }

  // Mark as synced
  static Future<bool> markAsSynced(String reportId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'is_synced': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to mark as synced: $e');
      return false;
    }
  }

  // Increment sync attempts
  static Future<bool> incrementSyncAttempts(String reportId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'sync_attempts': 'sync_attempts + 1',
          'last_sync_attempt': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to increment sync attempts: $e');
      return false;
    }
  }

  // Delete health report
  static Future<bool> deleteHealthReport(String reportId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to delete health report: $e');
      return false;
    }
  }

  // Get all health reports (with pagination)
  static Future<List<HealthReport>> getAllHealthReports({
    int limit = 50,
    int offset = 0,
    String? orderBy,
  }) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: orderBy ?? 'reported_at DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to get all health reports: $e');
      return [];
    }
  }

  // Search health reports
  static Future<List<HealthReport>> searchHealthReports(String query) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '''
          (description LIKE ? OR 
           location LIKE ? OR 
           reporter_name LIKE ? OR 
           symptoms LIKE ?)
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'reported_at DESC',
      );

      return maps.map((map) => _mapToHealthReport(map)).toList();
    } catch (e) {
      print('Failed to search health reports: $e');
      return [];
    }
  }

  // Get health report statistics
  static Future<Map<String, int>> getHealthReportStatistics() async {
    final db = DatabaseService.database!;

    try {
      final totalReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName',
      )) ?? 0;

      final pendingReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE status = ?',
        ['pending'],
      )) ?? 0;

      final criticalReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE severity = ?',
        ['critical'],
      )) ?? 0;

      final offlineReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE is_offline = ? AND is_synced = ?',
        [1, 0],
      )) ?? 0;

      final todayReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE DATE(reported_at) = DATE(?)',
        [DateTime.now().toIso8601String()],
      )) ?? 0;

      return {
        'total_reports': totalReports,
        'pending_reports': pendingReports,
        'critical_reports': criticalReports,
        'offline_reports': offlineReports,
        'today_reports': todayReports,
      };
    } catch (e) {
      print('Failed to get health report statistics: $e');
      return {};
    }
  }

  // Get district health report statistics
  static Future<Map<String, int>> getDistrictHealthReportStatistics(String districtId) async {
    final db = DatabaseService.database!;

    try {
      final totalReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE district_id = ?',
        [districtId],
      )) ?? 0;

      final pendingReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE district_id = ? AND status = ?',
        [districtId, 'pending'],
      )) ?? 0;

      final criticalReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE district_id = ? AND severity = ?',
        [districtId, 'critical'],
      )) ?? 0;

      final todayReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE district_id = ? AND DATE(reported_at) = DATE(?)',
        [districtId, DateTime.now().toIso8601String()],
      )) ?? 0;

      return {
        'total_reports': totalReports,
        'pending_reports': pendingReports,
        'critical_reports': criticalReports,
        'today_reports': todayReports,
      };
    } catch (e) {
      print('Failed to get district health report statistics: $e');
      return {};
    }
  }

  // Convert HealthReport to Map
  static Map<String, dynamic> _healthReportToMap(HealthReport report) {
    return {
      'id': report.id,
      'user_id': report.userId,
      'reporter_name': report.reporterName,
      'location': report.location,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'description': report.description,
      'symptoms': json.encode(report.symptoms),
      'severity': report.severity.toString().split('.').last,
      'status': report.status.toString().split('.').last,
      'photo_urls': report.photoUrls != null ? json.encode(report.photoUrls) : null,
      'reported_at': report.reportedAt.toIso8601String(),
      'processed_at': report.processedAt?.toIso8601String(),
      'ai_analysis': report.aiAnalysis,
      'ai_entities': report.aiEntities != null ? json.encode(report.aiEntities) : null,
      'triage_response': report.triageResponse,
      'district_id': report.districtId,
      'block_id': report.blockId,
      'village_id': report.villageId,
      'is_offline': report.isOffline ? 1 : 0,
      'is_synced': report.isSynced ? 1 : 0,
      'sync_attempts': report.syncAttempts,
      'last_sync_attempt': report.lastSyncAttempt?.toIso8601String(),
      'created_at': report.createdAt.toIso8601String(),
      'updated_at': report.updatedAt.toIso8601String(),
    };
  }

  // Convert Map to HealthReport
  static HealthReport _mapToHealthReport(Map<String, dynamic> map) {
    return HealthReport(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      reporterName: map['reporter_name'] as String,
      location: map['location'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      description: map['description'] as String,
      symptoms: List<String>.from(json.decode(map['symptoms'] as String)),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.toString() == 'ReportSeverity.${map['severity']}',
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${map['status']}',
      ),
      photoUrls: map['photo_urls'] != null ? List<String>.from(json.decode(map['photo_urls'] as String) as List) : null,
      reportedAt: DateTime.parse(map['reported_at'] as String),
      processedAt: map['processed_at'] != null ? DateTime.parse(map['processed_at'] as String) : null,
      aiAnalysis: map['ai_analysis'] as String?,
      aiEntities: map['ai_entities'] != null ? Map<String, dynamic>.from(json.decode(map['ai_entities'] as String)) : null,
      triageResponse: map['triage_response'] as String?,
      districtId: map['district_id'] as String?,
      blockId: map['block_id'] as String?,
      villageId: map['village_id'] as String?,
      isOffline: (map['is_offline'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
      syncAttempts: map['sync_attempts'] as int? ?? 0,
      lastSyncAttempt: map['last_sync_attempt'] != null ? DateTime.parse(map['last_sync_attempt'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

