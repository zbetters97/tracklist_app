import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
  }
}
