import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Settings screen with the global Dark Mode switch.
///
/// Calling [ThemeProvider.toggleTheme] triggers `notifyListeners()`,
/// which rebuilds the whole app (including the Home dashboard)
/// with the new theme instantly.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                themeProvider.isDarkMode
                    ? 'Dark theme is ON'
                    : 'Dark theme is OFF',
              ),
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}