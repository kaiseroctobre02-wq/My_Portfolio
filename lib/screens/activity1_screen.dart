import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

/// Activity 1: Counter Activity.
///
/// StatefulWidget because the counter value is local state that
/// changes when the user presses a button. Each change triggers
/// a rebuild through `setState`.
class Activity1Screen extends StatefulWidget {
  const Activity1Screen({super.key});

  @override
  State<Activity1Screen> createState() => _Activity1ScreenState();
}

class _Activity1ScreenState extends State<Activity1Screen> {
  int _count = 0;

  void _increment() {
    setState(() => _count++);
  }

  void _decrement() {
    setState(() => _count--);
  }

  void _reset() {
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 1 '),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exposure_plus_1,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Counter Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Count',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_count',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Decrease',
                      icon: Icons.remove,
                      filled: false,
                      onPressed: _decrement,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Increase',
                      icon: Icons.add,
                      onPressed: _increment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Reset',
                  icon: Icons.refresh,
                  filled: false,
                  onPressed: _reset,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}