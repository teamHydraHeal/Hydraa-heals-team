import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../models/health_report_model.dart';
import '../models/district_model.dart';
import 'database_service.dart';

class ValidationService {
  // Validate user data
  static ValidationResult validateUser(User user) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required field validation
    if (user.id.isEmpty) {
      errors.add('User ID is required');
    }

    if (user.aadhaarNumber.isEmpty) {
      errors.add('Aadhaar number is required');
    } else if (!_isValidAadhaar(user.aadhaarNumber)) {
      errors.add('Invalid Aadhaar number format');
    }

    if (user.phoneNumber.isEmpty) {
      errors.add('Phone number is required');
    } else if (!_isValidPhoneNumber(user.phoneNumber)) {
      errors.add('Invalid phone number format');
    }

    if (user.name.isEmpty) {
      errors.add('Name is required');
    } else if (user.name.length < 2) {
      warnings.add('Name is very short');
    }

    // Role-specific validation
    if (user.role == UserRole.healthOfficial || user.role == UserRole.ashaWorker) {
      if (user.professionalId == null || user.professionalId!.isEmpty) {
        errors.add('Professional ID is required for ${user.role.toString().split('.').last}');
      }
    }

    if (user.districtId == null || user.districtId!.isEmpty) {
      warnings.add('District ID is not specified');
    }

    // Date validation
    if (user.createdAt.isAfter(DateTime.now())) {
      errors.add('Created date cannot be in the future');
    }

    if (user.updatedAt.isBefore(user.createdAt)) {
      errors.add('Updated date cannot be before created date');
    }

