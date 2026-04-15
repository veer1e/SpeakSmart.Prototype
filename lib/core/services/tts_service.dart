import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'storage_service.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  final StorageService? _storage;

  double _rate = 0.5;
  double _pitch = 1.0;

  double get rate => _rate;
  double get pitch => _pitch;

  TtsService({StorageService? storage}) : _storage = storage;

  Future<void> init() async {
    if (_storage != null) {
      _rate = _storage.getTtsRate(fallback: _rate);
      _pitch = _storage.getTtsPitch(fallback: _pitch);
    }

    // On Android the TTS engine must be told to block until speech
    // finishes, otherwise speak() returns immediately and the next
    // stop() / speak() call can race with the audio output.
    // This is particularly noticeable on emulators running API 33+.
    await _tts.awaitSpeakCompletion(true);

    // Ensure the default Android TTS engine is initialised before we
    // set language / rate so that the settings actually take effect.
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(1.0);

    _tts.setErrorHandler((msg) {
      debugPrint('[TTS] error: $msg');
    });

    debugPrint('[TTS] init complete (rate=$_rate pitch=$_pitch)');
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> setRate(double value) async {
    _rate = value;
    await _tts.setSpeechRate(_rate);
    if (_storage != null) {
      await _storage.setTtsRate(_rate);
    }
  }

  Future<void> setPitch(double value) async {
    _pitch = value;
    await _tts.setPitch(_pitch);
    if (_storage != null) {
      await _storage.setTtsPitch(_pitch);
    }
  }
}
