enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class District {
  final String id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final RiskLevel riskLevel;
  final double riskScore;
  final int population;
  final int activeReports;
  final int criticalReports;
  final DateTime lastUpdated;
  final Map<String, dynamic>? polygonCoordinates;
  final int iotSensorCount;
  final int healthCentersCount;
  final int ashaWorkersCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const District({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.riskScore,
    required this.population,
    required this.activeReports,
    required this.criticalReports,
    required this.lastUpdated,
    this.polygonCoordinates,
    this.iotSensorCount = 0,
    this.healthCentersCount = 0,
    this.ashaWorkersCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == 'RiskLevel.${json['riskLevel']}',
      ),
      riskScore: (json['riskScore'] as num).toDouble(),
      population: json['population'] as int,
      activeReports: json['activeReports'] as int,
      criticalReports: json['criticalReports'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      polygonCoordinates: json['polygonCoordinates'] != null 
          ? Map<String, dynamic>.from(json['polygonCoordinates']) 
          : null,
      iotSensorCount: json['iotSensorCount'] as int? ?? 0,
      healthCentersCount: json['healthCentersCount'] as int? ?? 0,
      ashaWorkersCount: json['ashaWorkersCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'riskLevel': riskLevel.toString().split('.').last,
      'riskScore': riskScore,
      'population': population,
      'activeReports': activeReports,
      'criticalReports': criticalReports,
      'lastUpdated': lastUpdated.toIso8601String(),
      'polygonCoordinates': polygonCoordinates,
      'iotSensorCount': iotSensorCount,
      'healthCentersCount': healthCentersCount,
      'ashaWorkersCount': ashaWorkersCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  District copyWith({
    String? id,
    String? name,
    String? state,
    double? latitude,
    double? longitude,
    RiskLevel? riskLevel,
    double? riskScore,
    int? population,
    int? activeReports,
    int? criticalReports,
    DateTime? lastUpdated,
    Map<String, dynamic>? polygonCoordinates,
    int? iotSensorCount,
    int? healthCentersCount,
    int? ashaWorkersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return District(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      riskLevel: riskLevel ?? this.riskLevel,
      riskScore: riskScore ?? this.riskScore,
      population: population ?? this.population,
      activeReports: activeReports ?? this.activeReports,
      criticalReports: criticalReports ?? this.criticalReports,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      polygonCoordinates: polygonCoordinates ?? this.polygonCoordinates,
      iotSensorCount: iotSensorCount ?? this.iotSensorCount,
      healthCentersCount: healthCentersCount ?? this.healthCentersCount,
      ashaWorkersCount: ashaWorkersCount ?? this.ashaWorkersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isHighRisk => riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;
  bool get isCritical => riskLevel == RiskLevel.critical;
  
  String get riskColor {
    switch (riskLevel) {
      case RiskLevel.low:
        return '#4CAF50'; // Green
      case RiskLevel.medium:
        return '#FF9800'; // Orange
      case RiskLevel.high:
        return '#F44336'; // Red
      case RiskLevel.critical:
        return '#9C27B0'; // Purple
    }
  }
}
