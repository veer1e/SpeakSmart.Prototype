import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../calibration/controllers/calibration_controller.dart';
import '../../environment/controllers/environment_controller.dart';
import '../controllers/practice_controller.dart';
import '../models/conversation_scenario.dart';
import '../../../core/widgets/mic_button.dart';
import '../../../core/widgets/waveform.dart';
import '../../../core/widgets/db_meter.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeController>();
    final calib = context.watch<CalibrationController>();
    final env = context.watch<EnvironmentController>();

    final isNoisy =
        (calib.data != null) && (env.latestMeanDb > calib.data!.noiseOkThresholdDb);
    final current = p.currentTurn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            tooltip: 'Calibration',
            onPressed: () => Navigator.pushNamed(context, Routes.calibration),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Environment',
            onPressed: () => Navigator.pushNamed(context, Routes.environment),
            icon: const Icon(Icons.graphic_eq),
          ),
          IconButton(
            tooltip: 'Restart',
            onPressed: p.resetConversation,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  _DifficultyPicker(difficulty: p.difficulty, onChanged: p.setDifficulty),
                  const SizedBox(height: 10),
                  _ScenarioPicker(
                    scenarios: p.scenariosFor(p.difficulty),
                    scenario: p.scenario,
                    onChanged: p.setScenario,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  if (p.history.isEmpty)
                    const _InfoCard(
                      title: 'Roleplay Conversation',
                      body:
                          'The app speaks the partner line (TTS). Then it is your turn to speak the highlighted prompt. '
                          'Your SmartSpeak Score is computed per user turn.',
                    ),
                  for (final m in p.history) ...[
                    _ChatBubble(speaker: m.speaker, text: m.text),
                    const SizedBox(height: 8),
                  ],
                  if (current != null && !p.isFinished)
                    _TurnCard(
                      isSystemTurn: p.isSystemTurn,
                      systemLine: p.systemLine,
                      expectedUserLine: p.expectedUserLine,
                      onReplay: p.isSystemTurn ? p.replaySystemLine : p.replayExpectedUserLine,
                    )
                  else if (p.isFinished)
                    const _InfoCard(
                      title: 'Conversation Complete',
                      body: 'You finished this scenario. Tap Restart or choose another scenario.',
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DbMeter(value: env.latestMeanDb, label: 'Mic level (live)'),
                          ),
                          const SizedBox(width: 12),
                          if (isNoisy)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_outlined,
                                      color: Theme.of(context).colorScheme.error),
                                  const SizedBox(width: 6),
                                  Text('Too noisy',
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.error)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Waveform(height: 36),
                      const SizedBox(height: 12),
                      MicButton(
                        isRecording: p.recordState == RecordState.listening,
                        onPressed: () async {
                          if (p.isFinished) return;

                          try {
                            if (p.isSystemTurn) {
                              // user taps to advance after listening
                              await p.nextTurn();
                              return;
                            }

                            if (!p.isUserTurn) {
                              throw Exception('Listen to the partner first.');
                            }

                            if (p.recordState == RecordState.listening) {
                              await p.stopRecording();
                              final result = p.buildScoreForCurrentUserLine();
                              if (context.mounted) {
                                context
                                    .read<EnvironmentController>()
                                    .recordPractice(result.breakdown.smartSpeakScore);
                                Navigator.pushNamed(context, Routes.feedback, arguments: result);
                              }
                              await p.commitUserLineAndAdvance(
                                  recognizedText: result.recognizedText);
                            } else {
                              await p.startRecording();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Action error: $e')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _bottomHint(p),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      if (p.partialText.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Live STT: ${p.partialText}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bottomHint(PracticeController p) {
    if (p.isFinished) return 'Conversation complete.';
    if (p.isSystemTurn) return 'Partner is speaking. Tap mic to continue to your turn.';
    if (p.recordState == RecordState.listening) return 'Listening… speak your line now.';
    return 'Your turn. Tap the mic and say the prompt exactly.';
  }
}

class _DifficultyPicker extends StatelessWidget {
  final Difficulty difficulty;
  final void Function(Difficulty) onChanged;

  const _DifficultyPicker({required this.difficulty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Difficulty>(
      segments: const [
        ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
        ButtonSegment(value: Difficulty.medium, label: Text('Medium')),
        ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
      ],
      selected: {difficulty},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _ScenarioPicker extends StatelessWidget {
  final List<ConversationScenario> scenarios;
  final ConversationScenario scenario;
  final void Function(ConversationScenario) onChanged;

  const _ScenarioPicker({
    required this.scenarios,
    required this.scenario,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: scenario.id,
      decoration: const InputDecoration(
        labelText: 'Scenario',
        isDense: true,
      ),
      items: [
        for (final s in scenarios) DropdownMenuItem(value: s.id, child: Text(s.title)),
      ],
      onChanged: (id) {
        final s = scenarios.firstWhere((x) => x.id == id);
        onChanged(s);
      },
    );
  }
}

class _TurnCard extends StatelessWidget {
  final bool isSystemTurn;
  final String systemLine;
  final String expectedUserLine;
  final VoidCallback? onReplay;

  const _TurnCard({
    required this.isSystemTurn,
    required this.systemLine,
    required this.expectedUserLine,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = isSystemTurn ? 'Partner (TTS)' : 'Your Turn';
    final body = isSystemTurn ? systemLine : expectedUserLine;

    // Clear replay distinction
    final replayIcon = isSystemTurn ? Icons.play_circle_fill : Icons.record_voice_over;
    final replayLabel = isSystemTurn ? 'Hear example' : 'Hear my line';
    final replayTooltip =
        isSystemTurn ? 'Replay partner line' : 'Preview how your line should sound';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (onReplay != null)
                  Tooltip(
                    message: replayTooltip,
                    child: OutlinedButton.icon(
                      onPressed: onReplay,
                      icon: Icon(replayIcon),
                      label: Text(replayLabel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSystemTurn
                    ? scheme.surfaceContainerHighest
                    : scheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                body,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSystemTurn ? scheme.onSurfaceVariant : scheme.primary,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSystemTurn ? 'Listen, then continue.' : 'Speak this line clearly.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Speaker speaker;
  final String text;

  const _ChatBubble({required this.speaker, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSystem = speaker == Speaker.system;

    return Align(
      alignment: isSystem ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSystem ? scheme.surfaceContainerHighest : scheme.primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            text,
            style: TextStyle(color: isSystem ? scheme.onSurfaceVariant : scheme.primary),
          ),
        ),
      ),
    );
  }
}