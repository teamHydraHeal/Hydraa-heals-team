enum UserRole {
  healthOfficial,
  ashaWorker,
  citizen,
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

class User {
  final String id;
  final String aadhaarNumber;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final bool isVerified;
  final String? professionalId;
  final String? districtId;
  final String? state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic>? profileData;
  final List<String>? verificationDocuments;

  const User({
    required this.id,
    required this.aadhaarNumber,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.isVerified,
    this.professionalId,
    this.districtId,
    this.state,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.isActive = true,
    this.profileData,
    this.verificationDocuments,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      aadhaarNumber: json['aadhaarNumber'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      isVerified: json['isVerified'] as bool? ?? false,
      professionalId: json['professionalId'] as String?,
      districtId: json['districtId'] as String?,
      state: json['state'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      profileData: json['profileData'] != null 
          ? Map<String, dynamic>.from(json['profileData']) 
          : null,
      verificationDocuments: json['verificationDocuments'] != null 
          ? List<String>.from(json['verificationDocuments']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aadhaarNumber': aadhaarNumber,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'professionalId': professionalId,
      'districtId': districtId,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'profileData': profileData,
      'verificationDocuments': verificationDocuments,
    };
  }

  User copyWith({
    String? id,
    String? aadhaarNumber,
    String? name,
    String? phoneNumber,
    UserRole? role,
    bool? isVerified,
    String? professionalId,
    String? districtId,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    Map<String, dynamic>? profileData,
    List<String>? verificationDocuments,
  }) {
    return User(
      id: id ?? this.id,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      professionalId: professionalId ?? this.professionalId,
      districtId: districtId ?? this.districtId,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      profileData: profileData ?? this.profileData,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
    );
  }

  bool get isHealthOfficial => role == UserRole.healthOfficial;
  bool get isAshaWorker => role == UserRole.ashaWorker;
  bool get isCitizen => role == UserRole.citizen;
}
