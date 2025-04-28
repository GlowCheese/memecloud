import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/storage.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/blocs/gradient_bg/bg_cubit.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_cubit.dart';
import 'package:memecloud/core/dio_init.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // gradient background
  getIt.registerSingleton<BgCubit>(BgCubit());

  // oh, you're approaching me?
  final (dio, cookieJar) = await createDioWithPersistentCookies();
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<CookieJar>(cookieJar);
  getIt.registerSingleton<ZingMp3Api>(ZingMp3Api(dio: dio));

  // local storage & api kit
  final storage = await PersistentStorage.initialize();
  getIt.registerSingleton<PersistentStorage>(storage);
  final apiKit = await ApiKit.initialize(storage: storage);
  getIt.registerSingleton<ApiKit>(apiKit);

  // song player
  final playerCubit = SongPlayerCubit();
  getIt.registerSingleton<SongPlayerCubit>(playerCubit);
  getIt.registerSingleton<AudioPlayer>(playerCubit.audioPlayer);

  // miscs
  getIt.registerSingleton<LikedSongsCubit>(LikedSongsCubit());
}
