import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttResult {
  final String recognizedWords;
  final bool isFinal;
  final DateTime at;

  SttResult({required this.recognizedWords, required this.isFinal, required this.at});
}

class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  Future<void> init() async {
    _available = await _stt.initialize(
      onStatus: (status) => debugPrint('[STT] status: $status'),
      onError: (error) => debugPrint('[STT] error: ${error.errorMsg} (permanent: ${error.permanent})'),
      debugLogging: false,
    );
    debugPrint('[STT] init available: $_available');
  }

  bool get isAvailable => _available;

  Future<bool> requestAndCheck() async {
    if (!_available) {
      _available = await _stt.initialize(
        onStatus: (status) => debugPrint('[STT] status: $status'),
        onError: (error) => debugPrint('[STT] error: ${error.errorMsg}'),
        debugLogging: false,
      );
    }
    debugPrint('[STT] requestAndCheck available: $_available');
    return _available;
  }

  /// Returns a stream of partial + final STT results.
  ///
  /// Key fixes for Android API 33+/36 emulator:
  /// - Uses [ListenMode.dictation] (confirmation mode hangs on newer Android).
  /// - The [StreamController] is created BEFORE [_stt.listen] is called so
  ///   the caller can subscribe immediately and miss no events.
  /// - The controller is a regular (non-broadcast) controller — one subscriber
  ///   only, matching how PracticeController uses it.
  /// - [Future.microtask] schedules the actual listen call so the stream is
  ///   returned synchronously, avoiding an async* / yield* race.
  Stream<SttResult> listen({String localeId = 'en_US'}) {
    final controller = StreamController<SttResult>();
    bool soundDetected = false;
    int resultCount = 0;

    void closeIfOpen() {
      if (!controller.isClosed) controller.close();
    }

    Future.microtask(() async {
      try {
        debugPrint('[STT] listen() starting with locale: $localeId');
        debugPrint('[STT] listenMode: search, listenFor: 45s, pauseFor: 5s');
        await _stt.listen(
          localeId: localeId,
          listenMode: ListenMode.search,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 5),
          cancelOnError: false,
          onResult: (r) {
            resultCount++;
            debugPrint('[STT] onResult #$resultCount: "${r.recognizedWords}" (final: ${r.finalResult})');
            if (controller.isClosed) {
              debugPrint('[STT] WARNING: Controller already closed, dropping result');
              return;
            }
            controller.add(SttResult(
              recognizedWords: r.recognizedWords,
              isFinal: r.finalResult,
              at: DateTime.now(),
            ));
            if (r.finalResult) {
              debugPrint('[STT] Final result received, closing stream');
              closeIfOpen();
            }
          },
          // Providing this callback keeps the mic stream alive on emulators
          // that otherwise stop after the first silence detection.
          onSoundLevelChange: (level) {
            if (level > 0.0) {
              soundDetected = true;
              debugPrint('[STT] Sound detected: level=$level');
            }
          },
        );
        debugPrint('[STT] listen() returned normally. Sound detected: $soundDetected, Results received: $resultCount');
      } catch (e) {
        debugPrint('[STT] listen() threw exception: $e');
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
      }
    });

    return controller.stream;
  }

  Future<void> stop() async {
    await _stt.stop();
  }

  Future<void> cancel() async {
    await _stt.cancel();
  }
}
