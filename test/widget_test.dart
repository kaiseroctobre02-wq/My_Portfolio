import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_portfolio/main.dart';
import 'package:flutter_portfolio/providers/network_monitor_provider.dart';
import 'package:flutter_portfolio/providers/profile_provider.dart';
import 'package:flutter_portfolio/providers/theme_provider.dart';
import 'package:flutter_portfolio/screens/profile_screen.dart';

Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(
        create: (context) => NetworkMonitorProvider()..startMonitoring(),
      ),
    ],
    child: const MyApp(),
  );
}

void main() {
  testWidgets('Home dashboard renders the main menu cards', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('My Flutter Portfolio'), findsOneWidget);
    expect(find.text('Activity 1'), findsOneWidget);
    expect(find.text('Activity 2'), findsOneWidget);
    expect(find.text('Network Monitor'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('Activity 1 counter increments, decrements, and resets',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byIcon(Icons.exposure_plus_1));
    await tester.pumpAndSettle();

    expect(find.text('Counter Activity'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Increase'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Increase'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Decrease'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
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

  testWidgets('Network Monitor queues requests while offline',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.ensureVisible(find.text('Network Monitor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Network Monitor'));
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
}