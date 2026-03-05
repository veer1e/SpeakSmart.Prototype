import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/environment_controller.dart';
import '../widgets/environment_badge.dart';
import '../../../core/widgets/db_meter.dart';
import '../../../core/widgets/waveform.dart';

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final env = context.watch<EnvironmentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Environment Check')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checking your environment…', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Status', style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          EnvironmentBadge(state: env.state),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DbMeter(value: env.latestMeanDb, label: 'Live dB'),
                      const SizedBox(height: 16),
                      const Waveform(height: 48),
                      const SizedBox(height: 12),
                      Text(
                        _messageFor(env.state),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (env.calibration == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Calibration is recommended for accurate noise thresholds.')),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _messageFor(EnvironmentState s) {
    switch (s) {
      case EnvironmentState.ok:
        return 'Environment OK. You can start practicing.';
      case EnvironmentState.noisy:
        return 'Too noisy. Please move to a quieter place for better results.';
      case EnvironmentState.unknown:
        return 'Calibration not found. Noise status is unknown.';
    }
  }
}
