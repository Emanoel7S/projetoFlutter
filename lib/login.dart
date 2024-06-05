import 'package:flutter/material.dart';
import 'package:pdfscanner/home.dart';

import 'cadastro.dart';
import 'widget/text_form_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: Image.asset('assets/images/logo1.png',fit: BoxFit.cover,),width: 300,height: 300,),
              Form(child:
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InputFormulario(controller: _emailController, labelText: 'Email', hintText: 'Digite seu email'),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InputFormulario(controller: _emailController, labelText: 'Senha', hintText: 'Digite sua senha'),
                    ),
                    TextButton(onPressed: (){}, child: Text('Esqueceu a senha?',style: TextStyle(color: Colors.blueGrey[200]),)),

                    ElevatedButton(onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));

                    }, child: const Text('Login',style: TextStyle(color: Colors.blueGrey),)),
                    TextButton(onPressed: cadastro, child: Text('Cadastre-se aqui'))
                  ],
                ),
              )




              ) ,
            ],
          )

        ),
      ),
    );
  }

  cadastro() {
    Navigator.push(context,MaterialPageRoute(builder: (context) => Cadastro()));
  }
}
