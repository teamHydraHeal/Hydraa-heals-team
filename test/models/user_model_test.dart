import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/core/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    late User testUser;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime.now();
      testUser = User(
        id: 'test_user_1',
        aadhaarNumber: '123456789012',
        phoneNumber: '+91-9876543210',
        name: 'Test User',
        role: UserRole.citizen,
        isVerified: true,
        professionalId: 'PROF123',
        districtId: 'east_khasi_hills',
        state: 'Meghalaya',
        createdAt: testDateTime,
        updatedAt: testDateTime,
        lastLogin: testDateTime,
        isActive: true,
        profileData: {'experience': '5 years'},
        verificationDocuments: ['doc1.pdf', 'doc2.pdf'],
      );
    });

    test('should create User with all required fields', () {
      expect(testUser.id, equals('test_user_1'));
      expect(testUser.aadhaarNumber, equals('123456789012'));
      expect(testUser.phoneNumber, equals('+91-9876543210'));
      expect(testUser.name, equals('Test User'));
      expect(testUser.role, equals(UserRole.citizen));
      expect(testUser.isVerified, isTrue);
      expect(testUser.professionalId, equals('PROF123'));
      expect(testUser.districtId, equals('east_khasi_hills'));
      expect(testUser.state, equals('Meghalaya'));
      expect(testUser.isActive, isTrue);
    });

    test('should serialize to JSON correctly', () {
      final json = testUser.toJson();

      expect(json['id'], equals('test_user_1'));
      expect(json['aadhaarNumber'], equals('123456789012'));
      expect(json['phoneNumber'], equals('+91-9876543210'));
      expect(json['name'], equals('Test User'));
      expect(json['role'], equals('citizen'));
      expect(json['isVerified'], isTrue);
      expect(json['professionalId'], equals('PROF123'));
      expect(json['districtId'], equals('east_khasi_hills'));
      expect(json['state'], equals('Meghalaya'));
      expect(json['isActive'], isTrue);
      expect(json['profileData'], equals({'experience': '5 years'}));
      expect(json['verificationDocuments'], equals(['doc1.pdf', 'doc2.pdf']));
    });

    test('should deserialize from JSON correctly', () {
      final json = testUser.toJson();
      final userFromJson = User.fromJson(json);

      expect(userFromJson.id, equals(testUser.id));
      expect(userFromJson.aadhaarNumber, equals(testUser.aadhaarNumber));
      expect(userFromJson.phoneNumber, equals(testUser.phoneNumber));
      expect(userFromJson.name, equals(testUser.name));
      expect(userFromJson.role, equals(testUser.role));
      expect(userFromJson.isVerified, equals(testUser.isVerified));
      expect(userFromJson.professionalId, equals(testUser.professionalId));
      expect(userFromJson.districtId, equals(testUser.districtId));
      expect(userFromJson.state, equals(testUser.state));
      expect(userFromJson.isActive, equals(testUser.isActive));
    });

    test('should create copy with updated fields', () {
      final updatedUser = testUser.copyWith(
        name: 'Updated User',
        isVerified: false,
        districtId: 'west_khasi_hills',
      );

      expect(updatedUser.id, equals(testUser.id)); // unchanged
      expect(updatedUser.name, equals('Updated User')); // changed
      expect(updatedUser.isVerified, isFalse); // changed
      expect(updatedUser.districtId, equals('west_khasi_hills')); // changed
      expect(updatedUser.phoneNumber, equals(testUser.phoneNumber)); // unchanged
    });

    test('should validate user roles correctly', () {
      final healthOfficial = testUser.copyWith(role: UserRole.healthOfficial);
      final ashaWorker = testUser.copyWith(role: UserRole.ashaWorker);
      final citizen = testUser.copyWith(role: UserRole.citizen);

      expect(healthOfficial.isHealthOfficial, isTrue);
      expect(healthOfficial.isAshaWorker, isFalse);
      expect(healthOfficial.isCitizen, isFalse);

      expect(ashaWorker.isHealthOfficial, isFalse);
      expect(ashaWorker.isAshaWorker, isTrue);
      expect(ashaWorker.isCitizen, isFalse);

      expect(citizen.isHealthOfficial, isFalse);
      expect(citizen.isAshaWorker, isFalse);
      expect(citizen.isCitizen, isTrue);
    });

    test('should handle null optional fields', () {
      final minimalUser = User(
        id: 'minimal_user',
        aadhaarNumber: '123456789013',
        phoneNumber: '+91-9876543211',
        name: 'Minimal User',
        role: UserRole.citizen,
        isVerified: false,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(minimalUser.professionalId, isNull);
      expect(minimalUser.districtId, isNull);
      expect(minimalUser.state, isNull);
      expect(minimalUser.lastLogin, isNull);
      expect(minimalUser.profileData, isNull);
      expect(minimalUser.verificationDocuments, isNull);
      expect(minimalUser.isActive, isTrue); // default value
    });
  });
}
