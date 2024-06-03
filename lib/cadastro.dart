import 'package:flutter/material.dart';

import 'login.dart';
import 'widget/text_form_field.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
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
                SizedBox(child: Image.asset('assets/images/logo3.png',fit: BoxFit.cover,),width: 300,height: 300,),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputFormulario(controller: _emailController, labelText: 'Senha', hintText: 'Confirme a senha'),
                      ),
                      TextButton(onPressed: (){}, child: Text('Esqueceu a senha?',style: TextStyle(color: Colors.blueGrey[200]),)),

                      ElevatedButton(
                          onPressed: cadastrar, child: const Text('Cadastro',style: TextStyle(color: Colors.blueGrey),)),
                      // TextButton(onPressed: entrar, child: Text('Entrar'))
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

  entrar() {

      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Login()));

  }

  void cadastrar() {
  }
}
