import 'package:flutter/material.dart';

import '../../practice/models/score_result.dart';
import '../../../core/widgets/score_ring.dart';
import '../../../core/widgets/word_highlights.dart';

class FeedbackScreen extends StatelessWidget {
  final ScoreResult result;

  const FeedbackScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final b = result.breakdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ScoreRing(
                  score: b.smartSpeakScore,
                  label: 'SmartSpeak Score',
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expected', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(result.promptText),
                      const SizedBox(height: 12),
                      Text('You said', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(result.recognizedText.isEmpty ? '—' : result.recognizedText),
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
                      Text('Word-level highlights', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      WordHighlights(expectedScores: b.expectedWordScores, spokenWords: b.spokenWords),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Score breakdown', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _line('Correct in order', '${b.matchedInOrder}/${b.expectedCount}'),
                      _line('Extra words', '${b.extraCount}'),
                      _line('Word accuracy', '${(b.wordAccuracy * 100).toStringAsFixed(0)}%'),
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
                      Text('Fluency', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _line('Filler words', '${result.fluency.fillerCount}'),
                      _line('Total pause time', '${result.fluency.totalPauseSeconds.toStringAsFixed(1)}s'),
                      _line('Longest pause', '${result.fluency.longestPauseSeconds.toStringAsFixed(1)}s'),
                      const SizedBox(height: 12),
                      Text('Tips', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ..._tips(result),
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

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  List<Widget> _tips(ScoreResult r) {
    final tips = <String>[];
    if (r.fluency.fillerCount > 0) {
      tips.add('Try to pause silently instead of using filler words (e.g., “uh”, “um”).');
    }
    if (r.fluency.longestPauseSeconds > 1.0) {
      tips.add('Practice speaking in short chunks to reduce long pauses.');
    }
    if (r.breakdown.extraCount > 0) {
      tips.add('Focus on the expected words only—avoid adding extra words.');
    }
    if (r.breakdown.wordAccuracy < 0.85) {
      tips.add('Slow down slightly and repeat the difficult words clearly.');
    }
    if (tips.isEmpty) {
      tips.add('Nice work—try a longer phrase next for a bigger challenge.');
    }

    // Include one actionable pronunciation tip:
    tips.add('Tip: Tap “Listen” before recording and mimic the rhythm and stress.');

    return tips.map((t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(t)),
        ],
      ),
    )).toList();
  }
}
