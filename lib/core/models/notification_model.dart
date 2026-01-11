enum NotificationType {
  healthAlert,
  reportUpdate,
  systemMessage,
  emergency,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final String? districtId;
  final String? reportId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final bool isActionable;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.districtId,
    this.reportId,
    this.data,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    this.isActionable = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${json['priority']}',
      ),
      districtId: json['districtId'] as String?,
      reportId: json['reportId'] as String?,
      data: json['data'] != null 
          ? Map<String, dynamic>.from(json['data']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String) 
          : null,
      isRead: json['isRead'] as bool? ?? false,
      isActionable: json['isActionable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'districtId': districtId,
      'reportId': reportId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'isActionable': isActionable,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? districtId,
    String? reportId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
    bool? isActionable,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      districtId: districtId ?? this.districtId,
      reportId: reportId ?? this.reportId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
    );
  }

  bool get isUrgent => priority == NotificationPriority.urgent;
  bool get isHigh => priority == NotificationPriority.high;
  bool get isEmergency => type == NotificationType.emergency;
}
