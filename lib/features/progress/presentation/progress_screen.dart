import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../environment/controllers/environment_controller.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final env = context.watch<EnvironmentController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This device', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Streak: ${env.streakDays} day(s)'),
                  Text('Total practices: ${env.totalPractices}'),
                  Text('Average score (session): ${env.averageScore.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Tip: Practice short phrases daily to improve consistency.'),
        ],
      ),
    );
  }
}
