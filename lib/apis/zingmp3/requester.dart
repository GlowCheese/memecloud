import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memecloud/core/getit.dart';

class ZingMp3Requester {
  final Dio dio = getIt<Dio>();

  final _version = "1.13.13";
  final _baseUrl = "https://zingmp3.vn";
  final _apiKey = dotenv.env['ZINGMP3_API_KEY'].toString();
  final _secretKey = dotenv.env['ZINGMP3_SECRET_KEY'].toString();
  get _cTime => (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  String _getHash256(String str) {
    return sha256.convert(utf8.encode(str)).toString();
  }

  String _getHmac512(String str, String key) {
    var hmac = Hmac(sha512, utf8.encode(key));
    var digest = hmac.convert(utf8.encode(str));
    return digest.toString();
  }

  String _hashParam(
    String path, {
    String? id,
    String? type,
    int? page,
    int? count,
  }) {
    String res = "";
    if (count != null) res += 'count=$count';
    res += 'ctime=$_cTime';
    if (id != null) res += 'id=$id';
    if (page != null) res += 'page=$page';
    if (type != null) res += 'type=$type';
    res += 'version=$_version';
    return _getHmac512(path + _getHash256(res), _secretKey);
  }

  Map<String, dynamic> _prepParam(
    String path, {
    String? id,
    String? type,
    int? page,
    int? count,
    Map<String, dynamic>? extra,
  }) {
    Map<String, dynamic> params = extra ?? {};
    if (id != null) params['id'] = id;
    if (type != null) params['type'] = type;
    if (page != null) params['page'] = page;
    if (count != null) params['count'] = count;
    params['sig'] = _hashParam(
      path,
      id: id,
      type: type,
      page: page,
      count: count,
    );
    params['ctime'] = _cTime;
    params['version'] = _version;
    params['apiKey'] = _apiKey;
    return params;
  }

  Future<Map> _sendRequest(
    String path, {
    String? id,
    String? type,
    int? page,
    int? count,
    Map<String, dynamic>? extra,
    List<int> allowedErrorCodes = const [],
  }) async {
    int retries = 3;
    late Response resp;

    while (retries > 0) {
      retries--;
      resp = await dio.get(
        "$_baseUrl$path",
        queryParameters: _prepParam(
          path,
          id: id,
          type: type,
          page: page,
          count: count,
          extra: extra,
        ),
      );
      if (resp.data['err'] != -201) {
        debugPrint('Request sent: ${resp.requestOptions.uri}');
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    }

    if (resp.data['err'] != 0 &&
        !allowedErrorCodes.contains(resp.data['err'])) {
      throw Exception(
        'Unexpected eror code: ${resp.data['err']}. Resp data: ${resp.data}',
      );
    }

    return resp.data;
  }

  Future<Map> getSong(String songId) {
    final path = "/api/v2/song/get/streaming";
    return _sendRequest(path, id: songId, allowedErrorCodes: [-1150]);
  }

  Future<Map> getDetailPlaylist(String playlistId) {
    final path = "/api/v2/page/get/playlist";
    return _sendRequest(path, id: playlistId, allowedErrorCodes: [-1031]);
  }

  Future<Map> getHome({int page = 1}) {
    if (page <= 0) {
      throw ArgumentError.value(page, "page", "page must be at least 1");
    }
    final path = "/api/v2/page/get/home";
    return _sendRequest(
      path,
      page: page,
      count: 30,
      extra: {'segmentId': '-1'},
    );
  }

  Future<Map> getTop100({int page = 1}) {
    final path = "/api/v2/page/get/top-100";
    return _sendRequest(path);
  }

  Future<Map> getChartHome() {
    final path = "/api/v2/page/get/chart-home";
    return _sendRequest(path);
  }

  Future<Map> getNewReleaseChart() {
    final path = "/api/v2/page/get/newrelease-chart";
    return _sendRequest(path);
  }

  Future<Map> getInfoSong(String songId) {
    final path = "/api/v2/song/get/info";
    return _sendRequest(path, id: songId, allowedErrorCodes: [-1023]);
  }

  Future<Map> getListArtistSong({
    required String artistId,
    required int page,
    required int count,
  }) {
    final path = "/api/v2/song/get/list";
    return _sendRequest(
      path,
      id: artistId,
      type: "artist",
      page: page,
      count: count,
      extra: {'sort': 'new', 'sectionId': 'aSong'},
    );
  }

  Future<Map> getArtist(String artistAlias) {
    final path = "/api/v2/page/get/artist";
    return _sendRequest(
      path,
      extra: {'alias': artistAlias},
      allowedErrorCodes: [-108],
    );
  }

  Future<Map> getLyric(String songId) {
    final path = "/api/v2/lyric/get/lyric";
    return _sendRequest(path, id: songId);
  }

  Future<Map> multiSearch(String keyword) {
    final path = "/api/v2/search/multi";
    return _sendRequest(path, extra: {'q': keyword});
  }

  Future<Map> _filteredSearch(String type, String keyword, {int page = 1}) {
    if (page <= 0) {
      throw ArgumentError.value(page, "page", "page must be at least 1");
    }
    final path = "/api/v2/search";

    return _sendRequest(path, type: type, page: page, count: 16, extra: {'q': keyword});
  }

  Future<Map> searchSongs(String keyword, {int page = 1}) {
    return _filteredSearch('song', keyword, page: page);
  }

  Future<Map> searchArtists(String keyword, {int page = 1}) {
    return _filteredSearch('artist', keyword, page: page);
  }

  Future<Map> searchPlaylists(String keyword, {int page = 1}) {
    return _filteredSearch('playlist', keyword, page: page);
  }
}
