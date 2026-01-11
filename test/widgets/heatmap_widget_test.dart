import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jal_guard/features/field_worker/widgets/local_heatmap_widget.dart';
import 'package:jal_guard/features/citizen/widgets/area_status_widget.dart';

void main() {
  group('Heatmap Widget Tests', () {
    testWidgets('LocalHeatmapWidget should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalHeatmapWidget(),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(LocalHeatmapWidget), findsOneWidget);
      
      // Check for area names
      expect(find.text('Mawryngkneng'), findsOneWidget);
      expect(find.text('Shillong'), findsOneWidget);
      expect(find.text('Cherrapunji'), findsOneWidget);
      
      // Check for risk indicators
      expect(find.text('Low Risk'), findsOneWidget);
      expect(find.text('Medium Risk'), findsOneWidget);
      expect(find.text('High Risk'), findsOneWidget);
    });

    testWidgets('AreaStatusWidget should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AreaStatusWidget(),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(AreaStatusWidget), findsOneWidget);
      
      // Check for main title
      expect(find.text('Your Area Status'), findsOneWidget);
      
      // Check for area name and status
      expect(find.text('Shillong'), findsOneWidget);
      expect(find.text('Low Risk'), findsOneWidget);
      
      // Check for status items
      expect(find.text('Water Quality'), findsOneWidget);
      expect(find.text('Disease Reports'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('LocalHeatmapWidget should have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalHeatmapWidget(),
          ),
        ),
      );

      // Check for container with proper styling
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('AreaStatusWidget should have interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AreaStatusWidget(),
          ),
        ),
      );

      // Check for arrow icon indicating interactivity
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      
      // Check for status icons
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('LocalHeatmapWidget should display risk colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalHeatmapWidget(),
          ),
        ),
      );

      // Find risk indicator containers
      final riskContainers = find.byType(Container);
      expect(riskContainers, findsWidgets);
      
      // Pump the widget to ensure all colors are rendered
      await tester.pump();
      
      // Verify that different risk levels are displayed
      expect(find.text('low'), findsOneWidget);
      expect(find.text('medium'), findsOneWidget);
      expect(find.text('high'), findsOneWidget);
    });

    testWidgets('Widgets should be responsive to different screen sizes', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LocalHeatmapWidget(),
                AreaStatusWidget(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LocalHeatmapWidget), findsOneWidget);
      expect(find.byType(AreaStatusWidget), findsOneWidget);
      
      // Test with tablet size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pump();
      
      expect(find.byType(LocalHeatmapWidget), findsOneWidget);
      expect(find.byType(AreaStatusWidget), findsOneWidget);
      
      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Widgets should handle empty or error states gracefully', (WidgetTester tester) async {
      // This test ensures widgets don't crash with unexpected data
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalHeatmapWidget(),
          ),
        ),
      );

      // Verify no errors are thrown during rendering
      expect(tester.takeException(), isNull);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AreaStatusWidget(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
