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
    // TODO: implement initState
    super.initState();
    _checkAndSignInWithToken();
  }

  Future<void> _checkAndSignInWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    print('check');

    if (email != null && password != null) {
      await _logandoDadosSalvos(email, password);
    } else {
      print('dadosnulo');
    }
  }

  Future<void> _logandoDadosSalvos(String email, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');

      if (email != null && password != null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Container(
          color: Colors.blue,
          child: Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Image.asset('assets/images/logo1.png', fit: BoxFit.cover),
            ),
          ),
        )

      ),
    );


  }
}
