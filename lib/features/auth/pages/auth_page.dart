import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/app/widget_tree.dart';
import 'package:tracklist_app/features/auth/widgets/auth_text_field.dart';
import 'package:tracklist_app/features/auth/widgets/reset_password_widget.dart';

class AuthPage extends StatefulWidget {
  final bool isRegistration;

  const AuthPage({super.key, required this.isRegistration});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Register (true) or Login (false)
  late bool _isRegistration;

  final _formKey = GlobalKey<FormState>();

  // Spacing constants
  final double _kFieldSpacing = 10.0;
  final double _kSectionSpacing = 25.0;

  final TextEditingController _controllerDisplayName = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPw = TextEditingController();
  final TextEditingController _controllerRePw = TextEditingController();

  bool _rememberMe = false;

  String? _emailError;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _isRegistration = widget.isRegistration;
    _initHive();
  }

  @override
  void dispose() {
    _disposeForm();
    super.dispose();
  }

  Future<void> _initHive() async {
    // Initialize Hive to store values
    await Hive.initFlutter();

    if (_isRegistration) return;

    final box = await Hive.openBox('user_settings');

    setState(() {
      _rememberMe = box.get('remember_me', defaultValue: false) as bool;
      _controllerEmail.text = box.get('email', defaultValue: '') as String;
    });
  }

  void _changeAuthMode() {
    _clearForm();
    setState(() => _isRegistration = !_isRegistration);
  }

  void _onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) return;
    _isRegistration ? _submitRegister() : _submitLogin();
  }

  void _submitRegister() async {
    bool emailExists = await authService.value.checkIfEmailExists(email: _controllerEmail.text);

    if (emailExists) {
      setState(() => _emailError = "This email already exists.");
      return;
    }

    bool isValid = await authService.value.signUp(
      email: _controllerEmail.text,
      password: _controllerPw.text,
      displayname: _controllerDisplayName.text,
      username: _controllerUsername.text,
    );

    if (!isValid) {
      return;
    }

    _clearForm();
    _redirectToWelcomePage();
  }

  void _submitLogin() async {
    String errorCode = await authService.value.signIn(email: _controllerEmail.text, password: _controllerPw.text);

    if (errorCode != "Success!") {
      setState(() => _loginError = errorCode);
      return;
    }

    final box = Hive.box('user_settings');

    // Remember me box checked
    if (_rememberMe) {
      // Store login details
      await box.put('remember_me', _rememberMe);
      await box.put('email', _controllerEmail.text);
    } else {
      // Clear stored values
      await box.clear();
    }

    _redirectToWelcomePage();
  }

  void _redirectToWelcomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WidgetTree()),
      // Removes all previous pages in the stack
      (route) => false,
    );
  }

  void _clearForm() {
    _controllerDisplayName.clear();
    _controllerUsername.clear();
    _controllerEmail.clear();
    _controllerPw.clear();
    _controllerRePw.clear();
    _rememberMe = false;
    _emailError = null;
    _loginError = null;
  }

  void _disposeForm() {
    _controllerDisplayName.dispose();
    _controllerUsername.dispose();
    _controllerEmail.dispose();
    _controllerPw.dispose();
    _controllerRePw.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String switchAuthText = _isRegistration ? "Already have an account with us?" : "Don't have an account with us?";

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(_kSectionSpacing),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  SizedBox(height: _kSectionSpacing),
                  _isRegistration ? _buildRegisterFields() : _buildLoginFields(),
                  SizedBox(height: _kSectionSpacing),
                  _buildSubmitButton(),
                  SizedBox(height: _kSectionSpacing),
                  Text(switchAuthText),
                  _buildChangeAuthButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: _isRegistration ? "Sign up for " : "Log into "),
          TextSpan(
            text: "TrackList",
            style: TextStyle(color: PRIMARY_COLOR),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: _kFieldSpacing,
      children: [
        _buildDisplayNameField(),
        _buildUsernameField(),
        _buildEmailField(),
        _buildPasswordField(),
        _buildRePasswordField(),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: _kFieldSpacing,
      children: [
        _buildEmailField(),
        _buildPasswordField(),
        _buildRememberCheckBox(),
        if (_loginError != null) Text(_loginError ?? "", style: TextStyle(color: Colors.red)),
        ResetPasswordWidget(),
      ],
    );
  }

  Widget _buildDisplayNameField() {
    return AuthTextField(
      label: "Display Name",
      controller: _controllerDisplayName,
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

  Widget _buildUsernameField() {
    return AuthTextField(
      label: "Username",
      controller: _controllerUsername,
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

  Widget _buildEmailField() {
    return AuthTextField(
      label: "Email",
      controller: _controllerEmail,
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
      error: _emailError,
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField(
      label: "Password",
      controller: _controllerPw,
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

  Widget _buildRePasswordField() {
    return AuthTextField(
      label: "Re-enter Password",
      controller: _controllerRePw,
      keyboardType: TextInputType.visiblePassword,
      isHidden: true,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please re-enter the password");
        }
        if (value != _controllerPw.text) {
          return ("Passwords do not match");
        }
        return null;
      },
    );
  }

  Widget _buildRememberCheckBox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          activeColor: PRIMARY_COLOR,
          checkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (value) => setState(() => _rememberMe = value!),
        ),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            "Remember me",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return IntrinsicWidth(
      child: FilledButton(
        onPressed: () => _onSubmitPressed(),
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

  Widget _buildChangeAuthButton() {
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
        onPressed: () => _changeAuthMode(),
        child: Text(_isRegistration ? "Log in" : "Sign up"),
      ),
    );
  }
}
