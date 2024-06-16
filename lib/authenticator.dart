import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home.dart';
import 'screens/login.dart';

class Authenticar extends StatefulWidget {
  const Authenticar({super.key});

  @override
  State<Authenticar> createState() => _AuthenticarState();
}

class _AuthenticarState extends State<Authenticar> {
  @override
  void initState() {
    super.initState();
    _checkAndSignInWithToken();
  }

  Future<void> _checkAndSignInWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    print('check');

    await Future.delayed(Duration(seconds: 2)); // Delay for smoother transition

    if (email != null && password != null) {
      print('$email e $password');
      await _logandoDadosSalvos(email, password);
    } else {
      print('$email else $password');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  Future<void> _logandoDadosSalvos(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/images/logo1.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(), // Progress indicator
              ],
            ),
          ),
        ),
      ),
    );
  }
}
