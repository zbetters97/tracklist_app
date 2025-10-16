import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/widget_tree.dart';
import 'package:tracklist_app/views/widgets/auth_text_field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.isRegistration});

  final bool isRegistration;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Register (true) or Login (false)
  late bool isRegistration;

  final _formKey = GlobalKey<FormState>();

  // Spacing constants
  final double kFieldSpacing = 10.0;
  final double kSectionSpacing = 25.0;

  // Default values for debugging purposes
  TextEditingController controllerDisplayName = TextEditingController(text: "Debug User");
  TextEditingController controllerUsername = TextEditingController(text: "debuguser");
  TextEditingController controllerEmail = TextEditingController(text: "debug@debug.com");
  TextEditingController controllerPw = TextEditingController(text: "password");
  TextEditingController controllerRePw = TextEditingController(text: "password");

  TextEditingController controllerForgotEmail = TextEditingController(text: "debug@debug.com");

  @override
  void initState() {
    super.initState();
    isRegistration = widget.isRegistration;
  }

  @override
  void dispose() {
    super.dispose();
    disposeForm();
  }

  void disposeForm() {
    controllerDisplayName.dispose();
    controllerUsername.dispose();
    controllerEmail.dispose();
    controllerPw.dispose();
    controllerRePw.dispose();
    controllerForgotEmail.dispose();
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
                  isRegistration ? buildRegisterFields() : buildLoginFields(),
                  SizedBox(height: kSectionSpacing),
                  buildSubmitButton(),
                  SizedBox(height: kSectionSpacing),
                  Text(isRegistration ? "Already have an account with us?" : "Don't have an account with us?"),
                  buildChangeAuthButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: isRegistration ? "Sign up for " : "Log into "),
          TextSpan(
            text: "TrackList",
            style: TextStyle(color: PRIMARY_COLOR),
          ),
        ],
      ),
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
        SizedBox(height: kFieldSpacing),
        buildForgotPasswordButton(),
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

  Widget buildForgotPasswordButton() {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 16),
        children: [
          TextSpan(text: "Forgot password? "),
          TextSpan(
            text: "Click here",
            style: TextStyle(color: PRIMARY_COLOR_LIGHT, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = buildForgotPasswordDialog,
          ),
        ],
      ),
    );
  }

  Future buildForgotPasswordDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reset your password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(height: 1, color: Colors.white),
          ],
        ),
        titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Email", style: const TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 5),
              TextFormField(
                controller: controllerForgotEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ("Please enter an email");
                  }
                  if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]+").hasMatch(value)) {
                    return ("Please anter a valid email");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: IntrinsicWidth(
                  child: FilledButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      // TODO: implement password reset
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0.0, 40.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text("Submit"),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: PRIMARY_COLOR_LIGHT, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        shape: LinearBorder(),
        backgroundColor: TERTIARY_COLOR,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget buildSubmitButton() {
    return IntrinsicWidth(
      child: FilledButton(
        onPressed: () {
          onSubmitPressed();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0.0, 40.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: PRIMARY_COLOR,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Text("Submit"),
      ),
    );
  }

  Widget buildChangeAuthButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(),
          textStyle: TextStyle(fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        onPressed: () => changeAuthMode(),
        child: Text(isRegistration ? "Log in" : "Sign up"),
      ),
    );
  }

  void changeAuthMode() {
    setState(() {
      isRegistration = !isRegistration;
    });
  }

  void clearForm() {
    controllerDisplayName.clear();
    controllerUsername.clear();
    controllerEmail.clear();
    controllerPw.clear();
    controllerRePw.clear();
    controllerForgotEmail.clear();
  }

  void onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) return;
    isRegistration ? submitRegister() : submitLogin();
  }

  void submitRegister() async {
    bool isValid = await authService.value.signUp(
      email: controllerEmail.text,
      password: controllerPw.text,
      displayname: controllerDisplayName.text,
      username: controllerUsername.text,
    );

    if (isValid) {
      clearForm();
      redirectToWelcomePage();
    } else {
      throw Exception("Registration failed, invalid credentials");
    }
  }

  void submitLogin() async {
    bool isValid = await authService.value.signIn(email: controllerEmail.text, password: controllerPw.text);

    if (isValid) {
      redirectToWelcomePage();
    } else {
      throw Exception("Login failed, invalid credentials");
    }
  }

  void redirectToWelcomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WidgetTree();
        },
      ),
      // Removes all previous pages in the stack
      (route) => false,
    );
  }
}
