import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '/widgets/public_statistics_box.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;

  // Champs du profil
  String _username = "Utilisateur";
  String _selectedTitle = "Le Champion";
  String _selectedRegion = "France";
  String _selectedAvatar = "assets/images/default_avatar.png";
  String _bio = "";
  List<Map<String, dynamic>> _badges = [];

  bool get _isOwner => widget.userId == _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Charger les données du profil
  Future<void> _loadProfileData() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('profiles').doc(widget.userId).get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _username = data['username'] ?? "Utilisateur";
          _selectedTitle = data['title'] ?? "Le Champion";
          _selectedRegion = data['region'] ?? "France";
          _selectedAvatar = data['avatar'] ?? "assets/images/default_avatar.png";
          _bio = data['bio'] ?? "Aucune biographie disponible.";

          _badges = data.containsKey('badges') && data['badges'] is List
              ? List<Map<String, dynamic>>.from(data['badges'])
              : [
            {
              'name': 'Débutant',
              'icon': 'assets/images/badges/badge_debutant.png',
              'unlocked': false,
              'description': "Complétez 10 quiz d'entrainement"
            },
            {
              'name': 'Pro',
              'icon': 'assets/images/badges/badge_pro.png',
              'unlocked': false,
              'description': "Complètez 50 quiz d'entrainement, 50 challenges sprint, 50 challenges Survival"
            },
            {
              'name': 'Champion',
              'icon': 'assets/images/badges/badge_champion.png',
              'unlocked': false,
              'description': 'Atteignez le top 50 du classement général'
            },
            {
              'name': 'Légendaire',
              'icon': 'assets/images/badges/badge_legendaire.png',
              'unlocked': false,
              'description': 'Atteignez le top 10 du classement général'
            },
            {
              'name': 'Sprinteur',
              'icon': 'assets/images/badges/badge_sprinteur.png',
              'unlocked': false,
              'description': 'Atteignez 500 points cumulés dans le challenge Sprint'
            },
            {
              'name': 'Survivant',
              'icon': 'assets/images/badges/badge_survivant.png',
              'unlocked': false,
              'description': 'Atteignez 500 points cumulés dans le challenge Survival'
            },
            {
              'name': 'Tenace',
              'icon': 'assets/images/badges/badge_champion.png',
              'unlocked': false,
              'description': 'Atteignez 400 challenges effectués'
            },

          ];
        });
      } else {
        // Si le profil est vide ou n'existe pas
        setState(() {
          _username = "Nouvel Utilisateur";
          _selectedTitle = "Aucun titre";
          _selectedRegion = "Non spécifié";
          _selectedAvatar = "assets/images/default_avatar.png";
          _bio = "Bienvenue sur votre profil !";
          _badges = [];
        });
      }
    } catch (e) {
      print('🔴 Erreur lors du chargement du profil : $e');
      setState(() {
        _username = "Erreur de chargement";
        _selectedTitle = "Erreur";
        _selectedRegion = "Erreur";
        _selectedAvatar = "assets/images/default_avatar.png";
        _bio = "Impossible de charger les informations.";
        _badges = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Retour à l'accueil
  void _goToHome() {
    Navigator.pop(context);
  }

  /// Navigation vers la page d'édition
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: widget.userId),
      ),
    );

    if (result != null && result['shouldRefresh'] == true) {
      setState(() {
        _isLoading = true;
      });
      await _loadProfileData();
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// En-tête du Profil
  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 130), // Espacement ajusté sous la barre d'état
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 65,
            backgroundImage: AssetImage(_selectedAvatar),
          ),
        ),
        SizedBox(height: 16),
        Text(
          _username,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          _selectedTitle,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  /// Détails du Profil
  Widget _buildProfileDetails() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blue),
            title: Text('Région'),
            subtitle: Text(_selectedRegion),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text('Bio'),
            subtitle: Text(_bio),
          ),
        ],
      ),
    );
  }

  /// Liste des Badges
  Widget _buildBadges() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et sous-titre des badges
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber, size: 28),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏅 Badges',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Faites défiler pour découvrir vos badges',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          SizedBox(height: 8),

          // Liste de badges en défilement horizontal
          Container(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                final badge = _badges[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (badge['unlocked'] == true) {
                          // Affiche l'image en grand si le badge est débloqué
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      badge['icon'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        width: 100,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: badge['unlocked'] == true
                                      ? Colors.black54
                                      : Colors.grey,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  if (badge['unlocked'] == true)
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: Opacity(
                                opacity: badge['unlocked'] == true ? 1.0 : 0.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    badge['icon'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Affiche la description lorsque le titre est cliqué
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(badge['name']),
                            content: Text(badge['description']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        badge['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badge['unlocked'] == true
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profil'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: _goToHome),
        actions: [
          if (_isOwner)
            IconButton(icon: Icon(Icons.edit), onPressed: _navigateToEditProfile),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileDetails(),
              _buildBadges(),
              PublicStatisticsBox(userId: widget.userId),
    ],
          )
        ),
      ),
    );
  }
}