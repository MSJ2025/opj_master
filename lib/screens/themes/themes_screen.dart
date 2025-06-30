import 'package:flutter/material.dart';
import 'package:opj_master/screens/themes/cours_screen.dart';
import '../themes/themes_pratiques.dart';
import '../themes/cours_screen.dart';

class ThemesScreen extends StatelessWidget {
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
                  padding: const EdgeInsets.only(top: 2.0, bottom: 20.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ours_prof.png',
                        height: 270,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Explorez et apprenez !',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 28,
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
                      title: 'Fiches de Cours',
                      description:
                      'Accédez aux résumés essentiels pour apprendre rapidement.',
                      assetImage: 'assets/images/manuel.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CoursScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    _buildOptionTile(
                      context,
                      title: 'Thèmes Pratiques',
                      description:
                      'Explorez les concepts fondamentaux de manière détaillée.',
                      assetImage: 'assets/images/pratique.png',
                      gradientColors: [Colors.blue.shade400, Colors.black26],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ThemesPratiquesScreen()),
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