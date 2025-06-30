import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/statistics.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  late Box<Statistics> _statisticsBox;

  /// Initialisation de Hive et ouverture de la boîte pour les statistiques
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(StatisticsAdapter().typeId)) {
      Hive.registerAdapter(StatisticsAdapter());
    }
    _statisticsBox = await Hive.openBox<Statistics>('statisticsBox');

  }





  /// Chargement des fichiers JSON pour les questions
  Future<Map<String, dynamic>> _loadQuestions(String fileName) async {
    final String jsonData =
    await rootBundle.loadString('assets/questions/$fileName');

    return jsonDecode(jsonData);
  }

  // ==================================================
  // 1. Statistiques globales
  // ==================================================
  Map<String, dynamic> calculateGlobalStatistics() {
    int totalQuestions = 0;
    int totalCorrect = 0;
    double totalResponseTime = 0.0;

    for (var stat in _statisticsBox.values) {
      totalQuestions += stat.totalQuestions;
      totalCorrect += stat.correctAnswers;
      totalResponseTime += stat.totalResponseTime;
    }

    double averageResponseTime =
    totalQuestions > 0 ? totalResponseTime / totalQuestions : 0.0;
    double globalAccuracy =
    totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    return {
      'averageResponseTime': averageResponseTime,
      'globalAccuracy': globalAccuracy,
      'totalQuestions': totalQuestions,
      'totalCorrectAnswers': totalCorrect,
    };
  }

  void printAllStatistics() {
    for (var stat in _statisticsBox.values) {

    }
  }




