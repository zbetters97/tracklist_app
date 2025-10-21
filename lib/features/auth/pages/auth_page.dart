import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/app/widget_tree.dart';
import 'package:tracklist_app/features/auth/widgets/auth_text_field.dart';
import 'package:tracklist_app/features/auth/widgets/reset_password_widget.dart';

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

  String? emailError;

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
        ResetPasswordWidget(),
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
      error: emailError,
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
    return IntrinsicWidth(
      child: FilledButton(
        onPressed: () => onSubmitPressed(),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0.0, 40.0),
          shape: LinearBorder(),
          backgroundColor: PRIMARY_COLOR,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 20),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
    clearForm();
    setState(() => isRegistration = !isRegistration);
  }

  void clearForm() {
    controllerDisplayName.clear();
    controllerUsername.clear();
    controllerEmail.clear();
    controllerPw.clear();
    controllerRePw.clear();
    emailError = null;
  }

  void onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) return;
    isRegistration ? submitRegister() : submitLogin();
  }

  void submitRegister() async {
    bool emailExists = await authService.value.checkIfEmailExists(email: controllerEmail.text);

    if (emailExists) {
      setState(() => emailError = "This email already exists.");
      return;
    }

    bool isValid = await authService.value.signUp(
      email: controllerEmail.text,
      password: controllerPw.text,
      displayname: controllerDisplayName.text,
      username: controllerUsername.text,
    );

    if (!isValid) {
      return;
    }

    clearForm();
    redirectToWelcomePage();
  }

  void submitLogin() async {
    bool isValid = await authService.value.signIn(email: controllerEmail.text, password: controllerPw.text);

    if (isValid) {
      redirectToWelcomePage();
    } else {
      setState(() => emailError = "Incorrect email or password.");
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
