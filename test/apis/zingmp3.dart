import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';

final songId = 'Z78BZ0D7';
final songTitle = 'Giá Như';
final songAlias = 'Gia-Nhu-SOOBIN';

void main() async {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
    await setupLocator();
  });

  test('fetchSongUrl', () async {
    Either response = await getIt<ZingMp3Api>().fetchSongUrl(songId);
    response.fold((left) {}, (right) {
      expect(right, isA<String>());
      debugPrint('Song URL for $songId: $right');
    });
  });

  test('fetchSongInfo', () async {
    Either response = await getIt<ZingMp3Api>().fetchSongInfo(songId);
    response.fold((left) {}, (right) {
      expect(right, isA<Map>());
      expect(right['alias'], songAlias);
    });
  });

  test('search', () async {
    Either response = await getIt<ZingMp3Api>().search(songTitle);
    response.fold((left) {}, (right) {
      expect(right, isA<Map>());
      expect(right, contains('songs'));
    });
  });
}
