import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';

Future<void> showAlertDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: TERTIARY_COLOR,
        shape: RoundedRectangleBorder(),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 12.0,
            children: [
              Text(
                message,
                style: TextStyle(color: PRIMARY_COLOR_LIGHT, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(backgroundColor: PRIMARY_COLOR),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
