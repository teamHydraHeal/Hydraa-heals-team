
import 'database_service.dart';
import 'migration_service.dart';
import 'seed_service.dart';
import 'validation_service.dart';
import 'query_service.dart';

class DatabaseManager {
  static bool _isInitialized = false;
  static bool _isSeeded = false;

  // Initialize the complete database system
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('Database already initialized');
      return;
    }

    try {
      print('Initializing enhanced database system...');
      
      // Step 1: Initialize database service
      await DatabaseService.initialize();
      print('✓ Database service initialized');

      // Step 2: Run migrations if needed
      final db = DatabaseService.database;
      if (db != null) {
        final currentVersion = await MigrationService.getCurrentVersion(db);
        if (MigrationService.isMigrationNeeded(currentVersion, 2)) {
          await MigrationService.runMigrations(db, currentVersion, 2);
          print('✓ Database migrations completed');
        }
      }

      // Step 3: Validate database integrity
      final integrityCheck = await ValidationService.validateDatabaseIntegrity();
      if (!integrityCheck.isValid) {
        print('⚠️ Database integrity issues found:');
        for (final error in integrityCheck.errors) {
          print('  - $error');
        }
        for (final warning in integrityCheck.warnings) {
          print('  - $warning');
        }
      } else {
        print('✓ Database integrity validated');
      }

      // Step 4: Seed initial data if needed
      if (!_isSeeded) {
        await _seedInitialData();
        _isSeeded = true;
        print('✓ Initial data seeded');
      }

      _isInitialized = true;
      print('✓ Enhanced database system initialized successfully');
      
    } catch (e) {
      print('❌ Database initialization failed: $e');
      rethrow;
    }
  }

  // Seed initial data
  static Future<void> _seedInitialData() async {
    try {
      await SeedService.seedAllData();
    } catch (e) {
      print('Failed to seed initial data: $e');
      // Don't rethrow - seeding failure shouldn't prevent app startup
    }
  }

  // Get database health status
  static Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final dbHealth = await DatabaseService.getHealthStatus();
      final integrityCheck = await ValidationService.validateDatabaseIntegrity();
      final performanceInfo = await QueryService.getDatabasePerformanceInfo();

      return {
        'database': dbHealth,
        'integrity': {
          'is_valid': integrityCheck.isValid,
          'errors': integrityCheck.errors,
          'warnings': integrityCheck.warnings,
        },
        'performance': performanceInfo,
        'is_initialized': _isInitialized,
        'is_seeded': _isSeeded,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_initialized': _isInitialized,
        'is_seeded': _isSeeded,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Get comprehensive statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final dashboardStats = await QueryService.getDashboardStatistics();
      final performanceMetrics = await QueryService.getPerformanceMetrics();
      final dataQualityMetrics = await QueryService.getDataQualityMetrics();
      final complianceMetrics = await QueryService.getComplianceMetrics();

      return {
        'dashboard': dashboardStats,
        'performance': performanceMetrics,
        'data_quality': dataQualityMetrics,
        'compliance': complianceMetrics,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'generated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // Backup database
  static Future<String> backupDatabase() async {
    try {
      final backupPath = await DatabaseService.backupDatabase();
      print('✓ Database backed up to: $backupPath');
      return backupPath;
    } catch (e) {
      print('❌ Database backup failed: $e');
      rethrow;
    }
  }

  // Restore database from backup
  static Future<void> restoreDatabase(String backupPath) async {
    try {
      await DatabaseService.restoreDatabase(backupPath);
      _isInitialized = false;
      _isSeeded = false;
      await initialize();
      print('✓ Database restored from: $backupPath');
    } catch (e) {
      print('❌ Database restore failed: $e');
      rethrow;
    }
  }

  // Clear all data and re-seed
  static Future<void> resetDatabase() async {
    try {
      print('Resetting database...');
      await SeedService.clearSeededData();
      await _seedInitialData();
      _isSeeded = true;
      print('✓ Database reset completed');
    } catch (e) {
      print('❌ Database reset failed: $e');
      rethrow;
    }
  }

  // Optimize database
  static Future<void> optimizeDatabase() async {
    try {
      final db = DatabaseService.database;
      if (db == null) throw Exception('Database not initialized');

      // Run VACUUM to optimize database
      await db.execute('VACUUM');
      
      // Update statistics
      await db.execute('ANALYZE');
      
      print('✓ Database optimized');
    } catch (e) {
      print('❌ Database optimization failed: $e');
      rethrow;
    }
  }

  // Validate all data
  static Future<Map<String, dynamic>> validateAllData() async {
    try {
      final integrityCheck = await ValidationService.validateDatabaseIntegrity();
      final dataQualityMetrics = await QueryService.getDataQualityMetrics();

      return {
        'integrity': {
          'is_valid': integrityCheck.isValid,
          'errors': integrityCheck.errors,
          'warnings': integrityCheck.warnings,
        },
        'data_quality': dataQualityMetrics,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Get migration status
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final db = DatabaseService.database;
      if (db == null) throw Exception('Database not initialized');

      return await MigrationService.getMigrationStatus(db);
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Close database
  static Future<void> close() async {
    try {
      await DatabaseService.close();
      _isInitialized = false;
      _isSeeded = false;
      print('✓ Database closed');
    } catch (e) {
      print('❌ Database close failed: $e');
      rethrow;
    }
  }

  // Check if database is ready
  static bool get isReady => _isInitialized;

  // Get database info
  static Map<String, dynamic> getDatabaseInfo() {
    return {
      'is_initialized': _isInitialized,
      'is_seeded': _isSeeded,
      'database_name': DatabaseService._databaseName,
      'database_version': DatabaseService._databaseVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Export database schema
  static Future<String> exportSchema() async {
    try {
      final db = DatabaseService.database;
      if (db == null) throw Exception('Database not initialized');

      final tables = await db.rawQuery(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );

      final schema = StringBuffer();
      schema.writeln('-- Jal Guard Database Schema');
      schema.writeln('-- Generated: ${DateTime.now().toIso8601String()}');
      schema.writeln();

      for (final table in tables) {
        schema.writeln('-- Table: ${table['name']}');
        schema.writeln(table['sql']);
        schema.writeln();
      }

      return schema.toString();
    } catch (e) {
      throw Exception('Failed to export schema: $e');
    }
  }

  // Import data from JSON
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // This would implement data import functionality
      // For now, just log the attempt
      print('Data import requested for ${data.keys.length} tables');
      print('Import functionality to be implemented');
    } catch (e) {
      print('❌ Data import failed: $e');
      rethrow;
    }
  }

  // Export data to JSON
  static Future<Map<String, dynamic>> exportData() async {
    try {
      final db = DatabaseService.database;
      if (db == null) throw Exception('Database not initialized');

      final tables = [
        DatabaseService._usersTable,
        DatabaseService._healthReportsTable,
        DatabaseService._districtsTable,
        DatabaseService._notificationsTable,
        DatabaseService._iotSensorDataTable,
        DatabaseService._riskAnalysisTable,
        DatabaseService._resourcesTable,
        DatabaseService._educationalContentTable,
        DatabaseService._mcpCardsTable,
        DatabaseService._actionPlansTable,
      ];

      final exportData = <String, dynamic>{};
      
      for (final table in tables) {
        try {
          final data = await db.query(table);
          exportData[table] = data;
        } catch (e) {
          print('Failed to export table $table: $e');
        }
      }

      return {
        'exported_at': DateTime.now().toIso8601String(),
        'tables': exportData,
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}
