import 'package:flutter/material.dart';

class DbMeter extends StatelessWidget {
  final double value;
  final String label;

  const DbMeter({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {

    final v = value.isFinite ? value : 0;
    final normalized = ((v + 60) / 80).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Text('${v.toStringAsFixed(1)} dB', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
