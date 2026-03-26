class CalibrationData {
  final double ambientDbMean;
  final double ambientDbStd;
  final double voiceDbMean;
  final double voiceDbStd;
  final int updatedAtMs;

  const CalibrationData({
    required this.ambientDbMean,
    required this.ambientDbStd,
    required this.voiceDbMean,
    required this.voiceDbStd,
    required this.updatedAtMs,
  });

  double get noiseOkThresholdDb => ambientDbMean + (ambientDbStd * 1.5) + 3.0;

  double get voiceDetectThresholdDb {

    final floor = ambientDbMean + (ambientDbStd * 1.0) + 6.0;
    final ceiling = voiceDbMean - (voiceDbStd * 0.5);
    if (ceiling.isNaN) return floor;
    return (floor > ceiling) ? floor : (floor + ceiling) / 2.0;
  }
}
