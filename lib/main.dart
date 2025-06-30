import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opj_master/models/statistics.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/quiz/quiz_settings_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/statistiques/menu_statistique_screen.dart';
import 'screens/actualites/actualites.dart';
import 'widgets/theme.dart';
import 'services/statistics_service.dart';
import 'services/audio_service.dart';
import 'screens/admin/admin_dashboard_screen.dart'; // Import admin pages
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/manage_reports_screen.dart';
import 'screens/admin/admin_wrapper.dart';
import 'screens/contact/manage_questions_screen.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(StatisticsAdapter());
  // Initialisation Firebase
  await Firebase.initializeApp();
  // Initialisation Hive
  await Hive.initFlutter();
  final statisticsService = StatisticsService();
  await statisticsService.init();
  await statisticsService.validateStatistics();
  statisticsService.printAllStatistics();
  await statisticsService.printJsonKeys();
  // Ouvrir une boîte pour le test
  final box = await Hive.openBox<Statistics>('testBox');
  // Code de test : Créer, sauvegarder et charger une instance de Statistics
  final stats = Statistics(
    quizId: 'testQuiz',
    correctAnswers: 10,
    totalQuestions: 15,
    totalResponseTime: 30.0,
    domain: 'TestDomain',
    subDomain: 'TestSubDomain',
    isCorrect: true,
    isChallenge: false,
    isWin: true,
    date: DateTime.now(),
    sessions: [
      {'question': 'Sample question', 'correct': true, 'timeTaken': 5},
    ],
  );
  await box.put('testKey', stats);
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  runApp(OPJMasterApp(statisticsService: statisticsService));

}

class OPJMasterApp extends StatelessWidget {
  final StatisticsService statisticsService;

  OPJMasterApp({required this.statisticsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // Passez la clé globale ici
      title: 'OPJ Master',
      theme: AppTheme.lightTheme(),
      home: SplashScreen(statisticsService: statisticsService),
      routes: {
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(statisticsService: statisticsService),
        '/profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return ProfileScreen(userId: user.uid);
          } else {
            return Scaffold(
              body: Center(
                child: Text('Erreur : Aucun utilisateur connecté'),
              ),
            );
          }
        },
        '/quiz-settings': (context) => QuizSettingsScreen(
          statisticsService: statisticsService,
        ),
        '/statistics': (context) =>
            MenuStatistiquesScreen(statisticsService: statisticsService),
        '/actualites': (context) => ActualitesScreen(),
        '/admin': (context) => AdminWrapper(), // Wrapper pour vérifier l’accès admin
        '/admin/users': (context) => ManageUsersScreen(),
        '/admin/reports': (context) => ReportedQuestionsScreen(),
        '/admin/contact': (context) => ManageQuestionsScreen(),

      },
      onGenerateRoute: (settings) {
        if (settings.name == '/quiz') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null ||
              args['subDomains'] == null ||
              args['numberOfQuestions'] == null) {
            throw ArgumentError("Arguments manquants ou nuls pour /quiz");
          }

          return MaterialPageRoute(
            builder: (context) => QuizScreen(
              selectedSubDomains: [],
              numberOfQuestions: 10,
              statisticsService: statisticsService,
            ),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final StatisticsService statisticsService;

  AuthWrapper({required this.statisticsService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          User? user = snapshot.data;

          if (user != null && !user.emailVerified) {
            // Si l'utilisateur est connecté mais son e-mail n'est pas vérifié
            return EmailVerificationScreen();
          }

          // Si l'utilisateur est connecté et son e-mail est vérifié
          return HomeScreen(statisticsService: statisticsService);
        }

        // Si l'utilisateur n'est pas connecté
        return LoginScreen();
      },
    );
  }
}