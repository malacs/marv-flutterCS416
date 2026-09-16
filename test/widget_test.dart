import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity_app/main.dart';

void main() {
  testWidgets('App initializes and renders Home Dashboard with wireframe layout', (WidgetTester tester) async {
    await tester.pumpWidget(const ActivityApp());
    await tester.pumpAndSettle();

    // Verify main components matching reference wireframe design
    expect(find.text('Marvin Flutter Profile'), findsAtLeastNWidgets(1));
    expect(find.text('Compilation of Activity:'), findsOneWidget);
    expect(find.text('Activity 1:'), findsOneWidget);
    expect(find.text('Activity 2:'), findsOneWidget);
    expect(find.text('Activity 3:'), findsOneWidget);
    expect(find.text('View Activity'), findsAtLeastNWidgets(1));
  });

  testWidgets('Navigates to Settings screen via Bottom Navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ActivityApp());
    await tester.pumpAndSettle();

    // Tap Settings icon in Bottom Navigation Bar
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify Settings screen rendered
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });
}
