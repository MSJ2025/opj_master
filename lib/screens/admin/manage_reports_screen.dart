import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedQuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questions Signalées"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('question_reports').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("Connexion à Firebase en cours...");
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Erreur lors de la récupération des signalements : ${snapshot.error}");
              return Center(
                child: Text(
                  "Erreur : ${snapshot.error}",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              print("Aucun signalement trouvé dans la base de données.");
              return Center(
                child: Text(
                  "Aucun signalement pour le moment.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final reports = snapshot.data!.docs;
            print("Nombre de signalements récupérés : ${reports.length}");

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final reportData = report.data() as Map<String, dynamic>;

                // Log pour vérifier les données du signalement
                print("Signalement récupéré : $reportData");

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      reportData['question'] ?? "Question inconnue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Text(
                          "Motif : ${reportData['details'] ?? 'Non spécifié'}",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Signalé le : ${reportData['timestamp'] ?? 'Inconnu'}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReport(report.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _deleteReport(String reportId) async {
    try {
      print("Tentative de suppression du signalement avec ID : $reportId");
      await FirebaseFirestore.instance.collection('question_reports').doc(reportId).delete();
      print("Signalement supprimé avec succès : $reportId");
    } catch (e) {
      print("Erreur lors de la suppression du signalement : $e");
    }
  }
}