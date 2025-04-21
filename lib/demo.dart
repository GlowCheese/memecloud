import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:memecloud/core/service_locator.dart';
import 'package:memecloud/data/apis/zingmp3.dart';

Future<void> demo() async {
  // final dio = serviceLocator<Dio>();
  // final cookieJar = serviceLocator<CookieJar>();

  // print(await cookieJar.loadForRequest(Uri.parse('https://zingmp3.vn')));

  // var resp = await dio.get('https://zingmp3.vn/api/v2/song/get/streaming?id=ZW79ZBE8&sig=d50b27caa158b8e5fa40986361a590744e9072765f979b3c396637a86922a5159fa0c0007f4ccf59898df95dee7b0d3a315679edfb03338a15bb5a07873824df&ctime=1744883363&version=1.6.34&apiKey=88265e23d4284f25963e6eedac8fbfa3');

  // print(resp.data);

  // print(await cookieJar.loadForRequest(Uri.parse('https://zingmp3.vn')));

  // resp = await dio.get('https://zingmp3.vn/api/v2/song/get/streaming?id=ZW79ZBE8&sig=d50b27caa158b8e5fa40986361a590744e9072765f979b3c396637a86922a5159fa0c0007f4ccf59898df95dee7b0d3a315679edfb03338a15bb5a07873824df&ctime=1744883363&version=1.6.34&apiKey=88265e23d4284f25963e6eedac8fbfa3');

  // print(resp.data);

  // print("done!");

  print(await ZingMp3.getSongUrl('ZW79ZBE8'));
}