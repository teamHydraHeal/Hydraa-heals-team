import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import 'database_service.dart';

class MigrationService {
  static const int _currentVersion = 2;
  static final Map<int, List<String>> _migrations = {
    1: _getV1Migrations(),
    2: _getV2Migrations(),
  };

  // Version 1 migrations (initial schema)
  static List<String> _getV1Migrations() {
    return [
      // Users table
      '''
        CREATE TABLE ${DatabaseService._usersTable} (
          id TEXT PRIMARY KEY,
          aadhaar_number TEXT UNIQUE NOT NULL,
          phone_number TEXT NOT NULL,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          is_verified INTEGER NOT NULL DEFAULT 0,
          professional_id TEXT,
          district_id TEXT,
          state TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          profile_data TEXT
        )
      ''',
      
      // Health reports table
      '''
        CREATE TABLE ${DatabaseService._healthReportsTable} (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          reporter_name TEXT NOT NULL,
          location TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          description TEXT NOT NULL,
          symptoms TEXT NOT NULL,
          severity TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          photo_urls TEXT,
          reported_at TEXT NOT NULL,
          processed_at TEXT,
          ai_analysis TEXT,
          ai_entities TEXT,
          triage_response TEXT,
          district_id TEXT,
          is_offline INTEGER NOT NULL DEFAULT 1,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${DatabaseService._usersTable} (id)
        )
      ''',
      
      // Districts table
      '''
        CREATE TABLE ${DatabaseService._districtsTable} (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          state TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          population INTEGER NOT NULL,
          risk_score REAL NOT NULL DEFAULT 0.0,
          risk_level TEXT NOT NULL DEFAULT 'low',
          active_reports INTEGER NOT NULL DEFAULT 0,
          critical_reports INTEGER NOT NULL DEFAULT 0,
          last_updated TEXT NOT NULL,
          polygon_coordinates TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''',
      
      // Notifications table
      '''
        CREATE TABLE ${DatabaseService._notificationsTable} (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT NOT NULL,
          severity TEXT NOT NULL,
          district_id TEXT,
          is_read INTEGER NOT NULL DEFAULT 0,
          sent_at TEXT NOT NULL,
          read_at TEXT,
          action_url TEXT,
          metadata TEXT,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${DatabaseService._usersTable} (id)
        )
      ''',
      
      // IoT Sensor Data table
      '''
        CREATE TABLE ${DatabaseService._iotSensorDataTable} (
          id TEXT PRIMARY KEY,
          sensor_id TEXT NOT NULL,
          sensor_type TEXT NOT NULL,
          value REAL NOT NULL,
          unit TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          district_id TEXT NOT NULL,
          recorded_at TEXT NOT NULL,
          quality_score REAL,
          is_anomaly INTEGER NOT NULL DEFAULT 0,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''',
      
      // Risk Analysis table
      '''
        CREATE TABLE ${DatabaseService._riskAnalysisTable} (
          id TEXT PRIMARY KEY,
          district_id TEXT NOT NULL,
          risk_score REAL NOT NULL,
          risk_level TEXT NOT NULL,
          factors TEXT NOT NULL,
          iot_contribution REAL,
          report_contribution REAL,
          historical_contribution REAL,
          predicted_trend TEXT,
          confidence_score REAL,
          analyzed_at TEXT NOT NULL,
          valid_until TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (district_id) REFERENCES ${DatabaseService._districtsTable} (id)
        )
      ''',
      
      // Sync Queue table
      '''
        CREATE TABLE ${DatabaseService._syncQueueTable} (
          id TEXT PRIMARY KEY,
          table_name TEXT NOT NULL,
          record_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          data TEXT NOT NULL,
          created_at TEXT NOT NULL,
          retry_count INTEGER NOT NULL DEFAULT 0,
          last_retry TEXT,
          max_retries INTEGER NOT NULL DEFAULT 3,
          priority INTEGER NOT NULL DEFAULT 0,
          is_processing INTEGER NOT NULL DEFAULT 0
        )
      ''',
      
      // User Preferences table
      '''
        CREATE TABLE ${DatabaseService._userPreferencesTable} (
          user_id TEXT PRIMARY KEY,
          language TEXT NOT NULL DEFAULT 'en',
          notification_settings TEXT NOT NULL DEFAULT '{}',
          offline_mode INTEGER NOT NULL DEFAULT 1,
          auto_sync INTEGER NOT NULL DEFAULT 1,
          sync_frequency INTEGER NOT NULL DEFAULT 15,
          last_sync_at TEXT,
          data_usage_limit INTEGER NOT NULL DEFAULT 100,
          theme_preference TEXT NOT NULL DEFAULT 'system',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${DatabaseService._usersTable} (id)
        )
      ''',
      
      // Cached Data table
      '''
        CREATE TABLE ${DatabaseService._cachedDataTable} (
          id TEXT PRIMARY KEY,
          cache_key TEXT UNIQUE NOT NULL,
          data_type TEXT NOT NULL,
          data TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          access_count INTEGER NOT NULL DEFAULT 0,
          last_accessed TEXT
        )
      ''',
      
      // Action Plans table
      '''
        CREATE TABLE ${DatabaseService._actionPlansTable} (
          id TEXT PRIMARY KEY,
          district_id TEXT NOT NULL,
          situation TEXT NOT NULL,
          actions TEXT NOT NULL,
          resources TEXT NOT NULL,
          timeline TEXT NOT NULL,
          generated_at TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          created_by TEXT,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (district_id) REFERENCES ${DatabaseService._districtsTable} (id)
        )
      ''',
      
      // Resources table
      '''
        CREATE TABLE ${DatabaseService._resourcesTable} (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit TEXT NOT NULL,
          district_id TEXT,
          location TEXT,
          status TEXT NOT NULL DEFAULT 'available',
          last_updated TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''',
      
      // MCP Cards table
      '''
        CREATE TABLE ${DatabaseService._mcpCardsTable} (
          id TEXT PRIMARY KEY,
          patient_id TEXT NOT NULL,
          patient_name TEXT NOT NULL,
          mother_name TEXT NOT NULL,
          date_of_birth TEXT NOT NULL,
          gender TEXT NOT NULL,
          address TEXT NOT NULL,
          phone_number TEXT,
          asha_worker_id TEXT NOT NULL,
          vaccination_records TEXT,
          growth_records TEXT,
          health_issues TEXT,
          last_visit TEXT,
          next_visit TEXT,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (asha_worker_id) REFERENCES ${DatabaseService._usersTable} (id)
        )
      ''',
      
      // Educational Content table
      '''
        CREATE TABLE ${DatabaseService._educationalContentTable} (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          category TEXT NOT NULL,
          language TEXT NOT NULL,
          media_urls TEXT,
          difficulty_level TEXT NOT NULL DEFAULT 'beginner',
          target_audience TEXT NOT NULL,
          is_offline_available INTEGER NOT NULL DEFAULT 1,
          download_size INTEGER,
          last_updated TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''',
    ];
  }

