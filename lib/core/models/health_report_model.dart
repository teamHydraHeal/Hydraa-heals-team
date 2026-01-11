enum ReportSeverity {
  low,
  medium,
  high,
  critical,
}

enum ReportStatus {
  pending,
  processing,
  processed,
  escalated,
}

class HealthReport {
  final String id;
  final String userId;
  final String reporterName;
  final String location;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> symptoms;
  final ReportSeverity severity;
  final ReportStatus status;
  final List<String> photoUrls;
  final DateTime reportedAt;
  final DateTime? processedAt;
  final String? aiAnalysis;
  final Map<String, dynamic>? aiEntities;
  final String? triageResponse;
  final String? districtId;
  final String? blockId;
  final String? villageId;
  final bool isOffline;
  final bool isSynced;
  final int syncAttempts;
  final DateTime? lastSyncAttempt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthReport({
    required this.id,
    required this.userId,
    required this.reporterName,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.symptoms,
    required this.severity,
    required this.status,
    this.photoUrls = const [],
    required this.reportedAt,
    this.processedAt,
    this.aiAnalysis,
    this.aiEntities,
    this.triageResponse,
    this.districtId,
    this.blockId,
    this.villageId,
    this.isOffline = false,
    this.isSynced = true,
    this.syncAttempts = 0,
    this.lastSyncAttempt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      reporterName: json['reporterName'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      severity: ReportSeverity.values.firstWhere(
        (e) => e.toString() == 'ReportSeverity.${json['severity']}',
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == 'ReportStatus.${json['status']}',
      ),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt'] as String) 
          : null,
      aiAnalysis: json['aiAnalysis'] as String?,
      aiEntities: json['aiEntities'] != null 
          ? Map<String, dynamic>.from(json['aiEntities']) 
          : null,
      triageResponse: json['triageResponse'] as String?,
      districtId: json['districtId'] as String?,
      blockId: json['blockId'] as String?,
      villageId: json['villageId'] as String?,
      isOffline: json['isOffline'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
      syncAttempts: json['syncAttempts'] as int? ?? 0,
      lastSyncAttempt: json['lastSyncAttempt'] != null 
          ? DateTime.parse(json['lastSyncAttempt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reporterName': reporterName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'symptoms': symptoms,
      'severity': severity.toString().split('.').last,
      'status': status.toString().split('.').last,
      'photoUrls': photoUrls,
      'reportedAt': reportedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'aiAnalysis': aiAnalysis,
      'aiEntities': aiEntities,
      'triageResponse': triageResponse,
      'districtId': districtId,
      'blockId': blockId,
      'villageId': villageId,
      'isOffline': isOffline,
      'isSynced': isSynced,
      'syncAttempts': syncAttempts,
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HealthReport copyWith({
    String? id,
    String? userId,
    String? reporterName,
    String? location,
    double? latitude,
    double? longitude,
    String? description,
    List<String>? symptoms,
    ReportSeverity? severity,
    ReportStatus? status,
    List<String>? photoUrls,
    DateTime? reportedAt,
    DateTime? processedAt,
    String? aiAnalysis,
    Map<String, dynamic>? aiEntities,
    String? triageResponse,
    String? districtId,
    String? blockId,
    String? villageId,
    bool? isOffline,
    bool? isSynced,
    int? syncAttempts,
    DateTime? lastSyncAttempt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reporterName: reporterName ?? this.reporterName,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      reportedAt: reportedAt ?? this.reportedAt,
      processedAt: processedAt ?? this.processedAt,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      aiEntities: aiEntities ?? this.aiEntities,
      triageResponse: triageResponse ?? this.triageResponse,
      districtId: districtId ?? this.districtId,
      blockId: blockId ?? this.blockId,
      villageId: villageId ?? this.villageId,
      isOffline: isOffline ?? this.isOffline,
      isSynced: isSynced ?? this.isSynced,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCritical => severity == ReportSeverity.critical;
  bool get isHigh => severity == ReportSeverity.high;
  bool get needsAttention => severity == ReportSeverity.high || severity == ReportSeverity.critical;
}
