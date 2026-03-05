import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/audio_level_service.dart';
import '../../../core/services/storage_service.dart';
import '../../calibration/models/calibration_data.dart';
import '../../../core/utils/num.dart';

enum EnvironmentState { unknown, ok, noisy }

class EnvironmentController extends ChangeNotifier {
  final StorageService storage;
  final AudioLevelService audio;

  StreamSubscription? _sub;

  EnvironmentState state = EnvironmentState.unknown;
  double latestMeanDb = 0;

  // Simple local progress tracking
  int streakDays = 1;
  int practicesToday = 0;
  int totalPractices = 0;
  double averageScore = 0;

  EnvironmentController({required this.storage, required this.audio});

  CalibrationData? get calibration => storage.loadCalibration();

  Future<void> start() async {
    await audio.start();
    _sub?.cancel();
    _sub = audio.stream.listen((r) {
      latestMeanDb = r.meanDb;
      _updateState();
      notifyListeners();
    });
  }

  void _updateState() {
    final c = calibration;
    if (c == null) {
      state = EnvironmentState.unknown;
      return;
    }
    state = latestMeanDb <= c.noiseOkThresholdDb ? EnvironmentState.ok : EnvironmentState.noisy;
  }

  void recordPractice(int score) {
    practicesToday += 1;
    totalPractices += 1;
    averageScore = clampDouble(((averageScore * (totalPractices - 1)) + score) / totalPractices, 0, 100);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
