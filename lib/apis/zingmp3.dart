import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';


// ignore: constant_identifier_names
const String BASE_URL = 'https://714ep0-3000.csb.app';


class ZingMp3Api {
  final Dio dio;
  ZingMp3Api({required this.dio});

  Future<Response> _sendRequest(String endPoint, {
    Map<String, dynamic>? params,
    String baseUrl = '$BASE_URL/api'
  }) async {
    assert(endPoint == '' || endPoint.startsWith('/'));
    return await dio.get('$baseUrl$endPoint', queryParameters: params);
  }

  Future<Either> fetchSongUrl(String id) async {
    try {
      var resp = await _sendRequest('/song', params: {'id': id});
      resp = await _sendRequest('', baseUrl: resp.data['url']);
      final data = resp.data['data'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');
      return Right(data['128']);
    } catch (e, stackTrace) {
      log('ZingMp3API: Failed to fetch song url', stackTrace: stackTrace, level: 1000);
      return Left(e);
    }
  }

  Future<Either> fetchSongInfo(String id) async {
    try {
      final resp = await _sendRequest('/infosong', params: {'id': id});
      Map data = resp.data['data'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');

      assert(id == data['encodeId'], 'Expect id == encodeId, got $id == ${data['encodeId']}');
      return Right(data);
    } catch(e, stackTrace) {
      log('ZingMp3API: Failed to fetch song info', stackTrace: stackTrace, level: 1000);
      return Left(e);
    }
  }

  Future<Either> search(String keyword) async {
    try {
      final resp = await _sendRequest('/search', params: {'keyword': keyword});
      Map data = resp.data['data'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');
      return Right(data);
    } catch(e, stackTrace) {
      log('ZingMp3API: Failed to search', stackTrace: stackTrace, level: 1000);
      return Left(e);
    }
  }
}
