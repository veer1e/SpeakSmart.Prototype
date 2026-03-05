import 'package:shared_preferences/shared_preferences.dart';

import '../../features/calibration/models/calibration_data.dart';

class StorageService {
  SharedPreferences? _prefs;

  // Keys
  static const _kTtsRate = 'tts_rate';
  static const _kTtsPitch = 'tts_pitch';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw StateError('StorageService not initialized');
    }
    return p;
  }

  // ---------- Generic helpers ----------
  double? getDouble(String key) => prefs.getDouble(key);

  Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  // ---------- TTS settings ----------
  double getTtsRate({double fallback = 0.5}) {
    // FlutterTts rate is typically 0.0 - 1.0 (platform-dependent).
    return prefs.getDouble(_kTtsRate) ?? fallback;
  }

  double getTtsPitch({double fallback = 1.0}) {
    // FlutterTts pitch is typically ~0.5 - 2.0 (platform-dependent).
    return prefs.getDouble(_kTtsPitch) ?? fallback;
  }

  Future<void> setTtsRate(double value) => setDouble(_kTtsRate, value);

  Future<void> setTtsPitch(double value) => setDouble(_kTtsPitch, value);

  Future<void> saveCalibration(CalibrationData data) async {
    await prefs.setDouble('ambientDbMean', data.ambientDbMean);
    await prefs.setDouble('ambientDbStd', data.ambientDbStd);
    await prefs.setDouble('voiceDbMean', data.voiceDbMean);
    await prefs.setDouble('voiceDbStd', data.voiceDbStd);
    await prefs.setInt('calibrationUpdatedAtMs', data.updatedAtMs);
  }

  CalibrationData? loadCalibration() {
    final hasAmbient = prefs.containsKey('ambientDbMean') && prefs.containsKey('ambientDbStd');
    final hasVoice = prefs.containsKey('voiceDbMean') && prefs.containsKey('voiceDbStd');
    if (!hasAmbient || !hasVoice) return null;

    return CalibrationData(
      ambientDbMean: prefs.getDouble('ambientDbMean') ?? 0,
      ambientDbStd: prefs.getDouble('ambientDbStd') ?? 0,
      voiceDbMean: prefs.getDouble('voiceDbMean') ?? 0,
      voiceDbStd: prefs.getDouble('voiceDbStd') ?? 0,
      updatedAtMs: prefs.getInt('calibrationUpdatedAtMs') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
