import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  
  const NameField({
    super.key,
    required this.controller,
    this.errorText,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nombre completo',
        prefixIcon: const Icon(Icons.person),
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu nombre';
        }
        return null;
      },
    );
  }
}