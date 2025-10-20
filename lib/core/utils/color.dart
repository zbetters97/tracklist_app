import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tracklist_app/core/constants/constants.dart';

class ColorPalette {
  final Color light;
  final Color dark;
  final Color text;

  ColorPalette({required this.light, required this.dark, required this.text});
}

Future<ColorPalette> getColors(String imageUrl) async {
  final imageProvider = NetworkImage(imageUrl);

  final palette = await PaletteGenerator.fromImageProvider(imageProvider, maximumColorCount: 20);

  Color fallback = palette.colors.isNotEmpty ? palette.colors.first : BACKGROUND_COLOR;

  return ColorPalette(
    light: palette.mutedColor?.color ?? palette.lightMutedColor?.color ?? fallback,
    dark: palette.darkMutedColor?.color ?? palette.darkVibrantColor?.color ?? fallback,
    text: palette.lightVibrantColor?.color ?? palette.vibrantColor?.color ?? fallback,
  );
}
