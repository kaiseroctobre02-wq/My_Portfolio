import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_portfolio/main.dart';
import 'package:flutter_portfolio/providers/theme_provider.dart';
import 'package:flutter_portfolio/screens/settings_screen.dart';

Widget buildApp() {
  return ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  );
}

void main() {
  testWidgets('Home dashboard renders the main menu cards', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Flutter Portfolio'), findsOneWidget);
    expect(find.text('Activity 1'), findsOneWidget);
    expect(find.text('Activity 2'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
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

  testWidgets('Settings dark mode switch updates the global theme',
      (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.ensureVisible(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Dark Mode'), findsOneWidget);

    final context = tester.element(find.byType(SettingsScreen));
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    expect(provider.isDarkMode, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(provider.isDarkMode, isTrue);
    expect(find.text('Dark theme is ON'), findsOneWidget);
  });
}