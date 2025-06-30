class SprintStatistics {
  final int totalPoints;
  final int bestScore;
  final double avgCorrectPerChallenge;
  final double avgPointsPerChallenge;
  final double avgSkippedPerChallenge;
  final double avgPointsLostPerChallenge;
  final double successRate;

  SprintStatistics({
    required this.totalPoints,
    required this.bestScore,
    required this.avgCorrectPerChallenge,
    required this.avgPointsPerChallenge,
    required this.avgSkippedPerChallenge,
    required this.avgPointsLostPerChallenge,
    required this.successRate,
  });

  /// Factory pour créer une instance depuis une Map (Firestore)
  factory SprintStatistics.fromMap(Map<String, dynamic> data) {
    return SprintStatistics(
      totalPoints: data['total_points'] ?? 0,
      bestScore: data['best_score'] ?? 0,
      avgCorrectPerChallenge: (data['avg_correct_per_challenge'] ?? 0).toDouble(),
      avgPointsPerChallenge: (data['avg_points_per_challenge'] ?? 0).toDouble(),
      avgSkippedPerChallenge: (data['avg_skipped_per_challenge'] ?? 0).toDouble(),
      avgPointsLostPerChallenge: (data['avg_points_lost_per_challenge'] ?? 0).toDouble(),
      successRate: (data['success_rate'] ?? 0).toDouble(),
    );
  }

  /// Convertit une instance en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'total_points': totalPoints,
      'best_score': bestScore,
      'avg_correct_per_challenge': avgCorrectPerChallenge,
      'avg_points_per_challenge': avgPointsPerChallenge,
      'avg_skipped_per_challenge': avgSkippedPerChallenge,
      'avg_points_lost_per_challenge': avgPointsLostPerChallenge,
      'success_rate': successRate,
    };
  }

  /// Crée une copie modifiée de l'objet
  SprintStatistics copyWith({
    int? totalPoints,
    int? bestScore,
    double? avgCorrectPerChallenge,
    double? avgPointsPerChallenge,
    double? avgSkippedPerChallenge,
    double? avgPointsLostPerChallenge,
    double? successRate,
  }) {
    return SprintStatistics(
      totalPoints: totalPoints ?? this.totalPoints,
      bestScore: bestScore ?? this.bestScore,
      avgCorrectPerChallenge: avgCorrectPerChallenge ?? this.avgCorrectPerChallenge,
      avgPointsPerChallenge: avgPointsPerChallenge ?? this.avgPointsPerChallenge,
      avgSkippedPerChallenge: avgSkippedPerChallenge ?? this.avgSkippedPerChallenge,
      avgPointsLostPerChallenge: avgPointsLostPerChallenge ?? this.avgPointsLostPerChallenge,
      successRate: successRate ?? this.successRate,
    );
  }

  /// Affiche les statistiques (utile pour les logs et le débogage)
  @override
  String toString() {
    return '''
SprintStatistics(
  totalPoints: $totalPoints,
  bestScore: $bestScore,
  avgCorrectPerChallenge: $avgCorrectPerChallenge,
  avgPointsPerChallenge: $avgPointsPerChallenge,
  avgSkippedPerChallenge: $avgSkippedPerChallenge,
  avgPointsLostPerChallenge: $avgPointsLostPerChallenge,
  successRate: $successRate,
)
''';
  }
}