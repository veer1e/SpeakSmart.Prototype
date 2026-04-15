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

  int turnIndex = 0;
  RecordState recordState = RecordState.idle;

  final List<ChatMessage> history = [];

  String partialText = '';
  String finalText = '';

  DateTime? _lastResultAt;
  double totalPauseSeconds = 0;
  double longestPauseSeconds = 0;
  int fillerCount = 0;

  StreamSubscription<SttResult>? _sub;

  // Completer that resolves when we receive a final STT result (or the stream
  // closes without one). This lets stopRecording() wait for Android's async
  // final-result callback before the UI tries to score.
  Completer<void>? _finalResultCompleter;

  PracticeController({required this.storage, required this.stt, required this.tts}) {
    scenario = conversationScenarios.first;
    _resetConversation();
  }

  List<ConversationScenario> scenariosFor(Difficulty d) =>
      conversationScenarios.where((s) => s.difficulty == d).toList();

  void setDifficulty(Difficulty d) {
    difficulty = d;
    scenario = scenariosFor(d).first;
    _resetConversation();
    notifyListeners();
  }

  void setScenario(ConversationScenario s) {
    scenario = s;
    _resetConversation();
    notifyListeners();
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
  }

  Future<void> _autoPlayIfSystemTurn() async {
    if (isSystemTurn) {
      await tts.speak(systemLine);
    }
  }

  Future<void> startConversationAutoplayOnce() async {
    if (turnIndex == 0 && history.isEmpty && isSystemTurn) {
      await _autoPlayIfSystemTurn();
    }
  }

  Future<void> startRecording() async {
    if (!isUserTurn) {
      throw Exception('Not your turn yet. Listen to the partner first.');
    }

    debugPrint('[PracticeController] startRecording() called');
    
    final mic = await Permission.microphone.request();
    debugPrint('[PracticeController] Microphone permission: ${mic.name}');
    if (!mic.isGranted) {
      throw Exception('Microphone permission required');
    }

    final ok = await stt.requestAndCheck();
    debugPrint('[PracticeController] STT available: $ok');
    if (!ok) {
      throw Exception(
        'Speech-to-text not available on this device. '
        'On an Android emulator make sure a microphone is configured and '
        'the Google app is installed for on-device speech recognition.',
      );
    }

    // Cancel any in-flight session before starting a new one.
    await _cancelCurrentSession();

    partialText = '';
    finalText = '';
    recordState = RecordState.listening;
    _resetFluency();

    // Set up completer before subscribing so stopRecording() can await it.
    _finalResultCompleter = Completer<void>();

    notifyListeners();

    debugPrint('[PracticeController] Creating STT stream...');
    _sub = stt.listen().listen(
      (r) {
        debugPrint('[PracticeController] Got STT result: "${r.recognizedWords}" (final: ${r.isFinal})');
        _updateFluency(r);
        partialText = r.recognizedWords;
        if (r.isFinal) {
          finalText = r.recognizedWords;
          recordState = RecordState.processing;
          // Signal that we have a final result.
          if (_finalResultCompleter != null && !_finalResultCompleter!.isCompleted) {
            _finalResultCompleter!.complete();
          }
          notifyListeners();
        } else {
          notifyListeners();
        }
      },
      onError: (Object err) {
        debugPrint('[PracticeController] ❌ STT stream ERROR: $err');
        _completeIfPending();
        if (recordState == RecordState.listening) {
          recordState = RecordState.processing;
          notifyListeners();
        }
      },
      onDone: () {
        debugPrint('[PracticeController] ⏹️ STT stream DONE (closed)');
        // Stream closed (silence timeout, etc.) without a final result.
        _completeIfPending();
        if (recordState == RecordState.listening) {
          recordState = RecordState.processing;
          notifyListeners();
        }
      },
    );
    debugPrint('[PracticeController] STT stream subscription created');
  }

  void _completeIfPending() {
    if (_finalResultCompleter != null && !_finalResultCompleter!.isCompleted) {
      _finalResultCompleter!.complete();
    }
  }

  /// Stop recording and **wait** for Android to deliver the final STT result
  /// (or time out after 5 s if nothing arrives). This is the key fix for the
  /// "loads forever / no input received" bug: on Android, the recognizer
  /// delivers its final result *after* stop() returns, so we must wait.
  /// 
  /// IMPORTANT: This also cancels the subscription after the timeout to ensure
  /// we never get stuck in "processing" state, even if the stream doesn't close.
  Future<void> stopRecording() async {
    debugPrint('[PracticeController] stopRecording() called');
    
    try {
      await stt.stop();
      debugPrint('[PracticeController] ✅ stt.stop() completed');
    } catch (e) {
      debugPrint('[PracticeController] ⚠️ stt.stop() error: $e');
    }

    // Give Android up to 5 seconds to deliver the final result callback.
    if (_finalResultCompleter != null && !_finalResultCompleter!.isCompleted) {
      try {
        debugPrint('[PracticeController] ⏳ Waiting for final result (max 5s)...');
        await _finalResultCompleter!.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[PracticeController] ⏱️ Final-result timeout — using partial text');
            _completeIfPending();
            // Fall back to whatever partial text we have.
            if (partialText.isNotEmpty && finalText.isEmpty) {
              finalText = partialText;
              debugPrint('[PracticeController] 📝 Set finalText from partial: "$finalText"');
            }
          },
        );
        debugPrint('[PracticeController] ✅ Final result completed');
      } catch (e) {
        debugPrint('[PracticeController] ⚠️ Error waiting for final result: $e');
        _completeIfPending();
      }
    } else {
      debugPrint('[PracticeController] ℹ️ No final result completer or already completed');
    }

    // CRITICAL: Force cancel the subscription to prevent the stream from hanging.
    // This ensures we transition out of listening/processing state no matter what.
    if (_sub != null) {
      try {
        debugPrint('[PracticeController] 🛑 Cancelling STT subscription');
        await _sub!.cancel();
        debugPrint('[PracticeController] ✅ Subscription cancelled');
      } catch (e) {
        debugPrint('[PracticeController] ⚠️ Error cancelling subscription: $e');
      }
      _sub = null;
    }

    if (recordState == RecordState.listening) {
      debugPrint('[PracticeController] 🔄 Setting state to processing');
      recordState = RecordState.processing;
      notifyListeners();
    }
    
    debugPrint('[PracticeController] ✅ stopRecording() complete');
  }

  Future<void> _cancelCurrentSession() async {
    _completeIfPending();
    await _sub?.cancel();
    _sub = null;
    _finalResultCompleter = null;
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
  }

  void resetConversation() {
    _resetConversation();
    notifyListeners();
  }

  /// Reset recording state for retry - clears previous attempt data but keeps same line
  void resetForRetry() {
    debugPrint('[PracticeController] Resetting for retry - clearing previous recording data');
    partialText = '';
    finalText = '';
    recordState = RecordState.idle;
    _resetFluency();
    notifyListeners();
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
