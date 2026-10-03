import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity_app/main.dart';
import 'package:activity_app/providers/network_diagnostic_provider.dart';

void main() {
  testWidgets('App initializes and renders Home Dashboard with wireframe layout and Global Network Badge', (WidgetTester tester) async {
    await tester.pumpWidget(const ActivityApp());
    await tester.pumpAndSettle();

    // Verify main components matching reference wireframe design
    expect(find.text('Marvin Flutter Profile'), findsAtLeastNWidgets(1));
    expect(find.text('Compilation of Activity:'), findsOneWidget);
    expect(find.text('Activity 1:'), findsOneWidget);
    expect(find.text('Activity 2:'), findsOneWidget);
    expect(find.text('Activity 3:'), findsOneWidget);

    // Verify Global Network Health Badge exists in HomeScreen AppBar
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            (widget.icon == Icons.wifi_rounded ||
                widget.icon == Icons.wifi_off_rounded ||
                widget.icon == Icons.bolt_rounded ||
                widget.icon == Icons.network_check_rounded ||
                widget.icon ==
                    Icons.signal_cellular_connected_no_internet_4_bar_rounded),
      ),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('Navigates to Activity 3 and renders 5 required metrics and diagnostic controls without overflow', (WidgetTester tester) async {
    // Set small mobile screen size (380x800) to test responsive layout & zero overflow
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ActivityApp());
    await tester.pumpAndSettle();

    // Scroll to Activity 3 card and tap
    final activity3Text = find.text('Activity 3:');
    await tester.ensureVisible(activity3Text);
    await tester.tap(activity3Text);
    await tester.pumpAndSettle();

    // Verify Activity 3 screen and header render
    expect(find.text('Activity 3: Network Diagnostics'), findsOneWidget);
    expect(find.text('Network Diagnostic Dashboard'), findsOneWidget);

    // Verify all 5 required metrics labels exist in the UI
    expect(find.text('Idle Ping'), findsAtLeastNWidgets(1));
    expect(find.text('Download Speed'), findsOneWidget);
    expect(find.text('Download Ping'), findsOneWidget);
    expect(find.text('Upload Speed'), findsOneWidget);
    expect(find.text('Upload Ping'), findsOneWidget);

    // Verify 3-phase diagnostic indicators exist
    expect(find.text('Idle Ping'), findsAtLeastNWidgets(1));
    expect(find.text('Download & Ping'), findsOneWidget);
    expect(find.text('Upload & Ping'), findsOneWidget);

    // Verify Run Diagnostic button exists
    expect(find.text('Run Diagnostic'), findsOneWidget);
    expect(find.text('Auto-Refresh (30s):'), findsOneWidget);

    // Verify NO simulation choice chips or simulated badges remain
    expect(find.text('Tier Simulation & Override'), findsNothing);
    expect(find.text('Simulated'), findsNothing);
  });

  testWidgets('Auto-Refresh switch toggles periodic diagnostics in provider', (WidgetTester tester) async {
    final provider = NetworkDiagnosticProvider();
    expect(provider.isAutoRefreshEnabled, isFalse);

    provider.toggleAutoRefresh(true);
    expect(provider.isAutoRefreshEnabled, isTrue);

    provider.toggleAutoRefresh(false);
    expect(provider.isAutoRefreshEnabled, isFalse);
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

  testWidgets('Activity 3 renders dash "-" for all metrics when offline or unmeasured', (WidgetTester tester) async {
    await tester.pumpWidget(const ActivityApp());
    await tester.pumpAndSettle();

    final activity3Text = find.text('Activity 3:');
    await tester.ensureVisible(activity3Text);
    await tester.tap(activity3Text);
    await tester.pumpAndSettle();

    // At least one dash "-" must be rendered for metrics when unmeasured or offline
    expect(find.text('-'), findsWidgets);
  });
}
