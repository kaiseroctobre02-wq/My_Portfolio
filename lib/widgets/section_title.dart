import 'package:flutter/material.dart';

/// A simple heading used to separate sections on the Home dashboard.
///
/// StatelessWidget because a heading is pure, static text.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
    );
  }
}