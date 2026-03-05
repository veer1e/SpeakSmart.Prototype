import '../../../core/utils/text_normalize.dart';
import '../../../core/utils/num.dart';
import '../models/fluency_metrics.dart';
import '../models/score_result.dart';

class ScoringService {
  static const fillerSet = {
    'uh', 'um', 'uhm', 'umm', 'hmm', 'ah', 'er', 'erm'
  };

  ScoreResult score({
    required String expectedText,
    required String recognizedText,
    required FluencyMetrics fluency,
  }) {
    final expected = tokenizeWords(expectedText);
    final spokenAll = tokenizeWords(recognizedText);
    final spoken = spokenAll.where((w) => w.isNotEmpty).toList();

    // Order-based matching:
    int i = 0; // expected index
    final usedSpoken = List<bool>.filled(spoken.length, false);
    final expectedScores = <WordScore>[];

    for (final exp in expected) {
      bool matched = false;
      for (int j = 0; j < spoken.length; j++) {
        if (usedSpoken[j]) continue;
        if (spoken[j] == exp) {
          usedSpoken[j] = true;
          matched = true;
          break;
        }
      }
      // The above matches anywhere; we need in-order credit:
      // Implement true in-order scan:
    }

    // True in-order scan:
    i = 0;
    for (int j = 0; j < spoken.length && i < expected.length; j++) {
      if (fillerSet.contains(spoken[j])) continue; // fillers do not help matching
      if (spoken[j] == expected[i]) {
        usedSpoken[j] = true;
        i += 1;
      }
    }
    final matchedInOrder = i;

    // Build expected word score list
    for (int k = 0; k < expected.length; k++) {
      expectedScores.add(
        WordScore(
          word: expected[k],
          expected: true,
          credited: k < matchedInOrder,
          extra: false,
        ),
      );
    }

    // Count extra words (excluding fillers)
    int extraCount = 0;
    for (int j = 0; j < spoken.length; j++) {
      final w = spoken[j];
      if (fillerSet.contains(w)) continue;
      if (!usedSpoken[j]) extraCount += 1;
    }

    final expectedCount = expected.length;
    final accuracy = expectedCount == 0 ? 0.0 : (matchedInOrder / expectedCount);
    final penalty = expectedCount == 0 ? 1.0 : (extraCount / expectedCount);

    final score = (100.0 * (0.75 * accuracy + 0.25 * (1 - clampDouble(penalty, 0, 1)))).round();
    final smartSpeakScore = score.clamp(0, 100);

    final breakdown = ScoreBreakdown(
      expectedCount: expectedCount,
      matchedInOrder: matchedInOrder,
      extraCount: extraCount,
      wordAccuracy: clampDouble(accuracy, 0, 1),
      smartSpeakScore: smartSpeakScore,
      expectedWordScores: expectedScores,
      spokenWords: spoken,
    );

    return ScoreResult(
      promptText: expectedText,
      recognizedText: recognizedText,
      breakdown: breakdown,
      fluency: fluency,
    );
  }
}
