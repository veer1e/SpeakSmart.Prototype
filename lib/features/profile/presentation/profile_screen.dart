import 'package:flutter/material.dart';

import '../../../app/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.tune),
                    title: const Text('Microphone Calibration'),
                    subtitle: const Text('Set ambient and voice thresholds'),
                    onTap: () => Navigator.pushNamed(context, Routes.calibration),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.graphic_eq),
                    title: const Text('Environment Check'),
                    subtitle: const Text('See if your room is too noisy'),
                    onTap: () => Navigator.pushNamed(context, Routes.environment),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: const Text('Speech Settings'),
                    subtitle: const Text('TTS speed & pitch'),
                    onTap: () => Navigator.pushNamed(context, Routes.ttsSettings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
