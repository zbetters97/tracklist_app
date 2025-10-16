import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/views/pages/auth/auth_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: "tracklist logo",
                      child: ClipRRect(
                        child: Center(child: Image.asset(LOGO_IMG_LG, height: 300, width: 300, fit: BoxFit.cover)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage(isRegistration: true)),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                    shape: LinearBorder(),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: Text("Get Started"),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AuthPage(isRegistration: false);
                        },
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 40.0)),
                  child: Text(
                    "Login",
                    style: TextStyle(color: PRIMARY_COLOR, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
