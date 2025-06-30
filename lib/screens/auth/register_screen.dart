import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:opj_master/main.dart'; // Assurez-vous que le chemin est correct

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _socialLinkController = TextEditingController();

  String _selectedRegion = "France";
  bool _acceptedCGU = false;
  String _selectedAvatar = "assets/images/ours1.png";
  Position? _userLocation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    if (!_acceptedCGU) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Veuillez accepter les CGU.")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String userId = userCredential.user!.uid;

      // Envoi de l'e-mail de vérification
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("Un e-mail de vérification a été envoyé. Veuillez vérifier votre boîte mail.")),
        );
      }


      await _firestore.collection('profiles').doc(userId).set({
        'userId': userId,
        'username': _usernameController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
        'socialLink': _socialLinkController.text,
        'region': _selectedRegion,
        'avatar': _selectedAvatar,
        'location': {
          'latitude': _userLocation?.latitude,
          'longitude': _userLocation?.longitude,
        },
        'acceptedCGU': _acceptedCGU,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user', // Ajout du rôle par défaut
      });

      // Redirection vers un écran d'attente de vérification
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/splash_image.png',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Inscrivez-vous pour continuer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),

                // Username
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.blue.shade50),
                    labelText: 'Nom d’utilisateur',
                    labelStyle: TextStyle(color: Colors.blue.shade50),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Email
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.blue.shade50),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.blue.shade50),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade50),
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Colors.blue.shade50),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade50),
                    labelText: 'Confirmer le mot de passe',
                    labelStyle: TextStyle(color: Colors.blue.shade50),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                CheckboxListTile(
                  title: Text("J'accepte les CGU", style: TextStyle(color: Colors.white70)),
                  value: _acceptedCGU,
                  onChanged: (value) => setState(() => _acceptedCGU = value!),
                ),
                SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _register,
                  child: Text('S’inscrire', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Écran pour informer les utilisateurs de vérifier leur e-mail
class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isResending = false;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
  }

  Future<void> _checkEmailVerified() async {
    setState(() => _isCheckingVerification = true); // Indique que la vérification est en cours
    final user = FirebaseAuth.instance.currentUser!;
    await user.reload(); // Recharge les informations de l'utilisateur
    setState(() {
      _isVerified = user.emailVerified;
      _isCheckingVerification = false; // Vérification terminée
    });

    if (_isVerified) {
      // Redirige vers l'écran principal si l'e-mail est vérifié
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail de vérification renvoyé.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _logoutAndGoToLogin() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérification d\'e-mail')),
      body: Center(
        child: _isVerified
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Veuillez vérifier votre e-mail pour continuer.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResending ? null : _resendVerificationEmail,
              child: Text('Renvoyer l\'e-mail de vérification'),
            ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCheckingVerification
                      ? Colors.orangeAccent
                      : (_isVerified ? Colors.green : Colors.blue),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onPressed: _isCheckingVerification
                    ? null
                    : _checkEmailVerified,
                child: _isCheckingVerification
                    ? Text('Vérification en cours...')
                    : (_isVerified
                    ? Text(
                  'E-mail vérifié !',
                  style: TextStyle(color: Colors.white),
                )
                    : Text(
                  'J\'ai vérifié mon e-mail',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: _logoutAndGoToLogin,
              child: Text('Se déconnecter et aller à l\'écran de connexion'),
            ),
          ],
        ),
      ),
    );
  }
}