import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_level_service.dart';
import '../models/calibration_data.dart';

enum CalibrationStep { idle, ambient, voice, done }

class CalibrationController extends ChangeNotifier {
  final StorageService storage;
  final AudioLevelService audio;

  CalibrationData? _data;
  CalibrationStep step = CalibrationStep.idle;

  bool sampling = false;
  double latestDb = 0;

  CalibrationController({required this.storage, required this.audio});

  bool get hasCalibration => _data != null;
  CalibrationData? get data => _data;

  String get updatedAtLabel {
    final d = _data;
    if (d == null) return '—';
    return DateFormat('MMM d, yyyy • h:mm a').format(DateTime.fromMillisecondsSinceEpoch(d.updatedAtMs));
  }

  Future<void> load() async {
    _data = storage.loadCalibration();
    notifyListeners();
  }

  Future<void> startCalibration() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw Exception('Microphone permission required');
    }
    step = CalibrationStep.ambient;
    notifyListeners();
  }

  Future<void> sampleAmbient({Duration duration = const Duration(seconds: 4)}) async {
    step = CalibrationStep.ambient;
    await _sample(duration: duration, onComplete: (mean, std) async {
      final old = _data;
      _data = CalibrationData(
        ambientDbMean: mean,
        ambientDbStd: std,
        voiceDbMean: old?.voiceDbMean ?? 0,
        voiceDbStd: old?.voiceDbStd ?? 0,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      step = CalibrationStep.voice;
      await storage.saveCalibration(_data!);
    });
  }

  Future<void> sampleVoice({Duration duration = const Duration(seconds: 4)}) async {
    step = CalibrationStep.voice;
    await _sample(duration: duration, onComplete: (mean, std) async {
      final old = _data;
      _data = CalibrationData(
        ambientDbMean: old?.ambientDbMean ?? 0,
        ambientDbStd: old?.ambientDbStd ?? 0,
        voiceDbMean: mean,
        voiceDbStd: std,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      step = CalibrationStep.done;
      await storage.saveCalibration(_data!);
    });
  }

  Future<void> _sample({
    required Duration duration,
    required Future<void> Function(double mean, double std) onComplete,
  }) async {
    if (sampling) return;
    sampling = true;
    notifyListeners();

    await audio.start();

    final values = <double>[];
    final sub = audio.stream.listen((r) {
      latestDb = r.meanDb.isFinite ? r.meanDb : 0;
      if (latestDb > -200 && latestDb < 200) {
        values.add(latestDb);
      }
      notifyListeners();
    });

    await Future.delayed(duration);

    await sub.cancel();
    await audio.stop();

    final stats = _meanStd(values);
    await onComplete(stats.$1, stats.$2);

    sampling = false;
    notifyListeners();
  }

  (double, double) _meanStd(List<double> v) {
    if (v.isEmpty) return (0, 0);
    final mean = v.reduce((a, b) => a + b) / v.length;
    final variance = v.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / v.length;
    return (mean, sqrt(variance));
  }
}
