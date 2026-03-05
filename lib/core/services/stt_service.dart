import 'dart:async';

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
      onStatus: (_) {},
      onError: (_) {},
    );
  }

  bool get isAvailable => _available;

  Future<bool> requestAndCheck() async {
    if (!_available) {
      _available = await _stt.initialize(onStatus: (_) {}, onError: (_) {});
    }
    return _available;
  }

  Stream<SttResult> listen({String localeId = 'en_US'}) async* {
    final controller = StreamController<SttResult>();

    await _stt.listen(
      localeId: localeId,
      listenMode: ListenMode.confirmation,
      onResult: (r) {
        controller.add(
          SttResult(
            recognizedWords: r.recognizedWords,
            isFinal: r.finalResult,
            at: DateTime.now(),
          ),
        );
        if (r.finalResult) {
          controller.close();
        }
      },
    );

    yield* controller.stream;
  }

  Future<void> stop() async {
    await _stt.stop();
  }

  Future<void> cancel() async {
    await _stt.cancel();
  }
}
