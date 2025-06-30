import 'package:flutter/material.dart';
import '../../services/quiz_service.dart';
import '../../models/question.dart';
import '../../models/statistics.dart';
import 'package:hive/hive.dart';
import '../home/home_screen.dart';
import '/services/statistics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/audio_service.dart';



class QuizScreen extends StatefulWidget {
  final List<String> selectedSubDomains;
  final int numberOfQuestions;
  final StatisticsService statisticsService;

  QuizScreen({
    required this.selectedSubDomains,
    required this.numberOfQuestions,
    required this.statisticsService,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();

}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  List<Map<String, dynamic>> _responses = [];
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    AudioService().stopBackgroundMusic();
    _loadQuestions();
  }

  Future<void> _saveStatistics() async {
    final box = Hive.box<Statistics>('statisticsBox');
    for (var response in _responses) {
      final statistic = Statistics(
        quizId: "quiz_${DateTime.now().millisecondsSinceEpoch}",
        correctAnswers: response['correct'] ? 1 : 0,
        totalQuestions: 1,
        totalResponseTime: response['timeTaken']?.toDouble() ?? 0.0,
        domain: response['domain'] ?? "Domaine Inconnu",
        subDomain: response['subDomain'] ?? "Sous-domaine Inconnu",
        isCorrect: response['correct'],
        isChallenge: false,
        isWin: response['correct'],
        date: DateTime.now(),
      );
      await box.add(statistic);
    }

  }

  Future<void> _loadQuestions() async {
    try {
      List<Question> questions = await _quizService.loadQuestions(
        selectedSubDomains: widget.selectedSubDomains,
        numberOfQuestions: widget.numberOfQuestions,
      );

      for (var question in questions) {
        question.domain = _getDomainFromSubDomain(
          question.subDomain ?? 'Sous-domaine inconnu',
        );
        question.subDomain ??= 'Sous-domaine inconnu';
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
        _startTime = DateTime.now();
      });

      for (var question in _questions) {
        print(
          'Question chargée : ${question.question}, Domaine : ${question.domain}, Sous-domaine : ${question.subDomain}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des questions : $e');
    }
  }

