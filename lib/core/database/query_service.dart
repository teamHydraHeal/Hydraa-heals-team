import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import 'database_service.dart';
import 'dao/user_dao.dart';
import 'dao/health_report_dao.dart';
import 'dao/district_dao.dart';

class QueryService {
  // Advanced search with multiple filters
  static Future<List<Map<String, dynamic>>> advancedSearch({
    String? query,
    String? table,
    Map<String, dynamic>? filters,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (query != null && query.isNotEmpty) {
        // Build search conditions based on table
        switch (table) {
          case 'users':
            whereClause = '''
              (name LIKE ? OR 
               aadhaar_number LIKE ? OR 
               phone_number LIKE ? OR 
               professional_id LIKE ?)
            ''';
            whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%']);
            break;
          case 'health_reports':
            whereClause = '''
              (description LIKE ? OR 
               location LIKE ? OR 
               reporter_name LIKE ? OR 
               symptoms LIKE ?)
            ''';
            whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%']);
            break;
          case 'districts':
            whereClause = 'name LIKE ? OR state LIKE ?';
            whereArgs.addAll(['%$query%', '%$query%']);
            break;
        }
      }

      // Add additional filters
      if (filters != null && filters.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        
        final filterConditions = <String>[];
        filters.forEach((key, value) {
          if (value != null) {
            filterConditions.add('$key = ?');
            whereArgs.add(value);
          }
        });
        whereClause += filterConditions.join(' AND ');
      }

      // Build order by clause
      String orderByClause = '';
      if (orderBy != null && orderBy.isNotEmpty) {
        orderByClause = 'ORDER BY ${orderBy.join(', ')}';
      }

      // Build limit and offset clause
      String limitClause = '';
      if (limit != null) {
        limitClause = 'LIMIT $limit';
        if (offset != null) {
          limitClause += ' OFFSET $offset';
        }
      }

      final sql = '''
        SELECT * FROM $table 
        ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
        $orderByClause
        $limitClause
      ''';

      final result = await db.rawQuery(sql, whereArgs);
      return result;
    } catch (e) {
      print('Advanced search failed: $e');
      return [];
    }
  }

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStatistics() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      final userStats = await UserDAO.getUserStatistics();
      final reportStats = await HealthReportDAO.getHealthReportStatistics();
      final districtStats = await DistrictDAO.getDistrictStatistics();

