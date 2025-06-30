import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/challenge_service.dart';
import '../../services/challenge_statistics_service.dart';

class ChallengeQuizScreen extends StatefulWidget {
  @override
  _ChallengeQuizScreenState createState() => _ChallengeQuizScreenState();
}

class _ChallengeQuizScreenState extends State<ChallengeQuizScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final ChallengeStatisticsService _statisticsService = ChallengeStatisticsService();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isQuizEnded = false; // ✅ Indique si le quiz est terminé
  Timer? _timer;
  int _timeLeft = 12;

  // ✅ Ajout : Listes pour suivre les statistiques
  List<bool> _answeredCorrectly = []; // Réponses correctes
  int _skippedQuestions = 0; // Nombre de questions passées
  int _lostPoints = 0; // Points perdus

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadQuestions() async {
    final questions = await _challengeService.loadBalancedQuestions(20);
    setState(() {
      _questions = questions;
      _answeredCorrectly = List<bool>.filled(questions.length, false);
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endQuiz();
        }
      });
    });
  }

  void _submitAnswer(bool isCorrect) {
    if (_isQuizEnded) return; // ✅ Bloquer si le quiz est terminé

    setState(() {
      if (isCorrect) {
        _score += 10; // Points pour une bonne réponse
        _answeredCorrectly[_currentQuestionIndex] = true;
      } else {
        _score -= 8; // Points pour une mauvaise réponse
        _lostPoints += 8; // Ajouter aux points perdus
      }
      _nextQuestion();
    });
  }

  void _skipQuestion() {
    if (_isQuizEnded) return; // ✅ Bloquer si le quiz est terminé

    setState(() {
      _score -= 2; // Points pour passer une question
      _skippedQuestions++;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_isQuizEnded) return; // ✅ Bloquer si le quiz est terminé

    if (_questions.isNotEmpty) {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
    }
  }

  void _endQuiz() async {
    if (_isQuizEnded) return; // ✅ Évite les appels multiples

    setState(() {
      _isQuizEnded = true; // ✅ Marquer le quiz comme terminé
    });

    _timer?.cancel();

    // ✅ Calcul des statistiques
    int correctAnswers = _answeredCorrectly.where((isCorrect) => isCorrect).length;
    int skippedQuestions = _skippedQuestions;
    int lostPoints = _lostPoints;
    int totalQuestionsPlayed = _currentQuestionIndex + 1; // ✅ Nombre réel de questions jouées

    // ✅ Mise à jour des statistiques dans Firebase
    await _statisticsService.updateSprintStatistics(
      points: _score,
      correctAnswers: correctAnswers,
      skippedQuestions: skippedQuestions,
      lostPoints: lostPoints,
      isWin: _score > 50, // ✅ Critère de victoire (modifiable si besoin)
      totalQuestionsPlayed: totalQuestionsPlayed, // ✅ Ajout du paramètre requis
    );

    // ✅ Affichage de l'écran de fin du quiz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.blue,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quiz Terminé !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Votre score : $_score',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Revenir à l\'Accueil',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header: Timer and Score
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.cyanAccent, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Temps restant: $_timeLeft s',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amberAccent, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Score: $_score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Question Card
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    currentQuestion.question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Options List
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: _isQuizEnded
                              ? null
                              : () => _submitAnswer(index == currentQuestion.correct),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isQuizEnded
                                ? Colors.grey
                                : Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.black.withOpacity(0.2),
                            elevation: 4,
                          ),
                          child: Text(
                            currentQuestion.options[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Skip Question Button
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ElevatedButton.icon(
                    onPressed: _isQuizEnded ? null : _skipQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isQuizEnded
                          ? Colors.grey
                          : Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text(
                      'Passer la question (-2 points)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}