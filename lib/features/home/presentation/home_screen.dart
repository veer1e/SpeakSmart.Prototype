import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../calibration/controllers/calibration_controller.dart';
import '../../environment/controllers/environment_controller.dart';
import '../../environment/widgets/environment_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calib = context.watch<CalibrationController>();
    final env = context.watch<EnvironmentController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ready to practice today?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Progress', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Streak: ${env.streakDays} day(s)'),
                        const SizedBox(height: 4),
                        Text('Practices today: ${env.practicesToday}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Environment', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        EnvironmentBadge(state: env.state),
                        const SizedBox(height: 8),
                        Text('Live: ${env.latestMeanDb.toStringAsFixed(1)} dB'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Pronunciation Challenge', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text('“I want to improve my pronunciation.”'),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.practice),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calibration', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(calib.hasCalibration
                      ? 'Calibrated (updated ${calib.updatedAtLabel})'
                      : 'Not calibrated yet'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(context, Routes.calibration),
                        icon: const Icon(Icons.tune),
                        label: Text(calib.hasCalibration ? 'Recalibrate' : 'Calibrate'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, Routes.environment),
                        icon: const Icon(Icons.graphic_eq),
                        label: const Text('Noise Check'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
