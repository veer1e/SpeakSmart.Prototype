import 'package:flutter/material.dart';
import '../../practice/models/score_result.dart';
import '../../../core/widgets/score_ring.dart';
import '../../../core/widgets/word_highlights.dart';

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
  static const accentCyan = Color(0xFF4DD0E1);
}

class FeedbackScreen extends StatefulWidget {
  final ScoreResult result;
  const FeedbackScreen({super.key, required this.result});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.result.breakdown.smartSpeakScore == 100) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context, 'continue');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.result.breakdown;
    
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
                    Expanded(
                      child: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _P.navy,
                        ),
                      ),
                    ),
                    if (b.smartSpeakScore == 100)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _P.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _P.accentGreen, width: 1.2),
                        ),
                        child: const Text(
                          'Perfect 🎯',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _P.accentGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ScoreRing(
                    score: b.smartSpeakScore,
                    label: 'SmartSpeak Score',
                  ),
                ),
                const SizedBox(height: 24),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Word-level highlights',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      WordHighlights(
                        expectedScores: b.expectedWordScores,
                        spokenWords: b.spokenWords,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.black.withOpacity(0.08)),
                      const SizedBox(height: 12),
                      Text(
                        'Score breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _line('Correct in order', '${b.matchedInOrder}/${b.expectedCount}'),
                      const SizedBox(height: 6),
                      _line('Extra words', '${b.extraCount}'),
                      const SizedBox(height: 6),
                      _line(
                        'Word accuracy',
                        '${(b.wordAccuracy * 100).toStringAsFixed(0)}%',
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
                        'Fluency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _line('Filler words', '${widget.result.fluency.fillerCount}'),
                      const SizedBox(height: 6),
                      _line(
                        'Total pause time',
                        '${widget.result.fluency.totalPauseSeconds.toStringAsFixed(1)}s',
                      ),
                      const SizedBox(height: 6),
                      _line(
                        'Longest pause',
                        '${widget.result.fluency.longestPauseSeconds.toStringAsFixed(1)}s',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _P.navy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._tips(widget.result),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _P.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, 'try_again'),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _P.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, 'continue'),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
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
          child: Text(
            k,
            style: TextStyle(color: _P.textDark, fontSize: 14),
          ),
        ),
        Text(
          v,
          style: TextStyle(
            color: _P.navy,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Widget> _tips(ScoreResult r) {
    final tips = <String>[];
    if (r.fluency.fillerCount > 0) {
      tips.add('Try to pause silently instead of using filler words (e.g., "uh", "um").');
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
    tips.add('Tip: Tap "Listen" before recording and mimic the rhythm and stress.');

    return tips
        .map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: _P.textMuted, fontSize: 14)),
                Expanded(
                  child: Text(
                    t,
                    style: TextStyle(color: _P.textDark, fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
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