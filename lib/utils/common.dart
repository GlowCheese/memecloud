import 'dart:developer';
import 'package:color/color.dart' as color_pkg;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<Color> getDominantColor(String imageUrl) async {
  final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
    CachedNetworkImageProvider(imageUrl),
    size: Size(200, 200),
    maximumColorCount: 20,
  );

  var color = paletteGenerator.dominantColor?.color;
  if (color != null) {
    return color;
  } else {
    log('paletteGenerator failed to find dominantColor for: $imageUrl', level: 900);
    return Colors.grey.shade700;
  }
}

Color adjustLightness(Color color, double targetLightness) {
  final rgbColor = color_pkg.RgbColor(color.red, color.green, color.blue);

  final hslColor = rgbColor.toHslColor();

  final newHsl = color_pkg.HslColor(
    hslColor.h,
    hslColor.s,
    targetLightness * 100,
  );

  final newRgb = newHsl.toRgbColor();

  return Color.fromARGB(
    color.alpha,
    newRgb.r.round(),
    newRgb.g.round(),
    newRgb.b.round(),
  );
}

Color getTextColor(Color bgColor) {
  return ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
    ? Colors.white
    : Colors.black;
}

String getCurrentRoute(BuildContext context) {
  return GoRouter.of(context).routeInformationProvider.value.uri.toString();
}

Map ignoreNullValuesOfMap(Map map) {
  return Map.fromEntries(
    map.entries.where((e) => e.value != null),
  ).cast<String, dynamic>();
}
