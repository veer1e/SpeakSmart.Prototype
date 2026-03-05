import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/calibration_controller.dart';
import '../../../core/widgets/db_meter.dart';

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CalibrationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Microphone Calibration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calibration improves noise detection and voice thresholds on this device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 1: Ambient Noise', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('Stay quiet for a few seconds.'),
                      const SizedBox(height: 12),
                      DbMeter(value: c.latestDb, label: 'Ambient (live)'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: c.sampling ? null : () async {
                          try {
                            await c.startCalibration();
                            await c.sampleAmbient();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ambient sample saved. Next: Voice sample.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calibration error: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.play_circle),
                        label: Text(c.sampling ? 'Sampling…' : 'Sample Ambient'),
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
                      Text('Step 2: Voice Sample', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('Read: “SmartSpeak helps me speak clearly.”'),
                      const SizedBox(height: 12),
                      DbMeter(value: c.latestDb, label: 'Voice (live)'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: c.sampling ? null : () async {
                          try {
                            await c.sampleVoice();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voice sample saved. Calibration complete.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calibration error: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.record_voice_over),
                        label: Text(c.sampling ? 'Sampling…' : 'Sample Voice'),
                      ),
                      const SizedBox(height: 12),
                      if (c.data != null) ...[
                        const Divider(),
                        Text('Saved thresholds', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text('Noise OK threshold: ${c.data!.noiseOkThresholdDb.toStringAsFixed(1)} dB'),
                        Text('Voice detect threshold: ${c.data!.voiceDetectThresholdDb.toStringAsFixed(1)} dB'),
                        const SizedBox(height: 8),
                        Text('Last updated: ${c.updatedAtLabel}'),
                      ],
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
}
