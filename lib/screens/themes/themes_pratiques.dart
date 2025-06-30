import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemesPratiquesScreen extends StatefulWidget {
  @override
  _ThemesPratiquesScreenState createState() => _ThemesPratiquesScreenState();
}

class _ThemesPratiquesScreenState extends State<ThemesPratiquesScreen> {
  List<dynamic> _themes = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Set<int> _viewedIndexes = {}; // Suivi des histoires marquées comme effectuées

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _loadViewedIndexes();
  }

  Future<void> _loadThemes() async {
    final String jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/questions/themes_pratiques.json');
    final List<dynamic> themes = json.decode(jsonString);

    setState(() {
      _themes = themes;
      _isLoading = false;
    });
  }

  Future<void> _loadViewedIndexes() async {
    final prefs = await SharedPreferences.getInstance();
    final viewedIndexes = prefs.getStringList('viewedIndexes') ?? [];
    setState(() {
      _viewedIndexes = viewedIndexes.map(int.parse).toSet();
    });
  }

  Future<void> _saveViewedIndexes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('viewedIndexes', _viewedIndexes.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thèmes Pratiques",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _buildCarouselView(),
      ),
    );
  }

  Widget _buildCarouselView() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: _themes.length,
          controller: PageController(viewportFraction: 0.9),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final theme = _themes[index];
            final isViewed = _viewedIndexes.contains(index); // Vérifie si marqué comme effectué
            return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isViewed
                      ? [Colors.lightBlue, Colors.lightBlueAccent]
                      : [Colors.indigo, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(2, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Titre et Bouton "Marquer comme effectué"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            theme['titre'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isViewed ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isViewed ? Colors.greenAccent : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isViewed) {
                                _viewedIndexes.remove(index);
                              } else {
                                _viewedIndexes.add(index);
                              }
                              _saveViewedIndexes(); // Enregistre l'état après modification
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Histoire
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          theme['histoire'],
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),

                    // Bouton Voir la correction
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CorrectionScreen(correction: theme['correction'], title: theme['titre']),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        "Voir la correction",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Numérotation de pages
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Page ${_currentIndex + 1} sur ${_themes.length}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CorrectionScreen extends StatelessWidget {
  final List<dynamic> correction;
  final String title;

  CorrectionScreen({required this.correction, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade600, Colors.blueGrey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: correction.length,
          itemBuilder: (context, index) {
            final infraction = correction[index];
            return _buildCorrectionCard(infraction);
          },
        ),
      ),
    );
  }

  Widget _buildCorrectionCard(Map<String, dynamic> infraction) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade800,
                  child: Text(
                    infraction['infraction_numero'].toString(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    infraction['infraction']['qualification'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 30, color: Colors.blue.shade800),
            _buildSection(
              "Élément Légal",
              infraction['elements_constitutifs']['element_legal'],
              infraction['elements_de_preuve']['element_legal'],
            ),
            _buildSection(
              "Élément Matériel",
              (infraction['elements_constitutifs']['element_materiel'] as List<dynamic>).join('\n'),
              (infraction['elements_de_preuve']['element_materiel'] as List<dynamic>).join('\n'),
            ),
            _buildSection(
              "Élément Moral",
              infraction['elements_constitutifs']['element_moral'],
              infraction['elements_de_preuve']['element_moral'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String constitutive, String proof) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Constitutif :",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          constitutive,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 5),
        Text(
          "Preuve :",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          proof,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}