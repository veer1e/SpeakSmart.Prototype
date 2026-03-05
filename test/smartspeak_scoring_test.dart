import 'package:flutter_test/flutter_test.dart';
import 'package:smartspeak/features/practice/services/scoring_service.dart';
import 'package:smartspeak/features/practice/models/fluency_metrics.dart';

void main() {
  test('Scoring credits expected words in order and penalizes extras', () {
    final s = ScoringService();
    final r = s.score(
      expectedText: 'I want to improve my pronunciation',
      recognizedText: 'I want uh to improve pronunciation',
      fluency: const FluencyMetrics(fillerCount: 1, totalPauseSeconds: 1.4, longestPauseSeconds: 0.9),
    );

    expect(r.breakdown.expectedCount, 6);
    expect(r.breakdown.matchedInOrder, 5);
    expect(r.breakdown.extraCount, 0); // "to" is expected, "uh" is filler ignored, "my" missing, no extra beyond fillers
    expect(r.breakdown.smartSpeakScore, inInclusiveRange(0, 100));
  });
}
