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
    checkAndSignInWithToken();
  }

  Future<void> checkAndSignInWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    print('check');

    await Future.delayed(const Duration(seconds: 1));

    if (email != null && password != null) {
      print('$email e $password');
      await logandoDadosSalvos(email, password);
    } else {
      print('$email else $password');
      if(mounted){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }

    }
  }

  Future<void> logandoDadosSalvos(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }  catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('$e')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );

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
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
