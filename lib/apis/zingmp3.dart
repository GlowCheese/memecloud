import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/core/getit.dart';


// ignore: constant_identifier_names
const String BASE_URL = 'https://714ep0-3000.csb.app';
// const String BASE_URL = 'https://82lhmr-3000.csb.app';


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

  Future<Either<String, String?>> fetchSongUrl(String id) async {
    try {
      var resp = await _sendRequest('/song', params: {'id': id});
      debugPrint('Response 1: ${resp.data}');
      resp = await _sendRequest('', baseUrl: resp.data['url']);
      final data = resp.data['data'];
      debugPrint('Response 2: ${resp.data}');
      if (resp.data['err'] == -1150) {
        // Bài hát chỉ dành cho tài khoản VIP, PRI
        getIt<SupabaseSongsApi>().addSongToVip(id);
        return Right(null);
      }
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');
      return Right(data['128']);
    } catch (e, stackTrace) {
      log('ZingMp3API: Failed to fetch song url: $e.', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, dynamic>> fetchSongInfo(String id) async {
    try {
      final resp = await _sendRequest('/infosong', params: {'id': id});
      Map data = resp.data['data'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');

      assert(id == data['encodeId'], 'Expect id == encodeId, got $id == ${data['encodeId']}');
      return Right(data);
    } catch(e, stackTrace) {
      log('ZingMp3API: Failed to fetch song info', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, dynamic>> search(String keyword) async {
    try {
      final resp = await _sendRequest('/search', params: {'keyword': keyword});
      Map data = resp.data['data'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');
      return Right(data);
    } catch(e, stackTrace) {
      log('ZingMp3API: Failed to search', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, List<Map>>>> home({int page = 0}) async {
    try {
      final resp = await _sendRequest('/home', params: {'page': page});
      List data = resp.data['data']['items'];
      assert(resp.data['err'] == 0, 'Unexpected error code: ${resp.data['err']}');
      
      List<Map> resItems = [];

      for (var item in data) {
        if (item['sectionType'] == 'new-release') {
          item['items'] = item['items']['all'];
          resItems.add(item);
        }
        else if (item['sectionType'] == 'newReleaseChart') {
          resItems.add(item);
        }
      }

      return Right({'items': resItems});

    } catch(e, stackTrace) {
      log('ZingMp3API: Failed to search', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }
}
