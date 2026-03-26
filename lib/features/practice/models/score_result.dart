import 'fluency_metrics.dart';

class WordScore {
  final String word;
  final bool expected; 
  final bool credited; 
  final bool extra; 

  const WordScore({
    required this.word,
    required this.expected,
    required this.credited,
    required this.extra,
  });
}

class ScoreBreakdown {
  final int expectedCount;
  final int matchedInOrder;
  final int extraCount;
  final double wordAccuracy; 
  final int smartSpeakScore; 
  final List<WordScore> expectedWordScores;
  final List<String> spokenWords;

  const ScoreBreakdown({
    required this.expectedCount,
    required this.matchedInOrder,
    required this.extraCount,
    required this.wordAccuracy,
    required this.smartSpeakScore,
    required this.expectedWordScores,
    required this.spokenWords,
  });
}

class ScoreResult {
  final String promptText;
  final String recognizedText;
  final ScoreBreakdown breakdown;
  final FluencyMetrics fluency;

  const ScoreResult({
    required this.promptText,
    required this.recognizedText,
    required this.breakdown,
    required this.fluency,
  });
}
