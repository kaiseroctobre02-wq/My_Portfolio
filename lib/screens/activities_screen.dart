import 'package:flutter/material.dart';

import '../widgets/activity_card.dart';

/// Activities screen: a list of the activities inside this portfolio.
///
/// Each entry is a card that opens its own activity screen.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _ActivityLabel(title: 'Activity 2'),
          const SizedBox(height: 12),
          ActivityCard(
            title: 'Network Monitoring',
            subtitle: '',
            icon: Icons.network_check,
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/network'),
          ),
          const SizedBox(height: 24),
          const _ActivityLabel(title: 'Activity 3'),
          const SizedBox(height: 12),
          ActivityCard(
            title: 'Network Diagnostic Dashboard',
            subtitle: '',
            icon: Icons.speed,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/diagnostics'),
          ),
        ],
      ),
    );
  }
}

/// Small label that identifies an activity inside this screen.
class _ActivityLabel extends StatelessWidget {
  final String title;

  const _ActivityLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}