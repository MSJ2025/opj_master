import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

class QuizService {
  final Random _random = Random();

  /// Map des sous-domaines vers les domaines correspondants
  final Map<String, String> _domainMapping = {
    // Sous-domaines du Droit Pénal Général
    "Circonstances aggravantes": "Droit Pénal Général",
    "Classification des infractions": "Droit Pénal Général",
    "La tentative": "Droit Pénal Général",

    // Sous-domaines du Droit Pénal Spécial
    "Le vol": "Droit Pénal Spécial",
    "Le recel": "Droit Pénal Spécial",

    // Sous-domaines de la Procédure Pénale
    "Les APJA, APJ, OPJ": "Procédure Pénale",
    "Les contrôles d’identité": "Procédure Pénale",
    "La garde à vue": "Procédure Pénale",
  };

  /// Charge les questions pour des sous-domaines spécifiques
  Future<List<Question>> loadQuestions({
    required List<String> selectedSubDomains,
    int numberOfQuestions = 10,
  }) async {
    List<Question> allQuestions = [];
    final List<String> filePaths = [
      'assets/questions/dpg_questions.json',
      'assets/questions/dps_questions.json',
      'assets/questions/pp_questions.json',
    ];

    for (String filePath in filePaths) {
      try {
        String data = await rootBundle.loadString(filePath);
        Map<String, dynamic> jsonData = json.decode(data);

        if (jsonData == null || jsonData.isEmpty) {
          print("Le fichier JSON $filePath est vide ou mal formé.");
          continue;
        }

        for (String subDomain in selectedSubDomains) {
          if (jsonData.containsKey(subDomain)) {
            List<dynamic> questions = jsonData[subDomain];
            allQuestions.addAll(
              questions.map((item) {
                // Ajoutez le domaine et le sous-domaine avant de retourner l'objet Question
                final question = Question.fromJson(item);
                question.domain = _getDomainFromSubDomain(subDomain);
                question.subDomain = subDomain;
                return question;
              }).toList(),
            );

            // Debugging: Affiche les questions chargées
            for (var question in questions.map((item) => Question.fromJson(item))) {

            }
          }
        }
      } catch (e) {
        print("Erreur lors du chargement du fichier $filePath : $e");
      }
    }

    allQuestions.shuffle(_random);
    return allQuestions.take(numberOfQuestions).toList();
  }

  /// Récupère automatiquement tous les sous-domaines de tous les fichiers JSON
  Future<List<String>> getAllSubDomainsFromAllFiles() async {
    List<String> allSubDomains = [];
    final List<String> filePaths = [
      'assets/questions/dpg_questions.json',
      'assets/questions/dps_questions.json',
      'assets/questions/pp_questions.json',
    ];

    try {
      for (String filePath in filePaths) {
        String data = await rootBundle.loadString(filePath);
        Map<String, dynamic> jsonData = json.decode(data);

        if (jsonData != null && jsonData.isNotEmpty) {
          allSubDomains.addAll(jsonData.keys);
        } else {
          print("Le fichier JSON $filePath est vide ou mal formé.");
        }
      }
      allSubDomains = allSubDomains.toSet().toList(); // Supprime les doublons
    } catch (e) {
      print("Erreur lors de la récupération des sous-domaines : $e");
    }

    return allSubDomains;
  }

  /// Renvoie le domaine correspondant à un sous-domaine
  String _getDomainFromSubDomain(String subDomain) {
    return _domainMapping[subDomain] ?? "Domaine Inconnu";
  }

  /// Méthode de test pour afficher tous les sous-domaines
  void testGetAllSubDomains() async {
    List<String> subDomains = await getAllSubDomainsFromAllFiles();
    print('Sous-domaines disponibles : $subDomains');
  }
}