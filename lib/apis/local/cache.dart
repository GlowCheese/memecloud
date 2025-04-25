import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalCache {
  final Directory dir;
  LocalCache._(this.dir);
  
  static Future<LocalCache> create() async {
    final dir = await getTemporaryDirectory();
    return LocalCache._(dir);
  }
}