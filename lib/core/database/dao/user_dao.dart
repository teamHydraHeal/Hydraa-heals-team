import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../../models/user_model.dart';
import '../database_service.dart';

class UserDAO {
  static String get _tableName => DatabaseService.usersTable;

  // Create user
  static Future<String> createUser(User user) async {
    final db = DatabaseService.database!;

    try {
      await db.insert(_tableName, _userToMap(user));
      return user.id;
    } catch (e) {
      print('Failed to create user: $e');
      rethrow;
    }
  }

  // Get user by ID
  static Future<User?> getUserById(String id) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Failed to get user by ID: $e');
      return null;
    }
  }

  // Get user by Aadhaar number
  static Future<User?> getUserByAadhaar(String aadhaarNumber) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'aadhaar_number = ?',
        whereArgs: [aadhaarNumber],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Failed to get user by Aadhaar: $e');
      return null;
    }
  }

  // Get user by phone number
  static Future<User?> getUserByPhone(String phoneNumber) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'phone_number = ?',
        whereArgs: [phoneNumber],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Failed to get user by phone: $e');
      return null;
    }
  }

  // Get users by role
  static Future<List<User>> getUsersByRole(UserRole role) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'role = ? AND is_active = ?',
        whereArgs: [role.toString().split('.').last, 1],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Failed to get users by role: $e');
      return [];
    }
  }

  // Get users by district
  static Future<List<User>> getUsersByDistrict(String districtId) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'district_id = ? AND is_active = ?',
        whereArgs: [districtId, 1],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Failed to get users by district: $e');
      return [];
    }
  }

  // Get ASHA workers by district
  static Future<List<User>> getAshaWorkersByDistrict(String districtId) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'district_id = ? AND role = ? AND is_active = ?',
        whereArgs: [districtId, 'ashaWorker', 1],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Failed to get ASHA workers by district: $e');
      return [];
    }
  }

  // Update user
  static Future<bool> updateUser(User user) async {
    final db = DatabaseService.database!;

    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final result = await db.update(
        _tableName,
        _userToMap(updatedUser),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update user: $e');
      return false;
    }
  }

  // Update user last login
  static Future<bool> updateLastLogin(String userId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'last_login': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update last login: $e');
      return false;
    }
  }

  // Update user verification status
  static Future<bool> updateVerificationStatus(String userId, bool isVerified) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'is_verified': isVerified ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to update verification status: $e');
      return false;
    }
  }

  // Deactivate user
  static Future<bool> deactivateUser(String userId) async {
    final db = DatabaseService.database!;

    try {
      final result = await db.update(
        _tableName,
        {
          'is_active': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      print('Failed to deactivate user: $e');
      return false;
    }
  }

  // Delete user (soft delete)
  static Future<bool> deleteUser(String userId) async {
    return await deactivateUser(userId);
  }

  // Get all users (with pagination)
  static Future<List<User>> getAllUsers({
    int limit = 50,
    int offset = 0,
    String? orderBy,
  }) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: orderBy ?? 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Failed to get all users: $e');
      return [];
    }
  }

  // Search users
  static Future<List<User>> searchUsers(String query) async {
    final db = DatabaseService.database!;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '''
          (name LIKE ? OR 
           aadhaar_number LIKE ? OR 
           phone_number LIKE ? OR 
           professional_id LIKE ?) 
          AND is_active = ?
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', 1],
        orderBy: 'name ASC',
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Failed to search users: $e');
      return [];
    }
  }

  // Get user statistics
  static Future<Map<String, int>> getUserStatistics() async {
    final db = DatabaseService.database!;

    try {
      final totalUsers = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE is_active = ?',
        [1],
      )) ?? 0;

      final verifiedUsers = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE is_verified = ? AND is_active = ?',
        [1, 1],
      )) ?? 0;

      final healthOfficials = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE role = ? AND is_active = ?',
        ['healthOfficial', 1],
      )) ?? 0;

      final ashaWorkers = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE role = ? AND is_active = ?',
        ['ashaWorker', 1],
      )) ?? 0;

      final citizens = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE role = ? AND is_active = ?',
        ['citizen', 1],
      )) ?? 0;

      return {
        'total_users': totalUsers,
        'verified_users': verifiedUsers,
        'health_officials': healthOfficials,
        'asha_workers': ashaWorkers,
        'citizens': citizens,
      };
    } catch (e) {
      print('Failed to get user statistics: $e');
      return {};
    }
  }

  // Check if Aadhaar exists
  static Future<bool> aadhaarExists(String aadhaarNumber) async {
    final db = DatabaseService.database!;

    try {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE aadhaar_number = ?',
        [aadhaarNumber],
      )) ?? 0;
      return count > 0;
    } catch (e) {
      print('Failed to check Aadhaar existence: $e');
      return false;
    }
  }

  // Check if phone exists
  static Future<bool> phoneExists(String phoneNumber) async {
    final db = DatabaseService.database!;

    try {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE phone_number = ?',
        [phoneNumber],
      )) ?? 0;
      return count > 0;
    } catch (e) {
      print('Failed to check phone existence: $e');
      return false;
    }
  }

  // Convert User to Map
  static Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'aadhaar_number': user.aadhaarNumber,
      'phone_number': user.phoneNumber,
      'name': user.name,
      'role': user.role.toString().split('.').last,
      'is_verified': user.isVerified ? 1 : 0,
      'professional_id': user.professionalId,
      'district_id': user.districtId,
      'state': user.state,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      'last_login': user.lastLogin?.toIso8601String(),
      'is_active': user.isActive ? 1 : 0,
      'profile_data': user.profileData != null ? json.encode(user.profileData) : null,
      'verification_documents': user.verificationDocuments != null ? json.encode(user.verificationDocuments) : null,
    };
  }

  // Convert Map to User
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
}

