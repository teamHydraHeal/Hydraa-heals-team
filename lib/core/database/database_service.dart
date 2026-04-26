import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';


class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'jal_guard_enhanced.db';
  static const int _databaseVersion = 2;

  // Table names - Public constants for DAO access
  static const String usersTable = 'users';
  static const String healthReportsTable = 'health_reports';
  static const String districtsTable = 'districts';
  static const String notificationsTable = 'notifications';
  static const String iotSensorDataTable = 'iot_sensor_data';
  static const String riskAnalysisTable = 'risk_analysis';
  static const String syncQueueTable = 'sync_queue';
  static const String userPreferencesTable = 'user_preferences';
  static const String cachedDataTable = 'cached_data';
  static const String actionPlansTable = 'action_plans';
  static const String resourcesTable = 'resources';
  static const String mcpCardsTable = 'mcp_cards';
  static const String educationalContentTable = 'educational_content';

  // Initialize database
  static Future<void> initialize() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: _onDatabaseOpen,
      );
      
      print('Enhanced database initialized successfully');
      await _seedInitialData();
    } catch (e) {
      print('Failed to initialize enhanced database: $e');
      rethrow;
    }
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    await db.transaction((txn) async {
      // Users table
      await txn.execute('''
        CREATE TABLE $usersTable (
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
          last_login TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          profile_data TEXT,
          verification_documents TEXT
        )
      ''');

      // Health reports table
      await txn.execute('''
        CREATE TABLE $healthReportsTable (
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
          block_id TEXT,
          village_id TEXT,
          is_offline INTEGER NOT NULL DEFAULT 1,
          is_synced INTEGER NOT NULL DEFAULT 0,
          sync_attempts INTEGER NOT NULL DEFAULT 0,
          last_sync_attempt TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES $usersTable (id)
        )
      ''');

      // Districts table
      await txn.execute('''
        CREATE TABLE $districtsTable (
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
          iot_sensor_count INTEGER NOT NULL DEFAULT 0,
          health_centers_count INTEGER NOT NULL DEFAULT 0,
          asha_workers_count INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Notifications table
      await txn.execute('''
        CREATE TABLE $notificationsTable (
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
          FOREIGN KEY (user_id) REFERENCES $usersTable (id)
        )
      ''');

      // IoT Sensor Data table
      await txn.execute('''
        CREATE TABLE $iotSensorDataTable (
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
      ''');

      // Risk Analysis table
      await txn.execute('''
        CREATE TABLE $riskAnalysisTable (
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
          FOREIGN KEY (district_id) REFERENCES $_districtsTable (id)
        )
      ''');

      // Sync Queue table
      await txn.execute('''
        CREATE TABLE $syncQueueTable (
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
      ''');

      // User Preferences table
      await txn.execute('''
        CREATE TABLE $userPreferencesTable (
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
          FOREIGN KEY (user_id) REFERENCES $usersTable (id)
        )
      ''');

      // Cached Data table
      await txn.execute('''
        CREATE TABLE $cachedDataTable (
          id TEXT PRIMARY KEY,
          cache_key TEXT UNIQUE NOT NULL,
          data_type TEXT NOT NULL,
          data TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          access_count INTEGER NOT NULL DEFAULT 0,
          last_accessed TEXT
        )
      ''');

      // Action Plans table
      await txn.execute('''
        CREATE TABLE $actionPlansTable (
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
          FOREIGN KEY (district_id) REFERENCES $_districtsTable (id)
        )
      ''');

      // Resources table
      await txn.execute('''
        CREATE TABLE $resourcesTable (
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
      ''');

      // MCP Cards table
      await txn.execute('''
        CREATE TABLE $mcpCardsTable (
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
          FOREIGN KEY (asha_worker_id) REFERENCES $_usersTable (id)
        )
      ''');

      // Educational Content table
      await txn.execute('''
        CREATE TABLE $educationalContentTable (
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
      ''');

      // Create indexes for performance
      await _createIndexes(txn);
    });

    print('Enhanced database tables created successfully');
  }

  // Create database indexes
  static Future<void> _createIndexes(Database db) async {
    // Health reports indexes
    await db.execute('CREATE INDEX idx_health_reports_user_id ON $_healthReportsTable (user_id)');
    await db.execute('CREATE INDEX idx_health_reports_district_id ON $_healthReportsTable (district_id)');
    await db.execute('CREATE INDEX idx_health_reports_severity ON $_healthReportsTable (severity)');
    await db.execute('CREATE INDEX idx_health_reports_reported_at ON $_healthReportsTable (reported_at)');
    await db.execute('CREATE INDEX idx_health_reports_status ON $_healthReportsTable (status)');
    await db.execute('CREATE INDEX idx_health_reports_location ON $_healthReportsTable (latitude, longitude)');

    // IoT sensor data indexes
    await db.execute('CREATE INDEX idx_iot_sensor_data_sensor_id ON $iotSensorDataTable (sensor_id)');
    await db.execute('CREATE INDEX idx_iot_sensor_data_district_id ON $iotSensorDataTable (district_id)');
    await db.execute('CREATE INDEX idx_iot_sensor_data_recorded_at ON $iotSensorDataTable (recorded_at)');
    await db.execute('CREATE INDEX idx_iot_sensor_data_type ON $iotSensorDataTable (sensor_type)');

    // Notifications indexes
    await db.execute('CREATE INDEX idx_notifications_user_id ON $notificationsTable (user_id)');
    await db.execute('CREATE INDEX idx_notifications_is_read ON $notificationsTable (is_read)');
    await db.execute('CREATE INDEX idx_notifications_sent_at ON $notificationsTable (sent_at)');

    // Risk analysis indexes
    await db.execute('CREATE INDEX idx_risk_analysis_district_id ON $riskAnalysisTable (district_id)');
    await db.execute('CREATE INDEX idx_risk_analysis_analyzed_at ON $riskAnalysisTable (analyzed_at)');

    // Sync queue indexes
    await db.execute('CREATE INDEX idx_sync_queue_priority ON $syncQueueTable (priority)');
    await db.execute('CREATE INDEX idx_sync_queue_created_at ON $syncQueueTable (created_at)');
    await db.execute('CREATE INDEX idx_sync_queue_is_processing ON $syncQueueTable (is_processing)');

    // Cached data indexes
    await db.execute('CREATE INDEX idx_cached_data_cache_key ON $cachedDataTable (cache_key)');
    await db.execute('CREATE INDEX idx_cached_data_expires_at ON $cachedDataTable (expires_at)');

    print('Database indexes created successfully');
  }

  // Upgrade database
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute('ALTER TABLE $_usersTable ADD COLUMN last_login TEXT');
      await db.execute('ALTER TABLE $_usersTable ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
      await db.execute('ALTER TABLE $_usersTable ADD COLUMN profile_data TEXT');
      await db.execute('ALTER TABLE $_usersTable ADD COLUMN verification_documents TEXT');
      
      await db.execute('ALTER TABLE $_healthReportsTable ADD COLUMN block_id TEXT');
      await db.execute('ALTER TABLE $_healthReportsTable ADD COLUMN village_id TEXT');
      await db.execute('ALTER TABLE $_healthReportsTable ADD COLUMN sync_attempts INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $_healthReportsTable ADD COLUMN last_sync_attempt TEXT');
      
      await db.execute('ALTER TABLE $_districtsTable ADD COLUMN iot_sensor_count INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $_districtsTable ADD COLUMN health_centers_count INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $_districtsTable ADD COLUMN asha_workers_count INTEGER NOT NULL DEFAULT 0');
    }
  }

  // Database open callback
  static Future<void> _onDatabaseOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 1000');
    await db.execute('PRAGMA temp_store = MEMORY');
  }

  // Seed initial data
  static Future<void> _seedInitialData() async {
    try {
      // Check if data already exists
      final existingDistricts = await _database!.query(districtsTable, limit: 1);
      if (existingDistricts.isNotEmpty) return;

      // Seed districts
      await _seedDistricts();
      
      // Seed educational content
      await _seedEducationalContent();
      
      // Seed resources
      await _seedResources();
      
      print('Initial data seeded successfully');
    } catch (e) {
      print('Failed to seed initial data: $e');
    }
  }

  // Seed districts data
  static Future<void> _seedDistricts() async {
    final districts = [
      {
        'id': 'east_khasi_hills',
        'name': 'East Khasi Hills',
        'state': 'Meghalaya',
        'latitude': 25.5788,
        'longitude': 91.8933,
        'population': 825922,
        'risk_score': 7.8,
        'risk_level': 'high',
        'active_reports': 23,
        'critical_reports': 3,
        'last_updated': DateTime.now().toIso8601String(),
        'iot_sensor_count': 15,
        'health_centers_count': 8,
        'asha_workers_count': 45,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'west_khasi_hills',
        'name': 'West Khasi Hills',
        'state': 'Meghalaya',
        'latitude': 25.4000,
        'longitude': 90.8000,
        'population': 385601,
        'risk_score': 5.2,
        'risk_level': 'medium',
        'active_reports': 12,
        'critical_reports': 1,
        'last_updated': DateTime.now().toIso8601String(),
        'iot_sensor_count': 8,
        'health_centers_count': 5,
        'asha_workers_count': 28,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'ri_bhoi',
        'name': 'Ri Bhoi',
        'state': 'Meghalaya',
        'latitude': 25.8000,
        'longitude': 91.6000,
        'population': 258380,
        'risk_score': 9.1,
        'risk_level': 'critical',
        'active_reports': 45,
        'critical_reports': 8,
        'last_updated': DateTime.now().toIso8601String(),
        'iot_sensor_count': 12,
        'health_centers_count': 6,
        'asha_workers_count': 32,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'jaintia_hills',
        'name': 'Jaintia Hills',
        'state': 'Meghalaya',
        'latitude': 25.2000,
        'longitude': 92.5000,
        'population': 395124,
        'risk_score': 3.4,
        'risk_level': 'low',
        'active_reports': 5,
        'critical_reports': 0,
        'last_updated': DateTime.now().toIso8601String(),
        'iot_sensor_count': 6,
        'health_centers_count': 4,
        'asha_workers_count': 22,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'garo_hills',
        'name': 'Garo Hills',
        'state': 'Meghalaya',
        'latitude': 25.0000,
        'longitude': 90.3000,
        'population': 317917,
        'risk_score': 6.1,
        'risk_level': 'medium',
        'active_reports': 18,
        'critical_reports': 2,
        'last_updated': DateTime.now().toIso8601String(),
        'iot_sensor_count': 10,
        'health_centers_count': 7,
        'asha_workers_count': 35,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final district in districts) {
      await _database!.insert(districtsTable, district);
    }
  }

  // Seed educational content
  static Future<void> _seedEducationalContent() async {
    final content = [
      {
        'id': 'water_safety_en',
        'title': 'Water Safety Guidelines',
        'content': 'Always boil water for at least 1 minute before drinking. Store water in clean, covered containers.',
        'category': 'water_safety',
        'language': 'en',
        'media_urls': '[]',
        'difficulty_level': 'beginner',
        'target_audience': 'citizen',
        'is_offline_available': 1,
        'download_size': 1024,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'disease_prevention_en',
        'title': 'Disease Prevention',
        'content': 'Wash hands thoroughly with soap and water. Ensure proper sanitation and waste disposal.',
        'category': 'disease_prevention',
        'language': 'en',
        'media_urls': '[]',
        'difficulty_level': 'beginner',
        'target_audience': 'citizen',
        'is_offline_available': 1,
        'download_size': 2048,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'child_health_en',
        'title': 'Child Health Care',
        'content': 'Ensure children receive all scheduled vaccinations. Monitor growth and development regularly.',
        'category': 'child_health',
        'language': 'en',
        'media_urls': '[]',
        'difficulty_level': 'intermediate',
        'target_audience': 'asha_worker',
        'is_offline_available': 1,
        'download_size': 3072,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in content) {
      await _database!.insert(educationalContentTable, item);
    }
  }

  // Seed resources
  static Future<void> _seedResources() async {
    final resources = [
      {
        'id': 'testing_kit_001',
        'name': 'Water Quality Testing Kit',
        'type': 'testing_equipment',
        'quantity': 15,
        'unit': 'kits',
        'district_id': 'east_khasi_hills',
        'location': 'Shillong Health Center',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'medical_supplies_001',
        'name': 'Oral Rehydration Salts',
        'type': 'medical_supplies',
        'quantity': 250,
        'unit': 'packets',
        'district_id': 'ri_bhoi',
        'location': 'Nongpoh Health Center',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'vehicle_001',
        'name': 'Emergency Response Vehicle',
        'type': 'transportation',
        'quantity': 3,
        'unit': 'vehicles',
        'district_id': 'east_khasi_hills',
        'location': 'District Health Office',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final resource in resources) {
      await _database!.insert(resourcesTable, resource);
    }
  }

  // Get database instance
  static Database? get database => _database;

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Database health check
  static Future<Map<String, dynamic>> getHealthStatus() async {
    if (_database == null) {
      return {
        'status': 'error',
        'message': 'Database not initialized',
        'tables': {},
      };
    }

    try {
      final tables = [
        usersTable,
        healthReportsTable,
        districtsTable,
        notificationsTable,
        iotSensorDataTable,
        riskAnalysisTable,
        syncQueueTable,
        userPreferencesTable,
        cachedDataTable,
        actionPlansTable,
        resourcesTable,
        mcpCardsTable,
        educationalContentTable,
      ];

      final tableStats = <String, int>{};
      for (final table in tables) {
        final result = await _database!.rawQuery('SELECT COUNT(*) as count FROM $table');
        tableStats[table] = result.first['count'] as int;
      }

      return {
        'status': 'healthy',
        'message': 'Database is operational',
        'tables': tableStats,
        'version': _databaseVersion,
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Database health check failed: $e',
        'tables': {},
      };
    }
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    if (_database == null) return;

    final tables = [
      usersTable,
      healthReportsTable,
      districtsTable,
      notificationsTable,
      iotSensorDataTable,
      riskAnalysisTable,
      syncQueueTable,
      userPreferencesTable,
      cachedDataTable,
      actionPlansTable,
      resourcesTable,
      mcpCardsTable,
      educationalContentTable,
    ];

    await _database!.transaction((txn) async {
      for (final table in tables) {
        await txn.delete(table);
      }
    });

    print('All database data cleared');
  }

  // Backup database
  static Future<String> backupDatabase() async {
    if (_database == null) {
      throw Exception('Database not initialized');
    }

    final databasesPath = await getDatabasesPath();
    final sourcePath = join(databasesPath, _databaseName);
    final backupPath = join(databasesPath, '${_databaseName}_backup_${DateTime.now().millisecondsSinceEpoch}.db');
    
    await File(sourcePath).copy(backupPath);
    return backupPath;
  }

  // Restore database from backup
  static Future<void> restoreDatabase(String backupPath) async {
    if (_database != null) {
      await _database!.close();
    }

    final databasesPath = await getDatabasesPath();
    final targetPath = join(databasesPath, _databaseName);
    
    await File(backupPath).copy(targetPath);
    await initialize();
  }
}

