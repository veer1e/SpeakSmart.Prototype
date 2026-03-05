import 'dart:async';

class AudioLevelReading {
  final double meanDb;
  final double maxDb;
  final DateTime at;

  AudioLevelReading({required this.meanDb, required this.maxDb, required this.at});
}

class AudioLevelService {
  final _controller = StreamController<AudioLevelReading>.broadcast();
  Timer? _timer;

  bool get isSupported => false;

  Stream<AudioLevelReading> get stream => _controller.stream;

  Future<void> init() async {}

  Future<void> start() async {
    await stop();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _controller.add(AudioLevelReading(meanDb: 0, maxDb: 0, at: DateTime.now()));
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
