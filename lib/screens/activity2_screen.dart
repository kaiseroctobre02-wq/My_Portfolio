import 'package:flutter/material.dart';

/// Activity 2: .
///
/// Uses LayoutBuilder to measure the available width and decide how
/// many columns the grid should show:
///   - Phone  ( < 600 px )  -> 1 column
///   - Tablet (600 - 899 )  -> 2 columns
///   - Desktop (>= 900 )    -> 3 columns
///
/// No hard-coded sizes, so there are no RenderFlex overflow errors.
class Activity2Screen extends StatelessWidget {
  const Activity2Screen({super.key});

  static const List<_ResponsiveCard> _cards = [
    _ResponsiveCard(
      title: 'Profile',
      description: 'Your student profile with name, course, and year level.',
      icon: Icons.person_outline,
      color: Colors.indigo,
    ),
    _ResponsiveCard(
      title: 'Grades',
      description: 'A summary of your grades across all subjects this semester.',
      icon: Icons.grade_outlined,
      color: Colors.teal,
    ),
    _ResponsiveCard(
      title: 'Schedule',
      description: 'Your weekly class schedule with room assignments.',
      icon: Icons.schedule_outlined,
      color: Colors.orange,
    ),
    _ResponsiveCard(
      title: 'Assignments',
      description: 'Pending tasks and deadlines for each of your subjects.',
      icon: Icons.assignment_outlined,
      color: Colors.pink,
    ),
    _ResponsiveCard(
      title: 'Projects',
      description: 'A list of your course projects and practical activities.',
      icon: Icons.code,
      color: Colors.blueGrey,
    ),
    _ResponsiveCard(
      title: 'Certificates',
      description: 'Completed trainings and certificates you have earned.',
      icon: Icons.verified_outlined,
      color: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 2 '),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 170,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) => _cards[index],
                ),
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
              '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ' $layoutName · $columns $columnLabel',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ''
              '',
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

/// A single card inside the responsive grid.
///
/// Uses Row and Column for its layout and Expanded to let the
/// description fill the remaining space without overflowing.
class _ResponsiveCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _ResponsiveCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}