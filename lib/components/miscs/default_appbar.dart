import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

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
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    leadingWidth: 60,
    leading: Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 30),
      child: icon,
    ),
    actions: [
      IconButton(
        color: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      SizedBox(width: 8),
      GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            getIt<ApiKit>().myProfile().avatarUrl ??
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSuAqi5s1FOI-T3qoE_2HD1avj69-gvq2cvIw&s',
          ),
        ),
      ),
      SizedBox(width: 20),
    ],
  );
}
