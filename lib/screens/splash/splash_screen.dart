import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/login_screen.dart';
import '/services/statistics_service.dart'; // Assurez-vous que le chemin est correct
import '/main.dart'; // Assurez-vous que le chemin est correct

class SplashScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  SplashScreen({required this.statisticsService});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation de pulsation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));

    // Navigation après 6 secondes
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthWrapper(
            statisticsService: widget.statisticsService,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verrouiller l'orientation en mode portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027), // Bleu foncé
              Color(0xFF203A43), // Bleu-gris intermédiaire
              Color(0xFF2C5364), // Bleu plus clair
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image animée avec pulsation
                  ScaleTransition(
                    scale: _animation,
                    child: Image.asset(
                      'assets/images/splash_image.png',
                      width: 800,
                      height: 800,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Animation de barre de chargement moderne

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}