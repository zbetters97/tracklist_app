import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
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
  TextEditingController controllerDisplayName = TextEditingController();
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPw = TextEditingController();
  TextEditingController controllerRePw = TextEditingController();

  bool rememberMe = false;

  String? emailError;

  @override
  void initState() {
    super.initState();
    isRegistration = widget.isRegistration;
    initHive();
  }

  Future<void> initHive() async {
    // Initialize Hive to store values
    await Hive.initFlutter();

    if (isRegistration) return;

    final box = await Hive.openBox('user_settings');

    setState(() {
      rememberMe = box.get('remember_me', defaultValue: false) as bool;
      controllerEmail.text = box.get('email', defaultValue: '') as String;
    });
  }

  @override
  void dispose() {
    disposeForm();
    super.dispose();
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
    String switchAuthText = isRegistration ? "Already have an account with us?" : "Don't have an account with us?";

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
                  Text(switchAuthText),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: kFieldSpacing,
      children: [
        buildDisplayNameField(),
        buildUsernameField(),
        buildEmailField(),
        buildPasswordField(),
        buildRePasswordField(),
      ],
    );
  }

  Widget buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: kFieldSpacing,
      children: [buildEmailField(), buildPasswordField(), buildRememberCheckBox(), ResetPasswordWidget()],
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

  Widget buildRememberCheckBox() {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          activeColor: PRIMARY_COLOR,
          checkColor: Colors.white,
          onChanged: (value) => setState(() => rememberMe = value!),
        ),
        Text(
          "Remember me",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
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
      final box = Hive.box('user_settings');

      if (rememberMe) {
        await box.put('remember_me', rememberMe);
        await box.put('email', controllerEmail.text);
      } else {
        await box.clear();
      }

      redirectToWelcomePage();
    } else {
      setState(() => emailError = "Incorrect email or password.");
    }
  }

  void redirectToWelcomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WidgetTree()),
      // Removes all previous pages in the stack
      (route) => false,
    );
  }
}
