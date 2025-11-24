import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/alert_dialog.dart';

class ResetPasswordWidget extends StatefulWidget {
  const ResetPasswordWidget({super.key});

  @override
  State<ResetPasswordWidget> createState() => _ResetPasswordWidgetState();
}

class _ResetPasswordWidgetState extends State<ResetPasswordWidget> {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 16),
        children: [
          TextSpan(text: "Forgot password? "),
          TextSpan(
            text: "Click here",
            style: TextStyle(color: PRIMARY_COLOR_LIGHT, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = _buildForgotPasswordDialog,
          ),
        ],
      ),
    );
  }

  Future _buildForgotPasswordDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        TextEditingController controllerForgotEmail = TextEditingController();
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> resetPassword(BuildContext context, String email) async {
              if (!formKey.currentState!.validate()) return;

              bool emailExists = await authService.value.checkIfEmailExists(email: email);

              if (!emailExists) {
                setState(() => errorText = "This email does not exist.");
                return;
              }

              bool result = await authService.value.sendPasswordReset(email: email);

              // Check if context has been disposed before continuing
              if (!context.mounted) return;

              if (result) {
                await showAlertDialog(context, "Reset email sent!");

                // Check again if context is still mounted
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                setState(() => errorText = "Error! Please try again.");
              }
            }

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Reset your password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(height: 1, color: Colors.white),
                ],
              ),
              titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Email", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: controllerForgotEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          errorText: errorText,
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
                      const SizedBox(height: 16),
                      Center(
                        child: IntrinsicWidth(
                          child: FilledButton(
                            onPressed: () => resetPassword(context, controllerForgotEmail.text),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(0.0, 40.0),
                              shape: RoundedRectangleBorder(),
                              backgroundColor: PRIMARY_COLOR,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontSize: 20),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            child: Text("Submit"),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            );
          },
        );
      },
    );
  }
}
