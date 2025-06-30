class Question {
  final String question;
  final List<String> options;
  final int correct;

  // Ces deux champs sont ajoutés mais ne sont pas obligatoires dans le JSON
  String? domain;
  String? subDomain;

  Question({
    required this.question,
    required this.options,
    required this.correct,
    this.domain,
    this.subDomain,
  });

  // Méthode pour créer un objet Question à partir de JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correct: json['correct'],
      // On laisse domain et subDomain comme null pour être calculés dynamiquement
    );
  }
}