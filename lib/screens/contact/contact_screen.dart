import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/contact/user_box_screen.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _questionController.text.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await FirebaseFirestore.instance.collection('questions').add({
          'userId': user.uid,
          'email': user.email,
          'question': _questionController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'archived': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Votre question a été envoyée avec succès.')),
        );

        Navigator.pop(context); // Retour à l'écran précédent
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi : ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir une question.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nous contacter'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section pour poser une question
            Text(
              'Posez votre question ou envoyez-nous vos retours.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _questionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Votre question...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitQuestion,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }  }