import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

AppBar defaultAppBar(
  BuildContext context, {
  required String title,
  Object iconUri = 'assets/icons/listen.png'
  // Widget iconUri = const Image.asset(, width: 30, height: 30),
}) {
  late final Widget icon;
  if (iconUri is String) {
    icon = Image.asset(iconUri, width: 30, height: 30);
  } else if (iconUri is IconData) {
    icon = Icon(iconUri, size: 30);
  } else {
    throw UnsupportedError("Unsupported iconUri=$iconUri of type ${iconUri.runtimeType}");
  }

  var adaptiveTheme = AdaptiveTheme.of(context);
  return AppBar(
    backgroundColor: Colors.transparent,
    title: Text(
      title,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    leadingWidth: 60,
    leading: Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 30),
      child: icon,
    ),
    actions: [
      GestureDetector(
        onTap: () => adaptiveTheme.toggleThemeMode(useSystem: false),
        child: Icon(
          adaptiveTheme.mode.isDark
              ? Icons.light_mode
              : Icons.dark_mode_outlined,
          color: Colors.white,
        ),
      ),
      SizedBox(width: 4),
      IconButton(
        color: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      SizedBox(width: 4),
      GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuAqi5s1FOI-T3qoE_2HD1avj69-gvq2cvIw&s',
          ),
        ),
      ),
      SizedBox(width: 12),
    ],
  );
}
