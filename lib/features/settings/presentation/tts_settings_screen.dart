import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/tts_service.dart';

class TtsSettingsScreen extends StatefulWidget {
  const TtsSettingsScreen({super.key});

  static const String sampleText =
      'SmartSpeak sample: Clear speech at your chosen speed and pitch.';

  @override
  State<TtsSettingsScreen> createState() => _TtsSettingsScreenState();
}

class _TtsSettingsScreenState extends State<TtsSettingsScreen> {
  late double _rate;
  late double _pitch;
  late final TtsService _tts;

  @override
  void initState() {
    super.initState();
    // Provider is available in main.dart via MultiProvider.
    _tts = context.read<TtsService>();
    _rate = _tts.rate;
    _pitch = _tts.pitch;
  }

  Future<void> _playSample() async {
    await _tts.speak(TtsSettingsScreen.sampleText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Text-to-Speech (TTS)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust how SmartSpeak reads example lines. These settings are saved on your device.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SliderRow(
                    label: 'Speed',
                    value: _rate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    valueLabel: _rate.toStringAsFixed(2),
                    onChanged: (v) async {
                      setState(() => _rate = v);
                      await _tts.setRate(v);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SliderRow(
                    label: 'Pitch',
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    valueLabel: _pitch.toStringAsFixed(2),
                    onChanged: (v) async {
                      setState(() => _pitch = v);
                      await _tts.setPitch(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _playSample,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Play sample'),
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

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(valueLabel),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
