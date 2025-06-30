import 'package:flutter/material.dart';
import 'challenge_quiz_screen.dart';
import 'quiz_survival_screen.dart';


class ChallengeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            // Image d'en-tête avec l'ourson champion
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
                  padding: const EdgeInsets.only(top: 2, bottom: 10.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ours_king.png',
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 0),
                      Text(
                        'Les challenges OPJ Master !',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Testez vos connaissances et relevez les défis !',
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

            // Liste des challenges
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildChallengeTile(
                      context,
                      title: 'Challenge Sprint',
                      description:
                      'Vous avez 1 minute pour répondre à un maximum de questions couvrant tous les sous-domaines.',
                      assetImage: 'assets/images/ours_sprint.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeQuizScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    _buildChallengeTile(
                      context,
                      title: 'Survival Challenge',
                      description:
                      "Répondez correctement pour rester dans le jeu ! Trop d'erreurs et le challenge est terminé.",
                      assetImage: 'assets/images/ours_survival2.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizSurvivalScreen(),
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

  Widget _buildChallengeTile(
      BuildContext context, {
        required String title,
        required String description,
        IconData? icon,
        String? assetImage,
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
            padding: const EdgeInsets.all(2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (assetImage != null)
                  SizedBox(
                    height: 120, // Hauteur et largeur maximales pour l'image
                    width: 100,
                    child: Image.asset(
                      assetImage,
                      fit: BoxFit.contain, // L'image occupe tout l'espace disponible
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: gradientColors.first,
                    size: 28,
                  ),
                SizedBox(width: 8),
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