class SurvivalStatistics {
  final int totalPoints;
  final int bestScore;
  final double avgCorrectPerChallenge;
  final double avgScorePerChallenge;
  final double avgTotalTimePerChallenge;
  final double successRate;

  SurvivalStatistics({
    required this.totalPoints,
    required this.bestScore,
    required this.avgCorrectPerChallenge,
    required this.avgScorePerChallenge,
    required this.avgTotalTimePerChallenge,
    required this.successRate,
  });

  /// Factory pour créer une instance depuis une Map (Firestore)
  factory SurvivalStatistics.fromMap(Map<String, dynamic> data) {
    return SurvivalStatistics(
      totalPoints: data['total_points'] ?? 0,
      bestScore: data['best_score'] ?? 0,
      avgCorrectPerChallenge: (data['avg_correct_per_challenge'] ?? 0).toDouble(),
      avgScorePerChallenge: (data['avg_score_per_challenge'] ?? 0).toDouble(),
      avgTotalTimePerChallenge: (data['avg_total_time_per_challenge'] ?? 0).toDouble(),
      successRate: (data['success_rate'] ?? 0).toDouble(),
    );
  }

  /// Convertit une instance en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'total_points': totalPoints,
      'best_score': bestScore,
      'avg_correct_per_challenge': avgCorrectPerChallenge,
      'avg_score_per_challenge': avgScorePerChallenge,
      'avg_total_time_per_challenge': avgTotalTimePerChallenge,
      'success_rate': successRate,
    };
  }

  /// Crée une copie modifiée de l'objet
  SurvivalStatistics copyWith({
    int? totalPoints,
    int? bestScore,
    double? avgCorrectPerChallenge,
    double? avgScorePerChallenge,
    double? avgTotalTimePerChallenge,
    double? successRate,
  }) {
    return SurvivalStatistics(
      totalPoints: totalPoints ?? this.totalPoints,
      bestScore: bestScore ?? this.bestScore,
      avgCorrectPerChallenge: avgCorrectPerChallenge ?? this.avgCorrectPerChallenge,
      avgScorePerChallenge: avgScorePerChallenge ?? this.avgScorePerChallenge,
      avgTotalTimePerChallenge: avgTotalTimePerChallenge ?? this.avgTotalTimePerChallenge,
      successRate: successRate ?? this.successRate,
    );
  }

  /// Affiche les statistiques (utile pour les logs et le débogage)
  @override
  String toString() {
    return '''
SurvivalStatistics(
  totalPoints: $totalPoints,
  bestScore: $bestScore,
  avgCorrectPerChallenge: $avgCorrectPerChallenge,
  avgScorePerChallenge: $avgScorePerChallenge,
  avgTotalTimePerChallenge: $avgTotalTimePerChallenge,
  successRate: $successRate,
)
''';
  }
}