  // Version 2 migrations (enhancements)
  static List<String> _getV2Migrations() {
    return [
      // Add new columns to users table
      'ALTER TABLE ${DatabaseService._usersTable} ADD COLUMN last_login TEXT',
      'ALTER TABLE ${DatabaseService._usersTable} ADD COLUMN verification_documents TEXT',
      
      // Add new columns to health reports table
      'ALTER TABLE ${DatabaseService._healthReportsTable} ADD COLUMN block_id TEXT',
      'ALTER TABLE ${DatabaseService._healthReportsTable} ADD COLUMN village_id TEXT',
      'ALTER TABLE ${DatabaseService._healthReportsTable} ADD COLUMN sync_attempts INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE ${DatabaseService._healthReportsTable} ADD COLUMN last_sync_attempt TEXT',
      
      // Add new columns to districts table
      'ALTER TABLE ${DatabaseService._districtsTable} ADD COLUMN iot_sensor_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE ${DatabaseService._districtsTable} ADD COLUMN health_centers_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE ${DatabaseService._districtsTable} ADD COLUMN asha_workers_count INTEGER NOT NULL DEFAULT 0',
      
      // Create new indexes for performance
      'CREATE INDEX IF NOT EXISTS idx_health_reports_block_id ON ${DatabaseService._healthReportsTable} (block_id)',
      'CREATE INDEX IF NOT EXISTS idx_health_reports_village_id ON ${DatabaseService._healthReportsTable} (village_id)',
      'CREATE INDEX IF NOT EXISTS idx_health_reports_sync_attempts ON ${DatabaseService._healthReportsTable} (sync_attempts)',
      'CREATE INDEX IF NOT EXISTS idx_users_last_login ON ${DatabaseService._usersTable} (last_login)',
      'CREATE INDEX IF NOT EXISTS idx_districts_sensor_count ON ${DatabaseService._districtsTable} (iot_sensor_count)',
    ];
  }

