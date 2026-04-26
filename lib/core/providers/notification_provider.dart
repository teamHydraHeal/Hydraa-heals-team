import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Initialize notifications from local storage
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = json.decode(notificationsJson);
        _notifications = notificationsList
            .map((json) => AppNotification.fromJson(json))
            .toList();
        
        _updateUnreadCount();
      }
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new notification
  Future<void> addNotification(AppNotification notification) async {
    try {
      _notifications.insert(0, notification);
      _updateUnreadCount();
      await _saveNotifications();
      
      // Show local notification if app is in background
      await _notificationService.showLocalNotification(
        notification.title,
        notification.body,
        notification.id,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        _updateUnreadCount();
        await _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      }
      
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear notifications: $e');
    }
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get urgent notifications
  List<AppNotification> getUrgentNotifications() {
    return _notifications.where((n) => n.isUrgent || n.isEmergency).toList();
  }

  // Create health alert notification
  Future<void> createHealthAlert({
    required String title,
    required String body,
    required String districtId,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    final notification = AppNotification(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.healthAlert,
      priority: priority,
      districtId: districtId,
      createdAt: DateTime.now(),
      isActionable: true,
    );
    
    await addNotification(notification);
  }

  // Create report update notification
  Future<void> createReportUpdate({
    required String title,
    required String body,
    required String reportId,
  }) async {
    final notification = AppNotification(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.reportUpdate,
      priority: NotificationPriority.normal,
      reportId: reportId,
      createdAt: DateTime.now(),
      isActionable: true,
    );
    
    await addNotification(notification);
  }

  // Create emergency notification
  Future<void> createEmergencyAlert({
    required String title,
    required String body,
    String? districtId,
  }) async {
    final notification = AppNotification(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.emergency,
      priority: NotificationPriority.urgent,
      districtId: districtId,
      createdAt: DateTime.now(),
      isActionable: true,
    );
    
    await addNotification(notification);
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
