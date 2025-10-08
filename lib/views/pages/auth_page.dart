import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.isRegistration});

  final bool isRegistration;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(widget.isRegistration ? "Register" : "Login")],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