  void _checkAnswer(int selectedIndex) async {
    final DateTime now = DateTime.now();
    final int timeTaken = _startTime != null ? now.difference(_startTime!).inSeconds : 0;

    final currentQuestion = _questions[_currentQuestionIndex];

    setState(() {
      _showFeedback = true;
      _isCorrect = currentQuestion.correct == selectedIndex;

      _responses.add({
        'question': currentQuestion.question,
        'correct': _isCorrect,
        'timeTaken': timeTaken,
        'correctOptionIndex': currentQuestion.correct,
        'options': currentQuestion.options,
        'domain': currentQuestion.domain ?? 'Domaine inconnu',
        'subDomain': currentQuestion.subDomain ?? 'Sous-domaine inconnu',
      });
    });

    if (_currentQuestionIndex == _questions.length - 1) {
      await _saveStatistics();
      print('Réponse ajoutée : $_responses');
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _showFeedback = false;
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
          _startTime = DateTime.now();
        } else {
          _showSummary();
        }
      });
    });
  }

  String _getDomainFromSubDomain(String subDomain) {
    if ([
      "Circonstances aggravantes",
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
      "La tentative",
    ].contains(subDomain)) {
      return 'Droit Pénal Général';
    } else if ([
      "Le vol",
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
      "Infractions délictuelles à la circulation routière",
      // Ajoutez ici les autres sous-domaines...
    ].contains(subDomain)) {
      return 'Droit Pénal Spécial';
    } else if ([
      "Les APJA, APJ, OPJ",
      "Les auditions, les confrontations",
      "Les cadres d'enquête",
      "Les constatations, les réquisitions",
      "Les contrôles d'identité",
      "La garde à vue",
      "Les mandats",
      "Les perquisitions, les saisies",
      "La police judiciaire",
      "L'action publique",
      "La faute civile et la faute pénale",
      "L'action civile",
      "Les preuves en matière pénale",
      "Le ministère public",
      "Les juridictions d'instruction",
      // Ajoutez ici les autres sous-domaines...
    ].contains(subDomain)) {
      return 'Procédure Pénale';
    }
    return 'Domaine Inconnu';
  }

  void _showSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSummaryScreen(
          responses: _responses,
          statisticsService: widget.statisticsService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
            title: Text('Quiz')),
        body: Center(child:  Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blueGrey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 16.0),
    child: Column(
    children: [
    Image.asset(
    'assets/images/ours_paresseux.png',
    height: 400,
    fit: BoxFit.cover,
    ),
    SizedBox(height: 0),
    Text(
    "Aucune question chargée",
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 10),
    Text(
    "Selectionne tes sujets d'entrainement",
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Colors.white70,
    ),
    ),
    ],
    ),
    ),
    ),),
      );
    }

    Question currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey.shade300,
                color: Colors.indigo,
              ),
              SizedBox(height: 20),
              _buildQuestionCard(currentQuestion),
              SizedBox(height: 30),
              _buildOptionsList(currentQuestion),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            question.question,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(Question question) {
    return Expanded(
      child: ListView.builder(
        itemCount: question.options.length,
        itemBuilder: (context, index) {
          String option = question.options[index];
          return GestureDetector(
            onTap: _showFeedback ? null : () => _checkAnswer(index),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _showFeedback
                    ? (index == question.correct
                    ? Colors.green.shade100
                    : Colors.red.shade50)
                    : Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _showFeedback
                      ? (index == question.correct ? Colors.green : Colors.red)
                      : Colors.indigo,
                  width: 2,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizSummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> responses;
  final StatisticsService statisticsService;

  QuizSummaryScreen({
    required this.responses,
    required this.statisticsService,
  });

  @override
  Widget build(BuildContext context) {
    // Trier les réponses par mauvaises réponses en premier, puis par temps décroissant
    final sortedResponses = responses
      ..sort((a, b) {
        if (a['correct'] != b['correct']) {
          return a['correct'] ? 1 : -1;
        }
        return (b['timeTaken'] ?? 0).compareTo(a['timeTaken'] ?? 0);
      });

    int correctAnswers = responses.where((r) => r['correct'] == true).length;
    int totalQuestions = responses.length;
    double averageTime = responses.isNotEmpty
        ? responses.map((r) => r['timeTaken'] ?? 0).reduce((a, b) => a + b) /
        totalQuestions
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Résumé du Quiz"),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Résumé du Quiz",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Questions Correctes : $correctAnswers/$totalQuestions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Temps Moyen : ${averageTime.toStringAsFixed(2)} sec",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedResponses.length,
                  itemBuilder: (context, index) {
                    final response = sortedResponses[index];
                    bool isCorrect = response['correct'];
                    String correctAnswer = response['options'] != null &&
                        response['correctOptionIndex'] != null
                        ? response['options'][response['correctOptionIndex']]
                        : "Non spécifié";

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCorrect
                              ? [Colors.green[300]!, Colors.green[100]!]
                              : [Colors.red[300]!, Colors.red[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Title
                            Text(
                              response['question'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Correctness and Additional Info
                            Text(
                              "Réponse : ${isCorrect ? 'Correcte' : 'Incorrecte'}",
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            if (!isCorrect)
                              Text(
                                "Réponse correcte : $correctAnswer",
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            Text(
                              "Temps : ${response['timeTaken']} sec",
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            // Flag Button
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.flag, color: Colors.red),
                                onPressed: () {
                                  _reportQuestion(context, response['question']);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        statisticsService: statisticsService,
                      ),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Retour à l'accueil",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _reportQuestion(BuildContext context, String question) {
    print("Fonction _reportQuestion appelée"); // Ajoutez ceci
    final TextEditingController reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Signaler la question"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Expliquez pourquoi vous signalez cette question :"),
              TextField(
                controller: reportController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Détaillez le problème...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _sendReportToFirebase(question, reportController.text);
                Navigator.pop(context);
              },
              child: Text("Envoyer"),
            ),
          ],
        );
      },
    );
  }

  void _sendReportToFirebase(String question, String details) async {
    print("Fonction _sendReportToFirebase appelée"); // Ajoutez ceci
    print("Question : $question"); // Ajoutez ceci
    print("Détails : $details"); // Ajoutez ceci

    if (details.trim().isEmpty) {
      print("Détails du signalement vides."); // Ajoutez ceci
      return;
    }

    final report = {
      'question': question,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseFirestore.instance.collection('question_reports').add(report);
      print("Signalement envoyé avec succès."); // Ajoutez ceci
    } catch (e) {
      print("Erreur lors de l'envoi du signalement : $e"); // Ajoutez ceci
    }
  }
}