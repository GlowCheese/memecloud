import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';

void main() async {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
    await setupLocator();
  });

  test('fetchSongUrl', () async {
    final id = 'Z78BZ0D7';
    Either response = await getIt<ZingMp3Api>().fetchSongUrl(id);
    String? songUrl = response.getOrElse(() => null);
    debugPrint('Song URL for $id: $songUrl');
    expect(songUrl, isA<String?>());
  });
}