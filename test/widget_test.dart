import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_portfolio/main.dart';
import 'package:flutter_portfolio/providers/network_diagnostics_provider.dart';
import 'package:flutter_portfolio/providers/network_monitor_provider.dart';
import 'package:flutter_portfolio/providers/profile_provider.dart';
import 'package:flutter_portfolio/providers/theme_provider.dart';
import 'package:flutter_portfolio/screens/profile_screen.dart';
import 'package:flutter_portfolio/widgets/activity_card.dart';

Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(
        create: (context) => NetworkMonitorProvider()..startMonitoring(),
      ),
      ChangeNotifierProvider(
        create: (context) => NetworkDiagnosticsProvider(),
      ),
    ],
    child: const MyApp(),
  );
}

void main() {
  testWidgets('Home dashboard renders the main menu cards', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('My Flutter Portfolio'), findsOneWidget);
    expect(find.text('Activities'), findsWidgets);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('Profile screen dark mode switch updates the global theme',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);

    final context = tester.element(find.byType(ProfileScreen));
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    expect(themeProvider.isDarkMode, isFalse);

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(themeProvider.isDarkMode, isTrue);
    expect(find.text('Dark theme is ON'), findsOneWidget);
  });

  testWidgets('Saving the student name updates the Home greeting instantly',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Kaiser October');
    await tester.tap(find.text('Save Name'));
    await tester.pumpAndSettle();

    // Go back to Home and confirm the greeting updated instantly.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(
      find.text('Hi Kaiser October! Explore each activity to see '
          'navigation, state management, responsive layouts, '
          'and theming in action.'),
      findsOneWidget,
    );
  });

  testWidgets('Network Monitor is reachable from the Activities list',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Home -> Activities list.
    await tester.ensureVisible(find.byType(ActivityCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();

    // The Activities list shows the Activity 2 label + Network Monitoring.
    expect(find.text('Activity 2'), findsOneWidget);
    expect(find.text('Activity 3'), findsOneWidget);
    expect(find.text('Network Monitoring'), findsOneWidget);

    // Activities list -> Network Monitor screen.
    await tester.tap(find.text('Network Monitoring'));
    await tester.pumpAndSettle();

    // No connectivity plugin in tests, so the state starts offline.
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Queued Requests'), findsOneWidget);

    await tester.tap(find.text('Send New Request'));
    await tester.pump();
    await tester.tap(find.text('Send New Request'));
    await tester.pump();

    expect(find.text('Data request 1'), findsOneWidget);
    expect(find.text('Data request 2'), findsOneWidget);
    expect(find.text('Waiting for a connection... the queue auto-retries '
        'when Wi-Fi or Cellular returns.'), findsOneWidget);
  });

  testWidgets('Network Diagnostic Dashboard opens from the Activities list',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Home -> Activities list.
    await tester.ensureVisible(find.byType(ActivityCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();

    // Activities list -> Network Diagnostic Dashboard.
    await tester.ensureVisible(find.text('Network Diagnostic Dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Network Diagnostic Dashboard'));
    await tester.pumpAndSettle();

    // Dashboard renders with the tier state broadcast from the global
    // provider (no diagnostics started in tests -> awaiting state).
    expect(
        find.text('Network Diagnostic Dashboard'), findsOneWidget);
    expect(find.text('Checking…'), findsOneWidget);
    expect(find.text('Awaiting first test…'), findsOneWidget);
  });
}