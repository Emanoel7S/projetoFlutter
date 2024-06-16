import 'package:flutter/material.dart';

class CustomEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscure;
  final bool email;
  final IconData icon;
  final String emptyErrorMessage;
  final String invalidErrorMessage;

  const CustomEmailField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.obscure,
    required this.icon,
    required this.emptyErrorMessage,
    required this.invalidErrorMessage, required this.email,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:email?TextInputType.emailAddress:TextInputType.text ,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.blue),
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.1),
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return emptyErrorMessage;
        }
        if (email){
          if (!value.contains('@')) {
            return invalidErrorMessage;
          }
        }else{
          if (value.length < 6) {
            return invalidErrorMessage;
          }


        }

        return null;
      },
    );
  }
}
