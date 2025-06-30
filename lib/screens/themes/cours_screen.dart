import 'dart:convert';
import 'package:flutter/material.dart';

class CoursScreen extends StatefulWidget {
  @override
  _CoursScreenState createState() => _CoursScreenState();
}

class _CoursScreenState extends State<CoursScreen> {
  bool _isLoading = false;
  List<dynamic>? _dpgCourses;
  List<dynamic>? _ppCourses;
  List<dynamic>? _dpsInfractions;

  Future<void> _loadData(String filePath, String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String jsonString =
      await DefaultAssetBundle.of(context).loadString(filePath);
      final List<dynamic> data = json.decode(jsonString);

      data.sort((a, b) => (a['type'] ?? '').compareTo(b['type'] ?? ''));

      setState(() {
        if (category == 'DPG') _dpgCourses = data;
        if (category == 'PP') _ppCourses = data;
        if (category == 'DPS') _dpsInfractions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de chargement des données : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData('assets/cours/cadres_enquete.json', 'DPG');
    _loadData('assets/cours/actes_enquete.json', 'PP');
    _loadData('assets/cours/cours_dps.json', 'DPS');
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigo.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Fiches de Révision",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Accédez à des résumés organisés et interactifs.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: () => onPressed(),
        icon: Icon(icon, size: 28),
        label: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
    );
  }

  void _showCategoryDetails(List<dynamic>? items, String categoryTitle) {
    if (items == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aucun contenu disponible pour cette catégorie."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsListScreen(title: categoryTitle, items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cours et Révisions", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.indigo.shade800))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildCategoryButton(
                "Droit Pénal Général",
                Icons.book,
                    () => _showCategoryDetails(_dpgCourses, "Droit Pénal Général"),
              ),
              _buildCategoryButton(
                "Procédure Pénale",
                Icons.bookmark,
                    () => _showCategoryDetails(_ppCourses, "Procédure Pénale"),
              ),
              _buildCategoryButton(
                "Droit Pénal Spécial",
                Icons.gavel,
                    () => _showCategoryDetails(_dpsInfractions, "Droit Pénal Spécial"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsListScreen extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  DetailsListScreen({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: ListTile(
              title: Text(
                item['type'] ?? 'Titre inconnu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                (item['details'] as Map?)?['cadre_juridique'] ?? "Détails indisponibles",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(data: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailsScreen({required this.data});

  Widget _buildSection(String title, dynamic content) {
    if (content == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(content.toString(), style: TextStyle(color: Colors.black87)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['type'] ?? 'Détails'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Cadre Juridique", data['details']?['cadre_juridique']),
            _buildSection("Cadre Légal", data['details']?['cadre_legal']),
            _buildSection("Justification", data['details']?['justification']?['description']),
          ],
        ),
      ),
    );
  }
}