import 'package:flutter/material.dart';

/// Activities screen.
///
/// Uses LayoutBuilder to measure the available width and decide how
/// the layout adapts:
///   - Phone  ( < 600 px )  -> 1 column
///   - Tablet (600 - 899 )  -> 2 columns
///   - Desktop (>= 900 )    -> 3 columns
///
/// No hard-coded sizes, so there are no RenderFlex overflow errors.
class Activity2Screen extends StatelessWidget {
  const Activity2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isTablet = width >= 600;
          final bool isDesktop = width >= 900;
          final int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
          final String layoutName =
              isDesktop ? 'Desktop' : (isTablet ? 'Tablet' : 'Phone');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResponsiveHeader(
                  layoutName: layoutName,
                  columns: crossAxisCount,
                ),
                const SizedBox(height: 16),
                const _EmptyStateCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Header that tells the user which layout the screen is now showing.
class _ResponsiveHeader extends StatelessWidget {
  final String layoutName;
  final int columns;

  const _ResponsiveHeader({
    required this.layoutName,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnLabel = columns == 1 ? 'column' : 'columns';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Layout',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$layoutName · $columns $columnLabel',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This screen adapts to the available width using LayoutBuilder.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when there are no activities yet.
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No activities yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Future laboratory activities will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}