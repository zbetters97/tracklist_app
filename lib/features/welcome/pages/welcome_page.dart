import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/auth/pages/auth_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void sendToSignupPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage(isRegistration: true)));
  }

  void sendToLoginPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage(isRegistration: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLogo(),
                const SizedBox(height: 40),
                buildGetStartedButton(context),
                const SizedBox(height: 10),
                buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: "TrackList logo",
          child: ClipRRect(
            child: Center(child: Image.asset(LOGO_IMG_LG, height: 300, width: 300, fit: BoxFit.cover)),
          ),
        ),
      ],
    );
  }

  Widget buildGetStartedButton(BuildContext context) {
    return FilledButton(
      onPressed: () => sendToSignupPage(context),

      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: PRIMARY_COLOR,
        foregroundColor: Colors.white,
        shape: const LinearBorder(),
        textStyle: const TextStyle(fontSize: 20),
      ),
      child: Text("Get Started"),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () => sendToLoginPage(context),
      style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 40.0)),
      child: Text(
        "Login",
        style: TextStyle(color: PRIMARY_COLOR, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
