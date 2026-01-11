import 'dart:convert';

import '../models/user_model.dart';
import '../models/health_report_model.dart';
import '../models/district_model.dart';
import 'database_service.dart';
import 'dao/user_dao.dart';
import 'dao/health_report_dao.dart';
import 'dao/district_dao.dart';

class SeedService {

  // Seed all sample data
  static Future<void> seedAllData() async {
    try {
      print('Starting database seeding...');
      
      // Check if data already exists
      final existingUsers = await UserDAO.getAllUsers(limit: 1);
      if (existingUsers.isNotEmpty) {
        print('Data already exists, skipping seeding');
        return;
      }

      // Seed in order to maintain foreign key relationships
      await _seedDistricts();
      await _seedUsers();
      await _seedHealthReports();
      await _seedNotifications();
      await _seedIotSensorData();
      await _seedRiskAnalysis();
      await _seedResources();
      await _seedEducationalContent();
      await _seedMcpCards();
      await _seedActionPlans();
      
      print('Database seeding completed successfully');
    } catch (e) {
      print('Failed to seed database: $e');
      rethrow;
    }
  }

  // Seed districts
  static Future<void> _seedDistricts() async {
    print('Seeding districts...');
    
    final districts = [
      District(
        id: 'east_khasi_hills',
        name: 'East Khasi Hills',
        state: 'Meghalaya',
        latitude: 25.5788,
        longitude: 91.8933,
        population: 825922,
        riskScore: 7.8,
        riskLevel: RiskLevel.high,
        activeReports: 23,
        criticalReports: 3,
        lastUpdated: DateTime.now(),
        iotSensorCount: 15,
        healthCentersCount: 8,
        ashaWorkersCount: 45,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      District(
        id: 'west_khasi_hills',
        name: 'West Khasi Hills',
        state: 'Meghalaya',
        latitude: 25.4000,
        longitude: 90.8000,
        population: 385601,
        riskScore: 5.2,
        riskLevel: RiskLevel.medium,
        activeReports: 12,
        criticalReports: 1,
        lastUpdated: DateTime.now(),
        iotSensorCount: 8,
        healthCentersCount: 5,
        ashaWorkersCount: 28,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      District(
        id: 'ri_bhoi',
        name: 'Ri Bhoi',
        state: 'Meghalaya',
        latitude: 25.8000,
        longitude: 91.6000,
        population: 258380,
        riskScore: 9.1,
        riskLevel: RiskLevel.critical,
        activeReports: 45,
        criticalReports: 8,
        lastUpdated: DateTime.now(),
        iotSensorCount: 12,
        healthCentersCount: 6,
        ashaWorkersCount: 32,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      District(
        id: 'jaintia_hills',
        name: 'Jaintia Hills',
        state: 'Meghalaya',
        latitude: 25.2000,
        longitude: 92.5000,
        population: 395124,
        riskScore: 3.4,
        riskLevel: RiskLevel.low,
        activeReports: 5,
        criticalReports: 0,
        lastUpdated: DateTime.now(),
        iotSensorCount: 6,
        healthCentersCount: 4,
        ashaWorkersCount: 22,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      District(
        id: 'garo_hills',
        name: 'Garo Hills',
        state: 'Meghalaya',
        latitude: 25.0000,
        longitude: 90.3000,
        population: 317917,
        riskScore: 6.1,
        riskLevel: RiskLevel.medium,
        activeReports: 18,
        criticalReports: 2,
        lastUpdated: DateTime.now(),
        iotSensorCount: 10,
        healthCentersCount: 7,
        ashaWorkersCount: 35,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final district in districts) {
      await DistrictDAO.createDistrict(district);
    }
  }

  // Seed users
  static Future<void> _seedUsers() async {
    print('Seeding users...');
    
    final users = [
      // Health Officials
      User(
        id: 'health_official_001',
        aadhaarNumber: '123456789012',
        phoneNumber: '+91-9876543210',
        name: 'Dr. Rajesh Kumar',
        role: UserRole.healthOfficial,
        isVerified: true,
        professionalId: 'HO001',
        districtId: 'east_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        profileData: {
          'qualification': 'MD in Public Health',
          'experience': '15 years',
          'specialization': 'Epidemiology',
        },
      ),
      User(
        id: 'health_official_002',
        aadhaarNumber: '123456789013',
        phoneNumber: '+91-9876543211',
        name: 'Dr. Priya Sharma',
        role: UserRole.healthOfficial,
        isVerified: true,
        professionalId: 'HO002',
        districtId: 'ri_bhoi',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        profileData: {
          'qualification': 'MBBS, MPH',
          'experience': '12 years',
          'specialization': 'Community Health',
        },
      ),
      
      // ASHA Workers
      User(
        id: 'asha_worker_001',
        aadhaarNumber: '123456789014',
        phoneNumber: '+91-9876543212',
        name: 'Meera Devi',
        role: UserRole.ashaWorker,
        isVerified: true,
        professionalId: 'ASHA001',
        districtId: 'east_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
        profileData: {
          'area': 'Mawryngkneng',
          'experience': '8 years',
          'patients_served': 150,
        },
      ),
      User(
        id: 'asha_worker_002',
        aadhaarNumber: '123456789015',
        phoneNumber: '+91-9876543213',
        name: 'Sunita Singh',
        role: UserRole.ashaWorker,
        isVerified: true,
        professionalId: 'ASHA002',
        districtId: 'ri_bhoi',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
        isActive: true,
        profileData: {
          'area': 'Nongpoh',
          'experience': '6 years',
          'patients_served': 120,
        },
      ),
      User(
        id: 'asha_worker_003',
        aadhaarNumber: '123456789016',
        phoneNumber: '+91-9876543214',
        name: 'Lakshmi Das',
        role: UserRole.ashaWorker,
        isVerified: true,
        professionalId: 'ASHA003',
        districtId: 'west_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        profileData: {
          'area': 'Nongstoin',
          'experience': '10 years',
          'patients_served': 180,
        },
      ),
      
      // Citizens
      User(
        id: 'citizen_001',
        aadhaarNumber: '123456789017',
        phoneNumber: '+91-9876543215',
        name: 'Amit Singh',
        role: UserRole.citizen,
        isVerified: true,
        districtId: 'east_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 15)),
        isActive: true,
        profileData: {
          'address': 'Shillong, East Khasi Hills',
          'family_size': 4,
        },
      ),
      User(
        id: 'citizen_002',
        aadhaarNumber: '123456789018',
        phoneNumber: '+91-9876543216',
        name: 'Priya Sharma',
        role: UserRole.citizen,
        isVerified: true,
        districtId: 'ri_bhoi',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        profileData: {
          'address': 'Nongpoh, Ri Bhoi',
          'family_size': 3,
        },
      ),
      User(
        id: 'citizen_003',
        aadhaarNumber: '123456789019',
        phoneNumber: '+91-9876543217',
        name: 'Rajesh Kumar',
        role: UserRole.citizen,
        isVerified: true,
        districtId: 'west_khasi_hills',
        state: 'Meghalaya',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 45)),
        isActive: true,
        profileData: {
          'address': 'Nongstoin, West Khasi Hills',
          'family_size': 5,
        },
      ),
    ];

    for (final user in users) {
      await UserDAO.createUser(user);
    }
  }

  // Seed health reports
  static Future<void> _seedHealthReports() async {
    print('Seeding health reports...');
    
    final reports = [
      HealthReport(
        id: 'report_001',
        userId: 'asha_worker_001',
        reporterName: 'Meera Devi',
        location: 'Mawryngkneng, East Khasi Hills',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'Water contamination detected in village well. Multiple cases of diarrhea reported.',
        symptoms: ['Diarrhea', 'Vomiting', 'Fever'],
        severity: ReportSeverity.high,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        districtId: 'east_khasi_hills',
        blockId: 'Mawryngkneng',
        villageId: 'Mawryngkneng Village',
        isOffline: false,
        isSynced: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      HealthReport(
        id: 'report_002',
        userId: 'asha_worker_002',
        reporterName: 'Sunita Singh',
        location: 'Nongpoh, Ri Bhoi',
        latitude: 25.8000,
        longitude: 91.6000,
        description: 'Critical water quality issue. High turbidity and unusual odor detected.',
        symptoms: ['Diarrhea', 'Fever', 'Dehydration'],
        severity: ReportSeverity.critical,
        status: ReportStatus.pending,
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        districtId: 'ri_bhoi',
        blockId: 'Nongpoh',
        villageId: 'Nongpoh Village',
        isOffline: false,
        isSynced: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      HealthReport(
        id: 'report_003',
        userId: 'citizen_001',
        reporterName: 'Amit Singh',
        location: 'Shillong, East Khasi Hills',
        latitude: 25.5788,
        longitude: 91.8933,
        description: 'Water in my area looks dirty and smells bad. Concerned about health risks.',
        symptoms: ['Nausea'],
        severity: ReportSeverity.medium,
        status: ReportStatus.processed,
        reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(hours: 12)),
        aiAnalysis: 'Water quality concern reported. Recommend immediate water testing and boiling water before consumption.',
        triageResponse: 'Water sample collection scheduled. Community alert issued.',
        districtId: 'east_khasi_hills',
        blockId: 'Shillong',
        villageId: 'Shillong City',
        isOffline: false,
        isSynced: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      HealthReport(
        id: 'report_004',
        userId: 'asha_worker_003',
        reporterName: 'Lakshmi Das',
        location: 'Nongstoin, West Khasi Hills',
        latitude: 25.4000,
        longitude: 90.8000,
        description: 'Disease outbreak suspected. Multiple families reporting similar symptoms.',
        symptoms: ['Diarrhea', 'Vomiting', 'Fever', 'Dehydration'],
        severity: ReportSeverity.high,
        status: ReportStatus.escalated,
        reportedAt: DateTime.now().subtract(const Duration(days: 2)),
        processedAt: DateTime.now().subtract(const Duration(days: 1)),
        aiAnalysis: 'Potential disease outbreak detected. Immediate intervention required.',
        triageResponse: 'Emergency response team deployed. Water source testing initiated.',
        districtId: 'west_khasi_hills',
        blockId: 'Nongstoin',
        villageId: 'Nongstoin Village',
        isOffline: false,
        isSynced: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HealthReport(
        id: 'report_005',
        userId: 'citizen_002',
        reporterName: 'Priya Sharma',
        location: 'Nongpoh, Ri Bhoi',
        latitude: 25.8000,
        longitude: 91.6000,
        description: 'Child showing signs of dehydration. Water source appears contaminated.',
        symptoms: ['Dehydration', 'Diarrhea'],
        severity: ReportSeverity.medium,
        status: ReportStatus.processed,
        reportedAt: DateTime.now().subtract(const Duration(days: 3)),
        processedAt: DateTime.now().subtract(const Duration(days: 2)),
        aiAnalysis: 'Child dehydration case. Immediate medical attention recommended.',
        triageResponse: 'ASHA worker assigned for follow-up. Medical kit provided.',
        districtId: 'ri_bhoi',
        blockId: 'Nongpoh',
        villageId: 'Nongpoh Village',
        isOffline: false,
        isSynced: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    for (final report in reports) {
      await HealthReportDAO.createHealthReport(report);
    }
  }

  // Seed notifications
  static Future<void> _seedNotifications() async {
    print('Seeding notifications...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final notifications = [
      {
        'id': 'notification_001',
        'user_id': 'citizen_001',
        'title': 'Water Quality Alert',
        'message': 'Water contamination detected in your area. Please boil water before drinking.',
        'type': 'alert',
        'severity': 'high',
        'district_id': 'east_khasi_hills',
        'is_read': 0,
        'sent_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'action_url': '/citizen/dashboard',
        'metadata': json.encode({'report_id': 'report_001'}),
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'id': 'notification_002',
        'user_id': 'asha_worker_001',
        'title': 'New Report Assignment',
        'message': 'You have been assigned to investigate water contamination in Mawryngkneng.',
        'type': 'assignment',
        'severity': 'medium',
        'district_id': 'east_khasi_hills',
        'is_read': 0,
        'sent_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'action_url': '/field-worker/report-form',
        'metadata': json.encode({'report_id': 'report_001'}),
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'notification_003',
        'user_id': 'health_official_001',
        'title': 'Critical Alert - Ri Bhoi',
        'message': 'Critical water quality issue reported in Ri Bhoi district. Immediate action required.',
        'type': 'alert',
        'severity': 'critical',
        'district_id': 'ri_bhoi',
        'is_read': 1,
        'sent_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'read_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'action_url': '/health-official/dashboard',
        'metadata': json.encode({'report_id': 'report_002'}),
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      },
    ];

    for (final notification in notifications) {
      await db.insert(DatabaseService.notificationsTable, notification);
    }
  }

  // Seed IoT sensor data
  static Future<void> _seedIotSensorData() async {
    print('Seeding IoT sensor data...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final sensorData = [
      {
        'id': 'sensor_001',
        'sensor_id': 'water_quality_001',
        'sensor_type': 'water_quality',
        'value': 6.2,
        'unit': 'pH',
        'latitude': 25.5788,
        'longitude': 91.8933,
        'district_id': 'east_khasi_hills',
        'recorded_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        'quality_score': 0.3,
        'is_anomaly': 1,
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      },
      {
        'id': 'sensor_002',
        'sensor_id': 'temperature_001',
        'sensor_type': 'temperature',
        'value': 28.5,
        'unit': '°C',
        'latitude': 25.5788,
        'longitude': 91.8933,
        'district_id': 'east_khasi_hills',
        'recorded_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        'quality_score': 0.8,
        'is_anomaly': 0,
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      },
      {
        'id': 'sensor_003',
        'sensor_id': 'humidity_001',
        'sensor_type': 'humidity',
        'value': 85.2,
        'unit': '%',
        'latitude': 25.5788,
        'longitude': 91.8933,
        'district_id': 'east_khasi_hills',
        'recorded_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'quality_score': 0.7,
        'is_anomaly': 0,
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      },
    ];

    for (final data in sensorData) {
      await db.insert(DatabaseService.iotSensorDataTable, data);
    }
  }

  // Seed risk analysis
  static Future<void> _seedRiskAnalysis() async {
    print('Seeding risk analysis...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final riskAnalysis = [
      {
        'id': 'risk_001',
        'district_id': 'east_khasi_hills',
        'risk_score': 7.8,
        'risk_level': 'high',
        'factors': json.encode({
          'water_quality': 0.4,
          'disease_reports': 0.3,
          'environmental': 0.2,
          'population_density': 0.1,
        }),
        'iot_contribution': 0.4,
        'report_contribution': 0.3,
        'historical_contribution': 0.3,
        'predicted_trend': 'increasing',
        'confidence_score': 0.85,
        'analyzed_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(hours: 23)).toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'id': 'risk_002',
        'district_id': 'ri_bhoi',
        'risk_score': 9.1,
        'risk_level': 'critical',
        'factors': json.encode({
          'water_quality': 0.5,
          'disease_reports': 0.4,
          'environmental': 0.1,
          'population_density': 0.0,
        }),
        'iot_contribution': 0.5,
        'report_contribution': 0.4,
        'historical_contribution': 0.1,
        'predicted_trend': 'increasing',
        'confidence_score': 0.92,
        'analyzed_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(hours: 22)).toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    for (final analysis in riskAnalysis) {
      await db.insert(DatabaseService.riskAnalysisTable, analysis);
    }
  }

  // Seed resources
  static Future<void> _seedResources() async {
    print('Seeding resources...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final resources = [
      {
        'id': 'resource_001',
        'name': 'Water Quality Testing Kit',
        'type': 'testing_equipment',
        'quantity': 15,
        'unit': 'kits',
        'district_id': 'east_khasi_hills',
        'location': 'Shillong Health Center',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'resource_002',
        'name': 'Oral Rehydration Salts',
        'type': 'medical_supplies',
        'quantity': 250,
        'unit': 'packets',
        'district_id': 'ri_bhoi',
        'location': 'Nongpoh Health Center',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'resource_003',
        'name': 'Emergency Response Vehicle',
        'type': 'transportation',
        'quantity': 3,
        'unit': 'vehicles',
        'district_id': 'east_khasi_hills',
        'location': 'District Health Office',
        'status': 'available',
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final resource in resources) {
      await db.insert(DatabaseService.resourcesTable, resource);
    }
  }

  // Seed educational content
  static Future<void> _seedEducationalContent() async {
    print('Seeding educational content...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final content = [
      {
        'id': 'education_001',
        'title': 'Water Safety Guidelines',
        'content': 'Always boil water for at least 1 minute before drinking. Store water in clean, covered containers.',
        'category': 'water_safety',
        'language': 'en',
        'media_urls': json.encode([]),
        'difficulty_level': 'beginner',
        'target_audience': 'citizen',
        'is_offline_available': 1,
        'download_size': 1024,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'education_002',
        'title': 'Disease Prevention',
        'content': 'Wash hands thoroughly with soap and water. Ensure proper sanitation and waste disposal.',
        'category': 'disease_prevention',
        'language': 'en',
        'media_urls': json.encode([]),
        'difficulty_level': 'beginner',
        'target_audience': 'citizen',
        'is_offline_available': 1,
        'download_size': 2048,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'education_003',
        'title': 'Child Health Care',
        'content': 'Ensure children receive all scheduled vaccinations. Monitor growth and development regularly.',
        'category': 'child_health',
        'language': 'en',
        'media_urls': json.encode([]),
        'difficulty_level': 'intermediate',
        'target_audience': 'asha_worker',
        'is_offline_available': 1,
        'download_size': 3072,
        'last_updated': DateTime.now().toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in content) {
      await db.insert(DatabaseService.educationalContentTable, item);
    }
  }

  // Seed MCP cards
  static Future<void> _seedMcpCards() async {
    print('Seeding MCP cards...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final mcpCards = [
      {
        'id': 'mcp_001',
        'patient_id': 'patient_001',
        'patient_name': 'Priya Sharma',
        'mother_name': 'Sunita Sharma',
        'date_of_birth': '2023-05-15',
        'gender': 'female',
        'address': 'Nongpoh, Ri Bhoi, Meghalaya',
        'phone_number': '+91-9876543216',
        'asha_worker_id': 'asha_worker_002',
        'vaccination_records': json.encode({
          'bcg': '2023-05-20',
          'dpt1': '2023-06-15',
          'dpt2': '2023-07-15',
          'dpt3': '2023-08-15',
        }),
        'growth_records': json.encode({
          'birth_weight': 3.2,
          'current_weight': 6.8,
          'height': 65.5,
        }),
        'health_issues': json.encode([]),
        'last_visit': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'next_visit': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'is_synced': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final card in mcpCards) {
      await db.insert(DatabaseService.mcpCardsTable, card);
    }
  }

  // Seed action plans
  static Future<void> _seedActionPlans() async {
    print('Seeding action plans...');
    
    final db = DatabaseService.database;
    if (db == null) throw Exception('Database not initialized');

    final actionPlans = [
      {
        'id': 'action_plan_001',
        'district_id': 'ri_bhoi',
        'situation': 'Critical water contamination detected in multiple locations',
        'actions': json.encode([
          {'id': 'action_1', 'description': 'Deploy water testing teams', 'completed': false, 'priority': 'critical'},
          {'id': 'action_2', 'description': 'Distribute water purification tablets', 'completed': false, 'priority': 'high'},
          {'id': 'action_3', 'description': 'Set up emergency water supply', 'completed': true, 'priority': 'critical'},
        ]),
        'resources': json.encode([
          {'name': 'Water Testing Kits', 'quantity': 10, 'status': 'available'},
          {'name': 'Purification Tablets', 'quantity': 500, 'status': 'available'},
          {'name': 'Emergency Water Tankers', 'quantity': 2, 'status': 'deployed'},
        ]),
        'timeline': 'Immediate response required. Complete within 24 hours.',
        'generated_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'status': 'active',
        'created_by': 'health_official_002',
        'is_synced': 1,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    for (final plan in actionPlans) {
      await db.insert(DatabaseService.actionPlansTable, plan);
    }
  }

  // Clear all seeded data
  static Future<void> clearSeededData() async {
    try {
      print('Clearing seeded data...');
      await DatabaseService.clearAllData();
      print('Seeded data cleared successfully');
    } catch (e) {
      print('Failed to clear seeded data: $e');
      rethrow;
    }
  }

  // Re-seed data (clear and seed again)
  static Future<void> reseedData() async {
    try {
      await clearSeededData();
      await seedAllData();
    } catch (e) {
      print('Failed to re-seed data: $e');
      rethrow;
    }
  }
}

