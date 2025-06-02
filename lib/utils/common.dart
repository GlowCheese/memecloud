// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:color/color.dart' as color_pkg;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/utils/images.dart';
import 'package:palette_generator/palette_generator.dart';

Future<Color?> getDominantColor(String imageUrl) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        getImageProvider(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );
  return paletteGenerator.dominantColor?.color;
}

Future<List<Color>> getPaletteColors(String imageUrl) async {
  final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        getImageProvider(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

  var colors = paletteGenerator.paletteColors;
  if (colors.isEmpty) {
    dev.log(
      'paletteGenerator failed to find paletteColors for: $imageUrl',
      level: 900,
    );
    return [Colors.grey.shade700];
  }

  return colors.map((e) => e.color).toList();
}

Color adjustColor(Color color, {double? s, double? l}) {
  final rgbColor = color_pkg.RgbColor(color.red, color.green, color.blue);

  final hslColor = rgbColor.toHslColor();

  final newHsl = color_pkg.HslColor(
    hslColor.h,
    s != null ? s * 100 : hslColor.s,
    l != null ? l * 100 : hslColor.l,
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

String normalizeSearchQueryString(String searchQuery) {
  return searchQuery.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
}

String getCurrentRoute(BuildContext context) {
  return GoRouter.of(context).routeInformationProvider.value.uri.toString();
}

Map<K, V> ignoreNullValuesOfMap<K, V>(Map<K, V> map) {
  return Map.fromEntries(map.entries.where((e) => e.value != null));
}

String prettyJson(Map json) {
  var encoder = const JsonEncoder.withIndent('  ');
  return encoder.convert(json);
}

List mixLists(List<List> lists) {
  final random = Random();
  final reversedLists = lists.map((l) => List.of(l.reversed)).toList();
  int sumLen = reversedLists.fold(0, (prev, l) => prev + l.length);
  List result = [];

  while (sumLen > 0) {
    double p = random.nextDouble();
    for (int i = 0; i < reversedLists.length; i++) {
      final list = reversedLists[i];
      if (list.isEmpty) continue;
      double q = list.length / sumLen;
      if (p <= q) {
        result.add(list.removeLast());
        break;
      }
      p -= q;
    }
    sumLen--;
  }
  return result;
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final minutesStr = minutes.toString().padLeft(2, '0');
  final secondsStr = seconds.toString().padLeft(2, '0');

  if (hours == 0) {
    return '$minutesStr:$secondsStr';
  }
  return '$hours:$minutesStr:$secondsStr';
}
