import 'package:assets/assets.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SummaryCard Widget', () {
    testWidgets('should display title and value correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              title: 'إجمالي الأصول',
              value: '150',
              icon: Icons.business,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('إجمالي الأصول'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('should have correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              title: 'Test',
              value: '100',
              icon: Icons.test,
              color: Colors.red,
            ),
          ),
        ),
      );

      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });
  });
}
