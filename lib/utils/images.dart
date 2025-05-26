import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget getImage(String url, double size, {BoxFit fit = BoxFit.cover}) {
  if (url.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: fit,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Icon(Icons.error),
    );
  } else {
    return Image.asset(
      url,
      width: size,
      height: size,
      fit: fit,
    );
  }
}

ImageProvider getImageProvider(String url) {
  if (url.startsWith('http')) {
    return CachedNetworkImageProvider(url);
  } else if (url.startsWith('/')) {
    return FileImage(File(url));
  } else {
    return AssetImage(url);
  }
}
