import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff2c6a46),
      surfaceTint: Color(0xff2c6a46),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffb0f1c3),
      onPrimaryContainer: Color(0xff0e512f),
      secondary: Color(0xff4f6354),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd1e8d5),
      onSecondaryContainer: Color(0xff374b3d),
      tertiary: Color(0xff3b6470),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbeeaf7),
      onTertiaryContainer: Color(0xff214c57),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff6fbf3),
      onSurface: Color(0xff181d19),
      onSurfaceVariant: Color(0xff414942),
      outline: Color(0xff717971),
      outlineVariant: Color(0xffc0c9c0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322d),
      inversePrimary: Color(0xff94d5a8),
      primaryFixed: Color(0xffb0f1c3),
      onPrimaryFixed: Color(0xff00210f),
      primaryFixedDim: Color(0xff94d5a8),
      onPrimaryFixedVariant: Color(0xff0e512f),
      secondaryFixed: Color(0xffd1e8d5),
      onSecondaryFixed: Color(0xff0c1f13),
      secondaryFixedDim: Color(0xffb6ccb9),
      onSecondaryFixedVariant: Color(0xff374b3d),
      tertiaryFixed: Color(0xffbeeaf7),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xffa3cddb),
      onTertiaryFixedVariant: Color(0xff214c57),
      surfaceDim: Color(0xffd6dbd4),
      surfaceBright: Color(0xfff6fbf3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ee),
      surfaceContainer: Color(0xffeaefe8),
      surfaceContainerHigh: Color(0xffe5eae2),
      surfaceContainerHighest: Color(0xffdfe4dd),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff94d5a8),
      surfaceTint: Color(0xff94d5a8),
      onPrimary: Color(0xff00391e),
      primaryContainer: Color(0xff0e512f),
      onPrimaryContainer: Color(0xffb0f1c3),
      secondary: Color(0xffb6ccb9),
      onSecondary: Color(0xff213527),
      secondaryContainer: Color(0xff374b3d),
      onSecondaryContainer: Color(0xffd1e8d5),
      tertiary: Color(0xffa3cddb),
      onTertiary: Color(0xff023640),
      tertiaryContainer: Color(0xff214c57),
      onTertiaryContainer: Color(0xffbeeaf7),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffc0c9c0),
      outline: Color(0xff8a938b),
      outlineVariant: Color(0xff414942),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe4dd),
      inversePrimary: Color(0xff2c6a46),
      primaryFixed: Color(0xffb0f1c3),
      onPrimaryFixed: Color(0xff00210f),
      primaryFixedDim: Color(0xff94d5a8),
      onPrimaryFixedVariant: Color(0xff0e512f),
      secondaryFixed: Color(0xffd1e8d5),
      onSecondaryFixed: Color(0xff0c1f13),
      secondaryFixedDim: Color(0xffb6ccb9),
      onSecondaryFixedVariant: Color(0xff374b3d),
      tertiaryFixed: Color(0xffbeeaf7),
      onTertiaryFixed: Color(0xff001f26),
      tertiaryFixedDim: Color(0xffa3cddb),
      onTertiaryFixedVariant: Color(0xff214c57),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b36),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff181d19),
      surfaceContainer: Color(0xff1c211d),
      surfaceContainerHigh: Color(0xff262b27),
      surfaceContainerHighest: Color(0xff313631),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );
}