String _getDomainFromSubDomain(String subDomain) {
    // Exemple simple basé sur vos fichiers JSON
    print('Sous-domaine reçu : $subDomain'); // Ajoutez cette ligne pour debug

    if (["Circonstances aggravantes",
    "Classification des infractions",
    "Classification des peines", 
    "La complicité",
    "Concours d'infraction",
    "Généralités",
    "Les infractions",
    "L'irresponsabilité pénale",
    "Les peines",
    "La récidive",
    "La responsabilité pénale",
    "La tentative"
    ].contains(subDomain)) {
      return 'Droit Pénal Général';


    } else if (["Le vol",
     "L'usurpation de fonctions",
     "Le recel",
     "L'organisation d'insolvabilité",
     "L'extorsion, le chantage",
     "L'escroquerie",
     "Les dégradations ,destructions",
     "L'abus de faiblesse",
     "L'abus de confiance",
     "Les atteintes volontaires à la vie",
     "Homicide involontaire",
     "Atteintes involontaires à l'intégrité de la personne",
     "Risques causés à autrui",
     "Tortures_et_actes_de_barbarie",
     "Violences",
     "Enlèvement et séquestration",
     "Rébellion",
     "Agressions sexuelles",
     "Atteintes au respect dû aux morts",
     "Délaissement de mineurs de 15 ans",
     "Abandon de famille",
     "Atteintes à l'exercice de l'autorité parentale",
     "Atteintes à la filiation",
     "Délaissement de personnes hors d'état de se protéger",
     "Stupefiants",
     "Proxénétisme",
     "Association de malfaiteurs",
     "Traite des êtres humains et dissimulation du visage",
     "Exploitation de la personne",
     "Infractions au régime des armes, poudres et explosifs",
     "Menaces",
     "Menaces et actes d'intimidation commis contre les personnes exerçant une fonction publique",
     "Harcèlement moral",
     "Discriminations",
     "Provocation au suicide",
     "Entraves à la saisine de la justice",
     "Entraves à l'exercice de la justice",
     "Entrave aux mesures d'assistance et omission de porter secours",
     "Évasion",
     "Participation délictueuse à un attroupement",
     "Manifestations illicites et participation délictueuse à une manifestation ou à une réunion publique",
     "Atteintes à la liberté individuelle",
     "Dénonciation calomnieuse",
     "Infractions commises par voie de presse ou par tout autre moyen de publication portant atteinte à l'honneur ou à la considération de la personne",
     "Manquements au devoir de probité",
     "Autres manquements au devoir de probité",
     "Atteinte au secret",
     "Atteintes à l'honneur ou au respect",
     "Atteinte à la vie privée",
     "Atteintes au secret des correspondances commises par des personnes exerçant une fonction publique",
     "Atteintes à l'inviolabilité du domicile",
     "Atteinte à la représentation de la personne",
     "Atteintes à la confiance publique - Faux",
     "Atteintes à la confiance publique",
     "Infractions délictuelles à la circulation routière"
     ].contains(subDomain)) {
      return 'Droit Pénal Spécial';

    } else if (["Les APJA, APJ, OPJ",
    "Les auditions, les confrontations",
    "Les cadres d'enquête",
    "Les constatations, les réquisitions",
    "Les contrôles d’identité",
    "La garde à vue",
    "Les mandats",
    "Les perquisitions, les saisie",
    "La police judiciaire",
    "L'action publique",
    "La faute civile et la faute pénale",
    "L'action civile",
    "Les preuves en matière pénale",
    "Le ministère public",
    "Les juridictions d'instruction"
    ].contains(subDomain)) {
      return 'Procédure Pénale';
    }
    return 'Inconnu';
  }






  Future<void> printJsonKeys() async {
    final files = ['dpg_questions.json', 'dps_questions.json', 'pp_questions.json'];

    for (String file in files) {
      final data = await _loadQuestions(file);
      print('Keys for $file: ${data.keys}');

    }

  }

  Future<void> addStatistics() async {
    final statsBox = Hive.box<Statistics>('statisticsBox');

    // Ajout d'une nouvelle entrée
    final newStat = Statistics(
      quizId: 'quiz_1',
      correctAnswers: 5,
      totalQuestions: 10,
      totalResponseTime: 120.0,
      domain: 'Droit',
      subDomain: 'Circonstances aggravantes',
      isCorrect: true,
      isChallenge: false,
      isWin: true,
      date: DateTime.now(),
      sessions: [
        {'accuracy': 50.0, 'date': DateTime.now().toIso8601String()}
      ],
    );

    await statsBox.put(newStat.quizId, newStat);
    print('Statistique ajoutée : $newStat');
  }

  // ==================================================
  Future<Map<String, dynamic>> calculateDomainStatistics() async {
    Map<String, dynamic> domainStats = {};
    final files = ['dpg_questions.json', 'dps_questions.json', 'pp_questions.json'];

    for (String file in files) {
      final data = await _loadQuestions(file);
      int domainTotalQuestions = 0;
      int domainCorrectAnswers = 0;
      Map<String, dynamic> subDomainStats = {};

      data.forEach((subDomain, questions) {
        int subDomainTotalQuestions = (questions as List).length;
        int subDomainCorrectAnswers = _statisticsBox.values
            .where((stat) =>
        stat.domain == file &&
            stat.subDomain == subDomain &&
            stat.isCorrect)
            .length;

        if (subDomainTotalQuestions > 0) {
          subDomainStats[subDomain] = {
            'totalQuestions': subDomainTotalQuestions,
            'correctAnswers': subDomainCorrectAnswers,
            'accuracy': (subDomainCorrectAnswers / subDomainTotalQuestions) * 100,
          };
        }

        domainTotalQuestions += subDomainTotalQuestions;
        domainCorrectAnswers += subDomainCorrectAnswers;
      });

      if (domainTotalQuestions > 0) {
        domainStats[file] = {
          'totalQuestions': domainTotalQuestions,
          'correctAnswers': domainCorrectAnswers,
          'accuracy': (domainCorrectAnswers / domainTotalQuestions) * 100,
          'subDomains': subDomainStats,
        };
      }
    }

    return domainStats;
  }
  // ==================================================
  // 3. Progression moyenne par session
  // ==================================================

  // ==================================================
  // 4. Points forts/faibles de l'utilisateur
  // ==================================================
  Future<Map<String, dynamic>> analyzeUserStrengthsWeaknesses() async {
    final domainStats = await calculateDomainStatistics();
    Map<String, dynamic> strengths = {};
    Map<String, dynamic> weaknesses = {};

    domainStats.forEach((domain, stats) {
      stats['subDomains'].forEach((subDomain, data) {
        if (data['accuracy'] > 75) {
          strengths[subDomain] = data['accuracy'];
        } else if (data['accuracy'] < 50) {
          weaknesses[subDomain] = data['accuracy'];
        }
      });
    });

    return {'strengths': strengths, 'weaknesses': weaknesses};
  }

