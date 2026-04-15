import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/calibration_controller.dart';
import '../../../core/widgets/db_meter.dart';

class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const lightNavy = Color(0xFF2A4A62);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
  static const accentGreen = Color(0xFF4CAF50);
}

class CalibrationScreen extends StatelessWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CalibrationController>();

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
                        'Microphone Calibration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _P.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Calibration improves noise detection and voice thresholds on this device.',
                    style: TextStyle(fontSize: 13, color: _P.textMuted),
                  ),
                ),
                const SizedBox(height: 20),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1: Ambient Noise',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stay quiet for a few seconds.',
                        style: TextStyle(fontSize: 14, color: _P.textDark),
                      ),
                      const SizedBox(height: 14),
                      DbMeter(value: c.latestDb, label: 'Ambient (live)'),
                      const SizedBox(height: 16),
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
                          onPressed: c.sampling
                              ? null
                              : () async {
                                  try {
                                    await c.startCalibration();
                                    await c.sampleAmbient();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Ambient sample saved. Next: Voice sample.'),
                                          backgroundColor: _P.navy,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Calibration error: $e'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.play_circle, size: 18),
                          label: Text(
                            c.sampling ? 'Sampling…' : 'Sample Ambient',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Voice Sample',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Read: "SmartSpeak helps me speak clearly."',
                        style: TextStyle(fontSize: 14, color: _P.textDark, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 14),
                      DbMeter(value: c.latestDb, label: 'Voice (live)'),
                      const SizedBox(height: 16),
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
                          onPressed: (c.sampling || c.step != CalibrationStep.voice)
                              ? null
                              : () async {
                                  try {
                                    await c.sampleVoice();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Voice sample saved. Calibration complete.'),
                                          backgroundColor: _P.navy,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Calibration error: $e'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.record_voice_over, size: 18),
                          label: Text(
                            c.sampling ? 'Sampling…' : 'Sample Voice',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (c.data != null) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.black.withOpacity(0.08)),
                        const SizedBox(height: 12),
                        Text(
                          'Saved thresholds',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _P.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _line('Noise OK threshold', '${c.data!.noiseOkThresholdDb.toStringAsFixed(1)} dB'),
                        const SizedBox(height: 4),
                        _line('Voice detect threshold', '${c.data!.voiceDetectThresholdDb.toStringAsFixed(1)} dB'),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${c.updatedAtLabel}',
                          style: TextStyle(fontSize: 12, color: _P.textMuted),
                        ),
                      ],
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

  Widget _line(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(k, style: TextStyle(fontSize: 13, color: _P.textDark)),
        ),
        Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _P.navy)),
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
