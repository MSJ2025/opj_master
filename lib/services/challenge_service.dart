import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'; // Pour rootBundle
import '../models/question.dart';
import '../widgets/domains_helper.dart'; // Chemin corrigé pour DomainHelper

class ChallengeService {
  final Random _random = Random();

  // Charge les questions de manière équilibrée entre les sous-domaines
  Future<List<Question>> loadBalancedQuestions(int numberOfQuestions) async {
    final List<Question> allQuestions = [];
    final Map<String, String> filePaths = {
      'DPG': 'assets/questions/dpg_questions.json',
      'DPS': 'assets/questions/dps_questions.json',
      'PP': 'assets/questions/pp_questions.json',
    };

    // Charge les questions de chaque domaine
    final Map<String, List<Question>> domainQuestions = {};
    for (var domain in filePaths.keys) {
      final String response = await rootBundle.loadString(filePaths[domain]!);
      final Map<String, dynamic> data = json.decode(response);
      domainQuestions[domain] = [];

      data.forEach((subDomain, questions) {
        domainQuestions[domain]!.addAll(
          (questions as List).map((item) {
            final question = Question.fromJson(item);
            // Ajouter le sous-domaine et le domaine à chaque question
            question.subDomain = subDomain;
            question.domain = DomainHelper.getDomainFromSubDomain(subDomain);
            return question;
          }).toList(),
        );
      });
    }

    // Équilibre les questions entre les domaines
    final int questionsPerDomain = numberOfQuestions ~/ filePaths.keys.length;
    domainQuestions.forEach((domain, questions) {
      questions.shuffle(_random);
      allQuestions.addAll(questions.take(questionsPerDomain));
    });

    // Mélange les questions et retourne le total requis
    allQuestions.shuffle(_random);
    return allQuestions.take(numberOfQuestions).toList();
  }
}