import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/main.dart' as app;

void main() {
  // Initialize test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Jal Guard App Integration Tests', () {
    testWidgets('App should launch without crashing', (WidgetTester tester) async {
      // Mock platform channels to prevent initialization errors in tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Firebase#initializeCore') {
            return {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project-id',
              },
              'pluginConstants': {},
            };
          }
          return null;
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_messaging'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the app doesn't crash and shows the splash screen
      expect(find.text('Jal Guard'), findsOneWidget);
    });

    testWidgets('Navigation should work correctly', (WidgetTester tester) async {
      // Mock platform channels
      _mockPlatformChannels();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to welcome screen
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('Database initialization should complete', (WidgetTester tester) async {
      // Mock platform channels including sqflite
      _mockPlatformChannels();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.tekartik.sqflite'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'openDatabase') {
            return 1; // Mock database ID
          } else if (methodCall.method == 'execute') {
            return null; // Mock successful execution
          } else if (methodCall.method == 'query') {
            return []; // Mock empty query result
          }
          return null;
        },
      );

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // App should launch successfully with database initialized
      expect(tester.takeException(), isNull);
    });

    testWidgets('Theme should be applied correctly', (WidgetTester tester) async {
      _mockPlatformChannels();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if Material theme is applied
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsOneWidget);

      // Verify theme properties
      final MaterialApp materialAppWidget = tester.widget(materialApp);
      expect(materialAppWidget.theme, isNotNull);
      expect(materialAppWidget.darkTheme, isNotNull);
    });

    testWidgets('Error handling should work correctly', (WidgetTester tester) async {
      // Mock platform channels with some failures
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'test_error', message: 'Test error');
        },
      );

      // App should still launch even with some service failures
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should handle errors gracefully and not crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

void _mockPlatformChannels() {
  // Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        };
      }
      return null;
    },
  );

  // Firebase Messaging
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_messaging'),
    (MethodCall methodCall) async {
      return null;
    },
  );

  // Local Notifications
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dexterous.com/flutter/local_notifications'),
    (MethodCall methodCall) async {
      return null;
    },
  );

  // Shared Preferences
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/shared_preferences'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    },
  );

  // Path Provider
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/mock/documents';
      }
      return null;
    },
  );

  // Connectivity
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return 'wifi';
      }
      return null;
    },
  );
}
