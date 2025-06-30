import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GraphiquesScreen extends StatelessWidget {
  final String userId;

  GraphiquesScreen({required this.userId});

  /// Récupère les statistiques depuis Firestore
  Future<Map<String, dynamic>> fetchChallengeStats() async {
    final sprintDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('challenge_stats')
        .doc('sprint')
        .get();

    final survivalDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('challenge_stats')
        .doc('survival')
        .get();

    return {
      'sprint': sprintDoc.data() ?? {},
      'survival': survivalDoc.data() ?? {},
    };
  }

  /// Réinitialise les statistiques après confirmation
  Future<void> resetChallengeStats(BuildContext context) async {
    bool? confirmReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la réinitialisation'),
          content: Text('Voulez-vous vraiment réinitialiser toutes les statistiques des défis ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('challenge_stats')
            .doc('sprint')
            .set({
          'total_points': 0,
          'best_score': 0,
          'avg_correct_per_challenge': 0,
          'avg_points_per_challenge': 0,
          'avg_skipped_per_challenge': 0,
          'avg_points_lost_per_challenge': 0,
          'success_rate': 0,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('challenge_stats')
            .doc('survival')
            .set({
          'total_points': 0,
          'best_score': 0,
          'avg_correct_per_challenge': 0,
          'avg_score_per_challenge': 0,
          'avg_total_time_per_challenge': 0,
          'success_rate': 0,
          'total_challenges': 0,
          'total_correct_answers': 0,
          'total_questions_played': 0,
          'total_time_spent': 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statistiques réinitialisées avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : Impossible de réinitialiser les statistiques.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Méthode pour générer une ligne de statistique
  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques Challenges'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Réinitialiser les statistiques',
            onPressed: () => resetChallengeStats(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchChallengeStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.white)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('Aucune statistique trouvée.', style: TextStyle(color: Colors.white)),
              );
            }

            final sprintData = snapshot.data!['sprint'];
            final survivalData = snapshot.data!['survival'];

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏃 Sprint
                  Text('🏃 Statistiques Sprint', style: TextStyle(fontSize: 24, color: Colors.white)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(Icons.star, 'Total Points', '${sprintData['total_points'] ?? 0}'),
                        _buildStatRow(Icons.emoji_events, 'Meilleur Score', '${sprintData['best_score'] ?? 0}'),
                        _buildStatRow(Icons.check_circle, 'Moy. Réponses Correctes', '${sprintData['avg_correct_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.trending_up, 'Moy. Points', '${sprintData['avg_points_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.skip_next, 'Moy. Passages', '${sprintData['avg_skipped_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.remove_circle_outline, 'Moy. Points Perdus', '${sprintData['avg_points_lost_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.percent, 'Taux de Réussite', '${sprintData['success_rate'] ?? 0}%'),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white),

                  // 🛡️ Survival
                  Text('🛡️ Statistiques Survival', style: TextStyle(fontSize: 24, color: Colors.white)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(Icons.star, 'Total Points', '${survivalData['total_points'] ?? 0}'),
                        _buildStatRow(Icons.emoji_events, 'Meilleur Score', '${survivalData['best_score'] ?? 0}'),
                        _buildStatRow(Icons.check_circle, 'Moy. Réponses Correctes', '${survivalData['avg_correct_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.trending_up, 'Moyenne de Score', '${survivalData['avg_score_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.access_time, 'Moyenne Temps Total', '${survivalData['avg_total_time_per_challenge'] ?? 0}'),
                        _buildStatRow(Icons.percent, 'Taux de Réussite', '${survivalData['success_rate'] ?? 0}%'),
                        _buildStatRow(Icons.timeline, 'Nombre de Challenges', '${survivalData['total_challenges'] ?? 0}'),
                        _buildStatRow(Icons.check, 'Réponses Correctes Totales', '${survivalData['total_correct_answers'] ?? 0}'),
                        _buildStatRow(Icons.quiz, 'Questions Jouées Totales', '${survivalData['total_questions_played'] ?? 0}'),
                        _buildStatRow(Icons.timer, 'Temps Total Passé', '${survivalData['total_time_spent'] ?? 0} s'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

    );
  }
}