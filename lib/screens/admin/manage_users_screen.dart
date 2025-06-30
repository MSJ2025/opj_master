import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les Utilisateurs'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: _firestore.collection('profiles').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            var users = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                final userData = user.data() as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          userData['username']?[0].toUpperCase() ?? '?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        userData['username'] ?? 'Inconnu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Rôle : ${userData.containsKey('role') ? userData['role'] : 'user'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: userData.containsKey('role')
                              ? userData['role']
                              : 'user',
                          items: [
                            DropdownMenuItem(
                              value: 'user',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Utilisateur'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'premium',
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Premium'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(Icons.shield, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Admin'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            await _firestore
                                .collection('profiles')
                                .doc(user.id)
                                .update({'role': value});
                          },
                        ),
                      ),
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
}