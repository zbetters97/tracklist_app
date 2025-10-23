import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.isHidden = false,
    this.validator,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool? isHidden;
  final String? Function(String?)? validator;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isHidden!,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            error: error != null ? Text(error!, style: const TextStyle(color: Colors.red)) : null,
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        ),
      ],
    );
  }
}
