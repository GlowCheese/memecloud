import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/images.dart';

AppBar defaultAppBar(
  BuildContext context, {
  required String title,
  Object iconUri = 'assets/icons/listen.png',
}) {
  late final Widget icon;

  if (iconUri is String) {
    icon = Image.asset(iconUri, width: 30, height: 30);
  } else if (iconUri is IconData) {
    icon = Icon(iconUri, size: 30);
  } else {
    throw UnsupportedError(
      "Unsupported iconUri=$iconUri of type ${iconUri.runtimeType}",
    );
  }

  return AppBar(
    backgroundColor: Colors.transparent,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    leadingWidth: 60,
    leading: Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 30),
      child: icon,
    ),
    actions: [
      GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          backgroundImage: getImageProvider(
            getIt<ApiKit>().myProfile().avatarUrl,
          ),
        ),
      ),
      const SizedBox(width: 20),
    ],
  );
}
