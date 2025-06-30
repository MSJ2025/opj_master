import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicStatisticsBox extends StatefulWidget {
  final String userId;

  PublicStatisticsBox({required this.userId});

  @override
  _PublicStatisticsBoxState createState() => _PublicStatisticsBoxState();
}

class _PublicStatisticsBoxState extends State<PublicStatisticsBox> {
  late Future<Map<String, dynamic>> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    print('🟡 Initialisation des statistiques pour userId: ${widget.userId}');
    _statisticsFuture = fetchPublicStatistics();
  }

  /// 🔄 Récupère les statistiques depuis Firestore
  Future<Map<String, dynamic>> fetchPublicStatistics() async {
    print('🟡 Début de la récupération des statistiques...');
    try {
      if (widget.userId.isEmpty) {
        throw Exception('❌ L\'ID utilisateur est vide.');
      }

      final sprintSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('challenge_stats')
          .doc('sprint')
          .get();

      final survivalSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('challenge_stats')
          .doc('survival')
          .get();

      print('🟢 Snapshots obtenus : sprint=${sprintSnapshot.exists}, survival=${survivalSnapshot.exists}');

      if (!sprintSnapshot.exists && !survivalSnapshot.exists) {
        throw Exception('❌ Aucune statistique trouvée pour cet utilisateur.');
      }

      Map<String, dynamic> sprintData = sprintSnapshot.data() ?? {};
      Map<String, dynamic> survivalData = survivalSnapshot.data() ?? {};

      print('🟢 Données récupérées : Sprint=$sprintData, Survival=$survivalData');

      return {
        'total_points': (sprintData['total_points'] ?? 0) + (survivalData['total_points'] ?? 0),
        'sprint_points': sprintData['total_points'] ?? 0,
        'survival_points': survivalData['total_points'] ?? 0,
        'best_sprint_score': sprintData['best_score'] ?? 0,
        'best_challenge_score': survivalData['best_score'] ?? 0,
        'challenges_completed': (sprintData['total_challenges'] ?? 0) + (survivalData['total_challenges'] ?? 0),
        'ratio': survivalData['success_rate'] ?? 0.0,
      };
    } catch (e) {
      print('🔴 Erreur lors du chargement des statistiques : $e');
      throw Exception('Erreur : $e');
    }
  }

  /// 📊 Affiche les statistiques publiques
  /// Widget élégant pour afficher les statistiques publiques
  Widget buildStatistics(Map<String, dynamic> stats) {
    print('🟢 Affichage des statistiques : $stats');
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF203A43), Color(0xFF0F2027)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Statistiques',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white24),

            // Première ligne des stats
            _buildStatTile(
              icon: Icons.star,
              color: Colors.orange,
              title: 'SCORE TOTAL',
              value: '${stats['total_points']}',
            ),
            _buildStatTile(
              icon: Icons.flash_on,
              color: Colors.yellow,
              title: 'SCORE TOTAL SPRINT',
              value: '${stats['sprint_points']}',
            ),
            _buildStatTile(
              icon: Icons.shield,
              color: Colors.green,
              title: 'SCORE TOTAL SURVIVAL',
              value: '${stats['survival_points']}',
            ),
            Divider(color: Colors.white24),

            // Deuxième ligne des stats
            _buildStatTile(
              icon: Icons.timer,
              color: Colors.red,
              title: 'Meilleur score SPRINT',
              value: '${stats['best_sprint_score']}',
            ),
            _buildStatTile(
              icon: Icons.flag,
              color: Colors.purple,
              title: 'Meilleur score SURVIVAL',
              value: '${stats['best_challenge_score']}',
            ),
            Divider(color: Colors.white24),

            // Troisième ligne des stats
            _buildStatTile(
              icon: Icons.emoji_events,
              color: Colors.teal,
              title: 'Challenges effectués',
              value: '${stats['challenges_completed']}',
            ),
            _buildStatTile(
              icon: Icons.equalizer,
              color: Colors.blueGrey,
              title: 'Ratio',
              value: '${stats['ratio']}%',
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Sous-widget pour chaque statistique
  Widget _buildStatTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      horizontalTitleGap: 12,
    );
  }



  /// 🧩 Gestionnaire d'état avec FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        print('🔄 État actuel du FutureBuilder : ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔵 En attente des données...');
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('🔴 Erreur FutureBuilder : ${snapshot.error}');
          return Center(
            child: Text(
              'Erreur : ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('⚠️ Aucune statistique trouvée.');
          return Center(
            child: Text(
              'Aucune statistique disponible pour cet utilisateur.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final stats = snapshot.data!;
        return buildStatistics(stats);
      },
    );
  }
}