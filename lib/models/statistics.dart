import 'package:hive/hive.dart';

part 'statistics.g.dart';

@HiveType(typeId: 0)
class Statistics {
  @HiveField(0)
  final String quizId;

  @HiveField(1)
  final int correctAnswers;

  @HiveField(2)
  final int totalQuestions;

  @HiveField(3)
  final double totalResponseTime;

  @HiveField(4)
  final String domain;

  @HiveField(5)
  final String subDomain;

  @HiveField(6)
  final bool isCorrect;

  @HiveField(7)
  final bool isChallenge;

  @HiveField(8)
  final bool isWin;

  @HiveField(9)
  final DateTime date;

  @HiveField(10)
  final List<Map<String, dynamic>> sessions;

  @HiveField(11) // Ajout du nouveau champ
  final String? challengeType; // Optionnel, null si non défini

  Statistics({
    required this.quizId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.totalResponseTime,
    required this.domain,
    required this.subDomain,
    required this.isCorrect,
    required this.isChallenge,
    required this.isWin,
    required this.date,
    this.sessions = const [],
    this.challengeType, // Nouveau champ ajouté
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      quizId: json['quizId'],
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      totalResponseTime: json['totalResponseTime'],
      domain: json['domain'],
      subDomain: json['subDomain'],
      isCorrect: json['isCorrect'],
      isChallenge: json['isChallenge'],
      isWin: json['isWin'],
      date: DateTime.parse(json['date']),
      sessions: List<Map<String, dynamic>>.from(json['sessions'] ?? []),
      challengeType: json['challengeType'], // Champ facultatif
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'totalResponseTime': totalResponseTime,
      'domain': domain,
      'subDomain': subDomain,
      'isCorrect': isCorrect,
      'isChallenge': isChallenge,
      'isWin': isWin,
      'date': date.toIso8601String(),
      'sessions': sessions,
      'challengeType': challengeType, // Ajouté au JSON
    };
  }
}