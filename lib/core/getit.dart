import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:memecloud/apis/supabase/auth.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/dio_init.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/blocs/song_player/song_player_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // supabase
  await initializeSupabase();
  final _supabaseApi = SupabaseApi();
  getIt.registerSingleton<SupabaseApi>(_supabaseApi);
  getIt.registerSingleton<SupabaseAuthApi>(_supabaseApi.auth);
  getIt.registerSingleton<SupabaseSongsApi>(_supabaseApi.songs);

  // oh, you're approaching me?
  final (dio, cookieJar) = await createDioWithPersistentCookies();
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<CookieJar>(cookieJar);
  getIt.registerSingleton<ZingMp3Api>(ZingMp3Api(dio: dio));

  // song player
  getIt.registerSingleton<SongPlayerCubit>(SongPlayerCubit());
}
