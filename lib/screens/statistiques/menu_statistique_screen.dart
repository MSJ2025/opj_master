import 'package:flutter/material.dart';
import 'statistiques_screen.dart'; // Import de la page des statistiques
import 'challenges_stat_screen.dart'; // Import de la page des graphiques
import 'package:opj_master/services/statistics_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuStatistiquesScreen extends StatelessWidget {
  final StatisticsService statisticsService;

  MenuStatistiquesScreen({required this.statisticsService});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Utilisateur non connecté',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // En-tête avec titre et description
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.blueGrey],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ours_savant.png',
                        height: 205,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 0),
                      Text(
                        'Analysez vos performances',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Visualisez vos progrès et vos statistiques détaillées pour mieux comprendre vos performances.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Liste des options
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOptionTile(
                      context,
                      title: "Statistiques d'entraînement",
                      description: 'Obtenez un aperçu détaillé de vos résultats.',
                      assetImage: 'assets/images/pourcent.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatistiquesScreen(
                              statisticsService: statisticsService,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    _buildOptionTile(
                      context,
                      title: 'Statistiques de challenge',
                      description: 'Visualisez vos progrès au fil du temps.',
                      assetImage: 'assets/images/graph.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GraphiquesScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required String title,
        required String description,
        required String assetImage,
        required List<Color> gradientColors,
        required VoidCallback onPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image à gauche
                SizedBox(
                  height: 100,
                  width: 80,
                  child: Image.asset(
                    assetImage,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 8),
                // Texte à droite
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}