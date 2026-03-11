import 'dart:async';

import 'package:flutter/material.dart';

/// A simple "fake karaoke" highlighter:
/// - When [active] becomes true, it highlights words one-by-one using a timer.
/// - Timing is estimated (no TTS word callbacks needed).
class KaraokeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool active;

  /// Optional: tweak speed. Lower = faster highlight.
  /// Default ~320ms per word (decent for normal speech).
  final int msPerWord;

  /// Optional: highlight background opacity (uses current text color).
  final double highlightOpacity;

  const KaraokeText({
    super.key,
    required this.text,
    required this.style,
    required this.active,
    this.msPerWord = 320,
    this.highlightOpacity = 0.20,
  });

  @override
  State<KaraokeText> createState() => _KaraokeTextState();
}

class _KaraokeTextState extends State<KaraokeText> {
  Timer? _timer;
  int _index = -1;

  List<String> get _words {
    // Split on whitespace, keep it simple and robust.
    final raw = widget.text.trim().split(RegExp(r'\s+'));
    return raw.where((w) => w.isNotEmpty).toList();
  }

  @override
  void didUpdateWidget(covariant KaraokeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If text changes, reset.
    if (oldWidget.text != widget.text) {
      _stop(reset: true);
    }

    // Start/stop based on active flag.
    if (!oldWidget.active && widget.active) {
      _start();
    } else if (oldWidget.active && !widget.active) {
      _stop(reset: true);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void dispose() {
    _stop(reset: false);
    super.dispose();
  }

  void _start() {
    _stop(reset: true);

    final words = _words;
    if (words.isEmpty) return;

    // Start at first word.
    setState(() => _index = 0);

    _timer = Timer.periodic(Duration(milliseconds: widget.msPerWord), (t) {
      if (!mounted) return;

      final next = _index + 1;
      if (next >= words.length) {
        // Stay on last word until speaking ends (parent will set active=false).
        t.cancel();
        return;
      }
      setState(() => _index = next);
    });
  }

  void _stop({required bool reset}) {
    _timer?.cancel();
    _timer = null;
    if (reset && mounted) {
      setState(() => _index = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _words;
    if (words.isEmpty) {
      return Text(widget.text, style: widget.style);
    }

    // If not active, render normally (faster + cleaner).
    if (!widget.active) {
      return Text(widget.text, style: widget.style);
    }

    final baseColor = widget.style.color ?? Theme.of(context).colorScheme.onSurface;
    final highlightBg = baseColor.withOpacity(widget.highlightOpacity);

    return RichText(
      text: TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            TextSpan(
              text: words[i],
              style: widget.style.copyWith(
                backgroundColor: (i == _index) ? highlightBg : null,
                // a tiny emphasis for the active word
                fontWeight: (i == _index) ? FontWeight.w700 : widget.style.fontWeight,
              ),
            ),
            if (i != words.length - 1)
              TextSpan(text: ' ', style: widget.style),
          ],
        ],
      ),
    );
  }
}