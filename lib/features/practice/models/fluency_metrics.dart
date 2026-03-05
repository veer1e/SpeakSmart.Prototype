class FluencyMetrics {
  final int fillerCount;
  final double totalPauseSeconds;
  final double longestPauseSeconds;

  const FluencyMetrics({
    required this.fillerCount,
    required this.totalPauseSeconds,
    required this.longestPauseSeconds,
  });
}
