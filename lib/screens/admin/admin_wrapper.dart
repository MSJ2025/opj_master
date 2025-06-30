import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard_screen.dart';

class AdminWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Vérifiez si l'utilisateur est connecté
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Accès refusé : Connectez-vous.'),
        ),
      );
    }

    // Vérifiez le rôle de l'utilisateur
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('profiles').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text('Erreur : Impossible de vérifier le rôle utilisateur.'),
            ),
          );
        }

        final userDoc = snapshot.data!;
        final role = userDoc['role'] ?? 'user';

        if (role != 'admin') {
          return Scaffold(
            body: Center(
              child: Text('Accès refusé : Vous n\'êtes pas administrateur.'),
            ),
          );
        }

        // Accès autorisé à l'interface admin
        return AdminDashboardScreen();
      },
    );
  }
}