    if (user.lastLogin != null && user.lastLogin!.isAfter(DateTime.now())) {
      errors.add('Last login date cannot be in the future');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate health report data
  static ValidationResult validateHealthReport(HealthReport report) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required field validation
    if (report.id.isEmpty) {
      errors.add('Report ID is required');
    }

    if (report.userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (report.reporterName.isEmpty) {
      errors.add('Reporter name is required');
    }

    if (report.location.isEmpty) {
      errors.add('Location is required');
    }

    if (report.description.isEmpty) {
      errors.add('Description is required');
    } else if (report.description.length < 10) {
      warnings.add('Description is very short');
    }

    if (report.symptoms.isEmpty) {
      errors.add('At least one symptom is required');
    }

    // Coordinate validation
    if (report.latitude < -90 || report.latitude > 90) {
      errors.add('Invalid latitude value');
    }

    if (report.longitude < -180 || report.longitude > 180) {
      errors.add('Invalid longitude value');
    }

    // Date validation
    if (report.reportedAt.isAfter(DateTime.now())) {
      errors.add('Reported date cannot be in the future');
    }

    if (report.processedAt != null && report.processedAt!.isBefore(report.reportedAt)) {
      errors.add('Processed date cannot be before reported date');
    }

    if (report.createdAt.isAfter(DateTime.now())) {
      errors.add('Created date cannot be in the future');
    }

    if (report.updatedAt.isBefore(report.createdAt)) {
      errors.add('Updated date cannot be before created date');
    }

    // Photo URL validation
    for (final url in report.photoUrls) {
      if (!_isValidUrl(url)) {
        warnings.add('Invalid photo URL: $url');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate district data
  static ValidationResult validateDistrict(District district) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required field validation
    if (district.id.isEmpty) {
      errors.add('District ID is required');
    }

    if (district.name.isEmpty) {
      errors.add('District name is required');
    }

    if (district.state.isEmpty) {
      errors.add('State is required');
    }

    // Coordinate validation
    if (district.latitude < -90 || district.latitude > 90) {
      errors.add('Invalid latitude value');
    }

    if (district.longitude < -180 || district.longitude > 180) {
      errors.add('Invalid longitude value');
    }

    // Population validation
    if (district.population <= 0) {
      errors.add('Population must be greater than 0');
    } else if (district.population > 10000000) {
      warnings.add('Population seems unusually high');
    }

    // Risk score validation
    if (district.riskScore < 0 || district.riskScore > 10) {
      errors.add('Risk score must be between 0 and 10');
    }

    // Report count validation
    if (district.activeReports < 0) {
      errors.add('Active reports count cannot be negative');
    }

    if (district.criticalReports < 0) {
      errors.add('Critical reports count cannot be negative');
    }

    if (district.criticalReports > district.activeReports) {
      warnings.add('Critical reports cannot exceed active reports');
    }

    // Date validation
    if (district.lastUpdated.isAfter(DateTime.now())) {
      errors.add('Last updated date cannot be in the future');
    }

    if (district.createdAt.isAfter(DateTime.now())) {
      errors.add('Created date cannot be in the future');
    }

    if (district.updatedAt.isBefore(district.createdAt)) {
      errors.add('Updated date cannot be before created date');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate IoT sensor data
  static ValidationResult validateIotSensorData(Map<String, dynamic> sensorData) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required field validation
    if (sensorData['sensor_id'] == null || sensorData['sensor_id'].toString().isEmpty) {
      errors.add('Sensor ID is required');
    }

    if (sensorData['sensor_type'] == null || sensorData['sensor_type'].toString().isEmpty) {
      errors.add('Sensor type is required');
    }

    if (sensorData['value'] == null) {
      errors.add('Sensor value is required');
    } else {
      final value = double.tryParse(sensorData['value'].toString());
      if (value == null) {
        errors.add('Sensor value must be a number');
      }
    }

    if (sensorData['unit'] == null || sensorData['unit'].toString().isEmpty) {
      errors.add('Unit is required');
    }

    // Coordinate validation
    if (sensorData['latitude'] == null) {
      errors.add('Latitude is required');
    } else {
      final lat = double.tryParse(sensorData['latitude'].toString());
      if (lat == null || lat < -90 || lat > 90) {
        errors.add('Invalid latitude value');
      }
    }

    if (sensorData['longitude'] == null) {
      errors.add('Longitude is required');
    } else {
      final lng = double.tryParse(sensorData['longitude'].toString());
      if (lng == null || lng < -180 || lng > 180) {
        errors.add('Invalid longitude value');
      }
    }

    // Quality score validation
    if (sensorData['quality_score'] != null) {
      final qualityScore = double.tryParse(sensorData['quality_score'].toString());
      if (qualityScore == null || qualityScore < 0 || qualityScore > 1) {
        errors.add('Quality score must be between 0 and 1');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate JSON data
  static ValidationResult validateJsonData(String jsonString) {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      final data = json.decode(jsonString);
      if (data is! Map<String, dynamic>) {
        errors.add('JSON must be an object');
      }
    } catch (e) {
      errors.add('Invalid JSON format: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate database integrity
  static Future<ValidationResult> validateDatabaseIntegrity() async {
    final db = DatabaseService.database;
    if (db == null) {
      return ValidationResult(
        isValid: false,
        errors: ['Database not initialized'],
        warnings: [],
      );
    }

    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Check foreign key constraints
      final foreignKeyViolations = await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeyViolations.isNotEmpty) {
        errors.add('Foreign key constraint violations found');
        for (final violation in foreignKeyViolations) {
          errors.add('FK violation: ${violation.toString()}');
        }
      }

      // Check for orphaned records
      final orphanedReports = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseService.healthReportsTable} hr
        LEFT JOIN ${DatabaseService.usersTable} u ON hr.user_id = u.id
        WHERE u.id IS NULL
      ''');
      
      final orphanedCount = Sqflite.firstIntValue(orphanedReports) ?? 0;
      if (orphanedCount > 0) {
        errors.add('Found $orphanedCount orphaned health reports');
      }

      // Check for duplicate records
      final duplicateUsers = await db.rawQuery('''
        SELECT aadhaar_number, COUNT(*) as count 
        FROM ${DatabaseService.usersTable} 
        GROUP BY aadhaar_number 
        HAVING COUNT(*) > 1
      ''');
      
      if (duplicateUsers.isNotEmpty) {
        errors.add('Found duplicate Aadhaar numbers');
      }

      // Check data consistency
      final inconsistentReports = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseService.healthReportsTable}
        WHERE is_offline = 1 AND is_synced = 1
      ''');
      
      final inconsistentCount = Sqflite.firstIntValue(inconsistentReports) ?? 0;
      if (inconsistentCount > 0) {
        warnings.add('Found $inconsistentCount reports marked as both offline and synced');
      }

      // Check for missing required data
      final missingDistricts = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseService.healthReportsTable} hr
        LEFT JOIN ${DatabaseService.districtsTable} d ON hr.district_id = d.id
        WHERE hr.district_id IS NOT NULL AND d.id IS NULL
      ''');
      
      final missingCount = Sqflite.firstIntValue(missingDistricts) ?? 0;
      if (missingCount > 0) {
        errors.add('Found $missingCount reports with invalid district references');
      }

    } catch (e) {
      errors.add('Database integrity check failed: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Validate data before sync
  static Future<ValidationResult> validateDataForSync(String tableName, String recordId) async {
    final db = DatabaseService.database;
    if (db == null) {
      return ValidationResult(
        isValid: false,
        errors: ['Database not initialized'],
        warnings: [],
      );
    }

    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Get the record
      final record = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [recordId],
        limit: 1,
      );

      if (record.isEmpty) {
        errors.add('Record not found');
        return ValidationResult(isValid: false, errors: errors, warnings: warnings);
      }

      final data = record.first;

      // Table-specific validation
      switch (tableName) {
        case DatabaseService.usersTable:
          final user = _mapToUser(data);
          final userValidation = validateUser(user);
          errors.addAll(userValidation.errors);
          warnings.addAll(userValidation.warnings);
          break;

        case DatabaseService.healthReportsTable:
          final report = _mapToHealthReport(data);
          final reportValidation = validateHealthReport(report);
          errors.addAll(reportValidation.errors);
          warnings.addAll(reportValidation.warnings);
          break;

        case DatabaseService.districtsTable:
          final district = _mapToDistrict(data);
          final districtValidation = validateDistrict(district);
          errors.addAll(districtValidation.errors);
          warnings.addAll(districtValidation.warnings);
          break;
      }

      // Check for required sync fields
      if (data['is_synced'] == 1) {
        warnings.add('Record is already marked as synced');
      }

    } catch (e) {
      errors.add('Sync validation failed: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  // Helper methods for validation
  static bool _isValidAadhaar(String aadhaar) {
    // Aadhaar should be 12 digits
    final regex = RegExp(r'^\d{12}$');
    return regex.hasMatch(aadhaar);
  }

  static bool _isValidPhoneNumber(String phone) {
    // Indian phone number validation
    final regex = RegExp(r'^(\+91|91)?[6-9]\d{9}$');
    return regex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Helper methods for data conversion (simplified versions)
  static User _mapToUser(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      aadhaarNumber: map['aadhaar_number'] as String,
      phoneNumber: map['phone_number'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
      ),
      isVerified: (map['is_verified'] as int) == 1,
      professionalId: map['professional_id'] as String?,
      districtId: map['district_id'] as String?,
      state: map['state'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastLogin: map['last_login'] != null ? DateTime.parse(map['last_login'] as String) : null,
      isActive: (map['is_active'] as int) == 1,
      profileData: map['profile_data'] != null ? json.decode(map['profile_data'] as String) : null,
      verificationDocuments: map['verification_documents'] != null ? json.decode(map['verification_documents'] as String) : null,
    );
  }

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
      photoUrls: map['photo_urls'] != null ? List<String>.from(json.decode(map['photo_urls'] as String)) : const [],
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

  static District _mapToDistrict(Map<String, dynamic> map) {
    return District(
      id: map['id'] as String,
      name: map['name'] as String,
      state: map['state'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      population: map['population'] as int,
      riskScore: (map['risk_score'] as num).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == 'RiskLevel.${map['risk_level']}',
      ),
      activeReports: map['active_reports'] as int,
      criticalReports: map['critical_reports'] as int,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      polygonCoordinates: map['polygon_coordinates'] != null ? Map<String, dynamic>.from(json.decode(map['polygon_coordinates'] as String)) : null,
      iotSensorCount: map['iot_sensor_count'] as int? ?? 0,
      healthCentersCount: map['health_centers_count'] as int? ?? 0,
      ashaWorkersCount: map['asha_workers_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings)';
  }
}

