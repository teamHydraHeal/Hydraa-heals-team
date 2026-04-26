import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../models/health_report_model.dart';
import '../database/database_service.dart';
import '../database/dao/health_report_dao.dart';
import '../database/validation_service.dart';

class OfflineService {
  static Database? _database;
  static const String _databaseName = 'jal_guard_enhanced.db';
  static const int _databaseVersion = 2;

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

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    // Health reports table
    await db.execute('''
      CREATE TABLE $_reportsTable (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        reporterName TEXT NOT NULL,
        location TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        description TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        severity TEXT NOT NULL,
        status TEXT NOT NULL,
        photoUrls TEXT,
        reportedAt TEXT NOT NULL,
        processedAt TEXT,
        aiAnalysis TEXT,
        aiEntities TEXT,
        triageResponse TEXT,
        isOffline INTEGER NOT NULL DEFAULT 1,
        isSynced INTEGER NOT NULL DEFAULT 0,
        data TEXT NOT NULL
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE $_syncQueueTable (
        id TEXT PRIMARY KEY,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        retryCount INTEGER NOT NULL DEFAULT 0,
        lastRetry TEXT
      )
    ''');

    print('Database tables created successfully');
  }

  // Upgrade database
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    print('Database upgraded from version $oldVersion to $newVersion');
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
      final validation = ValidationService.validateHealthReport(report);
      if (!validation.isValid) {
        throw Exception('Health report validation failed: ${validation.errors.join(', ')}');
      }

      // Use the enhanced DAO
      await HealthReportDAO.createHealthReport(report);

      // Add to sync queue if not synced
      if (!report.isSynced) {
        await _addToSyncQueue(_reportsTable, report.id, 'INSERT', report.toJson());
      }

      print('Health report saved offline: ${report.id}');
    } catch (e) {
      print('Failed to save health report offline: $e');
      rethrow;
    }
  }

  // Get all offline health reports
  static Future<List<HealthReport>> getOfflineHealthReports() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      // Use the enhanced DAO
      return await HealthReportDAO.getOfflineHealthReports();
    } catch (e) {
      print('Failed to get offline health reports: $e');
      return [];
    }
  }

  // Get unsynced health reports
  static Future<List<HealthReport>> getUnsyncedHealthReports() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        _reportsTable,
        where: 'isSynced = ?',
        whereArgs: [0],
        orderBy: 'reportedAt ASC',
      );

      return maps.map((map) {
        final data = json.decode(map['data'] as String);
        return HealthReport.fromJson(data);
      }).toList();
    } catch (e) {
      print('Failed to get unsynced health reports: $e');
      return [];
    }
  }

  // Mark report as synced
  static Future<void> markReportAsSynced(String reportId) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.update(
        _reportsTable,
        {'isSynced': 1},
        where: 'id = ?',
        whereArgs: [reportId],
      );

      // Remove from sync queue
      await _removeFromSyncQueue(_reportsTable, reportId);

      print('Report marked as synced: $reportId');
    } catch (e) {
      print('Failed to mark report as synced: $e');
    }
  }

  // Add item to sync queue
  static Future<void> _addToSyncQueue(
    String tableName,
    String recordId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.insert(
        _syncQueueTable,
        {
          'id': '${tableName}_${recordId}_${DateTime.now().millisecondsSinceEpoch}',
          'tableName': tableName,
          'recordId': recordId,
          'operation': operation,
          'data': json.encode(data),
          'createdAt': DateTime.now().toIso8601String(),
          'retryCount': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Failed to add to sync queue: $e');
    }
  }

  // Remove item from sync queue
  static Future<void> _removeFromSyncQueue(String tableName, String recordId) async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.delete(
        _syncQueueTable,
        where: 'tableName = ? AND recordId = ?',
        whereArgs: [tableName, recordId],
      );
    } catch (e) {
      print('Failed to remove from sync queue: $e');
    }
  }

  // Get sync queue items
  static Future<List<Map<String, dynamic>>> getSyncQueueItems() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      return await _database!.query(
        _syncQueueTable,
        orderBy: 'createdAt ASC',
      );
    } catch (e) {
      print('Failed to get sync queue items: $e');
      return [];
    }
  }

  // Clear sync queue
  static Future<void> clearSyncQueue() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await _database!.delete(_syncQueueTable);
      print('Sync queue cleared');
    } catch (e) {
      print('Failed to clear sync queue: $e');
    }
  }

  // Get database size
  static Future<int> getDatabaseSize() async {
    if (_database == null) {
      return 0;
    }

    try {
      final result = await _database!.rawQuery('SELECT COUNT(*) as count FROM $_reportsTable');
      return result.first['count'] as int;
    } catch (e) {
      print('Failed to get database size: $e');
      return 0;
    }
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('Database closed');
    }
  }
}
