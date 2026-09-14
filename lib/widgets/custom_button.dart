import 'package:flutter/material.dart';

/// A reusable button with an optional icon and two visual styles.
///
/// StatelessWidget because a button is a static piece of UI.
class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool filled;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        child: buttonChild,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: buttonChild,
    );
  }
}