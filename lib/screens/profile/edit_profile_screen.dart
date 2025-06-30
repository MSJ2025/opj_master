import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  EditProfileScreen({required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = true;

  String _selectedTitle = "Le Champion";
  String _selectedRegion = "France";
  String _selectedAvatar = "assets/images/default_avatar.png";

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
          _usernameController.text = data['username'] ?? "Utilisateur";
          _bioController.text = data['bio'] ?? "Aucune biographie disponible.";
          _selectedTitle = data['title'] ?? "Le Champion";
          _selectedRegion = data['region'] ?? "France";
          _selectedAvatar = data['avatar'] ?? "assets/images/default_avatar.png";
          _isLoading = false;
        });
      } else {
        // Si le document n'existe pas ou est vide
        setState(() {
          _usernameController.text = "Nouvel Utilisateur";
          _bioController.text = "Bienvenue sur votre profil !";
          _selectedTitle = "Aucun titre";
          _selectedRegion = "Non spécifié";
          _selectedAvatar = "assets/images/default_avatar.png";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 Erreur lors du chargement des données : $e');
      setState(() {
        _usernameController.text = "Erreur de chargement";
        _bioController.text = "Impossible de charger les informations.";
        _selectedTitle = "Erreur";
        _selectedRegion = "Erreur";
        _selectedAvatar = "assets/images/default_avatar.png";
        _isLoading = false;
      });
    }
  }


  /// Sauvegarder les modifications
  Future<void> _saveProfile() async {
    await _firestore.collection('profiles').doc(widget.userId).update({
      'username': _usernameController.text,
      'title': _selectedTitle,
      'region': _selectedRegion,
      'avatar': _selectedAvatar,
      'bio': _bioController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil mis à jour avec succès')),
    );

    Navigator.pop(context, {'shouldRefresh': true});
  }

  /// Choisir un Avatar
  void _chooseAvatar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 21,
            itemBuilder: (context, index) {
              final avatar = "assets/images/ours${index + 1}.png";
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(avatar),
                  radius: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construction du formulaire
  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        height: screenHeight, // Fond dégradé sur toute la hauteur
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.08), // Ajustement dynamique
              Center(
                child: GestureDetector(
                  onTap: _chooseAvatar,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: AssetImage(_selectedAvatar),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              _buildFormField(
                label: 'Pseudo',
                icon: Icons.person,
                controller: _usernameController,
              ),
              SizedBox(height: 16),
              _buildFormField(
                label: 'Bio',
                icon: Icons.info,
                controller: _bioController,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                items: [
                  DropdownMenuItem(value: 'Le Champion', child: Text('Le Champion')),
                  DropdownMenuItem(value: 'Le Maître', child: Text('Le Maître')),
                  DropdownMenuItem(value: 'Légendaire', child: Text('Légendaire')),
                ],
                onChanged: (value) => setState(() => _selectedTitle = value ?? 'Le Champion'),
                decoration: InputDecoration(
                  labelText: 'Titre',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40), // Ajout d'un espace pour bien équilibrer
            ],
          ),
        ),
      ),
    );
  }
}