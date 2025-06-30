import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeStatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère l'ID utilisateur actuel
  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  /// 🏃 Mise à jour des statistiques pour Sprint
  Future<void> updateSprintStatistics({
    required int points,
    required int correctAnswers,
    required int skippedQuestions,
    required int lostPoints,
    required bool isWin,
    required int totalQuestionsPlayed, // Nombre réel de questions jouées
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Utilisateur non authentifié.");
    }

    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenge_stats')
        .doc('sprint');

    final doc = await ref.get();
    final data = doc.data() ?? {};

    final int totalChallenges = (data['total_challenges'] ?? 0) + 1;
    final int totalCorrectAnswers =
        (data['total_correct_answers'] ?? 0) + correctAnswers;
    final int totalSkippedQuestions =
        (data['total_skipped_questions'] ?? 0) + skippedQuestions;
    final int totalLostPoints =
        (data['total_lost_points'] ?? 0) + lostPoints;
    final int totalPoints = (data['total_points'] ?? 0) + points;
    final int totalQuestionsPlayedOverall =
        (data['total_questions_played'] ?? 0) + totalQuestionsPlayed;

    final int bestScore =
    points > (data['best_score'] ?? 0) ? points : (data['best_score'] ?? 0);

    // 🧠 Calcul des moyennes arrondies à 1 décimale
    final double avgCorrectPerChallenge =
    double.parse((totalCorrectAnswers / totalChallenges).toStringAsFixed(1));
    final double avgPointsPerChallenge =
    double.parse((totalPoints / totalChallenges).toStringAsFixed(1));
    final double avgSkippedPerChallenge =
    double.parse((totalSkippedQuestions / totalChallenges).toStringAsFixed(1));
    final double avgPointsLostPerChallenge =
    double.parse((totalLostPoints / totalChallenges).toStringAsFixed(1));

    // ✅ Calcul du taux de réussite basé sur les questions réellement jouées
    final double successRate = totalQuestionsPlayedOverall > 0
        ? double.parse(
        ((totalCorrectAnswers / totalQuestionsPlayedOverall) * 100)
            .toStringAsFixed(1))
        : 0.0;

    await ref.set({
      'total_points': totalPoints,
      'best_score': bestScore,
      'avg_correct_per_challenge': avgCorrectPerChallenge,
      'avg_points_per_challenge': avgPointsPerChallenge,
      'avg_skipped_per_challenge': avgSkippedPerChallenge,
      'avg_points_lost_per_challenge': avgPointsLostPerChallenge,
      'success_rate': successRate,
      'total_challenges': totalChallenges,
      'total_correct_answers': totalCorrectAnswers,
      'total_skipped_questions': totalSkippedQuestions,
      'total_lost_points': totalLostPoints,
      'total_questions_played': totalQuestionsPlayedOverall,
    }, SetOptions(merge: true));
  }

  /// 🛡️ Mise à jour des statistiques pour Survival
  Future<void> updateSurvivalStatistics({
    required int points,
    required int correctAnswers,
    required double totalTime,
    required bool isWin,
    required int totalQuestionsPlayed, // Nombre réel de questions jouées
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Utilisateur non authentifié.");
    }

    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenge_stats')
        .doc('survival');

    final doc = await ref.get();
    final data = doc.data() ?? {};

    final int totalChallenges = (data['total_challenges'] ?? 0) + 1;
    final int totalCorrectAnswers =
        (data['total_correct_answers'] ?? 0) + correctAnswers;
    final double totalTimeSpent =
        (data['total_time_spent'] ?? 0) + totalTime;
    final int totalPoints = (data['total_points'] ?? 0) + points;
    final int totalQuestionsPlayedOverall =
        (data['total_questions_played'] ?? 0) + totalQuestionsPlayed;

    final int bestScore =
    points > (data['best_score'] ?? 0) ? points : (data['best_score'] ?? 0);

    // 🧠 Calcul des moyennes arrondies à 1 décimale
    final double avgCorrectPerChallenge =
    double.parse((totalCorrectAnswers / totalChallenges).toStringAsFixed(1));
    final double avgScorePerChallenge =
    double.parse((totalPoints / totalChallenges).toStringAsFixed(1));
    final double avgTotalTimePerChallenge =
    double.parse((totalTimeSpent / totalChallenges).toStringAsFixed(1));

    // ✅ Calcul du taux de réussite basé sur les questions réellement jouées
    final double successRate = totalQuestionsPlayedOverall > 0
        ? double.parse(
        ((totalCorrectAnswers / totalQuestionsPlayedOverall) * 100)
            .toStringAsFixed(1))
        : 0.0;

    await ref.set({
      'total_points': totalPoints,
      'best_score': bestScore,
      'avg_correct_per_challenge': avgCorrectPerChallenge,
      'avg_score_per_challenge': avgScorePerChallenge,
      'avg_total_time_per_challenge': avgTotalTimePerChallenge,
      'success_rate': successRate,
      'total_challenges': totalChallenges,
      'total_correct_answers': totalCorrectAnswers,
      'total_time_spent': totalTimeSpent,
      'total_questions_played': totalQuestionsPlayedOverall,
    }, SetOptions(merge: true));
  }
}