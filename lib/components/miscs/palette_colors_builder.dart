import 'package:flutter/material.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';

Widget paletteColorsWidgetBuider(
  String imageUrl,
  Widget Function(List<Color> paletteColors) func,
) {
  return defaultFutureBuilder(
    future: getPaletteColors(imageUrl),
    onData: (context, data) {
      final paletteColors = data;
      return func(paletteColors);
    },
  );
}
