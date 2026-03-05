import 'package:flutter/material.dart';

import '../controllers/environment_controller.dart';

class EnvironmentBadge extends StatelessWidget {
  final EnvironmentState state;

  const EnvironmentBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (text, icon) = switch (state) {
      EnvironmentState.ok => ('Environment OK', Icons.check_circle_outline),
      EnvironmentState.noisy => ('Too noisy', Icons.warning_amber_outlined),
      EnvironmentState.unknown => ('Unknown', Icons.help_outline),
    };

    final color = switch (state) {
      EnvironmentState.ok => Theme.of(context).colorScheme.primary,
      EnvironmentState.noisy => Theme.of(context).colorScheme.error,
      EnvironmentState.unknown => Theme.of(context).colorScheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
