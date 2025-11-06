import 'package:flutter/material.dart';

class EmptyText extends StatelessWidget {
  final String message;

  const EmptyText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 24),
        ),
      ),
    );
  }
}
