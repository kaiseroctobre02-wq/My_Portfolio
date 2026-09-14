import 'package:flutter/material.dart';

/// A simple data model that describes one entry on the Home dashboard.
class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}