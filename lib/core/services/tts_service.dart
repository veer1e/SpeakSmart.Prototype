import 'package:flutter_tts/flutter_tts.dart';

import 'storage_service.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  final StorageService? _storage;

  // Defaults chosen to be pleasant and safe; users can adjust in-app.
  double _rate = 0.5;
  double _pitch = 1.0;

  double get rate => _rate;
  double get pitch => _pitch;

  TtsService({StorageService? storage}) : _storage = storage;

  Future<void> init() async {
    // Load persisted settings (if storage is provided/initialized).
    if (_storage != null) {
      _rate = _storage!.getTtsRate(fallback: _rate);
      _pitch = _storage!.getTtsPitch(fallback: _pitch);
    }

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
  }

  Future<void> speak(String text) async {
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
      await _storage!.setTtsRate(_rate);
    }
  }

  Future<void> setPitch(double value) async {
    _pitch = value;
    await _tts.setPitch(_pitch);
    if (_storage != null) {
      await _storage!.setTtsPitch(_pitch);
    }
  }
}