  // Run migrations from oldVersion to newVersion
  static Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
    print('Running migrations from version $oldVersion to $newVersion');
    
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      if (_migrations.containsKey(version)) {
        print('Running migration for version $version');
        await _runVersionMigration(db, version);
      }
    }
    
    print('All migrations completed successfully');
  }

  // Run migration for a specific version
  static Future<void> _runVersionMigration(Database db, int version) async {
    final migrations = _migrations[version]!;
    
    await db.transaction((txn) async {
      for (final migration in migrations) {
        try {
          await txn.execute(migration);
          print('Migration executed: ${migration.substring(0, migration.length > 50 ? 50 : migration.length)}...');
        } catch (e) {
          print('Migration failed: $e');
          print('Failed migration: $migration');
          rethrow;
        }
      }
    });
    
    // Update migration history
    await _recordMigration(db, version);
  }

  // Record migration in history
  static Future<void> _recordMigration(Database db, int version) async {
    try {
      // Create migration history table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS migration_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          version INTEGER NOT NULL,
          executed_at TEXT NOT NULL,
          success INTEGER NOT NULL DEFAULT 1,
          error_message TEXT
        )
      ''');
      
      // Record this migration
      await db.insert('migration_history', {
        'version': version,
        'executed_at': DateTime.now().toIso8601String(),
        'success': 1,
      });
    } catch (e) {
      print('Failed to record migration history: $e');
    }
  }

  // Get migration history
  static Future<List<Map<String, dynamic>>> getMigrationHistory(Database db) async {
    try {
      return await db.query('migration_history', orderBy: 'executed_at DESC');
    } catch (e) {
      print('Failed to get migration history: $e');
      return [];
    }
  }

  // Check if migration is needed
  static bool isMigrationNeeded(int currentVersion, int targetVersion) {
    return currentVersion < targetVersion;
  }

  // Get current database version
  static Future<int> getCurrentVersion(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA user_version');
      return result.first['user_version'] as int;
    } catch (e) {
      print('Failed to get current version: $e');
      return 0;
    }
  }

  // Set database version
  static Future<void> setVersion(Database db, int version) async {
    await db.execute('PRAGMA user_version = $version');
  }

  // Validate database schema
  static Future<Map<String, dynamic>> validateSchema(Database db) async {
    final validation = <String, dynamic>{
      'is_valid': true,
      'errors': <String>[],
      'warnings': <String>[],
      'tables': <String, Map<String, dynamic>>{},
    };

    try {
      // Get all tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );

      for (final table in tables) {
        final tableName = table['name'] as String;
        final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
        
        validation['tables'][tableName] = {
          'columns': tableInfo.length,
          'schema': tableInfo,
        };
      }

      // Check for required tables
      final requiredTables = [
        DatabaseService._usersTable,
        DatabaseService._healthReportsTable,
        DatabaseService._districtsTable,
        DatabaseService._notificationsTable,
        DatabaseService._iotSensorDataTable,
        DatabaseService._riskAnalysisTable,
        DatabaseService._syncQueueTable,
        DatabaseService._userPreferencesTable,
        DatabaseService._cachedDataTable,
        DatabaseService._actionPlansTable,
        DatabaseService._resourcesTable,
        DatabaseService._mcpCardsTable,
        DatabaseService._educationalContentTable,
      ];

      for (final requiredTable in requiredTables) {
        if (!validation['tables'].containsKey(requiredTable)) {
          validation['is_valid'] = false;
          validation['errors'].add('Missing required table: $requiredTable');
        }
      }

      // Check for foreign key constraints
      final foreignKeys = await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeys.isNotEmpty) {
        validation['is_valid'] = false;
        validation['errors'].add('Foreign key constraint violations found');
      }

    } catch (e) {
      validation['is_valid'] = false;
      validation['errors'].add('Schema validation failed: $e');
    }

    return validation;
  }

  // Rollback to previous version (for development/testing)
  static Future<void> rollback(Database db, int targetVersion) async {
    print('Rolling back database to version $targetVersion');
    
    // This is a simplified rollback - in production, you'd want more sophisticated rollback logic
    final history = await getMigrationHistory(db);
    final migrationsToRollback = history.where((m) => m['version'] > targetVersion).toList();
    
    for (final migration in migrationsToRollback) {
      print('Rolling back migration version ${migration['version']}');
      // In a real implementation, you'd have rollback scripts for each migration
    }
    
    await setVersion(db, targetVersion);
    print('Rollback completed');
  }

  // Create backup before migration
  static Future<String> createBackupBeforeMigration(Database db) async {
    // This would create a backup of the database before running migrations
    // Implementation depends on your backup strategy
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'backup_before_migration_$timestamp.db';
  }

  // Get migration status
  static Future<Map<String, dynamic>> getMigrationStatus(Database db) async {
    final currentVersion = await getCurrentVersion(db);
    final history = await getMigrationHistory(db);
    final schemaValidation = await validateSchema(db);
    
    return {
      'current_version': currentVersion,
      'target_version': _currentVersion,
      'migration_needed': isMigrationNeeded(currentVersion, _currentVersion),
      'migration_history': history,
      'schema_validation': schemaValidation,
      'last_migration': history.isNotEmpty ? history.first : null,
    };
  }
}

