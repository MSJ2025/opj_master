import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:opj_master/screens/actualites/actualites.dart';
import 'package:opj_master/screens/admin/admin_dashboard_screen.dart';
import 'package:opj_master/services/auth_service.dart';
import 'package:opj_master/screens/profile/profile_screen.dart';
import 'package:opj_master/screens/quiz/quiz_settings_screen.dart';
import 'package:opj_master/screens/statistiques/menu_statistique_screen.dart';
import 'package:opj_master/screens/themes/themes_screen.dart';
import 'package:opj_master/screens/challenge/challenge_screen.dart';
import 'package:opj_master/widgets/theme.dart';
import 'package:opj_master/services/statistics_service.dart';
import '/screens/admin/admin_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/contact/contact_screen.dart';
import '/screens/contact/user_box_screen.dart';

class HomeScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  HomeScreen({required this.statisticsService});

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  bool _isMenuOpen = false;
  late List<Widget> _screens;
  bool _isAdmin = false; // Indicateur pour savoir si l'utilisateur est admin
  bool _hasNewMessages = false;


  @override
  void initState() {
    AudioService().playBackgroundMusic('sons/background.mp3');
    _checkForNewMessages();

    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialisation des écrans avec le service des statistiques
    _screens = [
      ActualitesScreen(),
      QuizSettingsScreen(statisticsService: widget.statisticsService), // Passez le service ici
      ChallengeScreen(),
      ThemesScreen(),
      MenuStatistiquesScreen(statisticsService: widget.statisticsService),
    ];
    _checkIfAdmin(); // Vérifie si l'utilisateur est admin

  }


  void _checkForNewMessages() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('questions')
          .where('userId', isEqualTo: user.uid)
          .where('archived', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _hasNewMessages = true; // Il y a des messages
          });
        } else {
          setState(() {
            _hasNewMessages = false; // Aucun message
          });
        }
      });
    }
  }


  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Utilisateur connecté : ${user.uid}");

      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        print("Données de l'utilisateur : $data");

        if (data['role'] == 'admin') {
          setState(() {
            _isAdmin = true;
          });
          print("L'utilisateur est admin !");
        } else {
          print("L'utilisateur n'est pas admin.");
        }
      } else {
        print("Document utilisateur introuvable ou vide.");
      }
    } else {
      print("Aucun utilisateur connecté.");
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? '
              'Toutes vos données seront définitivement perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme la boîte de dialogue
              _deleteAccount(); // Appelle la méthode pour supprimer le compte
            },
            child: Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Supprime les données Firestore
        await FirebaseFirestore.instance.collection('profiles').doc(user.uid).delete();

        // Supprime l'utilisateur Firebase Authentication
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Votre compte a été supprimé.')),
        );

        // Redirige vers la page d'accueil
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : ${e.toString()}')),
        );
      }
    }
  }



  void _toggleMenu() {
    setState(() {
      if (_isMenuOpen) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        VoidCallback? onTap,
        bool badge = false,
      }) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(icon, color: color, size: 24),
          if (badge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: PageView(
              controller: _pageController,
              children: _screens,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          // Top-right menu toggle button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 20,
                  height: 80,
                  margin: EdgeInsets.only(right: 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(-1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        _isMenuOpen ? Icons.close : Icons.settings,
                        color: AppTheme.lightTheme().cardColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Side menu
    // Side menu
    AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
    double slide = 240 * _animationController.value; // Ajustement de la largeur
    return Transform.translate(
    offset: Offset(-240 + slide, 0), // Déplacement fluide
    child: Container(
    width: 240,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 10,
    offset: Offset(0, 4),
    ),
    ],
    ),
    child: SafeArea(
    child: FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('profiles')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
    return Center(
    child: Text(
    "Erreur de chargement du profil",
    style: TextStyle(color: Colors.white),
    ),
    );
    }

    final data = snapshot.data!.data() as Map<String, dynamic>;
    final avatar = data['avatar'] ?? 'assets/images/default_avatar.png';
    final username = data['username'] ?? 'Utilisateur';

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // En-tête du menu
    Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.teal.shade700, Colors.teal.shade900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 10,
    offset: Offset(0, 4),
    ),
    ],
    ),
    child: Row(
    children: [
    CircleAvatar(
    radius: 30,
    backgroundImage: avatar.startsWith('http')
    ? NetworkImage(avatar)
        : AssetImage(avatar) as ImageProvider,
    ),
    SizedBox(width: 12),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    "$username",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
    ),
    ),
    SizedBox(height: 4),

    ],
    ),
    ],
    ),
    ),

                        // Options du menu
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildMenuItem(
                                context,
                                icon: Icons.account_circle,
                                title: 'Profil',
                                color: Colors.white,
                                onTap: () {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(userId: user.uid),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur : Aucun utilisateur connecté'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                              if (_isAdmin)
                                _buildMenuItem(
                                  context,
                                  icon: Icons.developer_mode,
                                  title: 'Admin',
                                  color: Colors.amber,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                                    );
                                  },
                                ),
                              _buildMenuItem(
                                context,
                                icon: Icons.logout,
                                title: 'Déconnexion',
                                color: Colors.white,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirmation"),
                                      content: Text("Voulez-vous vraiment vous déconnecter ?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("Annuler"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await _authService.signOut();
                                            Navigator.pushNamedAndRemoveUntil(
                                                context, '/', (route) => false);
                                          },
                                          child: Text("Déconnecter"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                context,
                                icon: Icons.delete,
                                title: 'Se désinscrire',
                                color: Colors.red,
                                onTap: _showDeleteAccountDialog,
                              ),
                              _buildMenuItem(
                                context,
                                icon: Icons.contact_support,
                                title: 'Nous contacter',
                                color: Colors.blueAccent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ContactUsScreen()),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                context,
                                icon: Icons.mail,
                                title: 'Boîte de réception',
                                color: Colors.tealAccent,
                                badge: _hasNewMessages, // Ajout d'un badge pour les messages non lus
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserInboxScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Pied de page
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Powered by OPJ Master",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
      }, ),
                ),
              ));
            },
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        shadowColor: Colors.white,
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.home, title: 'Accueil'),
          TabItem(icon: Icons.quiz, title: 'Quiz'),
          TabItem(
            icon: Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            title: 'Challenge',
          ),
          TabItem(icon: Icons.book, title: 'Thèmes'),
          TabItem(icon: Icons.bar_chart, title: 'Stats'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.black, Colors.blue]),

        activeColor: Colors.white,
        color: Colors.grey.shade400,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}