import 'package:flutter/material.dart';

class PremiumBenefitsScreen extends StatefulWidget {
  @override
  _PremiumBenefitsScreenState createState() => _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends State<PremiumBenefitsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          _buildHeader(context),
          const SizedBox(height: 16),
          // Features Section
          Flexible(
            child: ListView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              children: _buildFeatureCards(),
            ),
          ),
          const SizedBox(height: 16),
          // CTA Button
          _buildCTAButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Image.asset(
              "assets/images/ours_pink2.png",
              height: 88,
              width: 88,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Passez à Premium",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Découvrez tous les avantages exclusifs",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildFeatureCards() {
    final features = [
      {
        "icon": Icons.lock_open,
        "title": "Accès Illimité",
        "description": "Débloquez toutes les questions et fonctionnalités.",
      },
      {
        "icon": Icons.bar_chart,
        "title": "Statistiques Avancées",
        "description": "Analysez vos performances avec des graphiques détaillés.",
      },
      {
        "icon": Icons.block, // Alternative à l'icône Ads
        "title": "Sans Publicité",
        "description": "Profitez d'une expérience sans interruptions.",
      },
    ];

    return features.map((feature) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueAccent.withOpacity(0.4),
              child: Icon(
                feature["icon"] as IconData,
                color: Colors.white,
              ),
            ),
            title: Text(
              feature["title"] as String, // Cast explicite en String
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                fontFamily: 'Montserrat',
              ),
            ),
            subtitle: Text(
              feature["description"] as String, // Cast explicite en String
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCTAButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Naviguer vers l'écran de paiement
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "Passer en Premium",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}