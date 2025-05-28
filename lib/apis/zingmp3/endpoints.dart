import 'dart:developer';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';
import 'package:memecloud/apis/others/connectivity.dart';

class ZingMp3Api {
  final ZingMp3Requester _requester = getIt<ZingMp3Requester>();
  final ConnectivityStatus _connectivity = getIt<ConnectivityStatus>();

    Future<Map<String, String>> fetchSongUrls(String songId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getSong(songId);

      // // Bài hát chỉ dành cho tài khoản VIP, PRI
      // if (resp['err'] == -1150) return null;

      final urls = Map.from(resp['data']);
      Map<String, String> res = {};
      for (var entry in urls.entries) {
        if (entry.value != "VIP") {
          res[entry.key] = entry.value;
        }
      }
      return res;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to fetch song urls: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<String> fetchSongUrl(String songId, [String quality="320"]) async {
    final urls = await fetchSongUrls(songId);
    return urls[quality] ?? urls['320'] ?? urls['128']!;
  }

  Future<Map<String, dynamic>?> fetchSongInfo(String songId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getInfoSong(songId);
      if (resp['err'] == -1023) return null;
      assert(resp['data']['encodeId'] == songId);
      return resp['data'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to fetch song info: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchPlaylistInfo(playlistId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getDetailPlaylist(playlistId);
      if (resp['err'] == -1031) return null;
      assert(resp['data']['encodeId'] == playlistId);
      return resp['data'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'ZingMp3Api failed to fetch playlist info: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchArtistInfo(String artistAlias) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getArtist(artistAlias);
      if (resp['err'] == -108) return null;
      assert(resp['data']['alias'] == artistAlias);
      return resp['data'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'ZingMp3Api failed to fetch artist info: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map> searchMulti(String keyword) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.multiSearch(keyword);
      return resp['data'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to search: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchSearchSuggestions(String keyword) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getSearchSuggestions(keyword);
      return List.castFrom<dynamic, Map<String, dynamic>>(resp['data']['items']);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to fetch search suggestions: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List?> searchSongs(String keyword, {required int page}) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.searchSongs(keyword, page: page);
      return resp['data']['items'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to search: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List?> searchArtists(String keyword, {required int page}) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.searchArtists(keyword, page: page);
      return resp['data']['items'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to search: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List?> searchPlaylists(String keyword, {required int page}) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.searchPlaylists(keyword, page: page);
      return resp['data']['items'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to search: $e',
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
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'ZingMp3Api failed to fetch home: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map> fetchLyric(String songId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getLyric(songId);
      return ignoreNullValuesOfMap({
        'lyric': resp['data']['lyric'],
        'file': resp['data']['file'],
      });
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'ZingMp3Api failed to fetch lyric for $songId: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchWeekChart(String chartId) async {
    try {
      _connectivity.ensure();
      final resp = await _requester.getWeekChart(chartId);
      return resp['data'];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'ZingMp3Api failed to fetch week chart: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchVpopWeekChart() {
    return _fetchWeekChart('IWZ9Z08I');
  }

  Future<Map<String, dynamic>> fetchUsukWeekChart() {
    return _fetchWeekChart('IWZ9Z0BW');
  }

  Future<Map<String, dynamic>> fetchKpopWeekChart() {
    return _fetchWeekChart('IWZ9Z0BO');
  }
}
