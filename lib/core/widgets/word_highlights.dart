import 'package:flutter/material.dart';

import '../../features/practice/models/score_result.dart';
import '../../features/practice/services/scoring_service.dart';

class WordHighlights extends StatelessWidget {
  final List<WordScore> expectedScores;
  final List<String> spokenWords;

  const WordHighlights({super.key, required this.expectedScores, required this.spokenWords});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final expectedChips = expectedScores.map((w) {
      final bg = w.credited ? scheme.primary.withOpacity(0.12) : scheme.error.withOpacity(0.10);
      final fg = w.credited ? scheme.primary : scheme.error;
      return _chip(context, w.word, bg, fg);
    }).toList();

    final extras = spokenWords.where((w) => !ScoringService.fillerSet.contains(w)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expected words', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: expectedChips),
        const SizedBox(height: 12),
        Text('Spoken words', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: extras.map((w) => _chip(context, w, scheme.surfaceContainerHighest, scheme.onSurfaceVariant)).toList(),
        ),
        const SizedBox(height: 8),
        Text('Note: filler words are ignored for word matching.', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _chip(BuildContext context, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
