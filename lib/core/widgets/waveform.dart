import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_level_service.dart';

class Waveform extends StatefulWidget {
  final double height;
  const Waveform({super.key, required this.height});

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  double _amp = 0.3;

  @override
  void initState() {
    super.initState();
    // Drive amplitude from live dB
    final audio = context.read<AudioLevelService>();
    audio.stream.listen((r) {
      final v = r.meanDb;
      final normalized = ((v + 60) / 80).clamp(0.0, 1.0);
      setState(() => _amp = 0.15 + 0.85 * normalized);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _WavePainter(phase: _c.value * 2 * pi, amplitude: _amp),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final double amplitude;

  _WavePainter({required this.phase, required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;
    final points = <Offset>[];

    for (double x = 0; x <= size.width; x += 4) {
      final t = x / size.width;
      final y = midY + sin((t * 2 * pi) + phase) * (midY * 0.8) * amplitude * _envelope(t);
      points.add(Offset(x, y));
    }

    // Gradient-like effect without specifying colors manually: use theme primary with opacity.
    paint.color = Colors.black.withOpacity(0.10);
    canvas.drawPoints(ui.PointMode.polygon, points, paint);

    paint.color = Colors.black.withOpacity(0.18);
    canvas.drawPoints(ui.PointMode.polygon, points.map((p) => Offset(p.dx, p.dy + 2)).toList(), paint);
  }

  double _envelope(double t) {
    // Smooth envelope to reduce edges.
    final a = t < 0.5 ? (t / 0.5) : ((1 - t) / 0.5);
    return a.clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.amplitude != amplitude;
  }
}
