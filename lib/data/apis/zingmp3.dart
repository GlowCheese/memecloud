import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:memecloud/core/service_locator.dart';

const String BASE_URL = 'https://714ep0-3000.csb.app';
Future<Response> sendRequest(
  Dio dio, String endPoint,
  {
    Map<String, dynamic>? params,
    String baseUrl = '$BASE_URL/api'
  }
) async {
  assert(endPoint == '' || endPoint.startsWith('/'));
  return await dio.get('$baseUrl$endPoint', queryParameters: params);
}

class ZingMp3 {
  static Future<String?> getSongUrl(String id) async {
    // test: https://714ep0-3000.csb.app/api/song?id=Z78BZ0D7

    final dio = serviceLocator<Dio>();
    try {
      var resp = await sendRequest(dio, '/song', params: {'id': id});
      resp = await sendRequest(dio, '', baseUrl: resp.data['url']);
      return resp.data['data']['128'];
    } catch (e, stackTrace) {
      log('Lỗi mẹ rồi: $e', stackTrace: stackTrace, level: 1000);
      return null;
    }
  }

  // static Future<dynamic> getSongInfo(String id) async {
  //   // test: https://714ep0-3000.csb.app/api/infosong?id=Z78BZ0D7

  //   var url = apiUrl('/infosong', {'id': id});
  //   var response = await http.get(url);

  //   try {
  //     var jsonData = jsonDecode(response.body);
  //     return jsonData['data'];
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
