import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/db_meter.dart';
import '../../../core/widgets/mic_button.dart';
import '../../calibration/controllers/calibration_controller.dart';
import '../../environment/controllers/environment_controller.dart';
import '../controllers/practice_controller.dart';
import '../models/conversation_scenario.dart';
import '../../../core/widgets/karaoke_text.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  bool _started = false;

  
  bool _isSpeaking = false;
  String? _speakingText; 
  Speaker? _speakingSpeaker;

  String? _lastScenarioId;
  Difficulty? _lastDifficulty;

  
  final ScrollController _sessionScroll = ScrollController();

  void _scrollToBottom() {
    if (!_sessionScroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sessionScroll.hasClients) return;
      _sessionScroll.animateTo(
        _sessionScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _sessionScroll.dispose();
    super.dispose();
  }

  void _syncPreviewState(PracticeController p) {
    final changed = (_lastScenarioId != p.scenario.id) || (_lastDifficulty != p.difficulty);
    if (changed) {
      _lastScenarioId = p.scenario.id;
      _lastDifficulty = p.difficulty;
      if (_started) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _started = false);
          p.resetConversation();
        });
      }
    }
  }

  Future<void> _speakWithUi(TtsService tts, {required String text, required Speaker speaker}) async {
    if (_isSpeaking) return; 
    setState(() {
      _isSpeaking = true;
      _speakingText = text;
      _speakingSpeaker = speaker;
    });

    try {
      await tts.speak(text);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _speakingText = null;
        _speakingSpeaker = null;
      });
    }
  }

  Future<void> _speakCurrentSystemLineIfAny({
    required PracticeController p,
    required TtsService tts,
  }) async {
    
    if (p.isSystemTurn && p.systemLine.isNotEmpty) {
      await _speakWithUi(tts, text: p.systemLine, speaker: Speaker.system);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeController>();
    final calib = context.watch<CalibrationController>();
    final env = context.watch<EnvironmentController>();
    final tts = context.read<TtsService>();

    _syncPreviewState(p);

    final isNoisy = (calib.data != null) && (env.latestMeanDb > calib.data!.noiseOkThresholdDb);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SPEAKSMART'),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: () {
              setState(() => _started = false);
              p.resetConversation();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const _PracticeMenuSheet(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Practice', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _DifficultyPicker(
                    difficulty: p.difficulty,
                    onChanged: (d) {
                      p.setDifficulty(d);
                      setState(() => _started = false);
                      p.resetConversation();
                    },
                  ),
                  const SizedBox(height: 10),
                  _ScenarioPicker(
                    scenarios: p.scenariosFor(p.difficulty),
                    scenario: p.scenario,
                    onChanged: (s) {
                      p.setScenario(s);
                      setState(() => _started = false);
                      p.resetConversation();
                    },
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: !_started
                  ? _PreviewPane(
                      scenario: p.scenario,
                      isSpeaking: _isSpeaking,
                      speakingText: _speakingText,
                      speakingSpeaker: _speakingSpeaker,
                      onPlayLine: (speaker, text) async {
                        await _speakWithUi(tts, text: text, speaker: speaker);
                      },
                    )
                  : _SessionPane(
                      controller: _sessionScroll, 
                      isNoisy: isNoisy,
                      isSpeaking: _isSpeaking,
                      speakingText: _speakingText,
                      speakingSpeaker: _speakingSpeaker,
                      onSpeak: (speaker, text) async {
                        await _speakWithUi(tts, text: text, speaker: speaker);
                      },
                    ),
            ),

            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: !_started
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _TipToolbox(),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSpeaking
                                ? null
                                : () async {
                                    setState(() => _started = true);

                                    
                                    p.resetConversation();

                                    
                                    await _speakCurrentSystemLineIfAny(p: p, tts: tts);
                                  },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('START'),
                          ),
                        ),
                      ],
                    )
                  : _RecorderCard(
                      isNoisy: isNoisy,
                      isSpeaking: _isSpeaking,
                      onResumeSystemAfterFeedback: () async {
                        await _speakCurrentSystemLineIfAny(p: p, tts: tts);
                      },
                      onAfterAdvanceScroll: _scrollToBottom, 
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PreviewPane extends StatelessWidget {
  final ConversationScenario scenario;

  final bool isSpeaking;
  final String? speakingText;
  final Speaker? speakingSpeaker;

  final Future<void> Function(Speaker speaker, String text) onPlayLine;

  const _PreviewPane({
    required this.scenario,
    required this.isSpeaking,
    required this.speakingText,
    required this.speakingSpeaker,
    required this.onPlayLine,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: [
        const SizedBox(height: 4),
        Text('Preview:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (int i = 0; i < scenario.turns.length; i++) ...[
                  _ConversationBubble(
                    speaker: scenario.turns[i].speaker,
                    text: scenario.turns[i].text,
                    isSpeaking: isSpeaking &&
                        speakingText == scenario.turns[i].text &&
                        speakingSpeaker == scenario.turns[i].speaker,
                    onPlay: () => onPlayLine(scenario.turns[i].speaker, scenario.turns[i].text),
                  ),
                  if (i != scenario.turns.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _SessionPane extends StatelessWidget {
  final ScrollController controller; 
  final bool isNoisy;

  final bool isSpeaking;
  final String? speakingText;
  final Speaker? speakingSpeaker;

  final Future<void> Function(Speaker speaker, String text) onSpeak;

  const _SessionPane({
    required this.controller, 
    required this.isNoisy,
    required this.isSpeaking,
    required this.speakingText,
    required this.speakingSpeaker,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeController>();
    final current = p.currentTurn;

    return ListView(
      controller: controller, 
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      children: [
        if (p.history.isEmpty)
          const _InfoCard(
            title: 'Roleplay Conversation',
            body:
                'Tap the play button to replay lines. Partner lines are TTS. On your turn, use “Hear my line” to listen before recording.',
          ),
        for (final m in p.history) ...[
          _ConversationBubble(
            speaker: m.speaker,
            text: m.text,
            isSpeaking: isSpeaking && speakingText == m.text && speakingSpeaker == m.speaker,
            onPlay: () => onSpeak(m.speaker, m.text),
          ),
          const SizedBox(height: 10),
        ],
        if (current != null && !p.isFinished) ...[
          _ConversationBubble(
            speaker: current.speaker,
            text: current.text,
            emphasis: true,
            isSpeaking:
                isSpeaking && speakingText == current.text && speakingSpeaker == current.speaker,
            onPlay: () async {
              if (current.speaker == Speaker.system) {
                await onSpeak(Speaker.system, p.systemLine);
              } else {
                await onSpeak(Speaker.user, p.expectedUserLine);
              }
            },
            playLabel: current.speaker == Speaker.system ? 'Replay Partner' : 'Hear my line',
            playIcon:
                current.speaker == Speaker.system ? Icons.replay : Icons.record_voice_over_rounded,
          ),
        ] else if (p.isFinished) ...[
          const _InfoCard(
            title: 'Conversation Complete',
            body: 'You finished this scenario. Tap Restart or choose another scenario.',
          ),
        ],
      ],
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  final Speaker speaker;
  final String text;
  final VoidCallback onPlay;

  final bool emphasis;
  final bool isSpeaking;

  final String? playLabel;
  final IconData? playIcon;

  const _ConversationBubble({
    required this.speaker,
    required this.text,
    required this.onPlay,
    required this.isSpeaking,
    this.emphasis = false,
    this.playLabel,
    this.playIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final isPartner = speaker == Speaker.system;

    final bubbleColor = isPartner ? scheme.surfaceContainerHighest : scheme.primary;
    final textColor = isPartner ? scheme.onSurfaceVariant : scheme.onPrimary;
    final align = isPartner ? Alignment.centerLeft : Alignment.centerRight;

    final iconBg = isPartner ? scheme.surface : scheme.primaryContainer;
    final iconFg = isPartner ? scheme.onSurfaceVariant : scheme.onPrimaryContainer;

    final borderColor =
        isSpeaking ? (isPartner ? scheme.primary : scheme.onPrimary) : scheme.outlineVariant;

    final effectivePlayLabel = playLabel ?? 'Play';
    final effectivePlayIcon = playIcon ?? Icons.play_arrow_rounded;

    return Align(
      alignment: align,
      child: Row(
        mainAxisAlignment: isPartner ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPartner) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: iconBg,
              child: Icon(Icons.support_agent_rounded, size: 16, color: iconFg),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: isSpeaking ? 2 : 1,
                ),
                boxShadow: isSpeaking
                    ? [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 0,
                          color: scheme.primary.withOpacity(0.18),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: KaraokeText(
                          text: text,
                          active: isSpeaking,
                          msPerWord: 320,
                          highlightOpacity: 0.22,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: textColor,
                                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkResponse(
                        onTap: isSpeaking ? null : onPlay,
                        radius: 22,
                        child: Icon(effectivePlayIcon, color: textColor),
                      ),
                    ],
                  ),
                  if (isSpeaking) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: textColor.withOpacity(0.18),
                      ),
                    ),
                  ],
                  if (emphasis) ...[
                    const SizedBox(height: 8),
                    Text(
                      effectivePlayLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: textColor.withOpacity(0.9),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isPartner) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.secondaryContainer,
              child: Icon(Icons.person_rounded, size: 16, color: scheme.onSecondaryContainer),
            ),
          ],
        ],
      ),
    );
  }
}

class _TipToolbox extends StatelessWidget {
  const _TipToolbox();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.tips_and_updates_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tip', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Use Preview to listen to any line. Tap START to begin; partner will speak once. '
                    'During your turn, tap “Hear my line” if you need a replay before recording.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecorderCard extends StatelessWidget {
  final bool isNoisy;
  final bool isSpeaking;

 
  final Future<void> Function() onResumeSystemAfterFeedback;

  
  final VoidCallback onAfterAdvanceScroll;

  const _RecorderCard({
    required this.isNoisy,
    required this.isSpeaking,
    required this.onResumeSystemAfterFeedback,
    required this.onAfterAdvanceScroll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PracticeController>();
    final calib = context.watch<CalibrationController>();
    final env = context.watch<EnvironmentController>();

    final isNoisyComputed =
        (calib.data != null) && (env.latestMeanDb > calib.data!.noiseOkThresholdDb);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: DbMeter(value: env.latestMeanDb, label: 'Mic level (live)')),
                const SizedBox(width: 12),
                if (isNoisyComputed)
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
                            style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            MicButton(
              isRecording: p.recordState == RecordState.listening,
              onPressed: () {
                if (isSpeaking) return;
                _handleMicPressed(context, p);
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
    );
  }

  Future<void> _handleMicPressed(BuildContext context, PracticeController p) async {
  if (p.isFinished) return;

  try {
    if (p.isSystemTurn) {
      await p.nextTurn();
      onAfterAdvanceScroll();
      return;
    }

    if (!p.isUserTurn) {
      throw Exception('Listen to the partner first.');
    }

    if (p.recordState == RecordState.listening) {
      await p.stopRecording();

      final result = p.buildScoreForCurrentUserLine();
      final score = result.breakdown.smartSpeakScore;

      if (context.mounted) {
        context.read<EnvironmentController>().recordPractice(score);
      }

      
      bool shouldAdvance = true;

      if (score < 100 && context.mounted) {
        shouldAdvance = await _showRetryDialog(context, score);
      }

      if (!shouldAdvance) {
        
        return;
      }
     

      if (context.mounted) {
        await Navigator.pushNamed(context, Routes.feedback, arguments: result);
      }

      await p.commitUserLineAndAdvance(
        recognizedText: result.recognizedText,
      );

      onAfterAdvanceScroll();

      await onResumeSystemAfterFeedback();

      onAfterAdvanceScroll();
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
}

  String _bottomHint(PracticeController p) {
    if (p.isFinished) return 'Conversation complete.';
    if (p.isSystemTurn) return 'Partner is speaking. Tap mic to continue to your turn.';
    if (p.recordState == RecordState.listening) return 'Listening… speak your line now.';
    return 'Your turn. Tap the mic and say the prompt exactly.';
  }
  Future<bool> _showRetryDialog(BuildContext context, int score) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Almost there 👀'),
        content: Text(
          'You scored $score.\n\nDo you want to retry this line or continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
}


class _DifficultyPicker extends StatelessWidget {
  final Difficulty difficulty;
  final void Function(Difficulty) onChanged;

  const _DifficultyPicker({required this.difficulty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget label(String text) => SizedBox(
          width: 84,
          child: Center(child: Text(text)),
        );

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<Difficulty>(
        segments: [
          ButtonSegment(value: Difficulty.easy, label: label('Easy')),
          ButtonSegment(value: Difficulty.medium, label: label('Medium')),
          ButtonSegment(value: Difficulty.hard, label: label('Hard')),
        ],
        selected: {difficulty},
        onSelectionChanged: (s) => onChanged(s.first),
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
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
        if (id == null) return;
        final s = scenarios.firstWhere((x) => x.id == id);
        onChanged(s);
      },
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

class _PracticeMenuSheet extends StatelessWidget {
  const _PracticeMenuSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Calibration'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.calibration);
            },
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text('Environment'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.environment);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}