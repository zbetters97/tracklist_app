import 'package:flutter/material.dart';
import 'package:tracklist_app/views/widgets/auth_text_field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.isRegistration});

  final bool isRegistration;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  // Spacing constants
  final double kFieldSpacing = 10.0;
  final double kSectionSpacing = 20.0;

  // Default values for debugging purposes
  TextEditingController controllerDisplayName = TextEditingController();
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPw = TextEditingController();
  TextEditingController controllerRePw = TextEditingController();

  void disposeForm() {
    controllerDisplayName.dispose();
    controllerUsername.dispose();
    controllerEmail.dispose();
    controllerPw.dispose();
    controllerRePw.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(kSectionSpacing),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildHeader(),
                  SizedBox(height: kSectionSpacing),
                  widget.isRegistration ? buildRegisterFields() : buildLoginFields(),
                  SizedBox(height: kSectionSpacing),
                  buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text(
      widget.isRegistration ? "Sign up for TrackList" : "Log into TrackList",
      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget buildRegisterFields() {
    return Column(
      children: [
        buildDisplayNameField(),
        SizedBox(height: kFieldSpacing),
        buildUsernameField(),
        SizedBox(height: kFieldSpacing),
        buildEmailField(),
        SizedBox(height: kFieldSpacing),
        buildPasswordField(),
        SizedBox(height: kFieldSpacing),
        buildRePasswordField(),
      ],
    );
  }

  Widget buildLoginFields() {
    return Column(
      children: [
        buildEmailField(),
        SizedBox(height: kFieldSpacing),
        buildPasswordField(),
      ],
    );
  }

  Widget buildDisplayNameField() {
    return AuthTextField(
      label: "Display Name",
      controller: controllerDisplayName,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a display name";
        }
        if (value.length < 3) {
          return "Display name must be at least 3 characters";
        }
        return null;
      },
    );
  }

  Widget buildUsernameField() {
    return AuthTextField(
      label: "Username",
      controller: controllerUsername,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a username";
        }
        if (value.length < 3) {
          return "Username must be at least 3 characters";
        }
        return null;
      },
    );
  }

  Widget buildEmailField() {
    return AuthTextField(
      label: "Email",
      controller: controllerEmail,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please enter an email");
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]+").hasMatch(value)) {
          return ("Please anter a valid email");
        }
        return null;
      },
    );
  }

  Widget buildPasswordField() {
    return AuthTextField(
      label: "Password",
      controller: controllerPw,
      keyboardType: TextInputType.visiblePassword,
      isHidden: true,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please enter a password");
        }
        if (value.length < 6) {
          return ("Password must be at least 6 characters");
        }
        return null;
      },
    );
  }

  Widget buildRePasswordField() {
    return AuthTextField(
      label: "Re-enter Password",
      controller: controllerRePw,
      keyboardType: TextInputType.visiblePassword,
      isHidden: true,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please re-enter the password");
        }
        if (value != controllerPw.text) {
          return ("Passwords do not match");
        }
        return null;
      },
    );
  }

  Widget buildSubmitButton() {
    return FilledButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 40.0)),
      child: Text("Submit"),
    );
  }
}
