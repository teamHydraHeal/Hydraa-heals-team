import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../models/health_report_model.dart';
import '../database/database_service.dart';
import '../database/dao/health_report_dao.dart';
import '../database/validation_service.dart';

class OfflineService {
  static Database? _database;

  // Table names
  static const String _reportsTable = 'health_reports';
  static const String _syncQueueTable = 'sync_queue';

  // Initialize database
  static Future<void> initialize() async {
    try {
      // Use the enhanced database service
      await DatabaseService.initialize();
      _database = DatabaseService.database;
      
      print('Enhanced offline database initialized successfully');
    } catch (e) {
      print('Failed to initialize enhanced offline database: $e');
      rethrow;
    }
  }

  // Get database instance
  static Database? get database => _database;

  // Save health report offline
  static Future<void> saveHealthReport(HealthReport report) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      // Validate the report before saving
      await ValidationService.validateHealthReport(report);
      
      // Use the DAO to save the report
      await HealthReportDAO.createHealthReport(report);
      
      // Add to sync queue for later upload
      await _addToSyncQueue('health_report', report.toJson());
      
      print('Health report saved offline: ${report.id}');
    } catch (e) {
      print('Failed to save health report offline: $e');
      rethrow;
    }
  }

  // Get offline health reports
  static Future<List<HealthReport>> getOfflineHealthReports() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        _reportsTable,
        orderBy: 'createdAt DESC',
      );

      return maps.map((map) => HealthReport.fromJson(map)).toList();
    } catch (e) {
      print('Failed to get offline health reports: $e');
      return [];
    }
  }

  // Update health report
  static Future<void> updateHealthReport(HealthReport report) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.update(
        _reportsTable,
        report.toJson(),
        where: 'id = ?',
        whereArgs: [report.id],
      );
      
      // Add to sync queue for later upload
      await _addToSyncQueue('health_report_update', report.toJson());
      
      print('Health report updated offline: ${report.id}');
    } catch (e) {
      print('Failed to update health report offline: $e');
      rethrow;
    }
  }

  // Delete health report
  static Future<void> deleteHealthReport(String reportId) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.delete(
        _reportsTable,
        where: 'id = ?',
        whereArgs: [reportId],
      );
      
      // Add to sync queue for later upload
      await _addToSyncQueue('health_report_delete', {'id': reportId});
      
      print('Health report deleted offline: $reportId');
    } catch (e) {
      print('Failed to delete health report offline: $e');
      rethrow;
    }
  }

  // Add item to sync queue
  static Future<void> _addToSyncQueue(String action, Map<String, dynamic> data) async {
    if (_database == null) return;

    try {
      await _database!.insert(
        _syncQueueTable,
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'action': action,
          'data': json.encode(data),
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'pending',
        },
      );
    } catch (e) {
      print('Failed to add to sync queue: $e');
    }
  }

  // Get sync queue items
  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    if (_database == null) return [];

    try {
      return await _database!.query(
        _syncQueueTable,
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'createdAt ASC',
      );
    } catch (e) {
      print('Failed to get sync queue: $e');
      return [];
    }
  }

  // Mark sync queue item as synced
  static Future<void> markAsSynced(String queueId) async {
    if (_database == null) return;

    try {
      await _database!.update(
        _syncQueueTable,
        {'status': 'synced', 'syncedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [queueId],
      );
    } catch (e) {
      print('Failed to mark as synced: $e');
    }
  }

  // Clear synced items from queue
  static Future<void> clearSyncedItems() async {
    if (_database == null) return;

    try {
      await _database!.delete(
        _syncQueueTable,
        where: 'status = ?',
        whereArgs: ['synced'],
      );
    } catch (e) {
      print('Failed to clear synced items: $e');
    }
  }

  // Get offline data statistics
  static Future<Map<String, int>> getOfflineStats() async {
    if (_database == null) return {};

    try {
      final reportsCount = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_reportsTable',
      );
      
      final syncQueueCount = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_syncQueueTable WHERE status = ?',
        ['pending'],
      );

      return {
        'reports': reportsCount.first['count'] as int,
        'pending_sync': syncQueueCount.first['count'] as int,
      };
    } catch (e) {
      print('Failed to get offline stats: $e');
      return {};
    }
  }

  // Clear all offline data
  static Future<void> clearAllOfflineData() async {
    if (_database == null) return;

    try {
      await _database!.delete(_reportsTable);
      await _database!.delete(_syncQueueTable);
      print('All offline data cleared');
    } catch (e) {
      print('Failed to clear offline data: $e');
    }
  }
}