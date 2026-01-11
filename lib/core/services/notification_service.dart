import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize notification service
  static Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission for push notifications
    await _requestPermission();
    
    // Set up Firebase messaging handlers
    _setupFirebaseMessaging();
  }

  // Request notification permissions
  static Future<void> _requestPermission() async {
    // Request permission for local notifications
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request permission for Firebase messaging
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission for notifications');
    } else {
      debugPrint('User declined or has not accepted permission for notifications');
    }
  }

  // Set up Firebase messaging handlers
  static void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      
      // Show local notification for foreground messages
      if (message.notification != null) {
        showLocalNotification(
          message.notification!.title ?? 'Jal Guard',
          message.notification!.body ?? '',
          message.messageId ?? 'firebase_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state: ${message.messageId}');
        _handleNotificationTap(message);
      }
    });
  }

  // Show local notification
  static Future<void> showLocalNotification(
    String title,
    String body,
    String id, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'jal_guard_channel',
      'Jal Guard Notifications',
      channelDescription: 'Health alerts and updates from Jal Guard',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id.hashCode,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show scheduled notification
  static Future<void> showScheduledNotification(
    String title,
    String body,
    DateTime scheduledDate,
    String id, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'jal_guard_scheduled',
      'Scheduled Health Alerts',
      channelDescription: 'Scheduled health alerts and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Handle local notification tap
    _handleLocalNotificationTap(response.payload);
  }

  // Handle Firebase notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Firebase notification tapped: ${message.data}');
    // Navigate to appropriate screen based on notification data
    // This would typically use a navigation service or context
  }

  // Handle local notification tap
  static void _handleLocalNotificationTap(String? payload) {
    debugPrint('Local notification payload: $payload');
    // Handle local notification tap based on payload
  }

  // Create notification channel for Android
  static Future<void> createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'jal_guard_channel',
      'Jal Guard Notifications',
      description: 'Health alerts and updates from Jal Guard',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }
}