      return {
        'users': userStats,
        'reports': reportStats,
        'districts': districtStats,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to get dashboard statistics: $e');
      return {};
    }
  }

  // Get health trends over time
  static Future<List<Map<String, dynamic>>> getHealthTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? districtId,
    String? severity,
  }) async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

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
        whereArgs.add(severity);
      }

      final result = await db.rawQuery('''
        SELECT 
          DATE(reported_at) as date,
          COUNT(*) as total_reports,
          COUNT(CASE WHEN severity = 'critical' THEN 1 END) as critical_reports,
          COUNT(CASE WHEN severity = 'high' THEN 1 END) as high_reports,
          COUNT(CASE WHEN severity = 'medium' THEN 1 END) as medium_reports,
          COUNT(CASE WHEN severity = 'low' THEN 1 END) as low_reports
        FROM ${DatabaseService._healthReportsTable}
        WHERE $whereClause
        GROUP BY DATE(reported_at)
        ORDER BY date ASC
      ''', whereArgs);

      return result;
    } catch (e) {
      print('Failed to get health trends: $e');
      return [];
    }
  }

  // Get geographic distribution of reports
  static Future<List<Map<String, dynamic>>> getGeographicDistribution({
    String? districtId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (districtId != null) {
        whereClause += ' AND district_id = ?';
        whereArgs.add(districtId);
      }

      if (startDate != null && endDate != null) {
        whereClause += ' AND reported_at >= ? AND reported_at <= ?';
        whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
      }

      final result = await db.rawQuery('''
        SELECT 
          district_id,
          COUNT(*) as report_count,
          AVG(latitude) as avg_latitude,
          AVG(longitude) as avg_longitude,
          COUNT(CASE WHEN severity = 'critical' THEN 1 END) as critical_count,
          COUNT(CASE WHEN severity = 'high' THEN 1 END) as high_count
        FROM ${DatabaseService._healthReportsTable}
        WHERE $whereClause
        GROUP BY district_id
        ORDER BY report_count DESC
      ''', whereArgs);

      return result;
    } catch (e) {
      print('Failed to get geographic distribution: $e');
      return [];
    }
  }

  // Get user activity analytics
  static Future<List<Map<String, dynamic>>> getUserActivityAnalytics({
    String? userId,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];

      if (userId != null) {
        whereClause += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      if (role != null) {
        whereClause += ' AND role = ?';
        whereArgs.add(role);
      }

      if (startDate != null && endDate != null) {
        whereClause += ' AND created_at >= ? AND created_at <= ?';
        whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
      }

      final result = await db.rawQuery('''
        SELECT 
          u.id,
          u.name,
          u.role,
          u.district_id,
          COUNT(hr.id) as reports_submitted,
          MAX(hr.reported_at) as last_report_date,
          COUNT(CASE WHEN hr.severity = 'critical' THEN 1 END) as critical_reports,
          u.last_login
        FROM ${DatabaseService._usersTable} u
        LEFT JOIN ${DatabaseService._healthReportsTable} hr ON u.id = hr.user_id
        WHERE $whereClause
        GROUP BY u.id, u.name, u.role, u.district_id, u.last_login
        ORDER BY reports_submitted DESC
      ''', whereArgs);

      return result;
    } catch (e) {
      print('Failed to get user activity analytics: $e');
      return [];
    }
  }

  // Get risk correlation analysis
  static Future<List<Map<String, dynamic>>> getRiskCorrelationAnalysis() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      final result = await db.rawQuery('''
        SELECT 
          d.id as district_id,
          d.name as district_name,
          d.risk_score,
          d.risk_level,
          COUNT(hr.id) as total_reports,
          COUNT(CASE WHEN hr.severity = 'critical' THEN 1 END) as critical_reports,
          COUNT(CASE WHEN hr.severity = 'high' THEN 1 END) as high_reports,
          AVG(isd.quality_score) as avg_water_quality,
          COUNT(isd.id) as sensor_readings
        FROM ${DatabaseService._districtsTable} d
        LEFT JOIN ${DatabaseService._healthReportsTable} hr ON d.id = hr.district_id
        LEFT JOIN ${DatabaseService._iotSensorDataTable} isd ON d.id = isd.district_id
        GROUP BY d.id, d.name, d.risk_score, d.risk_level
        ORDER BY d.risk_score DESC
      ''');

      return result;
    } catch (e) {
      print('Failed to get risk correlation analysis: $e');
      return [];
    }
  }

  // Get performance metrics
  static Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      // Response time metrics
      final responseTimeMetrics = await db.rawQuery('''
        SELECT 
          AVG(CASE 
            WHEN processed_at IS NOT NULL 
            THEN (julianday(processed_at) - julianday(reported_at)) * 24 * 60 
            ELSE NULL 
          END) as avg_response_time_minutes,
          COUNT(CASE WHEN processed_at IS NOT NULL THEN 1 END) as processed_reports,
          COUNT(*) as total_reports
        FROM ${DatabaseService._healthReportsTable}
        WHERE reported_at >= datetime('now', '-30 days')
      ''');

      // Sync metrics
      final syncMetrics = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_offline_reports,
          COUNT(CASE WHEN is_synced = 1 THEN 1 END) as synced_reports,
          AVG(sync_attempts) as avg_sync_attempts
        FROM ${DatabaseService._healthReportsTable}
        WHERE is_offline = 1
      ''');

      // User engagement metrics
      final engagementMetrics = await db.rawQuery('''
        SELECT 
          COUNT(DISTINCT user_id) as active_users,
          COUNT(*) as total_activities,
          AVG(activities_per_user) as avg_activities_per_user
        FROM (
          SELECT 
            user_id,
            COUNT(*) as activities_per_user
          FROM ${DatabaseService._healthReportsTable}
          WHERE reported_at >= datetime('now', '-7 days')
          GROUP BY user_id
        )
      ''');

      return {
        'response_time': responseTimeMetrics.isNotEmpty ? responseTimeMetrics.first : {},
        'sync': syncMetrics.isNotEmpty ? syncMetrics.first : {},
        'engagement': engagementMetrics.isNotEmpty ? engagementMetrics.first : {},
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to get performance metrics: $e');
      return {};
    }
  }

  // Get data quality metrics
  static Future<Map<String, dynamic>> getDataQualityMetrics() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      // Health reports data quality
      final reportQuality = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_reports,
          COUNT(CASE WHEN description IS NOT NULL AND description != '' THEN 1 END) as reports_with_description,
          COUNT(CASE WHEN latitude IS NOT NULL AND longitude IS NOT NULL THEN 1 END) as reports_with_location,
          COUNT(CASE WHEN ai_analysis IS NOT NULL THEN 1 END) as reports_with_ai_analysis,
          COUNT(CASE WHEN photo_urls IS NOT NULL AND photo_urls != '[]' THEN 1 END) as reports_with_photos
        FROM ${DatabaseService._healthReportsTable}
      ''');

      // User data quality
      final userQuality = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_users,
          COUNT(CASE WHEN is_verified = 1 THEN 1 END) as verified_users,
          COUNT(CASE WHEN professional_id IS NOT NULL THEN 1 END) as users_with_professional_id,
          COUNT(CASE WHEN district_id IS NOT NULL THEN 1 END) as users_with_district
        FROM ${DatabaseService._usersTable}
        WHERE is_active = 1
      ''');

      // IoT data quality
      final iotQuality = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_sensor_readings,
          COUNT(CASE WHEN quality_score IS NOT NULL THEN 1 END) as readings_with_quality_score,
          COUNT(CASE WHEN is_anomaly = 1 THEN 1 END) as anomaly_readings,
          AVG(quality_score) as avg_quality_score
        FROM ${DatabaseService._iotSensorDataTable}
        WHERE recorded_at >= datetime('now', '-7 days')
      ''');

      return {
        'reports': reportQuality.isNotEmpty ? reportQuality.first : {},
        'users': userQuality.isNotEmpty ? userQuality.first : {},
        'iot': iotQuality.isNotEmpty ? iotQuality.first : {},
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to get data quality metrics: $e');
      return {};
    }
  }

  // Get predictive insights
  static Future<List<Map<String, dynamic>>> getPredictiveInsights() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      // Trend analysis for next 7 days
      final trendAnalysis = await db.rawQuery('''
        SELECT 
          district_id,
          COUNT(*) as recent_reports,
          AVG(CASE WHEN severity = 'critical' THEN 1.0 ELSE 0.0 END) as critical_ratio,
          AVG(CASE WHEN severity = 'high' THEN 1.0 ELSE 0.0 END) as high_ratio,
          COUNT(*) * 1.2 as predicted_reports
        FROM ${DatabaseService._healthReportsTable}
        WHERE reported_at >= datetime('now', '-7 days')
        GROUP BY district_id
        HAVING recent_reports > 0
        ORDER BY predicted_reports DESC
      ''');

      // Risk escalation prediction
      final riskEscalation = await db.rawQuery('''
        SELECT 
          d.id as district_id,
          d.name as district_name,
          d.risk_score,
          d.risk_level,
          COUNT(hr.id) as recent_critical_reports,
          CASE 
            WHEN COUNT(hr.id) > 5 THEN 'HIGH'
            WHEN COUNT(hr.id) > 2 THEN 'MEDIUM'
            ELSE 'LOW'
          END as escalation_risk
        FROM ${DatabaseService._districtsTable} d
        LEFT JOIN ${DatabaseService._healthReportsTable} hr ON d.id = hr.district_id
        WHERE hr.reported_at >= datetime('now', '-3 days')
        AND hr.severity = 'critical'
        GROUP BY d.id, d.name, d.risk_score, d.risk_level
        ORDER BY recent_critical_reports DESC
      ''');

      return [
        {'type': 'trend_analysis', 'data': trendAnalysis},
        {'type': 'risk_escalation', 'data': riskEscalation},
      ];
    } catch (e) {
      print('Failed to get predictive insights: $e');
      return [];
    }
  }

  // Get resource utilization
  static Future<List<Map<String, dynamic>>> getResourceUtilization() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      final result = await db.rawQuery('''
        SELECT 
          r.type as resource_type,
          SUM(r.quantity) as total_quantity,
          COUNT(DISTINCT r.district_id) as districts_covered,
          AVG(r.quantity) as avg_quantity_per_district,
          COUNT(CASE WHEN r.status = 'available' THEN 1 END) as available_count,
          COUNT(CASE WHEN r.status = 'low_stock' THEN 1 END) as low_stock_count,
          COUNT(CASE WHEN r.status = 'unavailable' THEN 1 END) as unavailable_count
        FROM ${DatabaseService._resourcesTable} r
        GROUP BY r.type
        ORDER BY total_quantity DESC
      ''');

      return result;
    } catch (e) {
      print('Failed to get resource utilization: $e');
      return [];
    }
  }

  // Get compliance metrics
  static Future<Map<String, dynamic>> getComplianceMetrics() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      // Report processing compliance
      final reportCompliance = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_reports,
          COUNT(CASE WHEN processed_at IS NOT NULL THEN 1 END) as processed_reports,
          COUNT(CASE WHEN processed_at IS NOT NULL AND 
            (julianday(processed_at) - julianday(reported_at)) * 24 <= 24 THEN 1 END) as processed_within_24h,
          COUNT(CASE WHEN processed_at IS NOT NULL AND 
            (julianday(processed_at) - julianday(reported_at)) * 24 <= 48 THEN 1 END) as processed_within_48h
        FROM ${DatabaseService._healthReportsTable}
        WHERE reported_at >= datetime('now', '-30 days')
      ''');

      // User verification compliance
      final userCompliance = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_users,
          COUNT(CASE WHEN is_verified = 1 THEN 1 END) as verified_users,
          COUNT(CASE WHEN role = 'healthOfficial' AND is_verified = 1 THEN 1 END) as verified_officials,
          COUNT(CASE WHEN role = 'ashaWorker' AND is_verified = 1 THEN 1 END) as verified_asha_workers
        FROM ${DatabaseService._usersTable}
        WHERE is_active = 1
      ''');

      return {
        'reports': reportCompliance.isNotEmpty ? reportCompliance.first : {},
        'users': userCompliance.isNotEmpty ? userCompliance.first : {},
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to get compliance metrics: $e');
      return {};
    }
  }

  // Execute custom query
  static Future<List<Map<String, dynamic>>> executeCustomQuery(
    String sql,
    List<dynamic>? parameters,
  ) async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      final result = await db.rawQuery(sql, parameters ?? []);
      return result;
    } catch (e) {
      print('Custom query failed: $e');
      return [];
    }
  }

  // Get database performance info
  static Future<Map<String, dynamic>> getDatabasePerformanceInfo() async {
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    try {
      final tableSizes = await db.rawQuery('''
        SELECT 
          name as table_name,
          (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = m.name) as row_count
        FROM sqlite_master m
        WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
      ''');

      final indexInfo = await db.rawQuery('''
        SELECT 
          name as index_name,
          tbl_name as table_name,
          sql as index_sql
        FROM sqlite_master
        WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
      ''');

      return {
        'table_sizes': tableSizes,
        'indexes': indexInfo,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to get database performance info: $e');
      return {};
    }
  }
}

