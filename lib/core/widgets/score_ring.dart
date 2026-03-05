import 'dart:math';

import 'package:flutter/material.dart';

class ScoreRing extends StatefulWidget {
  final int score;
  final String label;

  const ScoreRing({super.key, required this.score, required this.label});

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _a = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _a = Tween<double>(begin: oldWidget.score / 100, end: widget.score / 100).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
      );
      _c
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 180),
                painter: _RingPainter(progress: _a.value, color: Theme.of(context).colorScheme.primary),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${widget.score}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    final bg = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.color != color;
}
