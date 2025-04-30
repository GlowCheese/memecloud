import 'dart:developer';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';

class ZingMp3Api {
  final ZingMp3Requester _requester = ZingMp3Requester();
  final ConnectivityStatus _connectivity = getIt<ConnectivityStatus>();

  Future<String?> fetchSongUrl(String songId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getSong(songId);

      // Bài hát chỉ dành cho tài khoản VIP, PRI
      if (resp['err'] == -1150) {
        getIt<ApiKit>().markSongAsVip(songId);
        return null;
      }
      return resp['data']['128']!;

    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3API failed to fetch song url: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchSongInfo(String songId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getInfoSong(songId);
      if (resp['err'] == -1023) return null;
      assert (resp['data']['encodeId'] == songId);
      return resp['data'];

    } catch(e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3API failed to fetch song info: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map> searchMulti(String keyword) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.searchMulti(keyword);
      return resp['data'];
    } catch(e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3API failed to search: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchHome({int page = 1}) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getHome(page: page);

      List data = resp['data']['items'];
      List<Map<String, dynamic>> resItems = [];

      for (var item in data) {
        if (item['sectionType'] == 'new-release') {
          item['items'] = item['items']['all'];
          resItems.add(item);
        } else if (item['sectionType'] == 'newReleaseChart') {
          resItems.add(item);
        }
      }
      return resItems;

    } catch(e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3API failed to fetch home: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
