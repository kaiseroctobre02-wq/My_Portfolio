import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_item.dart';
import '../providers/profile_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/section_title.dart';

/// Home dashboard: the main menu for the portfolio app.
///
/// StatelessWidget because it only displays static content and
/// navigation triggers; it does not manage any state itself.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<ActivityItem> _activities = [
    ActivityItem(
      title: 'Activity 1',
      subtitle: '',
      icon: Icons.exposure_plus_1,
      color: Colors.indigo,
      route: '/activity1',
    ),
    ActivityItem(
      title: 'Activity 2',
      subtitle: '',
      icon: Icons.dashboard_customize_outlined,
      color: Colors.teal,
      route: '/activity2',
    ),
    ActivityItem(
      title: 'Network Monitor',
      subtitle: '',
      icon: Icons.network_check,
      color: Colors.blue,
      route: '/network',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flutter Portfolio'),
        actions: [
          Tooltip(
            message: 'Edit profile',
            child: Consumer<ProfileProvider>(
              builder: (context, profile, child) {
                final theme = Theme.of(context);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        profile.initial,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SizedBox(height: 8),
          const _WelcomeHeader(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Activities'),
          const SizedBox(height: 12),
          _buildActivityCard(context, _activities[0]),
          const SizedBox(height: 12),
          _buildActivityCard(context, _activities[1]),
          const SizedBox(height: 12),
          _buildActivityCard(context, _activities[2]),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem item) {
    return ActivityCard(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      onTap: () => Navigator.pushNamed(context, item.route),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'BS Computer Science · Portfolio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<ProfileProvider>(
              builder: (context, profile, child) {
                final greeting = profile.name.isEmpty
                    ? 'Welcome, BS Computer Science student!'
                    : 'Hi ${profile.name}!';
                return Text(
                  '$greeting Explore each activity to see navigation, '
                  'state management, responsive layouts, and theming '
                  'in action.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}