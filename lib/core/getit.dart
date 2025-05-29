import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/others/events.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:memecloud/apis/zingmp3/requester.dart';
import 'package:memecloud/blocs/dl_status/dl_status_manager.dart';
import 'package:memecloud/blocs/recent_played/recent_played_stream.dart';
import 'package:memecloud/core/dio_init.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // oh, you're approaching me?
  final (dio, cookieJar) = await createDioWithPersistentCookies();
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<CookieJar>(cookieJar);
  getIt.registerSingleton<ConnectivityStatus>(ConnectivityStatus());

  // ZingMp3 API
  getIt.registerSingleton<ZingMp3Requester>(ZingMp3Requester());
  getIt.registerSingleton<ZingMp3Api>(ZingMp3Api());

  // Supabase API
  final supabase = await SupabaseApi.initialize();
  getIt.registerSingleton<SupabaseApi>(supabase);

  // local storage & api kit
  final storage = await PersistentStorage.initialize();
  getIt.registerSingleton<PersistentStorage>(storage);
  final apiKit = getIt.registerSingleton<ApiKit>(ApiKit());
  getIt.registerSingleton<SupabaseEvents>(await SupabaseEvents.initialize());
  
  // miscellaneous
  getIt.registerSingleton<DlStatusManager>(DlStatusManager());
  getIt.registerSingleton<LikedSongsStream>(LikedSongsStream());
  getIt.registerSingleton<RecentPlayedStream>(RecentPlayedStream());

  // custom cookie for vip songs
  dioInterceptorSetCustomCookie(dio, cookieJar, (await supabase.config.getZingCookie())!);
  dioInterceptorUpdateCookieOnSet(dio, apiKit);

  // song player
  final playerCubit = SongPlayerCubit();
  getIt.registerSingleton<SongPlayerCubit>(playerCubit);
  getIt.registerSingleton<AudioPlayer>(playerCubit.audioPlayer);

  // post setup locator cleanup
  await postSetupLocator();
}

Future<void> postSetupLocator() async {
  getIt.unregister<CookieJar>();
  getIt.unregister<ZingMp3Requester>();
  getIt.unregister<PersistentStorage>();
}
