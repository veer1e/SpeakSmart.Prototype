import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const MicButton({super.key, required this.isRecording, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = isRecording ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 92,
      height: 92,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              isRecording ? Icons.stop : Icons.mic,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