Future<void> resetStatistics() async {
  try {
    await _statisticsBox.clear(); // Supprime toutes les statistiques
    print('Toutes les statistiques ont été réinitialisées.');
  } catch (e) {
    print('Erreur lors de la réinitialisation des statistiques : $e');
  }
}


  // ==================================================
  // 5. Statistiques pour les challenges
  // ==================================================
  Map<String, dynamic> calculateChallengeStatistics() {
    int totalChallenges = 0;
    int totalChallengeWins = 0;
    double totalChallengeTime = 0.0;

    for (var stat in _statisticsBox.values) {
      if (stat.isChallenge) {
        totalChallenges++;
        if (stat.isWin) totalChallengeWins++;
        totalChallengeTime += stat.totalResponseTime;
      }
    }

    return {
      'totalChallenges': totalChallenges,
      'challengeWins': totalChallengeWins,
      'challengeWinRate': totalChallenges > 0
          ? (totalChallengeWins / totalChallenges) * 100
          : 0.0,
      'averageChallengeTime': totalChallenges > 0
          ? totalChallengeTime / totalChallenges
          : 0.0,
    };
  }

  // ==================================================
  // 6. Progression quotidienne
  // ==================================================

  // ==================================================
  // 7. Toutes les statistiques
  // ==================================================
  Future<Map<String, dynamic>> getAllStatistics() async {
    final box = Hive.box<Statistics>('statisticsBox');
    final stats = box.values.toList();

    // Récupère tous les sous-domaines valides des fichiers JSON
    final files = ['dpg_questions.json', 'dps_questions.json', 'pp_questions.json'];
    Set<String> validSubDomains = {};

    for (String file in files) {
      final data = await _loadQuestions(file);
      validSubDomains.addAll(data.keys);
    }

    Map<String, dynamic> domainStats = {};
    int totalQuestions = 0;
    int correctAnswers = 0;
    double totalResponseTime = 0.0;

    for (var stat in stats) {
      if (!validSubDomains.contains(stat.subDomain)) {
        print('Statistiques enregistrées : Domain=${stat.domain}, SubDomain=${stat.subDomain}');

      }

      totalQuestions += stat.totalQuestions;
      correctAnswers += stat.correctAnswers;
      totalResponseTime += stat.totalResponseTime;

      if (!domainStats.containsKey(stat.domain)) {
        domainStats[stat.domain] = {
          'totalQuestions': 0,
          'correctAnswers': 0,
          'accuracy': 0.0,
          'subDomains': <String, dynamic>{},
        };
      }

      domainStats[stat.domain]['totalQuestions'] += stat.totalQuestions;
      domainStats[stat.domain]['correctAnswers'] += stat.correctAnswers;

      domainStats[stat.domain]['accuracy'] =
      domainStats[stat.domain]['totalQuestions'] > 0
          ? (domainStats[stat.domain]['correctAnswers'] /
          domainStats[stat.domain]['totalQuestions']) *
          100
          : 0.0;

      final subDomains =
      domainStats[stat.domain]['subDomains'] as Map<String, dynamic>;

      if (!subDomains.containsKey(stat.subDomain)) {
        subDomains[stat.subDomain] = {
          'totalQuestions': 0,
          'correctAnswers': 0,
          'accuracy': 0.0,
        };
      }

      subDomains[stat.subDomain]['totalQuestions'] += stat.totalQuestions;
      subDomains[stat.subDomain]['correctAnswers'] += stat.correctAnswers;
      subDomains[stat.subDomain]['accuracy'] =
      subDomains[stat.subDomain]['totalQuestions'] > 0
          ? (subDomains[stat.subDomain]['correctAnswers'] /
          subDomains[stat.subDomain]['totalQuestions']) *
          100
          : 0.0;
    }

    double averageResponseTime =
    totalQuestions > 0 ? totalResponseTime / totalQuestions : 0.0;
    double globalAccuracy =
    totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

    return {
      'globalStats': {
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'averageResponseTime': averageResponseTime,
        'globalAccuracy': globalAccuracy,
      },
      'domainStats': domainStats,
    };
  }


  Future<void> validateStatistics() async {
    final files = ['dpg_questions.json', 'dps_questions.json', 'pp_questions.json'];
    Set<String> validSubDomains = {};

    // Collecte des sous-domaines valides depuis les fichiers JSON
    for (String file in files) {
      final data = await _loadQuestions(file);
      validSubDomains.addAll(data.keys);
    }

    // Validation des sous-domaines dans Hive
    for (var stat in _statisticsBox.values) {
      if (!validSubDomains.contains(stat.subDomain)) {
        print('Sous-domaine non valide trouvé : ${stat.subDomain}');
      }
    }

    print('Validation des sous-domaines terminée.');
  }
}