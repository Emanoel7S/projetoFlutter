import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdfscanner/screens/login.dart';
import 'package:pdfscanner/widget/text_form_field.dart';

import '../widget/elevated_button.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Image.asset('assets/images/logo3.png', fit: BoxFit.cover),
                width: 300,
                height: 300,
              ),
              CustomEmailField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Digite seu email',
                emptyErrorMessage: 'Por favor, insira seu email',
                invalidErrorMessage: 'Por favor, insira um email válido',
                icon: Icons.email,
                obscure: false,
                email: true,
              ),
              const SizedBox(height: 16),
              CustomEmailField(
                controller: _passwordController,
                labelText: 'Senha',
                hintText: 'Digite sua senha',
                emptyErrorMessage: 'Por favor, insira sua senha',
                invalidErrorMessage: 'A senha deve ter pelo menos 6 caracteres',
                icon: Icons.check_circle_outline,
                obscure: true,
                email: false,
              ),
              const SizedBox(height: 16),
              CustomEmailField(
                controller: _confirmPasswordController,
                labelText: 'Confirmar Senha',
                hintText: 'Confirme sua senha',
                emptyErrorMessage: 'Por favor, confirme sua senha',
                invalidErrorMessage: 'As senhas não coincidem',
                icon: Icons.check_circle_outline,
                obscure: true,
                email: false,
              ),
              const SizedBox(height: 32),
              CustomElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _createUserWithEmailAndPassword();
                  }
                },
                text: 'Cadastrar',
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text('Já possui uma conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createUserWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }  catch (e) {
      String? message;
      message = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('Ocorreu um erro. Por favor, tente novamente.$message')),
      );
    }
  }
}
