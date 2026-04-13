import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/tts_service.dart';

class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
  static const accentGreen = Color(0xFF4CAF50);
}

class TtsSettingsScreen extends StatefulWidget {
  const TtsSettingsScreen({super.key});

  static const String sampleText = 'SmartSpeak sample: Clear speech at your chosen speed and pitch.';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_P.bgTop, _P.bgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: _P.navy,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Speech Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _P.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Text-to-Speech (TTS)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adjust how SmartSpeak reads example lines. These settings are saved on your device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _P.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _P.accentGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _playSample,
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: const Text('Play sample', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _P.navy,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _P.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _P.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _P.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}