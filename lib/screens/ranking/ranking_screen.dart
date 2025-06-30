import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:opj_master/screens/profile/profile_screen.dart';

/// Écran du classement des utilisateurs
class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  String selectedRankingType = 'sprint'; // Type de classement sélectionné

  /// 🔄 Test direct de l'accès Firestore
  Future<void> testFirestoreAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('❌ Aucun utilisateur connecté.');
      return;
    }

    try {
      print('🟡 Test d\'accès aux statistiques Sprint pour l\'utilisateur : ${user.uid}');

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('challenge_stats')
          .doc('sprint')
          .get();

      if (docSnapshot.exists) {
        print('🟢 Accès réussi aux statistiques Sprint : ${docSnapshot.data()}');
      } else {
        print('❌ Aucun document Sprint trouvé pour cet utilisateur.');
      }
    } catch (e) {
      print('🔴 Erreur d\'accès aux statistiques Sprint : $e');
    }
  }

  /// 🔍 Étape 1 : Récupère les utilisateurs depuis `profiles` et leurs statistiques
  Future<List<Map<String, dynamic>>> fetchRanking(String type) async {
    try {
      print('🟡 Début de la récupération du classement pour le type : $type');

      final profilesSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .get();

      print('🟢 Profils trouvés : ${profilesSnapshot.docs.length}');

      List<Map<String, dynamic>> ranking = [];

      for (var profileDoc in profilesSnapshot.docs) {
        final userId = profileDoc.id;
        final username = profileDoc['username'] ?? 'Utilisateur inconnu';
        final avatar = profileDoc['avatar'] ?? '';

        final challengeDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('challenge_stats')
            .doc(type)
            .get();

        if (challengeDoc.exists) {
          final points = challengeDoc['total_points'] ?? 0;
          print('✅ Statistiques trouvées pour $username : $points points');

          ranking.add({
            'userId': userId,
            'username': username,
            'points': points,
            'avatar': avatar,
          });
        } else {
          print('❌ Aucun document trouvé pour $username dans challenge_stats/$type');
        }
      }

      ranking.sort((a, b) => b['points'].compareTo(a['points']));

      print('🟢 Classement final : ${ranking.length} utilisateurs.');
      return ranking;
    } catch (e) {
      print('🔴 Erreur lors de la récupération du classement : $e');
      throw Exception('Impossible de charger le classement : $e');
    }
  }

  /// 🚀 Navigation vers le profil utilisateur
  void navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    testFirestoreAccess(); // 🔍 Test direct Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classement des Joueurs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Barre de sélection du type de classement
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedRankingType,
                  isExpanded: true,
                  dropdownColor: Colors.blueGrey.shade900,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: SizedBox(),
                  items: ['sprint', 'survival']
                      .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRankingType = value!;
                    });
                  },
                ),
              ),
            ),

            // Affichage du classement
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchRanking(selectedRankingType),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '🔴 Erreur : ${snapshot.error}',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        '🟡 Aucune donnée trouvée pour ce classement.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final ranking = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final user = ranking[index];
                      return GestureDetector(
                        onTap: () => navigateToUserProfile(user['userId']),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                index == 0
                                    ? Colors.amber.shade400
                                    : index == 1
                                    ? Colors.grey.shade400
                                    : index == 2
                                    ? Colors.brown.shade300
                                    : Colors.blueGrey,
                                Colors.grey.shade900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: user['avatar'].isNotEmpty
                                    ? NetworkImage(user['avatar'])
                                    : AssetImage('assets/images/default_avatar.png')
                                as ImageProvider,
                                backgroundColor: Colors.grey[200],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['username'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${user['points']} pts',
                                      style: TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}