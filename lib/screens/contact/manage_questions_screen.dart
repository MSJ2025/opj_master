import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageQuestionsScreen extends StatelessWidget {
  const ManageQuestionsScreen({Key? key}) : super(key: key);

  Future<void> _archiveQuestion(BuildContext context, String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .update({'archived': true});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question archivée.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  Future<void> addArchivedFieldToQuestions() async {
    final questions = await FirebaseFirestore.instance.collection('questions').get();

    for (final question in questions.docs) {
      if (!question.data().containsKey('archived')) {
        await question.reference.update({'archived': false});
      }
    }
  }

  Future<void> _deleteQuestion(BuildContext context, String questionId) async {
    try {
      await FirebaseFirestore.instance.collection('questions').doc(questionId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question supprimée.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  void _showAnswerDialog(BuildContext context, String questionId, String? currentAnswer) {
    final TextEditingController _answerController =
    TextEditingController(text: currentAnswer ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une réponse'),
        content: TextField(
          controller: _answerController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Saisissez votre réponse ici...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final answer = _answerController.text.trim();
              if (answer.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('questions')
                      .doc(questionId)
                      .update({'answer': answer});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Réponse ajoutée avec succès.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de l\'ajout de la réponse : $e')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _addAnswer(String questionId, String answer) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .update({'answer': answer});
      print('Réponse ajoutée avec succès.');
    } catch (e) {
      print('Erreur lors de l\'ajout de la réponse : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les questions'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where('archived', isEqualTo: false) // Affiche uniquement les questions non archivées
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Erreur Firestore : ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucune question disponible.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            );
          }

          final questions = snapshot.data!.docs;

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final data = question.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Text(
                        data['question'] ?? 'Question non disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Email de l'utilisateur
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            data['email'] ?? 'Utilisateur inconnu',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Timestamp
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          data['timestamp'] != null
                              ? (data['timestamp'] as Timestamp).toDate().toString()
                              : 'Date inconnue',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Actions (Archiver et Supprimer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showAnswerDialog(context, question.id, data['answer']);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                            child: Text('Répondre'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _archiveQuestion(context, question.id);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            child: Text('Archiver'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _deleteQuestion(context, question.id);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text('Supprimer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          );
        },
      ),
    );
  }
}