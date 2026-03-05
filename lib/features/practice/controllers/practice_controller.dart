import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../models/fluency_metrics.dart';
import '../models/score_result.dart';
import '../services/scoring_service.dart';
import '../models/conversation_scenario.dart';

enum RecordState { idle, listening, processing }

class ChatMessage {
  final Speaker speaker;
  final String text;

  const ChatMessage({required this.speaker, required this.text});
}

class PracticeController extends ChangeNotifier {
  final StorageService storage;
  final SttService stt;
  final TtsService tts;

  final scoring = ScoringService();

  Difficulty difficulty = Difficulty.easy;
  late ConversationScenario scenario;

  int turnIndex = 0; // index in scenario.turns
  RecordState recordState = RecordState.idle;

  final List<ChatMessage> history = [];

  String partialText = '';
  String finalText = '';

  DateTime? _lastResultAt;
  double totalPauseSeconds = 0;
  double longestPauseSeconds = 0;
  int fillerCount = 0;

  StreamSubscription<SttResult>? _sub;

  PracticeController({required this.storage, required this.stt, required this.tts}) {
    scenario = conversationScenarios.first;
    _resetConversation();
    // Autoplay first system line
    _autoPlayIfSystemTurn();
  }

  List<ConversationScenario> scenariosFor(Difficulty d) =>
      conversationScenarios.where((s) => s.difficulty == d).toList();

  void setDifficulty(Difficulty d) {
    difficulty = d;
    scenario = scenariosFor(d).first;
    _resetConversation();
    notifyListeners();
    _autoPlayIfSystemTurn();
  }

  void setScenario(ConversationScenario s) {
    scenario = s;
    _resetConversation();
    notifyListeners();
    _autoPlayIfSystemTurn();
  }

  void _resetConversation() {
    turnIndex = 0;
    history.clear();
    partialText = '';
    finalText = '';
    recordState = RecordState.idle;
    _resetFluency();
  }

  ConversationTurn? get currentTurn =>
      (turnIndex >= 0 && turnIndex < scenario.turns.length) ? scenario.turns[turnIndex] : null;

  bool get isUserTurn => currentTurn?.speaker == Speaker.user;
  bool get isSystemTurn => currentTurn?.speaker == Speaker.system;

  bool get isFinished => turnIndex >= scenario.turns.length;

  String get systemLine => isSystemTurn ? currentTurn!.text : '';
  String get expectedUserLine => isUserTurn ? currentTurn!.text : '';

  Future<void> replaySystemLine() async {
    if (!isSystemTurn) return;
    await tts.speak(systemLine);
  }

  /// Plays the "expected" user line via TTS so the user can hear
  /// how their upcoming line should sound before recording.
  Future<void> replayExpectedUserLine() async {
    if (!isUserTurn) return;
    await tts.speak(expectedUserLine);
  }

  Future<void> nextTurn() async {
    if (isFinished) return;
    final t = currentTurn!;
    history.add(ChatMessage(speaker: t.speaker, text: t.text));
    turnIndex += 1;
    recordState = RecordState.idle;
    partialText = '';
    finalText = '';
    _resetFluency();
    notifyListeners();
    await _autoPlayIfSystemTurn();
  }

  Future<void> _autoPlayIfSystemTurn() async {
    if (isSystemTurn) {
      await tts.speak(systemLine);
    }
  }

  Future<void> startRecording() async {
    if (!isUserTurn) {
      throw Exception('Not your turn yet. Listen to the partner first.');
    }

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw Exception('Microphone permission required');
    }

    final ok = await stt.requestAndCheck();
    if (!ok) {
      throw Exception('Speech-to-text not available on this device');
    }

    partialText = '';
    finalText = '';
    recordState = RecordState.listening;
    _resetFluency();
    notifyListeners();

    _sub?.cancel();
    _sub = stt.listen().listen((r) {
      _updateFluency(r);
      partialText = r.recognizedWords;
      if (r.isFinal) {
        finalText = r.recognizedWords;
        recordState = RecordState.processing;
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> stopRecording() async {
    await stt.stop();
    await _sub?.cancel();
    _sub = null;

    if (recordState == RecordState.listening) {
      recordState = RecordState.processing;
      notifyListeners();
    }
  }

  ScoreResult buildScoreForCurrentUserLine() {
    if (!isUserTurn) {
      throw Exception('No user line to score');
    }
    final recognized = finalText.isNotEmpty ? finalText : partialText;
    final fluency = FluencyMetrics(
      fillerCount: fillerCount,
      totalPauseSeconds: totalPauseSeconds,
      longestPauseSeconds: longestPauseSeconds,
    );

    return scoring.score(
      expectedText: expectedUserLine,
      recognizedText: recognized,
      fluency: fluency,
    );
  }

  Future<void> commitUserLineAndAdvance({required String recognizedText}) async {
    history.add(ChatMessage(speaker: Speaker.user, text: expectedUserLine));
    history.add(ChatMessage(speaker: Speaker.user, text: 'Heard: ${recognizedText.isEmpty ? '—' : recognizedText}'));

    turnIndex += 1;
    recordState = RecordState.idle;
    partialText = '';
    finalText = '';
    _resetFluency();
    notifyListeners();

    await _autoPlayIfSystemTurn();
  }

  void resetConversation() {
    _resetConversation();
    notifyListeners();
    _autoPlayIfSystemTurn();
  }

  void _resetFluency() {
    _lastResultAt = null;
    totalPauseSeconds = 0;
    longestPauseSeconds = 0;
    fillerCount = 0;
  }

  void _updateFluency(SttResult r) {
    final now = r.at;
    final last = _lastResultAt;
    _lastResultAt = now;

    if (last != null) {
      final gap = now.difference(last).inMilliseconds / 1000.0;
      if (gap > 0.7) {
        totalPauseSeconds += gap;
        if (gap > longestPauseSeconds) longestPauseSeconds = gap;
      }
    }

    final w = (r.recognizedWords).toLowerCase();
    for (final f in const ['um', 'uh', 'erm', 'ah']) {
      if (w.contains(' $f ') || w.endsWith(' $f') || w.startsWith('$f ')) {
        fillerCount += 1;
      }
    }
  }
}