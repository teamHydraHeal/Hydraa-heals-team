import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../../models/district_model.dart';
import '../database_service.dart';

class DistrictDAO {
  static String get _tableName => DatabaseService.districtsTable;

  // Create district
  static Future<String> createDistrict(District district) async {
    final db = DatabaseService.database!;

    try {
      await db.insert(_tableName, _districtToMap(district));
      return district.id;
    } catch (e) {
      print('Failed to create district: $e');
      rethrow;
    }
  }

  // Get district by ID
  static Future<District?> getDistrictById(String id) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToDistrict(maps.first);
      }
      return null;
    } catch (e) {
      print('Failed to get district by ID: $e');
      return null;
    }
  }

  // Get all districts
  static Future<List<District>> getAllDistricts() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get all districts: $e');
      return [];
    }
  }

  // Get districts by state
  static Future<List<District>> getDistrictsByState(String state) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'state = ?',
        whereArgs: [state],
        orderBy: 'name ASC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get districts by state: $e');
      return [];
    }
  }

  // Get districts by risk level
  static Future<List<District>> getDistrictsByRiskLevel(RiskLevel riskLevel) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'risk_level = ?',
        whereArgs: [riskLevel.toString().split('.').last],
        orderBy: 'risk_score DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get districts by risk level: $e');
      return [];
    }
  }

  // Get high risk districts
  static Future<List<District>> getHighRiskDistricts() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'risk_level IN (?, ?)',
        whereArgs: ['high', 'critical'],
        orderBy: 'risk_score DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get high risk districts: $e');
      return [];
    }
  }

  // Get critical districts
  static Future<List<District>> getCriticalDistricts() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'risk_level = ?',
        whereArgs: ['critical'],
        orderBy: 'risk_score DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get critical districts: $e');
      return [];
    }
  }

  // Get districts with active reports
  static Future<List<District>> getDistrictsWithActiveReports() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'active_reports > ?',
        whereArgs: [0],
        orderBy: 'active_reports DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get districts with active reports: $e');
      return [];
    }
  }

  // Get districts with critical reports
  static Future<List<District>> getDistrictsWithCriticalReports() async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'critical_reports > ?',
        whereArgs: [0],
        orderBy: 'critical_reports DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get districts with critical reports: $e');
      return [];
    }
  }

  // Update district
  static Future<bool> updateDistrict(District district) async {
    final db = DatabaseService.database!;

    try {
      final updatedDistrict = district.copyWith(lastUpdated: DateTime.now());
      final result = await db.update(
        _tableName,
        _districtToMap(updatedDistrict),
        where: 'id = ?',
        whereArgs: [district.id],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update district: $e');
      return false;
    }
  }

  // Update district risk score
  static Future<bool> updateDistrictRiskScore(String districtId, double riskScore, RiskLevel riskLevel) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'risk_score': riskScore,
          'risk_level': riskLevel.toString().split('.').last,
          'last_updated': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [districtId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update district risk score: $e');
      return false;
    }
  }

  // Update district report counts
  static Future<bool> updateDistrictReportCounts(
    String districtId,
    int activeReports,
    int criticalReports,
  ) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'active_reports': activeReports,
          'critical_reports': criticalReports,
          'last_updated': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [districtId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update district report counts: $e');
      return false;
    }
  }

  // Update district IoT sensor count
  static Future<bool> updateDistrictIotSensorCount(String districtId, int sensorCount) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'iot_sensor_count': sensorCount,
          'last_updated': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [districtId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update district IoT sensor count: $e');
      return false;
    }
  }

  // Update district health infrastructure
  static Future<bool> updateDistrictHealthInfrastructure(
    String districtId,
    int healthCentersCount,
    int ashaWorkersCount,
  ) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'health_centers_count': healthCentersCount,
          'asha_workers_count': ashaWorkersCount,
          'last_updated': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [districtId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update district health infrastructure: $e');
      return false;
    }
  }

  // Delete district
  static Future<bool> deleteDistrict(String districtId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [districtId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to delete district: $e');
      return false;
    }
  }

  // Search districts
  static Future<List<District>> searchDistricts(String query) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'name LIKE ? OR state LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to search districts: $e');
      return [];
    }
  }

  // Get district statistics
  static Future<Map<String, dynamic>> getDistrictStatistics() async {
    final db = DatabaseService.database!;

    try {
      final totalDistricts = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName',
      )) ?? 0;

      final highRiskDistricts = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level IN (?, ?)',
        ['high', 'critical'],
      )) ?? 0;

      final criticalDistricts = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level = ?',
        ['critical'],
      )) ?? 0;

      final districtsWithActiveReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE active_reports > ?',
        [0],
      )) ?? 0;

      final totalPopulation = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(population) FROM $_tableName',
      )) ?? 0;

      final totalActiveReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(active_reports) FROM $_tableName',
      )) ?? 0;

      final totalCriticalReports = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(critical_reports) FROM $_tableName',
      )) ?? 0;

      final totalIotSensors = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(iot_sensor_count) FROM $_tableName',
      )) ?? 0;

      final totalHealthCenters = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(health_centers_count) FROM $_tableName',
      )) ?? 0;

      final totalAshaWorkers = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT SUM(asha_workers_count) FROM $_tableName',
      )) ?? 0;

      return {
        'total_districts': totalDistricts,
        'high_risk_districts': highRiskDistricts,
        'critical_districts': criticalDistricts,
        'districts_with_active_reports': districtsWithActiveReports,
        'total_population': totalPopulation,
        'total_active_reports': totalActiveReports,
        'total_critical_reports': totalCriticalReports,
        'total_iot_sensors': totalIotSensors,
        'total_health_centers': totalHealthCenters,
        'total_asha_workers': totalAshaWorkers,
      };
    } catch (e) {
      print('Failed to get district statistics: $e');
      return {};
    }
  }

  // Get district risk distribution
  static Future<Map<String, int>> getDistrictRiskDistribution() async {
    final db = DatabaseService.database!;

    try {
      final lowRisk = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level = ?',
        ['low'],
      )) ?? 0;

      final mediumRisk = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level = ?',
        ['medium'],
      )) ?? 0;

      final highRisk = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level = ?',
        ['high'],
      )) ?? 0;

      final criticalRisk = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE risk_level = ?',
        ['critical'],
      )) ?? 0;

      return {
        'low': lowRisk,
        'medium': mediumRisk,
        'high': highRisk,
        'critical': criticalRisk,
      };
    } catch (e) {
      print('Failed to get district risk distribution: $e');
      return {};
    }
  }

  // Get top districts by risk score
  static Future<List<District>> getTopDistrictsByRiskScore({int limit = 10}) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'risk_score DESC',
        limit: limit,
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get top districts by risk score: $e');
      return [];
    }
  }

  // Get districts by population range
  static Future<List<District>> getDistrictsByPopulationRange(int minPopulation, int maxPopulation) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'population >= ? AND population <= ?',
        whereArgs: [minPopulation, maxPopulation],
        orderBy: 'population DESC',
      );

      return maps.map((map) => _mapToDistrict(map)).toList();
    } catch (e) {
      print('Failed to get districts by population range: $e');
      return [];
    }
  }

  // Convert District to Map
  static Map<String, dynamic> _districtToMap(District district) {
    return {
      'id': district.id,
      'name': district.name,
      'state': district.state,
      'latitude': district.latitude,
      'longitude': district.longitude,
      'population': district.population,
      'risk_score': district.riskScore,
      'risk_level': district.riskLevel.toString().split('.').last,
      'active_reports': district.activeReports,
      'critical_reports': district.criticalReports,
      'last_updated': district.lastUpdated.toIso8601String(),
      'polygon_coordinates': district.polygonCoordinates != null ? json.encode(district.polygonCoordinates) : null,
      'iot_sensor_count': district.iotSensorCount,
      'health_centers_count': district.healthCentersCount,
      'asha_workers_count': district.ashaWorkersCount,
      'created_at': district.createdAt.toIso8601String(),
      'updated_at': district.updatedAt.toIso8601String(),
    };
  }

  // Convert Map to District
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

