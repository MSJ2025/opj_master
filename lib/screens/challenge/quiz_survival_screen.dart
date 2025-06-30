import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../services/challenge_service.dart';
import '../../services/challenge_statistics_service.dart';

class QuizSurvivalScreen extends StatefulWidget {
  @override
  _QuizSurvivalScreenState createState() => _QuizSurvivalScreenState();
}

class _QuizSurvivalScreenState extends State<QuizSurvivalScreen>
    with SingleTickerProviderStateMixin {
  final ChallengeService _challengeService = ChallengeService();
  final ChallengeStatisticsService _statisticsService = ChallengeStatisticsService();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _lives = 4;
  int _passes = 3;
  bool _isLoading = true;
  bool _isQuizEnded = false; // ✅ Pour éviter les appels multiples
  Timer? _timer;
  int _timeLeft = 15;

  late AnimationController _animationController;

  // ✅ Suivi temporaire des statistiques
  List<bool> _answeredCorrectly = [];
  double _totalTimeSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.forward();
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
          _totalTimeSpent++;
        } else {
          _loseLife();
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _startTimer();
  }

  void _submitAnswer(bool isCorrect) {
    if (_isQuizEnded) return; // ✅ Empêche les réponses après la fin du jeu

    setState(() {
      if (isCorrect) {
        int pointsGained = _timeLeft;
        _score += pointsGained;
        _answeredCorrectly[_currentQuestionIndex] = true;
        _nextQuestion();
      } else {
        _loseLife();
      }
    });
  }

  void _skipQuestion() {
    if (_isQuizEnded || _passes <= 0) return; // ✅ Vérifie les passes disponibles

    setState(() {
      _passes--;
      _nextQuestion();
    });
  }

  void _loseLife() {
    if (_isQuizEnded) return;

    setState(() {
      _lives--;
      if (_lives == 0) {
        _endGame();
      } else {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_isQuizEnded) return;

    _resetTimer();
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
      _animationController.forward(from: 0.0);
    } else {
      _endGame();
    }
  }

  void _endGame() async {
    if (_isQuizEnded) return;

    setState(() {
      _isQuizEnded = true;
    });

    _timer?.cancel();

    // ✅ Calcul des statistiques
    int correctAnswers = _answeredCorrectly.where((isCorrect) => isCorrect).length;
    double totalTime = _totalTimeSpent;
    int totalQuestionsPlayed = _currentQuestionIndex + 1; // Nombre réel de questions jouées

    // ✅ Mise à jour des statistiques dans Firebase
    await _statisticsService.updateSurvivalStatistics(
      points: _score,
      correctAnswers: correctAnswers,
      totalTime: totalTime,
      isWin: _lives > 0, // ✅ Critère de victoire basé sur le nombre de vies restantes
      totalQuestionsPlayed: totalQuestionsPlayed, // ✅ Ajout du paramètre requis
    );

    // ✅ Affichage de l'écran de fin du jeu
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.green,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jeu Terminé !',
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
                Text(
                  'Temps total : ${_totalTimeSpent.toStringAsFixed(1)} secondes',
                  style: TextStyle(
                    fontSize: 18,
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
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLives() {
    return Row(
      children: List.generate(
        _lives,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(Icons.favorite, color: Colors.redAccent, size: 30),
        ),
      ),
    );
  }

  Widget _buildPasses() {
    return Row(
      children: List.generate(
        _passes,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(Icons.arrow_forward, color: Colors.orangeAccent, size: 30),
        ),
      ),
    );
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
            colors: [Color(0xFF1E1E2F), Color(0xFF28293E), Color(0xFF3C3F5E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 60.0),
          child: Column(
            children: [
              // Header with Lives, Score, and Passes
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Lives
                    Column(
                      children: [
                        Row(
                          children: List.generate(
                            _lives,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vies',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // Score
                    Column(
                      children: [
                        Text(
                          '$_score',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    // Passes
                    Column(
                      children: [
                        Row(
                          children: List.generate(
                            _passes,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.arrow_forward, color: Colors.orangeAccent, size: 28),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Passes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Question Text
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion.question,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              // Answer Options
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 4,
                        ),
                        onPressed: () => _submitAnswer(index == currentQuestion.correct),
                        child: Text(
                          currentQuestion.options[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Skip Question Button
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _skipQuestion,
                  child: Text(
                    'Passer la question',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Timer
              LinearProgressIndicator(
                value: _timeLeft / 15,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}