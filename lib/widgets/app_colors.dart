import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF1A73E8); // Bleu moderne
  static const secondaryColor = Color(0xFFF9A825); // Jaune chaleureux
  static const cardColor = Colors.white; // Couleur des cartes
  static const shadowColor = Colors.black12; // Ombres légères
  static const textColor = Color(0xFF202124); // Texte principal
  static const mutedTextColor = Color(0xFF5F6368); // Texte atténué
  static const errorColor = Color(0xFFD32F2F); // Rouge pour les erreurs

  // Dégradé pour le fond
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFFF9A825)], // Bleu -> Jaune
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}