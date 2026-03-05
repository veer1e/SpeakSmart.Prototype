import 'dart:async';

import 'package:noise_meter/noise_meter.dart';

class AudioLevelReading {
  final double meanDb;
  final double maxDb;
  final DateTime at;

  AudioLevelReading({required this.meanDb, required this.maxDb, required this.at});
}

class AudioLevelService {
  NoiseMeter? _meter;
  StreamSubscription<NoiseReading>? _sub;
  final _controller = StreamController<AudioLevelReading>.broadcast();

  bool get isSupported => true;

  Stream<AudioLevelReading> get stream => _controller.stream;

  Future<void> init() async {
    _meter = NoiseMeter();
  }

  Future<void> start() async {
    final meter = _meter;
    if (meter == null) return;

    await stop();
    _sub = meter.noise.listen(
      (r) => _controller.add(
        AudioLevelReading(
          meanDb: r.meanDecibel,
          maxDb: r.maxDecibel,
          at: DateTime.now(),
        ),
      ),
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
