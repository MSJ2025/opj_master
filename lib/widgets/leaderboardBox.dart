import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opj_master/screens/profile/profile_screen.dart';

class LeaderboardBox extends StatefulWidget {
  final int maxEntries;

  LeaderboardBox({this.maxEntries = 10});

  @override
  _LeaderboardBoxState createState() => _LeaderboardBoxState();
}

class _LeaderboardBoxState extends State<LeaderboardBox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  /// 🛠️ Fetch leaderboard data from Firestore
  Future<List<Map<String, dynamic>>> fetchLeaderboard(String rankingType) async {
    try {
      final profilesSnapshot =
      await FirebaseFirestore.instance.collection('profiles').get();

      List<Map<String, dynamic>> leaderboard = [];

      for (var profileDoc in profilesSnapshot.docs) {
        final userId = profileDoc.id;
        final username = profileDoc['username'] ?? 'Utilisateur inconnu';
        final avatar = profileDoc['avatar'] ?? '';

        final statsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('challenge_stats')
            .doc(rankingType)
            .get();

        if (statsSnapshot.exists) {
          final points = statsSnapshot['total_points'] ?? 0;
          leaderboard.add({
            'userId': userId,
            'username': username,
            'points': points,
            'avatar': avatar,
          });
        }
      }

      leaderboard.sort((a, b) => b['points'].compareTo(a['points']));
      return leaderboard.take(widget.maxEntries).toList();
    } catch (e) {
      print('🔴 Erreur lors de la récupération du classement : $e');
      throw Exception('Impossible de charger le classement : $e');
    }
  }

  /// 🧭 Navigate to user profile
  void navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  /// 🖼️ Widget Avatar Universel avec gestion des erreurs
  Widget buildUserAvatar(String avatarUrl, {double radius = 40}) {
    if (avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: AssetImage('assets/images/default_avatar.png'),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: avatarUrl.startsWith('http')
          ? NetworkImage(avatarUrl)
          : AssetImage(avatarUrl) as ImageProvider,
      onBackgroundImageError: (_, __) {
        setState(() {
          print("⚠️ Erreur lors du chargement de l'image : $avatarUrl");
        });
      },
    );
  }

  /// 🥇 Carte pour les 3 meilleurs joueurs
  Widget _buildTopPlayerCard(
      BuildContext context, Map<String, dynamic> player, int position) {
    String avatarPath = player['avatar']?.isNotEmpty == true
        ? player['avatar']
        : 'assets/images/default_avatar.png';

    return GestureDetector(
      onTap: () => navigateToUserProfile(context, player['userId']),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            buildUserAvatar(avatarPath, radius: 30),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['username'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${player['points']} pts",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ],
            ),
            Spacer(),
            if (position == 1)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  /// 📝 Élément pour les joueurs suivants
  Widget _buildPlayerTile(Map<String, dynamic> player) {
    return GestureDetector(
      onTap: () => navigateToUserProfile(context, player['userId']),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: buildUserAvatar(player['avatar'], radius: 24),
          title: Text(
            player['username'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${player['points']} pts",
            style: TextStyle(color: Colors.grey),
          ),

        ),
      ),
    );
  }

  /// 🏆 Construire le contenu du classement
  Widget buildLeaderboard(String rankingType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchLeaderboard(rankingType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '🔴 Erreur : ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('🟡 Aucun joueur trouvé pour ce classement.'),
          );
        }

        final leaderboard = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final player = leaderboard[index];
                return _buildPlayerTile(player);
              },
            ),
          ],
        );
      },
    );
  }

  /// 📊 Construire l'interface utilisateur principale
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blueGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre "Meilleurs joueurs"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🏆 Meilleurs joueurs",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Icon(Icons.leaderboard, color: Colors.amber, size: 24),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Barre de navigation pour les onglets
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.amber,
            indicatorWeight: 3.0,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.directions_run, size: 20),
                text: 'Sprint',
              ),
              Tab(
                icon: Icon(Icons.shield, size: 20),
                text: 'Survival',
              ),
            ],
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet Sprint
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    physics: BouncingScrollPhysics(),
                    child: buildLeaderboard('sprint'),
                  ),
                ),

                // Onglet Survival
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    physics: BouncingScrollPhysics(),
                    child: buildLeaderboard('survival'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}