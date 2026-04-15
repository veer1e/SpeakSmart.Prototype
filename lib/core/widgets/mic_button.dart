import 'package:flutter/material.dart';

enum MicButtonState { idle, recording, processing }

class MicButton extends StatelessWidget {
  /// Prefer [state] for full control. [isRecording] is kept for back-compat
  /// but is ignored when [state] is provided.
  final MicButtonState state;
  final VoidCallback? onPressed;

  const MicButton({
    super.key,
    required this.onPressed,
    this.state = MicButtonState.idle,
    // Legacy param — mapped to state in the named constructor below
    bool isRecording = false,
  });

  /// Convenience constructor that maps the old bool to a state.
  const MicButton.fromBool({
    super.key,
    required bool isRecording,
    required this.onPressed,
  }) : state = isRecording ? MicButtonState.recording : MicButtonState.idle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color color;
    final Widget inner;

    switch (state) {
      case MicButtonState.recording:
        color = cs.error;
        inner = const Icon(Icons.stop, size: 40, color: Colors.white);
        break;
      case MicButtonState.processing:
        color = cs.primary.withOpacity(0.55);
        inner = const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
        break;
      case MicButtonState.idle:
        color = cs.primary;
        inner = const Icon(Icons.mic, size: 40, color: Colors.white);
        break;
    }

    final bool enabled = state != MicButtonState.processing && onPressed != null;

    return SizedBox(
      width: 92,
      height: 92,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: Center(child: inner),
        ),
      ),
    );
  }
}
